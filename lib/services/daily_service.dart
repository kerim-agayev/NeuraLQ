import 'package:dio/dio.dart';
import '../config/api_client.dart';
import '../models/daily.dart';

class DailyService {
  static final Dio _dio = ApiClient.dio;

  static Future<DailyChallenge?> getToday() async {
    final res = await _dio.get('/daily/today');
    final data = res.data['data'];
    if (data == null) return null;
    return DailyChallenge.fromJson(data);
  }

  static Future<DailyAttemptResponse> submitAttempt({
    required int selectedAnswer,
    required int responseTimeMs,
  }) async {
    final res = await _dio.post('/daily/today/attempt', data: {
      'selectedAnswer': selectedAnswer,
      'responseTimeMs': responseTimeMs,
    });
    return DailyAttemptResponse.fromJson(res.data['data']);
  }

  static Future<DailyStats> getStats() async {
    final res = await _dio.get('/daily/stats');
    return DailyStats.fromJson(res.data['data']);
  }
}
