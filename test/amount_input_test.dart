import 'package:flutter_test/flutter_test.dart';
import 'package:wealthflow/core/finance/amount_input.dart';

void main() {
  test('parses German amounts with thousands separators', () {
    expect(parseAmount('1.234,56'), 1234.56);
    expect(parseAmount('12.345.678,9'), 12345678.9);
    expect(parseAmount('1.234.567'), 1234567);
    expect(parseAmount(' 1 234,50 € '), 1234.5);
  });

  test('keeps plain decimal input working', () {
    expect(parseAmount('12,5'), 12.5);
    expect(parseAmount('12.5'), 12.5);
    expect(parseAmount('1.085'), 1.085);
    expect(parseAmount('0.125'), 0.125);
    expect(parseAmount('1234.56'), 1234.56);
    expect(parseAmount('0,0001'), 0.0001);
    expect(parseAmount('-3,20'), -3.2);
  });

  test('rejects empty and invalid input', () {
    expect(parseAmount(null), isNull);
    expect(parseAmount(''), isNull);
    expect(parseAmount('abc'), isNull);
    expect(parseAmount('1,2,3'), isNull);
  });

  test('formats amounts for editing in German notation', () {
    expect(formatAmountInput(12.5), '12,50');
    expect(formatAmountInput(1234.5678), '1234,5678');
    expect(formatAmountInput(3), '3,00');
  });
}
