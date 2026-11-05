import 'dart:io';

import 'package:path_provider/path_provider.dart';

const _fileName = 'wealthflow.sqlite';

/// Where the app database lives on this device.
///
/// Windows keeps it in `%APPDATA%\WealthFlow` instead of the Documents
/// folder, where cloud sync tools (OneDrive) and users can lock or copy a
/// half-written database. A database from an earlier version is moved there
/// on the first start. Other platforms keep the private documents folder.
Future<String?> appDatabasePath() async {
  final documents = await getApplicationDocumentsDirectory();
  final appData = Platform.isWindows ? Platform.environment['APPDATA'] : null;
  if (appData == null || appData.isEmpty) {
    return '${documents.path}${Platform.pathSeparator}$_fileName';
  }
  final folder = Directory('$appData${Platform.pathSeparator}WealthFlow');
  await folder.create(recursive: true);
  final target = '${folder.path}${Platform.pathSeparator}$_fileName';
  final legacy = '${documents.path}${Platform.pathSeparator}$_fileName';
  try {
    await moveLegacyDatabase(from: legacy, to: target);
  } on FileSystemException {
    return legacy;
  }
  return target;
}

/// Moves the database file and its journal files from [from] to [to], unless
/// [to] already exists. A failed move leaves the old database in place, so
/// the app falls back to it instead of starting empty.
Future<void> moveLegacyDatabase({
  required String from,
  required String to,
}) async {
  if (File(to).existsSync() || !File(from).existsSync()) return;
  const suffixes = ['', '-wal', '-shm', '-journal'];
  final copied = <File>[];
  try {
    for (final suffix in suffixes) {
      final source = File('$from$suffix');
      if (!source.existsSync()) continue;
      // Copy to a temporary name first so an interrupted move never leaves
      // a partial database at the new location.
      copied.add(await source.copy('$to$suffix.tmp'));
    }
    for (final file in copied) {
      await file.rename(file.path.substring(0, file.path.length - 4));
    }
  } catch (_) {
    for (final suffix in suffixes) {
      for (final path in ['$to$suffix.tmp', '$to$suffix']) {
        final file = File(path);
        if (file.existsSync()) await file.delete();
      }
    }
    rethrow;
  }
  for (final suffix in suffixes) {
    try {
      final old = File('$from$suffix');
      if (old.existsSync()) await old.delete();
    } on FileSystemException {
      // The copy is complete; a leftover old file does no harm.
    }
  }
}
