import 'package:dio/dio.dart';
import '../config/api_client.dart';
import '../models/leaderboard.dart';

class LeaderboardService {
  static final Dio _dio = ApiClient.dio;

  static Future<LeaderboardResponse> getGlobal({
    int limit = 100,
    int offset = 0,
  }) async {
    final res = await _dio.get('/leaderboard/global', queryParameters: {
      'limit': limit,
      'offset': offset,
    });
    return LeaderboardResponse.fromJson(res.data['data']);
  }

  static Future<LeaderboardResponse> getCountry({
    required String countryCode,
    int limit = 100,
    int offset = 0,
  }) async {
    final res =
        await _dio.get('/leaderboard/country/$countryCode', queryParameters: {
      'limit': limit,
      'offset': offset,
    });
    return LeaderboardResponse.fromJson(res.data['data']);
  }

  static Future<UserRankInfo> getUserRank() async {
    final res = await _dio.get('/leaderboard/me');
    return UserRankInfo.fromJson(res.data['data']);
  }
}
