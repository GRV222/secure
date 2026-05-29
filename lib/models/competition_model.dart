enum CompetitionCategory { traditional, digital }

enum CompetitionStatus { active, calculating, completed }

class CompetitionModel {
  final String competitionId;
  final String title;
  final String hashtag;
  final CompetitionCategory category;
  final String month;
  final DateTime startDate;
  final DateTime ratingDeadline;
  final DateTime endDate;
  final CompetitionStatus status;
  final double prizeShreeda;
  final double prizeShree;
  final double prizeDa;
  final String? winnerId;
  final String? winnerPostId;
  final int participantCount;

  const CompetitionModel({
    required this.competitionId,
    required this.title,
    required this.hashtag,
    required this.category,
    required this.month,
    required this.startDate,
    required this.ratingDeadline,
    required this.endDate,
    this.status = CompetitionStatus.active,
    this.prizeShreeda = 0.0,
    this.prizeShree = 0.0,
    this.prizeDa = 0.0,
    this.winnerId,
    this.winnerPostId,
    this.participantCount = 0,
  });

  static DateTime _parseDate(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    try { return (value as dynamic).toDate() as DateTime; } catch (_) {}
    return DateTime.now();
  }

  factory CompetitionModel.fromMap(Map<String, dynamic> map, String competitionId) {
    return CompetitionModel(
      competitionId: competitionId,
      title: map['title'] ?? '',
      hashtag: map['hashtag'] ?? '',
      category: CompetitionCategory.values.firstWhere(
        (e) => e.name == (map['category'] ?? 'traditional'),
        orElse: () => CompetitionCategory.traditional,
      ),
      month: map['month'] ?? '',
      startDate: _parseDate(map['startDate']),
      ratingDeadline: _parseDate(map['ratingDeadline']),
      endDate: _parseDate(map['endDate']),
      status: CompetitionStatus.values.firstWhere(
        (e) => e.name == (map['status'] ?? 'active'),
        orElse: () => CompetitionStatus.active,
      ),
      prizeShreeda: (map['prizeShreeda'] ?? 0.0).toDouble(),
      prizeShree: (map['prizeShree'] ?? 0.0).toDouble(),
      prizeDa: (map['prizeDa'] ?? 0.0).toDouble(),
      winnerId: map['winnerId'],
      winnerPostId: map['winnerPostId'],
      participantCount: (map['participantCount'] ?? 0) as int,
    );
  }

  Map<String, dynamic> toMap() => {
        'title': title,
        'hashtag': hashtag,
        'category': category.name,
        'month': month,
        'startDate': startDate.toIso8601String(),
        'ratingDeadline': ratingDeadline.toIso8601String(),
        'endDate': endDate.toIso8601String(),
        'status': status.name,
        'prizeShreeda': prizeShreeda,
        'prizeShree': prizeShree,
        'prizeDa': prizeDa,
        'winnerId': winnerId,
        'winnerPostId': winnerPostId,
        'participantCount': participantCount,
      };

  CompetitionModel copyWith({
    String? title,
    String? hashtag,
    CompetitionCategory? category,
    String? month,
    DateTime? startDate,
    DateTime? ratingDeadline,
    DateTime? endDate,
    CompetitionStatus? status,
    double? prizeShreeda,
    double? prizeShree,
    double? prizeDa,
    String? winnerId,
    String? winnerPostId,
    int? participantCount,
  }) {
    return CompetitionModel(
      competitionId: competitionId,
      title: title ?? this.title,
      hashtag: hashtag ?? this.hashtag,
      category: category ?? this.category,
      month: month ?? this.month,
      startDate: startDate ?? this.startDate,
      ratingDeadline: ratingDeadline ?? this.ratingDeadline,
      endDate: endDate ?? this.endDate,
      status: status ?? this.status,
      prizeShreeda: prizeShreeda ?? this.prizeShreeda,
      prizeShree: prizeShree ?? this.prizeShree,
      prizeDa: prizeDa ?? this.prizeDa,
      winnerId: winnerId ?? this.winnerId,
      winnerPostId: winnerPostId ?? this.winnerPostId,
      participantCount: participantCount ?? this.participantCount,
    );
  }
}
