import 'package:cloud_firestore/cloud_firestore.dart';

class JourneyModel {
  final String journeyId;
  final String uid;
  final String title;
  final String description;
  final String category;
  final String hashtag;
  final List<String> storyIds;
  final int dayCount;
  final DateTime startDate;
  final DateTime lastUpdated;
  final bool isActive;

  JourneyModel({
    required this.journeyId,
    required this.uid,
    required this.title,
    required this.description,
    required this.category,
    required this.hashtag,
    required this.storyIds,
    required this.dayCount,
    required this.startDate,
    required this.lastUpdated,
    required this.isActive,
  });

  factory JourneyModel.fromMap(Map<String, dynamic> data) {
    DateTime parseDate(dynamic value) {
      if (value == null) return DateTime.now();
      if (value is Timestamp) return value.toDate();
      return DateTime.now();
    }

    return JourneyModel(
      journeyId: data['journeyId'] ?? '',
      uid: data['uid'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      category: data['category'] ?? 'traditional',
      hashtag: data['hashtag'] ?? '',
      storyIds: List<String>.from(data['storyIds'] ?? []),
      dayCount: (data['dayCount'] ?? 0) as int,
      startDate: parseDate(data['startDate']),
      lastUpdated: parseDate(data['lastUpdated']),
      isActive: data['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toMap() => {
        'journeyId': journeyId,
        'uid': uid,
        'title': title,
        'description': description,
        'category': category,
        'hashtag': hashtag,
        'storyIds': storyIds,
        'dayCount': dayCount,
        'startDate': startDate.toIso8601String(),
        'lastUpdated': lastUpdated.toIso8601String(),
        'isActive': isActive,
      };
}
