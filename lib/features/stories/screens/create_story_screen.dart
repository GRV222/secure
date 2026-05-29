import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/providers/theme_provider.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../../models/story_model.dart';
import '../../../models/journey_model.dart';
import '../../../services/firestore_service.dart';

class CreateStoryScreen extends StatefulWidget {
  const CreateStoryScreen({super.key});

  @override
  State<CreateStoryScreen> createState() => _CreateStoryScreenState();
}

class _CreateStoryScreenState extends State<CreateStoryScreen> {
  final _contentCtrl = TextEditingController();
  final _hashtagCtrl = TextEditingController();
  String _type = 'quick';
  String _category = 'traditional';
  String? _selectedJourneyId;
  List<JourneyModel> _userJourneys = [];
  bool _isPosting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadJourneys());
  }

  Future<void> _loadJourneys() async {
    final uid = context.read<AuthProvider>().currentUser?.uid;
    if (uid == null) return;
    try {
      final journeys = await FirestoreService().getUserJourneys(uid);
      if (mounted) setState(() => _userJourneys = journeys);
    } catch (_) {}
  }

  Future<void> _post() async {
    final content = _contentCtrl.text.trim();
    if (content.isEmpty) return;

    final user = context.read<AuthProvider>().currentUser;
    if (user == null) return;

    setState(() => _isPosting = true);

    try {
      final story = StoryModel(
        storyId: '',
        uid: user.uid,
        authorName: user.displayName,
        authorUsername: user.username,
        authorPhotoURL: user.photoURL ?? '',
        content: content,
        mediaURL: '',
        type: _type,
        category: _category,
        identityHashtag: user.identityHashtags.isNotEmpty ? user.identityHashtags.first : '',
        hashtag: _hashtagCtrl.text.trim().replaceAll('#', ''),
        journeyId: _type == 'work' ? (_selectedJourneyId ?? '') : '',
        viewedBy: [],
        respectBy: [],
        loveBy: [],
        createdAt: DateTime.now(),
        expiresAt: DateTime.now().add(const Duration(hours: 24)),
      );

      await FirestoreService().createStory(story);
      if (mounted) context.pop();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to post story. Try again.')),
        );
        setState(() => _isPosting = false);
      }
    }
  }

  @override
  void dispose() {
    _contentCtrl.dispose();
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
        title: Text('New Story', style: TextStyle(color: AppColors.textFor(isDigital), fontWeight: FontWeight.bold)),
        actions: [
          TextButton(
            onPressed: _isPosting ? null : _post,
            child: _isPosting
                ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: primary))
                : Text(
                    'Post',
                    style: TextStyle(
                      color: _contentCtrl.text.trim().isEmpty ? AppColors.textSubFor(isDigital) : primary,
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
            Text('Story Type', style: TextStyle(color: AppColors.textSubFor(isDigital), fontSize: 13, fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            _TypeSelector(
              selected: _type,
              onChanged: (t) => setState(() {
                _type = t;
                if (t != 'work') _selectedJourneyId = null;
              }),
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

            if (_type == 'work' && _userJourneys.isNotEmpty) ...[
              Text('Journey (optional)', style: TextStyle(color: AppColors.textSubFor(isDigital), fontSize: 13, fontWeight: FontWeight.w600)),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.07),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white24),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String?>(
                    value: _selectedJourneyId,
                    isExpanded: true,
                    dropdownColor: const Color(0xFF1A1A2E),
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    hint: const Text('No journey', style: TextStyle(color: Colors.white54)),
                    items: [
                      const DropdownMenuItem<String?>(
                        value: null,
                        child: Text('No journey', style: TextStyle(color: Colors.white54)),
                      ),
                      ..._userJourneys.map((j) => DropdownMenuItem<String?>(
                            value: j.journeyId,
                            child: Text(j.title, style: const TextStyle(color: Colors.white)),
                          )),
                    ],
                    onChanged: (v) => setState(() => _selectedJourneyId = v),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],

            Text('Your Story', style: TextStyle(color: AppColors.textSubFor(isDigital), fontSize: 13, fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceColor(isDigital).withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isDigital ? AppColors.digBorder : AppColors.tradBorder),
              ),
              child: TextField(
                controller: _contentCtrl,
                maxLength: 300,
                maxLines: 6,
                style: TextStyle(color: AppColors.textFor(isDigital), fontSize: 16, height: 1.5),
                decoration: InputDecoration(
                  hintText: 'What\'s your story today?',
                  hintStyle: TextStyle(color: AppColors.textSubFor(isDigital)),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(16),
                  counterStyle: TextStyle(color: AppColors.textSubFor(isDigital)),
                ),
                onChanged: (_) => setState(() {}),
              ),
            ),
            const SizedBox(height: 16),

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
                  hintText: '#hashtag (optional)',
                  hintStyle: TextStyle(color: AppColors.textSubFor(isDigital)),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  prefixIcon: Icon(Icons.tag, color: AppColors.textSubFor(isDigital), size: 18),
                ),
              ),
            ),

            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceColor(isDigital).withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(Icons.timer_outlined, color: AppColors.textSubFor(isDigital), size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'Stories disappear after 24 hours',
                    style: TextStyle(color: AppColors.textSubFor(isDigital), fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TypeSelector extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onChanged;
  const _TypeSelector({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _TypeOption(
          emoji: '⚡',
          label: 'Quick',
          value: 'quick',
          selected: selected,
          color: Colors.white,
          onTap: onChanged,
        ),
        const SizedBox(width: 10),
        _TypeOption(
          emoji: '📖',
          label: 'Work',
          value: 'work',
          selected: selected,
          color: Colors.blue,
          onTap: onChanged,
        ),
        const SizedBox(width: 10),
        _TypeOption(
          emoji: '🏆',
          label: 'Competing',
          value: 'competition',
          selected: selected,
          color: Colors.amber,
          onTap: onChanged,
        ),
      ],
    );
  }
}

class _TypeOption extends StatelessWidget {
  final String emoji;
  final String label;
  final String value;
  final String selected;
  final Color color;
  final ValueChanged<String> onTap;
  const _TypeOption({
    required this.emoji,
    required this.label,
    required this.value,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = selected == value;
    return GestureDetector(
      onTap: () => onTap(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color.withValues(alpha: 0.6) : Colors.white12,
          ),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? color : Colors.white54,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
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
