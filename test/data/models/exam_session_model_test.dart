import 'package:flutter_test/flutter_test.dart';
import 'package:naturaliqcm/data/models/exam_session_model.dart';

void main() {
  group('ExamSessionModel', () {
    test('should have correct regulatory constants', () {
      expect(ExamSessionModel.totalQuestions, equals(40));
      expect(ExamSessionModel.maxDurationMinutes, equals(45));
      expect(ExamSessionModel.passingScore, equals(32));
      expect(ExamSessionModel.passingPercentage, equals(0.8));
    });

    test('should have correct theme distribution', () {
      final distribution = ExamSessionModel.themeDistribution;

      expect(distribution[1]!['total'], equals(11)); // Principes
      expect(distribution[1]!['practicalScenario'], equals(6));

      expect(distribution[2]!['total'], equals(6)); // Institutions
      expect(distribution[2]!['practicalScenario'], equals(0));

      expect(distribution[3]!['total'], equals(11)); // Droits
      expect(distribution[3]!['practicalScenario'], equals(6));

      expect(distribution[4]!['total'], equals(8)); // Histoire
      expect(distribution[4]!['practicalScenario'], equals(0));

      expect(distribution[5]!['total'], equals(4)); // Vivre
      expect(distribution[5]!['practicalScenario'], equals(0));

      // Total should be 40
      final totalQuestions = distribution.values
          .map((v) => v['total']!)
          .reduce((a, b) => a + b);
      expect(totalQuestions, equals(40));

      // Total practical scenarios should be 12
      final totalPractical = distribution.values
          .map((v) => v['practicalScenario']!)
          .reduce((a, b) => a + b);
      expect(totalPractical, equals(12));
    });

    test('should calculate score correctly when passing', () {
      // Arrange
      final session = ExamSessionModel(
        id: 1,
        userId: 1,
        startedAt: DateTime.now(),
        status: ExamSessionStatus.inProgress,
        answers: _createAnswers(32, 8), // 32 correct, 8 incorrect
      );

      // Act
      final calculated = session.calculateScore();

      // Assert
      expect(calculated.score, equals(32));
      expect(calculated.passed, isTrue);
      expect(calculated.status, equals(ExamSessionStatus.completed));
    });

    test('should calculate score correctly when failing', () {
      // Arrange
      final session = ExamSessionModel(
        id: 1,
        userId: 1,
        startedAt: DateTime.now(),
        status: ExamSessionStatus.inProgress,
        answers: _createAnswers(30, 10), // 30 correct, 10 incorrect
      );

      // Act
      final calculated = session.calculateScore();

      // Assert
      expect(calculated.score, equals(30));
      expect(calculated.passed, isFalse);
      expect(calculated.status, equals(ExamSessionStatus.completed));
    });

    test('should calculate theme breakdown correctly', () {
      // Arrange
      final answers = [
        ..._createAnswersForTheme(1, 8, 3), // Theme 1: 8 correct, 3 incorrect
        ..._createAnswersForTheme(2, 5, 1), // Theme 2: 5 correct, 1 incorrect
        ..._createAnswersForTheme(3, 10, 1), // Theme 3: 10 correct, 1 incorrect
      ];

      final session = ExamSessionModel(
        id: 1,
        userId: 1,
        startedAt: DateTime.now(),
        status: ExamSessionStatus.inProgress,
        answers: answers,
      );

      // Act
      final breakdown = session.getThemeBreakdown();

      // Assert
      expect(breakdown[1]!.totalQuestions, equals(11));
      expect(breakdown[1]!.correctAnswers, equals(8));
      expect(breakdown[1]!.percentage, closeTo(0.727, 0.01));

      expect(breakdown[2]!.totalQuestions, equals(6));
      expect(breakdown[2]!.correctAnswers, equals(5));
      expect(breakdown[2]!.percentage, closeTo(0.833, 0.01));

      expect(breakdown[3]!.totalQuestions, equals(11));
      expect(breakdown[3]!.correctAnswers, equals(10));
      expect(breakdown[3]!.percentage, closeTo(0.909, 0.01));
    });

    test('should calculate remaining seconds correctly', () {
      // Arrange
      final session = ExamSessionModel(
        id: 1,
        userId: 1,
        startedAt: DateTime.now(),
        status: ExamSessionStatus.inProgress,
        durationSeconds: 1200, // 20 minutes elapsed
      );

      // Act
      final remaining = session.getRemainingSeconds();

      // Assert
      expect(
        remaining,
        equals(1500),
      ); // 25 minutes remaining (45 - 20 = 25 * 60 = 1500)
    });

    test('should detect time expiration', () {
      // Arrange
      final session = ExamSessionModel(
        id: 1,
        userId: 1,
        startedAt: DateTime.now(),
        status: ExamSessionStatus.inProgress,
        durationSeconds: 2700, // 45 minutes
      );

      // Act
      final isExpired = session.isTimeExpired();

      // Assert
      expect(isExpired, isTrue);
    });

    test('should serialize to and from map correctly', () {
      // Arrange
      final original = ExamSessionModel(
        id: 1,
        userId: 2,
        startedAt: DateTime(2025, 11, 4, 10, 30),
        completedAt: DateTime(2025, 11, 4, 11, 15),
        status: ExamSessionStatus.completed,
        score: 35,
        passed: true,
        durationSeconds: 2400,
      );

      // Act
      final map = original.toMap();
      final restored = ExamSessionModel.fromMap(map);

      // Assert
      expect(restored.id, equals(original.id));
      expect(restored.userId, equals(original.userId));
      expect(restored.startedAt, equals(original.startedAt));
      expect(restored.completedAt, equals(original.completedAt));
      expect(restored.status, equals(original.status));
      expect(restored.score, equals(original.score));
      expect(restored.passed, equals(original.passed));
      expect(restored.durationSeconds, equals(original.durationSeconds));
    });
  });

  group('ThemeScoreBreakdown', () {
    test('should calculate percentage correctly', () {
      // Arrange
      final breakdown = ThemeScoreBreakdown(
        themeId: 1,
        totalQuestions: 10,
        correctAnswers: 7,
      );

      // Act
      final percentage = breakdown.percentage;

      // Assert
      expect(percentage, equals(0.7));
    });

    test('should handle zero total questions', () {
      // Arrange
      final breakdown = ThemeScoreBreakdown(
        themeId: 1,
        totalQuestions: 0,
        correctAnswers: 0,
      );

      // Act
      final percentage = breakdown.percentage;

      // Assert
      expect(percentage, equals(0.0));
    });
  });
}

/// Helper to create mock answers
List<ExamAnswerModel> _createAnswers(int correctCount, int incorrectCount) {
  final answers = <ExamAnswerModel>[];
  final now = DateTime.now();

  for (var i = 0; i < correctCount; i++) {
    answers.add(
      ExamAnswerModel(
        id: i,
        examSessionId: 1,
        questionId: i,
        themeId: 1,
        selectedChoiceId: i * 10,
        isCorrect: true,
        answeredAt: now,
      ),
    );
  }

  for (var i = 0; i < incorrectCount; i++) {
    answers.add(
      ExamAnswerModel(
        id: correctCount + i,
        examSessionId: 1,
        questionId: correctCount + i,
        themeId: 1,
        selectedChoiceId: (correctCount + i) * 10,
        isCorrect: false,
        answeredAt: now,
      ),
    );
  }

  return answers;
}

/// Helper to create answers for a specific theme
List<ExamAnswerModel> _createAnswersForTheme(
  int themeId,
  int correctCount,
  int incorrectCount,
) {
  final answers = <ExamAnswerModel>[];
  final now = DateTime.now();
  var questionId = themeId * 100;

  for (var i = 0; i < correctCount; i++) {
    answers.add(
      ExamAnswerModel(
        id: questionId,
        examSessionId: 1,
        questionId: questionId,
        themeId: themeId,
        selectedChoiceId: questionId * 10,
        isCorrect: true,
        answeredAt: now,
      ),
    );
    questionId++;
  }

  for (var i = 0; i < incorrectCount; i++) {
    answers.add(
      ExamAnswerModel(
        id: questionId,
        examSessionId: 1,
        questionId: questionId,
        themeId: themeId,
        selectedChoiceId: questionId * 10,
        isCorrect: false,
        answeredAt: now,
      ),
    );
    questionId++;
  }

  return answers;
}
