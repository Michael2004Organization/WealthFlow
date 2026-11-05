import 'dart:convert';

/// One transaction from a bank's CSV export. [amount] is signed: negative
/// for money that left the account.
class BankCsvRow {
  const BankCsvRow({
    required this.date,
    required this.amount,
    required this.counterparty,
    required this.purpose,
  });

  final DateTime date;
  final double amount;
  final String counterparty;
  final String purpose;
}

/// Which column holds what; indices into a row of [BankCsvTable.rows].
class BankCsvMapping {
  const BankCsvMapping({
    required this.date,
    required this.amount,
    this.counterparty,
    this.counterpartyIncoming,
    this.purpose,
    this.status,
  });

  final int date;
  final int amount;

  /// Payee, or for DKB the payee of outgoing payments.
  final int? counterparty;

  /// DKB names the payer in its own column for incoming money.
  final int? counterpartyIncoming;
  final int? purpose;

  /// DKB marks pending bookings as "Vorgemerkt"; those are skipped.
  final int? status;
}

/// The cells of a CSV file below its header line.
class BankCsvTable {
  const BankCsvTable({
    required this.header,
    required this.rows,
    required this.bank,
    required this.mapping,
  });

  final List<String> header;
  final List<List<String>> rows;

  /// Name of the recognised bank, or null for an unknown layout.
  final String? bank;

  /// Detected columns, or null when the user has to assign them.
  final BankCsvMapping? mapping;

  /// The transactions read with [mapping]; rows that do not parse are left
  /// out (sums, empty lines, pending bookings).
  List<BankCsvRow> read([BankCsvMapping? override]) {
    final columns = override ?? mapping;
    if (columns == null) return const [];
    String cell(List<String> row, int? index) =>
        index == null || index >= row.length ? '' : row[index].trim();
    final result = <BankCsvRow>[];
    for (final row in rows) {
      if (cell(row, columns.status).toLowerCase().startsWith('vorgemerkt')) {
        continue;
      }
      final date = parseBankDate(cell(row, columns.date));
      final amount = parseBankAmount(cell(row, columns.amount));
      if (date == null || amount == null || amount == 0) continue;
      final incoming = cell(row, columns.counterpartyIncoming);
      var counterparty = amount > 0 && incoming.isNotEmpty
          ? incoming
          : cell(row, columns.counterparty);
      var purpose = cell(row, columns.purpose);
      // comdirect writes "Auftraggeber: X Buchungstext: Y" into one cell.
      final named = RegExp(
        r'(?:Empfänger|Auftraggeber):\s*(.+?)\s*(?:Kto/IBAN:.*?)?(?:Buchungstext:\s*(.*))?$',
      ).firstMatch(purpose);
      if (counterparty.isEmpty && named != null) {
        counterparty = named[1]!;
        purpose = named[2] ?? '';
      }
      result.add(
        BankCsvRow(
          date: date,
          amount: amount,
          counterparty: _collapse(counterparty),
          purpose: _collapse(purpose),
        ),
      );
    }
    return result;
  }
}

/// Reads the bytes of a bank export. Handles UTF-8 with or without BOM and
/// Windows-1252/Latin-1 (Sparkasse, Volksbank), `;` or `,` as separator and
/// the lines some banks put above the header (ING, DKB).
BankCsvTable parseBankCsv(List<int> bytes) {
  final text = _decode(bytes);
  final lines = const LineSplitter()
      .convert(text)
      .where((line) => line.trim().isNotEmpty)
      .toList();
  if (lines.isEmpty) {
    throw const FormatException('Die Datei ist leer.');
  }
  // The header is the first line that names a date and an amount column.
  var headerIndex = lines.indexWhere((line) {
    final lower = line.toLowerCase();
    return (lower.contains('buchung') || lower.contains('datum')) &&
        (lower.contains('betrag') || lower.contains('umsatz'));
  });
  if (headerIndex < 0) headerIndex = 0;
  final headerLine = lines[headerIndex];
  final separator =
      ';'.allMatches(headerLine).length >= ','.allMatches(headerLine).length
      ? ';'
      : ',';
  final header = _split(headerLine, separator);
  final rows = [
    for (final line in lines.skip(headerIndex + 1)) _split(line, separator),
  ];
  final detected = _detect(header);
  return BankCsvTable(
    header: header,
    rows: rows,
    bank: detected?.bank,
    mapping: detected?.mapping,
  );
}

({String? bank, BankCsvMapping mapping})? _detect(List<String> header) {
  final names = [for (final name in header) _normalize(name)];
  int? find(List<String> candidates) {
    for (final candidate in candidates) {
      final index = names.indexOf(_normalize(candidate));
      if (index >= 0) return index;
    }
    return null;
  }

  final has = names.toSet().contains;
  final bank = has('beguenstigterzahlungspflichtiger')
      ? 'Sparkasse'
      : has('auftraggeberempfaenger')
      ? 'ING'
      : has('zahlungsempfaengerin') || has('auftraggeberbeguenstigter')
      ? 'DKB'
      : has('umsatzineur') || has('vorgang')
      ? 'comdirect'
      : has('namezahlungsbeteiligter')
      ? 'Volksbank'
      : null;
  final date = find(['Buchungstag', 'Buchungsdatum', 'Buchung', 'Datum']);
  final amount = find([
    'Betrag',
    'Betrag (€)',
    'Betrag (EUR)',
    'Umsatz in EUR',
    'Umsatz',
  ]);
  if (date == null || amount == null) return null;
  final payee = find([
    'Beguenstigter/Zahlungspflichtiger',
    'Begünstigter/Zahlungspflichtiger',
    'Auftraggeber/Empfänger',
    'Name Zahlungsbeteiligter',
    'Zahlungsempfänger*in',
    'Auftraggeber / Begünstigter',
    'Empfänger',
    'Name',
  ]);
  final purpose = find(['Verwendungszweck', 'Buchungstext']);
  return (
    bank: bank,
    mapping: BankCsvMapping(
      date: date,
      amount: amount,
      counterparty: payee ?? (bank == 'comdirect' ? null : find(['Vorgang'])),
      counterpartyIncoming: find(['Zahlungspflichtige*r']),
      purpose: purpose,
      status: find(['Status']),
    ),
  );
}

/// German or plain amounts: `-1.234,56`, `1234.56`, `12,50 €`, `+3,00`.
double? parseBankAmount(String input) {
  var value = input.replaceAll(RegExp(r'[^0-9,.\-+]'), '');
  if (value.isEmpty) return null;
  final comma = value.lastIndexOf(',');
  final dot = value.lastIndexOf('.');
  if (comma > dot) {
    value = value.replaceAll('.', '').replaceAll(',', '.');
  } else if (dot > comma && comma >= 0) {
    value = value.replaceAll(',', '');
  }
  return double.tryParse(value);
}

/// `31.12.2026`, `31.12.26` or `2026-12-31`.
DateTime? parseBankDate(String input) {
  final german = RegExp(r'^(\d{1,2})\.(\d{1,2})\.(\d{2,4})$').firstMatch(input);
  if (german != null) {
    var year = int.parse(german[3]!);
    if (year < 100) year += 2000;
    return _validDate(year, int.parse(german[2]!), int.parse(german[1]!));
  }
  final iso = RegExp(r'^(\d{4})-(\d{2})-(\d{2})').firstMatch(input);
  if (iso != null) {
    return _validDate(
      int.parse(iso[1]!),
      int.parse(iso[2]!),
      int.parse(iso[3]!),
    );
  }
  return null;
}

DateTime? _validDate(int year, int month, int day) {
  final date = DateTime(year, month, day);
  return date.month == month && date.day == day ? date : null;
}

String _decode(List<int> bytes) {
  var data = bytes;
  if (data.length >= 3 &&
      data[0] == 0xEF &&
      data[1] == 0xBB &&
      data[2] == 0xBF) {
    data = data.sublist(3);
  }
  try {
    return utf8.decode(data);
  } on FormatException {
    return latin1.decode(data);
  }
}

/// Splits one CSV line; quoted cells may hold the separator and `""`.
List<String> _split(String line, String separator) {
  final cells = <String>[];
  final cell = StringBuffer();
  var quoted = false;
  for (var index = 0; index < line.length; index++) {
    final char = line[index];
    if (char == '"') {
      if (quoted && index + 1 < line.length && line[index + 1] == '"') {
        cell.write('"');
        index++;
      } else {
        quoted = !quoted;
      }
    } else if (char == separator && !quoted) {
      cells.add(cell.toString());
      cell.clear();
    } else {
      cell.write(char);
    }
  }
  cells.add(cell.toString());
  return cells;
}

String _normalize(String name) => name
    .toLowerCase()
    .replaceAll('ä', 'ae')
    .replaceAll('ö', 'oe')
    .replaceAll('ü', 'ue')
    .replaceAll('ß', 'ss')
    .replaceAll(RegExp(r'[^a-z]'), '');

String _collapse(String value) => value.replaceAll(RegExp(r'\s+'), ' ').trim();
