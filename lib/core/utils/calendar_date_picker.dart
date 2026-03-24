import 'package:flutter/material.dart';
import 'package:date_picker_plus/date_picker_plus.dart';
import 'package:pocketree/core/theme/app_colors.dart';

Future<DateTime?> showCalendarDatePicker(
  BuildContext context, {
  DateTime? initialDate,
  DateTime? minDate,
  DateTime? maxDate,
}) {
  return showDatePickerDialog(
    context: context,
    initialDate: initialDate ?? DateTime.now(),
    minDate: minDate ?? DateTime(2000),
    maxDate: maxDate ?? DateTime.now(),
    width: 340,
    height: 370,
    currentDateDecoration: BoxDecoration(
      border: Border.all(color: AppColors.primaryForest, width: 1),
      shape: BoxShape.circle,
    ),
    currentDateTextStyle: const TextStyle(
      color: AppColors.primaryForest,
      fontWeight: FontWeight.w600,
    ),
    selectedCellDecoration: const BoxDecoration(
      color: AppColors.primaryForest,
      shape: BoxShape.circle,
    ),
    selectedCellTextStyle: const TextStyle(
      color: AppColors.white,
      fontWeight: FontWeight.w600,
    ),
    enabledCellsTextStyle: const TextStyle(color: AppColors.brownEspresso),
    disabledCellsTextStyle: TextStyle(
      color: AppColors.neutralTaupe.withValues(alpha: 0.5),
    ),
    leadingDateTextStyle: const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: AppColors.brownEspresso,
    ),
    slidersColor: AppColors.primaryForest,
    splashColor: AppColors.primaryForest.withValues(alpha: 0.1),
    highlightColor: AppColors.primaryForest.withValues(alpha: 0.1),
  );
}
