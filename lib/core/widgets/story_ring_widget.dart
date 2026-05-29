import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

class StoryRingWidget extends StatefulWidget {
  final Widget child;
  final bool hasStory;
  final bool isViewed;
  final bool isCompetitionLeader;
  final bool isDigital;
  final VoidCallback? onTap;
  final double size;

  const StoryRingWidget({
    super.key,
    required this.child,
    this.hasStory = false,
    this.isViewed = false,
    this.isCompetitionLeader = false,
    this.isDigital = false,
    this.onTap,
    this.size = 60,
  });

  @override
  State<StoryRingWidget> createState() => _StoryRingWidgetState();
}

class _StoryRingWidgetState extends State<StoryRingWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl =
        AnimationController(vsync: this, duration: const Duration(seconds: 3))
          ..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDigital =
        widget.isDigital || context.watch<ThemeProvider>().isDigital;

    if (!widget.hasStory) {
      return GestureDetector(
        onTap: widget.onTap,
        child:
            SizedBox(width: widget.size, height: widget.size, child: widget.child),
      );
    }

    return GestureDetector(
      onTap: widget.onTap,
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: AnimatedBuilder(
          animation: _ctrl,
          builder: (_, child) => CustomPaint(
            painter: _RingPainter(
              progress: _ctrl.value,
              isViewed: widget.isViewed,
              isCompetitionLeader: widget.isCompetitionLeader,
              isDigital: isDigital,
            ),
            child: child,
          ),
          child: Center(
            child: ClipOval(
              child: SizedBox(
                width: widget.size - 6,
                height: widget.size - 6,
                child: widget.child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final bool isViewed;
  final bool isCompetitionLeader;
  final bool isDigital;

  const _RingPainter({
    required this.progress,
    required this.isViewed,
    required this.isCompetitionLeader,
    required this.isDigital,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2 - 1.5;

    if (isViewed) {
      canvas.drawCircle(
        center,
        radius,
        Paint()
          ..color = Colors.grey.shade400
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke,
      );
      return;
    }

    final List<Color> colors = isCompetitionLeader
        ? const [
            Color(0xFFC9A227),
            Color(0xFFE8C060),
            Color(0xFF8B6914),
            Color(0xFFC9A227),
          ]
        : isDigital
            ? const [
                Color(0xFFA68C8C),
                Color(0xFF8C7A7B),
                Color(0xFF705B59),
                Color(0xFFA68C8C),
              ]
            : const [
                Color(0xFFC9956C),
                Color(0xFFE8B4A0),
                Color(0xFFB19DA0),
                Color(0xFFC9956C),
              ];

    final rect = Rect.fromCircle(center: center, radius: radius);
    final gradient = SweepGradient(
      startAngle: 0,
      endAngle: 2 * pi,
      transform: GradientRotation(2 * pi * progress),
      colors: colors,
    );

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..shader = gradient.createShader(rect)
        ..strokeWidth = isCompetitionLeader ? 3.0 : 2.5
        ..style = PaintingStyle.stroke,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.progress != progress ||
      old.isViewed != isViewed ||
      old.isCompetitionLeader != isCompetitionLeader ||
      old.isDigital != isDigital;
}
