import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pocketree/core/theme/app_colors.dart';

class MainShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainShell({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    final currentIndex = navigationShell.currentIndex;

    return Scaffold(
      body: navigationShell,
      floatingActionButton: Container(
        height: 60,
        width: 60,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: AppColors.primaryGradient,
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryForest.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: () => GoRouter.of(context).push('/splitbill'),
          elevation: 0,
          backgroundColor: Colors.transparent,
          shape: const CircleBorder(),
          child: const Icon(
            Icons.call_split_rounded,
            color: AppColors.white,
            size: 26,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      bottomNavigationBar: BottomAppBar(
        height: 72,
        padding: EdgeInsets.zero,
        color: AppColors.white,
        surfaceTintColor: Colors.transparent,
        notchMargin: 8,
        shape: const CircularNotchedRectangle(),
        child: Row(
          children: [

            // Home
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => navigationShell.goBranch(
                  0,
                  initialLocation: 0 == currentIndex,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      currentIndex == 0
                          ? Icons.home_rounded
                          : Icons.home_outlined,
                      color: currentIndex == 0
                          ? AppColors.primaryForest
                          : AppColors.brownMocha,
                      size: 24,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Home',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: currentIndex == 0
                            ? FontWeight.w600
                            : FontWeight.w400,
                        color: currentIndex == 0
                            ? AppColors.primaryForest
                            : AppColors.brownMocha,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),

            // Transactions
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => navigationShell.goBranch(
                  1,
                  initialLocation: 1 == currentIndex,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      currentIndex == 1
                          ? Icons.receipt_long_rounded
                          : Icons.receipt_long_outlined,
                      color: currentIndex == 1
                          ? AppColors.primaryForest
                          : AppColors.brownMocha,
                      size: 24,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Transactions',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: currentIndex == 1
                            ? FontWeight.w600
                            : FontWeight.w400,
                        color: currentIndex == 1
                            ? AppColors.primaryForest
                            : AppColors.brownMocha,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),

            // Center Spacer 
            const Expanded(child: SizedBox()),

            // Reports
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => navigationShell.goBranch(
                  2,
                  initialLocation: 2 == currentIndex,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      currentIndex == 2
                          ? Icons.assessment_rounded
                          : Icons.assessment_outlined,
                      color: currentIndex == 2
                          ? AppColors.primaryForest
                          : AppColors.brownMocha,
                      size: 24,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Reports',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: currentIndex == 2
                            ? FontWeight.w600
                            : FontWeight.w400,
                        color: currentIndex == 2
                            ? AppColors.primaryForest
                            : AppColors.brownMocha,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),

            // Settings
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => navigationShell.goBranch(
                  3,
                  initialLocation: 3 == currentIndex,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      currentIndex == 3
                          ? Icons.settings_rounded
                          : Icons.settings_outlined,
                      color: currentIndex == 3
                          ? AppColors.primaryForest
                          : AppColors.brownMocha,
                      size: 24,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Settings',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: currentIndex == 3
                            ? FontWeight.w600
                            : FontWeight.w400,
                        color: currentIndex == 3
                            ? AppColors.primaryForest
                            : AppColors.brownMocha,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}