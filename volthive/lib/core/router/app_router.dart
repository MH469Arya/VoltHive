import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:volthive/features/auth/presentation/screens/splash_screen.dart';
import 'package:volthive/features/auth/presentation/screens/onboarding_screen.dart';
import 'package:volthive/features/auth/presentation/screens/login_screen.dart';
import 'package:volthive/features/auth/presentation/screens/sign_up_screen.dart';
import 'package:volthive/features/main_navigation/presentation/screens/main_navigation_screen.dart';

/// App router configuration using go_router
class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      // Splash Screen
      GoRoute(
        path: '/',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),

      // Onboarding
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),

      // Login
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),

      // Sign Up
      GoRoute(
        path: '/signup',
        name: 'signup',
        builder: (context, state) => const SignUpScreen(),
      ),

      // Main Navigation (Home, Dashboard, Plans, Billing, Support)
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const MainNavigationScreen(),
      ),

      // Plan Details (will implement later)
      // GoRoute(
      //   path: '/plans/:planId',
      //   name: 'planDetails',
      //   builder: (context, state) {
      //     final planId = state.pathParameters['planId']!;
      //     return PlanDetailsScreen(planId: planId);
      //   },
      // ),

      // Subscription Flow (will implement later)
      // GoRoute(
      //   path: '/subscription-flow',
      //   name: 'subscriptionFlow',
      //   builder: (context, state) => const SubscriptionFlowScreen(),
      // ),

      // Ticket Details (will implement later)
      // GoRoute(
      //   path: '/ticket/:ticketId',
      //   name: 'ticketDetails',
      //   builder: (context, state) {
      //     final ticketId = state.pathParameters['ticketId']!;
      //     return TicketDetailsScreen(ticketId: ticketId);
      //   },
      // ),
    ],

    // Error handling
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Page not found: ${state.matchedLocation}'),
      ),
    ),
  );
}
