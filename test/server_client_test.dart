import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:wealthflow/core/security/secure_session_store.dart';
import 'package:wealthflow/core/server/server_client.dart';
import 'package:wealthflow/core/server/server_connection.dart';
import 'package:wealthflow/core/server/server_http_native.dart';
import 'package:wealthflow/core/server/server_link.dart';
import 'package:wealthflow_core/server/pairing.dart';

import 'support/fake_server.dart';

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
