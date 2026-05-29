import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../config/route_names.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/providers/theme_provider.dart';
import '../../../core/dummy/dummy_data.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../../features/feed/providers/feed_provider.dart';
import '../../../models/hashtag_model.dart';
import '../../../models/post_model.dart';
import '../../../services/claude_service.dart';
import '../../../services/storage_service.dart';
import '../../../services/location_service.dart';
import '../providers/post_provider.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  int _step = 1;
  final StorageService _storageService = StorageService();
  final LocationService _locationService = LocationService();

  // ── Location ───────────────────────────────────────────────────────────────
  LocationData? _location;
  bool _locationLoading = false;
  bool _locationEnabled = true;

  // ── Step 1 ─────────────────────────────────────────────────────────────────
  String _contentType = ''; // 'image' | 'text' | 'video' | 'audio'
  File? _selectedImage;
  File? _selectedVideo;
  File? _selectedVideoThumb;
  File? _selectedAudio;
  String _audioFileName = '';
  double _uploadProgress = 0.0;
  final _textCtrl = TextEditingController();
  final _captionCtrl = TextEditingController();

  // ── Step 2 ─────────────────────────────────────────────────────────────────
  String? _selectedIdentity;
  String? _selectedHashtag;
  String _hashtagCategory = '';
  String _hashtagQuery = '';
  final _hashtagSearchCtrl = TextEditingController();

  // ── Step 3 ─────────────────────────────────────────────────────────────────
  bool _allowComments = true;
  bool _isPosting = false;
  bool _moderating = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _detectLocation());
  }

  @override
  void dispose() {
    _textCtrl.dispose();
    _captionCtrl.dispose();
    _hashtagSearchCtrl.dispose();
    super.dispose();
  }

  Future<void> _detectLocation() async {
    if (!_locationEnabled) return;
    setState(() => _locationLoading = true);
    final loc = await _locationService.getCurrentLocation();
    if (mounted) setState(() { _location = loc; _locationLoading = false; });
  }

  void _changeLocation() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Location'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.my_location),
              title: const Text('Use current location'),
              onTap: () { Navigator.pop(context); _detectLocation(); },
            ),
            ListTile(
              leading: const Icon(Icons.location_off),
              title: const Text('Remove location'),
              onTap: () { setState(() => _location = null); Navigator.pop(context); },
            ),
          ],
        ),
      ),
    );
  }

  List<HashtagModel> get _filteredHashtags {
    if (_hashtagQuery.isEmpty) return DummyData.dummyHashtags;
    return DummyData.dummyHashtags.where((h) => h.name.contains(_hashtagQuery.toLowerCase())).toList();
  }

  bool get _isCustomHashtag =>
      _hashtagQuery.isNotEmpty &&
      !DummyData.dummyHashtags.any((h) => h.name == _hashtagQuery.toLowerCase());

  void _advance() {
    if (_step == 1 && _contentType.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a content type')));
      return;
    }
    if (_step == 1 && _contentType == 'video' && _selectedVideo == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please pick a video file')));
      return;
    }
    if (_step == 1 && _contentType == 'audio' && _selectedAudio == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please pick an audio file')));
      return;
    }
    if (_step < 3) setState(() => _step++);
  }

  Future<void> _showImagePickerSheet() async {
    await showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('Camera'),
              onTap: () async {
                Navigator.pop(ctx);
                final file = await _storageService.pickImageFromCamera();
                if (file != null && mounted) setState(() => _selectedImage = file);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Gallery'),
              onTap: () async {
                Navigator.pop(ctx);
                final file = await _storageService.pickImageFromGallery();
                if (file != null && mounted) setState(() => _selectedImage = file);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickVideo() async {
    final file = await _storageService.pickVideo();
    if (file == null || !mounted) return;
    final thumb = await _storageService.generateVideoThumbnail(file.path);
    setState(() {
      _selectedVideo = file;
      _selectedVideoThumb = thumb;
    });
  }

  Future<void> _pickAudio() async {
    final file = await _storageService.pickAudio();
    if (file == null || !mounted) return;
    final name = file.path.split(RegExp(r'[/\\]')).last;
    setState(() {
      _selectedAudio = file;
      _audioFileName = name;
    });
  }

  Future<void> _showSuccessSheet({String? hashtag}) async {
    final isDigital = context.read<ThemeProvider>().isDigital;
    final primary = AppColors.adaptivePrimary(isDigital);
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.bg(isDigital),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: primary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            const Text('🎉', style: TextStyle(fontSize: 52)),
            const SizedBox(height: 16),
            Text(
              'Your post is live!',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 22,
                color: AppColors.textFor(isDigital),
              ),
            ),
            if (hashtag != null) ...[
              const SizedBox(height: 6),
              Text(
                'Posted to #$hashtag',
                style: TextStyle(fontSize: 14, color: primary),
              ),
            ],
            const SizedBox(height: 8),
            Text(
              'Ratings open. Share to grow your reach.',
              style: TextStyle(
                  fontSize: 13, color: AppColors.textSubFor(isDigital)),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.pop(context),
                style: FilledButton.styleFrom(backgroundColor: primary),
                child: const Text('Go to Feed'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitPost() async {
    final authUser = context.read<AuthProvider>().currentUser;
    if (authUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in first')),
      );
      return;
    }
    final postProv = context.read<PostProvider>();
    final feedProv = context.read<FeedProvider>();

    // AI content moderation
    final contentToCheck = _contentType == 'text'
        ? _textCtrl.text.trim()
        : _captionCtrl.text.trim();
    if (contentToCheck.isNotEmpty) {
      setState(() => _moderating = true);
      try {
        const apiKey = String.fromEnvironment('ANTHROPIC_API_KEY', defaultValue: '');
        if (apiKey.isNotEmpty) {
          final result = await ClaudeService(apiKey).moderateContent(contentToCheck);
          if (!mounted) return;
          if (result.toLowerCase().contains('unsafe')) {
            setState(() => _moderating = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Content flagged. Please review your post before submitting.'),
                backgroundColor: Colors.red.shade700,
              ),
            );
            return;
          }
        }
      } catch (_) {
        // Moderation unavailable — allow post to proceed
      }
      if (mounted) setState(() => _moderating = false);
    }

    setState(() => _isPosting = true);

    String? mediaURL;
    String thumbnailURL = '';
    String audioTitle = '';

    try {
      if (_contentType == 'image' && _selectedImage != null) {
        mediaURL = await _storageService.uploadPostImage(
          uid: authUser.uid,
          imageFile: _selectedImage!,
        );
      } else if (_contentType == 'video' && _selectedVideo != null) {
        final result = await _storageService.uploadVideo(
          uid: authUser.uid,
          videoFile: _selectedVideo!,
          thumbnail: _selectedVideoThumb,
          onProgress: (p) => setState(() => _uploadProgress = p),
        );
        mediaURL = result.videoUrl;
        thumbnailURL = result.thumbnailUrl;
      } else if (_contentType == 'audio' && _selectedAudio != null) {
        mediaURL = await _storageService.uploadAudio(
          uid: authUser.uid,
          audioFile: _selectedAudio!,
          fileName: _audioFileName,
        );
        audioTitle = _textCtrl.text.trim().isNotEmpty ? _textCtrl.text.trim() : _audioFileName;
      }
    } catch (_) {
      if (!mounted) return;
      setState(() { _isPosting = false; _uploadProgress = 0; });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Upload failed. Please try again.')),
      );
      return;
    }

    PostType postType;
    switch (_contentType) {
      case 'image': postType = PostType.image;
      case 'video': postType = PostType.video;
      case 'audio': postType = PostType.audio;
      default: postType = PostType.text;
    }

    final created = await postProv.createPost(
      uid: authUser.uid,
      authorName: authUser.displayName,
      authorUsername: authUser.username,
      authorPhotoURL: authUser.photoURL,
      type: postType,
      category: _hashtagCategory == 'digital' ? PostCategory.digital : PostCategory.traditional,
      content: _contentType == 'text' ? _textCtrl.text.trim() : (_contentType == 'audio' ? audioTitle : ''),
      caption: _captionCtrl.text.trim().isEmpty ? null : _captionCtrl.text.trim(),
      mediaURL: mediaURL,
      hashtags: _selectedHashtag != null ? [_selectedHashtag!] : [],
      identityHashtag: _selectedIdentity,
      commentsEnabled: _allowComments,
      locationCity: _location?.city ?? '',
      locationState: _location?.state ?? '',
      locationCountry: _location?.country ?? '',
      locationDisplay: _location?.displayName ?? '',
      locationLat: _location?.lat ?? 0.0,
      locationLng: _location?.lng ?? 0.0,
      hasLocation: _location != null,
      thumbnailURL: thumbnailURL,
      audioTitle: audioTitle,
    );

    if (!mounted) return;
    setState(() => _isPosting = false);

    if (created != null) {
      feedProv.addPost(created);
      await _showSuccessSheet(hashtag: _selectedHashtag);
      if (!mounted) return;
      context.go(RouteNames.home);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(postProv.error ?? 'Failed to post. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDigital = context.watch<ThemeProvider>().isDigital;
    return Scaffold(
      backgroundColor: AppColors.bg(isDigital),
      appBar: AppBar(
        title: Text(_stepTitle()),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (_step > 1) { setState(() => _step--); } else { context.pop(); }
          },
        ),
      ),
      body: Column(
        children: [
          _StepIndicator(step: _step),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSizes.md),
              child: _buildCurrentStep(isDigital),
            ),
          ),
        ],
      ),
    );
  }

  String _stepTitle() {
    switch (_step) {
      case 1: return 'Create Post';
      case 2: return 'Tag Your Post';
      default: return 'Almost Done';
    }
  }

  Widget _buildCurrentStep(bool isDigital) {
    switch (_step) {
      case 1: return _buildStep1(isDigital);
      case 2: return _buildStep2(isDigital);
      default: return _buildStep3(isDigital);
    }
  }

  // ── Step 1: Content ─────────────────────────────────────────────────────────

  Widget _buildStep1(bool isDigital) {
    final textLen = _textCtrl.text.length;
    final captionLen = _captionCtrl.text.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Choose content type', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        const SizedBox(height: AppSizes.sm),
        Row(
          children: [
            Expanded(child: _TypeCard(label: '📷  Image', value: 'image', selected: _contentType == 'image', onTap: () => setState(() => _contentType = 'image'))),
            const SizedBox(width: AppSizes.sm),
            Expanded(child: _TypeCard(label: '📝  Text', value: 'text', selected: _contentType == 'text', onTap: () => setState(() => _contentType = 'text'))),
          ],
        ),
        const SizedBox(height: AppSizes.sm),
        Row(
          children: [
            Expanded(child: _TypeCard(label: '🎬  Video', value: 'video', selected: _contentType == 'video', onTap: () => setState(() => _contentType = 'video'))),
            const SizedBox(width: AppSizes.sm),
            Expanded(child: _TypeCard(label: '🎵  Audio', value: 'audio', selected: _contentType == 'audio', onTap: () => setState(() => _contentType = 'audio'))),
          ],
        ),
        const SizedBox(height: AppSizes.sm),
        GestureDetector(
          onTap: () => context.push(RouteNames.createFlash),
          child: Container(
            height: 56,
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(AppSizes.radiusLg),
              border: Border.all(color: Colors.amber.withValues(alpha: 0.4), width: 1.5),
            ),
            alignment: Alignment.center,
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('⚡', style: TextStyle(fontSize: 18)),
                SizedBox(width: 8),
                Text(
                  'Flash Post  —  seen once, expires in 24h',
                  style: TextStyle(
                    color: Colors.amber,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSizes.md),

        // Image content
        if (_contentType == 'image') ...[
          GestureDetector(
            onTap: _showImagePickerSheet,
            child: Container(
              height: 180,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                border: Border.all(
                  color: _selectedImage != null ? AppColors.adaptivePrimary(isDigital) : Colors.grey.shade300,
                  width: 1.5,
                ),
                image: _selectedImage != null
                    ? DecorationImage(image: FileImage(_selectedImage!), fit: BoxFit.cover)
                    : null,
              ),
              child: _selectedImage == null
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_photo_alternate_outlined, size: 40, color: Colors.grey.shade400),
                        const SizedBox(height: 8),
                        Text('Tap to pick image', style: TextStyle(color: Colors.grey.shade500)),
                      ],
                    )
                  : Align(
                      alignment: Alignment.bottomRight,
                      child: Container(
                        margin: const EdgeInsets.all(8),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text('Tap to change', style: TextStyle(color: Colors.white, fontSize: 11)),
                      ),
                    ),
            ),
          ),
          const SizedBox(height: AppSizes.md),
        ],

        // Video content
        if (_contentType == 'video') ...[
          GestureDetector(
            onTap: _pickVideo,
            child: Container(
              height: 180,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                border: Border.all(
                  color: _selectedVideo != null ? AppColors.adaptivePrimary(isDigital) : Colors.grey.shade300,
                  width: 1.5,
                ),
              ),
              child: _selectedVideo == null
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.videocam_outlined, size: 40, color: Colors.grey.shade400),
                        const SizedBox(height: 8),
                        Text('Tap to pick video', style: TextStyle(color: Colors.grey.shade500)),
                      ],
                    )
                  : Stack(
                      alignment: Alignment.center,
                      children: [
                        if (_selectedVideoThumb != null)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                            child: Image.file(_selectedVideoThumb!, fit: BoxFit.cover, width: double.infinity, height: 180),
                          ),
                        const Icon(Icons.play_circle_outline, size: 48, color: Colors.white),
                        Positioned(
                          bottom: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(6)),
                            child: const Text('Tap to change', style: TextStyle(color: Colors.white, fontSize: 11)),
                          ),
                        ),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: AppSizes.md),
        ],

        // Audio content
        if (_contentType == 'audio') ...[
          GestureDetector(
            onTap: _pickAudio,
            child: Container(
              height: 120,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.deepPurple.shade50,
                borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                border: Border.all(
                  color: _selectedAudio != null ? Colors.deepPurple : Colors.deepPurple.shade100,
                  width: 1.5,
                ),
              ),
              child: _selectedAudio == null
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.audio_file_outlined, size: 36, color: Colors.deepPurple.shade200),
                        const SizedBox(height: 8),
                        Text('Tap to pick audio file', style: TextStyle(color: Colors.deepPurple.shade300)),
                      ],
                    )
                  : Padding(
                      padding: const EdgeInsets.all(AppSizes.md),
                      child: Row(
                        children: [
                          Icon(Icons.music_note, color: Colors.deepPurple.shade400),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(_audioFileName, style: TextStyle(fontWeight: FontWeight.w600, color: Colors.deepPurple.shade700), maxLines: 2, overflow: TextOverflow.ellipsis),
                                const SizedBox(height: 4),
                                Text('Tap to change', style: TextStyle(fontSize: 12, color: Colors.deepPurple.shade300)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ),
          const SizedBox(height: AppSizes.md),
          TextField(
            controller: _textCtrl,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: 'Audio title (shown to listeners)…',
              filled: true,
              fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.all(AppSizes.md),
            ),
          ),
          const SizedBox(height: AppSizes.md),
        ],

        // Text content
        if (_contentType == 'text') ...[
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(AppSizes.radiusLg),
            ),
            child: TextField(
              controller: _textCtrl,
              maxLines: 8,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Write your post…',
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(AppSizes.md),
                suffixIcon: Padding(
                  padding: const EdgeInsets.only(right: 10, bottom: 8),
                  child: Align(
                    alignment: Alignment.bottomRight,
                    child: Text(
                      '$textLen / 500',
                      style: TextStyle(
                        fontSize: 11,
                        color: textLen > 500 ? AppColors.error : AppColors.textSubFor(isDigital),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (textLen > 500)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                'Will be saved as a document post',
                style: TextStyle(fontSize: 12, color: Colors.orange.shade700),
              ),
            ),
          const SizedBox(height: AppSizes.md),
        ],

        // Caption (always)
        if (_contentType.isNotEmpty) ...[
          const Text('Caption', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          const SizedBox(height: 6),
          TextField(
            controller: _captionCtrl,
            maxLines: 2,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: 'Add a caption…',
              filled: true,
              fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.all(AppSizes.md),
              counterText: '$captionLen / 151',
              counterStyle: TextStyle(
                fontSize: 11,
                color: captionLen > 151 ? AppColors.error : AppColors.textSubFor(isDigital),
              ),
            ),
          ),
          const SizedBox(height: AppSizes.lg),
        ],

        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: _advance,
            child: const Text('Next →'),
          ),
        ),
      ],
    );
  }

  // ── Step 2: Identity & Category ─────────────────────────────────────────────

  Widget _buildStep2(bool isDigital) {
    final user = context.read<AuthProvider>().currentUser;
    if (user == null) return const SizedBox.shrink();
    final filtered = _filteredHashtags;
    final traditional = filtered.where((h) => h.category == 'traditional').toList();
    final digital = filtered.where((h) => h.category == 'digital').toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Identity
        const Text('Post as which identity?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        const SizedBox(height: AppSizes.sm),
        Wrap(
          spacing: 8,
          runSpacing: 6,
          children: user.identityHashtags.map((id) {
            final selected = _selectedIdentity == id;
            return GestureDetector(
              onTap: () => setState(() => _selectedIdentity = id),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: selected ? AppColors.adaptivePrimary(isDigital) : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                  border: Border.all(color: selected ? AppColors.adaptivePrimary(isDigital) : AppColors.adaptivePrimary(isDigital).withValues(alpha: 0.5)),
                ),
                child: Text(
                  '#$id',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: selected ? AppColors.white : AppColors.adaptivePrimary(isDigital),
                  ),
                ),
              ),
            );
          }).toList(),
        ),

        const SizedBox(height: AppSizes.lg),

        // Category hashtag
        const Text('What is this post about?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        const SizedBox(height: AppSizes.sm),
        TextField(
          controller: _hashtagSearchCtrl,
          onChanged: (v) => setState(() => _hashtagQuery = v.trim()),
          decoration: InputDecoration(
            hintText: 'Search hashtags…',
            prefixIcon: const Icon(Icons.tag, size: 18),
            filled: true,
            fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusFull),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: AppSizes.md),
          ),
        ),

        if (_isCustomHashtag) ...[
          const SizedBox(height: AppSizes.sm),
          GestureDetector(
            onTap: () => setState(() {
              _selectedHashtag = _hashtagQuery.toLowerCase();
              _hashtagCategory = 'traditional';
            }),
            child: Container(
              padding: const EdgeInsets.all(AppSizes.sm),
              decoration: BoxDecoration(
                color: AppColors.adaptivePrimary(isDigital).withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                border: Border.all(color: AppColors.adaptivePrimary(isDigital).withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Create new hashtag: #${_hashtagQuery.toLowerCase()}',
                      style: TextStyle(color: AppColors.adaptivePrimary(isDigital), fontWeight: FontWeight.w600, fontSize: 13)),
                  const SizedBox(height: 2),
                  Text('New hashtags start a competition next month 🏆',
                      style: TextStyle(fontSize: 11, color: AppColors.textSubFor(isDigital))),
                ],
              ),
            ),
          ),
        ],

        const SizedBox(height: AppSizes.sm),

        if (traditional.isNotEmpty) ...[
          Text('🎨 Traditional', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.adaptivePrimary(isDigital))),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: traditional.map((h) => _HashtagChip(
              hashtag: h,
              selected: _selectedHashtag == h.name,
              color: AppColors.adaptivePrimary(isDigital),
              onTap: () => setState(() {
                _selectedHashtag = h.name;
                _hashtagCategory = 'traditional';
              }),
            )).toList(),
          ),
          const SizedBox(height: AppSizes.sm),
        ],

        if (digital.isNotEmpty) ...[
          Text('💻 Digital', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.adaptivePrimary(isDigital))),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: digital.map((h) => _HashtagChip(
              hashtag: h,
              selected: _selectedHashtag == h.name,
              color: AppColors.adaptivePrimary(isDigital),
              onTap: () => setState(() {
                _selectedHashtag = h.name;
                _hashtagCategory = 'digital';
              }),
            )).toList(),
          ),
          const SizedBox(height: AppSizes.sm),
        ],

        const SizedBox(height: AppSizes.sm),

        // Location row
        Row(
          children: [
            Icon(Icons.location_on_outlined, size: 18, color: Colors.grey.shade500),
            const SizedBox(width: 8),
            if (_locationLoading)
              Text('Detecting location…', style: TextStyle(color: Colors.grey.shade500, fontSize: 13))
            else if (_location != null)
              Expanded(
                child: Text(
                  _location!.displayName,
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                ),
              )
            else
              Text('No location', style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
            if (!_locationLoading) ...[ const Spacer() ],
            if (_location != null) ...[
              TextButton(
                onPressed: _changeLocation,
                child: const Text('Change', style: TextStyle(fontSize: 12)),
              ),
            ],
            Switch(
              value: _locationEnabled,
              onChanged: (val) {
                setState(() {
                  _locationEnabled = val;
                  if (!val) { _location = null; } else { _detectLocation(); }
                });
              },
              activeColor: AppColors.adaptivePrimary(isDigital),
            ),
          ],
        ),

        const SizedBox(height: AppSizes.sm),
        const Text('Post category', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        const SizedBox(height: 6),
        Row(
          children: [
            _CategoryChip('🎨 Traditional', 'traditional', _hashtagCategory, (v) => setState(() => _hashtagCategory = v)),
            const SizedBox(width: 8),
            _CategoryChip('💻 Digital', 'digital', _hashtagCategory, (v) => setState(() => _hashtagCategory = v)),
          ],
        ),

        const SizedBox(height: AppSizes.lg),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: _advance,
            child: const Text('Next →'),
          ),
        ),
      ],
    );
  }

  // ── Step 3: Settings & Post ──────────────────────────────────────────────────

  Widget _buildStep3(bool isDigital) {
    final user = context.read<AuthProvider>().currentUser;
    if (user == null) return const SizedBox.shrink();
    final contentPreview = _contentType == 'text'
        ? (_textCtrl.text.isEmpty ? '(no content)' : _textCtrl.text.length > 100 ? '${_textCtrl.text.substring(0, 100)}…' : _textCtrl.text)
        : '📷 Image post';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Comments toggle
        Container(
          padding: const EdgeInsets.all(AppSizes.md),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Allow comments on this post?', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                        const SizedBox(height: 2),
                        Text('One-time decision — cannot change after posting', style: TextStyle(fontSize: 11, color: AppColors.textSubFor(isDigital))),
                      ],
                    ),
                  ),
                  Switch(
                    value: _allowComments,
                    onChanged: (v) => setState(() => _allowComments = v),
                    activeColor: AppColors.adaptivePrimary(isDigital),
                  ),
                ],
              ),
              if (_allowComments) ...[
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.adaptivePrimary(isDigital).withValues(alpha: 0.07),
                    borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  ),
                  child: Text(
                    '📋 Comments require verified identity at a SECURE centre',
                    style: TextStyle(fontSize: 11, color: AppColors.textSubFor(isDigital)),
                  ),
                ),
              ],
            ],
          ),
        ),

        const SizedBox(height: AppSizes.lg),
        const Text('Preview', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        const SizedBox(height: AppSizes.sm),

        // Preview card
        Container(
          padding: const EdgeInsets.all(AppSizes.md),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSizes.radiusLg),
            border: Border.all(color: AppColors.adaptivePrimary(isDigital).withValues(alpha: 0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: AppColors.adaptivePrimary(isDigital),
                    child: Text(
                      user.displayName[0].toUpperCase(),
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user.displayName, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                      Text('@${user.username}', style: TextStyle(color: AppColors.textSubFor(isDigital), fontSize: 12)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                children: [
                  if (_selectedIdentity != null)
                    _PreviewPill('#$_selectedIdentity!', AppColors.adaptivePrimary(isDigital), false),
                  if (_selectedHashtag != null)
                    _PreviewPill(
                      '#$_selectedHashtag',
                      AppColors.adaptivePrimary(isDigital),
                      true,
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                contentPreview,
                style: const TextStyle(fontSize: 14, height: 1.4),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),

        const SizedBox(height: AppSizes.lg),
        if (_isPosting && _contentType == 'video' && _uploadProgress > 0) ...[
          Row(
            children: [
              Expanded(
                child: LinearProgressIndicator(
                  value: _uploadProgress,
                  backgroundColor: AppColors.adaptivePrimary(isDigital).withValues(alpha: 0.15),
                  color: AppColors.adaptivePrimary(isDigital),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '${(_uploadProgress * 100).toInt()}%',
                style: TextStyle(fontSize: 12, color: AppColors.textSubFor(isDigital)),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.sm),
        ],
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: (_isPosting || _moderating) ? null : _submitPost,
            child: _moderating
                ? const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)),
                      SizedBox(width: 8),
                      Text('Checking content…'),
                    ],
                  )
                : _isPosting
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Post Now'),
          ),
        ),
      ],
    );
  }
}

// ─── Step Indicator ────────────────────────────────────────────────────────────

class _StepIndicator extends StatelessWidget {
  final int step;
  const _StepIndicator({required this.step});

  @override
  Widget build(BuildContext context) {
    final isDigital = context.watch<ThemeProvider>().isDigital;
    final primary = AppColors.adaptivePrimary(isDigital);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.xl, vertical: AppSizes.md),
      child: Row(
        children: [
          for (int i = 1; i <= 3; i++) ...[
            if (i > 1)
              Expanded(
                child: Container(
                  height: 2,
                  color: i <= step ? primary : Colors.grey.shade200,
                ),
              ),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: i <= step ? primary : Colors.grey.shade200,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: i < step
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                  : Text(
                      '$i',
                      style: TextStyle(
                        color: i == step ? Colors.white : Colors.grey,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Type Card ─────────────────────────────────────────────────────────────────

class _TypeCard extends StatelessWidget {
  final String label;
  final String value;
  final bool selected;
  final VoidCallback onTap;
  const _TypeCard({required this.label, required this.value, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDigital = context.watch<ThemeProvider>().isDigital;
    final primary = AppColors.adaptivePrimary(isDigital);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 90,
        decoration: BoxDecoration(
          color: selected ? primary.withValues(alpha: 0.08) : Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          border: Border.all(color: selected ? primary : Colors.transparent, width: 2),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: selected ? primary : AppColors.textSubFor(isDigital),
          ),
        ),
      ),
    );
  }
}

// ─── Hashtag Chip ──────────────────────────────────────────────────────────────

class _HashtagChip extends StatelessWidget {
  final HashtagModel hashtag;
  final bool selected;
  final Color color;
  final VoidCallback onTap;
  const _HashtagChip({required this.hashtag, required this.selected, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(AppSizes.radiusFull),
          border: Border.all(color: selected ? color : color.withValues(alpha: 0.4)),
        ),
        child: Text(
          '#${hashtag.name}',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color),
        ),
      ),
    );
  }
}

// ─── Category Chip ─────────────────────────────────────────────────────────────

class _CategoryChip extends StatelessWidget {
  final String label;
  final String value;
  final String current;
  final ValueChanged<String> onChanged;
  const _CategoryChip(this.label, this.value, this.current, this.onChanged);

  @override
  Widget build(BuildContext context) {
    final isDigital = context.watch<ThemeProvider>().isDigital;
    final primary = AppColors.adaptivePrimary(isDigital);
    final active = current == value;
    return GestureDetector(
      onTap: () => onChanged(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: active ? primary : Colors.transparent,
          borderRadius: BorderRadius.circular(AppSizes.radiusFull),
          border: Border.all(color: active ? primary : AppColors.textSubFor(isDigital).withValues(alpha: 0.35)),
        ),
        child: Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: active ? AppColors.white : AppColors.textSubFor(isDigital))),
      ),
    );
  }
}

// ─── Preview Pill ──────────────────────────────────────────────────────────────

class _PreviewPill extends StatelessWidget {
  final String label;
  final Color color;
  final bool filled;
  const _PreviewPill(this.label, this.color, this.filled);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: filled ? color.withValues(alpha: 0.12) : Colors.transparent,
        borderRadius: BorderRadius.circular(AppSizes.radiusFull),
        border: Border.all(color: color.withValues(alpha: filled ? 0.3 : 0.55)),
      ),
      child: Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color)),
    );
  }
}
