import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pocketree/core/di/injection_container.dart';
import 'package:pocketree/core/theme/app_colors.dart';
import 'package:pocketree/features/home/presentation/bloc/home_bloc.dart';
import 'package:pocketree/features/home/presentation/bloc/home_event.dart';
import 'package:pocketree/features/recurring/presentation/bloc/recurring_bloc.dart';
import 'package:pocketree/features/recurring/presentation/bloc/recurring_event.dart';
import 'package:pocketree/features/recurring/presentation/bloc/recurring_state.dart';
import 'package:pocketree/features/transactions/presentation/bloc/calender_bloc.dart';
import 'package:pocketree/features/transactions/presentation/bloc/calender_event.dart';
import 'package:pocketree/features/transactions/presentation/bloc/calender_state.dart';
import 'package:pocketree/features/transactions/presentation/bloc/transaction_bloc.dart';
import 'package:pocketree/features/transactions/presentation/bloc/transaction_state.dart';
import 'package:pocketree/features/transactions/presentation/screens/calender_tab_view.dart';
import 'package:pocketree/features/transactions/presentation/screens/subscriptions_tab_view.dart';

enum _TransactionsTab { calendar, subscriptions, shared }

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen>
    with WidgetsBindingObserver {
  late final CalendarBloc _calendarBloc;
  late final TransactionBloc _transactionBloc;
  late final RecurringBloc _recurringBloc;

  _TransactionsTab _activeTab = _TransactionsTab.calendar;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    _calendarBloc = sl<CalendarBloc>()
      ..add(CalendarMonthRequested(month: DateTime.now()));
    _transactionBloc = sl<TransactionBloc>();
    _recurringBloc = sl<RecurringBloc>();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _calendarBloc.close();
    _transactionBloc.close();
    _recurringBloc.close();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _syncMonthToToday();
    }
  }

  void _syncMonthToToday() {
    final now = DateTime.now();
    final calendarState = _calendarBloc.state;

    if (calendarState is CalendarLoaded) {
      final isSameMonth =
          calendarState.currentMonth.year == now.year &&
          calendarState.currentMonth.month == now.month;

      if (!isSameMonth) {
        _calendarBloc.add(CalendarMonthRequested(month: now));
      }
    } else if (calendarState is CalendarInitial) {
      _calendarBloc.add(CalendarMonthRequested(month: now));
    }
  }

  void _refreshCurrentDay() {
    final calendarState = _calendarBloc.state;
    if (calendarState is CalendarLoaded) {
      _calendarBloc.add(CalendarDaySelected(date: calendarState.selectedDate));
    }
  }

  void _onTabChanged(_TransactionsTab tab) {
    setState(() => _activeTab = tab);
    if (tab == _TransactionsTab.calendar) {
      _syncMonthToToday();
      _refreshCurrentDay();
    }
    if (tab == _TransactionsTab.subscriptions) {
      _recurringBloc.add(const RecurringDataRequested());
    }
  }

  void _refreshCalendarMonth() {
    final calendarState = _calendarBloc.state;
    if (calendarState is CalendarLoaded) {
      _calendarBloc
        ..add(CalendarMonthRequested(month: calendarState.currentMonth))
        ..add(CalendarDaySelected(date: calendarState.selectedDate));
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _calendarBloc),
        BlocProvider.value(value: _transactionBloc),
        BlocProvider.value(value: _recurringBloc),
      ],
      child: MultiBlocListener(
        listeners: [
          // When a transaction is mutated here, also refresh HomeBloc.
          // HomeBloc is a lazySingleton so sl() returns the same instance
          // that HomeScreen is using.
          BlocListener<TransactionBloc, TransactionState>(
            listener: (context, state) {
              if (state is TransactionActionSuccess) {
                sl<HomeBloc>().add(const HomeDataRequested());
              }
            },
          ),
          // When a recurring is executed/created, a real transaction is
          // created on the backend — refresh the calendar to reflect it.
          BlocListener<RecurringBloc, RecurringState>(
            listener: (context, state) {
              if (state is RecurringActionSuccess) {
                _refreshCalendarMonth();
              }
            },
          ),
        ],
        child: _TransactionsView(
          activeTab: _activeTab,
          onTabChanged: _onTabChanged,
        ),
      ),
    );
  }
}

class _TransactionsView extends StatelessWidget {
  final _TransactionsTab activeTab;
  final ValueChanged<_TransactionsTab> onTabChanged;

  const _TransactionsView({
    required this.activeTab,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutralCream,
      floatingActionButton: activeTab == _TransactionsTab.subscriptions
          ? FloatingActionButton(
              heroTag: 'addRecurring',
              onPressed: () async {
                final created =
                    await GoRouter.of(context).push<bool>('/add-recurring');
                if (created == true && context.mounted) {
                  context
                      .read<RecurringBloc>()
                      .add(const RecurringDataRequested());
                }
              },
              backgroundColor: AppColors.brownEspresso,
              child: const Icon(
                Icons.add_rounded,
                color: AppColors.white,
                size: 28,
              ),
            )
          : null,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 16, 0),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Transactions',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: AppColors.brownEspresso,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.search_rounded,
                      color: AppColors.primaryForest,
                      size: 24,
                    ),
                    onPressed: () {
                      // TODO: Transaction search
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Tab Switcher
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: _TabSwitcher(
                activeTab: activeTab,
                onTabChanged: onTabChanged,
              ),
            ),
            const SizedBox(height: 24),

            // Tab Content
            Expanded(
              child: switch (activeTab) {
                _TransactionsTab.calendar => const CalendarTabView(),
                _TransactionsTab.subscriptions => const SubscriptionsTabView(),
                _TransactionsTab.shared => const _PlaceholderTab(
                  icon: Icons.group_outlined,
                  title: 'Shared Expenses',
                  subtitle: 'View your split bill history',
                ),
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ─
// Tab switcher widget
// ─
class _TabSwitcher extends StatelessWidget {
  final _TransactionsTab activeTab;
  final ValueChanged<_TransactionsTab> onTabChanged;

  const _TabSwitcher({required this.activeTab, required this.onTabChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: AppColors.neutralSand,
        borderRadius: BorderRadius.circular(25),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: _TransactionsTab.values.map((tab) {
          final isActive = activeTab == tab;
          final label = switch (tab) {
            _TransactionsTab.calendar => 'Calendar',
            _TransactionsTab.subscriptions => 'Subscriptions',
            _TransactionsTab.shared => 'Shared',
          };

          return Expanded(
            child: GestureDetector(
              onTap: () => onTabChanged(tab),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                decoration: BoxDecoration(
                  color: isActive
                      ? AppColors.brownEspresso
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(22),
                ),
                alignment: Alignment.center,
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isActive ? AppColors.white : AppColors.brownMocha,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ─
// Generic placeholder for unbuilt tabs
// ─
class _PlaceholderTab extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _PlaceholderTab({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.primaryForest.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 36,
                color: AppColors.primaryForest.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.brownEspresso,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: AppColors.brownMocha),
            ),
          ],
        ),
      ),
    );
  }
}
