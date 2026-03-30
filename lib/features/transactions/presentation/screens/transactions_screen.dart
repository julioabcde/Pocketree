import 'package:flutter/material.dart';
import 'package:pocketree/core/theme/app_colors.dart';

enum _TransactionsTab { calendar, subscriptions, shared }

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  _TransactionsTab _activeTab = _TransactionsTab.calendar;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutralCream,
      body: SafeArea(
        child: Column(
          children: [
            //  Header 
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

            //  Tab Switcher 
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: _buildTabSwitcher(),
            ),
            const SizedBox(height: 24),

            //  Tab Content 
            Expanded(
              child: switch (_activeTab) {
                _TransactionsTab.calendar => _buildCalendarPlaceholder(),
                _TransactionsTab.subscriptions =>
                  _buildSubscriptionsPlaceholder(),
                _TransactionsTab.shared => _buildSharedPlaceholder(),
              },
            ),
          ],
        ),
      ),
    );
  }

  //  Tab Switcher 

  Widget _buildTabSwitcher() {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: AppColors.neutralSand,
        borderRadius: BorderRadius.circular(25),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: _TransactionsTab.values.map((tab) {
          final isActive = _activeTab == tab;
          final label = switch (tab) {
            _TransactionsTab.calendar => 'Calendar',
            _TransactionsTab.subscriptions => 'Subscriptions',
            _TransactionsTab.shared => 'Shared',
          };

          return Expanded(
            child: GestureDetector(
              onTap: () {
                if (tab == _activeTab) return;
                setState(() => _activeTab = tab);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                decoration: BoxDecoration(
                  color: isActive ? AppColors.brownEspresso : Colors.transparent,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: isActive
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.06),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : [],
                ),
                alignment: Alignment.center,
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isActive
                        ? AppColors.white
                        : AppColors.brownMocha,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  //  Placeholder Builders 

  Widget _buildCalendarPlaceholder() {
    return _PlaceholderTab(
      icon: Icons.calendar_month_outlined,
      title: 'Calendar View',
      subtitle: 'View your daily transactions on a calendar',
    );
  }

  Widget _buildSubscriptionsPlaceholder() {
    return _PlaceholderTab(
      icon: Icons.autorenew_rounded,
      title: 'Subscriptions',
      subtitle: 'Track your recurring payments and subscriptions',
    );
  }

  Widget _buildSharedPlaceholder() {
    return _PlaceholderTab(
      icon: Icons.group_outlined,
      title: 'Shared Expenses',
      subtitle: 'View your split bill history',
    );
  }
}

//  Reusable placeholder widget 

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
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.brownMocha,
              ),
            ),
          ],
        ),
      ),
    );
  }
}