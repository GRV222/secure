import 'package:flutter/material.dart';
import '../../../models/user_model.dart';
import '../../../models/post_model.dart';
import '../../../services/firestore_service.dart';

class ProfileProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  UserModel? _profileUser;
  List<PostModel> _userPosts = [];
  bool _isLoading = false;
  String? _error;

  UserModel? get profileUser => _profileUser;
  List<PostModel> get userPosts => _userPosts;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadProfile(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _profileUser = await _firestoreService.getUser(userId);
      _userPosts = await _firestoreService.getUserPosts(userId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> followUser(String followerId, String targetId) async {
    try {
      await _firestoreService.followUser(followerId, targetId);
      _profileUser = await _firestoreService.getUser(targetId);
      notifyListeners();
    } catch (e) {
      debugPrint('ProfileProvider.followUser error: $e');
    }
  }

  Future<void> unfollowUser(String followerId, String targetId) async {
    try {
      await _firestoreService.unfollowUser(followerId, targetId);
      _profileUser = await _firestoreService.getUser(targetId);
      notifyListeners();
    } catch (e) {
      debugPrint('ProfileProvider.unfollowUser error: $e');
    }
  }
}
