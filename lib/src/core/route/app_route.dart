import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sewsafe_mobile/src/features/auth/frontend/presentation/screens/auth/auth.dart';
import 'package:sewsafe_mobile/src/features/auth/frontend/presentation/screens/auth/forgot_password.dart';
import 'package:sewsafe_mobile/src/features/auth/frontend/presentation/screens/auth/verify_email.dart';
import 'package:sewsafe_mobile/src/features/auth/frontend/presentation/screens/auth/verify_password_reset.dart';
import 'package:sewsafe_mobile/src/features/auth/frontend/presentation/screens/dashboard.dart';
import 'package:sewsafe_mobile/src/features/auth/backend/data/auth_repository.dart';
import 'package:sewsafe_mobile/src/features/customer_management/presentation/screens/new_client_record_screen.dart';

// 1. Route Enums: You will never type a raw string like '/home' again.
enum AppRoute { splash, onboarding, login, signup, home, addClient, forgotPassword, verifyPasswordReset, verifyEmail }

// 2. The Router Provider
final goRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateChangesProvider);

  return GoRouter(
    initialLocation: '/signup', // We start inside-out, focusing on Auth first
    debugLogDiagnostics: true, // Prints route changes in your terminal!
    // 3. The Active Gatekeeper
    redirect: (context, state) {
      if (authState.isLoading || !authState.hasValue) return null;

      final isLoggedIn = authState.value != null;
      final isGoingToAuth = state.matchedLocation == '/login' || 
                            state.matchedLocation == '/signup' || 
                            state.matchedLocation == '/verify-email' ||
                            state.matchedLocation == '/forgot-password' ||
                            state.matchedLocation == '/verify-password-reset';

      if (!isLoggedIn && !isGoingToAuth) return '/signup';
      if (isLoggedIn && isGoingToAuth) return '/home';

      return null;
    },

    // 4. The Strictly Typed Routes
    routes: [
      GoRoute(
        path: '/login',
        name: AppRoute.login.name,
        builder: (context, state) => const AuthScreen(isLoginInitially: true),
      ),
      GoRoute(
        path: '/signup',
        name: AppRoute.signup.name,
        builder: (context, state) => const AuthScreen(isLoginInitially: false),
      ),
      GoRoute(
        path: '/verify-email',
        name: AppRoute.verifyEmail.name,
        builder: (context, state) {
          final email = state.uri.queryParameters['email'] ?? '';
          return VerifyEmailScreen(email: email);
        },
      ),
      GoRoute(
        path: '/home',
        name: AppRoute.home.name,
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: '/add-client',
        name: AppRoute.addClient.name,
        builder: (context, state) => const NewClientRecordScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        name: AppRoute.forgotPassword.name,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/verify-password-reset',
        name: AppRoute.verifyPasswordReset.name,
        builder: (context, state) {
          final email = state.uri.queryParameters['email'] ?? '';
          return VerifyPasswordResetScreen(email: email);
        },
      ),
    ],
  );
});
