/// Trade Republic "Transaktionsexport" (CSV, since app 4.2616, April 2026).
///
/// There is no official format document. Columns are therefore found by
/// name (English export names and German variants), the delimiter is
/// detected (comma or semicolon) and unknown row types are counted, not
/// guessed. Known layout: datetime, date, account_type, category, type,
/// asset_class, name, symbol (the ISIN), shares, price, amount, fee, tax,
/// currency, original_amount, original_currency, fx_rate, description,
/// transaction_id, … Amounts are signed (negative = money out), fees and
/// taxes are separate columns on the same row, sells have negative shares.
library;

enum BrokerTransactionKind { buy, sell, dividend }

class BrokerTransaction {
  const BrokerTransaction({
    required this.kind,
    required this.id,
    required this.date,
    required this.isin,
    required this.name,
    required this.assetType,
    required this.shares,
    required this.price,
    required this.amount,
    required this.fee,
    required this.tax,
  });

  final BrokerTransactionKind kind;

  /// Stable id of the broker, used to skip rows imported before.
  final String id;
  final DateTime date;
  final String isin;
  final String name;

  /// App asset type: Aktie, ETF, Kryptowährung, Anleihe.
  final String assetType;

  /// Always positive.
  final double shares;

  /// Price per share in EUR, always positive.
  final double price;

  /// Gross value in EUR (Kurswert or gross dividend), always positive.
  final double amount;

  /// Fees in EUR, always positive.
  final double fee;

  /// Taxes in EUR: positive when paid, negative when refunded.
  final double tax;

  /// Money that reached the account for a dividend: gross minus tax and fee.
  double get netAmount => amount - tax - fee;
}

class BrokerCsvResult {
  const BrokerCsvResult({
    required this.transactions,
    required this.skippedTypes,
    this.error,
  });

  final List<BrokerTransaction> transactions;

  /// Row types the import does not handle (deposits, card payments, …)
  /// with their count.
  final Map<String, int> skippedTypes;

  /// Set when the file is not a Trade Republic export.
  final String? error;

  int get skipped => skippedTypes.values.fold(0, (sum, count) => sum + count);
}

const _buyTypes = {
  'BUY',
  'SAVINGS_PLAN_EXECUTED',
  'SAVINGS_PLAN',
  'SAVEBACK',
  'ROUND_UP',
  'KAUF',
  'SPARPLAN',
  'SPARPLAN AUSGEFÜHRT',
};
const _sellTypes = {'SELL', 'VERKAUF'};
const _dividendTypes = {
  'DIVIDEND',
  'DISTRIBUTION',
  'DIVIDENDE',
  'AUSSCHÜTTUNG',
  'CASH_DIVIDEND',
};

/// Column names per field, first match wins.
const _columns = {
  'date': ['date', 'datum', 'buchungstag'],
  'datetime': ['datetime', 'zeitpunkt'],
  'type': ['type', 'typ', 'art'],
  'account': ['account_type', 'kontotyp'],
  'assetClass': ['asset_class', 'anlageklasse'],
  'name': ['name', 'wertpapier', 'bezeichnung'],
  'isin': ['symbol', 'isin'],
  'shares': ['shares', 'stück', 'stueck', 'anzahl'],
  'price': ['price', 'kurs', 'preis'],
  'amount': ['amount', 'betrag'],
  'fee': ['fee', 'gebühr', 'gebuehr', 'gebühren'],
  'tax': ['tax', 'steuer', 'steuern'],
  'id': ['transaction_id', 'id', 'transaktions-id'],
};

BrokerCsvResult parseTradeRepublicCsv(String text) {
  final lines = text
      .replaceFirst('﻿', '')
      .split(RegExp(r'\r?\n'))
      .where((line) => line.trim().isNotEmpty)
      .toList();
  if (lines.isEmpty) {
    return const BrokerCsvResult(
      transactions: [],
      skippedTypes: {},
      error: 'Die Datei ist leer.',
    );
  }
  final delimiter =
      ';'.allMatches(lines.first).length > ','.allMatches(lines.first).length
      ? ';'
      : ',';
  final header = [
    for (final cell in splitCsvLine(lines.first, delimiter))
      cell.trim().toLowerCase(),
  ];
  int? column(String field) {
    for (final name in _columns[field]!) {
      final index = header.indexOf(name);
      if (index >= 0) return index;
    }
    return null;
  }

  final indices = {for (final field in _columns.keys) field: column(field)};
  final missing = [
    for (final field in const ['type', 'isin', 'shares', 'amount'])
      if (indices[field] == null) field,
  ];
  if (missing.isNotEmpty || (indices['date'] ?? indices['datetime']) == null) {
    return const BrokerCsvResult(
      transactions: [],
      skippedTypes: {},
      error:
          'Das ist kein Trade-Republic-Transaktionsexport. Erwartet werden '
          'Spalten wie date, type, symbol, shares und amount.',
    );
  }

  final transactions = <BrokerTransaction>[];
  final skipped = <String, int>{};
  for (var i = 1; i < lines.length; i++) {
    final cells = splitCsvLine(lines[i], delimiter);
    String cell(String field) {
      final index = indices[field];
      return index == null || index >= cells.length ? '' : cells[index].trim();
    }

    final type = cell('type').toUpperCase();
    // Junior depots belong to a child, not to this portfolio.
    if (cell('account').toUpperCase() == 'JUNIOR') {
      skipped.update('Junior-Depot', (count) => count + 1, ifAbsent: () => 1);
      continue;
    }
    final kind = _buyTypes.contains(type)
        ? BrokerTransactionKind.buy
        : _sellTypes.contains(type)
        ? BrokerTransactionKind.sell
        : _dividendTypes.contains(type)
        ? BrokerTransactionKind.dividend
        : null;
    final date = _date(cell('date')) ?? _date(cell('datetime'));
    final isin = cell('isin').toUpperCase();
    final shares = (_number(cell('shares')) ?? 0).abs();
    final amount = (_number(cell('amount')) ?? 0).abs();
    if (kind == null || date == null || isin.isEmpty) {
      final label = type.isEmpty ? 'Ohne Typ' : type;
      skipped.update(label, (count) => count + 1, ifAbsent: () => 1);
      continue;
    }
    if (kind != BrokerTransactionKind.dividend && shares <= 0) {
      skipped.update(type, (count) => count + 1, ifAbsent: () => 1);
      continue;
    }
    final price = (_number(cell('price')) ?? 0).abs();
    final id = cell('id');
    transactions.add(
      BrokerTransaction(
        kind: kind,
        id: id.isNotEmpty
            ? id
            : '${date.toIso8601String()}|$type|$isin|$shares|$amount',
        date: date,
        isin: isin,
        name: cell('name').isEmpty ? isin : cell('name'),
        assetType: _assetType(cell('assetClass')),
        shares: shares,
        price: price > 0 ? price : (shares > 0 ? amount / shares : 0),
        amount: amount,
        fee: (_number(cell('fee')) ?? 0).abs(),
        // Exported negative when paid, positive for a refund.
        tax: -(_number(cell('tax')) ?? 0),
      ),
    );
  }
  transactions.sort((a, b) => a.date.compareTo(b.date));
  return BrokerCsvResult(transactions: transactions, skippedTypes: skipped);
}

String _assetType(String assetClass) => switch (assetClass.toUpperCase()) {
  'FUND' || 'ETF' || 'FONDS' => 'ETF',
  'CRYPTO' || 'KRYPTO' => 'Kryptowährung',
  'BOND' || 'ANLEIHE' => 'Anleihe',
  _ => 'Aktie',
};

DateTime? _date(String value) {
  if (value.isEmpty) return null;
  final iso = DateTime.tryParse(value);
  if (iso != null) {
    // "date" is the local booking day; a UTC timestamp is moved to it.
    final local = iso.isUtc ? iso.toLocal() : iso;
    return DateTime(local.year, local.month, local.day);
  }
  final german = RegExp(r'^(\d{1,2})\.(\d{1,2})\.(\d{4})').firstMatch(value);
  if (german == null) return null;
  return DateTime(
    int.parse(german.group(3)!),
    int.parse(german.group(2)!),
    int.parse(german.group(1)!),
  );
}

/// Dot decimals as exported; German "1.234,56" is accepted too.
double? _number(String value) {
  var text = value.replaceAll(RegExp(r'[\s€]'), '');
  if (text.isEmpty) return null;
  if (text.contains(',')) {
    text = text.replaceAll('.', '').replaceAll(',', '.');
  }
  return double.tryParse(text);
}

/// Splits one CSV line; double quotes enclose cells and "" is a quote.
List<String> splitCsvLine(String line, String delimiter) {
  final cells = <String>[];
  final buffer = StringBuffer();
  var quoted = false;
  for (var i = 0; i < line.length; i++) {
    final char = line[i];
    if (quoted) {
      if (char == '"') {
        if (i + 1 < line.length && line[i + 1] == '"') {
          buffer.write('"');
          i++;
        } else {
          quoted = false;
        }
      } else {
        buffer.write(char);
      }
    } else if (char == '"') {
      quoted = true;
    } else if (char == delimiter) {
      cells.add(buffer.toString());
      buffer.clear();
    } else {
      buffer.write(char);
    }
  }
  cells.add(buffer.toString());
  return cells;
}
