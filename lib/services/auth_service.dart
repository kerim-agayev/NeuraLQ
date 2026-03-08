import 'package:dio/dio.dart';
import '../config/api_client.dart';
import '../models/user.dart';

class AuthService {
  static final Dio _dio = ApiClient.dio;

  static Future<AuthResponse> register({
    required String email,
    required String password,
    required String username,
    int? age,
    String? country,
    String language = 'en',
  }) async {
    final data = <String, dynamic>{
      'email': email,
      'password': password,
      'username': username,
      'language': language,
    };
    if (age != null) data['age'] = age;
    if (country != null) data['country'] = country;

    final res = await _dio.post('/auth/register', data: data);
    return AuthResponse.fromJson(res.data['data']);
  }

  static Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    final res = await _dio.post('/auth/login', data: {
      'email': email,
      'password': password,
    });
    return AuthResponse.fromJson(res.data['data']);
  }

  static Future<AuthResponse> googleAuth({
    required String idToken,
  }) async {
    final res = await _dio.post('/auth/google', data: {
      'idToken': idToken,
    });
    return AuthResponse.fromJson(res.data['data']);
  }

  static Future<User> getMe() async {
    final res = await _dio.get('/auth/me');
    return User.fromJson(res.data['data']);
  }

  static Future<User> updateProfile({
    String? username,
    String? displayName,
    int? age,
    String? country,
    String? city,
    String? school,
    String? language,
    String? themePreference,
  }) async {
    final data = <String, dynamic>{};
    if (username != null) data['username'] = username;
    if (displayName != null) data['displayName'] = displayName;
    if (age != null) data['age'] = age;
    if (country != null) data['country'] = country;
    if (city != null) data['city'] = city;
    if (school != null) data['school'] = school;
    if (language != null) data['language'] = language;
    if (themePreference != null) data['themePreference'] = themePreference;

    final res = await _dio.patch('/auth/me', data: data);
    return User.fromJson(res.data['data']);
  }
}
