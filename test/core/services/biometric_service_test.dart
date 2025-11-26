import 'package:flutter_test/flutter_test.dart';
import 'package:naturaliqcm/core/services/biometric_service.dart';

void main() {
  group('BiometricService', () {
    late BiometricService service;

    setUp(() {
      service = BiometricService();
    });

    test('BiometricAuthResult.success creates success result', () {
      final result = BiometricAuthResult.success();

      expect(result.isSuccess, isTrue);
      expect(result.errorMessage, isNull);
    });

    test('BiometricAuthResult.failure creates failure result', () {
      const errorMsg = 'Authentication failed';
      final result = BiometricAuthResult.failure(errorMsg);

      expect(result.isSuccess, isFalse);
      expect(result.errorMessage, equals(errorMsg));
    });

    test(
      'getBiometricTypeDescription returns description for available types',
      () async {
        // Note: This test will vary based on the device/platform
        final description = await service.getBiometricTypeDescription();

        expect(description, isNotEmpty);
        expect(description, isA<String>());
      },
    );
  });
}
