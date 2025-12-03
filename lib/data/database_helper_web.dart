import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:sqflite_common/sqlite_api.dart';

/// Helper pour gérer la base de données SQLite sur Web
/// Utilise sqflite_common_ffi_web pour IndexedDB
class DatabaseHelper {
  static const String _databaseName = 'naturaliqcm.db';
  static const int _databaseVersion = 1;

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;
  static bool _initialized = false;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    // Initialiser le factory pour web si pas encore fait
    if (!_initialized) {
      databaseFactory = databaseFactoryFfiWeb;
      _initialized = true;
    }

    return await databaseFactory.openDatabase(
      _databaseName,
      options: OpenDatabaseOptions(
        version: _databaseVersion,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
      ),
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
      CREATE TABLE lessons (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        theme_id INTEGER NOT NULL,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        order_index INTEGER NOT NULL,
        FOREIGN KEY (theme_id) REFERENCES themes (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE user_progress (
        user_id INTEGER NOT NULL,
        question_id INTEGER NOT NULL,
        times_seen INTEGER NOT NULL DEFAULT 0,
        times_correct INTEGER NOT NULL DEFAULT 0,
        last_seen_at TEXT,
        confidence_level INTEGER NOT NULL DEFAULT 1,
        next_review_at TEXT,
        PRIMARY KEY (user_id, question_id),
        FOREIGN KEY (user_id) REFERENCES user_profiles (id) ON DELETE CASCADE,
        FOREIGN KEY (question_id) REFERENCES questions (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE exam_sessions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        started_at TEXT NOT NULL,
        completed_at TEXT,
        duration_seconds INTEGER,
        score INTEGER,
        passed INTEGER,
        questions_data TEXT NOT NULL,
        answers_data TEXT,
        FOREIGN KEY (user_id) REFERENCES user_profiles (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE lesson_progress (
        user_id INTEGER NOT NULL,
        lesson_id INTEGER NOT NULL,
        completed INTEGER NOT NULL DEFAULT 0,
        completed_at TEXT,
        PRIMARY KEY (user_id, lesson_id),
        FOREIGN KEY (user_id) REFERENCES user_profiles (id) ON DELETE CASCADE,
        FOREIGN KEY (lesson_id) REFERENCES lessons (id) ON DELETE CASCADE
      )
    ''');

    // Insérer les thèmes par défaut
    await _insertDefaultThemes(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Gestion des migrations futures
  }

  Future<void> _insertDefaultThemes(Database db) async {
    final themes = [
      {
        'id': 1,
        'name': 'Principes et valeurs de la République',
        'code': 'principes_valeurs',
        'exam_question_count': 11,
        'practical_scenario_count': 6,
        'description':
            'Les principes fondamentaux et valeurs de la République française',
        'icon_path': 'assets/icons/theme_1.png'
      },
      {
        'id': 2,
        'name': 'Institutions de la République',
        'code': 'institutions',
        'exam_question_count': 6,
        'practical_scenario_count': 0,
        'description':
            'Le système institutionnel et politique de la France',
        'icon_path': 'assets/icons/theme_2.png'
      },
      {
        'id': 3,
        'name': 'Droits et devoirs du citoyen',
        'code': 'droits_devoirs',
        'exam_question_count': 11,
        'practical_scenario_count': 6,
        'description': 'Les droits fondamentaux et devoirs civiques',
        'icon_path': 'assets/icons/theme_3.png'
      },
      {
        'id': 4,
        'name': 'Histoire et culture françaises',
        'code': 'histoire_culture',
        'exam_question_count': 8,
        'practical_scenario_count': 0,
        'description':
            'L\'histoire de France et ses éléments culturels majeurs',
        'icon_path': 'assets/icons/theme_4.png'
      },
      {
        'id': 5,
        'name': 'Vivre en France',
        'code': 'vivre_france',
        'exam_question_count': 4,
        'practical_scenario_count': 0,
        'description': 'La vie quotidienne et les services publics en France',
        'icon_path': 'assets/icons/theme_5.png'
      },
    ];

    for (final theme in themes) {
      await db.insert('themes', theme);
    }
  }

  /// Vérifier si un profil utilisateur existe
  Future<bool> hasUserProfile() async {
    final db = await database;
    final result = await db.query('user_profiles', limit: 1);
    return result.isNotEmpty;
  }

  /// Obtenir le premier profil utilisateur
  Future<Map<String, dynamic>?> getUserProfile() async {
    final db = await database;
    final result = await db.query('user_profiles', limit: 1);
    return result.isNotEmpty ? result.first : null;
  }

  /// Fermer la base de données
  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
