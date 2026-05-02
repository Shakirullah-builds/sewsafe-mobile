import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// 1. Route Enums: You will never type a raw string like '/home' again.
enum AppRoute {
  splash,
  onboarding,
  login,
  signup,
  home,
  addClient,
}

// 2. The Router Provider
final goRouterProvider = Provider<GoRouter>((ref) {
  
  // (We will hook this up when we build the Auth Controller!)
  // final authState = ref.watch(authControllerProvider); 

  return GoRouter(
    initialLocation: '/login', // We start inside-out, focusing on Auth first
    debugLogDiagnostics: true, // Prints route changes in your terminal!
    
    // 3. The Active Gatekeeper
    redirect: (context, state) {
      // NOTE: This is pseudo-code until we build Supabase auth, but this is the logic:
      
      /*
      final isLoggedIn = authState.user != null;
      final isGoingToAuth = state.matchedLocation == '/login' || state.matchedLocation == '/signup';

      // If they are not logged in, and trying to go to Home, kick them to Login
      if (!isLoggedIn && !isGoingToAuth) return '/login';
      
      // If they ARE logged in, and trying to view the Login screen, push them to Home
      if (isLoggedIn && isGoingToAuth) return '/home';
      */

      return null; // Return null means "proceed as normal"
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
        path: '/home',
        name: AppRoute.home.name,
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('Home Screen Setup')), // Placeholder
        ),
      ),
    ],
  );
});