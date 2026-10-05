import 'dart:convert';
import 'dart:math';

import 'package:cryptography/cryptography.dart';

/// Characters of a pairing code: no 0/O, 1/I/L, so it can be typed from the
/// server window without mix-ups.
const pairingAlphabet = 'ABCDEFGHJKMNPQRSTUVWXYZ23456789';

/// Length of a pairing code without separators (about 59 bits).
const pairingCodeLength = 12;

/// Creates a random pairing code such as `ABCD-EFGH-JKMN`.
String newPairingCode([Random? random]) {
  final source = random ?? Random.secure();
  final raw = List.generate(
    pairingCodeLength,
    (_) => pairingAlphabet[source.nextInt(pairingAlphabet.length)],
  ).join();
  return formatPairingCode(raw);
}

/// Upper-cases and removes spaces and dashes.
String normalizePairingCode(String code) =>
    code.toUpperCase().replaceAll(RegExp(r'[\s\-]'), '');

String formatPairingCode(String code) {
  final raw = normalizePairingCode(code);
  return [
    for (var i = 0; i < raw.length; i += 4)
      raw.substring(i, min(i + 4, raw.length)),
  ].join('-');
}

/// Random nonce for one pairing attempt, base64url.
String newPairingNonce([Random? random]) {
  final source = random ?? Random.secure();
  return base64UrlEncode(List.generate(16, (_) => source.nextInt(256)));
}

/// Proof that one side knows the pairing code and sees the same server
/// certificate.
///
/// The server sends its proof first; the app compares it with the proof it
/// computes from the fingerprint it actually sees. A device in between that
/// presents its own certificate cannot produce a matching proof without the
/// code, so the app stops before revealing anything.
Future<String> pairingProof({
  required String code,
  required String role,
  required String fingerprint,
  required String clientNonce,
  String serverNonce = '',
}) async {
  final mac = await Hmac.sha256().calculateMac(
    utf8.encode('wealthflow-pairing|$role|$fingerprint|$clientNonce|$serverNonce'),
    secretKey: SecretKey(utf8.encode(normalizePairingCode(code))),
  );
  return base64UrlEncode(mac.bytes);
}

/// Compares two proofs in constant time.
bool proofsMatch(String a, String b) {
  if (a.length != b.length) return false;
  var difference = 0;
  for (var i = 0; i < a.length; i++) {
    difference |= a.codeUnitAt(i) ^ b.codeUnitAt(i);
  }
  return difference == 0;
}
