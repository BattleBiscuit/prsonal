import 'package:flutter/material.dart';

/// The PRsonal arc mark — two concentric 270° arcs, ported from gym-app and
/// rendered monochrome for the Graphite theme: the outer ring at full colour,
/// the inner ring at 50%. Drawn natively (no asset) so it's crisp at any size
/// and inherits the theme colour.
class BrandMark extends StatelessWidget {
  const BrandMark({super.key, this.size = 20, this.color});

  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = color ?? Theme.of(context).colorScheme.onSurface;
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _BrandMarkPainter(c)),
    );
  }
}

class _BrandMarkPainter extends CustomPainter {
  _BrandMarkPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 32.0); // arcs are authored in a 32×32 box
    final outer = Path()
      ..moveTo(9.17, 25.31)
      ..arcToPoint(
        const Offset(25.31, 9.17),
        radius: const Radius.circular(10),
        largeArc: true,
      );
    final inner = Path()
      ..moveTo(18.83, 13.17)
      ..arcToPoint(
        const Offset(13.17, 18.83),
        radius: const Radius.circular(4),
        largeArc: true,
      );
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..color = color
      ..strokeWidth = 3.5;
    canvas.drawPath(outer, paint);
    paint
      ..strokeWidth = 3.0
      ..color = color.withValues(alpha: 0.5);
    canvas.drawPath(inner, paint);
  }

  @override
  bool shouldRepaint(_BrandMarkPainter oldDelegate) =>
      oldDelegate.color != color;
}
