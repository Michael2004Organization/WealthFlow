import 'dart:convert';
import 'dart:io';

import 'package:drift/native.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:test/test.dart';
import 'package:wealthflow_core/database/app_database.dart';
import 'package:wealthflow_core/server/pairing.dart';
import 'package:wealthflow_server/wealthflow_server.dart';

const fastHasher = ServerPasswordHasher(memory: 64, iterations: 1);
const password = 'richtig-langes-passwort';

void main() {
  late AppDatabase database;
  late ServerAccess access;
  late DateTime now;

  setUp(() async {
    now = DateTime.utc(2026, 10, 5, 20);
    database = AppDatabase(NativeDatabase.memory());
    access = ServerAccess(
      database,
      certificateFingerprint: 'AA' * 32,
      hasher: fastHasher,
      clock: () => now,
    );
    await access.initialize();
    await access.createUser(
      email: 'Michael@Example.de',
      displayName: 'Michael',
      password: password,
    );
  });

  tearDown(() => database.close());

  Future<DeviceSession> pair({
    String? code,
    String fingerprintSeen = '',
    String email = 'michael@example.de',
    String pass = password,
  }) async {
    final active = code ?? access.startPairing();
    final clientNonce = newPairingNonce();
    final challenge = await access.pairingChallenge(clientNonce);
    final seen = fingerprintSeen.isEmpty ? 'AA' * 32 : fingerprintSeen;
    final expectedServerProof = await pairingProof(
      code: active,
      role: 'server',
      fingerprint: seen,
      clientNonce: clientNonce,
    );
    if (!proofsMatch(expectedServerProof, challenge['serverProof']!)) {
      throw StateError('Server-Nachweis passt nicht');
    }
    return access.completePairing(
      clientNonce: clientNonce,
      clientProof: await pairingProof(
        code: active,
        role: 'client',
        fingerprint: seen,
        clientNonce: clientNonce,
        serverNonce: challenge['serverNonce']!,
      ),
      email: email,
      password: pass,
      deviceName: 'Handy',
    );
  }

  test('erstes Konto ist Admin, weitere sind Mitglieder', () async {
    final second = await access.createUser(
      email: 'tobias@example.de',
      displayName: 'Tobias',
      password: password,
    );
    final first = await database.userByEmail('michael@example.de');
    expect(first!.role, 'admin');
    expect(second.role, 'member');
    expect(first.passwordHash, startsWith(r'argon2id$'));
    expect(first.passwordHash, isNot(contains(password)));
  });

  test('zu kurzes Passwort und doppelte E-Mail werden abgelehnt', () async {
    await expectLater(
      access.createUser(email: 'a@b.de', displayName: 'A', password: 'kurz'),
      throwsA(isA<AccessDenied>()),
    );
    await expectLater(
      access.createUser(
        email: 'michael@example.de',
        displayName: 'X',
        password: password,
      ),
      throwsA(isA<AccessDenied>()),
    );
  });

  test('Koppeln mit Code und Passwort liefert gültige Tokens', () async {
    final session = await pair();
    final context = await access.authenticate('Bearer ${session.accessToken}');
    expect(context!.deviceId, session.deviceId);
    expect(session.user.email, 'michael@example.de');
    expect((await access.devices()).single.name, 'Handy');
  });

  test('ein Code koppelt nur ein Gerät', () async {
    final code = access.startPairing();
    await pair(code: code);
    await expectLater(pair(code: code), throwsA(isA<AccessDenied>()));
  });

  test('falscher Code wird abgelehnt und nach 5 Fehlern ungültig', () async {
    final code = access.startPairing();
    for (var i = 0; i < ServerAccess.maxPairingFailures; i++) {
      final clientNonce = newPairingNonce();
      final challenge = await access.pairingChallenge(clientNonce);
      await expectLater(
        access.completePairing(
          clientNonce: clientNonce,
          clientProof: await pairingProof(
            code: 'FALS-CHER-CODE',
            role: 'client',
            fingerprint: 'AA' * 32,
            clientNonce: clientNonce,
            serverNonce: challenge['serverNonce']!,
          ),
          email: 'michael@example.de',
          password: password,
          deviceName: 'Fremd',
        ),
        throwsA(isA<AccessDenied>()),
      );
    }
    // Even the right code no longer works now.
    await expectLater(pair(code: code), throwsA(isA<AccessDenied>()));
  });

  test('Gerät dazwischen mit eigenem Zertifikat fällt auf', () async {
    // The app sees another certificate than the server holds, so the
    // server's proof does not match and the app stops before sending
    // anything secret.
    await expectLater(
      pair(fingerprintSeen: 'BB' * 32),
      throwsA(isA<StateError>()),
    );
  });

  test('abgelaufener Code wird abgelehnt', () async {
    final code = access.startPairing();
    now = now.add(ServerAccess.pairingLifetime + const Duration(seconds: 1));
    await expectLater(pair(code: code), throwsA(isA<AccessDenied>()));
  });

  test(
    'falsches Passwort sperrt nach 5 Versuchen für einige Minuten',
    () async {
      final session = await pair();
      for (var i = 0; i < ServerAccess.maxLoginFailures; i++) {
        await expectLater(
          access.login(
            deviceId: session.deviceId,
            email: 'michael@example.de',
            password: 'falsch-falsch',
          ),
          throwsA(isA<AccessDenied>()),
        );
      }
      final locked = access.login(
        deviceId: session.deviceId,
        email: 'michael@example.de',
        password: password,
      );
      await expectLater(
        locked,
        throwsA(isA<AccessDenied>().having((e) => e.status, 'status', 429)),
      );
      now = now.add(ServerAccess.lockDuration + const Duration(seconds: 1));
      final again = await access.login(
        deviceId: session.deviceId,
        email: 'michael@example.de',
        password: password,
      );
      expect(again.deviceId, session.deviceId);
    },
  );

  test('Zugangstoken läuft nach 15 Minuten ab, Refresh erneuert', () async {
    final session = await pair();
    now = now.add(ServerAccess.accessLifetime + const Duration(seconds: 1));
    expect(await access.authenticate('Bearer ${session.accessToken}'), isNull);
    final renewed = await access.refresh(session.refreshToken);
    expect(
      await access.authenticate('Bearer ${renewed.accessToken}'),
      isNotNull,
    );
    // The old refresh token was replaced.
    await expectLater(
      access.refresh(session.refreshToken),
      throwsA(isA<AccessDenied>()),
    );
  });

  test('Abmelden und Entfernen beenden den Zugang', () async {
    final session = await pair();
    final context = await access.authenticate('Bearer ${session.accessToken}');
    await access.logout(context!);
    expect(await access.authenticate('Bearer ${session.accessToken}'), isNull);
    await expectLater(
      access.refresh(session.refreshToken),
      throwsA(isA<AccessDenied>()),
    );

    final relogged = await access.login(
      deviceId: session.deviceId,
      email: 'michael@example.de',
      password: password,
    );
    await access.revokeDevice(session.deviceId);
    expect(await access.authenticate('Bearer ${relogged.accessToken}'), isNull);
    await expectLater(
      access.login(
        deviceId: session.deviceId,
        email: 'michael@example.de',
        password: password,
      ),
      throwsA(isA<AccessDenied>()),
    );
  });

  test(
    'anderer Benutzer kann sich nicht über fremdes Gerät anmelden',
    () async {
      await access.createUser(
        email: 'tobias@example.de',
        displayName: 'Tobias',
        password: password,
      );
      final session = await pair();
      await expectLater(
        access.login(
          deviceId: session.deviceId,
          email: 'tobias@example.de',
          password: password,
        ),
        throwsA(isA<AccessDenied>()),
      );
    },
  );

  group('über HTTPS', () {
    late HttpServer server;
    late ServerCertificate certificate;
    late ServerAccess httpsAccess;

    setUp(() async {
      certificate = ServerCertificate.create(hostNames: ['localhost']);
      httpsAccess = ServerAccess(
        database,
        certificateFingerprint: certificate.fingerprint,
        hasher: fastHasher,
      );
      server = await shelf_io.serve(
        buildHandler(
          database: database,
          access: httpsAccess,
          sync: ServerSync(database, settings: const ServerSettings()),
        ),
        InternetAddress.loopbackIPv4,
        0,
        securityContext: certificate.securityContext(),
      );
    });

    tearDown(() => server.close(force: true));

    Future<(int, Map<String, Object?>)> call(
      String method,
      String path, {
      Map<String, Object?>? body,
      String? token,
    }) async {
      final client = HttpClient()
        ..badCertificateCallback = (cert, _, _) =>
            derFingerprint(cert.der) == certificate.fingerprint;
      final request = await client.openUrl(
        method,
        Uri.parse('https://localhost:${server.port}$path'),
      );
      if (token != null) request.headers.set('authorization', 'Bearer $token');
      if (body != null) {
        request.headers.contentType = ContentType.json;
        request.write(jsonEncode(body));
      }
      final response = await request.close();
      final text = await utf8.decodeStream(response);
      client.close();
      return (
        response.statusCode,
        Map<String, Object?>.from(jsonDecode(text) as Map),
      );
    }

    test('Koppeln, /api/me und Abmelden', () async {
      final code = httpsAccess.startPairing();
      final (_, info) = await call('GET', '/api/pair/info');
      expect(info['fingerprint'], certificate.fingerprint);

      final clientNonce = newPairingNonce();
      final (_, challenge) = await call(
        'POST',
        '/api/pair/challenge',
        body: {'clientNonce': clientNonce},
      );
      expect(
        proofsMatch(
          challenge['serverProof'] as String,
          await pairingProof(
            code: code,
            role: 'server',
            fingerprint: certificate.fingerprint,
            clientNonce: clientNonce,
          ),
        ),
        isTrue,
      );
      final (status, session) = await call(
        'POST',
        '/api/pair/complete',
        body: {
          'clientNonce': clientNonce,
          'clientProof': await pairingProof(
            code: code,
            role: 'client',
            fingerprint: certificate.fingerprint,
            clientNonce: clientNonce,
            serverNonce: challenge['serverNonce'] as String,
          ),
          'email': 'michael@example.de',
          'password': password,
          'deviceName': 'PC',
        },
      );
      expect(status, 200);
      final token = session['accessToken'] as String;

      final (meStatus, me) = await call('GET', '/api/me', token: token);
      expect(meStatus, 200);
      expect(me['email'], 'michael@example.de');

      final (noTokenStatus, _) = await call('GET', '/api/me');
      expect(noTokenStatus, 401);

      await call('POST', '/api/auth/logout', token: token);
      final (afterStatus, _) = await call('GET', '/api/me', token: token);
      expect(afterStatus, 401);
    });

    test('kaputte Anfragen liefern 400 statt Absturz', () async {
      final client = HttpClient()
        ..badCertificateCallback = (cert, _, _) => true;
      final request = await client.postUrl(
        Uri.parse('https://localhost:${server.port}/api/auth/login'),
      );
      request.write('kein json');
      final response = await request.close();
      await response.drain<void>();
      client.close();
      expect(response.statusCode, 400);
    });
  });
}
