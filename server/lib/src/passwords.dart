import 'dart:convert';
import 'dart:math';

import 'package:cryptography/cryptography.dart';

/// Argon2id with the OWASP minimum (19 MiB, 2 passes), stored as
/// `argon2id$m=19456,t=2,p=1$<salt>$<hash>`.
final class ServerPasswordHasher {
  const ServerPasswordHasher({
    this.memory = 19456,
    this.iterations = 2,
    this.parallelism = 1,
  });

  final int memory;
  final int iterations;
  final int parallelism;

  static const minimumLength = 10;

  Future<String> hash(String password) async {
    final random = Random.secure();
    final salt = List.generate(16, (_) => random.nextInt(256));
    final hash = await _derive(password, salt, memory, iterations, parallelism);
    return 'argon2id\$m=$memory,t=$iterations,p=$parallelism'
        '\$${base64UrlEncode(salt)}\$${base64UrlEncode(hash)}';
  }

  Future<bool> verify(String password, String encoded) async {
    final parts = encoded.split(r'$');
    if (parts.length != 4 || parts[0] != 'argon2id') return false;
    final parameters = {
      for (final pair in parts[1].split(','))
        if (pair.contains('='))
          pair.split('=').first: int.tryParse(pair.split('=').last),
    };
    final m = parameters['m'], t = parameters['t'], p = parameters['p'];
    if (m == null || t == null || p == null) return false;
    try {
      final salt = base64Url.decode(parts[2]);
      final expected = base64Url.decode(parts[3]);
      final actual = await _derive(password, salt, m, t, p);
      if (actual.length != expected.length) return false;
      var difference = 0;
      for (var i = 0; i < actual.length; i++) {
        difference |= actual[i] ^ expected[i];
      }
      return difference == 0;
    } on FormatException {
      return false;
    }
  }

  static Future<List<int>> _derive(
    String password,
    List<int> salt,
    int memory,
    int iterations,
    int parallelism,
  ) async {
    final algorithm = Argon2id(
      memory: memory,
      iterations: iterations,
      parallelism: parallelism,
      hashLength: 32,
    );
    final key = await algorithm.deriveKey(
      secretKey: SecretKey(utf8.encode(password)),
      nonce: salt,
    );
    return key.extractBytes();
  }
}
