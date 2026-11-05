import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_selector/file_selector.dart';
import 'package:path_provider/path_provider.dart';

export 'package:wealthflow_core/storage/data_file.dart';

/// Android has no folder picker that `dart:io` may write to (scoped
/// storage). There the app keeps its files in its own external folder,
/// which needs no permission, is visible over USB under
/// `Android/data/<app>/files` and is covered by Android's automatic backup
/// (see `android/app/src/main/res/xml`).
Future<Directory> _androidFolder() async =>
    await getExternalStorageDirectory() ??
    await getApplicationDocumentsDirectory();

Future<bool> downloadReadonlyExport(String json, String fileName) async {
  if (Platform.isAndroid) {
    final folder = await _androidFolder();
    await File(
      '${folder.path}${Platform.pathSeparator}$fileName',
    ).writeAsString(json);
    return true;
  }
  final location = await getSaveLocation(suggestedName: fileName);
  if (location == null) return false;
  final file = XFile.fromData(
    Uint8List.fromList(utf8.encode(json)),
    mimeType: 'application/json',
    name: fileName,
  );
  await file.saveTo(location.path);
  return true;
}

Future<String?> chooseDataFilePath(String fileName) async {
  if (Platform.isAndroid) {
    final folder = await _androidFolder();
    return '${folder.path}${Platform.pathSeparator}$fileName';
  }
  final directory = await getDirectoryPath(
    confirmButtonText: 'Diesen Ordner verwenden',
  );
  if (directory == null) return null;
  final separator = directory.endsWith('/') || directory.endsWith(r'\')
      ? ''
      : Platform.pathSeparator;
  return directory + separator + fileName;
}

Future<Uint8List?> chooseDataImport() async {
  final file = await openFile(
    acceptedTypeGroups: const [
      XTypeGroup(
        label: 'WealthFlow-Datei',
        extensions: ['wflow2', 'wflow', 'json'],
      ),
    ],
  );
  return file?.readAsBytes();
}

/// Saves a transfer file. Android keeps it in the app's own folder (see
/// [_androidFolder]); returns the path, or null when cancelled.
Future<String?> saveTransferFile(Uint8List bytes, String fileName) async {
  if (Platform.isAndroid) {
    final folder = await _androidFolder();
    final path = '${folder.path}${Platform.pathSeparator}$fileName';
    await File(path).writeAsBytes(bytes, flush: true);
    return path;
  }
  final location = await getSaveLocation(
    suggestedName: fileName,
    acceptedTypeGroups: const [
      XTypeGroup(label: 'WealthFlow-Datei', extensions: ['wflow2']),
    ],
  );
  if (location == null) return null;
  await File(location.path).writeAsBytes(bytes, flush: true);
  return location.path;
}
