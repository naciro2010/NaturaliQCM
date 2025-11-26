import 'package:flutter_test/flutter_test.dart';
import 'package:naturaliqcm/data/models/question_model.dart';
import 'package:naturaliqcm/data/models/exam_session_model.dart';
import 'package:naturaliqcm/domain/use_cases/exam_question_selector.dart';

void main() {
  group('ExamQuestionSelector', () {
    late ExamQuestionSelector selector;

    setUp(() {
      selector = ExamQuestionSelector();
    });

    test('should select exactly 40 questions', () async {
      // Arrange
      final questionsByTheme = _createMockQuestionPool();

      // Act
      final selectedQuestions = await selector.selectExamQuestions(
        questionsByTheme,
      );

      // Assert
      expect(selectedQuestions.length, equals(40));
    });

    test(
      'should respect regulatory distribution for theme 1 (Principes)',
      () async {
        // Arrange
        final questionsByTheme = _createMockQuestionPool();

        // Act
        final selectedQuestions = await selector.selectExamQuestions(
          questionsByTheme,
        );

        // Assert
        final theme1Questions = selectedQuestions
            .where((q) => q.themeId == 1)
            .toList();
        final theme1Practical = theme1Questions
            .where((q) => q.type == QuestionType.practicalScenario)
            .length;

        expect(theme1Questions.length, equals(11)); // Total for theme 1
        expect(theme1Practical, equals(6)); // 6 practical scenarios
      },
    );

    test(
      'should respect regulatory distribution for theme 3 (Droits)',
      () async {
        // Arrange
        final questionsByTheme = _createMockQuestionPool();

        // Act
        final selectedQuestions = await selector.selectExamQuestions(
          questionsByTheme,
        );

        // Assert
        final theme3Questions = selectedQuestions
            .where((q) => q.themeId == 3)
            .toList();
        final theme3Practical = theme3Questions
            .where((q) => q.type == QuestionType.practicalScenario)
            .length;

        expect(theme3Questions.length, equals(11)); // Total for theme 3
        expect(theme3Practical, equals(6)); // 6 practical scenarios
      },
    );

    test('should respect distribution for all themes', () async {
      // Arrange
      final questionsByTheme = _createMockQuestionPool();

      // Act
      final selectedQuestions = await selector.selectExamQuestions(
        questionsByTheme,
      );

      // Assert
      final distribution = ExamSessionModel.themeDistribution;

      for (final entry in distribution.entries) {
        final themeId = entry.key;
        final expectedTotal = entry.value['total']!;
        final expectedPractical = entry.value['practicalScenario']!;

        final themeQuestions = selectedQuestions
            .where((q) => q.themeId == themeId)
            .toList();
        final practicalCount = themeQuestions
            .where((q) => q.type == QuestionType.practicalScenario)
            .length;

        expect(
          themeQuestions.length,
          equals(expectedTotal),
          reason: 'Theme $themeId should have $expectedTotal questions',
        );
        expect(
          practicalCount,
          equals(expectedPractical),
          reason:
              'Theme $themeId should have $expectedPractical practical scenarios',
        );
      }
    });

    test('should not have duplicate questions', () async {
      // Arrange
      final questionsByTheme = _createMockQuestionPool();

      // Act
      final selectedQuestions = await selector.selectExamQuestions(
        questionsByTheme,
      );

      // Assert
      final questionIds = selectedQuestions.map((q) => q.id).toSet();
      expect(questionIds.length, equals(selectedQuestions.length));
    });

    test('should validate selection correctly', () {
      // Arrange
      final validQuestions = _createValidSelection();

      // Act
      final isValid = selector.validateSelection(validQuestions);

      // Assert
      expect(isValid, isTrue);
    });

    test('should reject invalid selection with wrong count', () {
      // Arrange
      final invalidQuestions = _createValidSelection().take(35).toList();

      // Act
      final isValid = selector.validateSelection(invalidQuestions);

      // Assert
      expect(isValid, isFalse);
    });

    test('should shuffle question choices', () {
      // Arrange
      final question = _createMockQuestion(1, 1);

      // Act
      final shuffled = selector.shuffleQuestionChoices(question);

      // Assert
      expect(shuffled.choices.length, equals(question.choices.length));
      // Verify all choices are present (by ID)
      final originalIds = question.choices.map((c) => c.id).toSet();
      final shuffledIds = shuffled.choices.map((c) => c.id).toSet();
      expect(shuffledIds, equals(originalIds));
    });

    test('should throw exception when insufficient questions', () async {
      // Arrange - Not enough questions in pool
      final insufficientPool = {
        1: List.generate(5, (i) => _createMockQuestion(i, 1)),
      };

      // Act & Assert
      expect(
        () => selector.selectExamQuestions(insufficientPool),
        throwsA(isA<ExamSelectionException>()),
      );
    });
  });
}

/// Helper to create a mock question pool with sufficient questions
Map<int, List<QuestionModel>> _createMockQuestionPool() {
  return {
    1: [
      // Theme 1: Principes (need 11 total: 5 knowledge + 6 practical)
      ...List.generate(
        10,
        (i) => _createMockQuestion(i, 1, type: QuestionType.knowledge),
      ),
      ...List.generate(
        10,
        (i) => _createMockQuestion(
          i + 10,
          1,
          type: QuestionType.practicalScenario,
        ),
      ),
    ],
    2: [
      // Theme 2: Institutions (need 6 knowledge)
      ...List.generate(
        10,
        (i) => _createMockQuestion(i + 100, 2, type: QuestionType.knowledge),
      ),
    ],
    3: [
      // Theme 3: Droits (need 11 total: 5 knowledge + 6 practical)
      ...List.generate(
        10,
        (i) => _createMockQuestion(i + 200, 3, type: QuestionType.knowledge),
      ),
      ...List.generate(
        10,
        (i) => _createMockQuestion(
          i + 210,
          3,
          type: QuestionType.practicalScenario,
        ),
      ),
    ],
    4: [
      // Theme 4: Histoire (need 8 knowledge)
      ...List.generate(
        12,
        (i) => _createMockQuestion(i + 300, 4, type: QuestionType.knowledge),
      ),
    ],
    5: [
      // Theme 5: Vivre (need 4 knowledge)
      ...List.generate(
        8,
        (i) => _createMockQuestion(i + 400, 5, type: QuestionType.knowledge),
      ),
    ],
  };
}

/// Helper to create a mock question
QuestionModel _createMockQuestion(
  int id,
  int themeId, {
  QuestionType type = QuestionType.knowledge,
}) {
  return QuestionModel(
    id: id,
    themeId: themeId,
    type: type,
    difficulty: QuestionDifficulty.medium,
    questionText: 'Question $id',
    choices: [
      ChoiceModel(
        id: id * 10,
        questionId: id,
        choiceText: 'Choice A',
        isCorrect: true,
        displayOrder: 0,
      ),
      ChoiceModel(
        id: id * 10 + 1,
        questionId: id,
        choiceText: 'Choice B',
        isCorrect: false,
        displayOrder: 1,
      ),
      ChoiceModel(
        id: id * 10 + 2,
        questionId: id,
        choiceText: 'Choice C',
        isCorrect: false,
        displayOrder: 2,
      ),
      ChoiceModel(
        id: id * 10 + 3,
        questionId: id,
        choiceText: 'Choice D',
        isCorrect: false,
        displayOrder: 3,
      ),
    ],
    isPublic: type == QuestionType.knowledge,
  );
}

/// Helper to create a valid selection (for validation tests)
List<QuestionModel> _createValidSelection() {
  final questions = <QuestionModel>[];

  // Theme 1: 11 questions (6 practical)
  questions.addAll(
    List.generate(
      5,
      (i) => _createMockQuestion(i, 1, type: QuestionType.knowledge),
    ),
  );
  questions.addAll(
    List.generate(
      6,
      (i) =>
          _createMockQuestion(i + 5, 1, type: QuestionType.practicalScenario),
    ),
  );

  // Theme 2: 6 questions (0 practical)
  questions.addAll(
    List.generate(
      6,
      (i) => _createMockQuestion(i + 100, 2, type: QuestionType.knowledge),
    ),
  );

  // Theme 3: 11 questions (6 practical)
  questions.addAll(
    List.generate(
      5,
      (i) => _createMockQuestion(i + 200, 3, type: QuestionType.knowledge),
    ),
  );
  questions.addAll(
    List.generate(
      6,
      (i) =>
          _createMockQuestion(i + 205, 3, type: QuestionType.practicalScenario),
    ),
  );

  // Theme 4: 8 questions (0 practical)
  questions.addAll(
    List.generate(
      8,
      (i) => _createMockQuestion(i + 300, 4, type: QuestionType.knowledge),
    ),
  );

  // Theme 5: 4 questions (0 practical)
  questions.addAll(
    List.generate(
      4,
      (i) => _createMockQuestion(i + 400, 5, type: QuestionType.knowledge),
    ),
  );

  return questions;
}
