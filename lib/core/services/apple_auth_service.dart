import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

/// Service pour gérer l'authentification avec Sign in with Apple
class AppleAuthService {
  /// Vérifie si Sign in with Apple est disponible (iOS 13+, macOS 10.15+)
  Future<bool> isAvailable() async {
    try {
      return await SignInWithApple.isAvailable();
    } catch (e) {
      debugPrint('Error checking Apple Sign In availability: $e');
      return false;
    }
  }

  /// Génère un nonce aléatoire pour sécuriser la requête
  String _generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(
      length,
      (_) => charset[random.nextInt(charset.length)],
    ).join();
  }

  /// Hash SHA256 du nonce pour l'envoyer à Apple
  String _sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Authentifie l'utilisateur avec Sign in with Apple
  Future<AppleAuthResult> signIn() async {
    try {
      // Générer un nonce pour la sécurité
      final rawNonce = _generateNonce();
      final nonce = _sha256ofString(rawNonce);

      // Demander l'autorisation
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: nonce,
      );

      // Extraire les informations
      final userIdentifier = credential.userIdentifier;
      final email = credential.email;
      final givenName = credential.givenName;
      final familyName = credential.familyName;

      // Construire le nom complet si disponible
      String? fullName;
      if (givenName != null || familyName != null) {
        fullName = '${givenName ?? ''} ${familyName ?? ''}'.trim();
      }

      return AppleAuthResult.success(
        userId: userIdentifier,
        email: email,
        name: fullName,
        rawNonce: rawNonce,
      );
    } on SignInWithAppleAuthorizationException catch (e) {
      return _handleAuthorizationException(e);
    } catch (e) {
      return AppleAuthResult.failure('Erreur inconnue: $e');
    }
  }

  AppleAuthResult _handleAuthorizationException(
    SignInWithAppleAuthorizationException e,
  ) {
    switch (e.code) {
      case AuthorizationErrorCode.canceled:
        return AppleAuthResult.failure('Connexion annulée par l\'utilisateur');
      case AuthorizationErrorCode.failed:
        return AppleAuthResult.failure(
          'Erreur d\'authentification: ${e.message}',
        );
      case AuthorizationErrorCode.invalidResponse:
        return AppleAuthResult.failure('Réponse invalide d\'Apple');
      case AuthorizationErrorCode.notHandled:
        return AppleAuthResult.failure('Requête non traitée');
      case AuthorizationErrorCode.unknown:
        return AppleAuthResult.failure('Erreur inconnue: ${e.message}');
      default:
        return AppleAuthResult.failure('Erreur: ${e.code} - ${e.message}');
    }
  }

  /// Déconnecte l'utilisateur (note: Sign in with Apple n'a pas de vraie déconnexion côté client)
  /// Cette méthode est là pour la symétrie de l'API
  Future<void> signOut() async {
    // Apple ne fournit pas de méthode de déconnexion
    // La déconnexion se fait en supprimant les tokens côté app
    debugPrint('Apple Sign In: Sign out (local only)');
  }
}

/// Résultat d'une tentative d'authentification Apple
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
