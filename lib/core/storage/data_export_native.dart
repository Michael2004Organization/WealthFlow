import 'dart:convert';
import 'dart:typed_data';

import 'package:file_selector/file_selector.dart';

Future<bool> downloadReadonlyExport(String json, String fileName) async {
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
  final location = await getSaveLocation(suggestedName: fileName);
  return location?.path;
}

Future<bool> writeDataFile(String json, String path) async {
  if (path.trim().isEmpty) return false;
  final file = XFile.fromData(
    Uint8List.fromList(utf8.encode(json)),
    mimeType: 'application/json',
    name: path.split(RegExp(r'[/\\]')).last,
  );
  await file.saveTo(path);
  return true;
}

Future<String?> chooseDataImport() async {
  final file = await openFile(
    acceptedTypeGroups: const [
      XTypeGroup(label: 'WealthFlow JSON', extensions: ['json']),
    ],
  );
  return file?.readAsString();
}
