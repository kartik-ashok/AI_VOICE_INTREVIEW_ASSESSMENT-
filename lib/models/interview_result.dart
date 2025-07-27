class InterviewResult {
  final String id;
  final String userId;
  final String userEmail;
  final String subject;
  final String topic;
  final List<QuestionAnswer> questions;
  final int timeElapsed;
  final DateTime completedAt;
  final double score;

  InterviewResult({
    required this.id,
    required this.userId,
    required this.userEmail,
    required this.subject,
    required this.topic,
    required this.questions,
    required this.timeElapsed,
    required this.completedAt,
    required this.score,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'userEmail': userEmail,
      'subject': subject,
      'topic': topic,
      'questions': questions.map((q) => q.toMap()).toList(),
      'timeElapsed': timeElapsed,
      'completedAt': completedAt.toIso8601String(),
      'score': score,
    };
  }

  factory InterviewResult.fromMap(Map<String, dynamic> map) {
    return InterviewResult(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      userEmail: map['userEmail'] ?? '',
      subject: map['subject'] ?? '',
      topic: map['topic'] ?? '',
      questions: List<QuestionAnswer>.from(
        map['questions']?.map((x) => QuestionAnswer.fromMap(x)) ?? [],
      ),
      timeElapsed: map['timeElapsed']?.toInt() ?? 0,
      completedAt: DateTime.parse(map['completedAt']),
      score: map['score']?.toDouble() ?? 0.0,
    );
  }
}

class QuestionAnswer {
  final String question;
  final String userAnswer;
  final String? aiFeedback;
  final bool hasAiFeedback;

  QuestionAnswer({
    required this.question,
    required this.userAnswer,
    this.aiFeedback,
    this.hasAiFeedback = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'question': question,
      'userAnswer': userAnswer,
      'aiFeedback': aiFeedback,
      'hasAiFeedback': hasAiFeedback,
    };
  }

  factory QuestionAnswer.fromMap(Map<String, dynamic> map) {
    return QuestionAnswer(
      question: map['question'] ?? '',
      userAnswer: map['userAnswer'] ?? '',
      aiFeedback: map['aiFeedback'],
      hasAiFeedback: map['hasAiFeedback'] ?? false,
    );
  }

  QuestionAnswer copyWith({
    String? question,
    String? userAnswer,
    String? aiFeedback,
    bool? hasAiFeedback,
  }) {
    return QuestionAnswer(
      question: question ?? this.question,
      userAnswer: userAnswer ?? this.userAnswer,
      aiFeedback: aiFeedback ?? this.aiFeedback,
      hasAiFeedback: hasAiFeedback ?? this.hasAiFeedback,
    );
  }
} 