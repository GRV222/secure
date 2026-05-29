import 'package:cloud_firestore/cloud_firestore.dart';

class StoryModel {
  final String storyId;
  final String uid;
  final String authorName;
  final String authorUsername;
  final String authorPhotoURL;
  final String content;
  final String mediaURL;
  final String type; // quick, work, competition
  final String category; // traditional, digital
  final String identityHashtag;
  final String hashtag;
  final String journeyId;
  final String reaction;
  final List<String> viewedBy;
  final List<String> respectBy;
  final List<String> loveBy;
  final DateTime createdAt;
  final DateTime expiresAt;
  final bool isExpired;
  final bool savedToJourney;

  StoryModel({
    required this.storyId,
    required this.uid,
    required this.authorName,
    required this.authorUsername,
    required this.authorPhotoURL,
    required this.content,
    required this.mediaURL,
    required this.type,
    required this.category,
    required this.identityHashtag,
    required this.hashtag,
    required this.journeyId,
    required this.viewedBy,
    required this.respectBy,
    required this.loveBy,
    required this.createdAt,
    required this.expiresAt,
    this.reaction = '',
    this.isExpired = false,
    this.savedToJourney = false,
  });

  factory StoryModel.fromMap(Map<String, dynamic> data) {
    DateTime parseDate(dynamic value) {
      if (value == null) return DateTime.now();
      if (value is Timestamp) return value.toDate();
      if (value is String) {
        try {
          return DateTime.parse(value);
        } catch (_) {}
      }
      return DateTime.now();
    }

    return StoryModel(
      storyId: data['storyId'] ?? '',
      uid: data['uid'] ?? '',
      authorName: data['authorName'] ?? '',
      authorUsername: data['authorUsername'] ?? '',
      authorPhotoURL: data['authorPhotoURL'] ?? '',
      content: data['content'] ?? '',
      mediaURL: data['mediaURL'] ?? '',
      type: data['type'] ?? 'quick',
      category: data['category'] ?? 'traditional',
      identityHashtag: data['identityHashtag'] ?? '',
      hashtag: data['hashtag'] ?? '',
      journeyId: data['journeyId'] ?? '',
      viewedBy: List<String>.from(data['viewedBy'] ?? []),
      respectBy: List<String>.from(data['respectBy'] ?? []),
      loveBy: List<String>.from(data['loveBy'] ?? []),
      createdAt: parseDate(data['createdAt']),
      expiresAt: parseDate(data['expiresAt']),
      reaction: data['reaction'] ?? '',
      isExpired: data['isExpired'] ?? false,
      savedToJourney: data['savedToJourney'] ?? false,
    );
  }

  Map<String, dynamic> toMap() => {
        'storyId': storyId,
        'uid': uid,
        'authorName': authorName,
        'authorUsername': authorUsername,
        'authorPhotoURL': authorPhotoURL,
        'content': content,
        'mediaURL': mediaURL,
        'type': type,
        'category': category,
        'identityHashtag': identityHashtag,
        'hashtag': hashtag,
        'journeyId': journeyId,
        'viewedBy': viewedBy,
        'respectBy': respectBy,
        'loveBy': loveBy,
        'createdAt': createdAt.toIso8601String(),
        'expiresAt': expiresAt.toIso8601String(),
        'reaction': reaction,
        'isExpired': isExpired,
        'savedToJourney': savedToJourney,
      };
}
