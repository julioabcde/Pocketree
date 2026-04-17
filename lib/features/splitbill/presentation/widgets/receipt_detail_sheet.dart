import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:pocketree/core/theme/app_colors.dart';
import 'package:pocketree/core/utils/currency_formatter.dart';
import 'package:pocketree/features/splitbill/domain/entities/split_bill_detail.dart';
import 'package:share_plus/share_plus.dart';

class ReceiptDetailSheet extends StatefulWidget {
  final SplitBillDetail detail;

  const ReceiptDetailSheet({super.key, required this.detail});

  @override
  State<ReceiptDetailSheet> createState() => _ReceiptDetailSheetState();
}

class _ReceiptDetailSheetState extends State<ReceiptDetailSheet> {
  final _repaintKey = GlobalKey();
  bool _isSharing = false;

  Future<void> _shareAsImage() async {
    setState(() => _isSharing = true);
    try {
      RenderRepaintBoundary? boundary;
      for (var i = 0; i < 3; i++) {
        await WidgetsBinding.instance.endOfFrame;
        boundary = _repaintKey.currentContext?.findRenderObject()
            as RenderRepaintBoundary?;
        if (boundary != null && !boundary.debugNeedsPaint) break;
      }
      if (boundary == null || boundary.debugNeedsPaint) return;

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return;

      final bytes = byteData.buffer.asUint8List();
      await Share.shareXFiles(
        [XFile.fromData(bytes, mimeType: 'image/png', name: 'receipt.png')],
        subject: widget.detail.title,
      );
    } finally {
      if (mounted) setState(() => _isSharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.92,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.neutralCream,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Drag handle + header
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 12, 16, 0),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Receipt Details',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryForest,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.close_rounded,
                        color: AppColors.brownDriftwood,
                        size: 22,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),

              // Scrollable receipt card
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                  child: RepaintBoundary(
                    key: _repaintKey,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColors.neutralTaupe.withValues(alpha: 0.2),
                        ),
                      ),
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Restaurant name
                          Text(
                            widget.detail.title.toUpperCase(),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primaryForest,
                              letterSpacing: 1.5,
                            ),
                          ),

                          const SizedBox(height: 4),

                          // Date
                          Text(
                            DateFormat('d MMM yyyy').format(widget.detail.date),
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.brownMocha,
                            ),
                          ),

                          const SizedBox(height: 20),
                          _DashedDivider(),
                          const SizedBox(height: 16),

                          // Items
                          ...widget.detail.items.map(
                            (item) => Padding(
                              padding: const EdgeInsets.only(bottom: 14),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          '${item.quantity}x ${item.name}',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.brownEspresso,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        CurrencyFormatter.format(item.subtotal),
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.brownEspresso,
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (item.quantity > 1) ...[
                                    const SizedBox(height: 2),
                                    Text(
                                      '@ ${CurrencyFormatter.format(item.price)} each',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: AppColors.brownMocha,
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 4),
                          _DashedDivider(),
                          const SizedBox(height: 14),

                          // Subtotal
                          _ReceiptRow(
                            label: 'Subtotal',
                            amount: widget.detail.subtotal,
                            labelColor: AppColors.brownMocha,
                            amountColor: AppColors.brownMocha,
                          ),

                          // Charges
                          ...widget.detail.charges.map(
                            (c) => Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: _ReceiptRow(
                                label: c.name,
                                amount: c.amount,
                                labelColor: AppColors.brownMocha,
                                amountColor: AppColors.brownMocha,
                              ),
                            ),
                          ),

                          const SizedBox(height: 14),
                          const Divider(
                            color: AppColors.neutralTaupe,
                            thickness: 1,
                          ),
                          const SizedBox(height: 14),

                          // Grand total
                          Row(
                            children: [
                              const Text(
                                'GRAND TOTAL',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.brownEspresso,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                CurrencyFormatter.format(widget.detail.totalAmount),
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.primaryForest,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),

                          // Share as image button
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: _isSharing ? null : _shareAsImage,
                              icon: _isSharing
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: AppColors.brownDriftwood,
                                      ),
                                    )
                                  : const Icon(
                                      Icons.share_outlined,
                                      size: 18,
                                    ),
                              label: Text(_isSharing ? 'Preparing...' : 'Share as Image'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.brownDriftwood,
                                side: const BorderSide(
                                  color: AppColors.neutralTaupe,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

//  Receipt row

class _ReceiptRow extends StatelessWidget {
  final String label;
  final double amount;
  final Color labelColor;
  final Color amountColor;

  const _ReceiptRow({
    required this.label,
    required this.amount,
    required this.labelColor,
    required this.amountColor,
  });

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 13, color: labelColor),
          ),
          const Spacer(),
          Text(
            CurrencyFormatter.format(amount),
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: amountColor,
            ),
          ),
        ],
      );
}

//  Dashed divider

class _DashedDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const dashWidth = 6.0;
        const gapWidth = 4.0;
        final count =
            (constraints.maxWidth / (dashWidth + gapWidth)).floor();
        return Row(
          children: List.generate(
            count,
            (_) => Padding(
              padding: const EdgeInsets.only(right: gapWidth),
              child: Container(
                width: dashWidth,
                height: 1,
                color: AppColors.neutralTaupe.withValues(alpha: 0.5),
              ),
            ),
          ),
        );
      },
    );
  }
}
