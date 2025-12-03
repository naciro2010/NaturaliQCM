/// Service pour gérer l'authentification biométrique sur Web
/// La biométrie n'est pas disponible sur Web, ce service retourne toujours false
class BiometricService {
  /// Vérifie si la biométrie est disponible sur l'appareil
  /// Toujours false sur Web
  Future<bool> isBiometricAvailable() async {
    return false;
  }

  /// Récupère la liste des biométries disponibles
  /// Toujours vide sur Web
  Future<List<String>> getAvailableBiometrics() async {
    return [];
  }

  /// Authentifie l'utilisateur avec la biométrie
  /// Toujours échec sur Web
  Future<BiometricAuthResult> authenticate({
    required String reason,
    bool useErrorDialogs = true,
    bool stickyAuth = true,
    bool biometricOnly = true,
  }) async {
    return BiometricAuthResult.failure(
      'L\'authentification biométrique n\'est pas disponible sur le web',
    );
  }

  /// Obtient une description textuelle du type de biométrie disponible
  Future<String> getBiometricTypeDescription() async {
    return 'Non disponible';
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
