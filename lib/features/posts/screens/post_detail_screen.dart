import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../config/route_names.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/providers/theme_provider.dart';
import '../../../core/dummy/dummy_data.dart';
import '../../../core/security/content_layer_service.dart';
import '../../../core/security/screen_security.dart';
import '../../../core/utils/helpers.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../../models/post_model.dart';
import '../../../services/firestore_service.dart';
import '../widgets/deleted_post_card.dart';
import '../widgets/poll_widget.dart';

class PostDetailScreen extends StatefulWidget {
  final String postId;
  const PostDetailScreen({super.key, required this.postId});

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  PostModel? _post;
  int _pendingRating = 0;
  int _submittedRating = 0;
  bool _saved = false;
  bool _isCLPost = false;

  @override
  void initState() {
    super.initState();
    _loadPost();
  }

  @override
  void dispose() {
    if (_isCLPost) ScreenSecurity.disableScreenSecurity();
    super.dispose();
  }

  Future<void> _loadPost() async {
    try {
      final postDoc = await FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.postId)
          .get();

      if (!postDoc.exists || !mounted) {
        _loadDummyPost();
        return;
      }

      final data = postDoc.data()!;
      var post = PostModel.fromMap(data, postDoc.id);
      final uid = context.read<AuthProvider>().currentUser?.uid;

      if (uid != null && data['clEnabled'] == true) {
        final access = await ContentLayerService().checkAccess(
          postId: widget.postId,
          viewerUid: uid,
          postData: data,
        );

        if (access.hasAccess) {
          await ScreenSecurity.enableMaxSecurity();
          if (mounted) setState(() => _isCLPost = true);

          post = post.copyWith(
            content: access.originalContent,
            mediaURL: access.originalMediaURL.isNotEmpty
                ? access.originalMediaURL
                : null,
            commentsEnabled: false,
          );
        }
      }

      if (mounted) setState(() => _post = post);

      if (uid != null) {
        final rating =
            await FirestoreService().getUserRating(widget.postId, uid);
        if (mounted) setState(() => _submittedRating = rating ?? 0);
      }
    } catch (e) {
      debugPrint('Post load error: $e');
      _loadDummyPost();
    }
  }

  void _loadDummyPost() {
    try {
      final post =
          DummyData.dummyPosts.firstWhere((p) => p.postId == widget.postId);
      if (mounted) setState(() => _post = post);
    } catch (_) {
      if (mounted) setState(() => _post = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDigital = context.watch<ThemeProvider>().isDigital;
    if (_post == null) {
      return Scaffold(
        backgroundColor: AppColors.bg(isDigital),
        appBar: AppBar(title: const Text('Post')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    final post = _post!;

    if (post.isDeleted) {
      return Scaffold(
        backgroundColor: AppColors.bg(isDigital),
        appBar: AppBar(title: const Text('Post')),
        body: Center(child: DeletedPostCard(post: post)),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.bg(isDigital),
      appBar: AppBar(
        title: const Text('Post'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () {
              if (_isCLPost) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Sharing not available')),
                );
                return;
              }
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Share coming soon')),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _AuthorSection(post: post),
            if (post.type == PostType.image) _ImageArea(),
            if (post.type == PostType.text)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                    AppSizes.md, AppSizes.sm, AppSizes.md, AppSizes.sm),
                child: Text(post.content,
                    style: const TextStyle(fontSize: 16, height: 1.65)),
              ),
            if (post.isPollPost)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
                child: PollWidget(
                  post: post,
                  onVote: (option) => FirestoreService().votePoll(
                    postId: post.postId,
                    uid: context.read<AuthProvider>().currentUser?.uid ?? '',
                    option: option,
                  ),
                ),
              ),
            _HashtagRow(post: post),
            if (post.isCompetitionEntry) _CompetitionCard(post: post),
            const _Divider(),
            _RatingSection(
              post: post,
              pendingRating: _pendingRating,
              submittedRating: _submittedRating,
              onStarTap: (s) => setState(() => _pendingRating = s),
              onSubmit: () {
                if (_pendingRating == 0) return;
                setState(() => _submittedRating = _pendingRating);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Rating submitted! ⭐')),
                );
              },
            ),
            const _Divider(),
            _AvgRatingRow(post: post),
            const _Divider(),
            _ActionsRow(
                saved: _saved,
                onSave: () => setState(() => _saved = !_saved)),
            const _Divider(),
            const _CommentsSection(),
            const SizedBox(height: AppSizes.xl),
          ],
        ),
      ),
    );
  }
}

// ─── Author Section ────────────────────────────────────────────────────────────

class _AuthorSection extends StatelessWidget {
  final PostModel post;
  const _AuthorSection({required this.post});

  @override
  Widget build(BuildContext context) {
    final isDigital = context.watch<ThemeProvider>().isDigital;
    final primary = AppColors.adaptivePrimary(isDigital);
    final isDigitalPost = post.category == PostCategory.digital;
    final categoryColor = primary;

    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSizes.md, AppSizes.md, AppSizes.md, AppSizes.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: primary,
            child: Text(
              post.authorName.isNotEmpty ? post.authorName[0].toUpperCase() : '?',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(post.authorName, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                Text('@${post.authorUsername}', style: TextStyle(color: AppColors.textSubFor(isDigital), fontSize: 13)),
                if (post.hasLocation && post.locationDisplay.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined, size: 14, color: Colors.grey.shade500),
                      const SizedBox(width: 4),
                      Text(
                        post.locationDisplay,
                        style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  children: [
                    if (post.identityHashtag != null)
                      _Pill(label: '#${post.identityHashtag}', color: primary, filled: false),
                    _Pill(label: isDigitalPost ? 'Digital' : 'Traditional', color: categoryColor, filled: true),
                  ],
                ),
              ],
            ),
          ),
          Text(
            Helpers.timeAgo(post.createdAt),
            style: TextStyle(fontSize: 12, color: AppColors.textSubFor(isDigital)),
          ),
        ],
      ),
    );
  }
}

// ─── Image Area ────────────────────────────────────────────────────────────────

class _ImageArea extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 350,
      width: double.infinity,
      color: Colors.grey.shade200,
      child: Icon(Icons.camera_alt_outlined, size: 48, color: Colors.grey.shade400),
    );
  }
}

// ─── Hashtag Row ───────────────────────────────────────────────────────────────

class _HashtagRow extends StatelessWidget {
  final PostModel post;
  const _HashtagRow({required this.post});

  @override
  Widget build(BuildContext context) {
    final isDigital = context.watch<ThemeProvider>().isDigital;
    final primary = AppColors.adaptivePrimary(isDigital);
    final identityTag = post.identityHashtag;
    final categoryTag = post.hashtags.isNotEmpty ? post.hashtags.first : null;
    if (identityTag == null && categoryTag == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSizes.md, AppSizes.sm, AppSizes.md, AppSizes.sm),
      child: Wrap(
        spacing: 10,
        children: [
          if (identityTag != null)
            GestureDetector(
              onTap: () => context.push('/hashtag/$identityTag'),
              child: _Pill(label: '#$identityTag', color: primary, filled: false),
            ),
          if (categoryTag != null)
            GestureDetector(
              onTap: () => context.push('/hashtag/$categoryTag'),
              child: _Pill(label: '#$categoryTag', color: primary, filled: true),
            ),
        ],
      ),
    );
  }
}

// ─── Competition Card ──────────────────────────────────────────────────────────

class _CompetitionCard extends StatelessWidget {
  final PostModel post;
  const _CompetitionCard({required this.post});

  @override
  Widget build(BuildContext context) {
    final hashtag = post.hashtags.isNotEmpty ? post.hashtags.first : 'competition';

    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSizes.md, AppSizes.sm, AppSizes.md, 0),
      child: Container(
        padding: const EdgeInsets.all(AppSizes.md),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          border: Border.all(color: AppColors.adaptivePrimary(context.watch<ThemeProvider>().isDigital).withValues(alpha: 0.4)),
          color: AppColors.adaptivePrimary(context.watch<ThemeProvider>().isDigital).withValues(alpha: 0.04),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('🏆', style: TextStyle(fontSize: 18)),
                const SizedBox(width: 8),
                Text('In Competition', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.adaptivePrimary(context.watch<ThemeProvider>().isDigital))),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              '#$hashtag',
              style: TextStyle(color: AppColors.adaptivePrimary(context.watch<ThemeProvider>().isDigital), fontWeight: FontWeight.w600, fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text(
              'Rating period ends the 25th of this month',
              style: TextStyle(fontSize: 12, color: AppColors.textSubFor(context.watch<ThemeProvider>().isDigital)),
            ),
            const SizedBox(height: AppSizes.sm),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => context.push(RouteNames.leaderboard),
                child: const Text('View Leaderboard'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Rating Section ────────────────────────────────────────────────────────────

class _RatingSection extends StatelessWidget {
  final PostModel post;
  final int pendingRating;
  final int submittedRating;
  final ValueChanged<int> onStarTap;
  final VoidCallback onSubmit;

  const _RatingSection({
    required this.post,
    required this.pendingRating,
    required this.submittedRating,
    required this.onStarTap,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final daysLeft = post.ratingLockedUntil?.difference(DateTime.now()).inDays.clamp(0, 999) ?? 0;

    return Padding(
      padding: const EdgeInsets.all(AppSizes.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Rate This Post', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 4),
          Text(
            'Your rating is anonymous — only the average is shown',
            style: TextStyle(fontSize: 12, color: AppColors.textSubFor(context.watch<ThemeProvider>().isDigital)),
          ),
          const SizedBox(height: AppSizes.md),
          if (submittedRating == 0) ...[
            _StarRating(selected: pendingRating, onTap: onStarTap),
            const SizedBox(height: AppSizes.md),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: pendingRating > 0 ? onSubmit : null,
                child: const Text('Submit Rating'),
              ),
            ),
          ] else ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (i) => Icon(
                i < submittedRating ? Icons.star_rounded : Icons.star_outline_rounded,
                color: AppColors.gold,
                size: 32,
              )),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                'Rating locked for $daysLeft days',
                style: TextStyle(fontSize: 13, color: AppColors.textSubFor(context.watch<ThemeProvider>().isDigital)),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _StarRating extends StatelessWidget {
  final int selected;
  final ValueChanged<int> onTap;
  const _StarRating({required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (i) {
        final n = i + 1;
        return GestureDetector(
          onTap: () => onTap(n),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Icon(
              n <= selected ? Icons.star_rounded : Icons.star_outline_rounded,
              color: AppColors.gold,
              size: 44,
            ),
          ),
        );
      }),
    );
  }
}

// ─── Average Rating Row ────────────────────────────────────────────────────────

class _AvgRatingRow extends StatelessWidget {
  final PostModel post;
  const _AvgRatingRow({required this.post});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.md, vertical: AppSizes.sm),
      child: Row(
        children: [
          const Icon(Icons.star_rounded, color: AppColors.gold, size: 28),
          const SizedBox(width: 6),
          Text(
            post.ratingAvg.toStringAsFixed(1),
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
          ),
          const SizedBox(width: 6),
          Text(
            '(${Helpers.formatCount(post.ratingCount)} ratings)',
            style: TextStyle(color: AppColors.textSubFor(context.watch<ThemeProvider>().isDigital), fontSize: 14),
          ),
        ],
      ),
    );
  }
}

// ─── Actions Row ───────────────────────────────────────────────────────────────

class _ActionsRow extends StatelessWidget {
  final bool saved;
  final VoidCallback onSave;
  const _ActionsRow({required this.saved, required this.onSave});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.md, vertical: AppSizes.sm),
      child: Row(
        children: [
          _ActionBtn(
            icon: Icons.reply_outlined,
            label: 'Share',
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Share coming soon')),
            ),
          ),
          const SizedBox(width: AppSizes.lg),
          _ActionBtn(
            icon: saved ? Icons.bookmark : Icons.bookmark_border_outlined,
            label: saved ? 'Saved' : 'Save',
            color: saved ? AppColors.adaptivePrimary(context.watch<ThemeProvider>().isDigital) : null,
            onTap: onSave,
          ),
          const Spacer(),
          _ActionBtn(
            icon: Icons.flag_outlined,
            label: 'Report',
            color: AppColors.textSubFor(context.watch<ThemeProvider>().isDigital),
            onTap: () => _showReportDialog(context),
          ),
        ],
      ),
    );
  }

  void _showReportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Report Post'),
        content: const Text('Thank you for helping keep SECURE safe. Our team will review this post.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(context), child: const Text('Report')),
        ],
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;
  final VoidCallback? onTap;
  const _ActionBtn({required this.icon, required this.label, this.color, this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.textSubFor(context.watch<ThemeProvider>().isDigital);
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20, color: c),
          const SizedBox(width: 5),
          Text(label, style: TextStyle(fontSize: 13, color: c, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

// ─── Comments Section ──────────────────────────────────────────────────────────

class _CommentsSection extends StatelessWidget {
  const _CommentsSection();

  @override
  Widget build(BuildContext context) {
    final isDigital = context.watch<ThemeProvider>().isDigital;
    return Padding(
      padding: const EdgeInsets.all(AppSizes.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Comments', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: AppSizes.sm),
          Container(
            padding: const EdgeInsets.all(AppSizes.md),
            decoration: BoxDecoration(
              color: AppColors.surfaceColor(isDigital),
              borderRadius: BorderRadius.circular(AppSizes.radiusLg),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('💬', style: TextStyle(fontSize: 20)),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Comments require identity verification',
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Verify at a SECURE centre to comment. Coming soon.',
                        style: TextStyle(fontSize: 12, color: AppColors.textSubFor(isDigital)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Shared helpers ────────────────────────────────────────────────────────────

class _Pill extends StatelessWidget {
  final String label;
  final Color color;
  final bool filled;
  const _Pill({required this.label, required this.color, required this.filled});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: filled ? color.withValues(alpha: 0.13) : Colors.transparent,
        borderRadius: BorderRadius.circular(AppSizes.radiusFull),
        border: Border.all(color: color.withValues(alpha: filled ? 0.3 : 0.55)),
      ),
      child: Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color)),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSizes.md),
      child: Divider(height: 1),
    );
  }
}
