import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/dummy/dummy_data.dart';
import '../../../core/providers/theme_provider.dart';
import '../../../services/firestore_service.dart';
import '../../../features/auth/providers/auth_provider.dart';

class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _purposeCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String? _selectedIdentity;
  String _category = 'traditional';

  static final _identities = [
    ...DummyData.artisticIdentities,
    ...DummyData.professionalIdentities,
  ];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _purposeCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedIdentity == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an identity hashtag for this group.')),
      );
      return;
    }
    final uid = context.read<AuthProvider>().currentUser?.uid ?? 'user_001';
    final name = _nameCtrl.text.trim();
    try {
      await FirestoreService().createGroup(
        name: name,
        description: _descCtrl.text.trim(),
        identityHashtag: _selectedIdentity!,
        category: _category,
        createdBy: uid,
      );
    } catch (e) {
      debugPrint('createGroup error: $e');
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Group "$name" created! 🎉'),
        backgroundColor: AppColors.success,
      ),
    );
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final isDigital = context.watch<ThemeProvider>().isDigital;
    final primary = AppColors.adaptivePrimary(isDigital);
    return Scaffold(
      backgroundColor: AppColors.bg(isDigital),
      appBar: AppBar(
        title: const Text('Create a Group', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSizes.md),
          children: [
            // ── Group name ────────────────────────────────────────────────
            TextFormField(
              controller: _nameCtrl,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Group Name',
                hintText: 'e.g. Sketchers of India',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.group_outlined),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Group name is required';
                if (v.trim().length < 4) return 'Name must be at least 4 characters';
                return null;
              },
            ),
            const SizedBox(height: AppSizes.md),

            // ── Description ───────────────────────────────────────────────
            TextFormField(
              controller: _descCtrl,
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'What is this group about?',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Description is required';
                if (v.trim().length < 10) return 'Please write a fuller description';
                return null;
              },
            ),
            const SizedBox(height: AppSizes.lg),

            // ── Identity hashtag ──────────────────────────────────────────
            const Text('Identity Hashtag', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 4),
            Text(
              'Which identity field is this group for?',
              style: TextStyle(fontSize: 12, color: AppColors.textSubFor(isDigital)),
            ),
            const SizedBox(height: AppSizes.sm),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _identities.map((id) {
                final selected = _selectedIdentity == id;
                return GestureDetector(
                  onTap: () => setState(() => _selectedIdentity = id),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: selected ? primary.withValues(alpha: 0.12) : Colors.transparent,
                      borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                      border: Border.all(
                        color: selected ? primary : AppColors.textSubFor(isDigital).withValues(alpha: 0.3),
                        width: selected ? 1.5 : 1,
                      ),
                    ),
                    child: Text(
                      '#$id',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: selected ? FontWeight.w700 : FontWeight.normal,
                        color: selected ? primary : AppColors.textSubFor(isDigital),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: AppSizes.lg),

            // ── Category toggle ───────────────────────────────────────────
            const Text('Category', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: AppSizes.sm),
            Row(
              children: [
                Expanded(child: _CategoryOption(
                  label: 'Traditional',
                  icon: Icons.brush_outlined,
                  selected: _category == 'traditional',
                  onTap: () => setState(() => _category = 'traditional'),
                  color: primary,
                  isDigital: isDigital,
                )),
                const SizedBox(width: AppSizes.sm),
                Expanded(child: _CategoryOption(
                  label: 'Digital',
                  icon: Icons.computer_outlined,
                  selected: _category == 'digital',
                  onTap: () => setState(() => _category = 'digital'),
                  color: primary,
                  isDigital: isDigital,
                )),
              ],
            ),
            const SizedBox(height: AppSizes.lg),

            // ── Purpose (optional) ────────────────────────────────────────
            TextFormField(
              controller: _purposeCtrl,
              maxLines: 2,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Purpose (optional)',
                hintText: 'What will your group do? Projects, events, competitions...',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: AppSizes.lg),

            // ── Info card ─────────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(AppSizes.md),
              decoration: BoxDecoration(
                color: primary.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                border: Border.all(color: primary.withValues(alpha: 0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text('📋', style: TextStyle(fontSize: 16)),
                      const SizedBox(width: 8),
                      Text('Group Rules', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: primary)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  for (final rule in const [
                    'Groups auto-convert to Community at 50 members',
                    'Anyone with same identity hashtag can join',
                    'Groups can create charity pools for good causes',
                    'Group posts go to Group Competition',
                  ])
                    Padding(
                      padding: const EdgeInsets.only(bottom: 5),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('•  ', style: TextStyle(fontSize: 13, color: primary, fontWeight: FontWeight.bold)),
                          Expanded(child: Text(rule, style: const TextStyle(fontSize: 13, height: 1.4))),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: AppSizes.xl),

            // ── Submit ────────────────────────────────────────────────────
            FilledButton(
              onPressed: _submit,
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
                backgroundColor: primary,
              ),
              child: const Text('Create Group', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            ),
            const SizedBox(height: AppSizes.lg),
          ],
        ),
      ),
    );
  }
}

class _CategoryOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final bool isDigital;
  final VoidCallback onTap;
  final Color color;
  const _CategoryOption({
    required this.label,
    required this.icon,
    required this.selected,
    required this.isDigital,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          border: Border.all(
            color: selected ? color : AppColors.textSubFor(isDigital).withValues(alpha: 0.3),
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: selected ? color : AppColors.textSubFor(isDigital), size: 22),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: selected ? FontWeight.w700 : FontWeight.normal,
                color: selected ? color : AppColors.textSubFor(isDigital),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
