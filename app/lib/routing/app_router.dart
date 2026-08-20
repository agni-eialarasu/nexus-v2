import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../features/auth/providers/auth_provider.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/dashboard/screens/dashboard_screen.dart';
import '../providers/rbac_provider.dart';
import 'app_shell.dart';

part 'app_router.g.dart';

/// Application router configuration.
///
/// Routes are tenant-scoped: /org/:slug/...
/// Auth state determines redirect behavior.
@riverpod
GoRouter appRouter(Ref ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final isLoggedIn = authState.valueOrNull != null;
      final isOnLogin = state.matchedLocation == '/login';
      final isOnRegister = state.matchedLocation == '/register';

      // Not logged in → redirect to login (unless already there)
      if (!isLoggedIn && !isOnLogin && !isOnRegister) {
        return '/login';
      }

      // Logged in but on login page → redirect to dashboard
      if (isLoggedIn && (isOnLogin || isOnRegister)) {
        return '/'; // Will resolve to default tenant dashboard
      }

      return null; // No redirect
    },
    routes: [
      // ─── Public Routes ───────────────────────────────────────────
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),

      // ─── Authenticated Routes (with app shell) ──────────────────
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: '/',
            name: 'home',
            redirect: (context, state) {
              // TODO: Redirect to /:tenantSlug/dashboard
              return null;
            },
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: '/org/:slug/dashboard',
            name: 'dashboard',
            builder: (context, state) => const DashboardScreen(),
          ),
          // TODO: Add feature routes here as they're built
          // GoRoute(path: '/org/:slug/projects', ...),
          // GoRoute(path: '/org/:slug/portfolios', ...),
          // GoRoute(path: '/org/:slug/okrs', ...),
        ],
      ),
    ],
  );
}
