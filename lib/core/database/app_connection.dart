import 'package:drift_flutter/drift_flutter.dart';
import 'package:wealthflow_core/database/app_database.dart';

import '../storage/data_export.dart';
import 'database_location.dart';

/// Opens the app's own database on this device (SQLite file on Android and
/// desktop, browser storage on the web). See [appDatabasePath].
AppDatabase openAppDatabase() => AppDatabase(
  driftDatabase(
    name: 'wealthflow',
    web: DriftWebOptions(
      sqlite3Wasm: Uri.parse('sqlite3.wasm'),
      driftWorker: Uri.parse('drift_worker.js'),
    ),
    native: DriftNativeOptions(
      shareAcrossIsolates: true,
      databasePath: _databasePath,
    ),
  ),
  writeDataFile: writeDataFile,
);

Future<String> _databasePath() async {
  final path = await appDatabasePath();
  if (path == null) throw UnsupportedError('Kein Dateipfad im Browser');
  return path;
}
