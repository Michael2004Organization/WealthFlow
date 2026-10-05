import 'dart:io';

import 'package:drift/native.dart';
import 'package:shelf/shelf.dart';
import 'package:test/test.dart';
import 'package:wealthflow_core/database/app_database.dart';
import 'package:wealthflow_server/wealthflow_server.dart';

void main() {
  late Directory root;
  late Directory web;
  late AppDatabase database;
  late Handler handler;

  setUp(() async {
    root = await Directory.systemTemp.createTemp('wealthflow-web');
    web = await Directory('${root.path}/web').create();
    await File('${web.path}/index.html').writeAsString('<html>App</html>');
    await File('${web.path}/main.dart.js').writeAsString('main();');
    await File('${web.path}/sqlite3.wasm').writeAsBytes([0, 97, 115, 109]);
    await File('${root.path}/geheim.txt').writeAsString('geheim');
    database = AppDatabase(NativeDatabase.memory());
    final access = ServerAccess(database, certificateFingerprint: 'AA' * 32);
    await access.initialize();
    handler = buildHandler(
      database: database,
      access: access,
      sync: ServerSync(database, settings: const ServerSettings()),
      webApp: WebApp(web),
    );
  });

  tearDown(() async {
    await database.close();
    await root.delete(recursive: true);
  });

  Future<Response> get(String path) async =>
      await handler(Request('GET', Uri.parse('https://localhost:8443$path')));

  test('liefert die Web-App mit sicheren Headern aus', () async {
    final response = await get('/');
    expect(response.statusCode, 200);
    expect(await response.readAsString(), '<html>App</html>');
    expect(response.headers['content-type'], startsWith('text/html'));
    expect(response.headers['cross-origin-opener-policy'], 'same-origin');
    expect(response.headers['cross-origin-embedder-policy'], 'require-corp');
    expect(
      response.headers['content-security-policy'],
      contains("script-src 'self' 'wasm-unsafe-eval'"),
    );
    expect(response.headers['strict-transport-security'], isNotNull);
  });

  test('richtige Typen für Skript und WebAssembly', () async {
    expect(
      (await get('/main.dart.js')).headers['content-type'],
      startsWith('text/javascript'),
    );
    expect(
      (await get('/sqlite3.wasm')).headers['content-type'],
      'application/wasm',
    );
  });

  test('App-Seiten bekommen index.html, fehlende Dateien 404', () async {
    final page = await get('/einstellungen');
    expect(page.statusCode, 200);
    expect(await page.readAsString(), '<html>App</html>');
    expect((await get('/fehlt.js')).statusCode, 404);
  });

  test('kein Zugriff außerhalb des web-Ordners', () async {
    for (final path in ['/%2E%2E/geheim.txt', '/..%2Fgeheim.txt', '/.env']) {
      final response = await get(path);
      expect(await response.readAsString(), isNot('geheim'), reason: path);
      expect(response.statusCode, anyOf(404, 400), reason: path);
    }
  });

  test('API bleibt geschützt und unberührt', () async {
    expect((await get('/api/me')).statusCode, 401);
    expect((await get('/api/health')).statusCode, 200);
  });

  test('ohne web-Ordner ein Hinweis statt Absturz', () async {
    await web.delete(recursive: true);
    final response = await get('/');
    expect(response.statusCode, 404);
    expect(await response.readAsString(), contains('web'));
  });
}
