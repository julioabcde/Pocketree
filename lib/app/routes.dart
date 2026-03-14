import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pocketree/app/main_shell.dart';
import 'package:pocketree/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:pocketree/features/auth/presentation/bloc/auth_state.dart';
import 'package:pocketree/features/auth/presentation/screens/auth_screen.dart';
import 'package:pocketree/features/home/presentation/screens/home_screen.dart';
import 'package:pocketree/features/transactions/presentation/screens/transactions_screen.dart';
import 'package:pocketree/features/splitbill/presentation/screens/splitbill_screen.dart';
import 'package:pocketree/features/reports/presentation/screens/reports_screen.dart';
import 'package:pocketree/features/settings/presentation/screens/settings_screen.dart';

GoRouter createRouter(AuthBloc authBloc) {
  return GoRouter(
    initialLocation: '/home',
    refreshListenable: _GoRouterRefreshStream(authBloc.stream),
    redirect: (context, state) {
      final authState = context.read<AuthBloc>().state;

      if (authState is AuthInitial || authState is AuthLoading) return null;

      final isAuthenticated = authState is AuthAuthenticated;
      final isOnAuthRoute = state.matchedLocation == '/auth';

      if (!isAuthenticated && !isOnAuthRoute) return '/auth';
      if (isAuthenticated && isOnAuthRoute) return '/home';
      return null;
    },
    routes: [
      // Auth — standalone, no nav bar
      GoRoute(
        path: '/auth',
        builder: (context, state) => const AuthScreen(),
      ),

      // Split Bill — standalone modal action, no nav bar
      GoRoute(
        path: '/splitbill',
        builder: (context, state) => const SplitbillScreen(),
      ),

      // Main app shell — 4 branches with persistent bottom nav
      // Branch order MUST match visual tab order in MainShell
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainShell(navigationShell: navigationShell);
        },
        branches: [
          // Index 0 — Home
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),

          // Index 1 — Transactions
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/transactions',
                builder: (context, state) => const TransactionsScreen(),
              ),
            ],
          ),

          // Index 2 — Reports
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/reports',
                builder: (context, state) => const ReportsScreen(),
              ),
            ],
          ),

          // Index 3 — Settings
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/settings',
                builder: (context, state) => const SettingsScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

class _GoRouterRefreshStream extends ChangeNotifier {
  late final StreamSubscription<dynamic> _subscription;

  _GoRouterRefreshStream(Stream<dynamic> stream) {
    _subscription = stream.listen((_) => notifyListeners());
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}