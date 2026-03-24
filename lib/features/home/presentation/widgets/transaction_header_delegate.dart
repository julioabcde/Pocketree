import 'package:flutter/material.dart';
import 'package:pocketree/core/theme/app_colors.dart';

class TransactionHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double height;

  TransactionHeaderDelegate({this.height = 72});

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
    final borderRadius = overlapsContent
        ? BorderRadius.zero
        : const BorderRadius.vertical(top: Radius.circular(36));

    return SizedBox.expand(
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.neutralCream,
          borderRadius: borderRadius,
          boxShadow: overlapsContent
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, -4),
                  ),
                ],
        ),
        padding: const EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: 12,
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Daily Transactions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.darkDeepPine,
              ),
            ),
            Text(
              'TODAY',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.brownMocha,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant TransactionHeaderDelegate oldDelegate) {
    return height != oldDelegate.height;
  }
}
