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
  final List<TestAnswer> localAnswers;
  final bool isLoading;
  final bool isCompleting;
  final String? error;
  final TestResult? result;

  const TestState({
    this.session,
    this.currentIndex = 0,
    this.localAnswers = const [],
    this.isLoading = false,
    this.isCompleting = false,
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

  TestState copyWith({
    StartTestResponse? session,
    int? currentIndex,
    List<TestAnswer>? localAnswers,
    bool? isLoading,
    bool? isCompleting,
    String? error,
    TestResult? result,
    bool clearError = false,
    bool clearSession = false,
    bool clearResult = false,
  }) {
    return TestState(
      session: clearSession ? null : (session ?? this.session),
      currentIndex: currentIndex ?? this.currentIndex,
      localAnswers: localAnswers ?? this.localAnswers,
      isLoading: isLoading ?? this.isLoading,
      isCompleting: isCompleting ?? this.isCompleting,
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
      await _saveBackup();
    } on DioException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: extractDioError(e),
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  void recordAnswer(TestAnswer answer) {
    state = state.copyWith(
      localAnswers: [...state.localAnswers, answer],
    );
    _saveBackup();
  }

  void nextQuestion() {
    if (state.currentIndex < state.totalQuestions) {
      state = state.copyWith(currentIndex: state.currentIndex + 1);
    }
  }

  Future<void> completeTest() async {
    if (state.session == null) return;

    state = state.copyWith(isCompleting: true, clearError: true);
    try {
      final result = await TestService.completeTest(
        sessionId: state.session!.sessionId,
        answers: state.localAnswers,
      );
      state = state.copyWith(
        result: result,
        isCompleting: false,
      );
      await StorageService.clearTestBackup();
    } on DioException catch (e) {
      state = state.copyWith(
        isCompleting: false,
        error: extractDioError(e),
      );
    } catch (e) {
      state = state.copyWith(
        isCompleting: false,
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
      final localAnswers = (backup['localAnswers'] as List?)
              ?.map((a) => TestAnswer.fromJson(a as Map<String, dynamic>))
              .toList() ??
          [];

      state = TestState(
        session: session,
        currentIndex: backup['currentIndex'] ?? localAnswers.length,
        localAnswers: localAnswers,
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
      'localAnswers': state.localAnswers.map((a) => a.toJson()).toList(),
    });
    await StorageService.saveTestBackup(backup);
  }
}

// ── Provider ──
final testProvider = StateNotifierProvider<TestNotifier, TestState>((ref) {
  return TestNotifier();
});
