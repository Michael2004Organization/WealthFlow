import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';

/// Whether this platform can see and pin the server certificate itself.
const canPinCertificate = true;

/// SHA-256 of a DER certificate, 64 upper-case hex digits (as the server
/// window shows it).
String certificateFingerprint(List<int> der) =>
    sha256.convert(der).toString().toUpperCase();

/// Connects once and returns the fingerprint of the certificate the server
/// presents, without trusting it yet.
Future<String> observeServerFingerprint(Uri baseUrl) async {
  String? seen;
  final client = HttpClient(context: SecurityContext(withTrustedRoots: false))
    ..connectionTimeout = const Duration(seconds: 8)
    ..badCertificateCallback = (certificate, _, _) {
      seen = certificateFingerprint(certificate.der);
      return true;
    };
  try {
    final request = await client.getUrl(baseUrl.resolve('/api/health'));
    final response = await request.close();
    await response.drain<void>();
  } finally {
    client.close(force: true);
  }
  final fingerprint = seen;
  if (fingerprint == null) {
    throw const HttpException('Kein Zertifikat vom Server erhalten.');
  }
  return fingerprint;
}

/// HTTP client that only talks to the server holding [fingerprint].
///
/// No system root is trusted, so every certificate goes through the
/// fingerprint check; a certificate signed by a public authority for the
/// same name is refused as well.
http.Client pinnedServerClient(String fingerprint) {
  final client = HttpClient(context: SecurityContext(withTrustedRoots: false))
    ..connectionTimeout = const Duration(seconds: 8)
    ..badCertificateCallback = (certificate, _, _) =>
        certificateFingerprint(certificate.der) == fingerprint;
  return IOClient(client);
}
