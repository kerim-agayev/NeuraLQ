import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';

/// Extracts a user-friendly, localized error message from a [DioException].
/// Handles connection errors, timeouts, specific HTTP status codes, and
/// falls back to backend error messages or generic defaults.
String extractDioError(DioException e) {
  // Connection-level errors (no response from server)
  switch (e.type) {
    case DioExceptionType.connectionError:
      return 'errors.noInternet'.tr();
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
      return 'errors.connectionTimeout'.tr();
    case DioExceptionType.receiveTimeout:
      return 'errors.serverSlow'.tr();
    default:
      break;
  }

  // HTTP status-code errors
  final statusCode = e.response?.statusCode;
  if (statusCode != null) {
    switch (statusCode) {
      case 401:
        return 'errors.sessionExpired'.tr();
      case 429:
        return 'errors.tooManyRequests'.tr();
      case 500:
      case 502:
      case 503:
        return 'errors.serverDown'.tr();
    }
  }

  // Backend-provided error message
  final data = e.response?.data;
  if (data is Map<String, dynamic>) {
    final msg = data['error'];
    if (msg is String && msg.isNotEmpty) return msg;
  }

  return 'common.error'.tr();
}
