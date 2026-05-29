import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/dummy/dummy_data.dart';
import '../../../core/providers/theme_provider.dart';

class CharityPoolScreen extends StatefulWidget {
  final String poolId;
  const CharityPoolScreen({super.key, required this.poolId});

  @override
  State<CharityPoolScreen> createState() => _CharityPoolScreenState();
}

class _CharityPoolScreenState extends State<CharityPoolScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _progressCtrl;
  late Animation<double> _progressAnim;

  late double _raisedDA;
  double _daBalance = 245.5;

  final _customAmountCtrl = TextEditingController();
  double? _selectedAmount;
  bool _customSelected = false;

  static const _quickAmounts = [50.0, 100.0, 250.0];

  static const _donors = [
    ('Gaurav Bathia', 50.0, '2h ago'),
    ('Kavya Nair', 100.0, '1d ago'),
    ('Rohit Verma', 250.0, '2d ago'),
  ];

  CharityPoolModel get _pool =>
      DummyData.dummyPools.firstWhere((p) => p.id == widget.poolId);

  @override
  void initState() {
    super.initState();
    _raisedDA = _pool.raisedDA;
    final targetPct = (_raisedDA / _pool.targetDA).clamp(0.0, 1.0);

    _progressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _progressAnim = Tween<double>(begin: 0, end: targetPct).animate(
      CurvedAnimation(parent: _progressCtrl, curve: Curves.easeOutCubic),
    );

    Future.microtask(() => _progressCtrl.forward());
  }

  @override
  void dispose() {
    _progressCtrl.dispose();
    _customAmountCtrl.dispose();
    super.dispose();
  }

  int get _daysLeft {
    final diff = _pool.endDate.difference(DateTime.now()).inDays;
    return diff < 0 ? 0 : diff;
  }

  double? get _donateAmount {
    if (_customSelected) {
      return double.tryParse(_customAmountCtrl.text.trim());
    }
    return _selectedAmount;
  }

  void _showConfirmDialog(double amount) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Donation'),
        content: Text(
          'Donate ${amount.toStringAsFixed(0)} DA to "${_pool.title}"?\n\nThis cannot be undone.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.success),
            onPressed: () {
              Navigator.pop(ctx);
              _processDonation(amount);
            },
            child: const Text('Donate'),
          ),
        ],
      ),
    );
  }

  void _processDonation(double amount) {
    setState(() {
      _daBalance -= amount;
      _raisedDA += amount;

      final newPct = (_raisedDA / _pool.targetDA).clamp(0.0, 1.0);
      _progressCtrl.animateTo(newPct, duration: const Duration(milliseconds: 800));

      _selectedAmount = null;
      _customSelected = false;
      _customAmountCtrl.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Text('💚  ', style: TextStyle(fontSize: 16)),
            Expanded(child: Text('${amount.toStringAsFixed(0)} DA donated! Thank you.')),
          ],
        ),
        backgroundColor: AppColors.success,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  String _fmt(double v) =>
      v >= 1000 ? '${(v / 1000).toStringAsFixed(v % 1000 == 0 ? 0 : 1)}k' : v.toStringAsFixed(0);

  @override
  Widget build(BuildContext context) {
    final isDigital = context.watch<ThemeProvider>().isDigital;
    final pool = _pool;
    final pct = (_raisedDA / pool.targetDA).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: AppColors.bg(isDigital),
      appBar: AppBar(
        title: const Text('Charity Pool', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: AppSizes.md),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(100),
              border: Border.all(color: AppColors.success.withValues(alpha: 0.4)),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.circle, size: 7, color: AppColors.success),
                SizedBox(width: 5),
                Text('Active', style: TextStyle(fontSize: 12, color: AppColors.success, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          // ── Hero: circular progress ──────────────────────────────────
          _buildHero(pool, pct, isDigital),

          // ── Description card ─────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(AppSizes.md),
            child: Container(
              padding: const EdgeInsets.all(AppSizes.md),
              decoration: BoxDecoration(
                color: AppColors.adaptivePrimary(isDigital).withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                border: Border.all(color: AppColors.adaptivePrimary(isDigital).withValues(alpha: 0.15)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('About this Pool', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(height: 8),
                  Text(pool.description, style: TextStyle(fontSize: 14, height: 1.65, color: AppColors.textSubFor(isDigital))),
                ],
              ),
            ),
          ),

          // ── Impact section ────────────────────────────────────────────
          _buildImpactSection(isDigital),

          // ── Donate section ────────────────────────────────────────────
          _buildDonateSection(isDigital),

          // ── Donors section ────────────────────────────────────────────
          _buildDonorsSection(isDigital),

          const SizedBox(height: AppSizes.xl),
        ],
      ),
    );
  }

  // ── Hero ──────────────────────────────────────────────────────────────────

  Widget _buildHero(CharityPoolModel pool, double pct, bool isDigital) {
    return Container(
      color: AppColors.success.withValues(alpha: 0.04),
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        children: [
          Text(pool.title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, height: 1.3)),
          const SizedBox(height: 24),
          // Animated circular progress
          AnimatedBuilder(
            animation: _progressAnim,
            builder: (_, __) {
              final v = _progressAnim.value;
              return SizedBox(
                width: 180,
                height: 180,
                child: CustomPaint(
                  painter: _CircleProgressPainter(progress: v),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${(v * 100).round()}%',
                          style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: AppColors.success),
                        ),
                        Text('funded', style: TextStyle(fontSize: 13, color: AppColors.textSubFor(isDigital))),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          Text(
            '${_fmt(_raisedDA)} DA raised of ${_fmt(pool.targetDA)} DA goal',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            '$_daysLeft days remaining',
            style: TextStyle(fontSize: 13, color: AppColors.textSubFor(isDigital)),
          ),
        ],
      ),
    );
  }

  // ── Impact ────────────────────────────────────────────────────────────────

  Widget _buildImpactSection(bool isDigital) {
    return Padding(
      padding: const EdgeInsets.all(AppSizes.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('What Your DA Does', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: AppSizes.sm),
          Row(
            children: [
              _ImpactCard(amount: '100 DA', impact: 'Buys sketch materials for 2 children', isDigital: isDigital),
              const SizedBox(width: AppSizes.sm),
              _ImpactCard(amount: '500 DA', impact: 'Funds one month of art supplies', isDigital: isDigital),
              const SizedBox(width: AppSizes.sm),
              _ImpactCard(amount: '1k DA', impact: 'Equips an entire classroom', isDigital: isDigital),
            ],
          ),
        ],
      ),
    );
  }

  // ── Donate ────────────────────────────────────────────────────────────────

  Widget _buildDonateSection(bool isDigital) {
    final canDonate = _donateAmount != null &&
        _donateAmount! > 0 &&
        _donateAmount! <= _daBalance;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Donate Your DA', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 4),
          Text(
            'You have ${_daBalance.toStringAsFixed(1)} DA available',
            style: TextStyle(fontSize: 13, color: AppColors.textSubFor(isDigital)),
          ),
          const SizedBox(height: AppSizes.sm),
          // Quick amounts
          Row(
            children: [
              ..._quickAmounts.map((amt) {
                final sel = !_customSelected && _selectedAmount == amt;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => setState(() {
                      _selectedAmount = amt;
                      _customSelected = false;
                      _customAmountCtrl.clear();
                    }),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                      decoration: BoxDecoration(
                        color: sel ? AppColors.success.withValues(alpha: 0.12) : Colors.transparent,
                        borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                        border: Border.all(
                          color: sel ? AppColors.success : AppColors.textSubFor(isDigital).withValues(alpha: 0.3),
                          width: sel ? 1.5 : 1,
                        ),
                      ),
                      child: Text(
                        '${amt.toInt()} DA',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: sel ? FontWeight.w700 : FontWeight.normal,
                          color: sel ? AppColors.success : AppColors.textSubFor(isDigital),
                        ),
                      ),
                    ),
                  ),
                );
              }),
              // Custom
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() {
                    _customSelected = true;
                    _selectedAmount = null;
                  }),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _customSelected ? AppColors.success.withValues(alpha: 0.12) : Colors.transparent,
                      borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                      border: Border.all(
                        color: _customSelected ? AppColors.success : AppColors.textSubFor(isDigital).withValues(alpha: 0.3),
                        width: _customSelected ? 1.5 : 1,
                      ),
                    ),
                    child: Text(
                      'Custom',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: _customSelected ? FontWeight.w700 : FontWeight.normal,
                        color: _customSelected ? AppColors.success : AppColors.textSubFor(isDigital),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (_customSelected) ...[
            const SizedBox(height: AppSizes.sm),
            TextField(
              controller: _customAmountCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: false),
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                hintText: 'Enter amount in DA',
                border: OutlineInputBorder(),
                suffixText: 'DA',
                contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              ),
            ),
          ],
          const SizedBox(height: AppSizes.md),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: canDonate ? () => _showConfirmDialog(_donateAmount!) : null,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.success,
                minimumSize: const Size.fromHeight(48),
                disabledBackgroundColor: AppColors.success.withValues(alpha: 0.3),
              ),
              icon: const Icon(Icons.volunteer_activism, size: 18),
              label: Text(
                canDonate
                    ? 'Donate ${_donateAmount!.toStringAsFixed(0)} DA Now'
                    : 'Donate Now',
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
              ),
            ),
          ),
          const SizedBox(height: AppSizes.md),
          const Divider(),
        ],
      ),
    );
  }

  // ── Donors ────────────────────────────────────────────────────────────────

  Widget _buildDonorsSection(bool isDigital) {
    return Padding(
      padding: const EdgeInsets.all(AppSizes.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Recent Donors', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: AppSizes.sm),
          for (final d in _donors)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSizes.sm),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      d.$1[0].toUpperCase(),
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.success),
                    ),
                  ),
                  const SizedBox(width: AppSizes.sm),
                  Expanded(child: Text(d.$1, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14))),
                  Text(
                    '${d.$2.toInt()} DA',
                    style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.success, fontSize: 13),
                  ),
                  const SizedBox(width: AppSizes.sm),
                  Text(d.$3, style: TextStyle(fontSize: 12, color: AppColors.textSubFor(isDigital))),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// ── Impact Card ───────────────────────────────────────────────────────────────

class _ImpactCard extends StatelessWidget {
  final String amount;
  final String impact;
  final bool isDigital;
  const _ImpactCard({required this.amount, required this.impact, required this.isDigital});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.success.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          border: Border.all(color: AppColors.success.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Text(amount, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.success)),
            const SizedBox(height: 4),
            Text(impact, textAlign: TextAlign.center, style: TextStyle(fontSize: 11, color: AppColors.textSubFor(isDigital), height: 1.4)),
          ],
        ),
      ),
    );
  }
}

// ── Circular Progress Painter ─────────────────────────────────────────────────

class _CircleProgressPainter extends CustomPainter {
  final double progress;
  const _CircleProgressPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    const strokeWidth = 12.0;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    const startAngle = -math.pi / 2;

    // Track
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = AppColors.success.withValues(alpha: 0.12)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth,
    );

    // Progress arc
    if (progress > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        2 * math.pi * progress,
        false,
        Paint()
          ..color = AppColors.success
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(_CircleProgressPainter old) => old.progress != progress;
}
