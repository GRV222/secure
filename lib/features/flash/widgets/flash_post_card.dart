import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/post_model.dart';

class FlashPostCard extends StatefulWidget {
  final PostModel post;
  final VoidCallback onViewed;
  final bool isDigital;

  const FlashPostCard({
    super.key,
    required this.post,
    required this.onViewed,
    this.isDigital = false,
  });

  @override
  State<FlashPostCard> createState() => _FlashPostCardState();
}

class _FlashPostCardState extends State<FlashPostCard>
    with TickerProviderStateMixin {
  late AnimationController _enterAnim;
  late AnimationController _reactionAnim;
  late Animation<double> _fade;
  late Animation<Offset> _slide;
  late Animation<double> _reactionScale;
  String? _reaction;

  @override
  void initState() {
    super.initState();

    _enterAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _fade = CurvedAnimation(parent: _enterAnim, curve: Curves.easeOut);

    _slide = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _enterAnim, curve: Curves.easeOut));

    _reactionAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _reactionScale = TweenSequence([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1, end: 1.4)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.4, end: 0.95)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.95, end: 1)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 30,
      ),
    ]).animate(_reactionAnim);

    _enterAnim.forward();

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) widget.onViewed();
    });
  }

  @override
  void dispose() {
    _enterAnim.dispose();
    _reactionAnim.dispose();
    super.dispose();
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  void _react(String type) {
    setState(() => _reaction = _reaction == type ? null : type);
    _reactionAnim.forward(from: 0);
    HapticFeedback.mediumImpact();
  }

  @override
  Widget build(BuildContext context) {
    final isDigital = widget.isDigital;

    final cardBg = isDigital
        ? const Color(0xFF3D3032)
        : const Color(0xFF3A2010);

    final cardBorder = isDigital
        ? Colors.white.withValues(alpha: 0.07)
        : Colors.white.withValues(alpha: 0.12);

    final accentColor = isDigital ? AppColors.digAccent : AppColors.tradPrimary;
    final flashBadgeColor = isDigital ? AppColors.digGold : AppColors.tradGold;

    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: cardBorder),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Top accent line ──
              Container(
                height: 3,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(24)),
                  gradient: LinearGradient(
                    colors: isDigital
                        ? [AppColors.digPrimary, AppColors.digAccent]
                        : [AppColors.tradPrimaryDark, AppColors.tradPrimary],
                  ),
                ),
              ),

              // ── Header ──
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
                child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: isDigital
                              ? [AppColors.digPrimary, AppColors.digAccent]
                              : [
                                  AppColors.tradPrimaryDark,
                                  AppColors.tradPrimary
                                ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: accentColor.withValues(alpha: 0.3),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          widget.post.authorName[0].toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.post.authorName,
                            style: TextStyle(
                              fontFamily: isDigital
                                  ? 'PlusJakartaSans'
                                  : 'CormorantGaramond',
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: isDigital ? 14 : 16,
                            ),
                          ),
                          Row(
                            children: [
                              if ((widget.post.identityHashtag ?? '')
                                  .isNotEmpty) ...[
                                Text(
                                  '#${widget.post.identityHashtag}',
                                  style: TextStyle(
                                    color:
                                        accentColor.withValues(alpha: 0.8),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(width: 8),
                              ],
                              Text(
                                _timeAgo(widget.post.createdAt),
                                style: TextStyle(
                                  color:
                                      Colors.white.withValues(alpha: 0.35),
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: flashBadgeColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: flashBadgeColor.withValues(alpha: 0.25)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '⚡',
                            style: TextStyle(
                              fontSize: 11,
                              shadows: [
                                Shadow(
                                  color:
                                      flashBadgeColor.withValues(alpha: 0.5),
                                  blurRadius: 6,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 3),
                          Text(
                            'FLASH',
                            style: TextStyle(
                              color: flashBadgeColor,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // ── Media ──
              if ((widget.post.mediaURL ?? '').isNotEmpty)
                CachedNetworkImage(
                  imageUrl: widget.post.mediaURL!,
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    height: 200,
                    color: Colors.white.withValues(alpha: 0.05),
                    child: const Center(
                      child: SizedBox(
                        width: 20, height: 20,
                        child: CircularProgressIndicator(strokeWidth: 1.5, color: Colors.white54),
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    height: 200,
                    color: Colors.white.withValues(alpha: 0.05),
                    child: Center(
                      child: Icon(
                        Icons.image_outlined,
                        color: Colors.white.withValues(alpha: 0.3),
                        size: 48,
                      ),
                    ),
                  ),
                ),

              // ── Content ──
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
                child: Text(
                  widget.post.content,
                  style: TextStyle(
                    fontFamily:
                        isDigital ? 'PlusJakartaSans' : 'CormorantGaramond',
                    color: Colors.white.withValues(alpha: 0.88),
                    fontSize: isDigital ? 14 : 16,
                    height: 1.65,
                  ),
                ),
              ),

              // ── Hashtags ──
              if (widget.post.hashtags.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                  child: Wrap(
                    spacing: 6,
                    children: widget.post.hashtags
                        .take(3)
                        .map((tag) => Text(
                              '#$tag',
                              style: TextStyle(
                                color: accentColor.withValues(alpha: 0.65),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ))
                        .toList(),
                  ),
                ),

              // ── Desi divider ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 1,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: [
                            Colors.transparent,
                            Colors.white.withValues(alpha: 0.08),
                            Colors.transparent,
                          ]),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        isDigital ? '◈' : '✿',
                        style: TextStyle(
                          color: accentColor.withValues(alpha: 0.25),
                          fontSize: 10,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        height: 1,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: [
                            Colors.transparent,
                            Colors.white.withValues(alpha: 0.08),
                            Colors.transparent,
                          ]),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Reactions ──
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
                child: Row(
                  children: [
                    _buildReactionBtn(
                      emoji: '👏',
                      label: 'Respect',
                      type: 'respect',
                      accentColor: accentColor,
                    ),
                    const SizedBox(width: 10),
                    _buildReactionBtn(
                      emoji: '❤️',
                      label: 'Love',
                      type: 'love',
                      accentColor: accentColor,
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Icon(
                          Icons.swipe_up_rounded,
                          size: 14,
                          color: Colors.white.withValues(alpha: 0.2),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Scroll = gone forever',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.2),
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReactionBtn({
    required String emoji,
    required String label,
    required String type,
    required Color accentColor,
  }) {
    final isSelected = _reaction == type;
    return GestureDetector(
      onTap: () => _react(type),
      child: AnimatedBuilder(
        animation: _reactionAnim,
        builder: (context, child) => Transform.scale(
          scale: isSelected ? _reactionScale.value : 1.0,
          child: child,
        ),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? accentColor.withValues(alpha: 0.2)
                : Colors.white.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected
                  ? accentColor.withValues(alpha: 0.5)
                  : Colors.white.withValues(alpha: 0.1),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: isSelected
                      ? accentColor
                      : Colors.white.withValues(alpha: 0.5),
                  fontSize: 13,
                  fontWeight:
                      isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
