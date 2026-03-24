import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pocketree/core/theme/app_colors.dart';

Future<DateTime?> showCupertinoDatePicker(
  BuildContext context, {
  DateTime? initialDate,
  DateTime? minDate,
  DateTime? maxDate,
}) async {
  DateTime tempDate = initialDate ?? DateTime.now();
  DateTime? result;

  await showModalBottomSheet(
    context: context,
    backgroundColor: AppColors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) {
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 16, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Select date',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.brownEspresso,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      result = tempDate;
                      Navigator.pop(context);
                    },
                    child: const Text(
                      'Done',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryForest,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 220,
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.date,
                initialDateTime: initialDate ?? DateTime.now(),
                minimumDate: minDate ?? DateTime(2000),
                maximumDate: maxDate ?? DateTime.now(),
                onDateTimeChanged: (date) => tempDate = date,
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      );
    },
  );

  return result;
}