import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth/error_codes.dart' as auth_error;

/// Service pour gérer l'authentification biométrique
class BiometricService {
  final LocalAuthentication _localAuth = LocalAuthentication();

  /// Vérifie si la biométrie est disponible sur l'appareil
  Future<bool> isBiometricAvailable() async {
    try {
      final canCheckBiometrics = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      return canCheckBiometrics && isDeviceSupported;
    } catch (e) {
      return false;
    }
  }

  /// Récupère la liste des biométries disponibles
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (e) {
      return [];
    }
  }

  /// Authentifie l'utilisateur avec la biométrie
  Future<BiometricAuthResult> authenticate({
    required String reason,
    bool useErrorDialogs = true,
    bool stickyAuth = true,
    bool biometricOnly = true,
  }) async {
    try {
      final authenticated = await _localAuth.authenticate(
        localizedReason: reason,
        options: AuthenticationOptions(
          useErrorDialogs: useErrorDialogs,
          stickyAuth: stickyAuth,
          biometricOnly: biometricOnly,
        ),
      );

      if (authenticated) {
        return BiometricAuthResult.success();
      } else {
        return BiometricAuthResult.failure('Authentification annulée');
      }
    } on PlatformException catch (e) {
      return _handlePlatformException(e);
    } catch (e) {
      return BiometricAuthResult.failure('Erreur inconnue: $e');
    }
  }

  BiometricAuthResult _handlePlatformException(PlatformException e) {
    switch (e.code) {
      case auth_error.notAvailable:
        return BiometricAuthResult.failure(
          'Biométrie non disponible sur cet appareil',
        );
      case auth_error.notEnrolled:
        return BiometricAuthResult.failure(
          'Aucune biométrie enregistrée. Veuillez configurer la biométrie dans les paramètres de votre appareil.',
        );
      case auth_error.lockedOut:
        return BiometricAuthResult.failure(
          'Trop de tentatives échouées. Veuillez réessayer plus tard.',
        );
      case auth_error.permanentlyLockedOut:
        return BiometricAuthResult.failure(
          'Biométrie définitivement bloquée. Utilisez le code de déverrouillage de votre appareil.',
        );
      case auth_error.passcodeNotSet:
        return BiometricAuthResult.failure(
          'Aucun code de déverrouillage défini. Veuillez configurer un code dans les paramètres.',
        );
      default:
        return BiometricAuthResult.failure(
          'Erreur d\'authentification: ${e.message ?? e.code}',
        );
    }
  }

  /// Obtient une description textuelle du type de biométrie disponible
  Future<String> getBiometricTypeDescription() async {
    final biometrics = await getAvailableBiometrics();

    if (biometrics.contains(BiometricType.face)) {
      return 'Face ID';
    } else if (biometrics.contains(BiometricType.fingerprint)) {
      return 'Empreinte digitale';
    } else if (biometrics.contains(BiometricType.iris)) {
      return 'Iris';
    } else if (biometrics.contains(BiometricType.strong)) {
      return 'Authentification forte';
    } else if (biometrics.contains(BiometricType.weak)) {
      return 'Authentification biométrique';
    }
    return 'Biométrie';
  }
}

/// Résultat d'une tentative d'authentification biométrique
class BiometricAuthResult {
  final bool isSuccess;
  final String? errorMessage;

  BiometricAuthResult._({required this.isSuccess, this.errorMessage});

  factory BiometricAuthResult.success() {
    return BiometricAuthResult._(isSuccess: true);
  }

  factory BiometricAuthResult.failure(String message) {
    return BiometricAuthResult._(isSuccess: false, errorMessage: message);
  }
}
