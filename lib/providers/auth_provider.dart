import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
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
    } catch (_) {
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
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        error: 'common.error',
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
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        error: 'common.error',
      );
    }
  }

  Future<void> googleAuth() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      // signIn() opens the Google account picker. On a fresh Play-signed
      // install it can hang indefinitely while Play Services initialises —
      // 45s is generous enough for a real user (account picker + selection)
      // but bounded so the UI never freezes forever.
      final account = await _googleSignIn.signIn().timeout(
        const Duration(seconds: 45),
      );
      if (account == null) {
        state = state.copyWith(isLoading: false);
        return;
      }

      final googleAuth = await account.authentication.timeout(
        const Duration(seconds: 15),
      );
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
    } on TimeoutException {
      // Try to clear any stuck state in the SDK so the next tap starts fresh.
      // Without this, the corrupt state often persists and the user has to
      // clear app data to retry.
      try {
        await _googleSignIn.signOut().timeout(const Duration(seconds: 3));
      } catch (_) {}
      debugPrint('Google sign-in timed out');
      state = state.copyWith(
        isLoading: false,
        error: 'Sign-in timed out. Please try again.',
      );
    } on DioException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: extractDioError(e),
      );
    } catch (e) {
      debugPrint('Google sign-in failed: $e');
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
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        error: 'common.error',
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
    // FlutterSecureStorage's first write on a fresh install can stall while
    // the Android Keystore platform channel initialises. Bound it so the
    // login flow can't hang on persistence — if it times out, the caller's
    // outer catch block will surface an error and keep the UI responsive.
    await Future.wait([
      StorageService.saveAccessToken(auth.accessToken),
      StorageService.saveRefreshToken(auth.refreshToken),
    ]).timeout(
      const Duration(seconds: 10),
      onTimeout: () {
        throw TimeoutException('Failed to save credentials');
      },
    );
  }


}

// ── Provider ──
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
