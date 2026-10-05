import 'dart:io';

import 'package:drift/native.dart';
import 'package:wealthflow_core/database/app_database.dart';
import 'package:wealthflow_core/storage/data_file.dart';

/// Opens the server's SQLite file. Only this process uses the file, so WAL
/// mode keeps reads fast while a write is running and survives a closed
/// window without a broken database.
AppDatabase openServerDatabase(File file) => AppDatabase(
  NativeDatabase.createInBackground(
    file,
    setup: (database) {
      database.execute('PRAGMA journal_mode = WAL;');
      database.execute('PRAGMA foreign_keys = ON;');
    },
  ),
  writeDataFile: writeDataFile,
);
