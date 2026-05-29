import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/wallet_provider.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../../config/route_names.dart';
import '../../../core/dummy/dummy_data.dart';
import '../../../core/providers/theme_provider.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});
  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen>
    with TickerProviderStateMixin {
  late AnimationController _coinCtrl;
  late AnimationController _glowCtrl;
  late AnimationController _pulseCtrl;
  late Animation<double> _coinSpin;
  late Animation<double> _glow;
  late Animation<double> _pulse;

  @override
  void initState() {
    super.initState();

    _coinCtrl = AnimationController(
        vsync: this, duration: const Duration(seconds: 4))
      ..repeat();
    _glowCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1800))
      ..repeat(reverse: true);
    _pulseCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2200))
      ..repeat(reverse: true);

    _coinSpin = Tween<double>(begin: 0, end: 2 * pi).animate(
        CurvedAnimation(parent: _coinCtrl, curve: Curves.easeInOut));
    _glow = Tween<double>(begin: 0.3, end: 0.8).animate(
        CurvedAnimation(parent: _glowCtrl, curve: Curves.easeInOut));
    _pulse = Tween<double>(begin: 0.95, end: 1.05).animate(
        CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _coinCtrl.dispose();
    _glowCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDigital = context.watch<ThemeProvider>().isDigital;
    final wallet = context.watch<WalletProvider>();
    final user = context.watch<AuthProvider>().currentUser;
    if (user != null) wallet.loadWallet(user);

    return Scaffold(
      backgroundColor: isDigital
          ? const Color(0xFF0A080E)
          : const Color(0xFF0A0806),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 0,
            floating: true,
            backgroundColor:
                isDigital ? const Color(0xFF0A080E) : const Color(0xFF0A0806),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFFB8860B)),
              onPressed: () => context.pop(),
            ),
            title: Text(
              'SHREEDA Wallet',
              style: TextStyle(
                fontFamily: 'CormorantGaramond',
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: const Color(0xFFB8860B),
                letterSpacing: 1,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.info_outline,
                    color: Color(0xFFB8860B)),
                onPressed: () => context.push(RouteNames.tokenomics),
              ),
            ],
          ),

          SliverToBoxAdapter(
            child: Column(
              children: [
                _ShreedaBanner(
                  glow: _glow,
                  pulse: _pulse,
                  coinSpin: _coinSpin,
                  isDigital: isDigital,
                ),
                const SizedBox(height: 16),
                _PhaseStatus(isDigital: isDigital),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Column(
                    children: [
                      _ShreedaCard(
                        amount: wallet.shreedaBalance,
                        glow: _glow,
                        isDigital: isDigital,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _ShreeCard(
                              amount: wallet.shreeCoinBalance,
                              isDigital: isDigital,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _DaCard(
                              amount: wallet.daCoinBalance,
                              isDigital: isDigital,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _TokenMechanics(isDigital: isDigital),
                      const SizedBox(height: 20),
                      _SupplySection(isDigital: isDigital),
                      const SizedBox(height: 20),
                      _CompetitionRewards(isDigital: isDigital),
                      const SizedBox(height: 20),
                      _NftTiers(isDigital: isDigital),
                      const SizedBox(height: 20),
                      _BurnMechanics(isDigital: isDigital),
                      const SizedBox(height: 20),
                      _GovernancePyramid(isDigital: isDigital),
                      const SizedBox(height: 20),
                      _DonateDaSection(isDigital: isDigital),
                      const SizedBox(height: 20),
                      _Tagline(isDigital: isDigital),
                      const SizedBox(height: 40),
                    ],
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

// ─── Section Wrapper ─────────────────────────────────────────────

class _Section extends StatelessWidget {
  final String title;
  final String emoji;
  final bool isDigital;
  final Widget child;

  const _Section({
    required this.title,
    required this.emoji,
    required this.isDigital,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'CormorantGaramond',
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

// ─── SHREEDA Banner ──────────────────────────────────────────────

class _ShreedaBanner extends StatelessWidget {
  final Animation<double> glow;
  final Animation<double> pulse;
  final Animation<double> coinSpin;
  final bool isDigital;

  const _ShreedaBanner({
    required this.glow,
    required this.pulse,
    required this.coinSpin,
    required this.isDigital,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDigital
              ? [
                  const Color(0xFF1a0a2e),
                  const Color(0xFF0d1520),
                  const Color(0xFF0a1a10),
                ]
              : [
                  const Color(0xFF2a1a00),
                  const Color(0xFF1a0a00),
                  const Color(0xFF0a1a10),
                ],
        ),
      ),
      child: Column(
        children: [
          AnimatedBuilder(
            animation: Listenable.merge([coinSpin, glow, pulse]),
            builder: (_, __) => Transform.scale(
              scale: pulse.value,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFB8860B)
                          .withValues(alpha: glow.value * 0.5),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child:
                    const Text('🪙', style: TextStyle(fontSize: 56)),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'SHREEDA',
            style: TextStyle(
              fontFamily: 'CormorantGaramond',
              fontSize: 32,
              fontWeight: FontWeight.w700,
              color: Color(0xFFB8860B),
              letterSpacing: 6,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '"The Lock. The Key. The Journey."',
            style: TextStyle(
              fontFamily: 'CormorantGaramond',
              fontStyle: FontStyle.italic,
              fontSize: 14,
              color: const Color(0xFFB8860B).withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '"If you have a dream and the willingness to work,\nwe will give you everything else."',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'CormorantGaramond',
              fontStyle: FontStyle.italic,
              fontSize: 13,
              color: Colors.white.withValues(alpha: 0.35),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _StatPill(
                  label: 'Supply',
                  value: '21B',
                  color: const Color(0xFF9b59b6)),
              _StatPill(
                  label: 'Network',
                  value: 'Solana',
                  color: const Color(0xFF27ae60)),
              _StatPill(
                  label: 'Launch',
                  value: '~\$0.00006',
                  color: const Color(0xFFB8860B)),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _StatPill(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) => Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Column(
          children: [
            Text(value,
                style: TextStyle(
                    color: color,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'CormorantGaramond')),
            Text(label,
                style: TextStyle(
                    color: color.withValues(alpha: 0.6),
                    fontSize: 10)),
          ],
        ),
      );
}

// ─── Phase Status ────────────────────────────────────────────────

class _PhaseStatus extends StatelessWidget {
  final bool isDigital;
  const _PhaseStatus({required this.isDigital});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFB8860B).withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: const Color(0xFFB8860B).withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFB8860B).withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Center(
                child: Text('🔒', style: TextStyle(fontSize: 20))),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Phase 1 — Display Only',
                  style: TextStyle(
                    fontFamily: 'CormorantGaramond',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFB8860B),
                  ),
                ),
                Text(
                  'Token economy launches in Phase 2 on Solana mainnet. '
                  'Your balances are tracked and will be honoured.',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.white.withValues(alpha: 0.4),
                    height: 1.5,
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

// ─── SHREEDA Token Card ──────────────────────────────────────────

class _ShreedaCard extends StatelessWidget {
  final double amount;
  final Animation<double> glow;
  final bool isDigital;

  const _ShreedaCard({
    required this.amount,
    required this.glow,
    required this.isDigital,
  });

  @override
  Widget build(BuildContext context) {
    const color = Color(0xFF9b59b6);
    return AnimatedBuilder(
      animation: glow,
      builder: (_, __) => Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1a0a2e),
              Color(0xFF0d0820),
              Color(0xFF08041a)
            ],
          ),
          border: Border.all(color: color.withValues(alpha: 0.5)),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: glow.value * 0.2),
              blurRadius: 20,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: color.withValues(alpha: 0.3))),
                    child: const Center(
                      child: Text('SD',
                          style: TextStyle(
                              color: Color(0xFFc39bd3),
                              fontWeight: FontWeight.w800,
                              fontSize: 13,
                              fontFamily: 'CormorantGaramond')),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('SHREEDA',
                          style: TextStyle(
                              color: Color(0xFFc39bd3),
                              fontFamily: 'CormorantGaramond',
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 2)),
                      Text('Parent Token · Tradeable',
                          style: TextStyle(
                              color: color.withValues(alpha: 0.6),
                              fontSize: 11)),
                    ],
                  ),
                  const Spacer(),
                  Icon(Icons.lock_outline,
                      color: color.withValues(alpha: 0.4), size: 18),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                amount == 0 ? '0' : amount.toStringAsFixed(0),
                style: TextStyle(
                  color: const Color(0xFFc39bd3),
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                  fontFamily: 'CormorantGaramond',
                  shadows: [
                    Shadow(
                        color: color.withValues(alpha: glow.value * 0.4),
                        blurRadius: 12)
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Container(
                height: 1,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [
                    Colors.transparent,
                    color.withValues(alpha: 0.3),
                    Colors.transparent,
                  ]),
                ),
              ),
              const SizedBox(height: 10),
              _FactRow('Supply', '21,000,000,000', color),
              _FactRow('Network', 'Solana', color),
              _FactRow('Listed on', 'Raydium · Jupiter', color),
              _FactRow('Launch price', '~\$0.00006', color),
              _FactRow('Can be broken', 'Releases SHREE + DA', color),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── SHREE Token Card ────────────────────────────────────────────

class _ShreeCard extends StatelessWidget {
  final double amount;
  final bool isDigital;
  const _ShreeCard({required this.amount, required this.isDigital});

  @override
  Widget build(BuildContext context) {
    const color = Color(0xFFB8860B);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1a1200), Color(0xFF080600)],
        ),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    shape: BoxShape.circle),
                child: const Center(
                  child: Text('S',
                      style: TextStyle(
                          color: Color(0xFFFFD700),
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                          fontFamily: 'CormorantGaramond')),
                ),
              ),
              const SizedBox(width: 8),
              const Text('SHREE',
                  style: TextStyle(
                      color: Color(0xFFFFD700),
                      fontFamily: 'CormorantGaramond',
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1)),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            amount == 0 ? '0' : amount.toStringAsFixed(0),
            style: const TextStyle(
                color: Color(0xFFFFD700),
                fontSize: 28,
                fontWeight: FontWeight.w800,
                fontFamily: 'CormorantGaramond'),
          ),
          const SizedBox(height: 6),
          Text('Platform Currency\nFor You 🔒',
              style: TextStyle(
                  color: color.withValues(alpha: 0.6),
                  fontSize: 10,
                  height: 1.5)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: color.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(8),
                border:
                    Border.all(color: color.withValues(alpha: 0.15))),
            child: Text('Unlock: Donate or burn DA (1:1)',
                style: TextStyle(
                    color: color.withValues(alpha: 0.7), fontSize: 9)),
          ),
          const SizedBox(height: 4),
          Text('10B supply · 5B in reserve',
              style: TextStyle(
                  color: color.withValues(alpha: 0.4), fontSize: 9)),
        ],
      ),
    );
  }
}

// ─── DA Token Card ───────────────────────────────────────────────

class _DaCard extends StatelessWidget {
  final double amount;
  final bool isDigital;
  const _DaCard({required this.amount, required this.isDigital});

  @override
  Widget build(BuildContext context) {
    const color = Color(0xFF27ae60);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0a2218), Color(0xFF040f08)],
        ),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    shape: BoxShape.circle),
                child: const Center(
                  child: Text('DA',
                      style: TextStyle(
                          color: Color(0xFF2ecc71),
                          fontWeight: FontWeight.w800,
                          fontSize: 11,
                          fontFamily: 'CormorantGaramond')),
                ),
              ),
              const SizedBox(width: 8),
              const Text('DA',
                  style: TextStyle(
                      color: Color(0xFF2ecc71),
                      fontFamily: 'CormorantGaramond',
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1)),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            amount == 0 ? '0' : amount.toStringAsFixed(0),
            style: const TextStyle(
                color: Color(0xFF2ecc71),
                fontSize: 28,
                fontWeight: FontWeight.w800,
                fontFamily: 'CormorantGaramond'),
          ),
          const SizedBox(height: 6),
          Text('Charity Currency\nFor Others ♻',
              style: TextStyle(
                  color: color.withValues(alpha: 0.6),
                  fontSize: 10,
                  height: 1.5)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: color.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(8),
                border:
                    Border.all(color: color.withValues(alpha: 0.15))),
            child: Text('Donate → unlocks SHREE ♻\nBurn → unlocks SHREE 🔥',
                style: TextStyle(
                    color: color.withValues(alpha: 0.7),
                    fontSize: 9,
                    height: 1.4)),
          ),
          const SizedBox(height: 4),
          Text('10B supply · 5B in reserve',
              style: TextStyle(
                  color: color.withValues(alpha: 0.4), fontSize: 9)),
        ],
      ),
    );
  }
}

// ─── Fact Row ────────────────────────────────────────────────────

class _FactRow extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _FactRow(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Text(label,
              style: TextStyle(
                  color: color.withValues(alpha: 0.5), fontSize: 11)),
          const Spacer(),
          Text(value,
              style: TextStyle(
                  color: color.withValues(alpha: 0.8),
                  fontSize: 11,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

// ─── Token Mechanics ─────────────────────────────────────────────

class _TokenMechanics extends StatelessWidget {
  final bool isDigital;
  const _TokenMechanics({required this.isDigital});

  @override
  Widget build(BuildContext context) {
    return _Section(
      title: 'How It Works',
      emoji: '⚙️',
      isDigital: isDigital,
      child: Column(
        children: [
          _MechanicRow(
            step: '1',
            text: 'You earn SHREEDA through competitions & platform activities',
            color: const Color(0xFF9b59b6),
          ),
          _MechanicRow(
            step: '2',
            text: 'SHREE always arrives LOCKED — zero utility alone',
            color: const Color(0xFFB8860B),
          ),
          _MechanicRow(
            step: '3',
            text: 'DA arrives FREE — immediately usable for charity',
            color: const Color(0xFF27ae60),
          ),
          _MechanicRow(
            step: '4',
            text: 'Donate your DA → unlocks SHREE 1:1 + DA recirculates ♻',
            color: const Color(0xFF27ae60),
          ),
          _MechanicRow(
            step: '5',
            text: 'OR burn DA → unlocks SHREE 1:1 + DA destroyed forever 🔥',
            color: const Color(0xFFe74c3c),
          ),
          _MechanicRow(
            step: '6',
            text:
                'Spend SHREE on marketplace · Convert to SHREEDA for bank',
            color: const Color(0xFFB8860B),
          ),
        ],
      ),
    );
  }
}

class _MechanicRow extends StatelessWidget {
  final String step;
  final String text;
  final Color color;
  const _MechanicRow(
      {required this.step, required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
                border:
                    Border.all(color: color.withValues(alpha: 0.3))),
            child: Center(
                child: Text(step,
                    style: TextStyle(
                        color: color,
                        fontSize: 11,
                        fontWeight: FontWeight.w700))),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text,
                style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 12,
                    height: 1.5)),
          ),
        ],
      ),
    );
  }
}

// ─── Supply Distribution ─────────────────────────────────────────

class _SupplySection extends StatelessWidget {
  final bool isDigital;
  const _SupplySection({required this.isDigital});

  static const _items = [
    _SupplyItem('Broken at genesis → SHREE+DA', 10000000000.0,
        Color(0xFFe74c3c), 47.6),
    _SupplyItem('Competition Rewards (40%)', 4000000000.0,
        Color(0xFFB8860B), 19.0),
    _SupplyItem(
        'Operations / Treasury (18%)', 1800000000.0, Color(0xFF3498db), 8.6),
    _SupplyItem(
        'Founder — Gaurav (12%)', 1200000000.0, Color(0xFFD4A017), 5.7),
    _SupplyItem('Liquidity Pool — Locked (10%)', 1000000000.0,
        Color(0xFF9b59b6), 4.8),
    _SupplyItem('NFT Allocation All Tiers', 1000000000.0,
        Color(0xFFe056a0), 4.8),
    _SupplyItem('Partners / Investors (8%)', 800000000.0,
        Color(0xFFe67e22), 3.8),
    _SupplyItem('Staking + Marketing + Insurance', 1200000000.0,
        Color(0xFF48c9b0), 5.7),
  ];

  @override
  Widget build(BuildContext context) {
    return _Section(
      title: 'Supply Distribution — 21B Total',
      emoji: '📊',
      isDigital: isDigital,
      child: Column(
        children: _items
            .map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(item.label,
                                style: TextStyle(
                                    color: item.color,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600)),
                          ),
                          Text(_fmt(item.amount),
                              style: TextStyle(
                                  color: item.color.withValues(alpha: 0.7),
                                  fontSize: 10,
                                  fontFamily: 'CormorantGaramond')),
                        ],
                      ),
                      const SizedBox(height: 4),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: item.pct / 100,
                          minHeight: 6,
                          backgroundColor:
                              item.color.withValues(alpha: 0.1),
                          valueColor:
                              AlwaysStoppedAnimation(item.color),
                        ),
                      ),
                    ],
                  ),
                ))
            .toList(),
      ),
    );
  }

  static String _fmt(double n) {
    if (n >= 1000000000) {
      return '${(n / 1000000000).toStringAsFixed(1)}B';
    }
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(0)}M';
    return n.toStringAsFixed(0);
  }
}

class _SupplyItem {
  final String label;
  final double amount;
  final Color color;
  final double pct;
  const _SupplyItem(this.label, this.amount, this.color, this.pct);
}

// ─── Competition Rewards ─────────────────────────────────────────

class _CompetitionRewards extends StatelessWidget {
  final bool isDigital;
  const _CompetitionRewards({required this.isDigital});

  @override
  Widget build(BuildContext context) {
    return _Section(
      title: 'Competition Rewards',
      emoji: '🏆',
      isDigital: isDigital,
      child: Column(
        children: [
          const _RewardRow(
              pos: 'Every Entry (Yr 1–2)', shree: '10', da: '10'),
          const _RewardRow(
              pos: '🥇 1st Place',
              shree: '180,000',
              da: '180,000',
              shreeda: '150,000'),
          const _RewardRow(
              pos: '🥈 2nd–10th (each)',
              shree: '33,333',
              da: '33,333',
              shreeda: '27,777'),
          const _RewardRow(
              pos: '🥉 11th–50th (each)',
              shree: '3,000',
              da: '3,000'),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF9b59b6).withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFF9b59b6).withValues(alpha: 0.25)),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('✦ ', style: TextStyle(color: Color(0xFF9b59b6), fontSize: 12)),
                Expanded(
                  child: Text(
                    'SHREEDA is never freely distributed — it can only be earned through sustained excellence across multiple competitions.',
                    style: TextStyle(color: Color(0xFF9b59b6), fontSize: 11, height: 1.5),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: Colors.white.withValues(alpha: 0.06)),
            ),
            child: const Column(
              children: [
                _TimelineItem('1st', 'Competition opens — posts accepted',
                    Color(0xFFB8860B)),
                _TimelineItem('25th',
                    'HARD CUTOFF — no exceptions', Color(0xFFe74c3c)),
                _TimelineItem('~30th',
                    'Results declared — winners announced', Color(0xFF27ae60)),
                _TimelineItem('1st',
                    'New cycle begins — fresh competition', Color(0xFF9b59b6)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RewardRow extends StatelessWidget {
  final String pos;
  final String shree;
  final String da;
  final String? shreeda;
  const _RewardRow(
      {required this.pos,
      required this.shree,
      required this.da,
      this.shreeda});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(pos,
              style: const TextStyle(color: Colors.white54, fontSize: 12)),
          const SizedBox(height: 4),
          Wrap(
            spacing: 6,
            children: [
              _Badge('$shree SHREE', const Color(0xFFB8860B)),
              _Badge('$da DA', const Color(0xFF27ae60)),
              if (shreeda != null)
                _Badge('$shreeda SHREEDA', const Color(0xFF9b59b6)),
            ],
          ),
          const Divider(color: Colors.white10, height: 16),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String text;
  final Color color;
  const _Badge(this.text, this.color);

  @override
  Widget build(BuildContext context) => Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: color.withValues(alpha: 0.25))),
        child: Text(text,
            style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: FontWeight.w600,
                fontFamily: 'CormorantGaramond')),
      );
}

class _TimelineItem extends StatelessWidget {
  final String day;
  final String text;
  final Color color;
  const _TimelineItem(this.day, this.text, this.color);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withValues(alpha: 0.12),
                border: Border.all(color: color.withValues(alpha: 0.3))),
            child: Center(
              child: Text(day,
                  style: TextStyle(
                      color: color,
                      fontSize: 8,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'CormorantGaramond')),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text,
                style: TextStyle(
                    color: color.withValues(alpha: 0.8), fontSize: 11)),
          ),
        ],
      ),
    );
  }
}

// ─── NFT Tiers ───────────────────────────────────────────────────

class _NftTiers extends StatelessWidget {
  final bool isDigital;
  const _NftTiers({required this.isDigital});

  static const _tiers = [
    _NftTier('👑', 'OWNERSHIP', '1 Only', 'Not For Sale',
        Color(0xFFFFD700), 'SUPREME', [
      'Single vote overrides all',
      '10% gross revenue',
      'Emergency freeze power',
      'Cannot be transferred',
    ]),
    _NftTier('⭐', 'STAR', '2 Only', '₹10,00,000', Color(0xFFD4A017),
        'SENATE', [
      'Bipartisan veto power',
      '3% gross revenue each',
      '50M SHREEDA (12m lock)',
      'Buyback at 2 years',
    ]),
    _NftTier('💎', 'DIAMOND', '3 Only', '₹3,00,000', Color(0xFF7b9ed9),
        'COUNCIL', [
      'Charity wallet after yr 2',
      '2% gross (split 3 ways)',
      '30M SHREEDA (6m lock)',
      'Buyback at 2 years',
    ]),
    _NftTier('🥇', 'GOLD', '6 Only', '₹1,00,000', Color(0xFFB8860B),
        'PARLIAMENT', [
      'Standard voting rights',
      '1% gross (split 6 ways)',
      '15M SHREEDA (6m lock)',
      'Buyback at 2 years',
    ]),
    _NftTier('🥈', 'SILVER', '9 Only', '₹50,000', Color(0xFF888888),
        'CITIZEN', [
      'Standard voting rights',
      '0.5% gross (split 9 ways)',
      '5M SHREEDA (6m lock)',
      'No buyback guarantee',
    ]),
  ];

  @override
  Widget build(BuildContext context) {
    return _Section(
      title: 'Founder NFTs — 21 Total',
      emoji: '🎖️',
      isDigital: isDigital,
      child: Column(
        children: [
          const Text(
            '5 Tiers · ₹39.5 Lakh Target · Governance + Revenue',
            style: TextStyle(
                color: Colors.white38,
                fontSize: 11,
                fontStyle: FontStyle.italic),
          ),
          const SizedBox(height: 14),
          ..._tiers.map((tier) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    color: tier.color.withValues(alpha: 0.05),
                    border: Border.all(
                        color: tier.color.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        children: [
                          Text(tier.icon,
                              style: const TextStyle(fontSize: 24)),
                          const SizedBox(height: 4),
                          Text(tier.tier,
                              style: TextStyle(
                                  color: tier.color,
                                  fontSize: 7,
                                  letterSpacing: 1,
                                  fontWeight: FontWeight.w600)),
                        ],
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(tier.name,
                                    style: TextStyle(
                                        color: tier.color,
                                        fontFamily: 'CormorantGaramond',
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700)),
                                const Spacer(),
                                Text(tier.count,
                                    style: TextStyle(
                                        color: tier.color
                                            .withValues(alpha: 0.6),
                                        fontSize: 11)),
                              ],
                            ),
                            Text(tier.price,
                                style: TextStyle(
                                    color: tier.color,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    fontFamily: 'CormorantGaramond')),
                            const SizedBox(height: 6),
                            ...tier.benefits.map((b) => Padding(
                                  padding:
                                      const EdgeInsets.only(bottom: 2),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text('→ ',
                                          style: TextStyle(
                                              color: tier.color
                                                  .withValues(alpha: 0.4),
                                              fontSize: 10)),
                                      Expanded(
                                          child: Text(b,
                                              style: const TextStyle(
                                                  color: Colors.white38,
                                                  fontSize: 10))),
                                    ],
                                  ),
                                )),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              )),
        ],
      ),
    );
  }
}

class _NftTier {
  final String icon, name, count, price, tier;
  final Color color;
  final List<String> benefits;
  const _NftTier(this.icon, this.name, this.count, this.price,
      this.color, this.tier, this.benefits);
}

// ─── Burn Mechanics ──────────────────────────────────────────────

class _BurnMechanics extends StatelessWidget {
  final bool isDigital;
  const _BurnMechanics({required this.isDigital});

  @override
  Widget build(BuildContext context) {
    return _Section(
      title: 'Burn Mechanics',
      emoji: '🔥',
      isDigital: isDigital,
      child: Column(
        children: [
          const _BurnRow('SHREEDA 🔥', 'Permanently destroyed',
              'SHREEDA price rises · All holders benefit',
              Color(0xFFe74c3c)),
          const SizedBox(height: 8),
          const _BurnRow('SHREE 🔥', 'Permanently destroyed',
              'SHREE price rises · All holders benefit',
              Color(0xFFB8860B)),
          const SizedBox(height: 8),
          const _BurnRow('DA 🔥', 'Permanently destroyed',
              'SHREE unlocks (1:1) + DA price rises',
              Color(0xFF27ae60)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
                color: const Color(0xFFe74c3c).withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color:
                        const Color(0xFFe74c3c).withValues(alpha: 0.1))),
            child: const Text(
              'Platform never forces burns. No scheduled burn events. '
              'User choice only. Honest selfish act — '
              'no one receives the key but the lock still opens.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.white30,
                  fontSize: 11,
                  fontStyle: FontStyle.italic,
                  height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}

class _BurnRow extends StatelessWidget {
  final String token, effect, benefit;
  final Color color;
  const _BurnRow(this.token, this.effect, this.benefit, this.color);

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
            color: color.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: color.withValues(alpha: 0.2))),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(token,
                style: TextStyle(
                    color: color,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'CormorantGaramond')),
            Text(effect,
                style: TextStyle(
                    color: color.withValues(alpha: 0.6),
                    fontSize: 11,
                    fontStyle: FontStyle.italic)),
            const SizedBox(height: 2),
            Text(benefit,
                style: const TextStyle(
                    color: Color(0xFF27ae60), fontSize: 11)),
          ],
        ),
      );
}

// ─── Governance Pyramid ──────────────────────────────────────────

class _GovernancePyramid extends StatelessWidget {
  final bool isDigital;
  const _GovernancePyramid({required this.isDigital});

  static const _tiers = [
    _GovTier(
        '👑 FOUNDER — OWNERSHIP NFT',
        'Single vote overrides all · Rarely intervenes · Protection only',
        Color(0xFFFFD700),
        1.0),
    _GovTier(
        '⭐ STAR NFT HOLDERS (2)',
        'Bipartisan veto · Both must agree · Neither alone has power',
        Color(0xFFD4A017),
        0.85),
    _GovTier(
        '⚙️ TEAM + PARTNERS + INVESTORS',
        'Operational decisions · Policy voting · Day-to-day approvals',
        Color(0xFF3498db),
        0.70),
    _GovTier(
        '🏅 NFT HOLDERS + COMPETITION WINNERS',
        'Policy and platform voting · 1 person = 1 vote · Merit earned',
        Color(0xFF9b59b6),
        0.55),
    _GovTier(
        '🛡️ COMMUNITY MODERATORS',
        'Elected annually · First-level charity review · Community trusted',
        Color(0xFF27ae60),
        0.40),
    _GovTier(
        '👥 REGULAR USERS',
        'Compete · Earn · Give · Earn your way up the pyramid',
        Color(0xFF555555),
        0.25),
  ];

  @override
  Widget build(BuildContext context) {
    return _Section(
      title: 'Governance Pyramid',
      emoji: '🏛️',
      isDigital: isDigital,
      child: Column(
        children: [
          ..._tiers.map((t) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: FractionallySizedBox(
                  widthFactor: t.width,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                        color: t.color.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: t.color.withValues(alpha: 0.25))),
                    child: Column(
                      children: [
                        Text(t.role,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: t.color,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5)),
                        const SizedBox(height: 3),
                        Text(t.power,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: t.color.withValues(alpha: 0.55),
                                fontSize: 9,
                                fontStyle: FontStyle.italic)),
                      ],
                    ),
                  ),
                ),
              )),
          const SizedBox(height: 14),
          Row(
            children: [
              _PhaseCard('YEAR 1',
                  'Founder leads alone. All decisions transparent.',
                  const Color(0xFFB8860B)),
              const SizedBox(width: 8),
              _PhaseCard('YEAR 2–3',
                  'Hybrid model. NFT holders + winners vote.',
                  const Color(0xFF3498db)),
              const SizedBox(width: 8),
              _PhaseCard('YEAR 4+',
                  'DAO day-to-day. Founder veto for protection only.',
                  const Color(0xFF27ae60)),
            ],
          ),
        ],
      ),
    );
  }
}

class _GovTier {
  final String role, power;
  final Color color;
  final double width;
  const _GovTier(this.role, this.power, this.color, this.width);
}

class _PhaseCard extends StatelessWidget {
  final String phase, desc;
  final Color color;
  const _PhaseCard(this.phase, this.desc, this.color);

  @override
  Widget build(BuildContext context) => Expanded(
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: color.withValues(alpha: 0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(phase,
                  style: TextStyle(
                      color: color,
                      fontSize: 10,
                      letterSpacing: 1,
                      fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text(desc,
                  style: TextStyle(
                      color: color.withValues(alpha: 0.55),
                      fontSize: 9,
                      height: 1.4)),
            ],
          ),
        ),
      );
}

// ─── Donate DA Section ───────────────────────────────────────────

class _DonateDaSection extends StatelessWidget {
  final bool isDigital;
  const _DonateDaSection({required this.isDigital});

  @override
  Widget build(BuildContext context) {
    final activePools =
        DummyData.dummyPools.where((p) => p.isActive).take(2).toList();

    return _Section(
      title: 'Donate Your DA',
      emoji: '💚',
      isDigital: isDigital,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Every DA donated unlocks your SHREE and recirculates for more good.',
            style: TextStyle(
                color: Colors.white.withValues(alpha: 0.4),
                fontSize: 12,
                height: 1.5),
          ),
          const SizedBox(height: 12),
          ...activePools.map((pool) {
            final pct = (pool.raisedDA / pool.targetDA).clamp(0.0, 1.0);
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF27ae60).withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                      color:
                          const Color(0xFF27ae60).withValues(alpha: 0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(pool.title,
                              style: const TextStyle(
                                  color: Colors.white70,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                        ),
                        const SizedBox(width: 8),
                        Text('${(pct * 100).round()}%',
                            style: const TextStyle(
                                color: Color(0xFF2ecc71),
                                fontSize: 12,
                                fontWeight: FontWeight.w700)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: pct,
                        minHeight: 5,
                        backgroundColor:
                            const Color(0xFF27ae60).withValues(alpha: 0.12),
                        valueColor: const AlwaysStoppedAnimation(
                            Color(0xFF27ae60)),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          '${_fmt(pool.raisedDA)} / ${_fmt(pool.targetDA)} DA',
                          style: TextStyle(
                              fontSize: 11,
                              color: Colors.white.withValues(alpha: 0.35)),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: () =>
                              context.push('/groups/pool/${pool.id}'),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF27ae60)
                                  .withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                  color: const Color(0xFF27ae60)
                                      .withValues(alpha: 0.3)),
                            ),
                            child: const Text('Donate',
                                style: TextStyle(
                                    color: Color(0xFF2ecc71),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
          GestureDetector(
            onTap: () => context.push(RouteNames.groups),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.03),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: const Color(0xFF27ae60).withValues(alpha: 0.15)),
              ),
              child: const Text('View All Charity Pools →',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Color(0xFF27ae60),
                      fontSize: 13,
                      fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }

  String _fmt(double v) =>
      v >= 1000 ? '${(v / 1000).toStringAsFixed(1)}k' : v.toStringAsFixed(0);
}

// ─── Tagline ─────────────────────────────────────────────────────

class _Tagline extends StatelessWidget {
  final bool isDigital;
  const _Tagline({required this.isDigital});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0d0820), Color(0xFF040f08)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: const Color(0xFFB8860B).withValues(alpha: 0.15)),
      ),
      child: Column(
        children: [
          Text(
            '✿',
            style: TextStyle(
                fontSize: 22,
                color: const Color(0xFFB8860B).withValues(alpha: 0.5)),
          ),
          const SizedBox(height: 14),
          Text(
            '"Every rupee of charity is a key.\nEvery key opens a door.\nEvery door leads to growth."',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'CormorantGaramond',
              fontStyle: FontStyle.italic,
              fontSize: 15,
              color: Colors.white.withValues(alpha: 0.5),
              height: 1.8,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            '— SHREEDA Whitepaper',
            style: TextStyle(
              fontSize: 10,
              letterSpacing: 2,
              color: const Color(0xFFB8860B).withValues(alpha: 0.4),
            ),
          ),
        ],
      ),
    );
  }
}
