import 'package:flutter/material.dart';
import '../../../models/post_model.dart';
import '../../../services/firestore_service.dart';

class PostProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<PostModel?> createPost({
    required String uid,
    required String authorName,
    required String authorUsername,
    String? authorPhotoURL,
    required PostType type,
    required PostCategory category,
    required String content,
    String? caption,
    String? mediaURL,
    List<String> hashtags = const [],
    String? identityHashtag,
    bool commentsEnabled = true,
    String locationCity = '',
    String locationState = '',
    String locationCountry = '',
    String locationDisplay = '',
    double locationLat = 0.0,
    double locationLng = 0.0,
    bool hasLocation = false,
    String thumbnailURL = '',
    int videoDuration = 0,
    String audioTitle = '',
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final now = DateTime.now();
      final draft = PostModel(
        postId: '',
        uid: uid,
        authorName: authorName,
        authorUsername: authorUsername,
        authorPhotoURL: authorPhotoURL,
        type: type,
        category: category,
        content: content,
        caption: caption,
        mediaURL: mediaURL,
        hashtags: hashtags,
        identityHashtag: identityHashtag,
        commentsEnabled: commentsEnabled,
        createdAt: now,
        locationCity: locationCity,
        locationState: locationState,
        locationCountry: locationCountry,
        locationDisplay: locationDisplay,
        locationLat: locationLat,
        locationLng: locationLng,
        hasLocation: hasLocation,
        thumbnailURL: thumbnailURL,
        videoDuration: videoDuration,
        audioTitle: audioTitle,
      );
      final postId = await _firestoreService.createPost(draft);
      _isLoading = false;
      notifyListeners();
      return PostModel(
        postId: postId,
        uid: uid,
        authorName: authorName,
        authorUsername: authorUsername,
        authorPhotoURL: authorPhotoURL,
        type: type,
        category: category,
        content: content,
        caption: caption,
        mediaURL: mediaURL,
        hashtags: hashtags,
        identityHashtag: identityHashtag,
        commentsEnabled: commentsEnabled,
        createdAt: now,
        locationCity: locationCity,
        locationState: locationState,
        locationCountry: locationCountry,
        locationDisplay: locationDisplay,
        locationLat: locationLat,
        locationLng: locationLng,
        hasLocation: hasLocation,
        thumbnailURL: thumbnailURL,
        videoDuration: videoDuration,
        audioTitle: audioTitle,
      );
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  Future<PostModel?> getPost(String postId) async {
    try {
      return await _firestoreService.getPost(postId);
    } catch (_) {
      return null;
    }
  }

  Future<bool> ratePost(String postId, String uid, int rating) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _firestoreService.ratePost(postId, uid, rating);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<int?> getUserRating(String postId, String uid) async {
    try {
      return await _firestoreService.getUserRating(postId, uid);
    } catch (_) {
      return null;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
