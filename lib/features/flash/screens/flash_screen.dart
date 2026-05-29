import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/providers/theme_provider.dart';
import '../../../core/dummy/dummy_data.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../../models/post_model.dart';
import '../../../services/firestore_service.dart';
import '../../../services/time_algorithm_service.dart';
import '../widgets/flash_post_card.dart';

class FlashScreen extends StatefulWidget {
  const FlashScreen({super.key});

  @override
  State<FlashScreen> createState() => _FlashScreenState();
}

class _FlashScreenState extends State<FlashScreen>
    with TickerProviderStateMixin {
  final List<String> _viewedPostIds = [];
  late PageController _pageController;
  int _currentIndex = 0;
  List<PostModel> _flashPosts = [];
  bool _isLoading = true;

  // ── Animations ──
  late AnimationController _headerAnim;
  late AnimationController _pulseAnim;
  late Animation<double> _headerFade;
  late Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    _headerAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _pulseAnim = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _headerFade = CurvedAnimation(
        parent: _headerAnim, curve: Curves.easeOut);
    _pulse = Tween<double>(begin: 0.7, end: 1.0)
        .animate(CurvedAnimation(parent: _pulseAnim, curve: Curves.easeInOut));

    _headerAnim.forward();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadFlashPosts();
      _checkFirstTime();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _headerAnim.dispose();
    _pulseAnim.dispose();
    super.dispose();
  }

  Future<void> _loadFlashPosts() async {
    try {
      final uid = context.read<AuthProvider>().currentUser?.uid ?? '';
      final hashtags =
          context.read<AuthProvider>().currentUser?.followedHashtags ?? [];
      final posts = await FirestoreService()
          .getFlashPosts(uid: uid, followedHashtags: hashtags);
      if (mounted) {
        setState(() { _flashPosts = posts; _isLoading = false; });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _flashPosts = DummyData.dummyFlashPosts;
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _checkFirstTime() async {
    final prefs = await SharedPreferences.getInstance();
    final seen = prefs.getBool('flash_seen') ?? false;
    if (!seen && mounted) {
      Future.delayed(const Duration(milliseconds: 600), _showFlashWarning);
    }
  }

  Future<void> _showFlashWarning() async {
    final isDigital = context.read<ThemeProvider>().isDigital;
    final primary = AppColors.adaptivePrimary(isDigital);
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1A0E00),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: primary.withValues(alpha: 0.3)),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('⚡', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 16),
            Text(
              'Flash Feed',
              style: TextStyle(
                fontFamily: 'CormorantGaramond',
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: primary,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Posts disappear once you scroll past.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white70,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'No replays. No saves.\nReact before you scroll away.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white38,
                fontSize: 13,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  Navigator.pop(context);
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setBool('flash_seen', true);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  "I understand — Let's go ⚡",
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<PostModel> get _unviewedPosts =>
      _flashPosts.where((p) => !_viewedPostIds.contains(p.postId)).toList();

  void _markAsViewed(String postId) {
    if (!_viewedPostIds.contains(postId)) {
      setState(() => _viewedPostIds.add(postId));
      HapticFeedback.lightImpact();
    }
  }

  void _goBack() {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else {
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDigital = context.watch<ThemeProvider>().isDigital;
    final posts = _unviewedPosts;
    final timeInfo = TimeAlgorithmService().getTimeSlotInfo();

    final bgColor = isDigital
        ? AppColors.digBg
        : const Color(0xFF2A1A0E);

    final accentColor = isDigital
        ? AppColors.digAccent
        : AppColors.tradPrimary;

    final flashColor = isDigital
        ? const Color(0xFFC9A227)
        : const Color(0xFFC9956C);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _goBack();
      },
      child: Scaffold(
        backgroundColor: bgColor,
        body: _isLoading
            ? _buildLoader(isDigital, flashColor)
            : SafeArea(
                child: Column(
                  children: [
                    FadeTransition(
                      opacity: _headerFade,
                      child: _buildHeader(
                          context, isDigital, posts, flashColor,
                          accentColor, timeInfo),
                    ),
                    if (posts.isNotEmpty)
                      _buildProgressDots(posts, isDigital, flashColor),
                    Expanded(
                      child: posts.isEmpty
                          ? _buildEmptyState(isDigital, flashColor)
                          : PageView.builder(
                              controller: _pageController,
                              scrollDirection: Axis.vertical,
                              onPageChanged: (index) {
                                setState(() => _currentIndex = index);
                                if (index > 0) {
                                  _markAsViewed(posts[index - 1].postId);
                                }
                              },
                              itemCount: posts.length,
                              itemBuilder: (context, index) {
                                return FlashPostCard(
                                  post: posts[index],
                                  isDigital: isDigital,
                                  onViewed: () =>
                                      _markAsViewed(posts[index].postId),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildLoader(bool isDigital, Color flashColor) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              AnimatedBuilder(
                animation: _pulseAnim,
                builder: (context, child) => Transform.scale(
                  scale: _pulse.value,
                  child: Container(
                    width: 80, height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: flashColor.withValues(alpha: 0.2),
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
              ),
              AnimatedBuilder(
                animation: _pulseAnim,
                builder: (context, child) => Transform.scale(
                  scale: 1.3 - (_pulse.value * 0.3),
                  child: Container(
                    width: 56, height: 56,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: flashColor.withValues(alpha: 0.15),
                        width: 1,
                      ),
                    ),
                  ),
                ),
              ),
              Text(
                '⚡',
                style: TextStyle(
                  fontSize: 32,
                  shadows: [
                    Shadow(
                      color: flashColor.withValues(alpha: 0.6),
                      blurRadius: 20,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            'Loading Flash...',
            style: TextStyle(
              fontFamily: 'CormorantGaramond',
              fontSize: 16,
              color: flashColor.withValues(alpha: 0.6),
              letterSpacing: 2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    bool isDigital,
    List<PostModel> posts,
    Color flashColor,
    Color accentColor,
    dynamic timeInfo,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: _goBack,
            child: Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: isDigital
                    ? Colors.white.withValues(alpha: 0.06)
                    : Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDigital
                      ? Colors.white.withValues(alpha: 0.08)
                      : Colors.white.withValues(alpha: 0.2),
                ),
              ),
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 16,
                color: Colors.white.withValues(alpha: 0.7),
              ),
            ),
          ),
          const SizedBox(width: 12),
          AnimatedBuilder(
            animation: _pulseAnim,
            builder: (context, child) => Text(
              '⚡',
              style: TextStyle(
                fontSize: 22,
                shadows: [
                  Shadow(
                    color: flashColor.withValues(alpha: _pulse.value),
                    blurRadius: 12,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'FLASH',
            style: TextStyle(
              fontFamily:
                  isDigital ? 'PlusJakartaSans' : 'CormorantGaramond',
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 20,
              letterSpacing: isDigital ? 4 : 3,
            ),
          ),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${timeInfo.emoji} ${timeInfo.name}',
                style: TextStyle(
                  fontSize: 10,
                  color: flashColor.withValues(alpha: 0.7),
                  fontFamily: 'CormorantGaramond',
                ),
              ),
              if (posts.isNotEmpty)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: flashColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: flashColor.withValues(alpha: 0.2)),
                  ),
                  child: Text(
                    '${posts.length} new',
                    style: TextStyle(
                      color: flashColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressDots(
      List<PostModel> posts, bool isDigital, Color flashColor) {
    final count = posts.length > 10 ? 10 : posts.length;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: Row(
        children: List.generate(count, (i) {
          final active = i <= _currentIndex;
          return Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: 2,
              margin: const EdgeInsets.symmetric(horizontal: 1.5),
              decoration: BoxDecoration(
                color: active
                    ? flashColor
                    : Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(1),
                boxShadow: active
                    ? [
                        BoxShadow(
                          color: flashColor.withValues(alpha: 0.4),
                          blurRadius: 4,
                        ),
                      ]
                    : null,
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildEmptyState(bool isDigital, Color flashColor) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              AnimatedBuilder(
                animation: _pulseAnim,
                builder: (context, _) => Container(
                  width: 100, height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: flashColor.withValues(
                          alpha: _pulse.value * 0.2),
                      width: 1,
                    ),
                  ),
                ),
              ),
              Text(
                '⚡',
                style: TextStyle(
                  fontSize: 48,
                  shadows: [
                    Shadow(
                      color: flashColor.withValues(alpha: 0.4),
                      blurRadius: 20,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          Text(
            'All caught up!',
            style: TextStyle(
              fontFamily: 'CormorantGaramond',
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w600,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'No new flash posts right now.\nCheck back soon.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.4),
              fontSize: 14,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 8),
          if (_viewedPostIds.isNotEmpty)
            Text(
              '${_viewedPostIds.length} posts viewed today ✓',
              style: TextStyle(
                color: flashColor.withValues(alpha: 0.5),
                fontSize: 12,
                fontFamily: 'CormorantGaramond',
              ),
            ),
          const SizedBox(height: 32),
          GestureDetector(
            onTap: _goBack,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: flashColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: flashColor.withValues(alpha: 0.25)),
              ),
              child: Text(
                '← Back to Feed',
                style: TextStyle(
                  color: flashColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
