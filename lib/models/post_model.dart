enum PostType { image, text, poll, idea, flash, video, audio }

enum PostCategory { traditional, digital }

enum AiModerationStatus { pending, approved, rejected }

enum PostStatus { live, underReview, rejected }

class PostModel {
  final String postId;
  final String uid;
  final String authorName;
  final String? authorPhotoURL;
  final String authorUsername;
  final PostType type;
  final PostCategory category;
  final String content;
  final String? caption;
  final String? mediaURL;
  final List<String> hashtags;
  final String? identityHashtag;
  final List<String> pollOptions;
  final Map<String, int> pollVotes;
  final bool commentsEnabled;
  final double ratingSum;
  final int ratingCount;
  final double ratingAvg;
  final bool isCompetitionEntry;
  final String? competitionId;
  final AiModerationStatus aiModerationStatus;
  final String? aiModerationNote;
  final double? aiJudgeScore;
  final int shareCount;
  final int saveCount;
  final int reportCount;
  final PostStatus status;
  final DateTime createdAt;
  final DateTime? ratingLockedUntil;
  final DateTime? editableAfter;
  final bool isFlash;
  final List<String> flashViewedBy;
  final DateTime? flashExpiresAt;
  final String locationCity;
  final String locationState;
  final String locationCountry;
  final String locationDisplay;
  final double locationLat;
  final double locationLng;
  final bool hasLocation;
  final String thumbnailURL;
  final int videoDuration;
  final String audioTitle;
  final bool isDeleted;
  final DateTime? deletedAt;
  final String? deletionReason;
  final int viewsAtDeletion;
  final double ratingAtDeletion;
  final bool isPollPost;

  const PostModel({
    required this.postId,
    required this.uid,
    required this.authorName,
    this.authorPhotoURL,
    required this.authorUsername,
    this.type = PostType.text,
    this.category = PostCategory.traditional,
    required this.content,
    this.caption,
    this.mediaURL,
    this.hashtags = const [],
    this.identityHashtag,
    this.pollOptions = const [],
    this.pollVotes = const {},
    this.commentsEnabled = true,
    this.ratingSum = 0.0,
    this.ratingCount = 0,
    this.ratingAvg = 0.0,
    this.isCompetitionEntry = false,
    this.competitionId,
    this.aiModerationStatus = AiModerationStatus.pending,
    this.aiModerationNote,
    this.aiJudgeScore,
    this.shareCount = 0,
    this.saveCount = 0,
    this.reportCount = 0,
    this.status = PostStatus.live,
    required this.createdAt,
    this.ratingLockedUntil,
    this.editableAfter,
    this.isFlash = false,
    this.flashViewedBy = const [],
    this.flashExpiresAt,
    this.locationCity = '',
    this.locationState = '',
    this.locationCountry = '',
    this.locationDisplay = '',
    this.locationLat = 0.0,
    this.locationLng = 0.0,
    this.hasLocation = false,
    this.thumbnailURL = '',
    this.videoDuration = 0,
    this.audioTitle = '',
    this.isDeleted = false,
    this.deletedAt,
    this.deletionReason,
    this.viewsAtDeletion = 0,
    this.ratingAtDeletion = 0.0,
    this.isPollPost = false,
  });

  static DateTime _parseDate(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    try { return (value as dynamic).toDate() as DateTime; } catch (_) {}
    return DateTime.now();
  }

  factory PostModel.fromMap(Map<String, dynamic> map, String postId) {
    return PostModel(
      postId: postId,
      uid: map['uid'] ?? '',
      authorName: map['authorName'] ?? '',
      authorPhotoURL: map['authorPhotoURL'],
      authorUsername: map['authorUsername'] ?? '',
      type: PostType.values.firstWhere(
        (e) => e.name == (map['type'] ?? 'text'),
        orElse: () => PostType.text,
      ),
      category: PostCategory.values.firstWhere(
        (e) => e.name == (map['category'] ?? 'traditional'),
        orElse: () => PostCategory.traditional,
      ),
      content: map['content'] ?? '',
      caption: map['caption'],
      mediaURL: map['mediaURL'],
      hashtags: List<String>.from(map['hashtags'] ?? []),
      identityHashtag: map['identityHashtag'],
      pollOptions: List<String>.from(map['pollOptions'] ?? []),
      pollVotes: Map<String, int>.from(map['pollVotes'] ?? {}),
      commentsEnabled: map['commentsEnabled'] ?? true,
      ratingSum: (map['ratingSum'] ?? 0.0).toDouble(),
      ratingCount: (map['ratingCount'] ?? 0) as int,
      ratingAvg: (map['ratingAvg'] ?? 0.0).toDouble(),
      isCompetitionEntry: map['isCompetitionEntry'] ?? false,
      competitionId: map['competitionId'],
      aiModerationStatus: AiModerationStatus.values.firstWhere(
        (e) => e.name == (map['aiModerationStatus'] ?? 'approved'),
        orElse: () => AiModerationStatus.approved,
      ),
      aiModerationNote: map['aiModerationNote'],
      aiJudgeScore: map['aiJudgeScore'] != null
          ? (map['aiJudgeScore']).toDouble()
          : null,
      shareCount: (map['shareCount'] ?? 0) as int,
      saveCount: (map['saveCount'] ?? 0) as int,
      reportCount: (map['reportCount'] ?? 0) as int,
      status: PostStatus.values.firstWhere(
        (e) => e.name == (map['status'] ?? 'live'),
        orElse: () => PostStatus.live,
      ),
      createdAt: _parseDate(map['createdAt']),
      ratingLockedUntil: map['ratingLockedUntil'] != null
          ? _parseDate(map['ratingLockedUntil'])
          : null,
      editableAfter: map['editableAfter'] != null
          ? _parseDate(map['editableAfter'])
          : null,
      isFlash: map['isFlash'] ?? false,
      flashViewedBy: List<String>.from(map['flashViewedBy'] ?? []),
      flashExpiresAt: map['flashExpiresAt'] != null
          ? _parseDate(map['flashExpiresAt'])
          : null,
      locationCity: map['locationCity'] ?? '',
      locationState: map['locationState'] ?? '',
      locationCountry: map['locationCountry'] ?? '',
      locationDisplay: map['locationDisplay'] ?? '',
      locationLat: (map['locationLat'] ?? 0.0).toDouble(),
      locationLng: (map['locationLng'] ?? 0.0).toDouble(),
      hasLocation: map['hasLocation'] ?? false,
      thumbnailURL: map['thumbnailURL'] ?? '',
      videoDuration: (map['videoDuration'] ?? 0) as int,
      audioTitle: map['audioTitle'] ?? '',
      isDeleted: map['isDeleted'] ?? false,
      deletedAt: map['deletedAt'] != null ? _parseDate(map['deletedAt']) : null,
      deletionReason: map['deletionReason'],
      viewsAtDeletion: (map['viewsAtDeletion'] ?? 0) as int,
      ratingAtDeletion: (map['ratingAtDeletion'] ?? 0.0).toDouble(),
      isPollPost: map['isPollPost'] ?? false,
    );
  }

  Map<String, dynamic> toMap() => {
        'uid': uid,
        'authorName': authorName,
        'authorPhotoURL': authorPhotoURL,
        'authorUsername': authorUsername,
        'type': type.name,
        'category': category.name,
        'content': content,
        'caption': caption,
        'mediaURL': mediaURL,
        'hashtags': hashtags,
        'identityHashtag': identityHashtag,
        'pollOptions': pollOptions,
        'pollVotes': pollVotes,
        'commentsEnabled': commentsEnabled,
        'ratingSum': ratingSum,
        'ratingCount': ratingCount,
        'ratingAvg': ratingAvg,
        'isCompetitionEntry': isCompetitionEntry,
        'competitionId': competitionId,
        'aiModerationStatus': aiModerationStatus.name,
        'aiModerationNote': aiModerationNote,
        'aiJudgeScore': aiJudgeScore,
        'shareCount': shareCount,
        'saveCount': saveCount,
        'reportCount': reportCount,
        'status': status.name,
        'createdAt': createdAt.toIso8601String(),
        'ratingLockedUntil': ratingLockedUntil?.toIso8601String(),
        'editableAfter': editableAfter?.toIso8601String(),
        'isFlash': isFlash,
        'flashViewedBy': flashViewedBy,
        'flashExpiresAt': flashExpiresAt?.toIso8601String(),
        'locationCity': locationCity,
        'locationState': locationState,
        'locationCountry': locationCountry,
        'locationDisplay': locationDisplay,
        'locationLat': locationLat,
        'locationLng': locationLng,
        'hasLocation': hasLocation,
        'thumbnailURL': thumbnailURL,
        'videoDuration': videoDuration,
        'audioTitle': audioTitle,
        'isDeleted': isDeleted,
        'deletedAt': deletedAt?.toIso8601String(),
        'deletionReason': deletionReason,
        'viewsAtDeletion': viewsAtDeletion,
        'ratingAtDeletion': ratingAtDeletion,
        'isPollPost': isPollPost,
      };

  PostModel copyWith({
    String? authorName,
    String? authorPhotoURL,
    String? authorUsername,
    PostType? type,
    PostCategory? category,
    String? content,
    String? caption,
    String? mediaURL,
    List<String>? hashtags,
    String? identityHashtag,
    List<String>? pollOptions,
    Map<String, int>? pollVotes,
    bool? commentsEnabled,
    double? ratingSum,
    int? ratingCount,
    double? ratingAvg,
    bool? isCompetitionEntry,
    String? competitionId,
    AiModerationStatus? aiModerationStatus,
    String? aiModerationNote,
    double? aiJudgeScore,
    int? shareCount,
    int? saveCount,
    int? reportCount,
    PostStatus? status,
    DateTime? ratingLockedUntil,
    DateTime? editableAfter,
    bool? isFlash,
    List<String>? flashViewedBy,
    DateTime? flashExpiresAt,
    String? locationCity,
    String? locationState,
    String? locationCountry,
    String? locationDisplay,
    double? locationLat,
    double? locationLng,
    bool? hasLocation,
    String? thumbnailURL,
    int? videoDuration,
    String? audioTitle,
    bool? isDeleted,
    DateTime? deletedAt,
    String? deletionReason,
    int? viewsAtDeletion,
    double? ratingAtDeletion,
    bool? isPollPost,
  }) {
    return PostModel(
      postId: postId,
      uid: uid,
      authorName: authorName ?? this.authorName,
      authorPhotoURL: authorPhotoURL ?? this.authorPhotoURL,
      authorUsername: authorUsername ?? this.authorUsername,
      type: type ?? this.type,
      category: category ?? this.category,
      content: content ?? this.content,
      caption: caption ?? this.caption,
      mediaURL: mediaURL ?? this.mediaURL,
      hashtags: hashtags ?? this.hashtags,
      identityHashtag: identityHashtag ?? this.identityHashtag,
      pollOptions: pollOptions ?? this.pollOptions,
      pollVotes: pollVotes ?? this.pollVotes,
      commentsEnabled: commentsEnabled ?? this.commentsEnabled,
      ratingSum: ratingSum ?? this.ratingSum,
      ratingCount: ratingCount ?? this.ratingCount,
      ratingAvg: ratingAvg ?? this.ratingAvg,
      isCompetitionEntry: isCompetitionEntry ?? this.isCompetitionEntry,
      competitionId: competitionId ?? this.competitionId,
      aiModerationStatus: aiModerationStatus ?? this.aiModerationStatus,
      aiModerationNote: aiModerationNote ?? this.aiModerationNote,
      aiJudgeScore: aiJudgeScore ?? this.aiJudgeScore,
      shareCount: shareCount ?? this.shareCount,
      saveCount: saveCount ?? this.saveCount,
      reportCount: reportCount ?? this.reportCount,
      status: status ?? this.status,
      createdAt: createdAt,
      ratingLockedUntil: ratingLockedUntil ?? this.ratingLockedUntil,
      editableAfter: editableAfter ?? this.editableAfter,
      isFlash: isFlash ?? this.isFlash,
      flashViewedBy: flashViewedBy ?? this.flashViewedBy,
      flashExpiresAt: flashExpiresAt ?? this.flashExpiresAt,
      locationCity: locationCity ?? this.locationCity,
      locationState: locationState ?? this.locationState,
      locationCountry: locationCountry ?? this.locationCountry,
      locationDisplay: locationDisplay ?? this.locationDisplay,
      locationLat: locationLat ?? this.locationLat,
      locationLng: locationLng ?? this.locationLng,
      hasLocation: hasLocation ?? this.hasLocation,
      thumbnailURL: thumbnailURL ?? this.thumbnailURL,
      videoDuration: videoDuration ?? this.videoDuration,
      audioTitle: audioTitle ?? this.audioTitle,
      isDeleted: isDeleted ?? this.isDeleted,
      deletedAt: deletedAt ?? this.deletedAt,
      deletionReason: deletionReason ?? this.deletionReason,
      viewsAtDeletion: viewsAtDeletion ?? this.viewsAtDeletion,
      ratingAtDeletion: ratingAtDeletion ?? this.ratingAtDeletion,
      isPollPost: isPollPost ?? this.isPollPost,
    );
  }
}
