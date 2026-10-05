import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:wealthflow_core/server/pairing.dart';

import 'server_http.dart';
import 'server_link.dart';

/// A refusal or connection problem, worded for the user.
final class ServerException implements Exception {
  const ServerException(this.message, {this.status});

  final String message;

  /// HTTP status, or null when the server was not reached.
  final int? status;

  bool get needsLogin => status == 401;

  @override
  String toString() => message;
}

/// Tokens of one signed-in device.
final class ServerTokens {
  const ServerTokens({required this.accessToken, required this.refreshToken});

  final String accessToken;
  final String refreshToken;
}

/// Result of pairing or signing in.
final class ServerSession {
  const ServerSession({required this.link, required this.tokens});

  final ServerLink link;
  final ServerTokens tokens;
}

const _unreachable =
    'Der Server ist nicht erreichbar. Läuft start.cmd auf dem PC, und ist '
    'dieses Gerät im selben WLAN?';

/// Talks to the WealthFlow server over the pinned HTTPS connection.
final class ServerClient {
  ServerClient({
    Future<String> Function(Uri baseUrl)? observeFingerprint,
    http.Client Function(String fingerprint)? clientFor,
  }) : _observeFingerprint = observeFingerprint ?? observeServerFingerprint,
       _clientFor = clientFor ?? pinnedServerClient;

  final Future<String> Function(Uri baseUrl) _observeFingerprint;
  final http.Client Function(String fingerprint) _clientFor;

  static const _timeout = Duration(seconds: 20);

  /// Pairs this device with the code shown in the server window and signs
  /// in. Nothing secret leaves the device before the server has proven that
  /// it knows the code and holds the certificate this device sees.
  Future<ServerSession> pair({
    required String address,
    required String code,
    required String email,
    required String password,
    required String deviceName,
  }) async {
    final baseUrl = parseServerAddress(address);
    if (baseUrl == null) {
      throw const ServerException(
        'Bitte die Adresse aus dem Server-Fenster eingeben, '
        'z. B. 192.168.178.20:8443.',
      );
    }
    if (normalizePairingCode(code).length != pairingCodeLength) {
      throw const ServerException(
        'Der Kopplungscode hat 12 Zeichen, z. B. ABCD-EFGH-JKMN.',
      );
    }
    final String fingerprint;
    try {
      fingerprint = await _observeFingerprint(baseUrl).timeout(_timeout);
    } catch (_) {
      throw const ServerException(_unreachable);
    }
    final client = _clientFor(fingerprint);
    try {
      final clientNonce = newPairingNonce();
      final challenge = await _post(client, baseUrl, '/api/pair/challenge', {
        'clientNonce': clientNonce,
      });
      final expected = await pairingProof(
        code: code,
        role: 'server',
        fingerprint: fingerprint,
        clientNonce: clientNonce,
      );
      final serverProof = challenge['serverProof'];
      if (serverProof is! String || !proofsMatch(expected, serverProof)) {
        throw const ServerException(
          'Der Kopplungscode passt nicht zu diesem Server. Bitte Code und '
          'Adresse prüfen. Wenn beides stimmt, gibt sich womöglich ein '
          'anderes Gerät als dein Server aus.',
        );
      }
      final body = await _post(client, baseUrl, '/api/pair/complete', {
        'clientNonce': clientNonce,
        'clientProof': await pairingProof(
          code: code,
          role: 'client',
          fingerprint: fingerprint,
          clientNonce: clientNonce,
          serverNonce: challenge['serverNonce'] as String? ?? '',
        ),
        'email': email.trim().toLowerCase(),
        'password': password,
        'deviceName': deviceName,
      });
      return _session(body, baseUrl: baseUrl, fingerprint: fingerprint);
    } finally {
      client.close();
    }
  }

  /// Signs a paired device in again.
  Future<ServerSession> login(
    ServerLink link, {
    required String email,
    required String password,
  }) async {
    final client = _clientFor(link.fingerprint);
    try {
      final body =
          await _post(client, Uri.parse(link.baseUrl), '/api/auth/login', {
            'deviceId': link.deviceId,
            'email': email.trim().toLowerCase(),
            'password': password,
          });
      return _session(
        body,
        baseUrl: Uri.parse(link.baseUrl),
        fingerprint: link.fingerprint,
      );
    } finally {
      client.close();
    }
  }

  Future<ServerTokens> refresh(ServerLink link, String refreshToken) async {
    final client = _clientFor(link.fingerprint);
    try {
      final body = await _post(
        client,
        Uri.parse(link.baseUrl),
        '/api/auth/refresh',
        {'refreshToken': refreshToken},
      );
      return _tokens(body);
    } finally {
      client.close();
    }
  }

  Future<void> logout(ServerLink link, String accessToken) async {
    final client = _clientFor(link.fingerprint);
    try {
      await _post(
        client,
        Uri.parse(link.baseUrl),
        '/api/auth/logout',
        const {},
        accessToken: accessToken,
      );
    } finally {
      client.close();
    }
  }

  /// Authorized JSON request for the sync endpoints.
  Future<Map<String, Object?>> send(
    ServerLink link,
    String accessToken,
    String method,
    String path, {
    Map<String, Object?>? body,
  }) async {
    final client = _clientFor(link.fingerprint);
    try {
      return await _request(
        client,
        method,
        Uri.parse(link.baseUrl).resolve(path),
        body: body,
        accessToken: accessToken,
      );
    } finally {
      client.close();
    }
  }

  Future<Map<String, Object?>> _post(
    http.Client client,
    Uri baseUrl,
    String path,
    Map<String, Object?> body, {
    String? accessToken,
  }) => _request(
    client,
    'POST',
    baseUrl.resolve(path),
    body: body,
    accessToken: accessToken,
  );

  Future<Map<String, Object?>> _request(
    http.Client client,
    String method,
    Uri url, {
    Map<String, Object?>? body,
    String? accessToken,
  }) async {
    final request = http.Request(method, url)
      ..headers['accept'] = 'application/json';
    if (accessToken != null) {
      request.headers['authorization'] = 'Bearer $accessToken';
    }
    if (body != null) {
      request.headers['content-type'] = 'application/json; charset=utf-8';
      request.body = jsonEncode(body);
    }
    final http.Response response;
    try {
      response = await http.Response.fromStream(
        await client.send(request).timeout(_timeout),
      ).timeout(_timeout);
    } catch (_) {
      throw const ServerException(_unreachable);
    }
    Object? decoded;
    try {
      decoded = jsonDecode(utf8.decode(response.bodyBytes));
    } on FormatException {
      decoded = null;
    }
    final map = decoded is Map ? Map<String, Object?>.from(decoded) : null;
    if (response.statusCode >= 400) {
      throw ServerException(
        map?['error'] as String? ??
            'Der Server hat die Anfrage abgelehnt (${response.statusCode}).',
        status: response.statusCode,
      );
    }
    if (map == null) {
      throw const ServerException('Der Server antwortet nicht wie erwartet.');
    }
    return map;
  }

  static ServerTokens _tokens(Map<String, Object?> body) {
    final access = body['accessToken'], refresh = body['refreshToken'];
    if (access is! String || refresh is! String) {
      throw const ServerException('Der Server antwortet nicht wie erwartet.');
    }
    return ServerTokens(accessToken: access, refreshToken: refresh);
  }

  static ServerSession _session(
    Map<String, Object?> body, {
    required Uri baseUrl,
    required String fingerprint,
  }) {
    final user = body['user'];
    final deviceId = body['deviceId'];
    if (user is! Map || deviceId is! String) {
      throw const ServerException('Der Server antwortet nicht wie erwartet.');
    }
    return ServerSession(
      link: ServerLink(
        baseUrl: baseUrl.toString(),
        fingerprint: fingerprint,
        deviceId: deviceId,
        serverUserId: user['id'] as String,
        email: user['email'] as String? ?? '',
        displayName: user['displayName'] as String? ?? '',
      ),
      tokens: _tokens(body),
    );
  }
}
