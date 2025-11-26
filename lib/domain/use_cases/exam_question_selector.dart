import 'dart:math';
import '../../data/models/question_model.dart';
import '../../data/models/exam_session_model.dart';

/// Moteur de sélection des questions d'examen conforme à l'arrêté du 10 octobre 2025
/// Garantit la répartition réglementaire : 40 questions, distribution exacte par thème
class ExamQuestionSelector {
  final Random _random = Random();

  /// Sélectionne 40 questions conformes à la distribution réglementaire
  ///
  /// Distribution imposée:
  /// - Thème 1 (Principes): 11 questions (dont 6 mises en situation)
  /// - Thème 2 (Institutions): 6 questions (0 mise en situation)
  /// - Thème 3 (Droits): 11 questions (dont 6 mises en situation)
  /// - Thème 4 (Histoire): 8 questions (0 mise en situation)
  /// - Thème 5 (Vivre): 4 questions (0 mise en situation)
  ///
  /// Total: 40 questions (dont 12 mises en situation)
  Future<List<QuestionModel>> selectExamQuestions(
    Map<int, List<QuestionModel>> questionsByTheme,
  ) async {
    final List<QuestionModel> selectedQuestions = [];

    // Validation: vérifier qu'on a assez de questions dans chaque thème
    _validateQuestionPool(questionsByTheme);

    // Pour chaque thème, sélectionner selon la distribution
    for (final entry in ExamSessionModel.themeDistribution.entries) {
      final themeId = entry.key;
      final distribution = entry.value;
      final totalRequired = distribution['total']!;
      final practicalRequired = distribution['practicalScenario']!;

      final themeQuestions = questionsByTheme[themeId] ?? [];

      // Séparer les questions de connaissance et les mises en situation
      final knowledgeQuestions = themeQuestions
          .where((q) => q.type == QuestionType.knowledge)
          .toList();
      final practicalQuestions = themeQuestions
          .where((q) => q.type == QuestionType.practicalScenario)
          .toList();

      // Sélectionner les mises en situation requises
      final selectedPractical = _selectRandomQuestions(
        practicalQuestions,
        practicalRequired,
      );
      selectedQuestions.addAll(selectedPractical);

      // Sélectionner les questions de connaissance pour compléter
      final knowledgeRequired = totalRequired - practicalRequired;
      final selectedKnowledge = _selectRandomQuestions(
        knowledgeQuestions,
        knowledgeRequired,
      );
      selectedQuestions.addAll(selectedKnowledge);
    }

    // Vérification finale
    if (selectedQuestions.length != ExamSessionModel.totalQuestions) {
      throw ExamSelectionException(
        'Nombre de questions incorrect: ${selectedQuestions.length} au lieu de ${ExamSessionModel.totalQuestions}',
      );
    }

    // Mélanger l'ordre des questions
    selectedQuestions.shuffle(_random);

    return selectedQuestions;
  }

  /// Sélectionne N questions aléatoires sans doublon
  List<QuestionModel> _selectRandomQuestions(
    List<QuestionModel> pool,
    int count,
  ) {
    if (count == 0) return [];

    if (pool.length < count) {
      throw ExamSelectionException(
        'Pas assez de questions dans le pool: ${pool.length} disponibles, $count requises',
      );
    }

    // Copier le pool pour ne pas modifier l'original
    final shuffledPool = List<QuestionModel>.from(pool);
    shuffledPool.shuffle(_random);

    return shuffledPool.take(count).toList();
  }

  /// Valide que le pool de questions est suffisant
  void _validateQuestionPool(Map<int, List<QuestionModel>> questionsByTheme) {
    for (final entry in ExamSessionModel.themeDistribution.entries) {
      final themeId = entry.key;
      final distribution = entry.value;
      final totalRequired = distribution['total']!;
      final practicalRequired = distribution['practicalScenario']!;

      final themeQuestions = questionsByTheme[themeId] ?? [];
      final knowledgeCount = themeQuestions
          .where((q) => q.type == QuestionType.knowledge)
          .length;
      final practicalCount = themeQuestions
          .where((q) => q.type == QuestionType.practicalScenario)
          .length;

      final knowledgeRequired = totalRequired - practicalRequired;

      if (knowledgeCount < knowledgeRequired) {
        throw ExamSelectionException(
          'Thème $themeId: pas assez de questions de connaissance ($knowledgeCount/$knowledgeRequired)',
        );
      }

      if (practicalCount < practicalRequired) {
        throw ExamSelectionException(
          'Thème $themeId: pas assez de mises en situation ($practicalCount/$practicalRequired)',
        );
      }
    }
  }

  /// Mélange les choix d'une question (important pour l'équité)
  QuestionModel shuffleQuestionChoices(QuestionModel question) {
    final shuffledChoices = List<ChoiceModel>.from(question.choices);
    shuffledChoices.shuffle(_random);

    // Créer une nouvelle liste avec les ordres mis à jour
    final reorderedChoices = shuffledChoices
        .asMap()
        .entries
        .map(
          (entry) => ChoiceModel(
            id: entry.value.id,
            questionId: entry.value.questionId,
            choiceText: entry.value.choiceText,
            isCorrect: entry.value.isCorrect,
            displayOrder: entry.key,
          ),
        )
        .toList();

    return QuestionModel(
      id: question.id,
      themeId: question.themeId,
      subthemeId: question.subthemeId,
      type: question.type,
      difficulty: question.difficulty,
      questionText: question.questionText,
      choices: reorderedChoices,
      explanation: question.explanation,
      lessonReference: question.lessonReference,
      isPublic: question.isPublic,
    );
  }

  /// Vérifie qu'une sélection respecte la distribution réglementaire
  bool validateSelection(List<QuestionModel> questions) {
    if (questions.length != ExamSessionModel.totalQuestions) {
      return false;
    }

    // Vérifier la distribution par thème
    for (final entry in ExamSessionModel.themeDistribution.entries) {
      final themeId = entry.key;
      final distribution = entry.value;
      final totalRequired = distribution['total']!;
      final practicalRequired = distribution['practicalScenario']!;

      final themeQuestions = questions.where((q) => q.themeId == themeId);
      final practicalCount = themeQuestions
          .where((q) => q.type == QuestionType.practicalScenario)
          .length;

      if (themeQuestions.length != totalRequired) {
        return false;
      }

      if (practicalCount != practicalRequired) {
        return false;
      }
    }

    // Vérifier l'unicité des questions
    final uniqueIds = questions.map((q) => q.id).toSet();
    if (uniqueIds.length != questions.length) {
      return false;
    }

    return true;
  }
}

/// Exception levée lors d'un problème de sélection
class ExamSelectionException implements Exception {
  final String message;

  ExamSelectionException(this.message);

  @override
  String toString() => 'ExamSelectionException: $message';
}
