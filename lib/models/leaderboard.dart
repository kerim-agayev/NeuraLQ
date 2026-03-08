class LeaderboardEntry {
  final int rank;
  final String userId;
  final String username;
  final String? displayName;
  final String? avatarUrl;
  final int iqScore;
  final String? country;
  final String completedAt;

  LeaderboardEntry({
    required this.rank,
    required this.userId,
    required this.username,
    this.displayName,
    this.avatarUrl,
    required this.iqScore,
    this.country,
    required this.completedAt,
  });

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntry(
      rank: json['rank'] ?? 0,
      userId: json['userId'],
      username: json['username'],
      displayName: json['displayName'],
      avatarUrl: json['avatarUrl'],
      iqScore: json['iqScore'] ?? 0,
      country: json['country'],
      completedAt: json['completedAt'] ?? '',
    );
  }
}

class LeaderboardResponse {
  final List<LeaderboardEntry> entries;
  final int total;

  LeaderboardResponse({
    required this.entries,
    required this.total,
  });

  factory LeaderboardResponse.fromJson(Map<String, dynamic> json) {
    return LeaderboardResponse(
      entries: (json['entries'] as List?)
              ?.map((e) => LeaderboardEntry.fromJson(e))
              .toList() ??
          [],
      total: json['total'] ?? 0,
    );
  }
}

class UserRankInfo {
  final int? globalRank;
  final int? countryRank;

  UserRankInfo({
    this.globalRank,
    this.countryRank,
  });

  factory UserRankInfo.fromJson(Map<String, dynamic> json) {
    return UserRankInfo(
      globalRank: json['globalRank'],
      countryRank: json['countryRank'],
    );
  }
}
