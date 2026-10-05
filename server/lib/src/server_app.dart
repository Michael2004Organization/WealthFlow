import 'dart:convert';

import 'package:shelf/shelf.dart';
import 'package:wealthflow_core/database/app_database.dart';

import 'package:wealthflow_core/security/data_cipher.dart';

import 'access.dart';
import 'sync.dart';

/// Version shown by `/api/health`; the app compares it before syncing.
const serverVersion = '1.0.0';

/// Largest request body accepted (a full data export fits easily).
const maxRequestBytes = 32 * 1024 * 1024;

/// Builds the request handler of the server.
Handler buildHandler({
  required AppDatabase database,
  required ServerAccess access,
  required ServerSync sync,
}) {
  return const Pipeline()
      .addMiddleware(_securityHeaders())
      .addHandler((request) => _route(request, database, access, sync));
}

Future<Response> _route(
  Request request,
  AppDatabase database,
  ServerAccess access,
  ServerSync sync,
) async {
  final path = '/${request.url.path}';
  final method = request.method;
  try {
    switch ((method, path)) {
      case ('GET', '/api/health'):
        return jsonResponse({
          'status': 'ok',
          'version': serverVersion,
          'schemaVersion': database.schemaVersion,
        });
      case ('GET', '/api/pair/info'):
        // Lets the web version, which cannot see the certificate itself,
        // bind the pairing proof to it; the browser already checked TLS.
        return jsonResponse({'fingerprint': access.certificateFingerprint});
      case ('POST', '/api/pair/challenge'):
        final body = await _jsonBody(request);
        return jsonResponse(
          await access.pairingChallenge(_string(body, 'clientNonce')),
        );
      case ('POST', '/api/pair/complete'):
        final body = await _jsonBody(request);
        final session = await access.completePairing(
          clientNonce: _string(body, 'clientNonce'),
          clientProof: _string(body, 'clientProof'),
          email: _string(body, 'email'),
          password: _string(body, 'password'),
          deviceName: _string(body, 'deviceName'),
        );
        return jsonResponse(session.toJson());
      case ('POST', '/api/auth/login'):
        final body = await _jsonBody(request);
        final session = await access.login(
          deviceId: _string(body, 'deviceId'),
          email: _string(body, 'email'),
          password: _string(body, 'password'),
        );
        return jsonResponse(session.toJson());
      case ('POST', '/api/auth/refresh'):
        final body = await _jsonBody(request);
        final session = await access.refresh(_string(body, 'refreshToken'));
        return jsonResponse(session.toJson());
    }

    final context = await access.authenticate(request.headers['authorization']);
    if (path.startsWith('/api/') && context == null) {
      return jsonResponse({'error': 'Bitte erneut anmelden.'}, status: 401);
    }
    switch ((method, path)) {
      case ('POST', '/api/auth/logout'):
        await access.logout(context!);
        return jsonResponse({'status': 'ok'});
      case ('GET', '/api/me'):
        final user = await database.userById(context!.userId);
        return jsonResponse({
          'id': user!.id,
          'email': user.email,
          'displayName': user.displayName,
          'role': user.role,
          'deviceId': context.deviceId,
        });
      case ('POST', '/api/sync'):
        final body = await _jsonBody(request);
        if (body['schemaVersion'] != database.schemaVersion) {
          throw const _BadRequest(
            'App und Server haben unterschiedliche Versionen. Bitte beide '
            'auf den neuesten Stand bringen.',
            status: 409,
          );
        }
        final data = body['data'];
        if (data is! Map) throw const _BadRequest('Feld "data" fehlt.');
        final result = await sync.sync(
          context!,
          Map<String, Object?>.from(data),
          backupKey: BackupKey.fromJson(body['backupKey']),
        );
        return jsonResponse({
          'data': result.data,
          'dataFile': result.dataFile.name,
          'syncedAt': DateTime.now().toUtc().toIso8601String(),
        });
    }
    return jsonResponse({'error': 'Nicht gefunden'}, status: 404);
  } on AccessDenied catch (denied) {
    return jsonResponse({'error': denied.message}, status: denied.status);
  } on _BadRequest catch (bad) {
    return jsonResponse({'error': bad.message}, status: bad.status);
  }
}

Response jsonResponse(Object body, {int status = 200}) => Response(
  status,
  body: jsonEncode(body),
  headers: {'content-type': 'application/json; charset=utf-8'},
);

final class _BadRequest implements Exception {
  const _BadRequest(this.message, {this.status = 400});

  final String message;
  final int status;
}

Future<Map<String, Object?>> _jsonBody(Request request) async {
  final length = request.contentLength;
  if (length != null && length > maxRequestBytes) {
    throw const _BadRequest('Anfrage zu groß.', status: 413);
  }
  final bytes = <int>[];
  await for (final chunk in request.read()) {
    bytes.addAll(chunk);
    if (bytes.length > maxRequestBytes) {
      throw const _BadRequest('Anfrage zu groß.', status: 413);
    }
  }
  try {
    final decoded = jsonDecode(utf8.decode(bytes));
    if (decoded is Map) return Map<String, Object?>.from(decoded);
  } on FormatException {
    // Falls through to the error below.
  }
  throw const _BadRequest('Ungültige Anfrage.');
}

String _string(Map<String, Object?> body, String key) {
  final value = body[key];
  if (value is! String) throw _BadRequest('Feld "$key" fehlt.');
  return value;
}

Middleware _securityHeaders() =>
    (inner) => (request) async {
      final response = await inner(request);
      return response.change(
        headers: {
          'strict-transport-security': 'max-age=31536000',
          'x-content-type-options': 'nosniff',
          'referrer-policy': 'no-referrer',
          'cache-control': 'no-store',
        },
      );
    };
