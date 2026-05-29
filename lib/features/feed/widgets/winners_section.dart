import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../config/route_names.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/providers/theme_provider.dart';
import '../../../models/post_model.dart';

class WinnersSection extends StatelessWidget {
  final List<PostModel> winners;
  const WinnersSection({super.key, required this.winners});

  @override
  Widget build(BuildContext context) {
    if (winners.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: [
              const Text('🏆', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              const Text(
                'Top Rated This Month',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
              ),
              const Spacer(),
              TextButton(
                onPressed: () => context.push(RouteNames.compete),
                child: const Text('See All', style: TextStyle(fontSize: 13)),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 280,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: winners.length,
            itemBuilder: (context, i) => _WinnerCard(post: winners[i], rank: i + 1),
          ),
        ),
        const SizedBox(height: 8),
        const Divider(height: 1),
        const SizedBox(height: 8),
      ],
    );
  }
}

class _WinnerCard extends StatelessWidget {
  final PostModel post;
  final int rank;
  const _WinnerCard({required this.post, required this.rank});

  Color _rankColor(bool isDigital) {
    if (rank == 1) return const Color(0xFFFFB800);
    if (rank == 2) return const Color(0xFF9E9E9E);
    if (rank == 3) return const Color(0xFFCD7F32);
    return AppColors.adaptivePrimary(isDigital);
  }

  String get _rankEmoji {
    if (rank == 1) return '🥇';
    if (rank == 2) return '🥈';
    if (rank == 3) return '🥉';
    return '#$rank';
  }

  @override
  Widget build(BuildContext context) {
    final isDigital = context.watch<ThemeProvider>().isDigital;
    final rankColor = _rankColor(isDigital);
    return GestureDetector(
      onTap: () => context.push('/post/${post.postId}'),
      child: Container(
        width: 200,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: rankColor.withValues(alpha: 0.5),
            width: rank <= 3 ? 2 : 1,
          ),
          color: AppColors.cardBg(isDigital),
          boxShadow: [
            BoxShadow(
              color: rankColor.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                  child: (post.mediaURL ?? '').isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: post.mediaURL!,
                          width: 200,
                          height: 140,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            width: 200,
                            height: 140,
                            color: rankColor.withValues(alpha: 0.08),
                            child: const Center(
                              child: SizedBox(
                                width: 20, height: 20,
                                child: CircularProgressIndicator(strokeWidth: 1.5),
                              ),
                            ),
                          ),
                          errorWidget: (context, url, error) =>
                              _Placeholder(rankColor: rankColor, rankEmoji: _rankEmoji),
                        )
                      : _Placeholder(rankColor: rankColor, rankEmoji: _rankEmoji),
                ),
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: rankColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(_rankEmoji, style: const TextStyle(fontSize: 14)),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      post.category == PostCategory.traditional ? '🎨' : '💻',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 10,
                        backgroundColor: AppColors.adaptivePrimary(isDigital),
                        child: Text(
                          post.authorName.isNotEmpty ? post.authorName[0].toUpperCase() : '?',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          post.authorName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    post.content,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12, color: Colors.grey[700], height: 1.4),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Text('⭐', style: TextStyle(fontSize: 12)),
                      const SizedBox(width: 4),
                      Text(
                        post.ratingAvg.toStringAsFixed(1),
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        ' (${post.ratingCount})',
                        style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                      ),
                      const Spacer(),
                      if (post.hashtags.isNotEmpty)
                        Flexible(
                          child: Text(
                            '#${post.hashtags.first}',
                            style: TextStyle(fontSize: 11, color: AppColors.adaptivePrimary(isDigital)),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
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
    );
  }
}

class _Placeholder extends StatelessWidget {
  final Color rankColor;
  final String rankEmoji;
  const _Placeholder({required this.rankColor, required this.rankEmoji});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      height: 140,
      color: rankColor.withValues(alpha: 0.1),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(rankEmoji, style: const TextStyle(fontSize: 40)),
          const SizedBox(height: 4),
          Text('Text Post', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
        ],
      ),
    );
  }
}
