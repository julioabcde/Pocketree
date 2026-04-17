import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pocketree/core/di/injection_container.dart';
import 'package:pocketree/core/theme/app_colors.dart';
import 'package:pocketree/features/splitbill/domain/usecases/scan_receipt_usecase.dart';
import 'package:pocketree/features/splitbill/presentation/args/create_splitbill_args.dart';
import 'package:pocketree/features/splitbill/presentation/models/split_bill_charge_input.dart';
import 'package:pocketree/features/splitbill/presentation/models/split_bill_item_input.dart';

class SplitbillScreen extends StatefulWidget {
  const SplitbillScreen({super.key});

  @override
  State<SplitbillScreen> createState() => _SplitbillScreenState();
}

class _SplitbillScreenState extends State<SplitbillScreen> {
  bool _flashOn = false;
  bool _isProcessing = false;
  String _scanStatus = 'Scanning receipt...';

  final ScanReceiptUseCase _scanReceipt = sl<ScanReceiptUseCase>();
  final _picker = ImagePicker();

  Future<void> _pickFromGallery() async {
    final file = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      imageQuality: 80,
    );
    if (file != null) await _processImage(file);
  }

  Future<void> _captureFromCamera() async {
    final file = await _picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1024,
      imageQuality: 80,
    );
    if (file != null) await _processImage(file);
  }

  Future<void> _processImage(XFile file) async {
    setState(() {
      _isProcessing = true;
      _scanStatus = 'Scanning receipt...';
    });

    try {
      const source = 'ai';
      var items = <SplitBillItemInput>[];
      var charges = <SplitBillChargeInput>[];

      debugPrint('[Scan] Scanning with AI...');
      setState(() => _scanStatus = 'Scanning with AI...');

      final result = await _scanReceipt(File(file.path));

      result.fold(
        (failure) {
          debugPrint('[Scan] Failure: ${failure.message}');
          throw Exception(failure.message);
        },
        (scan) {
          debugPrint(
            '[Scan] items: ${scan.items.length}, charges: ${scan.charges.length}',
          );
          items = scan.items
              .map(
                (i) => SplitBillItemInput(
                  name: i.name,
                  price: i.unitPrice,
                  qty: i.qty,
                  isFromOCR: true,
                ),
              )
              .toList();
          charges = scan.charges
              .map(
                (c) => SplitBillChargeInput(
                  type: c.type,
                  name: c.name,
                  amount: c.amount,
                ),
              )
              .toList();
        },
      );

      if (!mounted) return;

      if (items.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No items detected. You can add them manually.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }

      context.push(
        '/create-splitbill',
        extra: CreateSplitbillArgs(
          prefillItems: items,
          prefillCharges: charges.isNotEmpty ? charges : null,
          source: source,
        ),
      );
    } catch (e) {
      debugPrint('[Scan] Error: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Scanning failed: ${e.toString().split('\n').first}'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.2,
                colors: [Color(0xFF3A3A2A), Color(0xFF1A1209)],
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white, size: 26),
                    onPressed: () => GoRouter.of(context).pop(),
                  ),
                  const Expanded(
                    child: Text(
                      'SCAN RECEIPT',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      _flashOn ? Icons.flash_on_rounded : Icons.flash_off_rounded,
                      color: Colors.white,
                      size: 26,
                    ),
                    onPressed: () => setState(() => _flashOn = !_flashOn),
                  ),
                ],
              ),
            ),
          ),

          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 48),
              child: AspectRatio(
                aspectRatio: 0.62,
                child: CustomPaint(
                  painter: _CornerBracketPainter(
                    color: AppColors.primaryForest,
                    strokeWidth: 3.5,
                    bracketLength: 40,
                  ),
                ),
              ),
            ),
          ),

          Positioned(
            bottom: 148,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Text(
                  'Align receipt within the frame',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.75),
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Pastikan struk rata, tidak blur, dan cukup cahaya',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.50),
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),

          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              color: AppColors.neutralCream,
              padding: EdgeInsets.only(
                top: 20,
                bottom: MediaQuery.of(context).padding.bottom + 20,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _BottomAction(
                    icon: Icons.photo_library_outlined,
                    label: 'GALLERY',
                    onTap: _isProcessing ? null : _pickFromGallery,
                  ),

                  GestureDetector(
                    onTap: _isProcessing ? null : _captureFromCamera,
                    child: Container(
                      width: 74,
                      height: 74,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.primaryForest.withValues(alpha: 0.35),
                          width: 3.5,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(5),
                        child: Container(
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.primaryForest,
                          ),
                          child: const Icon(
                            Icons.camera_alt_outlined,
                            color: AppColors.white,
                            size: 28,
                          ),
                        ),
                      ),
                    ),
                  ),

                  _BottomAction(
                    icon: Icons.edit_document,
                    label: 'MANUAL',
                    onTap: _isProcessing
                        ? null
                        : () => context.push(
                              '/create-splitbill',
                              extra: const CreateSplitbillArgs(source: 'manual'),
                            ),
                  ),
                ],
              ),
            ),
          ),

          if (_isProcessing)
            Container(
              color: Colors.black54,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(color: Colors.white),
                    const SizedBox(height: 16),
                    Text(
                      _scanStatus,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _BottomAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _BottomAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: enabled
                ? AppColors.primaryForest
                : AppColors.primaryForest.withValues(alpha: 0.4),
            size: 30,
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: enabled
                  ? AppColors.brownDriftwood
                  : AppColors.brownDriftwood.withValues(alpha: 0.4),
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class _CornerBracketPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double bracketLength;

  const _CornerBracketPainter({
    required this.color,
    this.strokeWidth = 3.0,
    this.bracketLength = 36.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.square;

    final l = bracketLength;
    final w = size.width;
    final h = size.height;

    canvas.drawLine(Offset(0, l), Offset.zero, paint);
    canvas.drawLine(Offset.zero, Offset(l, 0), paint);
    canvas.drawLine(Offset(w - l, 0), Offset(w, 0), paint);
    canvas.drawLine(Offset(w, 0), Offset(w, l), paint);
    canvas.drawLine(Offset(0, h - l), Offset(0, h), paint);
    canvas.drawLine(Offset(0, h), Offset(l, h), paint);
    canvas.drawLine(Offset(w - l, h), Offset(w, h), paint);
    canvas.drawLine(Offset(w, h - l), Offset(w, h), paint);
  }

  @override
  bool shouldRepaint(_CornerBracketPainter old) =>
      color != old.color ||
      strokeWidth != old.strokeWidth ||
      bracketLength != old.bracketLength;
}
