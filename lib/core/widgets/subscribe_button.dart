import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class SubscribeButton extends StatefulWidget {
  final bool isSubscribed;
  final bool isDigital;
  final VoidCallback onTap;
  const SubscribeButton({
    super.key,
    required this.isSubscribed,
    required this.isDigital,
    required this.onTap,
  });

  @override
  State<SubscribeButton> createState() => _SubscribeButtonState();
}

class _SubscribeButtonState extends State<SubscribeButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.12), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.12, end: 1.0), weight: 50),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    _controller.forward(from: 0);
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    final primary = AppColors.adaptivePrimary(widget.isDigital);

    return ScaleTransition(
      scale: _scaleAnim,
      child: widget.isSubscribed
          ? OutlinedButton(
              onPressed: _handleTap,
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: primary.withValues(alpha: 0.5)),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              child: Text(
                'Subscribed',
                style: TextStyle(fontSize: 13, color: primary, fontWeight: FontWeight.w600),
              ),
            )
          : FilledButton(
              onPressed: _handleTap,
              style: FilledButton.styleFrom(
                backgroundColor: primary,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              child: const Text(
                'Subscribe',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ),
    );
  }
}
