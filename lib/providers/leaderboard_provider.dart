import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/leaderboard.dart';
import '../services/leaderboard_service.dart';

// ── State ──
class LeaderboardState {
  final LeaderboardResponse? global;
  final LeaderboardResponse? country;
  final UserRankInfo? userRank;
  final bool isLoading;
  final String? error;

  const LeaderboardState({
    this.global,
    this.country,
    this.userRank,
    this.isLoading = false,
    this.error,
  });

  LeaderboardState copyWith({
    LeaderboardResponse? global,
    LeaderboardResponse? country,
    UserRankInfo? userRank,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return LeaderboardState(
      global: global ?? this.global,
      country: country ?? this.country,
      userRank: userRank ?? this.userRank,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

// ── Notifier ──
class LeaderboardNotifier extends StateNotifier<LeaderboardState> {
  LeaderboardNotifier() : super(const LeaderboardState());

  Future<void> loadGlobal() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final global = await LeaderboardService.getGlobal();
      state = state.copyWith(global: global, isLoading: false);
    } on DioException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: _extractError(e),
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load leaderboard',
      );
    }
  }

  Future<void> loadCountry(String countryCode) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final country = await LeaderboardService.getCountry(
        countryCode: countryCode,
      );
      state = state.copyWith(country: country, isLoading: false);
    } on DioException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: _extractError(e),
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load leaderboard',
      );
    }
  }

  Future<void> loadUserRank() async {
    try {
      final rank = await LeaderboardService.getUserRank();
      state = state.copyWith(userRank: rank);
    } catch (_) {}
  }

  String _extractError(DioException e) {
    final data = e.response?.data;
    if (data is Map<String, dynamic>) {
      return data['error'] ?? 'Something went wrong';
    }
    return 'Network error';
  }
}

// ── Provider ──
final leaderboardProvider =
    StateNotifierProvider<LeaderboardNotifier, LeaderboardState>((ref) {
  return LeaderboardNotifier();
});
