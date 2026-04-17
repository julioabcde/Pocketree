import 'package:flutter/material.dart';
import 'package:pocketree/core/theme/app_colors.dart';

class SectionCard extends StatelessWidget {
  const SectionCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.neutralTaupe.withValues(alpha: 0.25),
        ),
      ),
      child: child,
    );
  }
}
