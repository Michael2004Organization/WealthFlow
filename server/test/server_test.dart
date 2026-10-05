import 'dart:convert';
import 'dart:io';

import 'package:drift/native.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:test/test.dart';
import 'package:wealthflow_core/database/app_database.dart';
import 'package:wealthflow_server/wealthflow_server.dart';

void main() {
  group('Zertifikat', () {
    late Directory temp;

    setUp(() async {
      temp = await Directory.systemTemp.createTemp('wealthflow-tls-');
    });
    tearDown(() => temp.delete(recursive: true));

    test('wird beim ersten Start erzeugt und danach wiederverwendet', () async {
      final first = await ServerCertificate.loadOrCreate(
        temp,
        hostNames: ['meinpc', 'localhost'],
      );
      final second = await ServerCertificate.loadOrCreate(
        temp,
        hostNames: ['anderer-name'],
      );
      expect(second.fingerprint, first.fingerprint);
      expect(first.fingerprint, matches(RegExp(r'^[0-9A-F]{64}$')));
      expect(
        File(
          '${temp.path}/${ServerCertificate.certificateFileName}',
        ).readAsStringSync(),
        startsWith('-----BEGIN CERTIFICATE-----'),
      );
    });

    test('zwei neue Zertifikate haben verschiedene Fingerabdrücke', () {
      final a = ServerCertificate.create(hostNames: ['meinpc']);
      final b = ServerCertificate.create(hostNames: ['meinpc']);
      expect(a.fingerprint, isNot(b.fingerprint));
      expect(a.readableFingerprint.split(' '), hasLength(16));
    });
  });

  group('HTTPS-Server', () {
    late HttpServer server;
    late AppDatabase database;
    late ServerCertificate certificate;

    setUp(() async {
      certificate = ServerCertificate.create(hostNames: ['localhost']);
      database = AppDatabase(NativeDatabase.memory());
      final access = ServerAccess(
        database,
        certificateFingerprint: certificate.fingerprint,
      );
      await access.initialize();
      server = await shelf_io.serve(
        buildHandler(database: database, access: access),
        InternetAddress.loopbackIPv4,
        0,
        securityContext: certificate.securityContext(),
      );
    });

    tearDown(() async {
      await server.close(force: true);
      await database.close();
    });

    HttpClient pinnedClient(String fingerprint) =>
        HttpClient()
          ..badCertificateCallback = (cert, host, port) =>
              derFingerprint(cert.der) == fingerprint;

    test('/api/health antwortet über HTTPS', () async {
      final client = pinnedClient(certificate.fingerprint);
      final request = await client.getUrl(
        Uri.parse('https://localhost:${server.port}/api/health'),
      );
      final response = await request.close();
      final body = jsonDecode(await utf8.decodeStream(response)) as Map;
      client.close();

      expect(response.statusCode, 200);
      expect(body['status'], 'ok');
      expect(body['version'], serverVersion);
      expect(body['schemaVersion'], database.schemaVersion);
      expect(response.headers.value('strict-transport-security'), isNotNull);
      expect(response.headers.value('x-content-type-options'), 'nosniff');
    });

    test('ein Gerät mit anderem Fingerabdruck verbindet sich nicht', () async {
      final other = ServerCertificate.create(hostNames: ['localhost']);
      final client = pinnedClient(other.fingerprint);
      await expectLater(
        client
            .getUrl(Uri.parse('https://localhost:${server.port}/api/health'))
            .then((request) => request.close()),
        throwsA(isA<HandshakeException>()),
      );
      client.close(force: true);
    });

    test('unverschlüsseltes HTTP wird nicht beantwortet', () async {
      final client = HttpClient();
      await expectLater(
        client
            .getUrl(Uri.parse('http://localhost:${server.port}/api/health'))
            .then((request) => request.close())
            .then((response) => response.drain<void>()),
        throwsA(anything),
      );
      client.close(force: true);
    });

    test('unbekannte Pfade liefern 404', () async {
      final client = pinnedClient(certificate.fingerprint);
      final request = await client.getUrl(
        Uri.parse('https://localhost:${server.port}/geheim'),
      );
      final response = await request.close();
      await response.drain<void>();
      client.close();
      expect(response.statusCode, 404);
    });
  });

  group('Datenordner', () {
    test('Einstellungen werden gespeichert und gelesen', () async {
      final temp = await Directory.systemTemp.createTemp('wealthflow-set-');
      final paths = ServerPaths(temp);
      expect(await ServerSettings.load(paths.settings), isNull);
      await const ServerSettings(
        dataFileDirectory: r'E:\WealthFlow',
      ).save(paths.settings);
      final loaded = await ServerSettings.load(paths.settings);
      expect(loaded!.dataFileDirectory, r'E:\WealthFlow');
      await temp.delete(recursive: true);
    });

    test('Server-Datenbank wird als Datei im Datenordner angelegt', () async {
      final temp = await Directory.systemTemp.createTemp('wealthflow-db-');
      final paths = ServerPaths(temp);
      final database = openServerDatabase(paths.database);
      await database.customSelect('SELECT 1').get();
      final mode = await database
          .customSelect('PRAGMA journal_mode')
          .getSingle();
      await database.close();
      expect(paths.database.existsSync(), isTrue);
      expect(mode.data.values.single, 'wal');
      await temp.delete(recursive: true);
    });
  });
}
