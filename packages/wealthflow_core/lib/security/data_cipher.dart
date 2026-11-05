import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:archive/archive.dart';
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

  // --- .wflow2: compressed, binary data file -------------------------------
  //
  // Layout: "WFLOW2" · version (1) · mode (0 device key, 1 password)
  //         [mode 1: iterations (uint32 big endian) · salt (16)]
  //         nonce (12) · mac (16) · AES-256-GCM(gzip(utf8(json)))
  //
  // Compared with the JSON envelope there is no base64 and no indentation,
  // and the content is compressed, so files are roughly ten times smaller.

  static const _packedMagic = [0x57, 0x46, 0x4C, 0x4F, 0x57, 0x32];
  static const _packedVersion = 1;

  /// Whether [bytes] is a `.wflow2` file.
  static bool isPacked(List<int> bytes) {
    if (bytes.length < _packedMagic.length + 2) return false;
    for (var index = 0; index < _packedMagic.length; index++) {
      if (bytes[index] != _packedMagic[index]) return false;
    }
    return true;
  }

  /// Whether a `.wflow2` file needs the backup password.
  static bool isPackedWithPassword(List<int> bytes) =>
      isPacked(bytes) && bytes[_packedMagic.length + 1] == 1;

  /// Compresses and encrypts [plaintext] into a `.wflow2` file.
  static Future<Uint8List> pack(
    String plaintext,
    List<int> keyBytes, {
    BackupKey? backupKey,
  }) async {
    final compressed = const GZipEncoder().encodeBytes(utf8.encode(plaintext));
    final box = await _algorithm.encrypt(
      compressed,
      secretKey: SecretKey(backupKey?.key ?? keyBytes),
    );
    final out = BytesBuilder(copy: false)
      ..add(_packedMagic)
      ..addByte(_packedVersion)
      ..addByte(backupKey == null ? 0 : 1);
    if (backupKey != null) {
      out
        ..add(
          (ByteData(
            4,
          )..setUint32(0, backupKey.iterations)).buffer.asUint8List(),
        )
        ..add(backupKey.salt);
    }
    out
      ..add(box.nonce)
      ..add(box.mac.bytes)
      ..add(box.cipherText);
    return out.toBytes();
  }

  /// Opens a `.wflow2` file. A device-key file needs [deviceKey]; a password
  /// file tries [stored] first when its salt matches, otherwise [password].
  static Future<String> unpack(
    List<int> bytes, {
    List<int>? deviceKey,
    BackupKey? stored,
    String? password,
  }) async {
    if (!isPacked(bytes)) throw const FormatException('Keine .wflow2-Datei');
    var offset = _packedMagic.length;
    final version = bytes[offset++];
    if (version != _packedVersion) {
      throw const FormatException('Unbekannte Version der Datendatei');
    }
    final withPassword = bytes[offset++] == 1;
    List<int>? key = deviceKey;
    if (withPassword) {
      final iterations = ByteData.sublistView(
        Uint8List.fromList(bytes.sublist(offset, offset + 4)),
      ).getUint32(0);
      offset += 4;
      final salt = bytes.sublist(offset, offset + 16);
      offset += 16;
      if (stored != null &&
          stored.iterations == iterations &&
          _sameBytes(stored.salt, salt)) {
        key = stored.key;
      } else if (password == null || password.isEmpty) {
        throw const BackupPasswordRequired();
      } else {
        key = (await deriveBackupKey(
          password,
          salt: salt,
          iterations: iterations,
        )).key;
      }
    }
    if (key == null) throw const BackupPasswordRequired();
    final nonce = bytes.sublist(offset, offset + 12);
    offset += 12;
    final mac = bytes.sublist(offset, offset + 16);
    offset += 16;
    final clear = await _algorithm.decrypt(
      SecretBox(bytes.sublist(offset), nonce: nonce, mac: Mac(mac)),
      secretKey: SecretKey(key),
    );
    return utf8.decode(const GZipDecoder().decodeBytes(clear));
  }

  static bool _sameBytes(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    for (var index = 0; index < a.length; index++) {
      if (a[index] != b[index]) return false;
    }
    return true;
  }
}
