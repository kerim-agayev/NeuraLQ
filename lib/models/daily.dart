import 'question.dart';
import 'user.dart';

class DailyUserAnswer {
  final int selectedAnswer;
  final bool isCorrect;
  final int brainPointsEarned;

  DailyUserAnswer({
    required this.selectedAnswer,
    required this.isCorrect,
    required this.brainPointsEarned,
  });

  factory DailyUserAnswer.fromJson(Map<String, dynamic> json) {
    return DailyUserAnswer(
      selectedAnswer: json['selectedAnswer'],
      isCorrect: json['isCorrect'],
      brainPointsEarned: json['brainPointsEarned'] ?? 0,
    );
  }
}

class DailyChallenge {
  final String id;
  final String date;
  final TestQuestion question;
  final int totalAttempts;
  final int correctAttempts;
  final bool alreadyAttempted;
  final DailyUserAnswer? userAnswer;

  DailyChallenge({
    required this.id,
    required this.date,
    required this.question,
    required this.totalAttempts,
    required this.correctAttempts,
    required this.alreadyAttempted,
    this.userAnswer,
  });

  factory DailyChallenge.fromJson(Map<String, dynamic> json) {
    return DailyChallenge(
      id: json['id'],
      date: json['date'],
      question: TestQuestion.fromJson(json['question']),
      totalAttempts: json['totalAttempts'] ?? 0,
      correctAttempts: json['correctAttempts'] ?? 0,
      alreadyAttempted: json['alreadyAttempted'] ?? false,
      userAnswer: json['userAnswer'] != null
          ? DailyUserAnswer.fromJson(json['userAnswer'])
          : null,
    );
  }
}

class DailyAttemptResponse {
  final bool isCorrect;
  final int correctAnswer;
  final String? explanation;
  final int brainPointsEarned;
  final int neuralCoinsEarned;
  final int streakBonus;
  final int streak;
  final List<Badge> newBadges;

  DailyAttemptResponse({
    required this.isCorrect,
    required this.correctAnswer,
    this.explanation,
    required this.brainPointsEarned,
    required this.neuralCoinsEarned,
    required this.streakBonus,
    required this.streak,
    this.newBadges = const [],
  });

  factory DailyAttemptResponse.fromJson(Map<String, dynamic> json) {
    return DailyAttemptResponse(
      isCorrect: json['isCorrect'],
      correctAnswer: json['correctAnswer'],
      explanation: json['explanation'],
      brainPointsEarned: json['brainPointsEarned'] ?? 0,
      neuralCoinsEarned: json['neuralCoinsEarned'] ?? 0,
      streakBonus: json['streakBonus'] ?? 0,
      streak: json['streak'] ?? 0,
      newBadges: (json['newBadges'] as List?)
              ?.map((b) => Badge.fromJson(b))
              .toList() ??
          [],
    );
  }
}

class DailyStats {
  final int brainPoints;
  final int neuralCoins;
  final int currentStreak;
  final int longestStreak;
  final int totalAttempts;
  final int correctAttempts;
  final int accuracy;

  DailyStats({
    required this.brainPoints,
    required this.neuralCoins,
    required this.currentStreak,
    required this.longestStreak,
    required this.totalAttempts,
    required this.correctAttempts,
    required this.accuracy,
  });

  factory DailyStats.fromJson(Map<String, dynamic> json) {
    return DailyStats(
      brainPoints: json['brainPoints'] ?? 0,
      neuralCoins: json['neuralCoins'] ?? 0,
      currentStreak: json['currentStreak'] ?? 0,
      longestStreak: json['longestStreak'] ?? 0,
      totalAttempts: json['totalAttempts'] ?? 0,
      correctAttempts: json['correctAttempts'] ?? 0,
      accuracy: json['accuracy'] ?? 0,
    );
  }
}
