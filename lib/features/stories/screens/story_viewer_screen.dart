import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/providers/theme_provider.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../../models/story_model.dart';
import '../../../services/firestore_service.dart';

class StoryViewerScreen extends StatefulWidget {
  final List<StoryModel> stories;
  const StoryViewerScreen({super.key, required this.stories});

  @override
  State<StoryViewerScreen> createState() => _StoryViewerScreenState();
}

class _StoryViewerScreenState extends State<StoryViewerScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _progressController;
  int _currentIndex = 0;
  String? _reaction;

  StoryModel get _current => widget.stories[_currentIndex];

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    );
    _startProgress();
    _markCurrentViewed();
  }

  void _startProgress() {
    _progressController.reset();
    _progressController.forward().then((_) {
      if (mounted) _nextStory();
    });
  }

  void _nextStory() {
    if (_currentIndex < widget.stories.length - 1) {
      setState(() => _currentIndex++);
      _startProgress();
      _markCurrentViewed();
    } else {
      Navigator.pop(context);
    }
  }

  void _previousStory() {
    if (_currentIndex > 0) {
      setState(() => _currentIndex--);
      _startProgress();
    }
  }

  Future<void> _markCurrentViewed() async {
    final uid = context.read<AuthProvider>().currentUser?.uid;
    if (uid != null) {
      await FirestoreService().markStoryViewed(_current.storyId, uid);
    }
  }

  Future<void> _react(String reaction) async {
    final uid = context.read<AuthProvider>().currentUser?.uid;
    if (uid == null) return;
    setState(() => _reaction = reaction);
    await FirestoreService().reactToStory(
      storyId: _current.storyId,
      uid: uid,
      reaction: reaction,
    );
  }

  String _timeLeft() {
    final diff = _current.expiresAt.difference(DateTime.now());
    if (diff.inHours > 0) return '${diff.inHours}h left';
    return '${diff.inMinutes}m left';
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTapDown: (details) {
          final width = MediaQuery.of(context).size.width;
          if (details.globalPosition.dx < width / 2) {
            _previousStory();
          } else {
            _nextStory();
          }
        },
        child: Stack(
          children: [
            _buildStoryContent(),

            // Animated progress bars
            Positioned(
              top: MediaQuery.of(context).padding.top + 8,
              left: 12,
              right: 12,
              child: AnimatedBuilder(
                animation: _progressController,
                builder: (context, _) => Row(
                  children: List.generate(
                    widget.stories.length,
                    (i) => Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: LinearProgressIndicator(
                          value: i < _currentIndex
                              ? 1.0
                              : i == _currentIndex
                                  ? _progressController.value
                                  : 0.0,
                          backgroundColor: Colors.white30,
                          valueColor:
                              const AlwaysStoppedAnimation(Colors.white),
                          minHeight: 2,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Header
            Positioned(
              top: MediaQuery.of(context).padding.top + 20,
              left: 12,
              right: 12,
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: AppColors.adaptivePrimary(context.watch<ThemeProvider>().isDigital),
                    child: Text(
                      _current.authorName[0].toUpperCase(),
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _current.authorName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          _timeLeft(),
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  _StoryTypeBadge(type: _current.type),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Bottom reactions
            Positioned(
              bottom: MediaQuery.of(context).padding.bottom + 24,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  if (_current.type == 'work' &&
                      _current.journeyId.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        '📖 Part of a Journey',
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _ReactionBtn(
                        emoji: '👏',
                        label: 'Respect',
                        isSelected: _reaction == 'respect',
                        onTap: () => _react('respect'),
                      ),
                      const SizedBox(width: 16),
                      _ReactionBtn(
                        emoji: '❤️',
                        label: 'Love',
                        isSelected: _reaction == 'love',
                        onTap: () => _react('love'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStoryContent() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: _current.category == 'traditional'
          ? const Color(0xFF1A0A00)
          : const Color(0xFF0A0A1A),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (_current.mediaURL.isNotEmpty)
            CachedNetworkImage(
              imageUrl: _current.mediaURL,
              width: double.infinity,
              height: 300,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                height: 300,
                color: Colors.black54,
                child: const Center(
                  child: SizedBox(
                    width: 20, height: 20,
                    child: CircularProgressIndicator(strokeWidth: 1.5, color: Colors.white54),
                  ),
                ),
              ),
              errorWidget: (context, url, error) => Container(
                height: 300,
                color: Colors.black54,
                child: const Icon(Icons.image_outlined, color: Colors.white54, size: 32),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(32),
            child: Text(
              _current.content,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                height: 1.6,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (_current.hashtag.isNotEmpty)
            Text(
              '#${_current.hashtag}',
              style: TextStyle(
                color: AppColors.adaptivePrimary(context.watch<ThemeProvider>().isDigital).withValues(alpha: 0.8),
                fontSize: 14,
              ),
            ),
        ],
      ),
    );
  }
}

class _StoryTypeBadge extends StatelessWidget {
  final String type;
  const _StoryTypeBadge({required this.type});

  @override
  Widget build(BuildContext context) {
    final String label;
    final Color color;
    switch (type) {
      case 'work':
        label = '📖 Work';
        color = Colors.blue.withValues(alpha: 0.6);
      case 'competition':
        label = '🏆 Competing';
        color = Colors.amber.withValues(alpha: 0.6);
      default:
        label = 'Quick';
        color = Colors.white30;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _ReactionBtn extends StatelessWidget {
  final String emoji;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ReactionBtn({
    required this.emoji,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.white.withValues(alpha: 0.25)
              : Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected
                ? Colors.white.withValues(alpha: 0.6)
                : Colors.white.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white70,
                fontSize: 14,
                fontWeight:
                    isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
