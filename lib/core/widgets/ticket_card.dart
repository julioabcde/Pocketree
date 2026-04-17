import 'package:flutter/material.dart';

class TicketCard extends StatefulWidget {
  final Widget top;
  final Widget bottom;
  final double notchRadius;
  final double cornerRadius;
  final Color backgroundColor;
  final Color dashedLineColor;
  final Color borderColor;

  const TicketCard({
    super.key,
    required this.top,
    required this.bottom,
    this.notchRadius = 14.0,
    this.cornerRadius = 18.0,
    this.backgroundColor = Colors.white,
    this.dashedLineColor = const Color(0xFFD9D0C0),
    this.borderColor = const Color(0xFFEAE3D5),
  });

  @override
  State<TicketCard> createState() => _TicketCardState();
}

class _TicketCardState extends State<TicketCard> {
  final _topKey = GlobalKey();
  double _notchY = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _measureTop());
  }

  void _measureTop() {
    final box = _topKey.currentContext?.findRenderObject() as RenderBox?;
    if (box != null && mounted) {
      final h = box.size.height;
      if (h != _notchY) setState(() => _notchY = h);
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _TicketPainter(
        notchY: _notchY,
        notchRadius: widget.notchRadius,
        cornerRadius: widget.cornerRadius,
        backgroundColor: widget.backgroundColor,
        dashedLineColor: widget.dashedLineColor,
        borderColor: widget.borderColor,
      ),
      child: ClipPath(
        clipper: _TicketClipper(
          notchY: _notchY,
          notchRadius: widget.notchRadius,
          cornerRadius: widget.cornerRadius,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            KeyedSubtree(key: _topKey, child: widget.top),
            widget.bottom,
          ],
        ),
      ),
    );
  }
}

Path _buildTicketPath(Size size, double notchY, double r, double cr) {
  final w = size.width;
  final h = size.height;
  final path = Path();

  path.moveTo(cr, 0);
  path.lineTo(w - cr, 0);
  path.arcToPoint(Offset(w, cr), radius: Radius.circular(cr), clockwise: true);
  path.lineTo(w, notchY - r);
  path.arcToPoint(
    Offset(w, notchY + r),
    radius: Radius.circular(r),
    clockwise: false,
  );
  path.lineTo(w, h - cr);
  path.arcToPoint(
    Offset(w - cr, h),
    radius: Radius.circular(cr),
    clockwise: true,
  );
  path.lineTo(cr, h);
  path.arcToPoint(
    Offset(0, h - cr),
    radius: Radius.circular(cr),
    clockwise: true,
  );
  path.lineTo(0, notchY + r);
  path.arcToPoint(
    Offset(0, notchY - r),
    radius: Radius.circular(r),
    clockwise: false,
  );
  path.lineTo(0, cr);
  path.arcToPoint(Offset(cr, 0), radius: Radius.circular(cr), clockwise: true);
  path.close();

  return path;
}

class _TicketClipper extends CustomClipper<Path> {
  final double notchY;
  final double notchRadius;
  final double cornerRadius;

  const _TicketClipper({
    required this.notchY,
    required this.notchRadius,
    required this.cornerRadius,
  });

  @override
  Path getClip(Size size) {
    if (notchY <= 0) {
      return Path()..addRRect(
        RRect.fromRectAndRadius(
          Offset.zero & size,
          Radius.circular(cornerRadius),
        ),
      );
    }
    return _buildTicketPath(size, notchY, notchRadius, cornerRadius);
  }

  @override
  bool shouldReclip(_TicketClipper old) =>
      old.notchY != notchY ||
      old.notchRadius != notchRadius ||
      old.cornerRadius != cornerRadius;
}

class _TicketPainter extends CustomPainter {
  final double notchY;
  final double notchRadius;
  final double cornerRadius;
  final Color backgroundColor;
  final Color dashedLineColor;
  final Color borderColor;

  const _TicketPainter({
    required this.notchY,
    required this.notchRadius,
    required this.cornerRadius,
    required this.backgroundColor,
    required this.dashedLineColor,
    required this.borderColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final effectiveNotchY = notchY > 0 ? notchY : size.height / 2;
    final measured = notchY > 0;

    final path = measured
        ? _buildTicketPath(size, effectiveNotchY, notchRadius, cornerRadius)
        : (Path()..addRRect(
            RRect.fromRectAndRadius(
              Offset.zero & size,
              Radius.circular(cornerRadius),
            ),
          ));

    canvas.drawShadow(path, Colors.black.withValues(alpha: 0.07), 10, true);

    canvas.drawPath(path, Paint()..color = backgroundColor);

    canvas.drawPath(
      path,
      Paint()
        ..color = borderColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0,
    );

    if (measured) _drawDashedLine(canvas, size, effectiveNotchY);
  }

  void _drawDashedLine(Canvas canvas, Size size, double y) {
    final paint = Paint()
      ..color = dashedLineColor
      ..strokeWidth = 1.0
      ..strokeCap = StrokeCap.round;

    const dashWidth = 5.0;
    const dashSpace = 4.0;

    double x = notchRadius + 4;
    final endX = size.width - notchRadius - 4;

    while (x < endX) {
      final segEnd = (x + dashWidth).clamp(0.0, endX);
      canvas.drawLine(Offset(x, y), Offset(segEnd, y), paint);
      x += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(_TicketPainter old) =>
      old.notchY != notchY ||
      old.backgroundColor != backgroundColor ||
      old.dashedLineColor != dashedLineColor ||
      old.borderColor != borderColor;
}
