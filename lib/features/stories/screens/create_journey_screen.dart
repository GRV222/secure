import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/providers/theme_provider.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../../models/journey_model.dart';
import '../../../services/firestore_service.dart';

class CreateJourneyScreen extends StatefulWidget {
  const CreateJourneyScreen({super.key});

  @override
  State<CreateJourneyScreen> createState() => _CreateJourneyScreenState();
}

class _CreateJourneyScreenState extends State<CreateJourneyScreen> {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _hashtagCtrl = TextEditingController();
  String _category = 'traditional';
  bool _isPosting = false;

  Future<void> _create() async {
    final title = _titleCtrl.text.trim();
    if (title.isEmpty) return;

    final user = context.read<AuthProvider>().currentUser;
    if (user == null) return;

    setState(() => _isPosting = true);

    try {
      final journey = JourneyModel(
        journeyId: '',
        uid: user.uid,
        title: title,
        description: _descCtrl.text.trim(),
        category: _category,
        hashtag: _hashtagCtrl.text.trim().replaceAll('#', ''),
        storyIds: [],
        dayCount: 0,
        startDate: DateTime.now(),
        lastUpdated: DateTime.now(),
        isActive: true,
      );

      await FirestoreService().createJourney(journey);
      if (mounted) context.pop();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to create journey. Try again.')),
        );
        setState(() => _isPosting = false);
      }
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _hashtagCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDigital = context.watch<ThemeProvider>().isDigital;
    final primary = AppColors.adaptivePrimary(isDigital);
    return Scaffold(
      backgroundColor: AppColors.bg(isDigital),
      appBar: AppBar(
        backgroundColor: AppColors.bg(isDigital),
        foregroundColor: AppColors.textFor(isDigital),
        title: Text('New Journey', style: TextStyle(color: AppColors.textFor(isDigital), fontWeight: FontWeight.bold)),
        actions: [
          TextButton(
            onPressed: _isPosting ? null : _create,
            child: _isPosting
                ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: primary))
                : Text(
                    'Create',
                    style: TextStyle(
                      color: _titleCtrl.text.trim().isEmpty ? AppColors.textSubFor(isDigital) : primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: primary.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.auto_stories_outlined, color: primary, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'A Journey is a multi-day work series. Link your daily stories to tell one ongoing story.',
                      style: TextStyle(color: primary, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            Text('Journey Title', style: TextStyle(color: AppColors.textSubFor(isDigital), fontSize: 13, fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            _InputField(
              controller: _titleCtrl,
              hint: 'e.g. My 30-Day Coding Challenge',
              maxLines: 1,
              maxLength: 80,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 20),

            Text('Description', style: TextStyle(color: AppColors.textSubFor(isDigital), fontSize: 13, fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            _InputField(
              controller: _descCtrl,
              hint: 'Describe what this journey is about...',
              maxLines: 4,
              maxLength: 300,
            ),
            const SizedBox(height: 20),

            Text('Category', style: TextStyle(color: AppColors.textSubFor(isDigital), fontSize: 13, fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            Row(
              children: [
                _CategoryChip(
                  label: '🎨 Traditional',
                  selected: _category == 'traditional',
                  onTap: () => setState(() => _category = 'traditional'),
                ),
                const SizedBox(width: 10),
                _CategoryChip(
                  label: '💻 Digital',
                  selected: _category == 'digital',
                  onTap: () => setState(() => _category = 'digital'),
                ),
              ],
            ),
            const SizedBox(height: 20),

            Text('Hashtag (optional)', style: TextStyle(color: AppColors.textSubFor(isDigital), fontSize: 13, fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceColor(isDigital).withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: isDigital ? AppColors.digBorder : AppColors.tradBorder),
              ),
              child: TextField(
                controller: _hashtagCtrl,
                style: TextStyle(color: AppColors.textFor(isDigital), fontSize: 14),
                decoration: InputDecoration(
                  hintText: '#hashtag',
                  hintStyle: TextStyle(color: AppColors.textSubFor(isDigital)),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  prefixIcon: Icon(Icons.tag, color: AppColors.textSubFor(isDigital), size: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final int maxLines;
  final int maxLength;
  final ValueChanged<String>? onChanged;
  const _InputField({
    required this.controller,
    required this.hint,
    required this.maxLines,
    required this.maxLength,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDigital = context.watch<ThemeProvider>().isDigital;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceColor(isDigital).withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDigital ? AppColors.digBorder : AppColors.tradBorder),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        maxLength: maxLength,
        style: TextStyle(color: AppColors.textFor(isDigital), fontSize: 15),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: AppColors.textSubFor(isDigital)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(14),
          counterStyle: TextStyle(color: AppColors.textSubFor(isDigital)),
        ),
        onChanged: onChanged,
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _CategoryChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDigital = context.watch<ThemeProvider>().isDigital;
    final primary = AppColors.adaptivePrimary(isDigital);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? primary.withValues(alpha: 0.2) : AppColors.surfaceColor(isDigital).withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? primary.withValues(alpha: 0.6) : (isDigital ? AppColors.digBorder : AppColors.tradBorder),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? primary : AppColors.textSubFor(isDigital),
            fontSize: 13,
            fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
