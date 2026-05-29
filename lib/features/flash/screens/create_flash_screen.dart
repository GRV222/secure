import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/providers/theme_provider.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../../models/post_model.dart';
import '../../../services/firestore_service.dart';

class CreateFlashScreen extends StatefulWidget {
  const CreateFlashScreen({super.key});

  @override
  State<CreateFlashScreen> createState() => _CreateFlashScreenState();
}

class _CreateFlashScreenState extends State<CreateFlashScreen> {
  final _controller = TextEditingController();
  final _captionController = TextEditingController();
  String _selectedCategory = 'traditional';
  bool _isLoading = false;

  @override
  void dispose() {
    _controller.dispose();
    _captionController.dispose();
    super.dispose();
  }

  Future<void> _post() async {
    if (_controller.text.trim().isEmpty) return;
    setState(() => _isLoading = true);

    final user = context.read<AuthProvider>().currentUser;
    if (user == null) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      await FirestoreService().createPost(PostModel(
        postId: '',
        uid: user.uid,
        authorName: user.displayName,
        authorUsername: user.username,
        authorPhotoURL: user.photoURL ?? '',
        type: PostType.flash,
        category: _selectedCategory == 'digital'
            ? PostCategory.digital
            : PostCategory.traditional,
        content: _controller.text.trim(),
        caption: _captionController.text.trim().isEmpty
            ? null
            : _captionController.text.trim(),
        hashtags: const [],
        identityHashtag: user.identityHashtags.isNotEmpty
            ? user.identityHashtags.first
            : '',
        commentsEnabled: false,
        isFlash: true,
        status: PostStatus.live,
        aiModerationStatus: AiModerationStatus.approved,
        createdAt: DateTime.now(),
        ratingLockedUntil: DateTime.now().add(const Duration(days: 1)),
        editableAfter: DateTime.now().add(const Duration(days: 1)),
        flashExpiresAt: DateTime.now().add(const Duration(hours: 24)),
      ));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('⚡ Flash posted!'),
            backgroundColor: Colors.amber,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDigital = context.watch<ThemeProvider>().isDigital;
    final bgColor = isDigital ? AppColors.digBgDark : const Color(0xFF2A1A0E);
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Row(
          children: [
            Text('⚡', style: TextStyle(fontSize: 20)),
            SizedBox(width: 8),
            Text('Flash Post', style: TextStyle(color: Colors.white)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _post,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.amber),
                  )
                : const Text(
                    'Post',
                    style: TextStyle(
                      color: Colors.amber,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: Colors.amber.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  const Text('⚡', style: TextStyle(fontSize: 20)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Flash posts are seen once.\nShare live moments, updates, daily work.',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _controller,
              maxLines: 6,
              maxLength: 500,
              style: const TextStyle(
                  color: Colors.white, fontSize: 17, height: 1.6),
              decoration: InputDecoration(
                hintText: "What's happening right now?",
                hintStyle: TextStyle(
                  color: Colors.white.withValues(alpha: 0.3),
                  fontSize: 17,
                ),
                border: InputBorder.none,
                counterStyle: TextStyle(
                    color: Colors.white.withValues(alpha: 0.3)),
              ),
            ),
            const Divider(color: Colors.white12),
            const SizedBox(height: 16),
            Row(
              children: [
                Text(
                  'Category:',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(width: 12),
                _CategoryChip(
                  label: '🎨 Traditional',
                  isSelected: _selectedCategory == 'traditional',
                  onTap: () =>
                      setState(() => _selectedCategory = 'traditional'),
                ),
                const SizedBox(width: 8),
                _CategoryChip(
                  label: '💻 Digital',
                  isSelected: _selectedCategory == 'digital',
                  onTap: () =>
                      setState(() => _selectedCategory = 'digital'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.amber.withValues(alpha: 0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? Colors.amber : Colors.white24,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.amber : Colors.white54,
            fontSize: 13,
            fontWeight:
                isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
