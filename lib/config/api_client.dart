import 'package:dio/dio.dart';
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
              final res = await Dio().post(
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
            } catch (_) {
              await _storage.delete(key: storageKeyAccessToken);
              await _storage.delete(key: storageKeyRefreshToken);
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
