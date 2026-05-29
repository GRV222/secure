import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../providers/theme_provider.dart';

enum StarRatingMode { display, interactive, locked }

class StarRatingWidget extends StatefulWidget {
  final double rating;
  final int ratingCount;
  final StarRatingMode mode;
  final double itemSize;
  final void Function(double)? onRatingSelected;

  const StarRatingWidget({
    super.key,
    required this.rating,
    this.ratingCount = 0,
    this.mode = StarRatingMode.display,
    this.itemSize = 24.0,
    this.onRatingSelected,
  });

  const StarRatingWidget.display({
    super.key,
    required this.rating,
    this.ratingCount = 0,
    this.itemSize = 24.0,
  })  : mode = StarRatingMode.display,
        onRatingSelected = null;

  const StarRatingWidget.interactive({
    super.key,
    required this.rating,
    this.ratingCount = 0,
    this.itemSize = 24.0,
    required this.onRatingSelected,
  }) : mode = StarRatingMode.interactive;

  const StarRatingWidget.locked({
    super.key,
    this.rating = 0,
    this.ratingCount = 0,
    this.itemSize = 24.0,
  })  : mode = StarRatingMode.locked,
        onRatingSelected = null;

  @override
  State<StarRatingWidget> createState() => _StarRatingWidgetState();
}

class _StarRatingWidgetState extends State<StarRatingWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _burstCtrl;
  late Animation<double> _burstAnim;
  bool _showBurst = false;
  double _currentRating = 0;

  @override
  void initState() {
    super.initState();
    _currentRating = widget.rating;
    _burstCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _burstAnim =
        CurvedAnimation(parent: _burstCtrl, curve: Curves.easeOut);
    _burstCtrl.addStatusListener((s) {
      if (s == AnimationStatus.completed) {
        setState(() => _showBurst = false);
        _burstCtrl.reset();
      }
    });
  }

  @override
  void dispose() {
    _burstCtrl.dispose();
    super.dispose();
  }

  void _onRate(double val) {
    setState(() => _currentRating = val);
    if (val == 5.0) {
      setState(() => _showBurst = true);
      _burstCtrl.forward(from: 0);
      HapticFeedback.heavyImpact();
    } else {
      HapticFeedback.mediumImpact();
    }
    widget.onRatingSelected?.call(val);
  }

  @override
  Widget build(BuildContext context) {
    final isDigital = context.watch<ThemeProvider>().isDigital;
    final starColor =
        isDigital ? AppColors.digGold : AppColors.tradGold;

    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.mode == StarRatingMode.locked)
              _buildLocked(starColor)
            else
              RatingBar.builder(
                initialRating: _currentRating.clamp(1.0, 5.0),
                minRating: 1,
                direction: Axis.horizontal,
                allowHalfRating: widget.mode == StarRatingMode.display,
                itemCount: 5,
                itemSize: widget.itemSize,
                ignoreGestures: widget.mode == StarRatingMode.display,
                itemBuilder: (_, __) =>
                    Icon(Icons.star_rounded, color: starColor),
                unratedColor: starColor.withValues(alpha: 0.2),
                onRatingUpdate: _onRate,
              ),
            const SizedBox(height: 4),
            _buildCountLabel(context, isDigital),
          ],
        ),

        if (_showBurst)
          AnimatedBuilder(
            animation: _burstAnim,
            builder: (context, _) {
              return CustomPaint(
                size: Size(widget.itemSize * 5 + 40, 80),
                painter: _BurstPainter(
                  progress: _burstAnim.value,
                  color: starColor,
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _buildLocked(Color starColor) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...List.generate(
            5,
            (i) => Icon(
                  Icons.star_rounded,
                  size: widget.itemSize,
                  color: starColor.withValues(alpha: 0.2),
                )),
        const SizedBox(width: 6),
        Icon(Icons.lock_outline,
            size: 16, color: AppColors.tradTextSecondary),
      ],
    );
  }

  Widget _buildCountLabel(BuildContext context, bool isDigital) {
    if (widget.mode == StarRatingMode.locked) {
      return Text(
        'Locked',
        style: TextStyle(
          fontSize: 12,
          color: AppColors.textSubFor(isDigital),
          fontWeight: FontWeight.w500,
        ),
      );
    }
    return Text(
      widget.mode == StarRatingMode.display
          ? '${_currentRating.toStringAsFixed(1)} (${widget.ratingCount})'
          : '${widget.ratingCount} ${widget.ratingCount == 1 ? "rating" : "ratings"}',
      style: TextStyle(
        fontSize: 12,
        color: AppColors.textSubFor(isDigital),
      ),
    );
  }
}

class _BurstPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Random _rng = Random(42);

  _BurstPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..color = color.withValues(alpha: 1 - progress);

    for (int i = 0; i < 12; i++) {
      final angle = (i / 12) * 2 * pi;
      final distance = progress * 40;
      final x = center.dx + cos(angle) * distance;
      final y = center.dy + sin(angle) * distance;
      final radius = (1 - progress) * (_rng.nextDouble() * 3 + 2);
      canvas.drawCircle(Offset(x, y), radius, paint);
    }

    final linePaint = Paint()
      ..color = color.withValues(alpha: (1 - progress) * 0.6)
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < 6; i++) {
      final angle = (i / 6) * 2 * pi + pi / 6;
      final startDist = progress * 15;
      final endDist = progress * 35;
      canvas.drawLine(
        Offset(center.dx + cos(angle) * startDist,
            center.dy + sin(angle) * startDist),
        Offset(center.dx + cos(angle) * endDist,
            center.dy + sin(angle) * endDist),
        linePaint,
      );
    }
  }

  @override
  bool shouldRepaint(_BurstPainter old) => old.progress != progress;
}
