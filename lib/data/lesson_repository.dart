import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';
import 'database_helper.dart';
import 'models/lesson_model.dart';

/// Repository pour gérer les leçons
class LessonRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  /// Charge les leçons depuis le fichier JSON et les insère en base
  Future<void> loadLessonsFromAssets() async {
    final db = await _dbHelper.database;

    // Vérifie si les leçons sont déjà chargées
    final count = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM lessons')
    );

    if (count != null && count > 0) {
      return; // Leçons déjà chargées
    }

    // Charge le fichier JSON
    final String jsonString =
        await rootBundle.loadString('assets/data/lessons.json');
    final List<dynamic> jsonList = json.decode(jsonString);

    // Insère les leçons
    for (var lessonJson in jsonList) {
      await db.insert('lessons', lessonJson);
    }
  }

  /// Récupère toutes les leçons d'un thème
  Future<List<LessonModel>> getLessonsByTheme(int themeId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'lessons',
      where: 'theme_id = ?',
      whereArgs: [themeId],
      orderBy: 'display_order ASC',
    );

    return List.generate(maps.length, (i) => LessonModel.fromMap(maps[i]));
  }

  /// Récupère une leçon par son ID
  Future<LessonModel?> getLessonById(int id) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'lessons',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (maps.isEmpty) return null;
    return LessonModel.fromMap(maps.first);
  }

  /// Récupère la progression d'une leçon pour un utilisateur
  Future<LessonProgressModel?> getLessonProgress(
      int userId, int lessonId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'lesson_progress',
      where: 'user_id = ? AND lesson_id = ?',
      whereArgs: [userId, lessonId],
      limit: 1,
    );

    if (maps.isEmpty) return null;
    return LessonProgressModel.fromMap(maps.first);
  }

  /// Démarre une leçon
  Future<void> startLesson(int userId, int lessonId) async {
    final db = await _dbHelper.database;

    final existing = await getLessonProgress(userId, lessonId);
    if (existing != null) {
      return; // Déjà commencée
    }

    final progress = LessonProgressModel(
      userId: userId,
      lessonId: lessonId,
      startedAt: DateTime.now(),
      isCompleted: false,
    );

    await db.insert('lesson_progress', progress.toMap());
  }

  /// Marque une leçon comme terminée
  Future<void> completeLesson(int userId, int lessonId) async {
    final db = await _dbHelper.database;

    await db.update(
      'lesson_progress',
      {
        'completed_at': DateTime.now().toIso8601String(),
        'is_completed': 1,
      },
      where: 'user_id = ? AND lesson_id = ?',
      whereArgs: [userId, lessonId],
    );
  }

  /// Récupère toutes les leçons avec leur progression
  Future<List<Map<String, dynamic>>> getLessonsWithProgress(
      int userId, int themeId) async {
    final db = await _dbHelper.database;

    final List<Map<String, dynamic>> results = await db.rawQuery('''
      SELECT
        l.*,
        lp.is_completed,
        lp.started_at,
        lp.completed_at
      FROM lessons l
      LEFT JOIN lesson_progress lp ON l.id = lp.lesson_id AND lp.user_id = ?
      WHERE l.theme_id = ?
      ORDER BY l.display_order ASC
    ''', [userId, themeId]);

    return results;
  }

  /// Récupère le nombre de leçons terminées par thème
  Future<Map<int, int>> getCompletedLessonsByTheme(int userId) async {
    final db = await _dbHelper.database;

    final List<Map<String, dynamic>> results = await db.rawQuery('''
      SELECT
        l.theme_id,
        COUNT(*) as completed_count
      FROM lesson_progress lp
      JOIN lessons l ON lp.lesson_id = l.id
      WHERE lp.user_id = ? AND lp.is_completed = 1
      GROUP BY l.theme_id
    ''', [userId]);

    final Map<int, int> completedByTheme = {};
    for (var row in results) {
      completedByTheme[row['theme_id'] as int] = row['completed_count'] as int;
    }

    return completedByTheme;
  }

  /// Récupère le pourcentage de progression total
  Future<double> getOverallProgress(int userId) async {
    final db = await _dbHelper.database;

    final totalLessons = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM lessons')
    ) ?? 0;

    final completedLessons = Sqflite.firstIntValue(
      await db.rawQuery(
        'SELECT COUNT(*) FROM lesson_progress WHERE user_id = ? AND is_completed = 1',
        [userId],
      )
    ) ?? 0;

    if (totalLessons == 0) return 0.0;
    return completedLessons / totalLessons;
  }
}
