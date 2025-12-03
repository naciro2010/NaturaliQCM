/// Exports the appropriate PasskeyService implementation based on platform
export 'passkey_service_stub.dart'
    if (dart.library.io) 'passkey_service_mobile.dart'
    if (dart.library.html) 'passkey_service_web.dart';
