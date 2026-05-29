import 'package:flutter/material.dart';
import '../../../models/post_model.dart';
import '../../../core/dummy/dummy_data.dart';
import '../../../services/firestore_service.dart';
import '../../../services/time_algorithm_service.dart';

enum FeedMode { all, traditional, digital }

class FeedProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  final TimeAlgorithmService _timeAlgo = TimeAlgorithmService();

  FeedMode _mode = FeedMode.all;
  List<PostModel> _allPosts = [];
  List<PostModel> _winnerPosts = [];
  TimeSlotInfo? _currentTimeSlot;
  bool _isLoading = false;
  String? _error;
  List<String> _lastHashtags = [];

  FeedMode get mode => _mode;
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<PostModel> get winnerPosts => _winnerPosts;
  TimeSlotInfo? get currentTimeSlot => _currentTimeSlot;

  List<PostModel> get posts {
    if (_mode == FeedMode.all) return _allPosts;
    final preferred =
        _mode == FeedMode.traditional ? PostCategory.traditional : PostCategory.digital;
    return _allPosts.where((p) => p.category == preferred).toList();
  }

  Future<void> loadFeed(List<String> followedHashtags) async {
    if (_isLoading) return;
    _lastHashtags = followedHashtags;
    _isLoading = true;
    _error = null;
    notifyListeners();

    _currentTimeSlot = _timeAlgo.getTimeSlotInfo();

    try {
      final results = await Future.wait([
        _loadFeedPosts(followedHashtags),
        _firestoreService.getWinnerPosts(),
      ]);

      var feedPosts = results[0];
      _winnerPosts = results[1];

      if (feedPosts.isEmpty) {
        feedPosts = await _firestoreService.getAllRecentPosts(limit: 20);
      }
      if (feedPosts.isEmpty) feedPosts = DummyData.dummyPosts;

      _allPosts = _timeAlgo.sortByTimeRelevance(feedPosts);

      if (_winnerPosts.isEmpty) {
        final sorted = [...DummyData.dummyPosts]
          ..sort((a, b) => b.ratingAvg.compareTo(a.ratingAvg));
        _winnerPosts = sorted.take(5).toList();
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Feed load error: $e');
      _isLoading = false;
      if (_allPosts.isEmpty) _allPosts = DummyData.dummyPosts;
      if (_winnerPosts.isEmpty) {
        _winnerPosts = DummyData.dummyPosts.take(3).toList();
      }
      notifyListeners();
    }
  }

  Future<List<PostModel>> _loadFeedPosts(List<String> followedHashtags) async {
    if (followedHashtags.isEmpty) return [];
    return _firestoreService.getFeedPosts(followedHashtags: followedHashtags);
  }

  Future<void> refresh() => loadFeed(_lastHashtags);

  void addPost(PostModel post) {
    _allPosts = [post, ..._allPosts];
    notifyListeners();
  }

  void setMode(FeedMode mode) {
    if (_mode == mode) return;
    _mode = mode;
    notifyListeners();
  }

  void startListening() => refresh();
  void stopListening() {}
}
