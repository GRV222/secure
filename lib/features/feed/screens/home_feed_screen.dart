import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/feed_provider.dart';
import '../../../config/route_names.dart';
import '../../../core/widgets/post_card_widget.dart';
import '../../../core/widgets/shimmer_card.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/providers/theme_provider.dart';
import '../../../core/dummy/dummy_data.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../../features/notifications/providers/notification_provider.dart';
import '../../../features/messages/providers/message_provider.dart';
import '../../../features/stories/widgets/story_bar_widget.dart';
import '../widgets/winners_section.dart';
import '../widgets/comparison_card.dart';
import '../../../models/post_model.dart';
import '../../../models/user_model.dart';
import '../../../services/firestore_service.dart';
import '../../../services/time_algorithm_service.dart';

class HomeFeedScreen extends StatefulWidget {
  const HomeFeedScreen({super.key});

  @override
  State<HomeFeedScreen> createState() => _HomeFeedScreenState();
}

class _HomeFeedScreenState extends State<HomeFeedScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _greetAnim;
  late Animation<double> _greetFade;
  late Animation<Offset> _greetSlide;
  final Set<String> _dismissedCards = {};
  int _comparisonCounter = 0;

  @override
  void initState() {
    super.initState();
    _greetAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _greetFade =
        CurvedAnimation(parent: _greetAnim, curve: Curves.easeOut);
    _greetSlide = Tween<Offset>(
      begin: const Offset(0, -0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _greetAnim, curve: Curves.easeOut));
    _greetAnim.forward();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadFeed());
  }

  @override
  void dispose() {
    _greetAnim.dispose();
    super.dispose();
  }

  List<UserModel> _getProfilesForComparison(List<PostModel> posts) {
    final seen = <String>{};
    final profiles = <UserModel>[];
    for (final post in posts) {
      if (seen.contains(post.uid)) continue;
      seen.add(post.uid);
      profiles.add(UserModel(
        uid: post.uid,
        displayName: post.authorName,
        username: post.authorUsername,
        email: '',
        identityHashtags: post.identityHashtag != null ? [post.identityHashtag!] : const [],
        ratingAvgLifetime: post.ratingAvg,
        createdAt: DateTime.now(),
      ));
      if (profiles.length >= 3) break;
    }
    return profiles.length >= 2 ? profiles : [];
  }

  List<Widget> _buildFeedItems(List<PostModel> posts) {
    final items = <Widget>[];
    for (int i = 0; i < posts.length; i++) {
      items.add(PostCardWidget(post: posts[i]));
      if ((i + 1) % 5 == 0) {
        final compId = 'comp_${i ~/ 5}';
        if (!_dismissedCards.contains(compId)) {
          final card = _buildComparisonCard(posts, i, compId);
          if (card != null) items.add(card);
        }
      }
    }
    return items;
  }

  Widget? _buildComparisonCard(List<PostModel> posts, int afterIndex, String compId) {
    if (_dismissedCards.contains(compId)) return null;
    final myUid = context.read<AuthProvider>().currentUser?.uid ?? '';
    final isPostComp = _comparisonCounter % 2 == 0;
    _comparisonCounter++;

    if (isPostComp && afterIndex >= 1) {
      return ComparisonCard(
        postA: posts[afterIndex - 1],
        postB: posts[afterIndex],
        onChoose: (id) => FirestoreService().saveComparisonChoice(
          chooserUid: myUid, chosenId: id, compId: compId,
        ),
        onDismiss: () => setState(() => _dismissedCards.add(compId)),
      );
    } else {
      final profiles = _getProfilesForComparison(posts);
      if (profiles.length < 2) return null;
      return ComparisonCard(
        profileA: profiles[0],
        profileB: profiles[1],
        onChoose: (id) => FirestoreService().saveComparisonChoice(
          chooserUid: myUid, chosenId: id, compId: compId,
        ),
        onDismiss: () => setState(() => _dismissedCards.add(compId)),
      );
    }
  }

  Future<void> _loadFeed() async {
    try {
      final authProvider = context.read<AuthProvider>();
      final feedProvider = context.read<FeedProvider>();
      final hashtags = authProvider.currentUser?.followedHashtags ?? [];
      await feedProvider.loadFeed(hashtags);
      if (!mounted) return;
      final uid = authProvider.currentUser?.uid;
      if (uid != null) {
        context.read<NotificationProvider>().startListening(uid);
        context.read<MessageProvider>().startListening(uid);
      }
    } catch (e) {
      debugPrint('Feed load error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDigital = context.watch<ThemeProvider>().isDigital;
    final user = context.watch<AuthProvider>().currentUser;

    final identityTags = user?.followedIdentityHashtags.isNotEmpty == true
        ? user!.followedIdentityHashtags
        : DummyData.dummyUser.followedIdentityHashtags;

    final categoryTags = user?.followedCategoryHashtags.isNotEmpty == true
        ? user!.followedCategoryHashtags
        : DummyData.dummyUser.followedCategoryHashtags;

    return Scaffold(
      backgroundColor: AppColors.bg(isDigital),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                'assets/1024.png',
                width: 32,
                height: 32,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'SECURE',
              style: TextStyle(
                fontFamily: 'CormorantGaramond',
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.textFor(isDigital),
                letterSpacing: 3,
              ),
            ),
          ],
        ),
        actions: [
          Consumer<NotificationProvider>(
            builder: (_, np, __) => GestureDetector(
              onTap: () => context.push(RouteNames.notifications),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: _AnimatedBell(count: np.unreadCount),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send_outlined),
            onPressed: () => context.push(RouteNames.dmList),
          ),
        ],
      ),
      body: Consumer<FeedProvider>(
        builder: (context, feed, _) => RefreshIndicator(
          onRefresh: () => feed.refresh(),
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FadeTransition(
                      opacity: _greetFade,
                      child: SlideTransition(
                        position: _greetSlide,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
                          child: RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: 'Namaste, ',
                                  style: TextStyle(
                                    fontFamily: 'CormorantGaramond',
                                    fontSize: 18,
                                    fontWeight: FontWeight.w400,
                                    color: AppColors.textSubFor(isDigital),
                                  ),
                                ),
                                TextSpan(
                                  text: user?.displayName.split(' ').first ??
                                      'Friend',
                                  style: TextStyle(
                                    fontFamily: 'CormorantGaramond',
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color:
                                        AppColors.adaptivePrimary(isDigital),
                                  ),
                                ),
                                const TextSpan(
                                  text: ' 🌸',
                                  style: TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const StoryBarWidget(),
                    const SizedBox(height: AppSizes.sm),
                    const _ThemeToggle(),
                    const SizedBox(height: AppSizes.sm),
                    if (feed.currentTimeSlot != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppSizes.md),
                        child: _TimeSlotBadge(slot: feed.currentTimeSlot!),
                      ),
                    const SizedBox(height: AppSizes.sm),
                    _FieldsRow(
                      identityTags: identityTags,
                      categoryTags: categoryTags,
                    ),
                    const Divider(height: 1),
                    if (feed.winnerPosts.isNotEmpty)
                      WinnersSection(winners: feed.winnerPosts),
                    if (feed.posts.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                        child: Text(
                          'Latest from your fields',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              if (feed.isLoading)
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (_, __) => const ShimmerCard(height: 280),
                    childCount: 3,
                  ),
                )
              else if (feed.posts.isEmpty)
                const SliverFillRemaining(
                  child: Center(
                      child: Text('No posts yet. Be the first to share!')),
                )
              else
                Builder(
                  builder: (context) {
                    final items = _buildFeedItems(feed.posts);
                    return SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (_, i) => items[i],
                        childCount: items.length,
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.adaptivePrimary(isDigital),
        onPressed: () => context.push(RouteNames.createPost),
        child: const Icon(Icons.add, color: AppColors.white),
      ),
    );
  }
}

class _AnimatedBell extends StatefulWidget {
  final int count;
  const _AnimatedBell({required this.count});

  @override
  State<_AnimatedBell> createState() => _AnimatedBellState();
}

class _AnimatedBellState extends State<_AnimatedBell>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _ring;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _ring = TweenSequence([
      TweenSequenceItem(
          tween: Tween<double>(begin: 0, end: 0.15), weight: 20),
      TweenSequenceItem(
          tween: Tween<double>(begin: 0.15, end: -0.12), weight: 20),
      TweenSequenceItem(
          tween: Tween<double>(begin: -0.12, end: 0.08), weight: 20),
      TweenSequenceItem(
          tween: Tween<double>(begin: 0.08, end: -0.05), weight: 20),
      TweenSequenceItem(
          tween: Tween<double>(begin: -0.05, end: 0), weight: 20),
    ]).animate(_ctrl);

    if (widget.count > 0) {
      Future.delayed(const Duration(seconds: 2), _startRinging);
    }
  }

  void _startRinging() {
    if (!mounted) return;
    _ctrl.forward(from: 0);
    Future.delayed(const Duration(seconds: 5), _startRinging);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDigital = context.watch<ThemeProvider>().isDigital;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        AnimatedBuilder(
          animation: _ring,
          builder: (context, child) => Transform.rotate(
            angle: _ring.value,
            alignment: Alignment.topCenter,
            child: child,
          ),
          child: Icon(
            widget.count > 0
                ? Icons.notifications_rounded
                : Icons.notifications_outlined,
            color: AppColors.adaptivePrimary(isDigital),
            size: 24,
          ),
        ),
        if (widget.count > 0)
          Positioned(
            top: -4,
            right: -6,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
              constraints:
                  const BoxConstraints(minWidth: 16, minHeight: 16),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white, width: 1.5),
              ),
              child: Text(
                widget.count > 99 ? '99+' : '${widget.count}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}

class _ThemeToggle extends StatelessWidget {
  const _ThemeToggle();

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        final isDigital = themeProvider.isDigital;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(50),
            color: isDigital
                ? const Color(0xFF2E2426)
                : const Color(0xFFEDE0D0),
            boxShadow: isDigital
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.30),
                      blurRadius: 6,
                      offset: const Offset(2, 2),
                    ),
                    BoxShadow(
                      color: const Color(0xFF4A3A3A).withValues(alpha: 0.10),
                      blurRadius: 4,
                      offset: const Offset(-1, -1),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: const Color(0xFFA06040).withValues(alpha: 0.12),
                      blurRadius: 6,
                      offset: const Offset(2, 2),
                    ),
                    BoxShadow(
                      color: Colors.white.withValues(alpha: 0.80),
                      blurRadius: 4,
                      offset: const Offset(-1, -1),
                    ),
                  ],
          ),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    context.read<ThemeProvider>().setTraditional();
                    context.read<FeedProvider>().setMode(FeedMode.traditional);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(46),
                      gradient: !isDigital
                          ? const LinearGradient(
                              colors: [Color(0xFFC9956C), Color(0xFFA87048)],
                            )
                          : null,
                      boxShadow: !isDigital
                          ? [
                              BoxShadow(
                                color: const Color(0xFFC9956C).withValues(alpha: 0.30),
                                blurRadius: 6,
                              ),
                            ]
                          : null,
                    ),
                    child: Text(
                      '🎨 Traditional',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: !isDigital
                            ? const Color(0xFFFFF5EE)
                            : const Color(0xFFB8967A),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    context.read<ThemeProvider>().setDigital();
                    context.read<FeedProvider>().setMode(FeedMode.digital);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(46),
                      gradient: isDigital
                          ? const LinearGradient(
                              colors: [Color(0xFF8C7A7B), Color(0xFF705B59)],
                            )
                          : null,
                      boxShadow: isDigital
                          ? [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.30),
                                blurRadius: 6,
                              ),
                            ]
                          : null,
                    ),
                    child: Text(
                      '💻 Digital',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: isDigital
                            ? const Color(0xFFCFC3C3)
                            : const Color(0xFF8C7A7B),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _FieldsRow extends StatelessWidget {
  final List<String> identityTags;
  final List<String> categoryTags;
  const _FieldsRow({required this.identityTags, required this.categoryTags});

  @override
  Widget build(BuildContext context) {
    final isDigital = context.watch<ThemeProvider>().isDigital;
    if (identityTags.isEmpty && categoryTags.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: AppSizes.md, bottom: 6),
          child: Text(
            'Your Fields',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
              letterSpacing: 0.4,
            ),
          ),
        ),
        SizedBox(
          height: 36,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
            children: [
              ...identityTags.map((tag) => _FieldChip(
                    label: '#$tag',
                    color: AppColors.adaptivePrimary(isDigital),
                    iconData: Icons.person_outline,
                    onTap: () => context.push('/hashtag/$tag'),
                  )),
              ...categoryTags.map((tag) => _FieldChip(
                    label: '#$tag',
                    color: AppColors.adaptivePrimary(isDigital),
                    iconData: Icons.tag,
                    onTap: () => context.push('/hashtag/$tag'),
                  )),
              _FieldChip(
                label: '🔍 Explore Worlds',
                color: AppColors.adaptivePrimary(isDigital),
                isExplore: true,
                onTap: () => context.go(RouteNames.explore),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSizes.sm),
      ],
    );
  }
}

class _FieldChip extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;
  final IconData? iconData;
  final bool isExplore;
  const _FieldChip({required this.label, required this.color, required this.onTap, this.iconData, this.isExplore = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: color.withValues(alpha: isExplore ? 0.1 : 0.09),
          borderRadius: BorderRadius.circular(AppSizes.radiusFull),
          border: Border.all(color: color.withValues(alpha: isExplore ? 0.45 : 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (iconData != null) ...[
              Icon(iconData, size: 11, color: color),
              const SizedBox(width: 4),
            ],
            Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color)),
          ],
        ),
      ),
    );
  }
}

class _TimeSlotBadge extends StatelessWidget {
  final TimeSlotInfo slot;
  const _TimeSlotBadge({required this.slot});

  @override
  Widget build(BuildContext context) {
    final isDigital = context.watch<ThemeProvider>().isDigital;
    final primary = AppColors.adaptivePrimary(isDigital);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: primary.withValues(alpha: 0.15)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(slot.emoji, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 6),
          Text(
            slot.name,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: primary),
          ),
          const SizedBox(width: 4),
          Text(
            '· ${slot.description}',
            style: TextStyle(fontSize: 11, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }
}

