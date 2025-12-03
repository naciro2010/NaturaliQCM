/// Exports the appropriate AppleAuthService implementation based on platform
export 'apple_auth_service_stub.dart'
    if (dart.library.io) 'apple_auth_service_mobile.dart'
    if (dart.library.html) 'apple_auth_service_web.dart';
