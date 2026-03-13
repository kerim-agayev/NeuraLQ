import 'user.dart';

class TestResult {
  final String id;
  final String testSessionId;
  final String? userId;

  final double rawScore;
  final int iqScore;
  final double zScore;

  final double spatialScore;
  final double logicScore;
  final double? verbalScore;
  final double memoryScore;
  final double speedScore;

  final double spatialPercentile;
  final double logicPercentile;
  final double? verbalPercentile;
  final double memoryPercentile;
  final double speedPercentile;

  final int cognitiveAge;
  final String celebrityMatch;
  final int? countryRank;
  final int? globalRank;

  final String? certificateUrl;
  final String completedAt;
  final bool cheatFlagged;
  final List<Badge> newBadges;

  final int neuralCoinsEarned;

  // History-only fields
  final String? mode;

  TestResult({
    required this.id,
    required this.testSessionId,
    this.userId,
    required this.rawScore,
    required this.iqScore,
    required this.zScore,
    required this.spatialScore,
    required this.logicScore,
    this.verbalScore,
    required this.memoryScore,
    required this.speedScore,
    required this.spatialPercentile,
    required this.logicPercentile,
    this.verbalPercentile,
    required this.memoryPercentile,
    required this.speedPercentile,
    required this.cognitiveAge,
    required this.celebrityMatch,
    this.countryRank,
    this.globalRank,
    this.certificateUrl,
    required this.completedAt,
    this.cheatFlagged = false,
    this.newBadges = const [],
    this.neuralCoinsEarned = 0,
    this.mode,
  });

  factory TestResult.fromJson(Map<String, dynamic> json) {
    return TestResult(
      id: json['id'],
      testSessionId: json['testSessionId'] ?? '',
      userId: json['userId'],
      rawScore: (json['rawScore'] ?? 0).toDouble(),
      iqScore: json['iqScore'] ?? 0,
      zScore: (json['zScore'] ?? 0).toDouble(),
      spatialScore: (json['spatialScore'] ?? 0).toDouble(),
      logicScore: (json['logicScore'] ?? 0).toDouble(),
      verbalScore: json['verbalScore']?.toDouble(),
      memoryScore: (json['memoryScore'] ?? 0).toDouble(),
      speedScore: (json['speedScore'] ?? 0).toDouble(),
      spatialPercentile: (json['spatialPercentile'] ?? 0).toDouble(),
      logicPercentile: (json['logicPercentile'] ?? 0).toDouble(),
      verbalPercentile: json['verbalPercentile']?.toDouble(),
      memoryPercentile: (json['memoryPercentile'] ?? 0).toDouble(),
      speedPercentile: (json['speedPercentile'] ?? 0).toDouble(),
      cognitiveAge: json['cognitiveAge'] ?? 0,
      celebrityMatch: json['celebrityMatch'] ?? 'average_joe',
      countryRank: json['countryRank'],
      globalRank: json['globalRank'],
      certificateUrl: json['certificateUrl'],
      completedAt: json['completedAt'] ?? '',
      cheatFlagged: json['cheatFlagged'] ?? false,
      newBadges: (json['newBadges'] as List?)
              ?.map((b) => b is Map<String, dynamic>
                  ? Badge.fromJson(b)
                  : Badge(
                      id: b.toString(),
                      name: b.toString(),
                      awardedAt: ''))
              .toList() ??
          [],
      neuralCoinsEarned: json['neuralCoinsEarned'] ?? 0,
      mode: json['mode'],
    );
  }
}

class TestHistoryItem {
  final String id;
  final String testSessionId;
  final String mode;
  final int iqScore;
  final int cognitiveAge;
  final String celebrityMatch;
  final String completedAt;

  TestHistoryItem({
    required this.id,
    required this.testSessionId,
    required this.mode,
    required this.iqScore,
    required this.cognitiveAge,
    required this.celebrityMatch,
    required this.completedAt,
  });

  factory TestHistoryItem.fromJson(Map<String, dynamic> json) {
    return TestHistoryItem(
      id: json['id'],
      testSessionId: json['testSessionId'] ?? '',
      mode: json['mode'] ?? 'ARCADE',
      iqScore: json['iqScore'] ?? 0,
      cognitiveAge: json['cognitiveAge'] ?? 0,
      celebrityMatch: json['celebrityMatch'] ?? 'average_joe',
      completedAt: json['completedAt'] ?? '',
    );
  }
}

class TestHistoryResponse {
  final List<TestHistoryItem> items;
  final int page;
  final int limit;
  final int total;
  final int totalPages;

  TestHistoryResponse({
    required this.items,
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
  });

  factory TestHistoryResponse.fromJson(Map<String, dynamic> json) {
    final meta = json['meta'] ?? {};
    return TestHistoryResponse(
      items: (json['data'] as List?)
              ?.map((i) => TestHistoryItem.fromJson(i))
              .toList() ??
          [],
      page: meta['page'] ?? 1,
      limit: meta['limit'] ?? 10,
      total: meta['total'] ?? 0,
      totalPages: meta['totalPages'] ?? 0,
    );
  }
}
