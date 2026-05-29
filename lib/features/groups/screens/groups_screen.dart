import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../config/route_names.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/dummy/dummy_data.dart';
import '../../../core/providers/theme_provider.dart';
import '../../../services/firestore_service.dart';
import '../../../features/auth/providers/auth_provider.dart';

class GroupsScreen extends StatefulWidget {
  const GroupsScreen({super.key});

  @override
  State<GroupsScreen> createState() => _GroupsScreenState();
}

class _GroupsScreenState extends State<GroupsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  // Groups the current user (user_001) has joined
  List<GroupModel> get _myGroups =>
      DummyData.dummyGroups.where((g) => g.memberIds.contains('user_001')).toList();

  // Groups the current user has NOT joined
  List<GroupModel> get _discoverGroups =>
      DummyData.dummyGroups.where((g) => !g.memberIds.contains('user_001')).toList();

  // Track locally joined groups in Discover tab
  final Set<String> _joinedIds = {};

  // Filter state for Discover tab
  String _filter = 'All';

  CharityPoolModel? _poolFor(String groupId) =>
      DummyData.dummyPools.where((p) => p.groupId == groupId).firstOrNull;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDigital = context.watch<ThemeProvider>().isDigital;
    return Scaffold(
      backgroundColor: AppColors.bg(isDigital),
      appBar: AppBar(
        title: const Text('Groups & Communities', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Create Group',
            onPressed: () => context.push(RouteNames.createGroup),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [Tab(text: 'My Groups'), Tab(text: 'Discover')],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildMyGroups(isDigital),
          _buildDiscover(isDigital),
        ],
      ),
    );
  }

  // ── My Groups tab ─────────────────────────────────────────────────────────

  Widget _buildMyGroups(bool isDigital) {
    final groups = _myGroups;
    if (groups.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.group_outlined, size: 48, color: AppColors.textSubFor(isDigital)),
            const SizedBox(height: AppSizes.md),
            Text('You haven\'t joined any groups yet.',
                style: TextStyle(color: AppColors.textSubFor(isDigital))),
            const SizedBox(height: AppSizes.sm),
            OutlinedButton(
              onPressed: () => _tabController.animateTo(1),
              child: const Text('Discover Groups'),
            ),
          ],
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(AppSizes.md),
      itemCount: groups.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSizes.sm),
      itemBuilder: (_, i) => _GroupCard(
        group: groups[i],
        pool: _poolFor(groups[i].id),
        isDigital: isDigital,
        onTap: () => context.push('/groups/${groups[i].id}'),
      ),
    );
  }

  // ── Discover tab ──────────────────────────────────────────────────────────

  Widget _buildDiscover(bool isDigital) {
    var groups = _discoverGroups;
    if (_filter != 'All') {
      final cat = _filter.toLowerCase();
      groups = groups.where((g) => g.category == cat).toList();
    }

    final primary = AppColors.adaptivePrimary(isDigital);
    return Column(
      children: [
        // Filter chips
        Padding(
          padding: const EdgeInsets.fromLTRB(AppSizes.md, AppSizes.sm, AppSizes.md, 0),
          child: Row(
            children: ['All', 'Traditional', 'Digital'].map((label) {
              final selected = _filter == label;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(label),
                  selected: selected,
                  onSelected: (_) => setState(() => _filter = label),
                  selectedColor: primary.withValues(alpha: 0.15),
                  checkmarkColor: primary,
                  labelStyle: TextStyle(
                    color: selected ? primary : AppColors.textSubFor(isDigital),
                    fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                    fontSize: 13,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        Expanded(
          child: groups.isEmpty
              ? Center(child: Text('No groups found', style: TextStyle(color: AppColors.textSubFor(isDigital))))
              : ListView.separated(
                  padding: const EdgeInsets.all(AppSizes.md),
                  itemCount: groups.length,
                  separatorBuilder: (_, __) => const SizedBox(height: AppSizes.sm),
                  itemBuilder: (_, i) {
                    final g = groups[i];
                    final joined = _joinedIds.contains(g.id);
                    return _DiscoverGroupCard(
                      group: g,
                      joined: joined,
                      isDigital: isDigital,
                      onJoin: () async {
                        final uid = context.read<AuthProvider>().currentUser?.uid ?? 'user_001';
                        setState(() {
                          if (joined) {
                            _joinedIds.remove(g.id);
                          } else {
                            _joinedIds.add(g.id);
                          }
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(joined ? 'Left ${g.name}' : 'Joined ${g.name}!')),
                        );
                        if (!joined) {
                          try {
                            await FirestoreService().joinGroup(g.id, uid);
                          } catch (e) {
                            debugPrint('Join group error: $e');
                          }
                        }
                      },
                      onTap: () => context.push('/groups/${g.id}'),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

// ── Group Card (My Groups) ───────────────────────────────────────────────────

class _GroupCard extends StatelessWidget {
  final GroupModel group;
  final CharityPoolModel? pool;
  final bool isDigital;
  final VoidCallback onTap;
  const _GroupCard({required this.group, required this.pool, required this.isDigital, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = AppColors.adaptivePrimary(isDigital);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSizes.md),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Avatar circle with initial
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    group.name[0].toUpperCase(),
                    style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 18),
                  ),
                ),
                const SizedBox(width: AppSizes.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              group.name,
                              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (group.isCommunity) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.gold.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(100),
                                border: Border.all(color: AppColors.gold.withValues(alpha: 0.5)),
                              ),
                              child: const Text('Community', style: TextStyle(fontSize: 10, color: AppColors.gold, fontWeight: FontWeight.w700)),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '#${group.identityHashtag}  •  ${group.category == 'traditional' ? 'Traditional' : 'Digital'}  •  ${group.memberCount} members',
                        style: TextStyle(fontSize: 12, color: AppColors.textSubFor(isDigital)),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: AppColors.textSubFor(isDigital)),
              ],
            ),
            if (pool != null) ...[
              const SizedBox(height: AppSizes.sm),
              const Divider(height: 1),
              const SizedBox(height: AppSizes.sm),
              _PoolPreviewRow(pool: pool!, isDigital: isDigital),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Pool preview row inside group card ──────────────────────────────────────

class _PoolPreviewRow extends StatelessWidget {
  final CharityPoolModel pool;
  final bool isDigital;
  const _PoolPreviewRow({required this.pool, required this.isDigital});

  @override
  Widget build(BuildContext context) {
    final pct = (pool.raisedDA / pool.targetDA).clamp(0.0, 1.0);
    final raised = _fmtDA(pool.raisedDA);
    final target = _fmtDA(pool.targetDA);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.favorite_outline, size: 14, color: AppColors.success),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                '🟢 Active Pool: ${pool.title}',
                style: const TextStyle(fontSize: 12, color: AppColors.success, fontWeight: FontWeight.w600),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              '${(pct * 100).round()}%',
              style: const TextStyle(fontSize: 12, color: AppColors.success, fontWeight: FontWeight.w700),
            ),
          ],
        ),
        const SizedBox(height: 5),
        ClipRRect(
          borderRadius: BorderRadius.circular(100),
          child: LinearProgressIndicator(
            value: pct,
            minHeight: 5,
            backgroundColor: AppColors.success.withValues(alpha: 0.12),
            color: AppColors.success,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '$raised / $target DA raised',
          style: TextStyle(fontSize: 11, color: AppColors.textSubFor(isDigital)),
        ),
      ],
    );
  }

  String _fmtDA(double v) =>
      v >= 1000 ? '${(v / 1000).toStringAsFixed(v % 1000 == 0 ? 0 : 1)}k' : v.toStringAsFixed(0);
}

// ── Discover Group Card ──────────────────────────────────────────────────────

class _DiscoverGroupCard extends StatelessWidget {
  final GroupModel group;
  final bool joined;
  final bool isDigital;
  final VoidCallback onJoin;
  final VoidCallback onTap;
  const _DiscoverGroupCard({
    required this.group,
    required this.joined,
    required this.isDigital,
    required this.onJoin,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = AppColors.adaptivePrimary(isDigital);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSizes.md),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                group.name[0].toUpperCase(),
                style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 18),
              ),
            ),
            const SizedBox(width: AppSizes.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          group.name,
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (group.isCommunity) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.gold.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: const Text('Community', style: TextStyle(fontSize: 10, color: AppColors.gold, fontWeight: FontWeight.w700)),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '#${group.identityHashtag}  •  ${group.memberCount} members',
                    style: TextStyle(fontSize: 12, color: AppColors.textSubFor(isDigital)),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    group.description,
                    style: TextStyle(fontSize: 12, color: AppColors.textSubFor(isDigital)),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSizes.sm),
            joined
                ? OutlinedButton(
                    onPressed: onJoin,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      side: BorderSide(color: AppColors.textSubFor(isDigital).withValues(alpha: 0.4)),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text('Leave', style: TextStyle(fontSize: 12, color: AppColors.textSubFor(isDigital))),
                  )
                : FilledButton(
                    onPressed: onJoin,
                    style: FilledButton.styleFrom(
                      backgroundColor: color,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text('Join', style: TextStyle(fontSize: 12)),
                  ),
          ],
        ),
      ),
    );
  }
}
