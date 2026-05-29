class HashtagModel {
  final String name;
  final int postCount;
  final int followerCount;
  final bool isCompetitionTag;
  final String? competitionId;
  final String? category;
  final DateTime createdAt;
  final String createdBy;

  const HashtagModel({
    required this.name,
    this.postCount = 0,
    this.followerCount = 0,
    this.isCompetitionTag = false,
    this.competitionId,
    this.category,
    required this.createdAt,
    required this.createdBy,
  });

  static DateTime _parseDate(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    try { return (value as dynamic).toDate() as DateTime; } catch (_) {}
    return DateTime.now();
  }

  factory HashtagModel.fromMap(Map<String, dynamic> map, String name) {
    return HashtagModel(
      name: name,
      postCount: (map['postCount'] ?? 0) as int,
      followerCount: (map['followerCount'] ?? 0) as int,
      isCompetitionTag: map['isCompetitionTag'] ?? false,
      competitionId: map['competitionId'],
      category: map['category'],
      createdAt: _parseDate(map['createdAt']),
      createdBy: map['createdBy'] ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
        'postCount': postCount,
        'followerCount': followerCount,
        'isCompetitionTag': isCompetitionTag,
        'competitionId': competitionId,
        'category': category,
        'createdAt': createdAt.toIso8601String(),
        'createdBy': createdBy,
      };

  HashtagModel copyWith({
    int? postCount,
    int? followerCount,
    bool? isCompetitionTag,
    String? competitionId,
    String? category,
    DateTime? createdAt,
    String? createdBy,
  }) {
    return HashtagModel(
      name: name,
      postCount: postCount ?? this.postCount,
      followerCount: followerCount ?? this.followerCount,
      isCompetitionTag: isCompetitionTag ?? this.isCompetitionTag,
      competitionId: competitionId ?? this.competitionId,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
    );
  }
}
