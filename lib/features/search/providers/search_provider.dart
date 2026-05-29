import 'package:flutter/material.dart';
import '../../../models/user_model.dart';
import '../../../models/post_model.dart';
import '../../../models/hashtag_model.dart';
import '../../../services/firestore_service.dart';
import '../../../core/dummy/dummy_data.dart';

enum SearchTab { posts, users, hashtags }

class SearchProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  String _query = '';
  SearchTab _activeTab = SearchTab.posts;
  List<PostModel> _postResults = [];
  List<UserModel> _userResults = [];
  List<HashtagModel> _hashtagResults = [];
  List<HashtagModel> _trending = [];
  bool _isLoading = false;
  String? _error;

  String get query => _query;
  SearchTab get activeTab => _activeTab;
  List<PostModel> get postResults => _postResults;
  List<UserModel> get userResults => _userResults;
  List<HashtagModel> get hashtagResults => _hashtagResults;
  List<HashtagModel> get trendingHashtags => _trending;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void setTab(SearchTab tab) {
    _activeTab = tab;
    notifyListeners();
  }

  Future<void> loadTrending() async {
    try {
      final fetched = await _firestoreService.getTrendingHashtags(limit: 10);
      _trending = fetched.isEmpty ? DummyData.dummyHashtags : fetched;
      notifyListeners();
    } catch (_) {
      _trending = DummyData.dummyHashtags;
      notifyListeners();
    }
  }

  Future<void> search(String query) async {
    _query = query;
    if (query.isEmpty) {
      _postResults = [];
      _userResults = [];
      _hashtagResults = [];
      notifyListeners();
      return;
    }
    _isLoading = true;
    notifyListeners();
    try {
      _hashtagResults = await _firestoreService.searchHashtags(query);
      if (_hashtagResults.isEmpty) {
        final q = query.toLowerCase();
        _hashtagResults = DummyData.dummyHashtags
            .where((h) => h.name.toLowerCase().contains(q))
            .toList();
      }
      _userResults = await _firestoreService.searchUsers(query);
      if (_userResults.isEmpty) {
        final q = query.toLowerCase();
        _userResults = DummyData.dummySeedUsers
            .where((u) =>
                u.displayName.toLowerCase().contains(q) ||
                u.username.toLowerCase().contains(q))
            .toList();
      }
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearSearch() {
    _query = '';
    _postResults = [];
    _userResults = [];
    _hashtagResults = [];
    notifyListeners();
  }
}
