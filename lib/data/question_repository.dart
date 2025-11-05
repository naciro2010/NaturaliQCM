import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';
import 'database_helper.dart';
import 'models/question_model.dart';

/// Repository pour gérer les questions
class QuestionRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  /// Charge les questions depuis le fichier JSON et les insère en base
  Future<void> loadQuestionsFromAssets() async {
    final db = await _dbHelper.database;

    // Vérifie si les questions sont déjà chargées
    final count = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM questions')
    );

    if (count != null && count > 0) {
      return; // Questions déjà chargées
    }

    // Charge le fichier JSON
    final String jsonString =
        await rootBundle.loadString('assets/data/questions.json');
    final Map<String, dynamic> jsonData = json.decode(jsonString);
    final List<dynamic> questionsList = jsonData['questions'];

    // Insère les questions et leurs choix
    for (var questionJson in questionsList) {
      // Insère la question
      final questionId = await db.insert('questions', {
        'theme_id': questionJson['theme_id'],
        'subtheme_id': questionJson['subtheme_id'],
        'question_text': questionJson['question_text'],
        'explanation': questionJson['explanation'],
        'lesson_reference': questionJson['lesson_reference'],
        'type': questionJson['type'],
        'difficulty': questionJson['difficulty'],
        'is_public': questionJson['is_public'] ? 1 : 0,
      });

      // Insère les choix de réponse
      final List<dynamic> choices = questionJson['choices'];
      for (var choiceJson in choices) {
        await db.insert('choices', {
          'question_id': questionId,
          'choice_text': choiceJson['choice_text'],
          'is_correct': choiceJson['is_correct'] ? 1 : 0,
          'display_order': choiceJson['display_order'],
        });
      }
    }
  }

  /// Récupère une question avec ses choix
  Future<QuestionModel?> getQuestionById(int id) async {
    final db = await _dbHelper.database;

    final List<Map<String, dynamic>> questionMaps = await db.query(
      'questions',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (questionMaps.isEmpty) return null;

    final questionMap = questionMaps.first;

    // Récupère les choix
    final List<Map<String, dynamic>> choiceMaps = await db.query(
      'choices',
      where: 'question_id = ?',
      whereArgs: [id],
      orderBy: 'display_order ASC',
    );

    final choices = choiceMaps.map((map) => ChoiceModel.fromMap(map)).toList();

    return QuestionModel(
      id: questionMap['id'] as int,
      themeId: questionMap['theme_id'] as int,
      subthemeId: questionMap['subtheme_id'] as int?,
      type: QuestionType.values.firstWhere(
        (e) => e.toString().split('.').last == questionMap['type'],
      ),
      difficulty: Difficulty.values.firstWhere(
        (e) => e.toString().split('.').last == questionMap['difficulty'],
      ),
      questionText: questionMap['question_text'] as String,
      choices: choices,
      explanation: questionMap['explanation'] as String?,
      lessonReference: questionMap['lesson_reference'] as String?,
      isPublic: (questionMap['is_public'] as int) == 1,
    );
  }

  /// Récupère plusieurs questions par leurs IDs
  Future<List<QuestionModel>> getQuestionsByIds(List<int> ids) async {
    if (ids.isEmpty) return [];

    final List<QuestionModel> questions = [];
    for (var id in ids) {
      final question = await getQuestionById(id);
      if (question != null) {
        questions.add(question);
      }
    }
    return questions;
  }

  /// Récupère toutes les questions d'un thème
  Future<List<QuestionModel>> getQuestionsByTheme(int themeId) async {
    final db = await _dbHelper.database;

    final List<Map<String, dynamic>> questionMaps = await db.query(
      'questions',
      where: 'theme_id = ?',
      whereArgs: [themeId],
    );

    final List<QuestionModel> questions = [];
    for (var questionMap in questionMaps) {
      final question = await getQuestionById(questionMap['id'] as int);
      if (question != null) {
        questions.add(question);
      }
    }
    return questions;
  }

  /// Récupère toutes les questions d'un sous-thème
  Future<List<QuestionModel>> getQuestionsBySubtheme(int subthemeId) async {
    final db = await _dbHelper.database;

    final List<Map<String, dynamic>> questionMaps = await db.query(
      'questions',
      where: 'subtheme_id = ?',
      whereArgs: [subthemeId],
    );

    final List<QuestionModel> questions = [];
    for (var questionMap in questionMaps) {
      final question = await getQuestionById(questionMap['id'] as int);
      if (question != null) {
        questions.add(question);
      }
    }
    return questions;
  }

  /// Récupère les questions liées à une leçon spécifique
  Future<List<QuestionModel>> getQuestionsByLessonReference(
      String lessonReference) async {
    final db = await _dbHelper.database;

    final List<Map<String, dynamic>> questionMaps = await db.query(
      'questions',
      where: 'lesson_reference = ?',
      whereArgs: [lessonReference],
    );

    final List<QuestionModel> questions = [];
    for (var questionMap in questionMaps) {
      final question = await getQuestionById(questionMap['id'] as int);
      if (question != null) {
        questions.add(question);
      }
    }
    return questions;
  }

  /// Récupère le nombre total de questions
  Future<int> getTotalQuestionCount() async {
    final db = await _dbHelper.database;
    final count = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM questions')
    );
    return count ?? 0;
  }

  /// Récupère le nombre de questions par thème
  Future<Map<int, int>> getQuestionCountByTheme() async {
    final db = await _dbHelper.database;

    final List<Map<String, dynamic>> results = await db.rawQuery('''
      SELECT theme_id, COUNT(*) as count
      FROM questions
      GROUP BY theme_id
    ''');

    final Map<int, int> countByTheme = {};
    for (var row in results) {
      countByTheme[row['theme_id'] as int] = row['count'] as int;
    }
    return countByTheme;
  }

  /// Récupère les questions par difficulté
  Future<List<QuestionModel>> getQuestionsByDifficulty(
      Difficulty difficulty, {int? themeId}) async {
    final db = await _dbHelper.database;

    String whereClause = 'difficulty = ?';
    List<dynamic> whereArgs = [difficulty.toString().split('.').last];

    if (themeId != null) {
      whereClause += ' AND theme_id = ?';
      whereArgs.add(themeId);
    }

    final List<Map<String, dynamic>> questionMaps = await db.query(
      'questions',
      where: whereClause,
      whereArgs: whereArgs,
    );

    final List<QuestionModel> questions = [];
    for (var questionMap in questionMaps) {
      final question = await getQuestionById(questionMap['id'] as int);
      if (question != null) {
        questions.add(question);
      }
    }
    return questions;
  }

  /// Récupère les questions par type
  Future<List<QuestionModel>> getQuestionsByType(
      QuestionType type, {int? themeId}) async {
    final db = await _dbHelper.database;

    String whereClause = 'type = ?';
    List<dynamic> whereArgs = [type.toString().split('.').last];

    if (themeId != null) {
      whereClause += ' AND theme_id = ?';
      whereArgs.add(themeId);
    }

    final List<Map<String, dynamic>> questionMaps = await db.query(
      'questions',
      where: whereClause,
      whereArgs: whereArgs,
    );

    final List<QuestionModel> questions = [];
    for (var questionMap in questionMaps) {
      final question = await getQuestionById(questionMap['id'] as int);
      if (question != null) {
        questions.add(question);
      }
    }
    return questions;
  }

  /// Génère un examen officiel conforme à l'arrêté du 10 octobre 2025
  /// Distribution: Principes 11 (6 MS), Institutions 6, Droits 11 (6 MS), Histoire 8, Vivre 4
  /// Total: 40 questions (dont 12 mises en situation)
  Future<List<QuestionModel>> generateOfficialExam() async {
    final db = await _dbHelper.database;
    final List<QuestionModel> examQuestions = [];

    // Distribution réglementaire par thème
    // themeId: {total, practicalScenario}
    final distribution = {
      1: {'total': 11, 'practicalScenario': 6}, // Principes et valeurs
      2: {'total': 6, 'practicalScenario': 0},  // Institutions
      3: {'total': 11, 'practicalScenario': 6}, // Droits et devoirs
      4: {'total': 8, 'practicalScenario': 0},  // Histoire, culture
      5: {'total': 4, 'practicalScenario': 0},  // Vivre en France
    };

    for (var themeId in distribution.keys) {
      final themeDistribution = distribution[themeId]!;
      final totalQuestions = themeDistribution['total'] as int;
      final practicalScenarioCount = themeDistribution['practicalScenario'] as int;
      final knowledgeCount = totalQuestions - practicalScenarioCount;

      // Récupérer les questions de mise en situation
      if (practicalScenarioCount > 0) {
        final practicalQuestions = await db.query(
          'questions',
          where: 'theme_id = ? AND type = ?',
          whereArgs: [themeId, 'practicalScenario'],
          orderBy: 'RANDOM()',
          limit: practicalScenarioCount,
        );

        for (var questionMap in practicalQuestions) {
          final question = await getQuestionById(questionMap['id'] as int);
          if (question != null) {
            examQuestions.add(question);
          }
        }
      }

      // Récupérer les questions de connaissance
      if (knowledgeCount > 0) {
        final knowledgeQuestions = await db.query(
          'questions',
          where: 'theme_id = ? AND type = ?',
          whereArgs: [themeId, 'knowledge'],
          orderBy: 'RANDOM()',
          limit: knowledgeCount,
        );

        for (var questionMap in knowledgeQuestions) {
          final question = await getQuestionById(questionMap['id'] as int);
          if (question != null) {
            examQuestions.add(question);
          }
        }
      }
    }

    // Vérifier qu'on a bien 40 questions
    if (examQuestions.length != 40) {
      throw Exception(
        'Impossible de générer un examen conforme: seulement ${examQuestions.length} questions disponibles'
      );
    }

    // Mélanger les questions pour l'examen
    examQuestions.shuffle();

    return examQuestions;
  }
}
