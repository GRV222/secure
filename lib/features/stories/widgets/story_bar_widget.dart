import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../config/route_names.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/dummy/dummy_data.dart';
import '../../../core/providers/theme_provider.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../../models/story_model.dart';
import '../../../services/firestore_service.dart';

class StoryBarWidget extends StatefulWidget {
  const StoryBarWidget({super.key});

  @override
  State<StoryBarWidget> createState() => _StoryBarWidgetState();
}

class _StoryBarWidgetState extends State<StoryBarWidget> {
  bool _isLoading = true;
  Map<String, List<StoryModel>> _groupedStories = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    try {
      final user = context.read<AuthProvider>().currentUser;
      final stories = await FirestoreService().getStories(
        uid: user?.uid ?? '',
        followedHashtags: user?.followedHashtags ?? [],
      );
      final grouped = _group(stories);
      if (mounted) {
        setState(() {
          _groupedStories = grouped;
          _isLoading = false;
        });
      }
    } catch (_) {
      final grouped = _group(DummyData.dummyStories);
      if (mounted) {
        setState(() {
          _groupedStories = grouped;
          _isLoading = false;
        });
      }
    }
  }

  Map<String, List<StoryModel>> _group(List<StoryModel> stories) {
    final grouped = <String, List<StoryModel>>{};
    for (final s in stories) {
      grouped.putIfAbsent(s.uid, () => []).add(s);
    }
    return grouped;
  }

  bool _isGoldRing(List<StoryModel> stories) =>
      stories.any((s) => s.type == 'competition');

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return SizedBox(
        height: 90,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          itemCount: 5,
          itemBuilder: (_, __) => Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Column(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(height: 4),
                Container(width: 40, height: 10, color: Colors.grey[300]),
              ],
            ),
          ),
        ),
      );
    }

    final authors = _groupedStories.keys.toList();
    final showEmptyHint = authors.isEmpty;

    return SizedBox(
      height: 90,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: authors.length + (showEmptyHint ? 2 : 1),
        itemBuilder: (context, index) {
          if (index == 0) {
            return _OwnStoryButton(
              onTap: () => context.push(RouteNames.createStory),
            );
          }
          if (showEmptyHint && index == 1) {
            return _AddStoryHint(onTap: () => context.push(RouteNames.createStory));
          }

          final uid = authors[index - 1];
          final stories = _groupedStories[uid]!;
          final first = stories.first;
          final isGold = _isGoldRing(stories);

          return GestureDetector(
            onTap: () => context.push(RouteNames.viewStory, extra: stories),
            child: Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Column(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: isGold
                            ? [Colors.amber, Colors.orange]
                            : [
                                AppColors.adaptivePrimary(context.watch<ThemeProvider>().isDigital),
                                AppColors.adaptivePrimary(context.watch<ThemeProvider>().isDigital).withValues(alpha: 0.6),
                              ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    padding: const EdgeInsets.all(3),
                    child: CircleAvatar(
                      backgroundColor: AppColors.adaptivePrimary(context.watch<ThemeProvider>().isDigital),
                      child: Text(
                        first.authorName[0].toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  SizedBox(
                    width: 64,
                    child: Text(
                      first.authorName.split(' ').first,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _AddStoryHint extends StatelessWidget {
  final VoidCallback onTap;
  const _AddStoryHint({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDigital = context.watch<ThemeProvider>().isDigital;
    final primary = AppColors.adaptivePrimary(isDigital);
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(right: 12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: primary.withValues(alpha: 0.25)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add_circle_outline, size: 14, color: primary),
                  const SizedBox(width: 6),
                  Text(
                    'Add Story',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: primary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Get discovered',
              style: TextStyle(
                  fontSize: 10, color: AppColors.textSubFor(isDigital)),
            ),
          ],
        ),
      ),
    );
  }
}

class _OwnStoryButton extends StatelessWidget {
  final VoidCallback onTap;
  const _OwnStoryButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthProvider>().currentUser;
    final isDigital = context.watch<ThemeProvider>().isDigital;
    final primary = AppColors.adaptivePrimary(isDigital);
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(right: 12),
        child: Column(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: primary.withValues(alpha: 0.2),
                  child: Text(
                    user?.displayName[0].toUpperCase() ?? 'Y',
                    style: TextStyle(
                      color: primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(Icons.add, size: 14, color: Colors.white),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            const Text(
              'Your Story',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}
