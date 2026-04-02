import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pocketree/core/theme/app_colors.dart';

class DailyTransactionHeaderDelegate extends SliverPersistentHeaderDelegate {
  final DateTime selectedDate;
  static const double _height = 64;

  const DailyTransactionHeaderDelegate({required this.selectedDate});

  @override
  double get minExtent => _height;

  @override
  double get maxExtent => _height;

  @override
  bool shouldRebuild(covariant DailyTransactionHeaderDelegate oldDelegate) {
    return selectedDate != oldDelegate.selectedDate;
  }

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final dateLabel = _formatDate(selectedDate);

    return Container(
      height: _height,
      decoration: BoxDecoration(
        color: AppColors.neutralCream,
        boxShadow: overlapsContent
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
      alignment: Alignment.center,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Daily Transactions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.darkDeepPine,
            ),
          ),
          Text(
            dateLabel,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.brownMocha,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('EEE, d MMM').format(date);
    // Output: "Mon, 23 Mar"
  }
}