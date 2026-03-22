import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pocketree/core/theme/app_colors.dart';
import 'package:pocketree/features/accounts/domain/entities/account.dart';
import 'package:pocketree/features/home/presentation/bloc/home_bloc.dart';
import 'package:pocketree/features/home/presentation/bloc/home_event.dart';
import 'package:pocketree/features/home/presentation/widgets/wallet_card.dart';

class WalletSectionDelegate extends SliverPersistentHeaderDelegate {
  final List<Account> accounts;
  final int currentPage;
  final PageController pageController;
  final ValueChanged<int> onPageChanged;
  final double height;

  WalletSectionDelegate({
    required this.accounts,
    required this.currentPage,
    required this.pageController,
    required this.onPageChanged,
    required this.height,
  });

  @override
  double get minExtent => height;

  @override
  double get maxExtent => height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: AppColors.neutralCream,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'My Wallets',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.brownEspresso,
                  ),
                ),
                GestureDetector(
                  onTap: () async {
                    await GoRouter.of(context).push('/accounts');
                    if (context.mounted) {
                      context
                          .read<HomeBloc>()
                          .add(const HomeDataRequested());
                    }
                  },
                  child: const Text(
                    'See All',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.primaryForest,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Wallet cards pageView
          SizedBox(
            height: 200,
            child: PageView.builder(
              controller: pageController,
              itemCount: accounts.length,
              onPageChanged: onPageChanged,
              padEnds: true,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: WalletCard(account: accounts[index]),
                );
              },
            ),
          ),
          const SizedBox(height: 12),

          // Page indicator dots
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              accounts.length,
              (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: index == currentPage ? 24 : 8,
                height: 8,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: index == currentPage
                      ? AppColors.primaryForest
                      : AppColors.neutralTaupe,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(covariant WalletSectionDelegate oldDelegate) {
    return accounts != oldDelegate.accounts ||
        currentPage != oldDelegate.currentPage ||
        height != oldDelegate.height;
  }
}