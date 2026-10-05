import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:wealthflow/core/security/secure_session_store.dart';
import 'package:wealthflow/core/server/server_client.dart';
import 'package:wealthflow/core/server/server_connection.dart';
import 'package:wealthflow/core/server/server_http_native.dart';
import 'package:wealthflow/core/server/server_link.dart';
import 'package:wealthflow_core/server/pairing.dart';

/// Minimal stand-in for the WealthFlow server: pairing, refresh and /api/me.
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
  bool rejectAccess = false;

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

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  // The test binding answers every HTTP request with 400; these tests talk
  // to a real local HTTPS server.
  setUpAll(() => HttpOverrides.global = null);

  group('Adresse', () {
    test('nimmt Name, IP und https-Adresse, Standard-Port 8443', () {
      expect(parseServerAddress('meinpc').toString(), 'https://meinpc:8443');
      expect(
        parseServerAddress(' 192.168.178.20:9000 ').toString(),
        'https://192.168.178.20:9000',
      );
      expect(
        parseServerAddress('https://meinpc.fritz.box:8443/').toString(),
        'https://meinpc.fritz.box:8443',
      );
    });

    test('lehnt unverschlüsseltes http und Leeres ab', () {
      expect(parseServerAddress('http://meinpc:8443'), isNull);
      expect(parseServerAddress('  '), isNull);
    });
  });

  group('Zertifikat', () {
    late FakeServer server;

    setUp(() async => server = await FakeServer.start(knownCode: 'X'));
    tearDown(() => server.close());

    test('Fingerabdruck wird gesehen wie im Server-Fenster', () async {
      final seen = await observeServerFingerprint(
        Uri.parse('https://${server.address}'),
      );
      expect(seen, server.fingerprint);
      expect(seen, matches(RegExp(r'^[0-9A-F]{64}$')));
    });

    test('gepinnter Client spricht nur mit genau diesem Server', () async {
      final url = Uri.parse('https://${server.address}/api/health');
      final good = pinnedServerClient(server.fingerprint);
      expect((await good.get(url)).statusCode, 200);
      good.close();

      final other = pinnedServerClient('00' * 32);
      await expectLater(other.get(url), throwsA(anything));
      other.close();
    });
  });

  group('Koppeln', () {
    test('mit richtigem Code verbunden', () async {
      final code = newPairingCode();
      final server = await FakeServer.start(knownCode: code);
      final session = await ServerClient().pair(
        address: server.address,
        code: code.toLowerCase(),
        email: ' Michael@Example.de ',
        password: 'geheimes-passwort',
        deviceName: 'Test',
      );
      await server.close();
      expect(session.link.fingerprint, server.fingerprint);
      expect(session.link.deviceId, 'device-1');
      expect(session.tokens.refreshToken, 'refresh-1');
      expect(
        server.received['/api/pair/complete']!['email'],
        'michael@example.de',
      );
    });

    test('Gerät dazwischen ohne Code bekommt kein Passwort', () async {
      // Something in the WLAN answers instead of the real server. It does
      // not know the code shown in the server window.
      final server = await FakeServer.start(
        certificate: 'server_b',
        knownCode: newPairingCode(),
      );
      await expectLater(
        ServerClient().pair(
          address: server.address,
          code: newPairingCode(),
          email: 'michael@example.de',
          password: 'geheimes-passwort',
          deviceName: 'Test',
        ),
        throwsA(
          isA<ServerException>().having(
            (e) => e.message,
            'message',
            contains('passt nicht'),
          ),
        ),
      );
      await server.close();
      expect(server.received.containsKey('/api/pair/complete'), isFalse);
    });

    test('nicht erreichbarer Server liefert verständliche Meldung', () async {
      await expectLater(
        ServerClient().pair(
          address: 'localhost:1',
          code: newPairingCode(),
          email: 'michael@example.de',
          password: 'x',
          deviceName: 'Test',
        ),
        throwsA(
          isA<ServerException>().having(
            (e) => e.message,
            'message',
            contains('start.cmd'),
          ),
        ),
      );
    });

    test('falsch getippter Code wird vor dem Senden erkannt', () async {
      await expectLater(
        ServerClient().pair(
          address: 'localhost:1',
          code: 'ABC',
          email: 'michael@example.de',
          password: 'x',
          deviceName: 'Test',
        ),
        throwsA(isA<ServerException>()),
      );
    });
  });

  test('abgelehnter Zugangstoken wird einmal erneuert', () async {
    final code = newPairingCode();
    final server = await FakeServer.start(knownCode: code);
    final controller = ServerConnectionController(
      userId: 'local-user',
      sessionStore: SecureSessionStore(),
    );
    final ok = await controller.pair(
      address: server.address,
      code: code,
      email: 'michael@example.de',
      password: 'geheimes-passwort',
    );
    expect(ok, isTrue, reason: controller.state.error);

    final result = await controller.authorized(
      (link, token) => controller.client.send(link, token, 'GET', '/api/me'),
    );
    expect(result['token'], 'Bearer access-2');
    expect(server.refreshCalls, 1);
    expect(
      await SecureSessionStore().readServerRefreshToken('local-user'),
      'refresh-1',
    );

    await controller.disconnect();
    expect(controller.state.isConnected, isFalse);
    expect(await SecureSessionStore().readServerLink('local-user'), isNull);
    await server.close();
    controller.dispose();
  });
}
