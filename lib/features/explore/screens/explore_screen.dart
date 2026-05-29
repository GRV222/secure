import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../config/route_names.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/dummy/dummy_data.dart';
import '../../../core/providers/theme_provider.dart';
import '../../../models/user_model.dart';
import '../../../services/firestore_service.dart';

// ── Data types ─────────────────────────────────────────────────────────────────

class _Category {
  final String id;
  final String name;
  final List<String> hashtags;
  const _Category(this.id, this.name, this.hashtags);
}

class _EventData {
  final String title;
  final String city;
  final bool isLive;
  final int liveCount;
  const _EventData(this.title, this.city,
      {required this.isLive, required this.liveCount});
}

// ── Category data ──────────────────────────────────────────────────────────────
// [worldTab: 0=Traditional, 1=Digital][mediaTab: 0=Photos, 1=Audio, 2=Text, 3=Video]

final _catData = <List<List<_Category>>>[
  // Traditional
  [
    // Photos
    [
      _Category('canvas', 'Canvas & Sketches',
          ['canvapainting', 'skatchart', 'watercolor', 'pencilart']),
      _Category('folk', 'Folk & Miniature',
          ['miniature', 'madhubani', 'warli', 'mughal']),
      _Category('sculpture', 'Sculpture & Craft',
          ['sculpture', 'craft', 'pottery', 'handmade']),
      _Category('heritage', 'Heritage Photography',
          ['heritage', 'vintage', 'traditional', 'culture']),
    ],
    // Audio
    [
      _Category('classical', 'Classical Music',
          ['tabla', 'sitar', 'veena', 'bansuri']),
      _Category('vocal', 'Vocal & Folk',
          ['classicalvocal', 'folksong', 'bhajan', 'ghazal']),
      _Category('percussion', 'Percussion & Rhythm',
          ['mridangam', 'dhol', 'kanjira', 'rhythm']),
    ],
    // Text
    [
      _Category('poetry', 'Poetry & Shayari',
          ['poetry', 'shayari', 'kavita', 'haiku']),
      _Category('story', 'Story & Prose',
          ['shortstory', 'prose', 'fiction', 'narrative']),
      _Category('philosophy', 'Philosophy & Thought',
          ['philosophy', 'thought', 'wisdom', 'reflection']),
    ],
    // Video
    [
      _Category('dance', 'Classical Dance',
          ['bharatanatyam', 'kathak', 'odissi', 'kuchipudi']),
      _Category('films', 'Short Films',
          ['shortfilm', 'cinema', 'storytelling', 'drama']),
      _Category('tutorials', 'Tutorials & Teaching',
          ['tutorial', 'teaching', 'learning', 'guru']),
    ],
  ],
  // Digital
  [
    // Photos
    [
      _Category('digitalart', 'Digital Art',
          ['digitalart', 'digitalillustration', 'characterdesign', 'conceptart']),
      _Category('3d', '3D & Motion',
          ['3dart', '3drender', 'motiondesign', 'blender']),
      _Category('modernphoto', 'Modern Photography',
          ['modernphoto', 'streetphoto', 'portrait', 'aesthetic']),
    ],
    // Audio
    [
      _Category('electronic', 'Electronic & Produced',
          ['electronicmusic', 'lofi', 'synthwave', 'hiphop']),
      _Category('fusion', 'Fusion',
          ['indiemusic', 'fusion', 'ambient', 'digitalmusic']),
      _Category('podcast', 'Podcasts & Voice',
          ['podcast', 'voiceover', 'audiobook', 'interview']),
    ],
    // Text
    [
      _Category('codepoetry', 'Code Poetry',
          ['codepoetry', 'techwriting', 'developer', 'openSource']),
      _Category('creative', 'Creative Writing',
          ['creativewriting', 'fiction', 'worldbuilding', 'scifi']),
      _Category('ideas', 'Ideas & Innovation',
          ['innovation', 'startup', 'ideas', 'futurism']),
    ],
    // Video
    [
      _Category('animation', 'Animation & VFX',
          ['animation', '2danimation', 'vfx', 'motiongraphics']),
      _Category('performance', 'Digital Performance',
          ['digitalperformance', 'livestream', 'interactive', 'digital']),
      _Category('gaming', 'Gaming & Streaming',
          ['gaming', 'esports', 'streaming', 'gamedev']),
    ],
  ],
];

const _events = [
  _EventData('Sangeet Mahotsav 2026', 'Delhi', isLive: true, liveCount: 23),
  _EventData('Digital Art Summit', 'Mumbai', isLive: false, liveCount: 0),
  _EventData('Kathak Festival', 'Jaipur', isLive: true, liveCount: 8),
];

const _tabLabels = ['Photos', 'Audio', 'Text', 'Video'];
const _tabEmojis = ['📸', '🎵', '✍️', '🎬'];
const _mediaEmojis = ['🎨', '🎵', '✍️', '🎬'];

// Flat hashtag list derived from _catData for search
final _searchHashtags = _catData
    .expand((w) => w)
    .expand((m) => m)
    .expand((cat) => cat.hashtags)
    .toSet()
    .map((h) {
      final count = (h.length * 137 + (h.isEmpty ? 0 : h.codeUnitAt(0))) % 900 + 100;
      return (name: h, postCount: count);
    })
    .toList()
  ..sort((a, b) => a.name.compareTo(b.name));

// ── Main screen ────────────────────────────────────────────────────────────────

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen>
    with TickerProviderStateMixin {
  final _searchCtrl = TextEditingController();
  String _query = '';
  int _worldTab = 0;
  late TabController _mediaTabCtrl;
  late AnimationController _waveCtrl;

  @override
  void initState() {
    super.initState();
    _mediaTabCtrl = TabController(length: 4, vsync: this);
    _waveCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _mediaTabCtrl.addListener(() {
      if (!_mediaTabCtrl.indexIsChanging) setState(() {});
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _mediaTabCtrl.dispose();
    _waveCtrl.dispose();
    super.dispose();
  }

  void _onSearch(String v) => setState(() => _query = v.trim());

  @override
  Widget build(BuildContext context) {
    final isDigital = context.watch<ThemeProvider>().isDigital;
    final primary = AppColors.adaptivePrimary(isDigital);

    return Scaffold(
      backgroundColor: AppColors.bg(isDigital),
      body: SafeArea(
        child: Column(
          children: [
            _buildSearchBar(isDigital, primary),
            if (_query.length >= 2)
              Expanded(
                child: _SearchOverlay(query: _query, isDigital: isDigital),
              )
            else ...[
              _buildWorldTabs(isDigital, primary),
              const SizedBox(height: 4),
              _buildMediaTabBar(isDigital, primary),
              Expanded(
                child: TabBarView(
                  controller: _mediaTabCtrl,
                  children: List.generate(
                    4,
                    (i) => _TabContent(
                      mediaIdx: i,
                      worldTab: _worldTab,
                      isDigital: isDigital,
                      waveCtrl: _waveCtrl,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(bool isDigital, Color primary) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: TextField(
        controller: _searchCtrl,
        onChanged: _onSearch,
        decoration: InputDecoration(
          hintText: 'Search hashtags & people...',
          prefixIcon:
              Icon(Icons.search, size: 20, color: primary.withValues(alpha: 0.6)),
          suffixIcon: _query.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 18),
                  onPressed: () {
                    _searchCtrl.clear();
                    _onSearch('');
                  },
                )
              : null,
          filled: true,
          fillColor: AppColors.surfaceColor(isDigital),
          contentPadding: const EdgeInsets.symmetric(vertical: 10),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          hintStyle:
              TextStyle(color: AppColors.textSubFor(isDigital), fontSize: 14),
        ),
      ),
    );
  }

  Widget _buildWorldTabs(bool isDigital, Color primary) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      child: Container(
        height: 40,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: AppColors.surfaceColor(isDigital),
          borderRadius: BorderRadius.circular(22),
        ),
        child: Row(
          children: [
            _WorldTabPill(
              label: '🎨 Traditional',
              selected: _worldTab == 0,
              isDigital: isDigital,
              primary: primary,
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() => _worldTab = 0);
              },
            ),
            _WorldTabPill(
              label: '💻 Digital',
              selected: _worldTab == 1,
              isDigital: isDigital,
              primary: primary,
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() => _worldTab = 1);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMediaTabBar(bool isDigital, Color primary) {
    return TabBar(
      controller: _mediaTabCtrl,
      isScrollable: true,
      tabAlignment: TabAlignment.start,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      labelPadding: const EdgeInsets.symmetric(horizontal: 10),
      indicator: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [primary, primary.withValues(alpha: 0.7)],
        ),
      ),
      indicatorSize: TabBarIndicatorSize.tab,
      labelColor: Colors.white,
      unselectedLabelColor: AppColors.textSubFor(isDigital),
      labelStyle:
          const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
      dividerHeight: 0,
      tabs: List.generate(
        4,
        (i) => Tab(text: '${_tabEmojis[i]} ${_tabLabels[i]}'),
      ),
    );
  }
}

// ── World tab pill ─────────────────────────────────────────────────────────────

class _WorldTabPill extends StatelessWidget {
  final String label;
  final bool selected;
  final bool isDigital;
  final Color primary;
  final VoidCallback onTap;

  const _WorldTabPill({
    required this.label,
    required this.selected,
    required this.isDigital,
    required this.primary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: selected
                ? LinearGradient(
                    colors: [primary, primary.withValues(alpha: 0.75)],
                  )
                : null,
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: selected ? Colors.white : AppColors.textSubFor(isDigital),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Tab content (per media tab) ────────────────────────────────────────────────

class _TabContent extends StatelessWidget {
  final int mediaIdx;
  final int worldTab;
  final bool isDigital;
  final AnimationController waveCtrl;

  const _TabContent({
    required this.mediaIdx,
    required this.worldTab,
    required this.isDigital,
    required this.waveCtrl,
  });

  @override
  Widget build(BuildContext context) {
    final cats = _catData[worldTab][mediaIdx];
    final pools =
        DummyData.dummyPools.where((p) => p.isActive).take(3).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      children: [
        ...cats.map(
          (cat) => _CategorySection(
            category: cat,
            mediaIdx: mediaIdx,
            isDigital: isDigital,
            waveCtrl: waveCtrl,
          ),
        ),
        const SizedBox(height: 8),
        _SectionHeader(title: '📅 Events', isDigital: isDigital),
        const SizedBox(height: 10),
        SizedBox(
          height: 110,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _events.length,
            itemBuilder: (_, i) =>
                _EventCard(event: _events[i], isDigital: isDigital),
          ),
        ),
        const SizedBox(height: 20),
        _SectionHeader(title: '🫶 Charity Campaigns', isDigital: isDigital),
        const SizedBox(height: 10),
        SizedBox(
          height: 110,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: pools.length,
            itemBuilder: (_, i) =>
                _PoolCard(pool: pools[i], isDigital: isDigital),
          ),
        ),
      ],
    );
  }
}

// ── Section header ─────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  final bool isDigital;
  const _SectionHeader({required this.title, required this.isDigital});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontFamily: 'CormorantGaramond',
        fontWeight: FontWeight.w700,
        fontSize: 18,
        color: AppColors.textFor(isDigital),
      ),
    );
  }
}

// ── Category section ───────────────────────────────────────────────────────────

class _CategorySection extends StatelessWidget {
  final _Category category;
  final int mediaIdx;
  final bool isDigital;
  final AnimationController waveCtrl;

  const _CategorySection({
    required this.category,
    required this.mediaIdx,
    required this.isDigital,
    required this.waveCtrl,
  });

  @override
  Widget build(BuildContext context) {
    final primary = AppColors.adaptivePrimary(isDigital);

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            category.name,
            style: TextStyle(
              fontFamily: 'CormorantGaramond',
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.textFor(isDigital),
            ),
          ),
          const SizedBox(height: 8),
          // Audio uses animated waveform; others use magazine grid
          mediaIdx == 1
              ? _WaveformCard(
                  category: category,
                  isDigital: isDigital,
                  waveCtrl: waveCtrl,
                )
              : _MagazineGrid(
                  hashtags: category.hashtags,
                  mediaEmoji: _mediaEmojis[mediaIdx],
                  isDigital: isDigital,
                ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: category.hashtags
                .map((tag) => _HashtagChip(
                      tag: tag,
                      isDigital: isDigital,
                      primary: primary,
                    ))
                .toList(),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                context.push(RouteNames.createPost);
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 7),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [primary, primary.withValues(alpha: 0.7)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'JOIN',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Divider(
            color: AppColors.textSubFor(isDigital).withValues(alpha: 0.15),
          ),
        ],
      ),
    );
  }
}

class _HashtagChip extends StatelessWidget {
  final String tag;
  final bool isDigital;
  final Color primary;
  const _HashtagChip(
      {required this.tag, required this.isDigital, required this.primary});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/hashtag/$tag'),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: primary.withValues(alpha: 0.2)),
        ),
        child: Text(
          '#$tag',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: primary,
          ),
        ),
      ),
    );
  }
}

// ── Magazine grid ──────────────────────────────────────────────────────────────

class _MagazineGrid extends StatelessWidget {
  final List<String> hashtags;
  final String mediaEmoji;
  final bool isDigital;

  const _MagazineGrid({
    required this.hashtags,
    required this.mediaEmoji,
    required this.isDigital,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 160,
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: _PostTile(
              hashtag: hashtags.isNotEmpty ? hashtags[0] : '',
              emoji: mediaEmoji,
              isDigital: isDigital,
              isLarge: true,
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            flex: 2,
            child: Column(
              children: [
                Expanded(
                  child: _PostTile(
                    hashtag: hashtags.length > 1 ? hashtags[1] : '',
                    emoji: mediaEmoji,
                    isDigital: isDigital,
                    isLarge: false,
                  ),
                ),
                const SizedBox(height: 4),
                Expanded(
                  child: _PostTile(
                    hashtag: hashtags.length > 2 ? hashtags[2] : '',
                    emoji: mediaEmoji,
                    isDigital: isDigital,
                    isLarge: false,
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

class _PostTile extends StatelessWidget {
  final String hashtag;
  final String emoji;
  final bool isDigital;
  final bool isLarge;

  const _PostTile({
    required this.hashtag,
    required this.emoji,
    required this.isDigital,
    required this.isLarge,
  });

  @override
  Widget build(BuildContext context) {
    final primary = AppColors.adaptivePrimary(isDigital);
    return GestureDetector(
      onTap: hashtag.isNotEmpty ? () => context.push('/hashtag/$hashtag') : null,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    primary.withValues(alpha: 0.28),
                    primary.withValues(alpha: 0.10),
                  ],
                ),
              ),
            ),
            Center(
              child: Text(
                emoji,
                style: TextStyle(fontSize: isLarge ? 38 : 24),
              ),
            ),
            if (hashtag.isNotEmpty)
              Positioned(
                left: 6,
                right: 6,
                bottom: 6,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.45),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '#$hashtag',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ── Audio waveform card ────────────────────────────────────────────────────────

class _WaveformCard extends StatelessWidget {
  final _Category category;
  final bool isDigital;
  final AnimationController waveCtrl;

  const _WaveformCard({
    required this.category,
    required this.isDigital,
    required this.waveCtrl,
  });

  @override
  Widget build(BuildContext context) {
    final primary = AppColors.adaptivePrimary(isDigital);
    return Container(
      height: 100,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor(isDigital),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: primary.withValues(alpha: 0.18)),
      ),
      child: Row(
        children: [
          Expanded(
            child: AnimatedBuilder(
              animation: waveCtrl,
              builder: (_, __) => CustomPaint(
                painter: _WaveformPainter(
                  animValue: waveCtrl.value,
                  color: primary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          CircleAvatar(
            radius: 22,
            backgroundColor: primary.withValues(alpha: 0.15),
            child: const Text('🎵', style: TextStyle(fontSize: 20)),
          ),
        ],
      ),
    );
  }
}

class _WaveformPainter extends CustomPainter {
  final double animValue;
  final Color color;
  static const int _barCount = 28;

  const _WaveformPainter({required this.animValue, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final barWidth = size.width / (_barCount * 1.7);
    final step = size.width / _barCount;

    for (int i = 0; i < _barCount; i++) {
      final x = i * step;
      final phase =
          (i / _barCount) * 2 * math.pi + animValue * 2 * math.pi;
      final heightFactor =
          (math.sin(phase) + 1) / 2 * 0.75 + 0.1;
      final barHeight = size.height * heightFactor;
      final y = (size.height - barHeight) / 2;

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, y, barWidth, barHeight),
          const Radius.circular(3),
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_WaveformPainter old) => old.animValue != animValue;
}

// ── Event card ─────────────────────────────────────────────────────────────────

class _EventCard extends StatelessWidget {
  final _EventData event;
  final bool isDigital;

  const _EventCard({required this.event, required this.isDigital});

  @override
  Widget build(BuildContext context) {
    final primary = AppColors.adaptivePrimary(isDigital);
    return GestureDetector(
      onTap: () => context.push(RouteNames.live),
      child: Container(
        width: 200,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surfaceColor(isDigital),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: event.isLive
                ? Colors.red.withValues(alpha: 0.4)
                : primary.withValues(alpha: 0.2),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: event.isLive
                        ? Colors.red.withValues(alpha: 0.15)
                        : primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    event.isLive ? '● LIVE' : 'UPCOMING',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      color: event.isLive ? Colors.red : primary,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                if (event.isLive && event.liveCount > 0) ...[
                  const SizedBox(width: 6),
                  Text(
                    '${event.liveCount} watching',
                    style: TextStyle(
                      fontSize: 9,
                      color: AppColors.textSubFor(isDigital),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Text(
                event.title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textFor(isDigital),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.location_on_outlined,
                    size: 11, color: AppColors.textSubFor(isDigital)),
                const SizedBox(width: 3),
                Text(
                  event.city,
                  style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textSubFor(isDigital)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Charity pool card ──────────────────────────────────────────────────────────

class _PoolCard extends StatelessWidget {
  final CharityPoolModel pool;
  final bool isDigital;

  const _PoolCard({required this.pool, required this.isDigital});

  @override
  Widget build(BuildContext context) {
    final pct = pool.targetDA > 0
        ? (pool.raisedDA / pool.targetDA).clamp(0.0, 1.0)
        : 0.0;

    return GestureDetector(
      onTap: () => context.push('/groups/pool/${pool.id}'),
      child: Container(
        width: 220,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surfaceColor(isDigital),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: AppColors.success.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              pool.title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.textFor(isDigital),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: LinearProgressIndicator(
                value: pct,
                backgroundColor:
                    AppColors.success.withValues(alpha: 0.15),
                valueColor: const AlwaysStoppedAnimation<Color>(
                    AppColors.success),
                minHeight: 4,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${pool.raisedDA.toStringAsFixed(0)} / ${pool.targetDA.toStringAsFixed(0)} DA',
              style: TextStyle(
                  fontSize: 10,
                  color: AppColors.textSubFor(isDigital)),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 26,
              child: FilledButton(
                onPressed: () => context.push('/groups/pool/${pool.id}'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.success,
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text(
                  'Donate',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Search overlay ─────────────────────────────────────────────────────────────

class _SearchOverlay extends StatefulWidget {
  final String query;
  final bool isDigital;

  const _SearchOverlay({required this.query, required this.isDigital});

  @override
  State<_SearchOverlay> createState() => _SearchOverlayState();
}

class _SearchOverlayState extends State<_SearchOverlay> {
  List<UserModel> _users = [];
  bool _loadingUsers = true;
  String? _lastQuery;

  @override
  void initState() {
    super.initState();
    _fetchUsers(widget.query);
  }

  @override
  void didUpdateWidget(_SearchOverlay old) {
    super.didUpdateWidget(old);
    if (widget.query != old.query) _fetchUsers(widget.query);
  }

  void _fetchUsers(String q) {
    setState(() => _loadingUsers = true);
    _lastQuery = q;
    FirestoreService().searchUsers(q).then((users) {
      if (mounted && q == _lastQuery) {
        setState(() {
          _users = users;
          _loadingUsers = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final primary = AppColors.adaptivePrimary(widget.isDigital);
    final q = widget.query.toLowerCase();
    final matchingTags = _searchHashtags
        .where((h) => h.name.toLowerCase().contains(q))
        .take(8)
        .toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
      children: [
        if (matchingTags.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 6),
            child: Text(
              'Hashtags',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.textSubFor(widget.isDigital),
                letterSpacing: 0.5,
              ),
            ),
          ),
          ...matchingTags.map(
            (h) => ListTile(
              onTap: () => context.push('/hashtag/${h.name}'),
              contentPadding: const EdgeInsets.symmetric(horizontal: 4),
              leading: CircleAvatar(
                radius: 18,
                backgroundColor: primary.withValues(alpha: 0.12),
                child: Text(
                  '#',
                  style: TextStyle(
                      color: primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 16),
                ),
              ),
              title: Text(
                '#${h.name}',
                style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: primary,
                    fontSize: 14),
              ),
              subtitle: Text(
                '${h.postCount} posts',
                style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textSubFor(widget.isDigital)),
              ),
            ),
          ),
        ],
        Padding(
          padding: const EdgeInsets.only(top: 16, bottom: 6),
          child: Text(
            'People',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.textSubFor(widget.isDigital),
              letterSpacing: 0.5,
            ),
          ),
        ),
        if (_loadingUsers)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          )
        else if (_users.isEmpty)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'No people found',
              style: TextStyle(
                  color: AppColors.textSubFor(widget.isDigital),
                  fontSize: 14),
            ),
          )
        else
          ..._users.map(
            (u) => ListTile(
              onTap: () => context.push('/profile/${u.uid}'),
              contentPadding: const EdgeInsets.symmetric(horizontal: 4),
              leading: CircleAvatar(
                radius: 20,
                backgroundColor: primary.withValues(alpha: 0.12),
                backgroundImage: (u.photoURL != null && u.photoURL!.isNotEmpty)
                    ? NetworkImage(u.photoURL!)
                    : null,
                child: (u.photoURL == null || u.photoURL!.isEmpty)
                    ? Text(
                        u.displayName.isNotEmpty
                            ? u.displayName[0].toUpperCase()
                            : '?',
                        style: TextStyle(
                            color: primary, fontWeight: FontWeight.bold),
                      )
                    : null,
              ),
              title: Text(
                u.displayName,
                style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textFor(widget.isDigital),
                    fontSize: 14),
              ),
              subtitle: Row(
                children: [
                  Text(
                    '@${u.username}',
                    style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textSubFor(widget.isDigital)),
                  ),
                  if (u.ratingAvgLifetime > 0) ...[
                    const SizedBox(width: 8),
                    Icon(Icons.star_rounded,
                        size: 11, color: AppColors.gold),
                    Text(
                      u.ratingAvgLifetime.toStringAsFixed(1),
                      style: TextStyle(
                          fontSize: 11,
                          color: AppColors.textSubFor(widget.isDigital)),
                    ),
                  ],
                ],
              ),
            ),
          ),
      ],
    );
  }
}
