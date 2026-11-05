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

Future<String?> chooseDataImport() async {
  final file = await openFile(
    acceptedTypeGroups: const [
      XTypeGroup(label: 'WealthFlow JSON', extensions: ['json']),
      XTypeGroup(
        label: 'Verschlüsselte WealthFlow-Datei',
        extensions: ['wflow'],
      ),
    ],
  );
  return file?.readAsString();
}
