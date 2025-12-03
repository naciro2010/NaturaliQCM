/// Exports the appropriate BiometricService implementation based on platform
///
/// - Mobile (Android/iOS): Uses local_auth for native biometric authentication
/// - Web: Returns stubs (biometric auth not available on web)
export 'biometric_service_stub.dart'
    if (dart.library.io) 'biometric_service_mobile.dart'
    if (dart.library.html) 'biometric_service_web.dart';
