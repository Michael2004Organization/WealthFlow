// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use

import 'dart:async';
import 'dart:html' as html;

Future<bool> downloadReadonlyExport(String json, String fileName) async {
  final blob = html.Blob([json], 'application/json;charset=utf-8');
  final url = html.Url.createObjectUrlFromBlob(blob);
  html.AnchorElement(href: url)
    ..download = fileName
    ..click();
  html.Url.revokeObjectUrl(url);
  return true;
}

Future<String?> chooseDataFilePath(String fileName) async => null;

Future<bool> writeDataFile(String json, String path) async => false;

Future<String?> chooseDataImport() async {
  final input = html.FileUploadInputElement()
    ..accept = '.json,application/json';
  final completer = Completer<String?>();
  input.onChange.first.then((_) {
    final file = input.files?.firstOrNull;
    if (file == null) {
      completer.complete(null);
      return;
    }
    final reader = html.FileReader();
    reader.onLoad.first.then(
      (_) => completer.complete(reader.result as String?),
    );
    reader.onError.first.then((_) => completer.complete(null));
    reader.readAsText(file);
  });
  input.click();
  return completer.future;
}
