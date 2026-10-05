import 'package:drift_flutter/drift_flutter.dart';
import 'package:wealthflow_core/database/app_database.dart';

import '../storage/data_export.dart';

/// Opens the app's own database on this device (SQLite file on Android and
/// desktop, browser storage on the web).
AppDatabase openAppDatabase() => AppDatabase(
  driftDatabase(
    name: 'wealthflow',
    web: DriftWebOptions(
      sqlite3Wasm: Uri.parse('sqlite3.wasm'),
      driftWorker: Uri.parse('drift_worker.js'),
    ),
    native: const DriftNativeOptions(shareAcrossIsolates: true),
  ),
  writeDataFile: writeDataFile,
);
