import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';

final class PasswordDigest {
  const PasswordDigest({required this.hash, required this.salt});

  final String hash;
  final String salt;
}

/// PBKDF2-HMAC-SHA-256 implementation for the offline account vault.
final class PasswordHasher {
  const PasswordHasher({this.iterations = 210000, this.keyLength = 32});

  final int iterations;
  final int keyLength;

  PasswordDigest hash(String password) {
    final saltBytes = Uint8List.fromList(
      List<int>.generate(16, (_) => Random.secure().nextInt(256)),
    );
    final derived = _derive(utf8.encode(password), saltBytes);
    return PasswordDigest(
      hash: base64UrlEncode(derived),
      salt: base64UrlEncode(saltBytes),
    );
  }

  bool verify(String password, String encodedSalt, String expectedHash) {
    try {
      final actual = _derive(
        utf8.encode(password),
        base64Url.decode(encodedSalt),
      );
      final expected = base64Url.decode(expectedHash);
      if (actual.length != expected.length) return false;
      var difference = 0;
      for (var index = 0; index < actual.length; index++) {
        difference |= actual[index] ^ expected[index];
      }
      return difference == 0;
    } on FormatException {
      return false;
    }
  }

  Uint8List _derive(List<int> password, List<int> salt) {
    final hmac = Hmac(sha256, password);
    final blockCount = (keyLength / 32).ceil();
    final output = BytesBuilder(copy: false);
    for (var block = 1; block <= blockCount; block++) {
      final blockSalt = <int>[
        ...salt,
        (block >> 24) & 0xff,
        (block >> 16) & 0xff,
        (block >> 8) & 0xff,
        block & 0xff,
      ];
      var u = hmac.convert(blockSalt).bytes;
      final result = Uint8List.fromList(u);
      for (var round = 1; round < iterations; round++) {
        u = hmac.convert(u).bytes;
        for (var index = 0; index < result.length; index++) {
          result[index] ^= u[index];
        }
      }
      output.add(result);
    }
    return Uint8List.fromList(output.takeBytes().take(keyLength).toList());
  }
}
