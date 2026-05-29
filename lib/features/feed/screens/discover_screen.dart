import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../config/route_names.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/dummy/dummy_data.dart';
import '../../../core/providers/theme_provider.dart';
import '../../../core/widgets/post_card_widget.dart';
import '../../../models/hashtag_model.dart';
import '../../../models/post_model.dart';
import '../../../services/time_algorithm_service.dart';

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  String _filter = 'all';

  List<HashtagModel> get _trendingHashtags {
    final sorted = [...DummyData.dummyHashtags]..sort((a, b) => b.postCount.compareTo(a.postCount));
    if (_filter == 'all') return sorted;
    return sorted.where((h) => h.category == _filter).toList();
  }

  List<PostModel> get _topRatedPosts {
    final sorted = [...DummyData.dummyPosts]..sort((a, b) => b.ratingAvg.compareTo(a.ratingAvg));
    if (_filter == 'all') return sorted.take(3).toList();
    return sorted.where((p) => p.category.name == _filter).take(3).toList();
  }

  static const List<String> _suggestedFields = ['designer', 'filmmaker', 'digitalartist'];

  @override
  Widget build(BuildContext context) {
    final isDigital = context.watch<ThemeProvider>().isDigital;
    return Scaffold(
      backgroundColor: AppColors.bg(isDigital),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            snap: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
              onPressed: () => context.pop(),
            ),
            title: const Text('Discover'),
          ),
          SliverToBoxAdapter(child: _buildSearchBar(context)),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(AppSizes.md, 0, AppSizes.md, AppSizes.sm),
              child: _FilterRow(current: _filter, onChanged: (f) => setState(() => _filter = f)),
            ),
          ),
          SliverToBoxAdapter(child: _buildTimePicksCard(context)),
          _sectionHeader('Trending Now'),
          SliverToBoxAdapter(child: _buildTrendingRow(context)),
          _sectionHeaderWithAction(
            context,
            'Top Rated This Week',
            'See All',
            () => context.go(RouteNames.explore),
          ),
          _buildTopRated(),
          _sectionHeader('Explore Worlds'),
          SliverToBoxAdapter(child: _buildWorldsPreview(context)),
          _sectionHeader('Fields You Might Like'),
          SliverToBoxAdapter(child: _buildSuggestedFields(context)),
          const SliverToBoxAdapter(child: SizedBox(height: AppSizes.xl)),
        ],
      ),
    );
  }

  // ─── Search bar (tappable only) ──────────────────────────────────────────────

  Widget _buildSearchBar(BuildContext context) {
    final isDigital = context.watch<ThemeProvider>().isDigital;
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSizes.md, AppSizes.sm, AppSizes.md, AppSizes.sm),
      child: GestureDetector(
        onTap: () => context.push(RouteNames.search),
        child: Container(
          height: 44,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(AppSizes.radiusFull),
          ),
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
          child: Row(
            children: [
              Icon(Icons.search, size: 20, color: AppColors.textSubFor(isDigital)),
              const SizedBox(width: AppSizes.sm),
              Text(
                'Search hashtags, worlds, people…',
                style: TextStyle(fontSize: 14, color: AppColors.textSubFor(isDigital).withValues(alpha: 0.7)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Time picks card ────────────────────────────────────────────────────────

  Widget _buildTimePicksCard(BuildContext context) {
    final isDigital = context.watch<ThemeProvider>().isDigital;
    final primary = AppColors.adaptivePrimary(isDigital);
    final algo = TimeAlgorithmService();
    final slot = algo.getTimeSlotInfo();
    final boosted = algo.getBoostedHashtags();
    if (boosted.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.all(AppSizes.md),
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primary.withValues(alpha: 0.1), primary.withValues(alpha: 0.05)],
        ),
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(color: primary.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(slot.emoji, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Text('${slot.name} picks', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            ],
          ),
          const SizedBox(height: 4),
          Text(slot.description, style: TextStyle(fontSize: 12, color: AppColors.textSubFor(isDigital))),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: boosted.take(6).map((h) => GestureDetector(
              onTap: () => context.push('/hashtag/$h'),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: primary.withValues(alpha: 0.3)),
                ),
                child: Text('#$h', style: TextStyle(fontSize: 12, color: primary, fontWeight: FontWeight.w500)),
              ),
            )).toList(),
          ),
        ],
      ),
    );
  }

  // ─── Section headers ─────────────────────────────────────────────────────────

  SliverToBoxAdapter _sectionHeader(String title) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(AppSizes.md, AppSizes.md, AppSizes.md, AppSizes.sm),
        child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      ),
    );
  }

  SliverToBoxAdapter _sectionHeaderWithAction(
    BuildContext context,
    String title,
    String actionLabel,
    VoidCallback onAction,
  ) {
    final primary = AppColors.adaptivePrimary(context.watch<ThemeProvider>().isDigital);
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(AppSizes.md, AppSizes.md, AppSizes.md, AppSizes.sm),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            GestureDetector(
              onTap: onAction,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(actionLabel, style: TextStyle(color: primary, fontWeight: FontWeight.w600, fontSize: 13)),
                  const SizedBox(width: 2),
                  Icon(Icons.arrow_forward, size: 14, color: primary),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Trending Now ────────────────────────────────────────────────────────────

  Widget _buildTrendingRow(BuildContext context) {
    final isDigital = context.watch<ThemeProvider>().isDigital;
    final primary = AppColors.adaptivePrimary(isDigital);
    final trending = _trendingHashtags;
    if (trending.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
        child: Text('No trending hashtags', style: TextStyle(color: AppColors.textSubFor(isDigital))),
      );
    }
    return SizedBox(
      height: 72,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
        itemCount: trending.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (_, i) {
          final h = trending[i];
          return GestureDetector(
            onTap: () => context.push('/hashtag/${h.name}'),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                border: Border.all(color: primary.withValues(alpha: 0.3)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('#${h.name}', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: primary)),
                  const SizedBox(height: 2),
                  Text(_fmt(h.postCount), style: TextStyle(fontSize: 11, color: primary.withValues(alpha: 0.7))),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ─── Top Rated ───────────────────────────────────────────────────────────────

  SliverList _buildTopRated() {
    final posts = _topRatedPosts;
    if (posts.isEmpty) {
      // ignore: prefer_const_constructors — runtime color needed
      return SliverList(
        delegate: SliverChildListDelegate([
          Builder(
            builder: (context) => Padding(
              padding: const EdgeInsets.all(AppSizes.md),
              child: Text('No posts yet', style: TextStyle(color: AppColors.textSubFor(context.watch<ThemeProvider>().isDigital))),
            ),
          ),
        ]),
      );
    }
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (_, i) => PostCardWidget(post: posts[i]),
        childCount: posts.length,
      ),
    );
  }

  // ─── Worlds Preview ──────────────────────────────────────────────────────────

  Widget _buildWorldsPreview(BuildContext context) {
    final worlds = _filter == 'all'
        ? DummyData.worlds
        : _filter == 'traditional'
            ? DummyData.worlds.where((w) => w.traditionalHashtags.isNotEmpty).toList()
            : DummyData.worlds.where((w) => w.digitalHashtags.isNotEmpty).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 110,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
            itemCount: worlds.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (_, i) => _CompactWorldCard(
              world: worlds[i],
              onTap: () => context.push('/world/${worlds[i].id}'),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(AppSizes.md, AppSizes.sm, AppSizes.md, 0),
          child: GestureDetector(
            onTap: () => context.go(RouteNames.explore),
            child: Builder(
              builder: (context) {
                final primary = AppColors.adaptivePrimary(context.watch<ThemeProvider>().isDigital);
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('See All Worlds', style: TextStyle(color: primary, fontWeight: FontWeight.w600, fontSize: 13)),
                    const SizedBox(width: 4),
                    Icon(Icons.arrow_forward, size: 14, color: primary),
                  ],
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  // ─── Suggested Fields ────────────────────────────────────────────────────────

  Widget _buildSuggestedFields(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
      child: Column(
        children: _suggestedFields
            .map((f) => _SuggestedRow(field: f, onTap: () => context.push('/hashtag/$f')))
            .toList(),
      ),
    );
  }

  String _fmt(int n) => n >= 1000 ? '${(n / 1000).toStringAsFixed(n % 1000 == 0 ? 0 : 1)}k posts' : '$n posts';
}

// ─── Filter Row ────────────────────────────────────────────────────────────────

class _FilterRow extends StatelessWidget {
  final String current;
  final ValueChanged<String> onChanged;
  const _FilterRow({required this.current, required this.onChanged});

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
    final primary = AppColors.adaptivePrimary(isDigital);
    final active = current == value;
    return GestureDetector(
      onTap: () => onChanged(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: active ? primary : Colors.transparent,
          borderRadius: BorderRadius.circular(AppSizes.radiusFull),
          border: Border.all(color: active ? primary : AppColors.textSubFor(isDigital).withValues(alpha: 0.35)),
        ),
        child: Text(
          label,
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: active ? AppColors.white : AppColors.textSubFor(isDigital)),
        ),
      ),
    );
  }
}

// ─── Compact World Card (horizontal scroll) ────────────────────────────────────

class _CompactWorldCard extends StatelessWidget {
  final WorldModel world;
  final VoidCallback onTap;
  const _CompactWorldCard({required this.world, required this.onTap});

  static LinearGradient _gradientFor(String id) {
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

  static String _formatCount(int n) {
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(n % 1000 == 0 ? 0 : 1)}k';
    return '$n';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 120,
        decoration: BoxDecoration(
          gradient: _gradientFor(world.id),
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        ),
        padding: const EdgeInsets.all(AppSizes.sm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(world.emoji, style: const TextStyle(fontSize: 26)),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  world.name,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                ),
                Text(
                  _formatCount(world.postCount),
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.75), fontSize: 11),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Suggested Row ─────────────────────────────────────────────────────────────

class _SuggestedRow extends StatefulWidget {
  final String field;
  final VoidCallback onTap;
  const _SuggestedRow({required this.field, required this.onTap});

  @override
  State<_SuggestedRow> createState() => _SuggestedRowState();
}

class _SuggestedRowState extends State<_SuggestedRow> {
  bool _following = false;

  @override
  Widget build(BuildContext context) {
    final isDigital = context.watch<ThemeProvider>().isDigital;
    final primary = AppColors.adaptivePrimary(isDigital);
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        radius: 20,
        backgroundColor: primary.withValues(alpha: 0.1),
        child: Text('#', style: TextStyle(color: primary, fontWeight: FontWeight.bold, fontSize: 14)),
      ),
      title: GestureDetector(
        onTap: widget.onTap,
        child: Text('#${widget.field}', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: primary)),
      ),
      subtitle: Text(
        'Identity field · tap to explore',
        style: TextStyle(fontSize: 11, color: AppColors.textSubFor(isDigital).withValues(alpha: 0.8)),
      ),
      trailing: TextButton(
        onPressed: () => setState(() => _following = !_following),
        style: TextButton.styleFrom(
          foregroundColor: _following ? AppColors.textSubFor(isDigital) : primary,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          side: BorderSide(
            color: _following ? AppColors.textSubFor(isDigital).withValues(alpha: 0.35) : primary.withValues(alpha: 0.5),
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radiusFull)),
        ),
        child: Text(_following ? 'Following' : 'Follow', style: const TextStyle(fontSize: 12)),
      ),
    );
  }
}
