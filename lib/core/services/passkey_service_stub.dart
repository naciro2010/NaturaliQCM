/// Stub implementation
class PasskeyService {
  Future<bool> arePasskeysAvailable() async {
    throw UnsupportedError('Platform not supported');
  }

  Future<PasskeyResult> registerPasskey({
    required String userId,
    required String userName,
  }) async {
    throw UnsupportedError('Platform not supported');
  }

  Future<PasskeyResult> authenticateWithPasskey({
    required String userName,
  }) async {
    throw UnsupportedError('Platform not supported');
  }

  Future<bool> deletePasskey(String passkeyId) async {
    throw UnsupportedError('Platform not supported');
  }

  Future<PasskeyInfo> getPasskeyInfo() async {
    throw UnsupportedError('Platform not supported');
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
