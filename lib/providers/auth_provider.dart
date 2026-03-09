import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../config/constants.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import '../services/storage_service.dart';
import '../utils/error_utils.dart';

// ── State ──
class AuthState {
  final User? user;
  final bool isAuthenticated;
  final bool isLoading;
  final String? error;

  const AuthState({
    this.user,
    this.isAuthenticated = false,
    this.isLoading = false,
    this.error,
  });

  AuthState copyWith({
    User? user,
    bool? isAuthenticated,
    bool? isLoading,
    String? error,
    bool clearError = false,
    bool clearUser = false,
  }) {
    return AuthState(
      user: clearUser ? null : (user ?? this.user),
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

// ── Notifier ──
class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState());

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    serverClientId: googleWebClientId,
  );

  Future<bool> loadUser() async {
    final token = await StorageService.getAccessToken();
    if (token == null) return false;

    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final user = await AuthService.getMe();
      state = state.copyWith(
        user: user,
        isAuthenticated: true,
        isLoading: false,
      );
      return true;
    } on DioException {
      await StorageService.clearTokens();
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: false,
        clearUser: true,
      );
      return false;
    }
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final auth = await AuthService.login(
        email: email,
        password: password,
      );
      await _saveTokens(auth);
      state = state.copyWith(
        user: auth.user,
        isAuthenticated: true,
        isLoading: false,
      );
    } on DioException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: extractDioError(e),
      );
    }
  }

  Future<void> register({
    required String email,
    required String password,
    required String username,
    int? age,
    String? country,
    String language = 'en',
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final auth = await AuthService.register(
        email: email,
        password: password,
        username: username,
        age: age,
        country: country,
        language: language,
      );
      await _saveTokens(auth);
      state = state.copyWith(
        user: auth.user,
        isAuthenticated: true,
        isLoading: false,
      );
    } on DioException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: extractDioError(e),
      );
    }
  }

  Future<void> googleAuth() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final account = await _googleSignIn.signIn();
      if (account == null) {
        state = state.copyWith(isLoading: false);
        return;
      }

      final googleAuth = await account.authentication;
      final idToken = googleAuth.idToken;
      if (idToken == null) {
        state = state.copyWith(
          isLoading: false,
          error: 'Google authentication failed',
        );
        return;
      }

      final auth = await AuthService.googleAuth(idToken: idToken);
      await _saveTokens(auth);
      state = state.copyWith(
        user: auth.user,
        isAuthenticated: true,
        isLoading: false,
      );
    } on DioException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: extractDioError(e),
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Google sign-in failed',
      );
    }
  }

  Future<void> updateProfile({
    String? username,
    String? displayName,
    int? age,
    String? country,
    String? city,
    String? school,
    String? language,
    String? themePreference,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final user = await AuthService.updateProfile(
        username: username,
        displayName: displayName,
        age: age,
        country: country,
        city: city,
        school: school,
        language: language,
        themePreference: themePreference,
      );
      state = state.copyWith(user: user, isLoading: false);
    } on DioException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: extractDioError(e),
      );
    }
  }

  Future<void> refreshUser() async {
    try {
      final user = await AuthService.getMe();
      state = state.copyWith(user: user);
    } catch (_) {}
  }

  Future<void> logout() async {
    await StorageService.clearTokens();
    try {
      await _googleSignIn.signOut();
    } catch (_) {}
    state = const AuthState();
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }

  Future<void> _saveTokens(AuthResponse auth) async {
    await StorageService.saveAccessToken(auth.accessToken);
    await StorageService.saveRefreshToken(auth.refreshToken);
  }


}

// ── Provider ──
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
