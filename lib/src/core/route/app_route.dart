import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sewsafe_mobile/src/features/auth/frontend/presentation/screens/auth/auth.dart';
import 'package:sewsafe_mobile/src/features/auth/frontend/presentation/screens/auth/forgot_password.dart';
import 'package:sewsafe_mobile/src/features/auth/frontend/presentation/screens/auth/verify_password_reset.dart';
import 'package:sewsafe_mobile/src/features/auth/frontend/presentation/screens/home.dart';
import 'package:sewsafe_mobile/src/features/auth/backend/data/auth_repository.dart';

// 1. Route Enums: You will never type a raw string like '/home' again.
enum AppRoute { splash, onboarding, login, signup, home, addClient, forgotPassword, verifyPasswordReset }

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
      final isGoingToAuth = state.matchedLocation == '/login' || state.matchedLocation == '/signup';

      if (!isLoggedIn && !isGoingToAuth) return '/signup';
      if (isLoggedIn && isGoingToAuth) return '/home';

      return null;
    },

    // 4. The Strictly Typed Routes
    routes: [
      GoRoute(
        path: '/login',
        name: AppRoute.login.name,
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('Login Screen Setup')), // Placeholder
        ),
      ),
      GoRoute(
        path: '/signup',
        name: AppRoute.signup.name,
        builder: (context, state) => const AuthScreen(),
      ),
      GoRoute(
        path: '/home',
        name: AppRoute.home.name,
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        name: AppRoute.forgotPassword.name,
        builder: (context, state) => ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/verify-password-reset',
        name: AppRoute.verifyPasswordReset.name,
        builder: (context, state) => const VerifyPasswordResetScreen(),
      ),
    ],
  );
});
