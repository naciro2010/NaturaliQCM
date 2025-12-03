/// Stub implementation
class AppleAuthService {
  Future<bool> isAvailable() async {
    throw UnsupportedError('Platform not supported');
  }

  Future<AppleAuthResult> signIn() async {
    throw UnsupportedError('Platform not supported');
  }

  Future<void> signOut() async {
    throw UnsupportedError('Platform not supported');
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
