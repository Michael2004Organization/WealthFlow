import 'dart:convert';

import 'package:http/http.dart' as http;

/// The browser checks the certificate; the app cannot see it.
const canPinCertificate = false;

/// Asks the server for its fingerprint. The browser has already verified the
/// TLS connection, so the answer comes from the real server.
Future<String> observeServerFingerprint(Uri baseUrl) async {
  final response = await http.get(baseUrl.resolve('/api/pair/info'));
  final body = jsonDecode(response.body);
  if (body is Map && body['fingerprint'] is String) {
    return body['fingerprint'] as String;
  }
  throw const FormatException('Server antwortet nicht wie erwartet.');
}

http.Client pinnedServerClient(String fingerprint) => http.Client();
