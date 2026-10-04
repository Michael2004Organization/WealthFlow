import 'package:intl/intl.dart';

/// What a data file contains, shown before it is merged into the database.
final class ImportPreview {
  const ImportPreview({
    required this.exportedAt,
    required this.sourceName,
    required this.accounts,
    required this.ledgerEntries,
    required this.investments,
    required this.vehicles,
    required this.reminders,
  });

  factory ImportPreview.fromData(Map<String, dynamic> data) {
    int count(String key) =>
        (data[key] as List<dynamic>? ?? const []).whereType<Map>().where((row) {
          return row['deletedAt'] == null;
        }).length;
    final user = data['user'];
    return ImportPreview(
      exportedAt: DateTime.tryParse(data['exportedAt'] as String? ?? ''),
      sourceName: user is Map
          ? (user['displayName'] as String? ?? user['email'] as String? ?? '')
          : '',
      accounts: count('accounts'),
      ledgerEntries: count('ledgerEntries'),
      investments: count('investments'),
      vehicles: count('vehicles'),
      reminders: count('reminders'),
    );
  }

  final DateTime? exportedAt;
  final String sourceName;
  final int accounts;
  final int ledgerEntries;
  final int investments;
  final int vehicles;
  final int reminders;

  String describe() {
    final buffer = StringBuffer();
    if (exportedAt != null) {
      buffer.writeln(
        'Gesichert am ${DateFormat('dd.MM.yyyy HH:mm', 'de_DE').format(exportedAt!.toLocal())}'
        '${sourceName.isEmpty ? '' : ' von $sourceName'}.',
      );
      buffer.writeln();
    }
    buffer
      ..writeln('$accounts Konten')
      ..writeln('$ledgerEntries Buchungen')
      ..writeln('$investments Depotpositionen')
      ..writeln('$vehicles Fahrzeuge')
      ..writeln('$reminders Erinnerungen')
      ..writeln()
      ..write(
        'Die Daten werden mit deinen vorhandenen Daten zusammengeführt. '
        'Bei gleichen Einträgen gilt jeweils die neuere Fassung.',
      );
    return buffer.toString();
  }
}
