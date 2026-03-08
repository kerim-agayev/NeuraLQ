import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/daily.dart';
import '../services/daily_service.dart';

// ── State ──
enum DailyChallengeStatus { loading, question, result, alreadyDone, noChallenge }

class DailyState {
  final DailyChallenge? challenge;
  final DailyAttemptResponse? attemptResult;
  final DailyStats? stats;
  final DailyChallengeStatus status;
  final bool isLoading;
  final String? error;

  const DailyState({
    this.challenge,
    this.attemptResult,
    this.stats,
    this.status = DailyChallengeStatus.loading,
    this.isLoading = false,
    this.error,
  });

  DailyState copyWith({
    DailyChallenge? challenge,
    DailyAttemptResponse? attemptResult,
    DailyStats? stats,
    DailyChallengeStatus? status,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return DailyState(
      challenge: challenge ?? this.challenge,
      attemptResult: attemptResult ?? this.attemptResult,
      stats: stats ?? this.stats,
      status: status ?? this.status,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

// ── Notifier ──
class DailyNotifier extends StateNotifier<DailyState> {
  DailyNotifier() : super(const DailyState());

  Future<void> loadToday() async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
      status: DailyChallengeStatus.loading,
    );
    try {
      final challenge = await DailyService.getToday();
      if (challenge == null) {
        state = state.copyWith(
          status: DailyChallengeStatus.noChallenge,
          isLoading: false,
        );
        return;
      }

      if (challenge.alreadyAttempted) {
        state = state.copyWith(
          challenge: challenge,
          status: DailyChallengeStatus.alreadyDone,
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          challenge: challenge,
          status: DailyChallengeStatus.question,
          isLoading: false,
        );
      }
    } on DioException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: _extractError(e),
      );
    }
  }

  Future<void> submitAttempt({
    required int selectedAnswer,
    required int responseTimeMs,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final result = await DailyService.submitAttempt(
        selectedAnswer: selectedAnswer,
        responseTimeMs: responseTimeMs,
      );
      state = state.copyWith(
        attemptResult: result,
        status: DailyChallengeStatus.result,
        isLoading: false,
      );
    } on DioException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: _extractError(e),
      );
    }
  }

  Future<void> loadStats() async {
    try {
      final stats = await DailyService.getStats();
      state = state.copyWith(stats: stats);
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
final dailyProvider =
    StateNotifierProvider<DailyNotifier, DailyState>((ref) {
  return DailyNotifier();
});
