import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../config/route_names.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/providers/theme_provider.dart';
import '../../../models/journey_model.dart';
import '../../../models/story_model.dart';
import '../../../services/firestore_service.dart';

class JourneyDetailScreen extends StatefulWidget {
  final JourneyModel journey;
  const JourneyDetailScreen({super.key, required this.journey});

  @override
  State<JourneyDetailScreen> createState() => _JourneyDetailScreenState();
}

class _JourneyDetailScreenState extends State<JourneyDetailScreen> {
  List<StoryModel> _stories = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final stories = await FirestoreService().getJourneyStories(widget.journey.journeyId);
      if (mounted) setState(() { _stories = stories; _isLoading = false; });
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _formatDate(DateTime dt) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    final isDigital = context.watch<ThemeProvider>().isDigital;
    final primary = AppColors.adaptivePrimary(isDigital);
    final j = widget.journey;
    return Scaffold(
      backgroundColor: j.category == 'traditional'
          ? const Color(0xFF1A0A00)
          : const Color(0xFF0A0A1A),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 180,
            pinned: true,
            backgroundColor: j.category == 'traditional'
                ? const Color(0xFF1A0A00)
                : const Color(0xFF0A0A1A),
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: j.category == 'traditional'
                        ? [const Color(0xFF3D1A00), const Color(0xFF1A0A00)]
                        : [const Color(0xFF0A0A3A), const Color(0xFF0A0A1A)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 56, 20, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.auto_stories_outlined, color: Colors.white70, size: 28),
                        const SizedBox(height: 8),
                        Text(
                          j.title,
                          style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (j.hashtag.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text('#${j.hashtag}', style: TextStyle(color: primary.withValues(alpha: 0.8), fontSize: 13)),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _InfoChip(icon: Icons.calendar_today_outlined, label: _formatDate(j.startDate)),
                      const SizedBox(width: 10),
                      _InfoChip(icon: Icons.layers_outlined, label: '${j.dayCount} days'),
                      const SizedBox(width: 10),
                      _InfoChip(
                        icon: j.isActive ? Icons.play_circle_outline : Icons.check_circle_outline,
                        label: j.isActive ? 'Active' : 'Completed',
                        color: j.isActive ? Colors.green : Colors.white38,
                      ),
                    ],
                  ),

                  if (j.description.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text(
                      j.description,
                      style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.5),
                    ),
                  ],

                  const SizedBox(height: 24),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Stories  (${_stories.length})',
                        style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      GestureDetector(
                        onTap: () => context.push(RouteNames.createStory),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: primary.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: primary.withValues(alpha: 0.5)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.add, color: primary, size: 14),
                              const SizedBox(width: 4),
                              Text('Add Story', style: TextStyle(color: primary, fontSize: 12, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          if (_isLoading)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator(color: Colors.white54)),
            )
          else if (_stories.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.auto_stories_outlined, color: Colors.white24, size: 48),
                    const SizedBox(height: 12),
                    const Text('No stories yet', style: TextStyle(color: Colors.white38, fontSize: 15)),
                    const SizedBox(height: 8),
                    const Text('Add your first work story to this journey', style: TextStyle(color: Colors.white24, fontSize: 12)),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: () => context.push(RouteNames.createStory),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        decoration: BoxDecoration(
                          color: primary,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: const Text('Add Story', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (_, i) => _StoryTile(story: _stories[i], day: i + 1),
                  childCount: _stories.length,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;
  const _InfoChip({required this.icon, required this.label, this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ?? Colors.white54;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: c, size: 13),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(color: c, fontSize: 12)),
      ],
    );
  }
}

class _StoryTile extends StatelessWidget {
  final StoryModel story;
  final int day;
  const _StoryTile({required this.story, required this.day});

  @override
  Widget build(BuildContext context) {
    final primary = AppColors.adaptivePrimary(context.watch<ThemeProvider>().isDigital);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: primary.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                  border: Border.all(color: primary.withValues(alpha: 0.5)),
                ),
                child: Center(
                  child: Text(
                    '$day',
                    style: TextStyle(color: primary, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Day $day',
                style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              Text(
                '${story.respectBy.length + story.loveBy.length} reactions',
                style: const TextStyle(color: Colors.white38, fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            story.content,
            style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.5),
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
