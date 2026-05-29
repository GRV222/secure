import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/competition_provider.dart';
import '../../../config/route_names.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/dummy/dummy_data.dart';
import '../../../core/providers/theme_provider.dart';
import '../../../core/widgets/winner_celebration.dart';
import '../../../models/competition_model.dart';

class CompetitionScreen extends StatefulWidget {
  const CompetitionScreen({super.key});

  @override
  State<CompetitionScreen> createState() => _CompetitionScreenState();
}

class _CompetitionScreenState extends State<CompetitionScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  String _filter = 'all';

  WorldModel? _worldFor(String name) {
    for (final w in DummyData.worlds) {
      if (w.traditionalHashtags.contains(name) || w.digitalHashtags.contains(name)) return w;
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CompetitionProvider>().loadCompetitions();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CompetitionProvider>();
    final isDigital = context.watch<ThemeProvider>().isDigital;

    List<CompetitionModel> activeComps = provider.activeCompetitions;
    if (_filter != 'all') {
      activeComps = activeComps
          .where((c) => c.category.name == _filter)
          .toList();
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              color: AppColors.adaptivePrimary(isDigital)),
          onPressed: () => context.pop(),
        ),
        title: const Text('Compete', style: TextStyle(fontWeight: FontWeight.bold)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(84),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(AppSizes.md, 0, AppSizes.md, AppSizes.sm),
                child: _FilterRow(current: _filter, onChanged: (f) => setState(() => _filter = f)),
              ),
              TabBar(
                controller: _tabController,
                tabs: const [Tab(text: 'Active'), Tab(text: 'Past')],
              ),
            ],
          ),
        ),
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildActiveTab(activeComps),
                _buildPastTab(provider.pastCompetitions),
              ],
            ),
    );
  }

  Widget _buildActiveTab(List<CompetitionModel> comps) {
    final isDigital = context.watch<ThemeProvider>().isDigital;
    if (comps.isEmpty) {
      return Center(
        child: Text(
          'No active competitions in this category',
          style: TextStyle(color: AppColors.textSubFor(isDigital)),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(AppSizes.md),
      itemCount: comps.length,
      itemBuilder: (_, i) => _CompCard(
        competition: comps[i],
        world: _worldFor(comps[i].hashtag),
      ),
    );
  }

  Widget _buildPastTab(List<CompetitionModel> comps) {
    final isDigital = context.watch<ThemeProvider>().isDigital;
    if (comps.isEmpty) {
      return Center(
        child: Text('No past competitions yet', style: TextStyle(color: AppColors.textSubFor(isDigital))),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(AppSizes.md),
      itemCount: comps.length,
      itemBuilder: (_, i) => _PastCard(competition: comps[i]),
    );
  }

}

// ─── Competition Card ──────────────────────────────────────────────────────────

class _CompCard extends StatelessWidget {
  final CompetitionModel competition;
  final WorldModel? world;
  const _CompCard({required this.competition, this.world});

  @override
  Widget build(BuildContext context) {
    final isDigital = context.watch<ThemeProvider>().isDigital;
    final isDigitalCompetition = competition.category == CompetitionCategory.digital;
    final color = isDigitalCompetition ? AppColors.digAccent : AppColors.tradAccent;
    final categoryLabel = isDigitalCompetition ? 'Digital' : 'Traditional';

    final now = DateTime.now();
    final start = competition.startDate;
    final end = competition.ratingDeadline;
    final totalDays = end.difference(start).inDays;
    final elapsed = now.difference(start).inDays.clamp(0, totalDays);
    final daysLeft = end.difference(now).inDays.clamp(0, totalDays);
    final progress = totalDays > 0 ? elapsed / totalDays : 0.0;

    return Card(
      margin: const EdgeInsets.only(bottom: AppSizes.md),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        side: BorderSide(color: color.withValues(alpha: 0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('🏆 ', style: TextStyle(fontSize: 18)),
                Expanded(
                  child: Text(
                    '#${competition.hashtag}',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '$categoryLabel${world != null ? ' · ${world!.name} World' : ''}',
              style: TextStyle(fontSize: 13, color: AppColors.textSubFor(isDigital)),
            ),
            const SizedBox(height: AppSizes.sm),
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: Colors.grey.shade200,
                      color: color,
                      minHeight: 7,
                    ),
                  ),
                ),
                const SizedBox(width: AppSizes.sm),
                Text(
                  '$daysLeft/$totalDays days',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.sm),
            Row(
              children: [
                Icon(Icons.people_outline, size: 14, color: AppColors.textSubFor(isDigital)),
                const SizedBox(width: 4),
                Text(
                  '${_fmt(competition.participantCount)} entries',
                  style: TextStyle(fontSize: 12, color: AppColors.textSubFor(isDigital)),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.sm),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.gold.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.lock_outline, size: 13, color: AppColors.gold),
                  SizedBox(width: 5),
                  Text('Prize: Locked — Phase 2', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.gold)),
                ],
              ),
            ),
            const SizedBox(height: AppSizes.sm),
            Text(
              'How to enter: "Post with #${competition.hashtag}"',
              style: TextStyle(fontSize: 12, color: AppColors.textSubFor(isDigital)),
            ),
            const SizedBox(height: AppSizes.sm),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => context.push(
                      RouteNames.leaderboard,
                      extra: competition.hashtag,
                    ),
                    child: const Text('View Leaderboard'),
                  ),
                ),
                const SizedBox(width: AppSizes.sm),
                Expanded(
                  child: FilledButton(
                    onPressed: () => context.push(RouteNames.createPost),
                    child: const Text('Enter Now'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _fmt(int n) {
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return '$n';
  }
}

// ─── Past Card ─────────────────────────────────────────────────────────────────

class _PastCard extends StatelessWidget {
  final CompetitionModel competition;
  const _PastCard({required this.competition});

  static const _winnerNames = {
    'user_002': 'Priya Sharma',
    'user_004': 'Kavya Nair',
    'user_005': 'Rohit Verma',
  };

  @override
  Widget build(BuildContext context) {
    final isDigital = context.watch<ThemeProvider>().isDigital;
    final primary = AppColors.adaptivePrimary(isDigital);
    final winnerDisplay = competition.winnerId != null
        ? (_winnerNames[competition.winnerId!] ?? competition.winnerId!)
        : '—';
    final initial = winnerDisplay.isNotEmpty ? winnerDisplay[0].toUpperCase() : '?';

    return Card(
      margin: const EdgeInsets.only(bottom: AppSizes.sm),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radiusLg)),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.md),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: primary,
              child: Text(
                initial,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            const SizedBox(width: AppSizes.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '#${competition.hashtag}',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: primary),
                  ),
                  Text(competition.month, style: TextStyle(fontSize: 12, color: AppColors.textSubFor(isDigital))),
                  const SizedBox(height: 2),
                  Text(
                    competition.winnerId != null ? 'Winner: $winnerDisplay' : 'Winner pending',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
            if (competition.winnerId != null)
              GestureDetector(
                onTap: () => showDialog(
                  context: context,
                  barrierColor: Colors.black.withValues(alpha: 0.7),
                  builder: (_) => Dialog(
                    backgroundColor: Colors.transparent,
                    insetPadding: const EdgeInsets.all(16),
                    child: WinnerCelebration(
                      winnerName: winnerDisplay,
                      hashtag: competition.hashtag,
                      ratingAvg: 4.8,
                      ratingCount: 0,
                      onDismiss: () => Navigator.pop(context),
                    ),
                  ),
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.gold.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.gold.withValues(alpha: 0.3)),
                  ),
                  child: const Text('🏆', style: TextStyle(fontSize: 16)),
                ),
              )
            else
              const Icon(Icons.emoji_events, size: 20, color: AppColors.gold),
          ],
        ),
      ),
    );
  }
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
        const SizedBox(width: AppSizes.sm),
        _Chip('🎨 Traditional', 'traditional', current, onChanged),
        const SizedBox(width: AppSizes.sm),
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
