import 'dart:convert';
import 'dart:math';

import 'package:cryptography/cryptography.dart';

/// Key material for a password-protected data file.
///
/// Only the derived key is kept on the device; the backup password itself is
/// never stored. The salt and iteration count travel with every file, so the
/// same password opens the file on any other device.
final class BackupKey {
  const BackupKey({
    required this.salt,
    required this.iterations,
    required this.key,
  });

  final List<int> salt;
  final int iterations;
  final List<int> key;

  Map<String, Object> toJson() => {
    'salt': base64Encode(salt),
    'iterations': iterations,
    'key': base64Encode(key),
  };

  static BackupKey? fromJson(Object? value) {
    if (value is! Map) return null;
    try {
      return BackupKey(
        salt: base64Decode(value['salt'] as String),
        iterations: value['iterations'] as int,
        key: base64Decode(value['key'] as String),
      );
    } catch (_) {
      return null;
    }
  }
}

/// Thrown when a password-protected file is opened without a usable key.
final class BackupPasswordRequired implements Exception {
  const BackupPasswordRequired();
}

final class DataCipher {
  DataCipher._();

  static const _format = 'WealthFlow encrypted data';
  static const defaultIterations = 210000;
  static final _algorithm = AesGcm.with256bits();

  static Future<BackupKey> deriveBackupKey(
    String password, {
    List<int>? salt,
    int iterations = defaultIterations,
  }) async {
    final random = Random.secure();
    final usedSalt = salt ?? List<int>.generate(16, (_) => random.nextInt(256));
    final derived = await Pbkdf2(
      macAlgorithm: Hmac.sha256(),
      iterations: iterations,
      bits: 256,
    ).deriveKey(secretKey: SecretKey(utf8.encode(password)), nonce: usedSalt);
    return BackupKey(
      salt: usedSalt,
      iterations: iterations,
      key: await derived.extractBytes(),
    );
  }

  /// Encrypts with a device key (version 1) or, when [backupKey] is given,
  /// with a password-derived key whose salt is stored in the file (version 2).
  static Future<String> encrypt(
    String plaintext,
    List<int> keyBytes, {
    BackupKey? backupKey,
  }) async {
    final box = await _algorithm.encrypt(
      utf8.encode(plaintext),
      secretKey: SecretKey(backupKey?.key ?? keyBytes),
    );
    return const JsonEncoder.withIndent('  ').convert({
      'format': _format,
      'version': backupKey == null ? 1 : 2,
      'algorithm': 'AES-256-GCM',
      if (backupKey != null) ...{
        'kdf': 'PBKDF2-HMAC-SHA256',
        'iterations': backupKey.iterations,
        'salt': base64Encode(backupKey.salt),
      },
      'nonce': base64Encode(box.nonce),
      'ciphertext': base64Encode(box.cipherText),
      'mac': base64Encode(box.mac.bytes),
    });
  }

  static Map<String, dynamic>? _envelope(String content) {
    try {
      final decoded = jsonDecode(content);
      if (decoded is Map && decoded['format'] == _format) {
        return Map<String, dynamic>.from(decoded);
      }
    } on FormatException {
      return null;
    }
    return null;
  }

  /// Whether [content] needs the backup password instead of the device key.
  static bool isPasswordProtected(String content) =>
      _envelope(content)?['kdf'] != null;

  static Future<String> decrypt(String content, List<int> keyBytes) async {
    final map = _envelope(content);
    if (map == null) return content;
    return _open(map, keyBytes);
  }

  /// Opens a version 2 file. [stored] is tried first when its salt matches the
  /// file; otherwise [password] is needed.
  static Future<String> decryptWithPassword(
    String content, {
    BackupKey? stored,
    String? password,
  }) async {
    final map = _envelope(content);
    if (map == null) return content;
    final salt = base64Decode(map['salt'] as String);
    final iterations = map['iterations'] as int;
    if (stored != null &&
        stored.iterations == iterations &&
        _sameBytes(stored.salt, salt)) {
      try {
        return await _open(map, stored.key);
      } on SecretBoxAuthenticationError {
        // Fall through to the password below.
      }
    }
    if (password == null || password.isEmpty) {
      throw const BackupPasswordRequired();
    }
    final derived = await deriveBackupKey(
      password,
      salt: salt,
      iterations: iterations,
    );
    return _open(map, derived.key);
  }

  static Future<String> _open(Map<String, dynamic> map, List<int> key) async {
    final clear = await _algorithm.decrypt(
      SecretBox(
        base64Decode(map['ciphertext'] as String),
        nonce: base64Decode(map['nonce'] as String),
        mac: Mac(base64Decode(map['mac'] as String)),
      ),
      secretKey: SecretKey(key),
    );
    return utf8.decode(clear);
  }

  static bool _sameBytes(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    for (var index = 0; index < a.length; index++) {
      if (a[index] != b[index]) return false;
    }
    return true;
  }
}
