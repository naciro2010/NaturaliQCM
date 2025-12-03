import 'package:flutter/foundation.dart';

/// Service pour gérer les Passkeys sur Web
/// Les Passkeys ne sont pas disponibles dans cette version web
class PasskeyService {
  Future<bool> arePasskeysAvailable() async {
    debugPrint('Passkeys not available on web');
    return false;
  }

  Future<PasskeyResult> registerPasskey({
    required String userId,
    required String userName,
  }) async {
    return PasskeyResult.failure(
      'Les Passkeys ne sont pas disponibles sur le web',
    );
  }

  Future<PasskeyResult> authenticateWithPasskey({
    required String userName,
  }) async {
    return PasskeyResult.failure(
      'Les Passkeys ne sont pas disponibles sur le web',
    );
  }

  Future<bool> deletePasskey(String passkeyId) async {
    debugPrint('Passkeys not available on web');
    return false;
  }

  Future<PasskeyInfo> getPasskeyInfo() async {
    return PasskeyInfo(
      isAvailable: false,
      description: 'Non disponible sur web',
      availableBiometrics: [],
    );
  }
}

class PasskeyResult {
  final bool isSuccess;
  final String? passkeyId;
  final String? message;
  final String? errorMessage;

  PasskeyResult._({
    required this.isSuccess,
    this.passkeyId,
    this.message,
    this.errorMessage,
  });

  factory PasskeyResult.success({String? passkeyId, String? message}) {
    return PasskeyResult._(
      isSuccess: true,
      passkeyId: passkeyId,
      message: message,
    );
  }

  factory PasskeyResult.failure(String message) {
    return PasskeyResult._(isSuccess: false, errorMessage: message);
  }
}

class PasskeyInfo {
  final bool isAvailable;
  final String description;
  final List<dynamic> availableBiometrics;

  PasskeyInfo({
    required this.isAvailable,
    required this.description,
    required this.availableBiometrics,
  });
}
