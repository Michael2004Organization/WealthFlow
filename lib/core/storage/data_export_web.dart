// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use

import 'dart:async';
import 'dart:html' as html;
import 'dart:typed_data';

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

Future<bool> writeDataFile(List<int> bytes, String path) async => false;

Future<String?> saveTransferFile(Uint8List bytes, String fileName) async {
  final blob = html.Blob([bytes], 'application/octet-stream');
  final url = html.Url.createObjectUrlFromBlob(blob);
  html.AnchorElement(href: url)
    ..download = fileName
    ..click();
  html.Url.revokeObjectUrl(url);
  return fileName;
}

Future<Uint8List?> chooseDataImport() => _chooseFile(
  '.wflow2,.wflow,.json,application/json,application/octet-stream',
);

/// Lets the user pick a bank's CSV export.
Future<Uint8List?> chooseCsvFile() => _chooseFile('.csv,.txt,text/csv');

Future<Uint8List?> _chooseFile(String accept) async {
  final input = html.FileUploadInputElement()..accept = accept;
  final completer = Completer<Uint8List?>();
  input.onChange.first.then((_) {
    final file = input.files?.firstOrNull;
    if (file == null) {
      completer.complete(null);
      return;
    }
    final reader = html.FileReader();
    reader.onLoad.first.then(
      (_) => completer.complete(switch (reader.result) {
        final ByteBuffer buffer => buffer.asUint8List(),
        final Uint8List bytes => bytes,
        _ => null,
      }),
    );
    reader.onError.first.then((_) => completer.complete(null));
    reader.readAsArrayBuffer(file);
  });
  input.click();
  return completer.future;
}
