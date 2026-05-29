import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/competition_provider.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/providers/theme_provider.dart';

class LeaderboardScreen extends StatefulWidget {
  final String hashtag;
  const LeaderboardScreen({super.key, required this.hashtag});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CompetitionProvider>().loadLeaderboard(widget.hashtag);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDigital = context.watch<ThemeProvider>().isDigital;
    final provider = context.watch<CompetitionProvider>();
    final myUid = context.read<AuthProvider>().currentUser?.uid ?? '';

    final entries = provider.leaderboard.map((p) => _Entry(
          name: p.authorName,
          initial: p.authorName.isNotEmpty ? p.authorName[0].toUpperCase() : '?',
          rating: p.ratingAvg,
          count: p.ratingCount,
          uid: p.uid,
        )).toList();

    final myIndex = entries.indexWhere((e) => e.uid == myUid);
    final inTop = myIndex >= 0 && myIndex < 5;
    final primary = AppColors.adaptivePrimary(isDigital);

    return Scaffold(
      backgroundColor: AppColors.bg(isDigital),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '#${widget.hashtag}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Text(
              'Leaderboard',
              style: TextStyle(fontSize: 12, color: AppColors.textSubFor(isDigital)),
            ),
          ],
        ),
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : entries.isEmpty
              ? Center(
                  child: Text(
                    'No entries yet. Be the first to post!',
                    style: TextStyle(color: AppColors.textSubFor(isDigital)),
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.all(AppSizes.md),
                  children: [
                    _PodiumSection(entries: entries.take(3).toList()),
                    const SizedBox(height: AppSizes.lg),
                    ...List.generate(entries.take(5).length, (i) {
                      final entry = entries[i];
                      return _LeaderRow(
                        rank: i + 1,
                        entry: entry,
                        highlighted: entry.uid == myUid,
                      );
                    }),
                    if (!inTop && myUid.isNotEmpty) ...[
                      const Divider(height: AppSizes.lg),
                      _LeaderRow(
                        rank: myIndex >= 0 ? myIndex + 1 : entries.length + 1,
                        entry: myIndex >= 0
                            ? entries[myIndex]
                            : _Entry(
                                name: context.read<AuthProvider>().currentUser?.displayName ?? 'You',
                                initial: (context.read<AuthProvider>().currentUser?.displayName ?? 'Y')[0].toUpperCase(),
                                rating: 0.0,
                                count: 0,
                                uid: myUid,
                              ),
                        highlighted: true,
                        isYou: true,
                      ),
                    ],
                    const SizedBox(height: AppSizes.lg),
                    Container(
                      padding: const EdgeInsets.all(AppSizes.md),
                      decoration: BoxDecoration(
                        color: primary.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                        border: Border.all(color: primary.withValues(alpha: 0.15)),
                      ),
                      child: Text(
                        'Leaderboard updates in real time based on community ratings.',
                        style: TextStyle(fontSize: 12, color: AppColors.textSubFor(isDigital), height: 1.5),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: AppSizes.xl),
                  ],
                ),
    );
  }
}

class _Entry {
  final String name;
  final String initial;
  final double rating;
  final int count;
  final String uid;
  const _Entry({
    required this.name,
    required this.initial,
    required this.rating,
    required this.count,
    required this.uid,
  });
}

// ─── Podium ────────────────────────────────────────────────────────────────────

class _PodiumSection extends StatelessWidget {
  final List<_Entry> entries;
  const _PodiumSection({required this.entries});

  @override
  Widget build(BuildContext context) {
    final isDigital = context.watch<ThemeProvider>().isDigital;
    final primary = AppColors.adaptivePrimary(isDigital);
    if (entries.length < 3) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.md),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primary.withValues(alpha: 0.06), primary.withValues(alpha: 0.02)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
      ),
      child: Column(
        children: [
          Text('🏆 Top 3', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textSubFor(isDigital))),
          const SizedBox(height: AppSizes.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _PodiumSlot(entry: entries[1], rank: 2, blockHeight: 60, medal: '🥈', medalColor: AppColors.silver),
              _PodiumSlot(entry: entries[0], rank: 1, blockHeight: 88, medal: '🥇', medalColor: AppColors.gold),
              _PodiumSlot(entry: entries[2], rank: 3, blockHeight: 44, medal: '🥉', medalColor: AppColors.bronze),
            ],
          ),
        ],
      ),
    );
  }
}

class _PodiumSlot extends StatelessWidget {
  final _Entry entry;
  final int rank;
  final double blockHeight;
  final String medal;
  final Color medalColor;
  const _PodiumSlot({required this.entry, required this.rank, required this.blockHeight, required this.medal, required this.medalColor});

  @override
  Widget build(BuildContext context) {
    final isDigital = context.watch<ThemeProvider>().isDigital;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          radius: rank == 1 ? 28 : 22,
          backgroundColor: AppColors.adaptivePrimary(isDigital).withValues(alpha: rank == 1 ? 0.9 : 0.6),
          child: Text(
            entry.initial,
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: rank == 1 ? 20 : 16),
          ),
        ),
        const SizedBox(height: 6),
        Text(entry.name.split(' ').first, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.star_rounded, size: 12, color: AppColors.gold),
            Text(entry.rating.toStringAsFixed(1), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
          ],
        ),
        const SizedBox(height: 4),
        Text(medal, style: const TextStyle(fontSize: 20)),
        Container(
          width: 70,
          height: blockHeight,
          decoration: BoxDecoration(
            color: medalColor.withValues(alpha: 0.15),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
          ),
          alignment: Alignment.center,
          child: Text('$rank', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: medalColor)),
        ),
      ],
    );
  }
}

// ─── Leaderboard Row ───────────────────────────────────────────────────────────

class _LeaderRow extends StatelessWidget {
  final int rank;
  final _Entry entry;
  final bool highlighted;
  final bool isYou;
  const _LeaderRow({
    required this.rank,
    required this.entry,
    this.highlighted = false,
    this.isYou = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDigital = context.watch<ThemeProvider>().isDigital;
    final primary = AppColors.adaptivePrimary(isDigital);
    final Color? rankColor = rank == 1
        ? AppColors.gold
        : rank == 2
            ? AppColors.silver
            : rank == 3
                ? AppColors.bronze
                : null;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.xs),
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.md, vertical: 10),
      decoration: BoxDecoration(
        color: highlighted ? primary.withValues(alpha: 0.07) : null,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: highlighted ? Border.all(color: primary.withValues(alpha: 0.25)) : null,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 28,
            child: Text(
              '#$rank',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: rankColor ?? AppColors.textSubFor(isDigital)),
            ),
          ),
          const SizedBox(width: AppSizes.sm),
          CircleAvatar(
            radius: 18,
            backgroundColor: highlighted ? primary : primary.withValues(alpha: 0.5),
            child: Text(entry.initial, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
          ),
          const SizedBox(width: AppSizes.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(entry.name, style: TextStyle(fontWeight: FontWeight.w600, color: highlighted ? primary : null)),
                    if (isYou) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                        ),
                        child: Text('You', style: TextStyle(fontSize: 10, color: primary, fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ],
                ),
                if (isYou && entry.count == 0)
                  Text('Not yet entered', style: TextStyle(fontSize: 11, color: AppColors.textSubFor(isDigital)))
                else
                  Text('(${entry.count} ratings)', style: TextStyle(fontSize: 11, color: AppColors.textSubFor(isDigital))),
              ],
            ),
          ),
          if (entry.rating > 0)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.star_rounded, size: 14, color: AppColors.gold),
                const SizedBox(width: 2),
                Text(entry.rating.toStringAsFixed(1), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              ],
            ),
        ],
      ),
    );
  }
}
