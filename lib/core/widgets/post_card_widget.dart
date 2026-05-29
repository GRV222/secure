import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../models/post_model.dart';
import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';
import '../providers/theme_provider.dart';
import '../utils/helpers.dart';
import '../../config/route_names.dart';
import '../../features/posts/widgets/deleted_post_card.dart';
import '../../features/posts/widgets/poll_widget.dart';
import '../../services/firestore_service.dart';
import 'audio_player_widget.dart';
import 'video_player_widget.dart';
import 'secure_card.dart';

class PostCardWidget extends StatefulWidget {
  final PostModel post;
  final VoidCallback? onTap;
  final VoidCallback? onShare;
  final VoidCallback? onSave;

  const PostCardWidget({
    super.key,
    required this.post,
    this.onTap,
    this.onShare,
    this.onSave,
  });

  @override
  State<PostCardWidget> createState() => _PostCardWidgetState();
}

class _PostCardWidgetState extends State<PostCardWidget> {
  bool _pressed = false;

  PostModel get post => widget.post;

  @override
  Widget build(BuildContext context) {
    if (post.isDeleted) return DeletedPostCard(post: post);

    final isTopRated = post.isCompetitionEntry &&
        post.ratingAvg >= 4.5 &&
        post.ratingCount >= 10;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap ?? () => context.push('/post/${post.postId}'),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 80),
        transform: Matrix4.translationValues(0, _pressed ? -2.0 : 0, 0),
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: SecureCard(
          borderRadius: 16,
          padding: EdgeInsets.zero,
          tint: isTopRated
              ? const Color(0xFFFFB800).withValues(alpha: 0.04)
              : null,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isTopRated)
                Container(
                  width: double.infinity,
                  height: 2,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFFD4A843), Color(0xFFB76E79)],
                    ),
                    borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 14, 10, 10),
                child: _buildHeader(context),
              ),
              _buildMediaArea(),
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.content,
                      style: const TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 15,
                        height: 1.55,
                      ),
                    ),
                    if (post.isPollPost)
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: PollWidget(
                          post: post,
                          onVote: (option) => FirestoreService().votePoll(
                            postId: post.postId,
                            uid: '',
                            option: option,
                          ),
                        ),
                      ),
                    const SizedBox(height: 10),
                    _buildHashtagRow(context),
                    const SizedBox(height: 10),
                    _buildRatingRow(context),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: Divider(height: 1),
                    ),
                    _buildActionRow(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final isDigital = context.watch<ThemeProvider>().isDigital;
    final isDigitalPost = post.category == PostCategory.digital;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Avatar(name: post.authorName),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                post.authorName,
                style: const TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
              Text(
                '@${post.authorUsername}',
                style: TextStyle(color: AppColors.textSubFor(isDigital), fontSize: 12),
              ),
              if (post.hasLocation && post.locationDisplay.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Row(
                    children: [
                      Icon(Icons.location_on, size: 11, color: Colors.grey.shade500),
                      const SizedBox(width: 2),
                      Text(
                        post.locationDisplay,
                        style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 4),
              Wrap(
                spacing: 6,
                children: [
                  if (post.identityHashtag != null)
                    _TagPill(
                      label: '#${post.identityHashtag}',
                      color: AppColors.tradPrimary,
                      filled: false,
                    ),
                  _TagPill(
                    label: isDigitalPost ? 'Digital' : 'Traditional',
                    color: isDigitalPost ? AppColors.digPrimary : AppColors.tradPrimary,
                    filled: true,
                  ),
                ],
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              Helpers.timeAgo(post.createdAt),
              style: TextStyle(fontSize: 11, color: AppColors.textSubFor(isDigital)),
            ),
            const SizedBox(height: 4),
            Icon(Icons.more_horiz, size: 18, color: Colors.grey.shade400),
          ],
        ),
      ],
    );
  }

  Widget _buildMediaArea() {
    if (post.type == PostType.video) {
      return VideoPlayerWidget(
        videoUrl: post.mediaURL ?? '',
        thumbnailUrl: post.thumbnailURL.isNotEmpty ? post.thumbnailURL : null,
      );
    }
    if (post.type == PostType.audio) {
      return AudioPlayerWidget(
        audioUrl: post.mediaURL ?? '',
        title: post.audioTitle.isNotEmpty ? post.audioTitle : post.content,
      );
    }
    if (post.type != PostType.image) return const SizedBox.shrink();

    final hasUrl = post.mediaURL != null && post.mediaURL!.isNotEmpty;
    return ClipRRect(
      borderRadius: BorderRadius.zero,
      child: hasUrl
          ? CachedNetworkImage(
              imageUrl: post.mediaURL!,
              width: double.infinity,
              height: 280,
              fit: BoxFit.cover,
              placeholder: (_, __) => Container(
                height: 280,
                color: Colors.grey.shade200,
                child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
              ),
              errorWidget: (_, __, ___) => Container(
                height: 280,
                color: Colors.grey.shade200,
                child: Icon(Icons.image_outlined, size: 48, color: Colors.grey.shade400),
              ),
            )
          : Container(
              height: 280,
              width: double.infinity,
              color: Colors.grey.shade200,
              child: Icon(Icons.camera_alt_outlined, size: 44, color: Colors.grey.shade400),
            ),
    );
  }

  Widget _buildHashtagRow(BuildContext context) {
    final categoryTag = post.hashtags.isNotEmpty ? post.hashtags.first : null;
    final identityTag = post.identityHashtag;

    if (identityTag == null && categoryTag == null) return const SizedBox.shrink();

    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: [
        if (identityTag != null)
          GestureDetector(
            onTap: () => context.push('/hashtag/$identityTag'),
            child: _TagPill(label: '#$identityTag', color: AppColors.tradPrimary, filled: false),
          ),
        if (categoryTag != null)
          GestureDetector(
            onTap: () => context.push('/hashtag/$categoryTag'),
            child: _TagPill(
              label: '#$categoryTag',
              color: post.category == PostCategory.digital
                  ? AppColors.digPrimary
                  : AppColors.tradPrimary,
              filled: true,
            ),
          ),
      ],
    );
  }

  Widget _buildRatingRow(BuildContext context) {
    final isTopRated = post.isCompetitionEntry &&
        post.ratingAvg >= 4.5 &&
        post.ratingCount >= 10;

    return Row(
      children: [
        const Icon(Icons.star_rounded, color: AppColors.tradGold, size: 20),
        const SizedBox(width: 4),
        Text(
          post.ratingAvg.toStringAsFixed(1),
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
        ),
        const SizedBox(width: 4),
        Text(
          '(${Helpers.formatCount(post.ratingCount)} ratings)',
          style: TextStyle(color: AppColors.textSubFor(context.watch<ThemeProvider>().isDigital), fontSize: 13),
        ),
        const Spacer(),
        if (isTopRated)
          Container(
            margin: const EdgeInsets.only(right: 6),
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFFFFB800).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Text(
              '🏆 Top Rated',
              style: TextStyle(
                fontSize: 10,
                color: Color(0xFFB8860B),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        if (post.isCompetitionEntry)
          GestureDetector(
            onTap: () => context.push(RouteNames.compete),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.gold.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                border: Border.all(color: AppColors.gold.withValues(alpha: 0.45)),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('🏆', style: TextStyle(fontSize: 11)),
                  SizedBox(width: 3),
                  Text(
                    'In Competition',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.gold,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildActionRow() {
    return Row(
      children: [
        _ActionBtn(
          icon: Icons.reply_outlined,
          label: Helpers.formatCount(post.shareCount),
          onTap: widget.onShare,
        ),
        const SizedBox(width: AppSizes.lg),
        _ActionBtn(
          icon: Icons.bookmark_border_outlined,
          label: Helpers.formatCount(post.saveCount),
          onTap: widget.onSave,
        ),
        const Spacer(),
        _ActionBtn(icon: Icons.more_horiz, onTap: null),
      ],
    );
  }
}

class _Avatar extends StatelessWidget {
  final String name;
  const _Avatar({required this.name});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 22,
      backgroundColor: AppColors.adaptivePrimary(context.watch<ThemeProvider>().isDigital),
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : '?',
        style: const TextStyle(
          color: AppColors.white,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }
}

class _TagPill extends StatelessWidget {
  final String label;
  final Color color;
  final bool filled;
  const _TagPill({required this.label, required this.color, required this.filled});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: filled ? color.withValues(alpha: 0.12) : Colors.transparent,
        borderRadius: BorderRadius.circular(AppSizes.radiusFull),
        border: Border.all(color: color.withValues(alpha: filled ? 0.3 : 0.55)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final String? label;
  final VoidCallback? onTap;
  const _ActionBtn({required this.icon, this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    final sub = AppColors.textSubFor(context.watch<ThemeProvider>().isDigital);
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 19, color: sub),
          if (label != null) ...[
            const SizedBox(width: 4),
            Text(label!, style: TextStyle(color: sub, fontSize: 13)),
          ],
        ],
      ),
    );
  }
}
