class TokenModel {
  final String uid;
  final double shreeCoinBalance;
  final double daCoinBalance;
  final double shreedaBalance;
  final double totalDaDonated;
  final DateTime lastUpdated;

  const TokenModel({
    required this.uid,
    this.shreeCoinBalance = 0.0,
    this.daCoinBalance = 0.0,
    this.shreedaBalance = 0.0,
    this.totalDaDonated = 0.0,
    required this.lastUpdated,
  });

  factory TokenModel.fromMap(Map<String, dynamic> map, String uid) {
    return TokenModel(
      uid: uid,
      shreeCoinBalance: (map['shreeCoinBalance'] ?? 0.0).toDouble(),
      daCoinBalance: (map['daCoinBalance'] ?? 0.0).toDouble(),
      shreedaBalance: (map['shreedaBalance'] ?? 0.0).toDouble(),
      totalDaDonated: (map['totalDaDonated'] ?? 0.0).toDouble(),
      lastUpdated: DateTime.parse(map['lastUpdated'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toMap() => {
        'shreeCoinBalance': shreeCoinBalance,
        'daCoinBalance': daCoinBalance,
        'shreedaBalance': shreedaBalance,
        'totalDaDonated': totalDaDonated,
        'lastUpdated': lastUpdated.toIso8601String(),
      };

  TokenModel copyWith({
    double? shreeCoinBalance,
    double? daCoinBalance,
    double? shreedaBalance,
    double? totalDaDonated,
    DateTime? lastUpdated,
  }) {
    return TokenModel(
      uid: uid,
      shreeCoinBalance: shreeCoinBalance ?? this.shreeCoinBalance,
      daCoinBalance: daCoinBalance ?? this.daCoinBalance,
      shreedaBalance: shreedaBalance ?? this.shreedaBalance,
      totalDaDonated: totalDaDonated ?? this.totalDaDonated,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}
