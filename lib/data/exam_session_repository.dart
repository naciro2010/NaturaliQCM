import 'package:sqflite/sqflite.dart';
import 'database_helper.dart';
import 'models/exam_session_model.dart';
import 'models/question_model.dart';

/// Repository pour gérer les sessions d'examen et d'entraînement
class ExamSessionRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  /// Crée une nouvelle session d'examen
  Future<int> createSession(int userId) async {
    final db = await _dbHelper.database;
    return await db.insert('exam_sessions', {
      'user_id': userId,
      'started_at': DateTime.now().toIso8601String(),
      'status': ExamSessionStatus.inProgress.name,
      'duration_seconds': 0,
    });
  }

  /// Récupère une session par son ID avec toutes ses réponses
  Future<ExamSessionModel?> getSessionById(int sessionId) async {
    final db = await _dbHelper.database;

    // Récupérer la session
    final sessionMaps = await db.query(
      'exam_sessions',
      where: 'id = ?',
      whereArgs: [sessionId],
    );

    if (sessionMaps.isEmpty) return null;

    final sessionMap = sessionMaps.first;

    // Récupérer les réponses
    final answerMaps = await db.query(
      'exam_answers',
      where: 'exam_session_id = ?',
      whereArgs: [sessionId],
      orderBy: 'answered_at ASC',
    );

    final answers =
        answerMaps.map((map) => ExamAnswerModel.fromMap(map)).toList();

    return ExamSessionModel.fromMap(sessionMap).copyWith(answers: answers);
  }

  /// Récupère toutes les sessions d'un utilisateur (triées par date décroissante)
  Future<List<ExamSessionModel>> getUserSessions(int userId,
      {int? limit}) async {
    final db = await _dbHelper.database;

    final sessionMaps = await db.query(
      'exam_sessions',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'started_at DESC',
      limit: limit,
    );

    final sessions = <ExamSessionModel>[];

    for (final sessionMap in sessionMaps) {
      final sessionId = sessionMap['id'] as int;

      // Récupérer les réponses pour cette session
      final answerMaps = await db.query(
        'exam_answers',
        where: 'exam_session_id = ?',
        whereArgs: [sessionId],
        orderBy: 'answered_at ASC',
      );

      final answers =
          answerMaps.map((map) => ExamAnswerModel.fromMap(map)).toList();

      sessions.add(
        ExamSessionModel.fromMap(sessionMap).copyWith(answers: answers),
      );
    }

    return sessions;
  }

  /// Récupère les sessions complétées d'un utilisateur
  Future<List<ExamSessionModel>> getCompletedSessions(int userId) async {
    final db = await _dbHelper.database;

    final sessionMaps = await db.query(
      'exam_sessions',
      where: 'user_id = ? AND status = ?',
      whereArgs: [userId, ExamSessionStatus.completed.name],
      orderBy: 'completed_at DESC',
    );

    final sessions = <ExamSessionModel>[];

    for (final sessionMap in sessionMaps) {
      final sessionId = sessionMap['id'] as int;
      final answerMaps = await db.query(
        'exam_answers',
        where: 'exam_session_id = ?',
        whereArgs: [sessionId],
      );

      final answers =
          answerMaps.map((map) => ExamAnswerModel.fromMap(map)).toList();

      sessions.add(
        ExamSessionModel.fromMap(sessionMap).copyWith(answers: answers),
      );
    }

    return sessions;
  }

  /// Sauvegarde une réponse à une question
  Future<int> saveAnswer({
    required int examSessionId,
    required int questionId,
    required int themeId,
    required int selectedChoiceId,
    required bool isCorrect,
  }) async {
    final db = await _dbHelper.database;

    return await db.insert('exam_answers', {
      'exam_session_id': examSessionId,
      'question_id': questionId,
      'theme_id': themeId,
      'selected_choice_id': selectedChoiceId,
      'is_correct': isCorrect ? 1 : 0,
      'answered_at': DateTime.now().toIso8601String(),
    });
  }

  /// Met à jour le statut et les résultats d'une session
  Future<int> updateSession({
    required int sessionId,
    required ExamSessionStatus status,
    int? score,
    bool? passed,
    int? durationSeconds,
  }) async {
    final db = await _dbHelper.database;

    final Map<String, dynamic> updates = {
      'status': status.name,
    };

    if (status == ExamSessionStatus.completed) {
      updates['completed_at'] = DateTime.now().toIso8601String();
    }

    if (score != null) updates['score'] = score;
    if (passed != null) updates['passed'] = passed ? 1 : 0;
    if (durationSeconds != null) updates['duration_seconds'] = durationSeconds;

    return await db.update(
      'exam_sessions',
      updates,
      where: 'id = ?',
      whereArgs: [sessionId],
    );
  }

  /// Récupère les statistiques globales des sessions
  Future<Map<String, dynamic>> getSessionStatistics(int userId) async {
    final db = await _dbHelper.database;

    // Nombre total de sessions complétées
    final totalSessions = Sqflite.firstIntValue(await db.rawQuery(
      'SELECT COUNT(*) FROM exam_sessions WHERE user_id = ? AND status = ?',
      [userId, ExamSessionStatus.completed.name],
    ));

    // Sessions réussies
    final passedSessions = Sqflite.firstIntValue(await db.rawQuery(
      'SELECT COUNT(*) FROM exam_sessions WHERE user_id = ? AND passed = 1',
      [userId],
    ));

    // Score moyen
    final avgScoreResult = await db.rawQuery(
      'SELECT AVG(score) as avg_score FROM exam_sessions WHERE user_id = ? AND score IS NOT NULL',
      [userId],
    );
    final avgScore = avgScoreResult.first['avg_score'] as double? ?? 0.0;

    // Meilleur score
    final bestScoreResult = await db.rawQuery(
      'SELECT MAX(score) as best_score FROM exam_sessions WHERE user_id = ?',
      [userId],
    );
    final bestScore = bestScoreResult.first['best_score'] as int? ?? 0;

    // Durée moyenne
    final avgDurationResult = await db.rawQuery(
      'SELECT AVG(duration_seconds) as avg_duration FROM exam_sessions WHERE user_id = ? AND status = ?',
      [userId, ExamSessionStatus.completed.name],
    );
    final avgDuration =
        avgDurationResult.first['avg_duration'] as double? ?? 0.0;

    return {
      'total_sessions': totalSessions ?? 0,
      'passed_sessions': passedSessions ?? 0,
      'avg_score': avgScore,
      'best_score': bestScore,
      'avg_duration_seconds': avgDuration.toInt(),
      'success_rate': totalSessions != null && totalSessions > 0
          ? (passedSessions ?? 0) / totalSessions
          : 0.0,
    };
  }

  /// Supprime une session et toutes ses réponses
  Future<int> deleteSession(int sessionId) async {
    final db = await _dbHelper.database;
    return await db.delete(
      'exam_sessions',
      where: 'id = ?',
      whereArgs: [sessionId],
    );
  }

  /// Récupère les détails d'une réponse avec la question complète
  Future<Map<String, dynamic>?> getAnswerWithQuestion(int answerId) async {
    final db = await _dbHelper.database;

    final result = await db.rawQuery('''
      SELECT
        ea.*,
        q.question_text,
        q.explanation,
        q.type,
        q.difficulty
      FROM exam_answers ea
      INNER JOIN questions q ON ea.question_id = q.id
      WHERE ea.id = ?
    ''', [answerId]);

    if (result.isEmpty) return null;
    return result.first;
  }

  /// Récupère toutes les réponses d'une session avec les questions complètes
  Future<List<Map<String, dynamic>>> getSessionAnswersWithQuestions(
      int sessionId) async {
    final db = await _dbHelper.database;

    return await db.rawQuery('''
      SELECT
        ea.*,
        q.question_text,
        q.explanation,
        q.type,
        q.difficulty,
        q.theme_id
      FROM exam_answers ea
      INNER JOIN questions q ON ea.question_id = q.id
      WHERE ea.exam_session_id = ?
      ORDER BY ea.answered_at ASC
    ''', [sessionId]);
  }
}

/// Extension pour ajouter copyWith à ExamSessionModel
extension ExamSessionModelExtension on ExamSessionModel {
  ExamSessionModel copyWith({
    int? id,
    int? userId,
    DateTime? startedAt,
    DateTime? completedAt,
    ExamSessionStatus? status,
    int? score,
    bool? passed,
    int? durationSeconds,
    List<ExamAnswerModel>? answers,
  }) {
    return ExamSessionModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      status: status ?? this.status,
      score: score ?? this.score,
      passed: passed ?? this.passed,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      answers: answers ?? this.answers,
    );
  }
}
