/// Stub implementation - should never be used
/// Real implementations are in database_helper_mobile.dart and database_helper_web.dart
class DatabaseHelper {
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  Future<dynamic> get database async {
    throw UnsupportedError('Platform not supported');
  }

  Future<bool> hasUserProfile() async {
    throw UnsupportedError('Platform not supported');
  }

  Future<Map<String, dynamic>?> getUserProfile() async {
    throw UnsupportedError('Platform not supported');
  }

  Future<void> close() async {
    throw UnsupportedError('Platform not supported');
  }
}
