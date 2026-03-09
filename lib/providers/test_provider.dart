import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/question.dart';
import '../models/result.dart';
import '../services/storage_service.dart';
import '../services/test_service.dart';
import '../utils/error_utils.dart';

// ── State ──
class TestState {
  final StartTestResponse? session;
  final int currentIndex;
  final int streak;
  final Map<String, int?> answers; // questionId -> selectedAnswer
  final Map<String, bool> answerResults; // questionId -> isCorrect
  final bool isLoading;
  final String? error;
  final TestResult? result;

  const TestState({
    this.session,
    this.currentIndex = 0,
    this.streak = 0,
    this.answers = const {},
    this.answerResults = const {},
    this.isLoading = false,
    this.error,
    this.result,
  });

  TestQuestion? get currentQuestion {
    if (session == null || currentIndex >= session!.questions.length) {
      return null;
    }
    return session!.questions[currentIndex];
  }

  int get totalQuestions => session?.questions.length ?? 0;
  bool get isTestComplete => currentIndex >= totalQuestions;
  int get correctCount => answerResults.values.where((v) => v).length;

  TestState copyWith({
    StartTestResponse? session,
    int? currentIndex,
    int? streak,
    Map<String, int?>? answers,
    Map<String, bool>? answerResults,
    bool? isLoading,
    String? error,
    TestResult? result,
    bool clearError = false,
    bool clearSession = false,
    bool clearResult = false,
  }) {
    return TestState(
      session: clearSession ? null : (session ?? this.session),
      currentIndex: currentIndex ?? this.currentIndex,
      streak: streak ?? this.streak,
      answers: answers ?? this.answers,
      answerResults: answerResults ?? this.answerResults,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      result: clearResult ? null : (result ?? this.result),
    );
  }
}

// ── Notifier ──
class TestNotifier extends StateNotifier<TestState> {
  TestNotifier() : super(const TestState());

  Future<void> startSession({
    required String mode,
    String? language,
  }) async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
      clearResult: true,
    );
    try {
      final session = await TestService.startTest(
        mode: mode,
        language: language,
      );
      state = TestState(session: session);

      // Save backup
      await _saveBackup();
    } on DioException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: extractDioError(e),
      );
    }
  }

  Future<void> submitAnswer({
    required int? selectedAnswer,
    required int responseTimeMs,
  }) async {
    final question = state.currentQuestion;
    if (question == null || state.session == null) return;

    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final response = await TestService.submitAnswer(
        sessionId: state.session!.sessionId,
        questionId: question.id,
        selectedAnswer: selectedAnswer,
        responseTimeMs: responseTimeMs,
      );

      final newAnswers = Map<String, int?>.from(state.answers);
      newAnswers[question.id] = selectedAnswer;

      final newResults = Map<String, bool>.from(state.answerResults);
      newResults[question.id] = response.isCorrect;

      int newStreak = state.streak;
      if (response.isCorrect) {
        newStreak++;
      } else {
        newStreak = 0;
      }

      state = state.copyWith(
        answers: newAnswers,
        answerResults: newResults,
        streak: newStreak,
        isLoading: false,
      );

      await _saveBackup();
    } on DioException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: extractDioError(e),
      );
    }
  }

  void nextQuestion() {
    if (state.currentIndex < state.totalQuestions) {
      state = state.copyWith(currentIndex: state.currentIndex + 1);
    }
  }

  Future<void> completeTest() async {
    if (state.session == null) return;

    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final result = await TestService.completeTest(
        sessionId: state.session!.sessionId,
      );
      state = state.copyWith(
        result: result,
        isLoading: false,
      );

      // Clear backup after completion
      await StorageService.clearTestBackup();
    } on DioException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: extractDioError(e),
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to parse results: $e',
      );
    }
  }

  Future<bool> restoreFromBackup() async {
    final backupJson = await StorageService.getTestBackup();
    if (backupJson == null) return false;

    try {
      final backup = jsonDecode(backupJson) as Map<String, dynamic>;
      final session = StartTestResponse.fromJson(backup['session']);
      final answers = Map<String, int?>.from(backup['answers'] ?? {});
      final answerResults =
          (backup['answerResults'] as Map<String, dynamic>?)?.map(
                (k, v) => MapEntry(k, v as bool),
              ) ??
              {};

      state = TestState(
        session: session,
        currentIndex: backup['currentIndex'] ?? answers.length,
        streak: backup['streak'] ?? 0,
        answers: answers,
        answerResults: answerResults,
      );
      return true;
    } catch (_) {
      await StorageService.clearTestBackup();
      return false;
    }
  }

  void reset() {
    state = const TestState();
  }

  Future<void> _saveBackup() async {
    if (state.session == null) return;
    final backup = jsonEncode({
      'session': state.session!.toJson(),
      'currentIndex': state.currentIndex,
      'streak': state.streak,
      'answers': state.answers,
      'answerResults': state.answerResults,
    });
    await StorageService.saveTestBackup(backup);
  }


}

// ── Provider ──
final testProvider = StateNotifierProvider<TestNotifier, TestState>((ref) {
  return TestNotifier();
});
