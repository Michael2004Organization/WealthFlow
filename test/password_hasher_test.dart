import 'package:flutter_test/flutter_test.dart';
import 'package:wealthflow/core/security/password_hasher.dart';

void main() {
  group('PasswordHasher', () {
    const hasher = PasswordHasher(iterations: 1000);

    test('verifies the original password', () {
      final digest = hasher.hash('sicheres-passwort-42');

      expect(
        hasher.verify('sicheres-passwort-42', digest.salt, digest.hash),
        isTrue,
      );
    });

    test('rejects a different password', () {
      final digest = hasher.hash('sicheres-passwort-42');

      expect(
        hasher.verify('anderes-passwort', digest.salt, digest.hash),
        isFalse,
      );
    });

    test('uses a unique random salt', () {
      final first = hasher.hash('identisches-passwort');
      final second = hasher.hash('identisches-passwort');

      expect(first.salt, isNot(second.salt));
      expect(first.hash, isNot(second.hash));
    });
  });
}
