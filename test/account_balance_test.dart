import 'package:flutter_test/flutter_test.dart';
import 'package:wealthflow_core/database/app_database.dart';
import 'package:wealthflow_core/finance/account_balance_math.dart';

void main() {
  final created = DateTime(2026, 1, 1);
  final account = Account(
    id: 'giro',
    userId: 'user',
    bankName: 'Bank',
    label: 'Giro',
    holder: '',
    iban: '',
    bic: '',
    accountNumber: '',
    currency: 'EUR',
    balance: 0,
    availableBalance: 0,
    usageType: 'household',
    notes: '',
    displayOrder: 0,
    createdAt: created,
    updatedAt: created,
  );

  LedgerEntry entry(String id, DateTime date, double amount) => LedgerEntry(
    id: id,
    userId: 'user',
    bookingDate: date,
    amount: amount.abs(),
    isIncome: amount > 0,
    category: '',
    merchant: '',
    description: '',
    paymentMethod: '',
    recurrenceId: '',
    sourceType: '',
    sourceId: '',
    vehicleId: '',
    accountId: 'giro',
    accountApplied: true,
    createdAt: date,
    updatedAt: date,
  );

  test('bookings on the day of a recorded balance count on top of it', () {
    // The balance was entered during the day; it is valid from that day on.
    final history = AccountBalanceHistory(
      id: 'h',
      userId: 'user',
      accountId: 'giro',
      effectiveAt: DateTime(2026, 11, 3, 14, 30),
      balance: 4812,
      availableBalance: 4812,
      createdAt: DateTime(2026, 11, 3, 14, 30),
    );
    final day = DateTime(2026, 11, 3);
    final entries = [
      entry('salary', day, 2500),
      entry('rent', day, -120.5),
      entry('food', day, -80.22),
      entry('fuel', day, -42),
      entry('before', DateTime(2026, 11, 2), -999),
    ];

    final balance = accountBalanceAt(
      account: account,
      date: DateTime(2026, 11, 30, 23, 59),
      histories: [history],
      entries: entries,
      investments: const [],
      purchases: const [],
      sales: const [],
    );

    expect(balance, closeTo(7069.28, 0.001));
  });
}
