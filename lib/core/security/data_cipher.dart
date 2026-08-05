import 'dart:convert';

import 'package:cryptography/cryptography.dart';

final class DataCipher {
  DataCipher._();

  static final _algorithm = AesGcm.with256bits();

  static Future<String> encrypt(String plaintext, List<int> keyBytes) async {
    final box = await _algorithm.encrypt(
      utf8.encode(plaintext),
      secretKey: SecretKey(keyBytes),
    );
    return const JsonEncoder.withIndent('  ').convert({
      'format': 'WealthFlow encrypted data',
      'version': 1,
      'algorithm': 'AES-256-GCM',
      'nonce': base64Encode(box.nonce),
      'ciphertext': base64Encode(box.cipherText),
      'mac': base64Encode(box.mac.bytes),
    });
  }

  static Future<String> decrypt(String content, List<int> keyBytes) async {
    final decoded = jsonDecode(content);
    if (decoded is! Map || decoded['format'] != 'WealthFlow encrypted data') {
      return content;
    }
    final map = Map<String, dynamic>.from(decoded);
    final clear = await _algorithm.decrypt(
      SecretBox(
        base64Decode(map['ciphertext'] as String),
        nonce: base64Decode(map['nonce'] as String),
        mac: Mac(base64Decode(map['mac'] as String)),
      ),
      secretKey: SecretKey(keyBytes),
    );
    return utf8.decode(clear);
  }
}
