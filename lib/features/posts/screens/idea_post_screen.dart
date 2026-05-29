import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../config/route_names.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/providers/theme_provider.dart';
import '../../../features/auth/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class IdeaPostScreen extends StatefulWidget {
  const IdeaPostScreen({super.key});

  @override
  State<IdeaPostScreen> createState() => _IdeaPostScreenState();
}

class _IdeaPostScreenState extends State<IdeaPostScreen> {
  final _ideaCtrl = TextEditingController();
  String? _selectedIdentity;
  bool _isSubmitting = false;
  bool _submitted = false;

  @override
  void dispose() {
    _ideaCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_ideaCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please describe your idea first')),
      );
      return;
    }
    setState(() => _isSubmitting = true);
    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;
    setState(() {
      _isSubmitting = false;
      _submitted = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_submitted) return _SuccessScreen();

    final isDigital = context.watch<ThemeProvider>().isDigital;
    final primary = AppColors.adaptivePrimary(isDigital);
    final user = context.read<AuthProvider>().currentUser;
    if (user == null) return const SizedBox.shrink();

    return Scaffold(
      backgroundColor: AppColors.bg(isDigital),
      appBar: AppBar(
        backgroundColor: AppColors.bg(isDigital),
        title: Text('Share Your Idea 💡', style: TextStyle(color: AppColors.textFor(isDigital))),
        iconTheme: IconThemeData(color: AppColors.textFor(isDigital)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ───────────────────────────────────────────────────────
            Text(
              'Share Your Idea 💡',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textFor(isDigital)),
            ),
            const SizedBox(height: 4),
            Text(
              'Our team reviews every idea personally',
              style: TextStyle(color: AppColors.textSubFor(isDigital), fontSize: 14),
            ),

            const SizedBox(height: AppSizes.lg),

            // ── Idea text area ────────────────────────────────────────────────
            Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceColor(isDigital),
                borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                border: Border.all(color: isDigital ? AppColors.digBorder : AppColors.tradBorder),
              ),
              child: TextField(
                controller: _ideaCtrl,
                maxLines: 10,
                style: TextStyle(color: AppColors.textFor(isDigital)),
                decoration: InputDecoration(
                  hintText: 'Describe your idea in detail…',
                  hintStyle: TextStyle(color: AppColors.textSubFor(isDigital)),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(AppSizes.md),
                ),
              ),
            ),

            const SizedBox(height: AppSizes.lg),

            // ── Identity selector ─────────────────────────────────────────────
            Text('Which identity is this from?',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textFor(isDigital))),
            const SizedBox(height: AppSizes.sm),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: user.identityHashtags.map((id) {
                final sel = _selectedIdentity == id;
                return GestureDetector(
                  onTap: () => setState(() => _selectedIdentity = id),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: sel ? primary : Colors.transparent,
                      borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                      border: Border.all(color: primary.withValues(alpha: sel ? 1 : 0.5)),
                    ),
                    child: Text(
                      '#$id',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: sel ? AppColors.white : primary,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: AppSizes.lg),

            // ── Info card ─────────────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(AppSizes.md),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                border: Border.all(color: primary.withValues(alpha: 0.35)),
                color: primary.withValues(alpha: 0.06),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '📋 What happens next?',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: primary),
                  ),
                  const SizedBox(height: AppSizes.sm),
                  ...[
                    'Our team reviews your idea (2–5 days)',
                    'We contact you via email or call',
                    'If approved: your idea goes live with 💡 badge',
                    'If we need changes: we guide you',
                    'All ideas help us improve SECURE',
                  ].map((line) => Padding(
                    padding: const EdgeInsets.only(bottom: 5),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('• ', style: TextStyle(color: primary, fontWeight: FontWeight.bold)),
                        Expanded(
                            child: Text(line,
                                style: TextStyle(fontSize: 13, color: AppColors.textFor(isDigital)))),
                      ],
                    ),
                  )),
                ],
              ),
            ),

            const SizedBox(height: AppSizes.lg),

            // ── Submit ────────────────────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _isSubmitting ? null : _submit,
                style: FilledButton.styleFrom(backgroundColor: primary),
                child: _isSubmitting
                    ? const SizedBox(
                        height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Submit Idea'),
              ),
            ),

            const SizedBox(height: AppSizes.xl),
          ],
        ),
      ),
    );
  }
}

// ─── Success Screen ────────────────────────────────────────────────────────────

class _SuccessScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDigital = context.watch<ThemeProvider>().isDigital;
    final primary = AppColors.adaptivePrimary(isDigital);
    return Scaffold(
      backgroundColor: AppColors.bg(isDigital),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const Text('💡', style: TextStyle(fontSize: 52)),
              ),
              const SizedBox(height: AppSizes.lg),
              Text(
                'Idea Submitted!',
                style: TextStyle(
                    fontSize: 26, fontWeight: FontWeight.bold, color: AppColors.textFor(isDigital)),
              ),
              const SizedBox(height: AppSizes.sm),
              Text(
                "We'll review and contact you within 2–5 days",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, color: AppColors.textSubFor(isDigital)),
              ),
              const SizedBox(height: AppSizes.md),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.md, vertical: AppSizes.sm),
                decoration: BoxDecoration(
                  color: primary.withValues(alpha: 0.07),
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                ),
                child: Text(
                  'Track status in your Profile → My Ideas',
                  style: TextStyle(fontSize: 13, color: primary, fontWeight: FontWeight.w500),
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => context.go(RouteNames.home),
                  style: FilledButton.styleFrom(backgroundColor: primary),
                  child: const Text('Back to Feed'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
