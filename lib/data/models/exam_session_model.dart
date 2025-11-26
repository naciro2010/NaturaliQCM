import 'question_model.dart';

/// Statut d'une session d'examen
enum ExamSessionStatus { inProgress, completed, abandoned }

/// Modèle de session d'examen conforme aux exigences réglementaires
/// 40 questions, 45 minutes max, réussite ≥ 80% (32/40)
class ExamSessionModel {
  final int id;
  final int userId;
  final DateTime startedAt;
  final DateTime? completedAt;
  final ExamSessionStatus status;
  final int? score; // Score sur 40
  final bool? passed; // true si score ≥ 32
  final int durationSeconds; // Durée réelle en secondes
  final List<ExamAnswerModel> answers;

  const ExamSessionModel({
    required this.id,
    required this.userId,
    required this.startedAt,
    this.completedAt,
    required this.status,
    this.score,
    this.passed,
    this.durationSeconds = 0,
    this.answers = const [],
  });

  factory ExamSessionModel.fromMap(Map<String, dynamic> map) {
    return ExamSessionModel(
      id: map['id'] as int,
      userId: map['user_id'] as int,
      startedAt: DateTime.parse(map['started_at'] as String),
      completedAt: map['completed_at'] != null
          ? DateTime.parse(map['completed_at'] as String)
          : null,
      status: ExamSessionStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => ExamSessionStatus.inProgress,
      ),
      score: map['score'] as int?,
      passed: map['passed'] != null ? (map['passed'] as int) == 1 : null,
      durationSeconds: map['duration_seconds'] as int? ?? 0,
      answers: [], // Loaded separately
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'started_at': startedAt.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
      'status': status.name,
      'score': score,
      'passed': passed != null ? (passed! ? 1 : 0) : null,
      'duration_seconds': durationSeconds,
    };
  }

  /// Constantes réglementaires
  static const int totalQuestions = 40;
  static const int maxDurationMinutes = 45;
  static const int passingScore = 32; // 80% de 40
  static const double passingPercentage = 0.8;

  /// Distribution réglementaire des questions par thème
  /// Principes: 11 (6 MS), Institutions: 6, Droits: 11 (6 MS), Histoire: 8, Vivre: 4
  static const Map<int, Map<String, int>> themeDistribution = {
    1: {'total': 11, 'practicalScenario': 6}, // Principes et valeurs
    2: {'total': 6, 'practicalScenario': 0}, // Institutions
    3: {'total': 11, 'practicalScenario': 6}, // Droits et devoirs
    4: {'total': 8, 'practicalScenario': 0}, // Histoire, culture
    5: {'total': 4, 'practicalScenario': 0}, // Vivre en France
  };

  /// Calcule le score et le statut de réussite
  ExamSessionModel calculateScore() {
    final correctAnswers = answers.where((a) => a.isCorrect).length;
    final isPassed = correctAnswers >= passingScore;

    return ExamSessionModel(
      id: id,
      userId: userId,
      startedAt: startedAt,
      completedAt: completedAt ?? DateTime.now(),
      status: ExamSessionStatus.completed,
      score: correctAnswers,
      passed: isPassed,
      durationSeconds: durationSeconds,
      answers: answers,
    );
  }

  /// Obtient un breakdown par thème
  Map<int, ThemeScoreBreakdown> getThemeBreakdown() {
    final Map<int, ThemeScoreBreakdown> breakdown = {};

    for (final answer in answers) {
      final themeId = answer.themeId;
      if (!breakdown.containsKey(themeId)) {
        breakdown[themeId] = ThemeScoreBreakdown(
          themeId: themeId,
          totalQuestions: 0,
          correctAnswers: 0,
        );
      }

      breakdown[themeId] = ThemeScoreBreakdown(
        themeId: themeId,
        totalQuestions: breakdown[themeId]!.totalQuestions + 1,
        correctAnswers:
            breakdown[themeId]!.correctAnswers + (answer.isCorrect ? 1 : 0),
      );
    }

    return breakdown;
  }

  /// Temps restant en secondes
  int getRemainingSeconds() {
    final maxSeconds = maxDurationMinutes * 60;
    return maxSeconds - durationSeconds;
  }

  /// Vérifie si le temps est écoulé
  bool isTimeExpired() {
    return getRemainingSeconds() <= 0;
  }
}

/// Modèle de réponse à une question d'examen
class ExamAnswerModel {
  final int id;
  final int examSessionId;
  final int questionId;
  final int themeId;
  final int selectedChoiceId;
  final bool isCorrect;
  final DateTime answeredAt;

  const ExamAnswerModel({
    required this.id,
    required this.examSessionId,
    required this.questionId,
    required this.themeId,
    required this.selectedChoiceId,
    required this.isCorrect,
    required this.answeredAt,
  });

  factory ExamAnswerModel.fromMap(Map<String, dynamic> map) {
    return ExamAnswerModel(
      id: map['id'] as int,
      examSessionId: map['exam_session_id'] as int,
      questionId: map['question_id'] as int,
      themeId: map['theme_id'] as int,
      selectedChoiceId: map['selected_choice_id'] as int,
      isCorrect: (map['is_correct'] as int) == 1,
      answeredAt: DateTime.parse(map['answered_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'exam_session_id': examSessionId,
      'question_id': questionId,
      'theme_id': themeId,
      'selected_choice_id': selectedChoiceId,
      'is_correct': isCorrect ? 1 : 0,
      'answered_at': answeredAt.toIso8601String(),
    };
  }
}

/// Breakdown du score par thème
class ThemeScoreBreakdown {
  final int themeId;
  final int totalQuestions;
  final int correctAnswers;

  const ThemeScoreBreakdown({
    required this.themeId,
    required this.totalQuestions,
    required this.correctAnswers,
  });

  double get percentage =>
      totalQuestions > 0 ? correctAnswers / totalQuestions : 0.0;
}
