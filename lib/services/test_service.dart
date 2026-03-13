import 'package:dio/dio.dart';
import '../config/api_client.dart';
import '../models/question.dart';
import '../models/result.dart';

class TestService {
  static final Dio _dio = ApiClient.dio;

  static Future<StartTestResponse> startTest({
    required String mode,
    String? language,
  }) async {
    final data = <String, dynamic>{'mode': mode};
    if (language != null) data['language'] = language;
    final res = await _dio.post('/tests/start', data: data);
    return StartTestResponse.fromJson(res.data['data']);
  }

  static Future<TestResult> completeTest({
    required String sessionId,
    required List<TestAnswer> answers,
  }) async {
    final res = await _dio.post('/tests/$sessionId/complete', data: {
      'answers': answers.map((a) => a.toJson()).toList(),
    });
    return TestResult.fromJson(res.data['data']);
  }

  static Future<TestResult> getResult({
    required String sessionId,
  }) async {
    final res = await _dio.get('/tests/$sessionId/result');
    return TestResult.fromJson(res.data['data']);
  }

  static Future<TestHistoryResponse> getHistory({
    int page = 1,
    int limit = 10,
  }) async {
    final res = await _dio.get('/tests/history', queryParameters: {
      'page': page,
      'limit': limit,
    });
    return TestHistoryResponse.fromJson(res.data);
  }
}
