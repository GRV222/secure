enum AccountType { normal, celebrity, professional, org }

enum UiMode { traditional, digital }

class UserModel {
  final String uid;
  final String displayName;
  final String username;
  final List<String> pastUsernames;
  final String email;
  final String? phone;
  final String? photoURL;
  final String? selfieURL;
  final String? bio;
  final DateTime? birthdate;
  final String? professionalRole;
  final String? artisticRole;
  final AccountType accountType;
  final UiMode uiMode;
  final bool isVerified;
  final bool fanFeatureEnabled;
  final bool dmEnabled;
  final List<String> followedHashtags;
  final List<String> savedPosts;
  final List<String> blockedUsers;
  // Dual hashtag system
  final List<String> identityHashtags;
  final List<String> followedIdentityHashtags;
  final List<String> followedCategoryHashtags;
  final List<String> postedInHashtags;
  // Token balances
  final double shreeCoinBalance;
  final double daCoinBalance;
  final double shreedaBalance;
  final double totalDaDonated;
  final int competitionWins;
  final int comparisonWins;
  final double ratingAvgLifetime;
  final DateTime createdAt;
  final String homeCity;
  final String homeState;
  final String homeCountry;
  final String homeLocationDisplay;
  // Account tier / subscription
  final bool daWalletActivated;
  final int subscriberCount;
  final bool isVerifiedByTeam;

  const UserModel({
    required this.uid,
    required this.displayName,
    required this.username,
    this.pastUsernames = const [],
    required this.email,
    this.phone,
    this.photoURL,
    this.selfieURL,
    this.bio,
    this.birthdate,
    this.professionalRole,
    this.artisticRole,
    this.accountType = AccountType.normal,
    this.uiMode = UiMode.traditional,
    this.isVerified = false,
    this.fanFeatureEnabled = false,
    this.dmEnabled = true,
    this.followedHashtags = const [],
    this.savedPosts = const [],
    this.blockedUsers = const [],
    this.identityHashtags = const [],
    this.followedIdentityHashtags = const [],
    this.followedCategoryHashtags = const [],
    this.postedInHashtags = const [],
    this.shreeCoinBalance = 0.0,
    this.daCoinBalance = 0.0,
    this.shreedaBalance = 0.0,
    this.totalDaDonated = 0.0,
    this.competitionWins = 0,
    this.comparisonWins = 0,
    this.ratingAvgLifetime = 0.0,
    required this.createdAt,
    this.homeCity = '',
    this.homeState = '',
    this.homeCountry = '',
    this.homeLocationDisplay = '',
    this.daWalletActivated = false,
    this.subscriberCount = 0,
    this.isVerifiedByTeam = false,
  });

  static DateTime _parseDate(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    try { return (value as dynamic).toDate() as DateTime; } catch (_) {}
    return DateTime.now();
  }

  factory UserModel.fromMap(Map<String, dynamic> map, String uid) {
    return UserModel(
      uid: uid,
      displayName: map['displayName'] ?? '',
      username: map['username'] ?? '',
      pastUsernames: List<String>.from(map['pastUsernames'] ?? []),
      email: map['email'] ?? '',
      phone: map['phone'],
      photoURL: map['photoURL'],
      selfieURL: map['selfieURL'],
      bio: map['bio'],
      birthdate: map['birthdate'] != null ? _parseDate(map['birthdate']) : null,
      professionalRole: map['professionalRole'],
      artisticRole: map['artisticRole'],
      accountType: AccountType.values.firstWhere(
        (e) => e.name == (map['accountType'] ?? 'normal'),
        orElse: () => AccountType.normal,
      ),
      uiMode: UiMode.values.firstWhere(
        (e) => e.name == (map['uiMode'] ?? 'traditional'),
        orElse: () => UiMode.traditional,
      ),
      isVerified: map['isVerified'] ?? false,
      fanFeatureEnabled: map['fanFeatureEnabled'] ?? false,
      dmEnabled: map['dmEnabled'] ?? true,
      followedHashtags: List<String>.from(map['followedHashtags'] ?? []),
      savedPosts: List<String>.from(map['savedPosts'] ?? []),
      blockedUsers: List<String>.from(map['blockedUsers'] ?? []),
      identityHashtags: List<String>.from(map['identityHashtags'] ?? []),
      followedIdentityHashtags: List<String>.from(map['followedIdentityHashtags'] ?? []),
      followedCategoryHashtags: List<String>.from(map['followedCategoryHashtags'] ?? []),
      postedInHashtags: List<String>.from(map['postedInHashtags'] ?? []),
      shreeCoinBalance: (map['shreeCoinBalance'] ?? 0.0).toDouble(),
      daCoinBalance: (map['daCoinBalance'] ?? 0.0).toDouble(),
      shreedaBalance: (map['shreedaBalance'] ?? 0.0).toDouble(),
      totalDaDonated: (map['totalDaDonated'] ?? 0.0).toDouble(),
      competitionWins: map['competitionWins'] ?? 0,
      comparisonWins: map['comparisonWins'] ?? 0,
      ratingAvgLifetime: (map['ratingAvgLifetime'] ?? 0.0).toDouble(),
      createdAt: _parseDate(map['createdAt']),
      homeCity: map['homeCity'] ?? '',
      homeState: map['homeState'] ?? '',
      homeCountry: map['homeCountry'] ?? '',
      homeLocationDisplay: map['homeLocationDisplay'] ?? '',
      daWalletActivated: map['daWalletActivated'] ?? false,
      subscriberCount: map['subscriberCount'] ?? 0,
      isVerifiedByTeam: map['isVerifiedByTeam'] ?? false,
    );
  }

  Map<String, dynamic> toMap() => {
        'displayName': displayName,
        'username': username,
        'pastUsernames': pastUsernames,
        'email': email,
        'phone': phone,
        'photoURL': photoURL,
        'selfieURL': selfieURL,
        'bio': bio,
        'birthdate': birthdate?.toIso8601String(),
        'professionalRole': professionalRole,
        'artisticRole': artisticRole,
        'accountType': accountType.name,
        'uiMode': uiMode.name,
        'isVerified': isVerified,
        'fanFeatureEnabled': fanFeatureEnabled,
        'dmEnabled': dmEnabled,
        'followedHashtags': followedHashtags,
        'savedPosts': savedPosts,
        'blockedUsers': blockedUsers,
        'identityHashtags': identityHashtags,
        'followedIdentityHashtags': followedIdentityHashtags,
        'followedCategoryHashtags': followedCategoryHashtags,
        'postedInHashtags': postedInHashtags,
        'shreeCoinBalance': shreeCoinBalance,
        'daCoinBalance': daCoinBalance,
        'shreedaBalance': shreedaBalance,
        'totalDaDonated': totalDaDonated,
        'competitionWins': competitionWins,
        'comparisonWins': comparisonWins,
        'ratingAvgLifetime': ratingAvgLifetime,
        'createdAt': createdAt.toIso8601String(),
        'homeCity': homeCity,
        'homeState': homeState,
        'homeCountry': homeCountry,
        'homeLocationDisplay': homeLocationDisplay,
        'daWalletActivated': daWalletActivated,
        'subscriberCount': subscriberCount,
        'isVerifiedByTeam': isVerifiedByTeam,
      };

  UserModel copyWith({
    String? displayName,
    String? username,
    List<String>? pastUsernames,
    String? email,
    String? phone,
    String? photoURL,
    String? selfieURL,
    String? bio,
    DateTime? birthdate,
    String? professionalRole,
    String? artisticRole,
    AccountType? accountType,
    UiMode? uiMode,
    bool? isVerified,
    bool? fanFeatureEnabled,
    bool? dmEnabled,
    List<String>? followedHashtags,
    List<String>? savedPosts,
    List<String>? blockedUsers,
    List<String>? identityHashtags,
    List<String>? followedIdentityHashtags,
    List<String>? followedCategoryHashtags,
    List<String>? postedInHashtags,
    double? shreeCoinBalance,
    double? daCoinBalance,
    double? shreedaBalance,
    double? totalDaDonated,
    int? competitionWins,
    int? comparisonWins,
    double? ratingAvgLifetime,
    String? homeCity,
    String? homeState,
    String? homeCountry,
    String? homeLocationDisplay,
    bool? daWalletActivated,
    int? subscriberCount,
    bool? isVerifiedByTeam,
  }) {
    return UserModel(
      uid: uid,
      displayName: displayName ?? this.displayName,
      username: username ?? this.username,
      pastUsernames: pastUsernames ?? this.pastUsernames,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      photoURL: photoURL ?? this.photoURL,
      selfieURL: selfieURL ?? this.selfieURL,
      bio: bio ?? this.bio,
      birthdate: birthdate ?? this.birthdate,
      professionalRole: professionalRole ?? this.professionalRole,
      artisticRole: artisticRole ?? this.artisticRole,
      accountType: accountType ?? this.accountType,
      uiMode: uiMode ?? this.uiMode,
      isVerified: isVerified ?? this.isVerified,
      fanFeatureEnabled: fanFeatureEnabled ?? this.fanFeatureEnabled,
      dmEnabled: dmEnabled ?? this.dmEnabled,
      followedHashtags: followedHashtags ?? this.followedHashtags,
      savedPosts: savedPosts ?? this.savedPosts,
      blockedUsers: blockedUsers ?? this.blockedUsers,
      identityHashtags: identityHashtags ?? this.identityHashtags,
      followedIdentityHashtags: followedIdentityHashtags ?? this.followedIdentityHashtags,
      followedCategoryHashtags: followedCategoryHashtags ?? this.followedCategoryHashtags,
      postedInHashtags: postedInHashtags ?? this.postedInHashtags,
      shreeCoinBalance: shreeCoinBalance ?? this.shreeCoinBalance,
      daCoinBalance: daCoinBalance ?? this.daCoinBalance,
      shreedaBalance: shreedaBalance ?? this.shreedaBalance,
      totalDaDonated: totalDaDonated ?? this.totalDaDonated,
      competitionWins: competitionWins ?? this.competitionWins,
      comparisonWins: comparisonWins ?? this.comparisonWins,
      ratingAvgLifetime: ratingAvgLifetime ?? this.ratingAvgLifetime,
      createdAt: createdAt,
      homeCity: homeCity ?? this.homeCity,
      homeState: homeState ?? this.homeState,
      homeCountry: homeCountry ?? this.homeCountry,
      homeLocationDisplay: homeLocationDisplay ?? this.homeLocationDisplay,
      daWalletActivated: daWalletActivated ?? this.daWalletActivated,
      subscriberCount: subscriberCount ?? this.subscriberCount,
      isVerifiedByTeam: isVerifiedByTeam ?? this.isVerifiedByTeam,
    );
  }

  // Computed getters
  bool get isGrowing => daWalletActivated;
  bool get isCelebrity => accountType == AccountType.celebrity;
  bool get isOrganisation => accountType == AccountType.org;
  bool get hasSubscribeButton => isCelebrity || isOrganisation;
  bool get showSubscriberCount => isCelebrity || isOrganisation;
  String? get identityHashtag => identityHashtags.isNotEmpty ? identityHashtags.first : null;
}
