import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

/// Helper pour gérer la base de données SQLite locale
/// Schéma conforme aux exigences du Lot 1
class DatabaseHelper {
  static const String _databaseName = 'naturaliqcm.db';
  static const int _databaseVersion = 1;

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final Directory documentsDirectory =
        await getApplicationDocumentsDirectory();
    final String path = join(documentsDirectory.path, _databaseName);

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  /// Création du schéma de base de données v1
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE user_profiles (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        french_level TEXT NOT NULL,
        created_at TEXT NOT NULL,
        last_activity_at TEXT,
        biometric_enabled INTEGER NOT NULL DEFAULT 0,
        apple_user_id TEXT,
        passkey_id TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE themes (
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        code TEXT NOT NULL UNIQUE,
        exam_question_count INTEGER NOT NULL,
        practical_scenario_count INTEGER NOT NULL,
        description TEXT NOT NULL,
        icon_path TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE subthemes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        theme_id INTEGER NOT NULL,
        name TEXT NOT NULL,
        code TEXT NOT NULL UNIQUE,
        description TEXT,
        FOREIGN KEY (theme_id) REFERENCES themes (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE questions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        theme_id INTEGER NOT NULL,
        subtheme_id INTEGER,
        type TEXT NOT NULL,
        difficulty TEXT NOT NULL,
        question_text TEXT NOT NULL,
        explanation TEXT,
        lesson_reference TEXT,
        is_public INTEGER NOT NULL DEFAULT 1,
        FOREIGN KEY (theme_id) REFERENCES themes (id) ON DELETE CASCADE,
        FOREIGN KEY (subtheme_id) REFERENCES subthemes (id) ON DELETE SET NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE choices (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        question_id INTEGER NOT NULL,
        choice_text TEXT NOT NULL,
        is_correct INTEGER NOT NULL DEFAULT 0,
        display_order INTEGER NOT NULL,
        FOREIGN KEY (question_id) REFERENCES questions (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE exam_sessions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        started_at TEXT NOT NULL,
        completed_at TEXT,
        status TEXT NOT NULL,
        score INTEGER,
        passed INTEGER,
        duration_seconds INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (user_id) REFERENCES user_profiles (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE exam_answers (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        exam_session_id INTEGER NOT NULL,
        question_id INTEGER NOT NULL,
        theme_id INTEGER NOT NULL,
        selected_choice_id INTEGER NOT NULL,
        is_correct INTEGER NOT NULL,
        answered_at TEXT NOT NULL,
        FOREIGN KEY (exam_session_id) REFERENCES exam_sessions (id) ON DELETE CASCADE,
        FOREIGN KEY (question_id) REFERENCES questions (id) ON DELETE CASCADE,
        FOREIGN KEY (theme_id) REFERENCES themes (id),
        FOREIGN KEY (selected_choice_id) REFERENCES choices (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE lessons (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        theme_id INTEGER NOT NULL,
        subtheme_id INTEGER,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        duration_minutes INTEGER NOT NULL,
        display_order INTEGER NOT NULL,
        FOREIGN KEY (theme_id) REFERENCES themes (id) ON DELETE CASCADE,
        FOREIGN KEY (subtheme_id) REFERENCES subthemes (id) ON DELETE SET NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE user_progress (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        question_id INTEGER NOT NULL,
        last_seen_at TEXT NOT NULL,
        times_seen INTEGER NOT NULL DEFAULT 1,
        times_correct INTEGER NOT NULL DEFAULT 0,
        spaced_repetition_box INTEGER NOT NULL DEFAULT 1,
        next_review_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES user_profiles (id) ON DELETE CASCADE,
        FOREIGN KEY (question_id) REFERENCES questions (id) ON DELETE CASCADE,
        UNIQUE(user_id, question_id)
      )
    ''');

    // Indexes pour performance
    await db.execute(
        'CREATE INDEX idx_questions_theme ON questions(theme_id, type)');
    await db.execute(
        'CREATE INDEX idx_exam_sessions_user ON exam_sessions(user_id, started_at DESC)');
    await db.execute(
        'CREATE INDEX idx_exam_answers_session ON exam_answers(exam_session_id)');
    await db.execute(
        'CREATE INDEX idx_user_progress_user_next_review ON user_progress(user_id, next_review_at)');
    await db.execute('CREATE INDEX idx_choices_question ON choices(question_id)');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Migrations futures
  }

  /// Wipe complet de la base (pour paramètre vie privée)
  Future<void> wipeDatabase() async {
    final Directory documentsDirectory =
        await getApplicationDocumentsDirectory();
    final String path = join(documentsDirectory.path, _databaseName);

    if (_database != null) {
      await _database!.close();
      _database = null;
    }

    await deleteDatabase(path);
  }

  /// Fermeture de la connexion
  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }
}
