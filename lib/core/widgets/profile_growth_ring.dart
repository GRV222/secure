import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../providers/theme_provider.dart';

class ProfileGrowthRing extends StatefulWidget {
  final double ratingAvg;
  final int competitionWins;
  final double daGiven;
  final int postCount;
  final double size;
  final Widget child;

  const ProfileGrowthRing({
    super.key,
    required this.ratingAvg,
    required this.competitionWins,
    required this.daGiven,
    required this.postCount,
    required this.child,
    this.size = 100,
  });

  @override
  State<ProfileGrowthRing> createState() => _ProfileGrowthRingState();
}

class _ProfileGrowthRingState extends State<ProfileGrowthRing>
    with TickerProviderStateMixin {
  late AnimationController _spinCtrl;
  late AnimationController _fillCtrl;
  late AnimationController _glowCtrl;
  late Animation<double> _fill;
  late Animation<double> _glow;

  @override
  void initState() {
    super.initState();

    _spinCtrl = AnimationController(
        vsync: this, duration: const Duration(seconds: 8))
      ..repeat();

    _fillCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1400));
    _fill = CurvedAnimation(parent: _fillCtrl, curve: Curves.easeOut);

    _glowCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2000))
      ..repeat(reverse: true);
    _glow = Tween<double>(begin: 0.3, end: 0.7).animate(
        CurvedAnimation(parent: _glowCtrl, curve: Curves.easeInOut));

    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _fillCtrl.forward();
    });
  }

  @override
  void dispose() {
    _spinCtrl.dispose();
    _fillCtrl.dispose();
    _glowCtrl.dispose();
    super.dispose();
  }

  double get _activityScore {
    double score = 0;
    score += (widget.ratingAvg / 5.0) * 0.4;
    score += (widget.postCount.clamp(0, 50) / 50.0) * 0.25;
    score += (widget.daGiven.clamp(0, 500) / 500.0) * 0.20;
    score += (widget.competitionWins.clamp(0, 10) / 10.0) * 0.15;
    return score.clamp(0.0, 1.0);
  }

  List<Color> _ringColors(bool isDigital, double score) {
    if (widget.competitionWins > 0 && score > 0.7) {
      return const [
        Color(0xFFC9A227),
        Color(0xFFE8C060),
        Color(0xFF8B6914),
        Color(0xFFC9A227),
      ];
    }
    if (isDigital) {
      return [
        AppColors.digAccent,
        AppColors.digCinnamon,
        AppColors.digPrimary,
        AppColors.digAccent,
      ];
    }
    return [
      AppColors.tradPrimary,
      const Color(0xFFE8B4A0),
      AppColors.mauve,
      AppColors.tradPrimary,
    ];
  }

  @override
  Widget build(BuildContext context) {
    final isDigital = context.watch<ThemeProvider>().isDigital;
    final score = _activityScore;
    final colors = _ringColors(isDigital, score);
    final isChampion = widget.competitionWins > 0 && score > 0.7;

    return AnimatedBuilder(
      animation: Listenable.merge([_spinCtrl, _fill, _glow]),
      builder: (context, _) {
        return SizedBox(
          width: widget.size + 12,
          height: widget.size + 12,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Champion outer glow
              if (isChampion)
                Container(
                  width: widget.size + 20,
                  height: widget.size + 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.gold
                            .withValues(alpha: _glow.value * 0.4),
                        blurRadius: 20,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                ),

              // Track ring (empty)
              CustomPaint(
                size: Size(widget.size + 8, widget.size + 8),
                painter: _GrowthRingPainter(
                  fillProgress: 1.0,
                  colors: [
                    colors.first.withValues(alpha: 0.12),
                    colors.last.withValues(alpha: 0.12),
                  ],
                  spinAngle: 0,
                  strokeWidth: 4,
                  isTrack: true,
                ),
              ),

              // Filled arc (activity level)
              CustomPaint(
                size: Size(widget.size + 8, widget.size + 8),
                painter: _GrowthRingPainter(
                  fillProgress: score * _fill.value,
                  colors: colors,
                  spinAngle: _spinCtrl.value * 2 * pi,
                  strokeWidth: 4,
                  isTrack: false,
                ),
              ),

              // Orbit dots for champions
              if (isChampion)
                ...List.generate(4, (i) {
                  final angle = _spinCtrl.value * 2 * pi +
                      (i / 4) * 2 * pi;
                  final r = (widget.size + 8) / 2;
                  return Transform.translate(
                    offset: Offset(cos(angle) * r, sin(angle) * r),
                    child: Container(
                      width: 5,
                      height: 5,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.gold
                            .withValues(alpha: _glow.value),
                        boxShadow: [
                          BoxShadow(
                            color:
                                AppColors.gold.withValues(alpha: 0.5),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                  );
                }),

              // Avatar child
              SizedBox(
                width: widget.size,
                height: widget.size,
                child: widget.child,
              ),

              // Score indicator dot
              Positioned(
                bottom: 4,
                right: 4,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isChampion
                        ? AppColors.gold
                        : AppColors.adaptivePrimary(isDigital),
                    border: Border.all(
                        color: AppColors.bg(isDigital), width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: (isChampion
                                ? AppColors.gold
                                : AppColors.adaptivePrimary(isDigital))
                            .withValues(alpha: 0.4),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      isChampion ? '🏆' : '⭐',
                      style: const TextStyle(fontSize: 9),
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

class _GrowthRingPainter extends CustomPainter {
  final double fillProgress;
  final List<Color> colors;
  final double spinAngle;
  final double strokeWidth;
  final bool isTrack;

  const _GrowthRingPainter({
    required this.fillProgress,
    required this.colors,
    required this.spinAngle,
    required this.strokeWidth,
    required this.isTrack,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - strokeWidth;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    if (isTrack) {
      paint.color = colors.first;
      canvas.drawCircle(center, radius, paint);
      return;
    }

    if (fillProgress <= 0) return;

    final sweepAngle = fillProgress * 2 * pi;
    final startAngle = -pi / 2 + spinAngle * 0.1;

    paint.shader = SweepGradient(
      colors: colors,
      startAngle: startAngle,
      endAngle: startAngle + sweepAngle,
    ).createShader(rect);

    canvas.drawArc(rect, startAngle, sweepAngle, false, paint);

    // Glowing tip dot
    final tipAngle = startAngle + sweepAngle;
    final tipX = center.dx + cos(tipAngle) * radius;
    final tipY = center.dy + sin(tipAngle) * radius;
    final dotPaint = Paint()
      ..color = colors.last
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(tipX, tipY), strokeWidth / 2, dotPaint);
  }

  @override
  bool shouldRepaint(_GrowthRingPainter old) =>
      old.fillProgress != fillProgress || old.spinAngle != spinAngle;
}
