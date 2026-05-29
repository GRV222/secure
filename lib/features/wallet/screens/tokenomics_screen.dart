import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/providers/theme_provider.dart';

// ── Semantic token colors (unchanged) ────────────────────────────────────────
const _purple = Color(0xFF6C63FF);
const _gold   = Color(0xFFFFB800);
const _green  = Color(0xFF00C896);
const _red    = Color(0xFFFF4757);

// ── Adaptive palette helpers ──────────────────────────────────────────────────
Color _aBg(bool d)          => d ? AppColors.digBg        : AppColors.tradBg;
Color _aSurface(bool d)     => d ? AppColors.digSurface   : AppColors.tradSurface;
Color _aSurfaceHigh(bool d) => d ? AppColors.digCard      : AppColors.tradCard;
Color _aText(bool d)        => d ? AppColors.digText      : AppColors.tradText;
Color _aMuted(bool d)       => d ? AppColors.digTextSub   : AppColors.tradTextSub;

class TokenomicsScreen extends StatefulWidget {
  const TokenomicsScreen({super.key});

  @override
  State<TokenomicsScreen> createState() => _TokenomicsScreenState();
}

class _TokenomicsScreenState extends State<TokenomicsScreen>
    with TickerProviderStateMixin {
  late final AnimationController _bgCtrl;
  late final AnimationController _coinCtrl;
  late final AnimationController _glowCtrl;
  late final AnimationController _arrowCtrl;
  late final AnimationController _countCtrl;

  late final Animation<double> _countAnim;
  late final Animation<Color?> _glowColorAnim;

  final _scrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();

    _bgCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 8))
      ..repeat();

    _coinCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 3))
      ..repeat();

    _glowCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 2))
      ..repeat(reverse: true);

    _arrowCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))
      ..repeat(reverse: true);

    _countCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 3));

    _countAnim = Tween<double>(begin: 0, end: 50).animate(
      CurvedAnimation(parent: _countCtrl, curve: Curves.easeOut),
    );

    _glowColorAnim = ColorTween(begin: _purple, end: _gold).animate(
      CurvedAnimation(parent: _glowCtrl, curve: Curves.easeInOut),
    );

    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) _countCtrl.forward();
    });
  }

  @override
  void dispose() {
    _bgCtrl.dispose();
    _coinCtrl.dispose();
    _glowCtrl.dispose();
    _arrowCtrl.dispose();
    _countCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final d = context.watch<ThemeProvider>().isDigital;
    return Scaffold(
      backgroundColor: _aBg(d),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: _aText(d), size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: CustomScrollView(
        controller: _scrollCtrl,
        slivers: [
          SliverList(
            delegate: SliverChildListDelegate([
              _HeroSection(bgCtrl: _bgCtrl),
              _ProblemSection(),
              _VisionSection(),
              _ThreeTokensSection(coinCtrl: _coinCtrl, glowColorAnim: _glowColorAnim),
              _MechanicSection(arrowCtrl: _arrowCtrl),
              _InvestmentSection(),
              _CharitySection(countAnim: _countAnim),
              _ComparisonSection(),
              _CtaSection(),
              const SizedBox(height: 60),
            ]),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Section 1 — Hero
// ══════════════════════════════════════════════════════════════════════════════

class _HeroSection extends StatelessWidget {
  final AnimationController bgCtrl;
  const _HeroSection({required this.bgCtrl});

  @override
  Widget build(BuildContext context) {
    final d = context.watch<ThemeProvider>().isDigital;
    final textPrimary = _aText(d);
    final textMuted = _aMuted(d);
    final h = MediaQuery.of(context).size.height;
    return SizedBox(
      height: h,
      child: Stack(
        children: [
          AnimatedBuilder(
            animation: bgCtrl,
            builder: (_, __) {
              final t = bgCtrl.value * 2 * math.pi;
              return Stack(
                children: [
                  _FloatingCircle(
                    x: 0.15 + 0.08 * math.sin(t * 0.7),
                    y: 0.2 + 0.06 * math.cos(t * 0.5),
                    size: 260,
                    color: _purple.withValues(alpha: 0.18),
                    blur: 80,
                    screenSize: MediaQuery.of(context).size,
                  ),
                  _FloatingCircle(
                    x: 0.75 + 0.07 * math.cos(t * 0.6),
                    y: 0.15 + 0.08 * math.sin(t * 0.4),
                    size: 200,
                    color: _gold.withValues(alpha: 0.12),
                    blur: 70,
                    screenSize: MediaQuery.of(context).size,
                  ),
                  _FloatingCircle(
                    x: 0.85 + 0.05 * math.sin(t * 0.8),
                    y: 0.6 + 0.07 * math.cos(t * 0.7),
                    size: 180,
                    color: _green.withValues(alpha: 0.10),
                    blur: 60,
                    screenSize: MediaQuery.of(context).size,
                  ),
                  _FloatingCircle(
                    x: 0.1 + 0.06 * math.cos(t * 0.9),
                    y: 0.7 + 0.05 * math.sin(t * 0.6),
                    size: 140,
                    color: _purple.withValues(alpha: 0.10),
                    blur: 50,
                    screenSize: MediaQuery.of(context).size,
                  ),
                ],
              );
            },
          ),
          Positioned.fill(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    border: Border.all(color: _gold.withValues(alpha: 0.5)),
                    borderRadius: BorderRadius.circular(100),
                    color: _gold.withValues(alpha: 0.08),
                  ),
                  child: const Text(
                    'TOKENOMICS & VISION',
                    style: TextStyle(fontSize: 11, color: _gold, fontWeight: FontWeight.w700, letterSpacing: 1.8),
                  ),
                ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.3),
                const SizedBox(height: 24),
                Text(
                  'SECURE',
                  style: TextStyle(
                    fontSize: 72,
                    fontWeight: FontWeight.w900,
                    color: textPrimary,
                    letterSpacing: -2,
                    height: 1,
                  ),
                ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2),
                const SizedBox(height: 12),
                const Text(
                  'The Economy of\nHuman Growth',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontStyle: FontStyle.italic,
                    color: _gold,
                    height: 1.4,
                    fontWeight: FontWeight.w500,
                  ),
                ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.2),
                const SizedBox(height: 20),
                Text(
                  'A platform where talent is discovered,\nrewarded, and remembered.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15, color: textMuted, height: 1.6),
                ).animate().fadeIn(delay: 800.ms),
                const SizedBox(height: 60),
                _BouncingArrow(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FloatingCircle extends StatelessWidget {
  final double x, y, size, blur;
  final Color color;
  final Size screenSize;
  const _FloatingCircle({
    required this.x, required this.y, required this.size,
    required this.color, required this.blur, required this.screenSize,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: screenSize.width * x - size / 2,
      top: screenSize.height * y - size / 2,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: color, blurRadius: blur, spreadRadius: size * 0.3)],
        ),
      ),
    );
  }
}

class _BouncingArrow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final d = context.watch<ThemeProvider>().isDigital;
    return Icon(Icons.keyboard_arrow_down_rounded, color: _aMuted(d), size: 32)
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .slideY(begin: 0, end: 0.3, duration: 700.ms, curve: Curves.easeInOut)
        .fadeIn();
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Section 2 — The Problem
// ══════════════════════════════════════════════════════════════════════════════

class _ProblemSection extends StatelessWidget {
  static const _problems = [
    (
      icon: '😶',
      title: 'No Real Identity',
      body: 'Social media rewards persona, not person. You know the brand, not the human.',
    ),
    (
      icon: '📉',
      title: 'Merit Doesn\'t Matter',
      body: 'Quality loses to quantity. The loudest voice wins, not the best work.',
    ),
    (
      icon: '💸',
      title: 'Talent Goes Unrewarded',
      body: 'Billions of gifted people create daily and earn nothing. The platform takes all.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final d = context.watch<ThemeProvider>().isDigital;
    final bg = _aBg(d);
    final textPrimary = _aText(d);
    return Container(
      color: bg,
      padding: const EdgeInsets.symmetric(vertical: 64),
      child: Column(
        children: [
          _SectionLabel('THE PROBLEM'),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'The internet broke something fundamental.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: textPrimary, height: 1.3),
            ),
          ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.2),
          const SizedBox(height: 32),
          SizedBox(
            height: 190,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              itemCount: _problems.length,
              separatorBuilder: (_, __) => const SizedBox(width: 16),
              itemBuilder: (_, i) {
                final p = _problems[i];
                return _ProblemCard(icon: p.icon, title: p.title, body: p.body)
                    .animate().fadeIn(delay: (200 + i * 150).ms).slideX(begin: 0.2);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ProblemCard extends StatelessWidget {
  final String icon, title, body;
  const _ProblemCard({required this.icon, required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    final d = context.watch<ThemeProvider>().isDigital;
    final surface = _aSurface(d);
    final textPrimary = _aText(d);
    final textMuted = _aMuted(d);
    return Container(
      width: 220,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(16),
        border: Border(top: BorderSide(color: _red, width: 3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(icon, style: const TextStyle(fontSize: 28)),
          const SizedBox(height: 12),
          Text(title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: textPrimary)),
          const SizedBox(height: 8),
          Text(body, style: TextStyle(fontSize: 12, color: textMuted, height: 1.5)),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Section 3 — The Vision
// ══════════════════════════════════════════════════════════════════════════════

class _VisionSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final d = context.watch<ThemeProvider>().isDigital;
    final surfaceHigh = _aSurfaceHigh(d);
    final surface = _aSurface(d);
    final textPrimary = _aText(d);
    final textMuted = _aMuted(d);
    return Container(
      color: surfaceHigh,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 64),
      child: Column(
        children: [
          _SectionLabel('THE VISION'),
          const SizedBox(height: 16),
          Text(
            'She was 16. She sketched every day.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: textPrimary, height: 1.3),
          ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.2),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _purple.withValues(alpha: 0.3)),
            ),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _PulsingBulb(),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        'Imagine a 16-year-old in a small town. She sketches every day — faces, landscapes, flowers. '
                        'Her work is genuinely brilliant. But she has no resources, no mentor, no platform that truly sees her.\n\n'
                        'She uploads on social media. Gets 11 likes. Her friend posts a selfie — 340 likes.\n\n'
                        'She stops sketching.',
                        style: TextStyle(fontSize: 14, color: textMuted, height: 1.75),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Divider(color: d ? const Color(0xFF2A2A4A) : AppColors.tradBorder),
                const SizedBox(height: 20),
                const Text(
                  'SECURE exists so she never stops.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: _purple, height: 1.4),
                ),
                const SizedBox(height: 8),
                Text(
                  'On SECURE, her 11 ratings are from people who genuinely assessed her work. '
                  'Her average is 4.6 stars. She enters the monthly competition. She places 2nd. '
                  'She earns DA tokens. A mentor finds her.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: textMuted, height: 1.6),
                ),
              ],
            ),
          ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.15),
        ],
      ),
    );
  }
}

class _PulsingBulb extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Text('💡', style: TextStyle(fontSize: 32))
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .scaleXY(begin: 1.0, end: 1.25, duration: 900.ms, curve: Curves.easeInOut);
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Section 4 — Three Tokens
// ══════════════════════════════════════════════════════════════════════════════

class _ThreeTokensSection extends StatelessWidget {
  final AnimationController coinCtrl;
  final Animation<Color?> glowColorAnim;
  const _ThreeTokensSection({required this.coinCtrl, required this.glowColorAnim});

  @override
  Widget build(BuildContext context) {
    final d = context.watch<ThemeProvider>().isDigital;
    final bg = _aBg(d);
    final textPrimary = _aText(d);
    return Container(
      color: bg,
      padding: const EdgeInsets.symmetric(vertical: 64),
      child: Column(
        children: [
          _SectionLabel('THE TOKENS'),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'Three tokens. One economy.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: textPrimary, height: 1.3),
            ),
          ).animate().fadeIn(delay: 100.ms),
          const SizedBox(height: 40),
          _TokenCard(
            coinCtrl: coinCtrl,
            color: const Color(0xFF4A3FE0),
            label: 'SHREE',
            symbol: 'S',
            tagline: 'Platform Currency',
            description: 'The premium token. Earned by top performers and early believers. '
                'Used for platform governance, premium features, and staking rewards.',
            attrs: const [('Supply', '100M'), ('Earned by', 'Top Performers'), ('Governance', 'Yes')],
          ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.15),
          const SizedBox(height: 20),
          _TokenCard(
            coinCtrl: coinCtrl,
            color: _green,
            label: 'DA',
            symbol: 'DA',
            tagline: 'Activity Token',
            description: 'The participation token. Earned by posting quality content, rating others, '
                'and winning competitions. Spendable within the platform ecosystem.',
            attrs: const [('Supply', 'Dynamic'), ('Earned by', 'Quality Posts'), ('Use', 'Platform Spend')],
          ).animate().fadeIn(delay: 350.ms).slideX(begin: 0.15),
          const SizedBox(height: 20),
          _ShreeDaCard(glowColorAnim: glowColorAnim),
        ],
      ),
    );
  }
}

class _TokenCard extends StatelessWidget {
  final AnimationController coinCtrl;
  final Color color;
  final String label, symbol, tagline, description;
  final List<(String, String)> attrs;
  const _TokenCard({
    required this.coinCtrl, required this.color, required this.label,
    required this.symbol, required this.tagline, required this.description,
    required this.attrs,
  });

  @override
  Widget build(BuildContext context) {
    final d = context.watch<ThemeProvider>().isDigital;
    final surface = _aSurface(d);
    final surfaceHigh = _aSurfaceHigh(d);
    final textMuted = _aMuted(d);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          AnimatedBuilder(
            animation: coinCtrl,
            builder: (_, __) {
              final angle = coinCtrl.value * 2 * math.pi;
              final scaleX = math.cos(angle).abs();
              return Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()..scale(scaleX.clamp(0.15, 1.0), 1.0),
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [color.withValues(alpha: 0.9), color.withValues(alpha: 0.4)],
                    ),
                    boxShadow: [BoxShadow(color: color.withValues(alpha: 0.4), blurRadius: 16)],
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    symbol,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18),
                  ),
                ),
              );
            },
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(label, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: color)),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(color: color.withValues(alpha: 0.3)),
                      ),
                      child: Text(tagline,
                          style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(description, style: TextStyle(fontSize: 12, color: textMuted, height: 1.5)),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: attrs.map((a) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: surfaceHigh,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: color.withValues(alpha: 0.2)),
                      ),
                      child: Text(
                        '${a.$1}: ${a.$2}',
                        style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w600),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ShreeDaCard extends StatelessWidget {
  final Animation<Color?> glowColorAnim;
  const _ShreeDaCard({required this.glowColorAnim});

  @override
  Widget build(BuildContext context) {
    final d = context.watch<ThemeProvider>().isDigital;
    final surface = _aSurface(d);
    final surfaceHigh = _aSurfaceHigh(d);
    final textMuted = _aMuted(d);
    return AnimatedBuilder(
      animation: glowColorAnim,
      builder: (_, __) {
        final glowColor = glowColorAnim.value ?? _purple;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: glowColor.withValues(alpha: 0.6), width: 1.5),
            boxShadow: [
              BoxShadow(color: glowColor.withValues(alpha: 0.15), blurRadius: 24, spreadRadius: 2),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [glowColor.withValues(alpha: 0.9), glowColor.withValues(alpha: 0.4)],
                  ),
                  boxShadow: [BoxShadow(color: glowColor.withValues(alpha: 0.5), blurRadius: 20)],
                ),
                alignment: Alignment.center,
                child: const Text(
                  'SD',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text('SHREEDA',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: glowColor)),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                                colors: [_purple.withValues(alpha: 0.3), _gold.withValues(alpha: 0.3)]),
                            borderRadius: BorderRadius.circular(100),
                            border: Border.all(color: glowColor.withValues(alpha: 0.4)),
                          ),
                          child: Text('Master Token',
                              style: TextStyle(fontSize: 10, color: glowColor, fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'The convergence token. Created when SHREE and DA combine. '
                      'Represents mastery — both creative excellence and community contribution. '
                      'Rarest. Most valuable. Most meaningful.',
                      style: TextStyle(fontSize: 12, color: textMuted, height: 1.5),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        for (final a in [('Supply', 'Emergent'), ('Requires', 'SHREE + DA'), ('Status', 'Rarest')])
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: surfaceHigh,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: glowColor.withValues(alpha: 0.25)),
                            ),
                            child: Text(
                              '${a.$1}: ${a.$2}',
                              style: TextStyle(fontSize: 10, color: glowColor, fontWeight: FontWeight.w600),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Section 5 — The Mechanic
// ══════════════════════════════════════════════════════════════════════════════

class _MechanicSection extends StatelessWidget {
  final AnimationController arrowCtrl;
  const _MechanicSection({required this.arrowCtrl});

  static const _steps = [
    ('1', '📸', 'Post Your Work', 'Share a skill, art, or creation under a hashtag identity.', _purple),
    ('2', '⭐', 'Get Rated', 'Community rates 1–5 stars. Quality rises. Noise fades.', _gold),
    ('3', '🏆', 'Enter Competition', 'Monthly hashtag competitions rank the best performers.', _green),
    ('4', '🎖️', 'Win Rewards', 'Top performers earn DA tokens + reputation boost.', _gold),
    ('5', '📈', 'Build Reputation', 'Your star average and history are permanent and public.', _purple),
    ('6', '💎', 'Earn SHREE', 'Sustained excellence and platform contribution earns SHREE.', Color(0xFF4A3FE0)),
    ('7', '✨', 'Become SHREEDA', 'Combine excellence + community. Achieve mastery status.', Colors.white),
  ];

  @override
  Widget build(BuildContext context) {
    final d = context.watch<ThemeProvider>().isDigital;
    final surfaceHigh = _aSurfaceHigh(d);
    final textPrimary = _aText(d);
    return Container(
      color: surfaceHigh,
      padding: const EdgeInsets.symmetric(vertical: 64),
      child: Column(
        children: [
          _SectionLabel('HOW IT WORKS'),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'The 7-step value loop',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: textPrimary, height: 1.3),
            ),
          ).animate().fadeIn(delay: 100.ms),
          const SizedBox(height: 40),
          for (int i = 0; i < _steps.length; i++) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: _StepRow(step: _steps[i])
                  .animate().fadeIn(delay: (150 + i * 100).ms).slideX(begin: i.isEven ? -0.1 : 0.1),
            ),
            if (i < _steps.length - 1)
              Padding(
                padding: const EdgeInsets.only(left: 55),
                child: _PulsingArrow(ctrl: arrowCtrl, color: _steps[i].$5),
              ),
          ],
        ],
      ),
    );
  }
}

class _StepRow extends StatelessWidget {
  final (String, String, String, String, Color) step;
  const _StepRow({required this.step});

  @override
  Widget build(BuildContext context) {
    final d = context.watch<ThemeProvider>().isDigital;
    final textMuted = _aMuted(d);
    final (num, emoji, title, desc, color) = step;
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withValues(alpha: 0.15),
            border: Border.all(color: color.withValues(alpha: 0.5)),
          ),
          alignment: Alignment.center,
          child: Text(num, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: color)),
        ),
        const SizedBox(width: 16),
        Text(emoji, style: const TextStyle(fontSize: 24)),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: color)),
              Text(desc, style: TextStyle(fontSize: 12, color: textMuted, height: 1.4)),
            ],
          ),
        ),
      ],
    );
  }
}

class _PulsingArrow extends StatelessWidget {
  final AnimationController ctrl;
  final Color color;
  const _PulsingArrow({required this.ctrl, required this.color});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: ctrl,
      builder: (_, __) {
        return Opacity(
          opacity: 0.4 + 0.6 * ctrl.value,
          child: Icon(Icons.keyboard_arrow_down_rounded, color: _gold, size: 28),
        );
      },
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Section 6 — Investment Opportunity
// ══════════════════════════════════════════════════════════════════════════════

class _InvestmentSection extends StatelessWidget {
  static const _valueCards = [
    ('🌍', '2B+', 'Talented people with no platform to grow'),
    ('📱', '\$180B', 'Social media ad market we\'re disrupting'),
    ('🏦', '\$4T', 'Creator economy potential by 2030'),
  ];

  static const _supply = [
    ('SHREE', '100,000,000', 'Fixed', 'Platform governance & premium'),
    ('DA', 'Dynamic', 'Earned', 'Activity rewards & competitions'),
    ('SHREEDA', 'Emergent', 'Merged', 'Mastery proof-of-excellence'),
  ];

  static const _timeline = [
    ('Q3 2026', 'Phase 1 Beta', 'Core platform + ratings + competitions', true),
    ('Q1 2027', 'Phase 2 Tokens', 'DA distribution + competition rewards', false),
    ('Q3 2027', 'Phase 3 SHREE', 'SHREE listing + governance launch', false),
    ('2028', 'Phase 4 SHREEDA', 'SHREEDA emergence + global expansion', false),
  ];

  @override
  Widget build(BuildContext context) {
    final d = context.watch<ThemeProvider>().isDigital;
    final bg = _aBg(d);
    final surface = _aSurface(d);
    final surfaceHigh = _aSurfaceHigh(d);
    final textPrimary = _aText(d);
    final textMuted = _aMuted(d);
    return Container(
      color: bg,
      padding: const EdgeInsets.symmetric(vertical: 64),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: d
                    ? [const Color(0xFF2A2000), const Color(0xFF1A1400)]
                    : [const Color(0xFFF8E8C0), const Color(0xFFFDF3DC)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _gold.withValues(alpha: 0.4)),
            ),
            child: Column(
              children: [
                _SectionLabel('INVESTMENT OPPORTUNITY', color: _gold),
                const SizedBox(height: 12),
                const Text(
                  'The market is enormous.\nWe are early.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: _gold, height: 1.3),
                ),
              ],
            ),
          ).animate().fadeIn(delay: 100.ms),
          const SizedBox(height: 32),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: _valueCards.asMap().entries.map((e) {
                final (emoji, number, label) = e.value;
                return Expanded(
                  child: Container(
                    margin: EdgeInsets.only(left: e.key == 0 ? 0 : 8, right: e.key == 2 ? 0 : 8),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: _gold.withValues(alpha: 0.2)),
                    ),
                    child: Column(
                      children: [
                        Text(emoji, style: const TextStyle(fontSize: 24)),
                        const SizedBox(height: 8),
                        Text(number,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: _gold)),
                        const SizedBox(height: 4),
                        Text(label,
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 10, color: textMuted, height: 1.4)),
                      ],
                    ),
                  ).animate().fadeIn(delay: (200 + e.key * 100).ms).slideY(begin: 0.2),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 40),
          _SectionLabel('TOKEN SUPPLY'),
          const SizedBox(height: 16),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            decoration: BoxDecoration(
              color: surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: surfaceHigh),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: surfaceHigh,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                  child: Row(
                    children: [
                      Expanded(flex: 2, child: Text('Token', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: textMuted))),
                      Expanded(flex: 3, child: Text('Supply', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: textMuted))),
                      Expanded(flex: 2, child: Text('Model', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: textMuted))),
                    ],
                  ),
                ),
                for (int i = 0; i < _supply.length; i++)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      border: i < _supply.length - 1
                          ? Border(bottom: BorderSide(color: d ? const Color(0xFF1A1A35) : AppColors.tradBorder))
                          : null,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Text(
                            _supply[i].$1,
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: _purple),
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Text(_supply[i].$2, style: TextStyle(fontSize: 12, color: textPrimary)),
                        ),
                        Expanded(
                          flex: 2,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: _purple.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: Text(_supply[i].$3,
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 10, color: _purple, fontWeight: FontWeight.w600)),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ).animate().fadeIn(delay: 200.ms),
          const SizedBox(height: 40),
          _SectionLabel('LAUNCH TIMELINE'),
          const SizedBox(height: 24),
          for (int i = 0; i < _timeline.length; i++)
            _TimelineRow(
              quarter: _timeline[i].$1,
              phase: _timeline[i].$2,
              desc: _timeline[i].$3,
              isNow: _timeline[i].$4,
              isLast: i == _timeline.length - 1,
            ).animate().fadeIn(delay: (100 + i * 100).ms).slideX(begin: 0.15),
        ],
      ),
    );
  }
}

class _TimelineRow extends StatelessWidget {
  final String quarter, phase, desc;
  final bool isNow, isLast;
  const _TimelineRow({
    required this.quarter, required this.phase,
    required this.desc, required this.isNow, required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final d = context.watch<ThemeProvider>().isDigital;
    final surfaceHigh = _aSurfaceHigh(d);
    final textPrimary = _aText(d);
    final textMuted = _aMuted(d);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isNow ? _gold : surfaceHigh,
                  border: Border.all(color: isNow ? _gold : textMuted, width: isNow ? 2 : 1),
                ),
              ),
              if (!isLast)
                Container(width: 1, height: 56, color: surfaceHigh),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(quarter,
                          style: TextStyle(
                              fontSize: 12,
                              color: isNow ? _gold : textMuted,
                              fontWeight: FontWeight.w600)),
                      if (isNow) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: _gold.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(100),
                            border: Border.all(color: _gold.withValues(alpha: 0.4)),
                          ),
                          child: const Text('YOU ARE HERE',
                              style: TextStyle(
                                  fontSize: 9,
                                  color: _gold,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.5)),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(phase,
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: textPrimary)),
                  Text(desc, style: TextStyle(fontSize: 12, color: textMuted, height: 1.4)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Section 7 — Charity Economy
// ══════════════════════════════════════════════════════════════════════════════

class _CharitySection extends StatelessWidget {
  final Animation<double> countAnim;
  const _CharitySection({required this.countAnim});

  @override
  Widget build(BuildContext context) {
    final d = context.watch<ThemeProvider>().isDigital;
    final surfaceHigh = _aSurfaceHigh(d);
    final surface = _aSurface(d);
    final textPrimary = _aText(d);
    final textMuted = _aMuted(d);
    return Container(
      color: surfaceHigh,
      padding: const EdgeInsets.symmetric(vertical: 64, horizontal: 24),
      child: Column(
        children: [
          _SectionLabel('CHARITY ECONOMY'),
          const SizedBox(height: 16),
          Text(
            'Profit with purpose.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: textPrimary, height: 1.3),
          ).animate().fadeIn(delay: 100.ms),
          const SizedBox(height: 8),
          Text(
            'A portion of every token transaction goes to verified charitable causes. '
            'The community votes on where it goes.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: textMuted, height: 1.6),
          ).animate().fadeIn(delay: 200.ms),
          const SizedBox(height: 40),
          AnimatedBuilder(
            animation: countAnim,
            builder: (_, __) {
              return Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _green.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      children: [
                        Text(
                          '${countAnim.value.toStringAsFixed(1)}%',
                          style: const TextStyle(
                              fontSize: 52, fontWeight: FontWeight.w900, color: _green, height: 1),
                        ),
                        Text('of platform revenue', style: TextStyle(fontSize: 13, color: textMuted)),
                        Text('goes to charity', style: TextStyle(fontSize: 13, color: textMuted)),
                      ],
                    ),
                  ],
                ),
              );
            },
          ).animate().fadeIn(delay: 300.ms),
          const SizedBox(height: 32),
          _CharityNodes(),
        ],
      ),
    );
  }
}

class _CharityNodes extends StatelessWidget {
  static const _nodes = [
    ('🎓', 'Education\nFund'),
    ('🏥', 'Healthcare\nAccess'),
    ('🌱', 'Environment\nGrants'),
    ('🎨', 'Arts\nPrograms'),
    ('🤝', 'Community\nBuild'),
  ];

  @override
  Widget build(BuildContext context) {
    final d = context.watch<ThemeProvider>().isDigital;
    final surface = _aSurface(d);
    final textMuted = _aMuted(d);
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      alignment: WrapAlignment.center,
      children: _nodes.asMap().entries.map((e) {
        return Container(
          width: 120,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _green.withValues(alpha: 0.25)),
          ),
          child: Column(
            children: [
              Text(e.value.$1, style: const TextStyle(fontSize: 28)),
              const SizedBox(height: 8),
              Text(
                e.value.$2,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 11, color: textMuted, height: 1.4),
              ),
            ],
          ),
        ).animate().fadeIn(delay: (200 + e.key * 80).ms).scaleXY(begin: 0.85);
      }).toList(),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Section 8 — Why We Are Different
// ══════════════════════════════════════════════════════════════════════════════

class _ComparisonSection extends StatelessWidget {
  static const _rows = [
    ('Identity', 'Real name + reputation', 'Anonymous username'),
    ('Metric', 'Star ratings (quality)', 'Likes & followers (vanity)'),
    ('Algorithm', 'Merit-based', 'Engagement-bait'),
    ('Revenue', 'Shared with creators', 'Kept by platform'),
    ('Economy', 'Token ecosystem', 'Ad surveillance'),
    ('Charity', '50% to good causes', 'Profit only'),
    ('Competition', 'Monthly skill contests', 'Viral lottery'),
  ];

  @override
  Widget build(BuildContext context) {
    final d = context.watch<ThemeProvider>().isDigital;
    final bg = _aBg(d);
    final surface = _aSurface(d);
    final surfaceHigh = _aSurfaceHigh(d);
    final textPrimary = _aText(d);
    final textMuted = _aMuted(d);
    return Container(
      color: bg,
      padding: const EdgeInsets.symmetric(vertical: 64, horizontal: 24),
      child: Column(
        children: [
          _SectionLabel('WHY WE\'RE DIFFERENT'),
          const SizedBox(height: 16),
          Text(
            'Not another social app.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: textPrimary, height: 1.3),
          ).animate().fadeIn(delay: 100.ms),
          const SizedBox(height: 32),
          Container(
            decoration: BoxDecoration(
              color: surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: surfaceHigh),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  decoration: BoxDecoration(
                    color: surfaceHigh,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  child: Row(
                    children: [
                      Expanded(flex: 2, child: Text('Feature', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: textMuted))),
                      Expanded(flex: 3, child: Row(children: [
                        const Text('⚡ ', style: TextStyle(fontSize: 12)),
                        const Text('SECURE', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: _purple)),
                      ])),
                      Expanded(flex: 3, child: Text('Others', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: textMuted))),
                    ],
                  ),
                ),
                for (int i = 0; i < _rows.length; i++)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      color: i.isEven ? Colors.transparent : surfaceHigh.withValues(alpha: 0.3),
                      border: i < _rows.length - 1
                          ? Border(bottom: BorderSide(color: d ? const Color(0xFF1A1A35) : AppColors.tradBorder))
                          : null,
                      borderRadius: i == _rows.length - 1
                          ? const BorderRadius.vertical(bottom: Radius.circular(20))
                          : null,
                    ),
                    child: Row(
                      children: [
                        Expanded(flex: 2, child: Text(_rows[i].$1, style: TextStyle(fontSize: 12, color: textMuted, fontWeight: FontWeight.w600))),
                        Expanded(
                          flex: 3,
                          child: Row(
                            children: [
                              const Icon(Icons.check_circle, color: _green, size: 14),
                              const SizedBox(width: 6),
                              Flexible(child: Text(_rows[i].$2, style: TextStyle(fontSize: 12, color: textPrimary))),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Row(
                            children: [
                              const Icon(Icons.cancel, color: _red, size: 14),
                              const SizedBox(width: 6),
                              Flexible(child: Text(_rows[i].$3, style: TextStyle(fontSize: 12, color: textMuted))),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: (100 + i * 60).ms),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Section 9 — CTA
// ══════════════════════════════════════════════════════════════════════════════

class _CtaSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final d = context.watch<ThemeProvider>().isDigital;
    final surfaceHigh = _aSurfaceHigh(d);
    final textPrimary = _aText(d);
    final textMuted = _aMuted(d);
    return Container(
      color: surfaceHigh,
      padding: const EdgeInsets.symmetric(vertical: 72, horizontal: 32),
      child: Column(
        children: [
          const Text(
            '✨',
            style: TextStyle(fontSize: 48),
          ).animate().scaleXY(begin: 0.5, curve: Curves.elasticOut, duration: 800.ms),
          const SizedBox(height: 24),
          Text(
            'You Found This Early.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: textPrimary, height: 1.2),
          ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),
          const SizedBox(height: 16),
          Text(
            'The people who believed in the internet in 1995. In smartphones in 2007. In creators in 2015.\n\n'
            'You are here, in 2026, at the beginning of the merit economy.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 15, color: textMuted, height: 1.7),
          ).animate().fadeIn(delay: 400.ms),
          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: _purple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: () => context.pop(),
              icon: const Icon(Icons.account_balance_wallet_outlined, size: 20),
              label: const Text('Back to My Wallet',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            ),
          ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.2),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: _gold, width: 1.5),
                foregroundColor: _gold,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Sharing coming soon — tell a friend manually! 🙂')),
                );
              },
              icon: const Icon(Icons.share_outlined, size: 20),
              label: const Text('Share This Vision',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            ),
          ).animate().fadeIn(delay: 700.ms).slideY(begin: 0.2),
          const SizedBox(height: 40),
          Text(
            'SECURE tokens are utility tokens for platform use. This is not financial advice. '
            'Token availability subject to regulatory compliance. SECURE is currently in beta.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 10, color: textMuted.withValues(alpha: 0.6), height: 1.6),
          ).animate().fadeIn(delay: 900.ms),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Shared helpers
// ══════════════════════════════════════════════════════════════════════════════

class _SectionLabel extends StatelessWidget {
  final String text;
  final Color? color;
  const _SectionLabel(this.text, {this.color});

  @override
  Widget build(BuildContext context) {
    final d = context.watch<ThemeProvider>().isDigital;
    return Text(
      text,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: color ?? _aMuted(d),
        letterSpacing: 2.0,
      ),
    );
  }
}
