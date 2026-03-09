import 'package:flutter/material.dart';

abstract class AppColors {
  static const Color primaryForest = Color(0xFF0F764B);
  static const Color primaryEmerald = Color(0xFF188450);
  static const Color primaryJade = Color(0xFF2F905A);
  static const Color primarySpring = Color(0xFF3C985A);
  static const Color primaryFern = Color(0xFF479E5A);

  static const Color darkPine = Color(0xFF136443);
  static const Color darkDeepPine = Color(0xFF0E5239);
  static const Color darkMidnightLeaf = Color(0xFF06491E);

  static const Color activityHigh = Color(0xFF0E5239);
  static const Color activityMedium = Color(0xFF52A160);
  static const Color activityLow = Color(0xFF82BF71);
  static const Color activityNone = Color(0xFFD7CDC1);

  static const Color neutralCream = Color(0xFFFAF3EB);
  static const Color neutralSand = Color(0xFFF3E7D9);
  static const Color neutralLinen = Color(0xFFF0E7D8);
  static const Color neutralTaupe = Color(0xFFBFAD9F);

  static const Color brownCocoa = Color(0xFF886643);
  static const Color brownWalnut = Color(0xFF7C5B3C);
  static const Color brownEspresso = Color(0xFF45331F);
  static const Color brownDriftwood = Color(0xFF6A5C4F);
  static const Color brownMocha = Color(0xFF937D68);

  // Utility
  static const Color white = Color(0xFFFFFFFF);
  static const Color frost = Color(0xFFC9FFF4);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [primaryForest, primaryFern],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryForest, primaryEmerald, primaryJade, primarySpring, primaryFern],
  );
}
