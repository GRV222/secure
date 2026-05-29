import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import '../constants/app_colors.dart';
import '../providers/theme_provider.dart';

class AudioPlayerWidget extends StatefulWidget {
  final String audioUrl;
  final String title;

  const AudioPlayerWidget({
    super.key,
    required this.audioUrl,
    this.title = 'Audio',
  });

  @override
  State<AudioPlayerWidget> createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _isLoading = false;
  Timer? _progressTimer;

  Future<void> _init() async {
    if (_isLoading || _isInitialized) return;
    setState(() => _isLoading = true);
    try {
      final ctrl = VideoPlayerController.networkUrl(Uri.parse(widget.audioUrl));
      await ctrl.initialize();
      _progressTimer = Timer.periodic(const Duration(milliseconds: 500), (_) {
        if (mounted) setState(() {});
      });
      if (mounted) {
        setState(() {
          _controller = ctrl;
          _isInitialized = true;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _progressTimer?.cancel();
    _controller?.dispose();
    super.dispose();
  }

  String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final isDigital = context.watch<ThemeProvider>().isDigital;
    final primary = AppColors.adaptivePrimary(isDigital);
    final textSub = AppColors.textSubFor(isDigital);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor(isDigital),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDigital ? AppColors.digBorder : AppColors.tradBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.music_note, size: 18, color: primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: AppColors.textFor(isDigital),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (!_isInitialized)
            Center(
              child: _isLoading
                  ? SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2, color: primary),
                    )
                  : IconButton(
                      icon: const Icon(Icons.play_circle_outline, size: 40),
                      color: primary,
                      onPressed: _init,
                    ),
            )
          else ...[
            Row(
              children: [
                IconButton(
                  icon: Icon(
                    _controller!.value.isPlaying ? Icons.pause_circle : Icons.play_circle,
                    size: 36,
                  ),
                  color: primary,
                  onPressed: () {
                    if (_controller!.value.isPlaying) {
                      _controller!.pause();
                    } else {
                      _controller!.play();
                    }
                    setState(() {});
                  },
                ),
                Expanded(
                  child: Slider(
                    value: _controller!.value.position.inMilliseconds.toDouble(),
                    min: 0,
                    max: _controller!.value.duration.inMilliseconds
                        .toDouble()
                        .clamp(1, double.infinity),
                    onChanged: (v) {
                      _controller!.seekTo(Duration(milliseconds: v.toInt()));
                      setState(() {});
                    },
                    activeColor: primary,
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(_fmt(_controller!.value.position),
                      style: TextStyle(fontSize: 11, color: textSub)),
                  Text(_fmt(_controller!.value.duration),
                      style: TextStyle(fontSize: 11, color: textSub)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
