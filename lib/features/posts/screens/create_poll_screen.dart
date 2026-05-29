import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../config/route_names.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/dummy/dummy_data.dart';
import '../../../core/providers/theme_provider.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../../models/hashtag_model.dart';
import 'package:provider/provider.dart';

class CreatePollScreen extends StatefulWidget {
  const CreatePollScreen({super.key});

  @override
  State<CreatePollScreen> createState() => _CreatePollScreenState();
}

class _CreatePollScreenState extends State<CreatePollScreen> {
  final _questionCtrl = TextEditingController();
  final List<TextEditingController> _optionCtrls = [
    TextEditingController(),
    TextEditingController(),
  ];

  String? _selectedIdentity;
  String? _selectedHashtag;
  String _hashtagQuery = '';
  final _hashtagSearchCtrl = TextEditingController();
  bool _allowComments = true;
  bool _isCreating = false;

  @override
  void dispose() {
    _questionCtrl.dispose();
    for (final c in _optionCtrls) {
      c.dispose();
    }
    _hashtagSearchCtrl.dispose();
    super.dispose();
  }

  void _addOption() {
    if (_optionCtrls.length >= 4) return;
    setState(() => _optionCtrls.add(TextEditingController()));
  }

  void _removeOption(int i) {
    if (_optionCtrls.length <= 2) return;
    setState(() {
      _optionCtrls[i].dispose();
      _optionCtrls.removeAt(i);
    });
  }

  List<HashtagModel> get _filteredHashtags {
    if (_hashtagQuery.isEmpty) return DummyData.dummyHashtags;
    return DummyData.dummyHashtags.where((h) => h.name.contains(_hashtagQuery.toLowerCase())).toList();
  }

  Future<void> _createPoll() async {
    if (_questionCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a question')));
      return;
    }
    setState(() => _isCreating = true);
    await Future.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;
    setState(() => _isCreating = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(children: [
          Icon(Icons.check_circle, color: Colors.white),
          SizedBox(width: 8),
          Text('Poll created! ✓'),
        ]),
      ),
    );
    context.go(RouteNames.home);
  }

  @override
  Widget build(BuildContext context) {
    final isDigital = context.watch<ThemeProvider>().isDigital;
    final primary = AppColors.adaptivePrimary(isDigital);
    final user = context.read<AuthProvider>().currentUser;
    if (user == null) return const SizedBox.shrink();
    final traditional = _filteredHashtags.where((h) => h.category == 'traditional').toList();
    final digital = _filteredHashtags.where((h) => h.category == 'digital').toList();

    return Scaffold(
      backgroundColor: AppColors.bg(isDigital),
      appBar: AppBar(
        backgroundColor: AppColors.bg(isDigital),
        title: Text('Create Poll', style: TextStyle(color: AppColors.textFor(isDigital))),
        iconTheme: IconThemeData(color: AppColors.textFor(isDigital)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Question ─────────────────────────────────────────────────────
            Text('Your question',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textFor(isDigital))),
            const SizedBox(height: AppSizes.sm),
            TextField(
              controller: _questionCtrl,
              maxLines: 3,
              style: TextStyle(color: AppColors.textFor(isDigital)),
              decoration: InputDecoration(
                hintText: 'Ask a question…',
                hintStyle: TextStyle(color: AppColors.textSubFor(isDigital)),
                filled: true,
                fillColor: AppColors.surfaceColor(isDigital),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.all(AppSizes.md),
              ),
            ),

            const SizedBox(height: AppSizes.lg),

            // ── Options ──────────────────────────────────────────────────────
            Text('Options',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textFor(isDigital))),
            const SizedBox(height: AppSizes.sm),
            ...List.generate(_optionCtrls.length, (i) => Padding(
              padding: const EdgeInsets.only(bottom: AppSizes.sm),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _optionCtrls[i],
                      style: TextStyle(color: AppColors.textFor(isDigital)),
                      decoration: InputDecoration(
                        hintText: 'Option ${i + 1}',
                        hintStyle: TextStyle(color: AppColors.textSubFor(isDigital)),
                        filled: true,
                        fillColor: AppColors.surfaceColor(isDigital),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: AppSizes.md, vertical: 12),
                      ),
                    ),
                  ),
                  if (_optionCtrls.length > 2) ...[
                    const SizedBox(width: 8),
                    IconButton(
                      icon: Icon(Icons.remove_circle_outline, color: Colors.red.shade300),
                      onPressed: () => _removeOption(i),
                    ),
                  ],
                ],
              ),
            )),

            if (_optionCtrls.length < 4)
              TextButton.icon(
                onPressed: _addOption,
                icon: Icon(Icons.add, size: 18, color: primary),
                label: Text('Add Option', style: TextStyle(color: primary)),
              ),

            const SizedBox(height: AppSizes.lg),
            Divider(color: isDigital ? AppColors.digBorder : AppColors.tradBorder),
            const SizedBox(height: AppSizes.md),

            // ── Identity ─────────────────────────────────────────────────────
            Text('Post as identity',
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
                    child: Text('#$id',
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            color: sel ? AppColors.white : primary)),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: AppSizes.lg),

            // ── Hashtag ──────────────────────────────────────────────────────
            Text('Category hashtag',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textFor(isDigital))),
            const SizedBox(height: AppSizes.sm),
            TextField(
              controller: _hashtagSearchCtrl,
              onChanged: (v) => setState(() => _hashtagQuery = v.trim()),
              style: TextStyle(color: AppColors.textFor(isDigital)),
              decoration: InputDecoration(
                hintText: 'Search hashtags…',
                hintStyle: TextStyle(color: AppColors.textSubFor(isDigital)),
                prefixIcon: Icon(Icons.tag, size: 18, color: AppColors.textSubFor(isDigital)),
                filled: true,
                fillColor: AppColors.surfaceColor(isDigital),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: AppSizes.md),
              ),
            ),
            const SizedBox(height: AppSizes.sm),

            if (traditional.isNotEmpty) ...[
              Text('🎨 Traditional',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.tradAccent)),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: traditional.map((h) {
                  final sel = _selectedHashtag == h.name;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedHashtag = h.name),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: sel ? AppColors.tradAccent.withValues(alpha: 0.15) : Colors.transparent,
                        borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                        border: Border.all(
                            color: sel ? AppColors.tradAccent : AppColors.tradAccent.withValues(alpha: 0.4)),
                      ),
                      child: Text('#${h.name}',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.tradAccent)),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: AppSizes.sm),
            ],

            if (digital.isNotEmpty) ...[
              Text('💻 Digital',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: primary)),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: digital.map((h) {
                  final sel = _selectedHashtag == h.name;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedHashtag = h.name),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: sel ? primary.withValues(alpha: 0.15) : Colors.transparent,
                        borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                        border: Border.all(color: sel ? primary : primary.withValues(alpha: 0.4)),
                      ),
                      child: Text('#${h.name}',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: primary)),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: AppSizes.sm),
            ],

            const SizedBox(height: AppSizes.md),
            Divider(color: isDigital ? AppColors.digBorder : AppColors.tradBorder),
            const SizedBox(height: AppSizes.md),

            // ── Comments ─────────────────────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Allow comments?',
                          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.textFor(isDigital))),
                      Text('Requires identity verification',
                          style: TextStyle(fontSize: 11, color: AppColors.textSubFor(isDigital))),
                    ],
                  ),
                ),
                Switch(
                  value: _allowComments,
                  onChanged: (v) => setState(() => _allowComments = v),
                  activeColor: primary,
                ),
              ],
            ),

            const SizedBox(height: AppSizes.lg),

            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _isCreating ? null : _createPoll,
                style: FilledButton.styleFrom(backgroundColor: primary),
                child: _isCreating
                    ? const SizedBox(
                        height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Create Poll'),
              ),
            ),

            const SizedBox(height: AppSizes.xl),
          ],
        ),
      ),
    );
  }
}
