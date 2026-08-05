import 'package:flutter_test/flutter_test.dart';
import 'package:wealthflow/core/security/data_cipher.dart';
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

  group('DataCipher', () {
    test('round-trips without exposing plaintext', () async {
      const plaintext = 'sensible Kontodaten';
      final key = List<int>.generate(32, (index) => index);
      final encrypted = await DataCipher.encrypt(plaintext, key);

      expect(encrypted, contains('AES-256-GCM'));
      expect(encrypted, isNot(contains('Kontodaten')));
      expect(await DataCipher.decrypt(encrypted, key), plaintext);
    });

    test('keeps legacy plaintext exports importable', () async {
      const plaintext = 'null';
      expect(
        await DataCipher.decrypt(plaintext, List<int>.filled(32, 7)),
        plaintext,
      );
    });

    test('rejects a different encryption key', () async {
      final encrypted = await DataCipher.encrypt(
        'secret',
        List<int>.filled(32, 1),
      );
      await expectLater(
        DataCipher.decrypt(encrypted, List<int>.filled(32, 2)),
        throwsA(anything),
      );
    });
  });
}
