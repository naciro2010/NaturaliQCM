import 'package:flutter/foundation.dart';

/// Service pour gérer l'authentification avec Sign in with Apple sur Web
/// Sign in with Apple n'est pas disponible sur web dans cette implémentation
class AppleAuthService {
  Future<bool> isAvailable() async {
    debugPrint('Apple Sign In not available on web');
    return false;
  }

  Future<AppleAuthResult> signIn() async {
    return AppleAuthResult.failure(
      'Sign in with Apple n\'est pas disponible sur le web',
    );
  }

  Future<void> signOut() async {
    debugPrint('Apple Sign In: Sign out (not available on web)');
  }
}

class AppleAuthResult {
  final bool isSuccess;
  final String? userId;
  final String? email;
  final String? name;
  final String? rawNonce;
  final String? errorMessage;

  AppleAuthResult._({
    required this.isSuccess,
    this.userId,
    this.email,
    this.name,
    this.rawNonce,
    this.errorMessage,
  });

  factory AppleAuthResult.success({
    required String userId,
    String? email,
    String? name,
    String? rawNonce,
  }) {
    return AppleAuthResult._(
      isSuccess: true,
      userId: userId,
      email: email,
      name: name,
      rawNonce: rawNonce,
    );
  }

  factory AppleAuthResult.failure(String message) {
    return AppleAuthResult._(isSuccess: false, errorMessage: message);
  }
}
