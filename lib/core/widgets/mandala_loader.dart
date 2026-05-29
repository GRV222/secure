import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../providers/theme_provider.dart';

class MandalaLoader extends StatefulWidget {
  final double size;

  const MandalaLoader({super.key, this.size = 80});

  @override
  State<MandalaLoader> createState() => _MandalaLoaderState();
}

class _MandalaLoaderState extends State<MandalaLoader>
    with TickerProviderStateMixin {
  late final AnimationController _outer;
  late final AnimationController _mid;
  late final AnimationController _inner;

  @override
  void initState() {
    super.initState();
    _outer = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
    _mid = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    )..repeat(reverse: true);
    _inner = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _outer.dispose();
    _mid.dispose();
    _inner.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDigital = context.watch<ThemeProvider>().isDigital;
    final primary = AppColors.adaptivePrimary(isDigital);
    final accent  = isDigital ? AppColors.digGold : AppColors.tradGold;

    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: Listenable.merge([_outer, _mid, _inner]),
        builder: (_, __) => CustomPaint(
          painter: _MandalaPainter(
            outerAngle: _outer.value * 2 * pi,
            midAngle:   -_mid.value * 2 * pi,
            innerAngle: _inner.value * 2 * pi,
            primary: primary,
            accent:  accent,
          ),
        ),
      ),
    );
  }
}

class _MandalaPainter extends CustomPainter {
  final double outerAngle;
  final double midAngle;
  final double innerAngle;
  final Color primary;
  final Color accent;

  const _MandalaPainter({
    required this.outerAngle,
    required this.midAngle,
    required this.innerAngle,
    required this.primary,
    required this.accent,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final center = Offset(cx, cy);

    _drawDashedArc(canvas, center, cx * 0.90, outerAngle, 12, primary.withValues(alpha: 0.6), 1.5);
    _drawDashedArc(canvas, center, cx * 0.65, midAngle, 8, accent.withValues(alpha: 0.7), 2.0);

    // Inner solid arc
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: cx * 0.38),
      innerAngle,
      pi * 1.5,
      false,
      Paint()
        ..color = primary
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );

    // Center flower symbol
    final tp = TextPainter(
      text: TextSpan(
        text: '✿',
        style: TextStyle(fontSize: cx * 0.38, color: accent),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(cx - tp.width / 2, cy - tp.height / 2));
  }

  void _drawDashedArc(
    Canvas canvas,
    Offset center,
    double radius,
    double startAngle,
    int dashCount,
    Color color,
    double strokeWidth,
  ) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final dashAngle = 2 * pi / dashCount;
    final rect = Rect.fromCircle(center: center, radius: radius);

    for (int i = 0; i < dashCount; i++) {
      canvas.drawArc(rect, startAngle + i * dashAngle, dashAngle * 0.6, false, paint);
    }
  }

  @override
  bool shouldRepaint(_MandalaPainter old) =>
      old.outerAngle != outerAngle ||
      old.midAngle != midAngle ||
      old.innerAngle != innerAngle;
}
