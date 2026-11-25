import '../database/app_database.dart';

/// A booking read from one line of text, e.g. "12,50 Bäcker bar" or
/// "+3250 Gehalt giro".
class QuickEntry {
  const QuickEntry({
    required this.amount,
    required this.income,
    required this.merchant,
    required this.category,
    required this.paymentMethod,
    required this.date,
    required this.categoryLearned,
  });

  final double amount;
  final bool income;
  final String merchant;
  final String category;
  final String paymentMethod;
  final DateTime date;

  /// The category comes from an earlier booking at the same merchant.
  final bool categoryLearned;

  /// One line for the preview below the input field.
  String get summary {
    final parts = [
      income ? 'Einnahme' : 'Ausgabe',
      if (merchant.isNotEmpty) merchant,
      category,
      if (paymentMethod.isNotEmpty) paymentMethod,
    ];
    return parts.join(' · ');
  }
}

/// Short words that mean a payment method.
const _paymentAliases = {
  'bar': 'Bar',
  'cash': 'Bar',
  'karte': 'Karte',
  'ec': 'Girokarte',
  'giro': 'Girokarte',
  'girokarte': 'Girokarte',
  'kk': 'Kreditkarte',
  'kredit': 'Kreditkarte',
  'kreditkarte': 'Kreditkarte',
  'paypal': 'PayPal',
  'lastschrift': 'Lastschrift',
  'überweisung': 'Überweisung',
};

final _amountPattern = RegExp(
  r'^([+-]?)(\d{1,3}(?:\.\d{3})*|\d+)(?:,(\d{1,2}))?(?:€|eur)?$',
);
final _dotDecimal = RegExp(r'^([+-]?)(\d+)\.(\d{1,2})(?:€|eur)?$');

/// Reads [input]; null when it holds no amount.
///
/// * The first number is the amount (`12,50`, `12.50`, `1.250`); a leading
///   `+` makes it income.
/// * `heute`, `gestern`, `vorgestern` set the date.
/// * A word naming one of [paymentMethods] (or a short form like `bar`,
///   `kk`, `giro`) sets the payment method.
/// * A word naming one of [categories] sets the category.
/// * The remaining words are the merchant. Without a category word, the
///   category of the latest booking at that merchant in [history] is used,
///   else `Sonstiges`.
QuickEntry? parseQuickEntry(
  String input, {
  required DateTime today,
  Iterable<String> paymentMethods = const [],
  Iterable<String> categories = const [],
  Iterable<LedgerEntry> history = const [],
}) {
  final words = input.trim().split(RegExp(r'\s+'));
  double? amount;
  var income = false;
  var date = DateTime(today.year, today.month, today.day);
  String? payment;
  String? category;
  final rest = <String>[];

  String? findIn(Iterable<String> options, String word) {
    final lower = word.toLowerCase();
    for (final option in options) {
      if (option.toLowerCase() == lower) return option;
    }
    return null;
  }

  for (final word in words) {
    if (word.isEmpty) continue;
    final lower = word.toLowerCase();
    if (amount == null) {
      final parsed = _parseAmount(lower);
      if (parsed != null) {
        amount = parsed.$1.abs();
        income = parsed.$2;
        continue;
      }
    }
    if (lower == 'heute') continue;
    if (lower == 'gestern' || lower == 'vorgestern') {
      date = date.subtract(Duration(days: lower == 'gestern' ? 1 : 2));
      continue;
    }
    if (payment == null) {
      final known = findIn(paymentMethods, word);
      final alias = _paymentAliases[lower];
      if (known != null || alias != null) {
        // Prefer the user's own spelling of the method.
        payment = known ?? findIn(paymentMethods, alias!) ?? alias;
        continue;
      }
    }
    if (category == null) {
      final known = findIn(categories, word);
      if (known != null) {
        category = known;
        continue;
      }
    }
    rest.add(word);
  }
  if (amount == null || amount == 0) return null;

  final merchant = rest.join(' ');
  var learned = false;
  if (category == null && merchant.isNotEmpty) {
    final lower = merchant.toLowerCase();
    final previous = history
        .where(
          (entry) =>
              entry.deletedAt == null &&
              entry.isIncome == income &&
              (entry.merchant.toLowerCase() == lower ||
                  entry.description.toLowerCase() == lower),
        )
        .fold<LedgerEntry?>(
          null,
          (latest, entry) =>
              latest == null || entry.bookingDate.isAfter(latest.bookingDate)
              ? entry
              : latest,
        );
    if (previous != null) {
      category = previous.category;
      payment ??= previous.paymentMethod.isEmpty
          ? null
          : previous.paymentMethod;
      learned = true;
    }
  }
  return QuickEntry(
    amount: amount,
    income: income,
    merchant: merchant,
    category: category ?? 'Sonstiges',
    paymentMethod: payment ?? '',
    date: date,
    categoryLearned: learned,
  );
}

/// Amount and income flag, or null when [word] is no amount.
(double, bool)? _parseAmount(String word) {
  final dot = _dotDecimal.firstMatch(word);
  if (dot != null) {
    final value = double.parse('${dot.group(2)}.${dot.group(3)}');
    return (value, dot.group(1) == '+');
  }
  final match = _amountPattern.firstMatch(word);
  if (match == null) return null;
  final whole = match.group(2)!.replaceAll('.', '');
  final cents = match.group(3);
  final value = double.parse(cents == null ? whole : '$whole.$cents');
  return (value, match.group(1) == '+');
}
