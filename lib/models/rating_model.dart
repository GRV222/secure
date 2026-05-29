class RatingModel {
  final String postId;
  final String uid;
  final int stars;
  final DateTime createdAt;

  const RatingModel({
    required this.postId,
    required this.uid,
    required this.stars,
    required this.createdAt,
  }) : assert(stars >= 1 && stars <= 5);

  /// Firestore document ID for this rating: "{postId}_{uid}"
  String get documentId => '${postId}_$uid';

  static String buildDocumentId(String postId, String uid) =>
      '${postId}_$uid';

  factory RatingModel.fromMap(Map<String, dynamic> map) {
    return RatingModel(
      postId: map['postId'] ?? '',
      uid: map['uid'] ?? '',
      stars: (map['stars'] ?? 1).clamp(1, 5),
      createdAt: DateTime.parse(
          map['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toMap() => {
        'postId': postId,
        'uid': uid,
        'stars': stars,
        'createdAt': createdAt.toIso8601String(),
      };

  RatingModel copyWith({
    int? stars,
    DateTime? createdAt,
  }) {
    return RatingModel(
      postId: postId,
      uid: uid,
      stars: (stars ?? this.stars).clamp(1, 5),
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
