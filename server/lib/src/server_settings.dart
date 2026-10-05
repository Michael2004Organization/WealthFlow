import 'dart:convert';
import 'dart:io';

/// Settings chosen on the first start, stored as `einstellungen.json`.
final class ServerSettings {
  const ServerSettings({this.dataFileDirectory = ''});

  /// Folder for the additional encrypted data file; empty means none.
  final String dataFileDirectory;

  Map<String, Object?> toJson() => {'datendateiOrdner': dataFileDirectory};

  factory ServerSettings.fromJson(Map<String, Object?> json) => ServerSettings(
    dataFileDirectory: json['datendateiOrdner'] as String? ?? '',
  );

  static Future<ServerSettings?> load(File file) async {
    if (!await file.exists()) return null;
    final decoded = jsonDecode(await file.readAsString());
    if (decoded is! Map) return null;
    return ServerSettings.fromJson(Map<String, Object?>.from(decoded));
  }

  Future<void> save(File file) async {
    await file.parent.create(recursive: true);
    await file.writeAsString(
      const JsonEncoder.withIndent('  ').convert(toJson()),
      flush: true,
    );
  }
}
