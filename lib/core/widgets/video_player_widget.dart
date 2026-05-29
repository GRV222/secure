import 'package:cached_network_image/cached_network_image.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerWidget extends StatefulWidget {
  final String videoUrl;
  final String? thumbnailUrl;

  const VideoPlayerWidget({
    super.key,
    required this.videoUrl,
    this.thumbnailUrl,
  });

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  VideoPlayerController? _vpController;
  ChewieController? _chewieController;
  bool _isInitializing = false;

  Future<void> _loadPlayer() async {
    if (_isInitializing || _vpController != null) return;
    setState(() => _isInitializing = true);
    try {
      final vpc = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));
      await vpc.initialize();
      final chewie = ChewieController(
        videoPlayerController: vpc,
        autoPlay: true,
        looping: false,
        aspectRatio: vpc.value.aspectRatio,
      );
      if (mounted) {
        setState(() {
          _vpController = vpc;
          _chewieController = chewie;
          _isInitializing = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isInitializing = false);
    }
  }

  @override
  void dispose() {
    _chewieController?.dispose();
    _vpController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_chewieController != null) {
      return SizedBox(height: 280, child: Chewie(controller: _chewieController!));
    }

    return GestureDetector(
      onTap: _loadPlayer,
      child: Container(
        height: 280,
        width: double.infinity,
        color: Colors.black87,
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (widget.thumbnailUrl != null && widget.thumbnailUrl!.isNotEmpty)
              CachedNetworkImage(
                imageUrl: widget.thumbnailUrl!,
                width: double.infinity,
                height: 280,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.black54,
                  child: const Center(
                    child: SizedBox(
                      width: 20, height: 20,
                      child: CircularProgressIndicator(strokeWidth: 1.5, color: Colors.white54),
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => const SizedBox.shrink(),
              ),
            if (_isInitializing)
              const CircularProgressIndicator(color: Colors.white)
            else
              Container(
                width: 60,
                height: 60,
                decoration: const BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.play_arrow, color: Colors.white, size: 36),
              ),
          ],
        ),
      ),
    );
  }
}
