import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/providers/theme_provider.dart';
import '../../search/providers/search_provider.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen>
    with SingleTickerProviderStateMixin {
  final _controller = TextEditingController();
  late final TabController _tabController;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SearchProvider>().loadTrending();
    });
  }

  static const _popularIdentities = [
    ('painter', 3400),
    ('musician', 2100),
    ('writer', 1800),
    ('photographer', 1500),
    ('digitalartist', 1200),
  ];

  @override
  void dispose() {
    _controller.dispose();
    _tabController.dispose();
    super.dispose();
  }

  String _fmt(int n) {
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(n % 1000 == 0 ? 0 : 1)}k';
    return '$n';
  }

  @override
  Widget build(BuildContext context) {
    final isDigital = context.watch<ThemeProvider>().isDigital;
    final primary = AppColors.adaptivePrimary(isDigital);
    return Scaffold(
      backgroundColor: AppColors.bg(isDigital),
      appBar: AppBar(
        titleSpacing: 0,
        title: Padding(
          padding: const EdgeInsets.only(right: AppSizes.sm),
          child: TextField(
            controller: _controller,
            autofocus: true,
            onChanged: (v) {
              setState(() => _query = v.trim());
              context.read<SearchProvider>().search(v.trim());
            },
            decoration: InputDecoration(
              hintText: 'Search hashtags, people…',
              border: InputBorder.none,
              suffixIcon: _query.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      onPressed: () {
                        _controller.clear();
                        setState(() => _query = '');
                        context.read<SearchProvider>().clearSearch();
                      },
                    )
                  : null,
            ),
          ),
        ),
        bottom: _query.isNotEmpty
            ? TabBar(
                controller: _tabController,
                labelColor: primary,
                unselectedLabelColor: AppColors.textSubFor(isDigital),
                indicatorColor: primary,
                tabs: const [
                  Tab(text: 'Hashtags'),
                  Tab(text: 'People'),
                ],
              )
            : null,
      ),
      body: _query.isEmpty
          ? _buildEmptyState(context, isDigital)
          : TabBarView(
              controller: _tabController,
              children: [
                _buildHashtagResults(context, isDigital),
                _buildPeopleResults(context, isDigital),
              ],
            ),
    );
  }

  // ─── Empty state ──────────────────────────────────────────────────────────

  Widget _buildEmptyState(BuildContext context, bool isDigital) {
    final primary = AppColors.adaptivePrimary(isDigital);
    final trending = context.watch<SearchProvider>().trendingHashtags;
    return ListView(
      padding: const EdgeInsets.all(AppSizes.md),
      children: [
        const Text('Trending Today',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: AppSizes.sm),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: trending.map((h) {
            return GestureDetector(
              onTap: () => context.push('/hashtag/${h.name}'),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: primary.withValues(alpha: 0.08),
                  borderRadius:
                      BorderRadius.circular(AppSizes.radiusFull),
                  border:
                      Border.all(color: primary.withValues(alpha: 0.3)),
                ),
                child: Text(
                  '#${h.name} ${_fmt(h.postCount)}',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: primary),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: AppSizes.lg),
        const Text('Popular Identities',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: AppSizes.sm),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _popularIdentities.map((entry) {
            final (name, count) = entry;
            return GestureDetector(
              onTap: () => context.push('/hashtag/$name'),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: primary.withValues(alpha: 0.08),
                  borderRadius:
                      BorderRadius.circular(AppSizes.radiusFull),
                  border:
                      Border.all(color: primary.withValues(alpha: 0.3)),
                ),
                child: Text(
                  '#$name ${_fmt(count)}',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: primary),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // ─── Hashtag results ──────────────────────────────────────────────────────

  Widget _buildHashtagResults(BuildContext context, bool isDigital) {
    final primary = AppColors.adaptivePrimary(isDigital);
    final results = context.watch<SearchProvider>().hashtagResults;
    if (results.isEmpty) {
      return _buildNoResults(context, isDigital, 'hashtags');
    }
    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (_, i) {
        final h = results[i];
        final categoryLabel =
            h.category == 'digital' ? 'Digital' : 'Traditional';
        return ListTile(
          onTap: () => context.push('/hashtag/${h.name}'),
          leading: CircleAvatar(
            radius: 20,
            backgroundColor: primary.withValues(alpha: 0.12),
            child: Text('#',
                style: TextStyle(
                    color: primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 14)),
          ),
          title: Text('#${h.name}',
              style: TextStyle(
                  fontWeight: FontWeight.w700, color: primary)),
          subtitle: Text('${h.postCount} posts',
              style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSubFor(isDigital))),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (h.isCompetitionTag)
                Container(
                  margin: const EdgeInsets.only(right: 6),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.gold.withValues(alpha: 0.12),
                    borderRadius:
                        BorderRadius.circular(AppSizes.radiusFull),
                    border: Border.all(
                        color: AppColors.gold.withValues(alpha: 0.4)),
                  ),
                  child: const Text('🏆',
                      style: TextStyle(fontSize: 10)),
                ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: primary.withValues(alpha: 0.1),
                  borderRadius:
                      BorderRadius.circular(AppSizes.radiusFull),
                ),
                child: Text(categoryLabel,
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: primary)),
              ),
            ],
          ),
        );
      },
    );
  }

  // ─── People results ───────────────────────────────────────────────────────

  Widget _buildPeopleResults(BuildContext context, bool isDigital) {
    final primary = AppColors.adaptivePrimary(isDigital);
    final users = context.watch<SearchProvider>().userResults;
    if (users.isEmpty) {
      return _buildNoResults(context, isDigital, 'people');
    }
    return ListView.builder(
      itemCount: users.length,
      itemBuilder: (_, i) {
        final u = users[i];
        return ListTile(
          onTap: () => context.push('/profile/${u.uid}'),
          leading: CircleAvatar(
            radius: 22,
            backgroundColor: primary.withValues(alpha: 0.12),
            backgroundImage: u.photoURL != null
                ? NetworkImage(u.photoURL!)
                : null,
            child: u.photoURL == null
                ? Text(
                    u.displayName.isNotEmpty
                        ? u.displayName[0].toUpperCase()
                        : '?',
                    style: TextStyle(
                        color: primary, fontWeight: FontWeight.bold))
                : null,
          ),
          title: Text(u.displayName,
              style: const TextStyle(
                  fontWeight: FontWeight.w600, fontSize: 14)),
          subtitle: Text('@${u.username}',
              style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSubFor(isDigital))),
          trailing: u.ratingAvgLifetime > 0
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.star_rounded,
                        size: 14, color: AppColors.gold),
                    const SizedBox(width: 2),
                    Text(
                      u.ratingAvgLifetime.toStringAsFixed(1),
                      style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.gold,
                          fontWeight: FontWeight.w700),
                    ),
                  ],
                )
              : null,
        );
      },
    );
  }

  // ─── No results ───────────────────────────────────────────────────────────

  Widget _buildNoResults(
      BuildContext context, bool isDigital, String kind) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off,
                size: 48, color: AppColors.textSubFor(isDigital)),
            const SizedBox(height: AppSizes.md),
            Text(
              'No $kind found for "$_query"',
              style: TextStyle(
                  color: AppColors.textSubFor(isDigital), fontSize: 15),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
