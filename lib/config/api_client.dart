import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'constants.dart';

class ApiClient {
  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: apiBaseUrl,
      connectTimeout: apiTimeout,
      receiveTimeout: apiTimeout,
      headers: {'Content-Type': 'application/json'},
    ),
  );

  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  static void setupInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storage.read(key: storageKeyAccessToken);
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401 &&
              !error.requestOptions.extra.containsKey('_retry')) {
            error.requestOptions.extra['_retry'] = true;

            final refreshToken =
                await _storage.read(key: storageKeyRefreshToken);
            if (refreshToken == null) {
              return handler.reject(error);
            }

            try {
              // Use longer timeout for refresh — Render cold start can take 60s
              final refreshDio = Dio(BaseOptions(
                connectTimeout: const Duration(seconds: 90),
                receiveTimeout: const Duration(seconds: 90),
              ));

              final res = await refreshDio.post(
                '$apiBaseUrl/auth/refresh',
                data: {'refreshToken': refreshToken},
              );

              final data = res.data is Map ? res.data['data'] : null;
              if (data == null || data is! Map) {
                throw Exception('Invalid refresh response');
              }
              final newAccessToken = data['accessToken'] as String?;
              final newRefreshToken = data['refreshToken'] as String?;
              if (newAccessToken == null || newRefreshToken == null) {
                throw Exception('Missing tokens in refresh response');
              }

              await _storage.write(
                  key: storageKeyAccessToken, value: newAccessToken);
              await _storage.write(
                  key: storageKeyRefreshToken, value: newRefreshToken);

              error.requestOptions.headers['Authorization'] =
                  'Bearer $newAccessToken';
              final retryResponse = await _dio.fetch(error.requestOptions);
              return handler.resolve(retryResponse);
            } on DioException catch (e) {
              // Network/timeout error — backend might be cold starting
              // DON'T delete tokens, just fail this request
              if (e.response?.statusCode == 401 ||
                  e.response?.statusCode == 403) {
                // Refresh token is invalid/expired → clear tokens (real logout)
                await _storage.delete(key: storageKeyAccessToken);
                await _storage.delete(key: storageKeyRefreshToken);
              }
              debugPrint('Token refresh failed: ${e.type}');
              return handler.reject(error);
            } catch (e) {
              // Parsing error — don't delete tokens either
              debugPrint('Token refresh parse error: $e');
              return handler.reject(error);
            }
          }
          return handler.next(error);
        },
      ),
    );
  }

  static Dio get dio => _dio;
  static FlutterSecureStorage get storage => _storage;
}
