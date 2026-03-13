class QuestionOption {
  final String text;
  final String? imageUrl;

  QuestionOption({
    required this.text,
    this.imageUrl,
  });

  factory QuestionOption.fromJson(Map<String, dynamic> json) {
    return QuestionOption(
      text: json['text'] ?? '',
      imageUrl: json['imageUrl'],
    );
  }
}

class TestQuestion {
  final String id;
  final String category;
  final String content;
  final String? imageUrl;
  final List<QuestionOption> options;
  final int timeLimit;

  TestQuestion({
    required this.id,
    required this.category,
    required this.content,
    this.imageUrl,
    required this.options,
    required this.timeLimit,
  });

  factory TestQuestion.fromJson(Map<String, dynamic> json) {
    return TestQuestion(
      id: json['id'] ?? '',
      category: json['category'] ?? '',
      content: json['content'] ?? '',
      imageUrl: json['imageUrl'],
      options: ((json['options'] as List?) ?? []).map((o) {
        if (o is Map<String, dynamic>) {
          return QuestionOption.fromJson(o);
        }
        return QuestionOption(text: o.toString());
      }).toList(),
      timeLimit: json['timeLimit'] ?? 30,
    );
  }
}

class StartTestResponse {
  final String sessionId;
  final String mode;
  final bool verbalSkipped;
  final int totalTime;
  final List<TestQuestion> questions;

  StartTestResponse({
    required this.sessionId,
    required this.mode,
    required this.verbalSkipped,
    required this.totalTime,
    required this.questions,
  });

  factory StartTestResponse.fromJson(Map<String, dynamic> json) {
    return StartTestResponse(
      sessionId: json['sessionId'] ?? '',
      mode: json['mode'] ?? '',
      verbalSkipped: json['verbalSkipped'] ?? false,
      totalTime: json['totalTime'] ?? 0,
      questions: ((json['questions'] as List?) ?? [])
          .map((q) => TestQuestion.fromJson(q as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sessionId': sessionId,
      'mode': mode,
      'verbalSkipped': verbalSkipped,
      'totalTime': totalTime,
      'questions': questions
          .map((q) => {
                'id': q.id,
                'category': q.category,
                'content': q.content,
                'imageUrl': q.imageUrl,
                'options': q.options
                    .map((o) => {
                          'text': o.text,
                          'imageUrl': o.imageUrl,
                        })
                    .toList(),
                'timeLimit': q.timeLimit,
              })
          .toList(),
    };
  }
}

class TestAnswer {
  final String questionId;
  final int? selectedAnswer;
  final int responseTimeMs;

  TestAnswer({
    required this.questionId,
    required this.selectedAnswer,
    required this.responseTimeMs,
  });

  Map<String, dynamic> toJson() => {
        'questionId': questionId,
        'selectedAnswer': selectedAnswer,
        'responseTimeMs': responseTimeMs,
      };

  factory TestAnswer.fromJson(Map<String, dynamic> json) {
    return TestAnswer(
      questionId: json['questionId'] ?? '',
      selectedAnswer: json['selectedAnswer'],
      responseTimeMs: json['responseTimeMs'] ?? 0,
    );
  }
}
