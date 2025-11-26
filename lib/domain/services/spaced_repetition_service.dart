import '../../data/database_helper.dart';
import '../../data/models/user_progress_model.dart';

/// Service pour gérer l'algorithme de répétition espacée (système Leitner)
class SpacedRepetitionService {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  /// Intervalles de révision par box (en jours)
  /// Box 1: 1 jour, Box 2: 3 jours, Box 3: 7 jours, Box 4: 14 jours, Box 5: 30 jours
  static const Map<int, int> _boxIntervals = {1: 1, 2: 3, 3: 7, 4: 14, 5: 30};

  /// Enregistre la réponse à une question
  Future<void> recordAnswer({
    required int userId,
    required int questionId,
    required bool isCorrect,
  }) async {
    final db = await _dbHelper.database;

    // Récupère ou crée la progression
    final existing = await _getProgress(userId, questionId);

    if (existing == null) {
      // Première fois que l'utilisateur voit cette question
      final progress = UserProgressModel(
        userId: userId,
        questionId: questionId,
        lastSeenAt: DateTime.now(),
        timesSeen: 1,
        timesCorrect: isCorrect ? 1 : 0,
        spacedRepetitionBox: isCorrect ? 2 : 1,
        nextReviewAt: _calculateNextReview(isCorrect ? 2 : 1),
      );

      await db.insert('user_progress', progress.toMap());
    } else {
      // Mise à jour de la progression existante
      final newBox = _calculateNewBox(existing.spacedRepetitionBox, isCorrect);
      final updatedProgress = existing.copyWith(
        lastSeenAt: DateTime.now(),
        timesSeen: existing.timesSeen + 1,
        timesCorrect: existing.timesCorrect + (isCorrect ? 1 : 0),
        spacedRepetitionBox: newBox,
        nextReviewAt: _calculateNextReview(newBox),
      );

      await db.update(
        'user_progress',
        updatedProgress.toMap(),
        where: 'id = ?',
        whereArgs: [existing.id],
      );
    }
  }

  /// Calcule la nouvelle box selon la réponse
  int _calculateNewBox(int currentBox, bool isCorrect) {
    if (isCorrect) {
      // Réponse correcte : monte d'une box (max 5)
      return currentBox < 5 ? currentBox + 1 : 5;
    } else {
      // Réponse incorrecte : retour à la box 1
      return 1;
    }
  }

  /// Calcule la date de prochaine révision
  DateTime _calculateNextReview(int box) {
    final intervalDays = _boxIntervals[box] ?? 1;
    return DateTime.now().add(Duration(days: intervalDays));
  }

  /// Récupère les questions à réviser pour un utilisateur
  Future<List<int>> getQuestionsToReview(int userId, {int? themeId}) async {
    final db = await _dbHelper.database;

    String query = '''
      SELECT up.question_id
      FROM user_progress up
      JOIN questions q ON up.question_id = q.id
      WHERE up.user_id = ? AND up.next_review_at <= datetime('now')
    ''';

    List<dynamic> args = [userId];

    if (themeId != null) {
      query += ' AND q.theme_id = ?';
      args.add(themeId);
    }

    query += ' ORDER BY up.next_review_at ASC LIMIT 20';

    final results = await db.rawQuery(query, args);
    return results.map((row) => row['question_id'] as int).toList();
  }

  /// Récupère les questions recommandées pour un utilisateur
  /// Combine les questions à réviser et de nouvelles questions
  Future<List<int>> getRecommendedQuestions(
    int userId, {
    int? themeId,
    int maxQuestions = 20,
  }) async {
    final db = await _dbHelper.database;

    // 1. Questions à réviser (prioritaires)
    final toReview = await getQuestionsToReview(userId, themeId: themeId);

    if (toReview.length >= maxQuestions) {
      return toReview.sublist(0, maxQuestions);
    }

    // 2. Questions jamais vues (nouvelles questions)
    String newQuestionsQuery = '''
      SELECT q.id
      FROM questions q
      LEFT JOIN user_progress up ON q.id = up.question_id AND up.user_id = ?
      WHERE up.id IS NULL
    ''';

    List<dynamic> args = [userId];

    if (themeId != null) {
      newQuestionsQuery += ' AND q.theme_id = ?';
      args.add(themeId);
    }

    newQuestionsQuery += ' ORDER BY RANDOM() LIMIT ?';
    args.add(maxQuestions - toReview.length);

    final newQuestions = await db.rawQuery(newQuestionsQuery, args);
    final newIds = newQuestions.map((row) => row['id'] as int).toList();

    return [...toReview, ...newIds];
  }

  /// Récupère les statistiques de progression pour un utilisateur
  Future<Map<String, dynamic>> getProgressStatistics(int userId) async {
    final db = await _dbHelper.database;

    final stats = await db.rawQuery(
      '''
      SELECT
        COUNT(*) as total_questions_seen,
        SUM(times_correct) as total_correct,
        SUM(times_seen) as total_attempts,
        AVG(spaced_repetition_box) as avg_box,
        COUNT(CASE WHEN next_review_at <= datetime('now') THEN 1 END) as due_for_review
      FROM user_progress
      WHERE user_id = ?
    ''',
      [userId],
    );

    if (stats.isEmpty) {
      return {
        'total_questions_seen': 0,
        'total_correct': 0,
        'total_attempts': 0,
        'avg_box': 0.0,
        'due_for_review': 0,
        'success_rate': 0.0,
      };
    }

    final row = stats.first;
    final totalAttempts = row['total_attempts'] as int? ?? 0;
    final totalCorrect = row['total_correct'] as int? ?? 0;

    return {
      'total_questions_seen': row['total_questions_seen'] ?? 0,
      'total_correct': totalCorrect,
      'total_attempts': totalAttempts,
      'avg_box': row['avg_box'] ?? 0.0,
      'due_for_review': row['due_for_review'] ?? 0,
      'success_rate': totalAttempts > 0 ? totalCorrect / totalAttempts : 0.0,
    };
  }

  /// Récupère les statistiques par thème
  Future<Map<int, Map<String, dynamic>>> getProgressByTheme(int userId) async {
    final db = await _dbHelper.database;

    final results = await db.rawQuery(
      '''
      SELECT
        q.theme_id,
        COUNT(*) as questions_seen,
        SUM(up.times_correct) as total_correct,
        SUM(up.times_seen) as total_attempts,
        AVG(up.spaced_repetition_box) as avg_box
      FROM user_progress up
      JOIN questions q ON up.question_id = q.id
      WHERE up.user_id = ?
      GROUP BY q.theme_id
    ''',
      [userId],
    );

    final Map<int, Map<String, dynamic>> statsByTheme = {};

    for (var row in results) {
      final themeId = row['theme_id'] as int;
      final totalAttempts = row['total_attempts'] as int? ?? 0;
      final totalCorrect = row['total_correct'] as int? ?? 0;

      statsByTheme[themeId] = {
        'questions_seen': row['questions_seen'] ?? 0,
        'total_correct': totalCorrect,
        'total_attempts': totalAttempts,
        'avg_box': row['avg_box'] ?? 0.0,
        'success_rate': totalAttempts > 0 ? totalCorrect / totalAttempts : 0.0,
      };
    }

    return statsByTheme;
  }

  /// Récupère la progression pour une question spécifique
  Future<UserProgressModel?> _getProgress(int userId, int questionId) async {
    final db = await _dbHelper.database;

    final results = await db.query(
      'user_progress',
      where: 'user_id = ? AND question_id = ?',
      whereArgs: [userId, questionId],
      limit: 1,
    );

    if (results.isEmpty) return null;
    return UserProgressModel.fromMap(results.first);
  }

  /// Récupère les recommandations quotidiennes
  Future<Map<String, dynamic>> getDailyRecommendations(int userId) async {
    final questionsToReview = await getQuestionsToReview(userId);
    final stats = await getProgressStatistics(userId);

    return {
      'questions_to_review': questionsToReview.length,
      'due_today': questionsToReview.length,
      'total_mastered': stats['total_questions_seen'],
      'success_rate': stats['success_rate'],
      'recommended_session_size': questionsToReview.length > 0
          ? (questionsToReview.length < 10 ? 10 : 20)
          : 10,
    };
  }
}
