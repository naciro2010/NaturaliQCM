/// Type de question selon l'arrêté
enum QuestionType {
  knowledge, // Question de connaissance (publique)
  practicalScenario, // Mise en situation
}

/// Niveau de difficulté
enum QuestionDifficulty { easy, medium, hard }

/// Modèle de question conforme aux exigences réglementaires
class QuestionModel {
  final int id;
  final int themeId;
  final int? subthemeId;
  final QuestionType type;
  final QuestionDifficulty difficulty;
  final String questionText;
  final List<ChoiceModel> choices;
  final String? explanation; // Explication détaillée pour l'apprentissage
  final String? lessonReference; // Référence vers la leçon associée
  final bool isPublic; // Les questions de connaissance doivent être publiques

  const QuestionModel({
    required this.id,
    required this.themeId,
    this.subthemeId,
    required this.type,
    required this.difficulty,
    required this.questionText,
    required this.choices,
    this.explanation,
    this.lessonReference,
    required this.isPublic,
  });

  factory QuestionModel.fromMap(Map<String, dynamic> map) {
    return QuestionModel(
      id: map['id'] as int,
      themeId: map['theme_id'] as int,
      subthemeId: map['subtheme_id'] as int?,
      type: QuestionType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => QuestionType.knowledge,
      ),
      difficulty: QuestionDifficulty.values.firstWhere(
        (e) => e.name == map['difficulty'],
        orElse: () => QuestionDifficulty.medium,
      ),
      questionText: map['question_text'] as String,
      choices: [], // Loaded separately via JOIN
      explanation: map['explanation'] as String?,
      lessonReference: map['lesson_reference'] as String?,
      isPublic: (map['is_public'] as int) == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'theme_id': themeId,
      'subtheme_id': subthemeId,
      'type': type.name,
      'difficulty': difficulty.name,
      'question_text': questionText,
      'explanation': explanation,
      'lesson_reference': lessonReference,
      'is_public': isPublic ? 1 : 0,
    };
  }

  /// Retourne le choix correct
  ChoiceModel? get correctChoice {
    return choices.firstWhere(
      (choice) => choice.isCorrect,
      orElse: () => choices.first,
    );
  }
}

/// Modèle de choix de réponse
class ChoiceModel {
  final int id;
  final int questionId;
  final String choiceText;
  final bool isCorrect;
  final int displayOrder;

  const ChoiceModel({
    required this.id,
    required this.questionId,
    required this.choiceText,
    required this.isCorrect,
    required this.displayOrder,
  });

  factory ChoiceModel.fromMap(Map<String, dynamic> map) {
    return ChoiceModel(
      id: map['id'] as int,
      questionId: map['question_id'] as int,
      choiceText: map['choice_text'] as String,
      isCorrect: (map['is_correct'] as int) == 1,
      displayOrder: map['display_order'] as int,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'question_id': questionId,
      'choice_text': choiceText,
      'is_correct': isCorrect ? 1 : 0,
      'display_order': displayOrder,
    };
  }
}
