import 'package:flutter/material.dart';
import '../../../models/competition_model.dart';
import '../../../models/post_model.dart';
import '../../../services/firestore_service.dart';
import '../../../core/dummy/dummy_data.dart';

class CompetitionProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  List<CompetitionModel> _activeCompetitions = [];
  List<CompetitionModel> _pastCompetitions = [];
  List<PostModel> _leaderboard = [];
  bool _isLoading = false;
  String? _error;

  List<CompetitionModel> get activeCompetitions => _activeCompetitions;
  List<CompetitionModel> get pastCompetitions => _pastCompetitions;
  List<PostModel> get leaderboard => _leaderboard;
  bool get isLoading => _isLoading;
  String? get error => _error;

  static final List<CompetitionModel> _dummyActiveComps = [
    CompetitionModel(
      competitionId: 'comp_skatchart_may2026',
      title: '#skatchart May Competition',
      hashtag: 'skatchart',
      category: CompetitionCategory.traditional,
      month: 'May 2026',
      startDate: DateTime(2026, 5, 1),
      ratingDeadline: DateTime(2026, 5, 25),
      endDate: DateTime(2026, 5, 31),
      participantCount: 1247,
    ),
    CompetitionModel(
      competitionId: 'comp_digitalportrait_may2026',
      title: '#digitalportrait May Competition',
      hashtag: 'digitalportrait',
      category: CompetitionCategory.digital,
      month: 'May 2026',
      startDate: DateTime(2026, 5, 1),
      ratingDeadline: DateTime(2026, 5, 25),
      endDate: DateTime(2026, 5, 31),
      participantCount: 654,
    ),
    CompetitionModel(
      competitionId: 'comp_tabla_may2026',
      title: '#tabla May Competition',
      hashtag: 'tabla',
      category: CompetitionCategory.traditional,
      month: 'May 2026',
      startDate: DateTime(2026, 5, 1),
      ratingDeadline: DateTime(2026, 5, 25),
      endDate: DateTime(2026, 5, 31),
      participantCount: 445,
    ),
    CompetitionModel(
      competitionId: 'comp_canvapainting_may2026',
      title: '#canvapainting May Competition',
      hashtag: 'canvapainting',
      category: CompetitionCategory.traditional,
      month: 'May 2026',
      startDate: DateTime(2026, 5, 1),
      ratingDeadline: DateTime(2026, 5, 25),
      endDate: DateTime(2026, 5, 31),
      participantCount: 892,
    ),
    CompetitionModel(
      competitionId: 'comp_skatchartflowers_may2026',
      title: '#skatchartflowers May Competition',
      hashtag: 'skatchartflowers',
      category: CompetitionCategory.traditional,
      month: 'May 2026',
      startDate: DateTime(2026, 5, 1),
      ratingDeadline: DateTime(2026, 5, 25),
      endDate: DateTime(2026, 5, 31),
      participantCount: 423,
    ),
  ];

  static final List<CompetitionModel> _dummyPastComps = [
    CompetitionModel(
      competitionId: 'comp_skatchart_apr2026',
      title: '#skatchart April Competition',
      hashtag: 'skatchart',
      category: CompetitionCategory.traditional,
      month: 'April 2026',
      startDate: DateTime(2026, 4, 1),
      ratingDeadline: DateTime(2026, 4, 25),
      endDate: DateTime(2026, 4, 30),
      status: CompetitionStatus.completed,
      winnerId: 'user_004',
      participantCount: 1100,
    ),
    CompetitionModel(
      competitionId: 'comp_tabla_mar2026',
      title: '#tabla March Competition',
      hashtag: 'tabla',
      category: CompetitionCategory.traditional,
      month: 'March 2026',
      startDate: DateTime(2026, 3, 1),
      ratingDeadline: DateTime(2026, 3, 25),
      endDate: DateTime(2026, 3, 31),
      status: CompetitionStatus.completed,
      winnerId: 'user_005',
      participantCount: 389,
    ),
    CompetitionModel(
      competitionId: 'comp_canvapainting_feb2026',
      title: '#canvapainting February Competition',
      hashtag: 'canvapainting',
      category: CompetitionCategory.traditional,
      month: 'February 2026',
      startDate: DateTime(2026, 2, 1),
      ratingDeadline: DateTime(2026, 2, 25),
      endDate: DateTime(2026, 2, 28),
      status: CompetitionStatus.completed,
      winnerId: 'user_002',
      participantCount: 756,
    ),
  ];

  Future<void> loadCompetitions() async {
    _isLoading = true;
    notifyListeners();
    try {
      final active = await _firestoreService.getActiveCompetitions();
      _activeCompetitions = active.isEmpty ? _dummyActiveComps : active;
      final past = await _firestoreService.getPastCompetitions();
      _pastCompetitions = past.isEmpty ? _dummyPastComps : past;
    } catch (_) {
      _activeCompetitions = _dummyActiveComps;
      _pastCompetitions = _dummyPastComps;
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadLeaderboard(String hashtag) async {
    _isLoading = true;
    notifyListeners();
    try {
      final posts = await _firestoreService.getLeaderboard(hashtag);
      if (posts.isEmpty) {
        _leaderboard = DummyData.dummyPosts
            .where((p) => p.hashtags.contains(hashtag))
            .toList()
          ..sort((a, b) => b.ratingAvg.compareTo(a.ratingAvg));
      } else {
        _leaderboard = posts;
      }
    } catch (_) {
      _leaderboard = DummyData.dummyPosts
          .where((p) => p.hashtags.contains(hashtag))
          .toList()
        ..sort((a, b) => b.ratingAvg.compareTo(a.ratingAvg));
    }
    _isLoading = false;
    notifyListeners();
  }
}
