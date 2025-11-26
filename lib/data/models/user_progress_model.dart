/// Modèle pour le suivi de la progression de l'utilisateur avec répétition espacée
class UserProgressModel {
  final int? id;
  final int userId;
  final int questionId;
  final DateTime lastSeenAt;
  final int timesSeen;
  final int timesCorrect;
  final int spacedRepetitionBox; // Box Leitner (1-5)
  final DateTime nextReviewAt;

  const UserProgressModel({
    this.id,
    required this.userId,
    required this.questionId,
    required this.lastSeenAt,
    required this.timesSeen,
    required this.timesCorrect,
    required this.spacedRepetitionBox,
    required this.nextReviewAt,
  });

  factory UserProgressModel.fromMap(Map<String, dynamic> map) {
    return UserProgressModel(
      id: map['id'] as int?,
      userId: map['user_id'] as int,
      questionId: map['question_id'] as int,
      lastSeenAt: DateTime.parse(map['last_seen_at'] as String),
      timesSeen: map['times_seen'] as int,
      timesCorrect: map['times_correct'] as int,
      spacedRepetitionBox: map['spaced_repetition_box'] as int,
      nextReviewAt: DateTime.parse(map['next_review_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'user_id': userId,
      'question_id': questionId,
      'last_seen_at': lastSeenAt.toIso8601String(),
      'times_seen': timesSeen,
      'times_correct': timesCorrect,
      'spaced_repetition_box': spacedRepetitionBox,
      'next_review_at': nextReviewAt.toIso8601String(),
    };
  }

  /// Taux de réussite (0.0 à 1.0)
  double get successRate => timesSeen > 0 ? timesCorrect / timesSeen : 0.0;

  /// Est-ce qu'une révision est due?
  bool get isDueForReview => DateTime.now().isAfter(nextReviewAt);

  UserProgressModel copyWith({
    int? id,
    int? userId,
    int? questionId,
    DateTime? lastSeenAt,
    int? timesSeen,
    int? timesCorrect,
    int? spacedRepetitionBox,
    DateTime? nextReviewAt,
  }) {
    return UserProgressModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      questionId: questionId ?? this.questionId,
      lastSeenAt: lastSeenAt ?? this.lastSeenAt,
      timesSeen: timesSeen ?? this.timesSeen,
      timesCorrect: timesCorrect ?? this.timesCorrect,
      spacedRepetitionBox: spacedRepetitionBox ?? this.spacedRepetitionBox,
      nextReviewAt: nextReviewAt ?? this.nextReviewAt,
    );
  }
}
