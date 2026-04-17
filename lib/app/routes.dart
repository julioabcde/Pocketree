import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pocketree/app/main_shell.dart';
import 'package:pocketree/core/di/injection_container.dart';
import 'package:pocketree/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:pocketree/features/auth/presentation/bloc/auth_state.dart';
import 'package:pocketree/features/auth/presentation/screens/auth_screen.dart';
import 'package:pocketree/features/home/presentation/screens/home_screen.dart';
import 'package:pocketree/features/recurring/presentation/bloc/recurring_bloc.dart';
import 'package:pocketree/features/recurring/presentation/screens/add_recurring_screen.dart';
import 'package:pocketree/features/splitbill/presentation/args/assign_items_args.dart';
import 'package:pocketree/features/transactions/presentation/bloc/transaction_bloc.dart';
import 'package:pocketree/features/transactions/presentation/screens/add_transactions_screen.dart';
import 'package:pocketree/features/transactions/presentation/screens/edit_transaction_screen.dart';
import 'package:pocketree/features/transactions/domain/entities/transaction.dart';
import 'package:pocketree/features/reports/presentation/bloc/reports_bloc.dart';
import 'package:pocketree/features/reports/presentation/screens/reports_screen.dart';
import 'package:pocketree/features/settings/presentation/screens/settings_screen.dart';
import 'package:pocketree/features/accounts/domain/entities/account.dart';
import 'package:pocketree/features/accounts/presentation/screens/account_history_screen.dart';
import 'package:pocketree/features/accounts/presentation/screens/accounts_screen.dart';
import 'package:pocketree/features/categories/presentation/screens/category_management_screen.dart';
import 'package:pocketree/features/transactions/presentation/screens/transactions_screen.dart';
import 'package:pocketree/features/splitbill/presentation/bloc/splitbill_bloc.dart';
import 'package:pocketree/features/splitbill/presentation/bloc/splitbill_detail_bloc.dart';
import 'package:pocketree/features/splitbill/presentation/args/create_splitbill_args.dart';
import 'package:pocketree/features/splitbill/presentation/screens/assign_items_screen.dart';
import 'package:pocketree/features/splitbill/presentation/screens/create_splitbill_screen.dart';
import 'package:pocketree/features/splitbill/presentation/screens/splitbill_detail_screen.dart';
import 'package:pocketree/features/splitbill/presentation/screens/splitbill_screen.dart';

GoRouter createRouter(AuthBloc authBloc) {
  return GoRouter(
    initialLocation: '/home',
    refreshListenable: _GoRouterRefreshStream(authBloc.stream),
    redirect: (context, state) {
      final authState = context.read<AuthBloc>().state;
      final isAuthenticated = authState is AuthAuthenticated;
      final isOnAuthRoute = state.matchedLocation == '/auth';

      if (authState is AuthLoading || authState is AuthInitial) return null;
      if (!isAuthenticated && !isOnAuthRoute) return '/auth';
      if (isAuthenticated && isOnAuthRoute) return '/home';
      return null;
    },
    routes: [
      GoRoute(path: '/auth', builder: (context, state) => const AuthScreen()),
      GoRoute(
        path: '/accounts',
        builder: (context, state) => const AccountsScreen(),
      ),
      GoRoute(
        path: '/account-history',
        builder: (context, state) =>
            AccountHistoryScreen(account: state.extra! as Account),
      ),
      GoRoute(
        path: '/category-management',
        builder: (context, state) => const CategoryManagementScreen(),
      ),
      GoRoute(
        path: '/add-transaction',
        builder: (context, state) => BlocProvider(
          create: (_) => sl<TransactionBloc>(),
          child: const AddTransactionScreen(),
        ),
      ),
      GoRoute(
        path: '/edit-transaction',
        builder: (context, state) => BlocProvider(
          create: (_) => sl<TransactionBloc>(),
          child: EditTransactionScreen(
            transaction: state.extra! as Transaction,
          ),
        ),
      ),
      GoRoute(
        path: '/add-recurring',
        builder: (context, state) => BlocProvider(
          create: (_) => sl<RecurringBloc>(),
          child: const AddRecurringScreen(),
        ),
      ),
      GoRoute(
        path: '/splitbill',
        builder: (context, state) => const SplitbillScreen(),
      ),
      GoRoute(
        path: '/create-splitbill',
        builder: (context, state) => BlocProvider(
          create: (_) => sl<SplitBillBloc>(),
          child: CreateSplitbillScreen(
            args: state.extra as CreateSplitbillArgs?,
          ),
        ),
      ),
      GoRoute(
        path: '/assign-items',
        builder: (context, state) {
          final args = state.extra as AssignItemsArgs?;
          if (args == null) return const SizedBox.shrink();
          return BlocProvider(
            create: (_) => sl<SplitBillDetailBloc>(),
            child: AssignItemsScreen(
              billId: args.billId,
              isNewBill: args.isNewBill,
            ),
          );
        },
      ),
      GoRoute(
        path: '/splitbill-detail',
        builder: (context, state) => BlocProvider(
          create: (_) => sl<SplitBillDetailBloc>(),
          child: SplitbillDetailScreen(billId: state.extra! as int),
        ),
      ),

      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/transactions',
                builder: (context, state) => BlocProvider(
                  create: (_) => sl<TransactionBloc>(),
                  child: const TransactionsScreen(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/reports',
                builder: (context, state) => BlocProvider(
                  create: (_) => sl<ReportsBloc>(),
                  child: const ReportsScreen(),
                ),
              ),
            ],
          ),
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
