/// Exports the appropriate DatabaseHelper implementation based on platform
///
/// - Mobile (Android/iOS): Uses sqflite with native file system
/// - Web: Uses sqflite_common_ffi_web with IndexedDB
export 'database_helper_stub.dart'
    if (dart.library.io) 'database_helper_mobile.dart'
    if (dart.library.html) 'database_helper_web.dart';
