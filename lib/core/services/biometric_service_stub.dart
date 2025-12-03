/// Stub implementation - should never be used
/// Real implementations are in biometric_service_mobile.dart and biometric_service_web.dart
class BiometricService {
  Future<bool> isBiometricAvailable() async {
    throw UnsupportedError('Platform not supported');
  }

  Future<List<dynamic>> getAvailableBiometrics() async {
    throw UnsupportedError('Platform not supported');
  }

  Future<BiometricAuthResult> authenticate({
    required String reason,
    bool useErrorDialogs = true,
    bool stickyAuth = true,
    bool biometricOnly = true,
  }) async {
    throw UnsupportedError('Platform not supported');
  }

  Future<String> getBiometricTypeDescription() async {
    throw UnsupportedError('Platform not supported');
  }
}

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
