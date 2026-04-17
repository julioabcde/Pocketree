import 'package:flutter/material.dart';
import 'package:pocketree/core/theme/app_colors.dart';

class ReportVisuals {
  const ReportVisuals._();

  static Color colorFromHex(String? hex, {Color fallback = AppColors.brownCocoa}) {
    if (hex == null || hex.isEmpty) return fallback;
    var value = hex.trim();
    if (value.startsWith('#')) value = value.substring(1);
    if (value.length == 6) value = 'FF$value';
    if (value.length != 8) return fallback;
    final parsed = int.tryParse(value, radix: 16);
    if (parsed == null) return fallback;
    return Color(parsed);
  }

  static IconData iconFromToken(String? token) {
    switch (token?.toLowerCase().trim()) {
      case 'food':
      case 'restaurant':
      case 'meal':
        return Icons.restaurant_rounded;
      case 'cart':
      case 'shopping':
      case 'shop':
        return Icons.shopping_bag_rounded;
      case 'transport':
      case 'car':
      case 'vehicle':
        return Icons.directions_car_rounded;
      case 'bills':
      case 'bill':
      case 'receipt':
      case 'utility':
        return Icons.receipt_long_rounded;
      case 'entertainment':
      case 'movie':
        return Icons.movie_rounded;
      case 'health':
      case 'medical':
        return Icons.favorite_rounded;
      case 'education':
      case 'school':
        return Icons.school_rounded;
      case 'salary':
      case 'income':
        return Icons.south_west_rounded;
      case 'travel':
      case 'flight':
        return Icons.flight_takeoff_rounded;
      case 'home':
      case 'house':
        return Icons.home_rounded;
      case 'gift':
        return Icons.card_giftcard_rounded;
      case 'savings':
        return Icons.savings_rounded;
      case 'investment':
      case 'invest':
        return Icons.trending_up_rounded;
      default:
        return Icons.more_horiz_rounded;
    }
  }

  static IconData iconForAccountType(String? type) {
    switch (type?.toLowerCase().trim()) {
      case 'cash':
        return Icons.payments_rounded;
      case 'bank_account':
        return Icons.account_balance_rounded;
      case 'e_wallet':
        return Icons.account_balance_wallet_rounded;
      case 'credit_card':
        return Icons.credit_card_rounded;
      default:
        return Icons.account_balance_wallet_rounded;
    }
  }

  static Color colorForAccountType(String? type, int index) {
    const palette = <Color>[
      AppColors.primaryForest,
      AppColors.primaryFern,
      AppColors.brownCocoa,
      AppColors.brownWalnut,
      AppColors.primarySpring,
    ];
    if (type?.toLowerCase().trim() == 'credit_card') {
      return AppColors.errorRed;
    }
    return palette[index % palette.length];
  }
}
