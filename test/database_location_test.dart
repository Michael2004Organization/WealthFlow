import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:wealthflow/core/database/database_location_native.dart';

void main() {
  late Directory root;

  setUp(() async {
    root = await Directory.systemTemp.createTemp('wealthflow-location');
  });

  tearDown(() => root.delete(recursive: true));

  String path(String name) => '${root.path}${Platform.pathSeparator}$name';

  test('moves the database and its journal to the new folder', () async {
    await File(path('old.sqlite')).writeAsString('db');
    await File(path('old.sqlite-wal')).writeAsString('wal');

    await moveLegacyDatabase(from: path('old.sqlite'), to: path('new.sqlite'));

    expect(await File(path('new.sqlite')).readAsString(), 'db');
    expect(await File(path('new.sqlite-wal')).readAsString(), 'wal');
    expect(File(path('old.sqlite')).existsSync(), isFalse);
    expect(File(path('old.sqlite-wal')).existsSync(), isFalse);
    expect(File(path('new.sqlite.tmp')).existsSync(), isFalse);
  });

  test('keeps an existing database at the new location', () async {
    await File(path('old.sqlite')).writeAsString('old');
    await File(path('new.sqlite')).writeAsString('new');

    await moveLegacyDatabase(from: path('old.sqlite'), to: path('new.sqlite'));

    expect(await File(path('new.sqlite')).readAsString(), 'new');
    expect(File(path('old.sqlite')).existsSync(), isTrue);
  });
}
