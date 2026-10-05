import 'dart:convert';
import 'dart:io';

import 'package:wealthflow/core/server/server_http_native.dart';
import 'package:wealthflow_core/database/app_database.dart';
import 'package:wealthflow_core/server/pairing.dart';

/// Minimal stand-in for the WealthFlow server: pairing, refresh, /api/me
/// and, with [syncDatabase], /api/sync like the real server.
/// The certificates in test/fixtures are test-only.
final class FakeServer {
  FakeServer._(this._server, this.knownCode);

  final HttpServer _server;

  /// Code the server proves knowledge of; a device in between does not know
  /// the real one.
  final String knownCode;
  final received = <String, Map<String, Object?>>{};
  String fingerprint = '';
  int refreshCalls = 0;
  int syncCalls = 0;
  bool rejectAccess = false;

  /// Database of the server side for /api/sync.
  AppDatabase? syncDatabase;

  int get port => _server.port;
  String get address => 'localhost:$port';

  static Future<FakeServer> start({
    String certificate = 'server_a',
    required String knownCode,
  }) async {
    final context = SecurityContext()
      ..useCertificateChain('test/fixtures/$certificate.crt')
      ..usePrivateKey('test/fixtures/$certificate.key');
    final server = await HttpServer.bindSecure(
      InternetAddress.loopbackIPv4,
      0,
      context,
    );
    final fake = FakeServer._(server, knownCode);
    fake.fingerprint = certificateFingerprint(
      base64Decode(
        File(
          'test/fixtures/$certificate.crt',
        ).readAsLinesSync().where((line) => !line.startsWith('-----')).join(),
      ),
    );
    server.listen(fake._handle);
    return fake;
  }

  String? _serverNonce;

  Future<void> _handle(HttpRequest request) async {
    final text = await utf8.decodeStream(request);
    final body = text.isEmpty
        ? <String, Object?>{}
        : Map<String, Object?>.from(jsonDecode(text) as Map);
    received[request.uri.path] = body;
    Object reply;
    var status = 200;
    switch (request.uri.path) {
      case '/api/health':
        reply = {'status': 'ok'};
      case '/api/pair/challenge':
        _serverNonce = newPairingNonce();
        reply = {
          'serverNonce': _serverNonce,
          'serverProof': await pairingProof(
            code: knownCode,
            role: 'server',
            fingerprint: fingerprint,
            clientNonce: body['clientNonce'] as String,
          ),
        };
      case '/api/pair/complete':
        final expected = await pairingProof(
          code: knownCode,
          role: 'client',
          fingerprint: fingerprint,
          clientNonce: body['clientNonce'] as String,
          serverNonce: _serverNonce!,
        );
        if (!proofsMatch(expected, body['clientProof'] as String)) {
          status = 401;
          reply = {'error': 'Der Kopplungscode stimmt nicht.'};
        } else {
          reply = _session('access-1', 'refresh-1');
        }
      case '/api/auth/refresh':
        refreshCalls++;
        reply = _session('access-${refreshCalls + 1}', 'refresh-$refreshCalls');
      case '/api/me':
        final token = request.headers.value('authorization');
        if (rejectAccess || token == 'Bearer access-1') {
          rejectAccess = false;
          status = 401;
          reply = {'error': 'Bitte erneut anmelden.'};
        } else {
          reply = {'token': token};
        }
      case '/api/sync' when syncDatabase != null:
        syncCalls++;
        final database = syncDatabase!;
        await database.mergeUserData(
          'server-user',
          Map<String, dynamic>.from(body['data']! as Map),
        );
        reply = {
          'data': await database.exportUserData('server-user'),
          'dataFile': body['backupKey'] == null
              ? 'needsBackupPassword'
              : 'written',
        };
      default:
        status = 404;
        reply = {'error': 'Nicht gefunden'};
    }
    request.response
      ..statusCode = status
      ..headers.contentType = ContentType.json
      ..write(jsonEncode(reply));
    await request.response.close();
  }

  Map<String, Object?> _session(String access, String refresh) => {
    'deviceId': 'device-1',
    'accessToken': access,
    'refreshToken': refresh,
    'user': {
      'id': 'server-user',
      'email': 'michael@example.de',
      'displayName': 'Michael',
    },
  };

  Future<void> close() => _server.close(force: true);
}
