import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/dummy/dummy_data.dart';
import '../../../core/providers/theme_provider.dart';
import '../../../core/widgets/post_card_widget.dart';
import '../../../models/post_model.dart';

class WorldDetailScreen extends StatefulWidget {
  final String worldId;
  const WorldDetailScreen({super.key, required this.worldId});

  @override
  State<WorldDetailScreen> createState() => _WorldDetailScreenState();
}

class _WorldDetailScreenState extends State<WorldDetailScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late final WorldModel? _world;
  String _filter = 'all';

  @override
  void initState() {
    super.initState();
    try {
      _world = DummyData.worlds.firstWhere((w) => w.id == widget.worldId);
    } catch (_) {
      _world = null;
    }
    final hasComp = _world != null && _competitionHashtags(_world).isNotEmpty;
    _tabController = TabController(length: hasComp ? 3 : 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<String> _competitionHashtags(WorldModel world) {
    final allTags = {...world.traditionalHashtags, ...world.digitalHashtags};
    return DummyData.dummyHashtags
        .where((h) => allTags.contains(h.name) && h.isCompetitionTag)
        .map((h) => h.name)
        .toList();
  }

  List<String> get _visibleHashtags {
    if (_world == null) return [];
    switch (_filter) {
      case 'traditional': return _world.traditionalHashtags;
      case 'digital':     return _world.digitalHashtags;
      default:            return [..._world.traditionalHashtags, ..._world.digitalHashtags];
    }
  }

  List<PostModel> get _filteredPosts {
    if (_world == null) return [];
    final tags = Set<String>.from(_visibleHashtags);
    return DummyData.dummyPosts.where((p) => p.hashtags.any(tags.contains)).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (_world == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('World')),
        body: const Center(child: Text('World not found')),
      );
    }

    final world = _world;
    final hasComp = _competitionHashtags(world).isNotEmpty;
    final gradient = _worldGradient(world.id);
    final topRated = [..._filteredPosts]..sort((a, b) => b.ratingAvg.compareTo(a.ratingAvg));
    final latest   = [..._filteredPosts]..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final compTags = _competitionHashtags(world);

    return Scaffold(
      body: Column(
        children: [
          // ── Header ──────────────────────────────────────────────────────
          _WorldHeader(world: world, gradient: gradient),
          // ── Filter + Hashtags ───────────────────────────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(AppSizes.md, AppSizes.sm, AppSizes.md, 0),
            child: _FilterToggle(current: _filter, onChanged: (f) => setState(() => _filter = f)),
          ),
          _HashtagsRow(hashtags: _visibleHashtags),
          // ── Tab Bar ─────────────────────────────────────────────────────
          TabBar(
            controller: _tabController,
            tabs: [
              const Tab(text: 'Top Rated'),
              const Tab(text: 'Latest'),
              if (hasComp) const Tab(text: 'Competitions'),
            ],
          ),
          // ── Tab Content ─────────────────────────────────────────────────
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _PostsTab(posts: topRated),
                _PostsTab(posts: latest),
                if (hasComp) _CompetitionsTab(competitionTagNames: compTags),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Header ────────────────────────────────────────────────────────────────────

class _WorldHeader extends StatelessWidget {
  final WorldModel world;
  final LinearGradient gradient;
  const _WorldHeader({required this.world, required this.gradient});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(gradient: gradient),
      padding: EdgeInsets.fromLTRB(
        AppSizes.md,
        MediaQuery.of(context).padding.top + AppSizes.sm,
        AppSizes.md,
        AppSizes.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 4),
          Text(world.emoji, style: const TextStyle(fontSize: 44)),
          const SizedBox(height: 4),
          Text(
            world.name,
            style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 2),
          Text(
            world.description,
            style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 13),
          ),
          const SizedBox(height: 8),
          Text(
            '${_worldCount(world.postCount)} posts',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

// ─── Filter Toggle ─────────────────────────────────────────────────────────────

class _FilterToggle extends StatelessWidget {
  final String current;
  final ValueChanged<String> onChanged;
  const _FilterToggle({required this.current, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _Chip('All', 'all', current, onChanged),
        const SizedBox(width: 8),
        _Chip('🎨 Traditional', 'traditional', current, onChanged),
        const SizedBox(width: 8),
        _Chip('💻 Digital', 'digital', current, onChanged),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final String value;
  final String current;
  final ValueChanged<String> onChanged;
  const _Chip(this.label, this.value, this.current, this.onChanged);

  @override
  Widget build(BuildContext context) {
    final isDigital = context.watch<ThemeProvider>().isDigital;
    final active = current == value;
    final primary = AppColors.adaptivePrimary(isDigital);
    return GestureDetector(
      onTap: () => onChanged(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: active ? primary : Colors.transparent,
          borderRadius: BorderRadius.circular(AppSizes.radiusFull),
          border: Border.all(color: active ? primary : AppColors.textSubFor(isDigital).withValues(alpha: 0.35)),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: active ? AppColors.white : AppColors.textSubFor(isDigital),
          ),
        ),
      ),
    );
  }
}

// ─── Hashtags Row ──────────────────────────────────────────────────────────────

class _HashtagsRow extends StatelessWidget {
  final List<String> hashtags;
  const _HashtagsRow({required this.hashtags});

  @override
  Widget build(BuildContext context) {
    if (hashtags.isEmpty) return const SizedBox(height: AppSizes.sm);
    return SizedBox(
      height: 46,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(AppSizes.md, AppSizes.sm, AppSizes.md, 0),
        itemCount: hashtags.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final isDigital = context.watch<ThemeProvider>().isDigital;
          final primary = AppColors.adaptivePrimary(isDigital);
          final name = hashtags[i];
          final meta = DummyData.dummyHashtags.where((h) => h.name == name).firstOrNull;
          final suffix = meta != null ? ' (${meta.postCount})' : '';
          return GestureDetector(
            onTap: () => context.push('/hashtag/$name'),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: primary.withValues(alpha: 0.07),
                borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                border: Border.all(color: primary.withValues(alpha: 0.3)),
              ),
              child: Text('#$name$suffix', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: primary)),
            ),
          );
        },
      ),
    );
  }
}

LinearGradient _worldGradient(String id) {
  switch (id) {
    case 'art':         return const LinearGradient(colors: [Color(0xFFFF7043), Color(0xFFFFAB91)], begin: Alignment.topLeft, end: Alignment.bottomRight);
    case 'music':       return const LinearGradient(colors: [Color(0xFF7C3AED), Color(0xFFB388FF)], begin: Alignment.topLeft, end: Alignment.bottomRight);
    case 'words':       return const LinearGradient(colors: [Color(0xFF0D9488), Color(0xFF5EEAD4)], begin: Alignment.topLeft, end: Alignment.bottomRight);
    case 'tech':        return const LinearGradient(colors: [Color(0xFF1E3A5F), Color(0xFF2563EB)], begin: Alignment.topLeft, end: Alignment.bottomRight);
    case 'roots':       return const LinearGradient(colors: [Color(0xFF16A34A), Color(0xFF86EFAC)], begin: Alignment.topLeft, end: Alignment.bottomRight);
    case 'food':        return const LinearGradient(colors: [Color(0xFFDC2626), Color(0xFFFB923C)], begin: Alignment.topLeft, end: Alignment.bottomRight);
    case 'sports':      return const LinearGradient(colors: [Color(0xFF1D4ED8), Color(0xFF60A5FA)], begin: Alignment.topLeft, end: Alignment.bottomRight);
    case 'performance': return const LinearGradient(colors: [Color(0xFFBE185D), Color(0xFFF9A8D4)], begin: Alignment.topLeft, end: Alignment.bottomRight);
    case 'ideas':       return const LinearGradient(colors: [Color(0xFFD97706), Color(0xFFFDE68A)], begin: Alignment.topLeft, end: Alignment.bottomRight);
    case 'society':     return const LinearGradient(colors: [Color(0xFF475569), Color(0xFF94A3B8)], begin: Alignment.topLeft, end: Alignment.bottomRight);
    default:            return const LinearGradient(colors: [Color(0xFF6C63FF), Color(0xFF9C95FF)], begin: Alignment.topLeft, end: Alignment.bottomRight);
  }
}

String _worldCount(int n) {
  if (n >= 1000) return '${(n / 1000).toStringAsFixed(n % 1000 == 0 ? 0 : 1)}k';
  return '$n';
}

// ─── Posts Tab ─────────────────────────────────────────────────────────────────

class _PostsTab extends StatelessWidget {
  final List<PostModel> posts;
  const _PostsTab({required this.posts});

  @override
  Widget build(BuildContext context) {
    final isDigital = context.watch<ThemeProvider>().isDigital;
    if (posts.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.xl),
          child: Text('No posts yet in this world', style: TextStyle(color: AppColors.textSubFor(isDigital))),
        ),
      );
    }
    return ListView.builder(
      itemCount: posts.length,
      itemBuilder: (_, i) => PostCardWidget(post: posts[i]),
    );
  }
}

// ─── Competitions Tab ──────────────────────────────────────────────────────────

class _CompetitionsTab extends StatelessWidget {
  final List<String> competitionTagNames;
  const _CompetitionsTab({required this.competitionTagNames});

  @override
  Widget build(BuildContext context) {
    final compHashtags = DummyData.dummyHashtags
        .where((h) => competitionTagNames.contains(h.name))
        .toList();

    return ListView.builder(
      padding: const EdgeInsets.all(AppSizes.md),
      itemCount: compHashtags.length,
      itemBuilder: (_, i) {
        final isDigital = context.watch<ThemeProvider>().isDigital;
        final h = compHashtags[i];
        final isDigitalCategory = h.category == 'digital';
        final color = AppColors.adaptivePrimary(isDigital);
        final now = DateTime.now();
        final end = DateTime(2026, 5, 31);
        final daysLeft = end.difference(now).inDays.clamp(0, 30);

        return Card(
          margin: const EdgeInsets.only(bottom: AppSizes.sm),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radiusLg)),
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '#${h.name}',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                        border: Border.all(color: color.withValues(alpha: 0.3)),
                      ),
                      child: Text(
                        isDigitalCategory ? 'Digital' : 'Traditional',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.people_outline, size: 14, color: AppColors.textSubFor(isDigital)),
                    const SizedBox(width: 4),
                    Text('${h.postCount} participants', style: TextStyle(fontSize: 12, color: AppColors.textSubFor(isDigital))),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.gold.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                      ),
                      child: Text(
                        '$daysLeft days left',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.gold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => context.push('/hashtag/${h.name}'),
                    child: const Text('View Competition'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
