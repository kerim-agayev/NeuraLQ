import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/leaderboard.dart';
import '../services/leaderboard_service.dart';

// ── State ──
class LeaderboardState {
  final LeaderboardResponse? global;
  final LeaderboardResponse? country;
  final UserRankInfo? userRank;
  final bool isLoadingGlobal;
  final bool isLoadingCountry;
  final String? globalError;
  final String? countryError;

  const LeaderboardState({
    this.global,
    this.country,
    this.userRank,
    this.isLoadingGlobal = false,
    this.isLoadingCountry = false,
    this.globalError,
    this.countryError,
  });

  LeaderboardState copyWith({
    LeaderboardResponse? global,
    LeaderboardResponse? country,
    UserRankInfo? userRank,
    bool? isLoadingGlobal,
    bool? isLoadingCountry,
    String? globalError,
    String? countryError,
    bool clearGlobalError = false,
    bool clearCountryError = false,
  }) {
    return LeaderboardState(
      global: global ?? this.global,
      country: country ?? this.country,
      userRank: userRank ?? this.userRank,
      isLoadingGlobal: isLoadingGlobal ?? this.isLoadingGlobal,
      isLoadingCountry: isLoadingCountry ?? this.isLoadingCountry,
      globalError: clearGlobalError ? null : (globalError ?? this.globalError),
      countryError:
          clearCountryError ? null : (countryError ?? this.countryError),
    );
  }

  // Backwards-compatible getter
  bool get isLoading => isLoadingGlobal || isLoadingCountry;
}

// ── Notifier ──
class LeaderboardNotifier extends StateNotifier<LeaderboardState> {
  LeaderboardNotifier() : super(const LeaderboardState());

  Future<void> loadGlobal() async {
    state = state.copyWith(isLoadingGlobal: true, clearGlobalError: true);
    try {
      final global = await LeaderboardService.getGlobal();
      state = state.copyWith(global: global, isLoadingGlobal: false);
    } on DioException catch (e) {
      state = state.copyWith(
        isLoadingGlobal: false,
        globalError: _extractError(e),
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingGlobal: false,
        globalError: e.toString(),
      );
    }
  }

  Future<void> loadCountry(String countryCode) async {
    state = state.copyWith(isLoadingCountry: true, clearCountryError: true);
    try {
      final country = await LeaderboardService.getCountry(
        countryCode: countryCode,
      );
      state = state.copyWith(country: country, isLoadingCountry: false);
    } on DioException catch (e) {
      state = state.copyWith(
        isLoadingCountry: false,
        countryError: _extractError(e),
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingCountry: false,
        countryError: e.toString(),
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
