import 'package:intl/intl.dart';

final _germanThousands = RegExp(r'^-?\d{1,3}(\.\d{3}){2,}$');

/// Parses a user-entered amount in German or plain decimal notation.
///
/// Accepts `1.234,56`, `1234,56`, `1234.56` and `1.234.567`. A single dot
/// without a comma stays a decimal point, so values prefilled with
/// [double.toString] such as `1.085` keep their meaning. Spaces and a
/// trailing currency sign are ignored.
double? parseAmount(String? input) {
  var value = (input ?? '')
      .replaceAll(RegExp(r'[\s  €]'), '')
      .replaceAll(RegExp(r'[A-Za-z]{3}$'), '');
  if (value.isEmpty) return null;
  if (value.contains(',')) {
    value = value.replaceAll('.', '').replaceAll(',', '.');
  } else if (_germanThousands.hasMatch(value)) {
    value = value.replaceAll('.', '');
  }
  return double.tryParse(value);
}

/// Formats an amount for an editable input field, e.g. `1234,5` → `1234,50`.
String formatAmountInput(num value) =>
    NumberFormat('0.00##', 'de_DE').format(value);
