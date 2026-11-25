import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:wealthflow_core/database/app_database.dart';
import 'package:wealthflow_core/finance/account_balance_math.dart';
import 'package:wealthflow_core/finance/quick_entry.dart';

import '../../core/providers.dart';
import '../../core/widgets/common_widgets.dart';

/// Reads "12,50 Bäcker bar" with the user's payment methods, categories
/// and booking history.
QuickEntry? parseQuickBooking(WidgetRef ref, String text) {
  final masterData =
      ref.read(masterDataProvider).valueOrNull ?? const <MasterDataData>[];
  return parseQuickEntry(
    text,
    today: DateTime.now(),
    paymentMethods: [
      for (final item in masterData)
        if (item.kind == 'paymentMethod') item.value,
    ],
    categories: [
      for (final item in masterData)
        if (item.kind == 'category') item.value,
    ],
    history: ref.read(ledgerEntriesProvider).valueOrNull ?? const [],
  );
}

/// Books [entry] on the chosen household account and offers "Rückgängig".
/// Returns false when there is no household account yet.
Future<bool> bookQuickEntry(
  WidgetRef ref,
  ScaffoldMessengerState messenger,
  QuickEntry entry,
) async {
  final userId = ref.read(currentUserIdProvider);
  final accounts = householdAccounts(
    ref.read(accountsProvider).valueOrNull ?? const [],
    investments: ref.read(allInvestmentsProvider).valueOrNull ?? const [],
    physicalAssets: ref.read(physicalAssetsProvider).valueOrNull ?? const [],
  );
  final preferred = ref
      .read(preferencesProvider)
      .valueOrNull
      ?.selectedHouseholdAccountId;
  final account =
      accounts.where((a) => a.id == preferred).firstOrNull ??
      accounts.where((a) => a.usageType == 'household').firstOrNull ??
      accounts.firstOrNull;
  if (userId == null || account == null) {
    messenger.showSnackBar(
      const SnackBar(
        content: Text('Lege zuerst ein Haushaltskonto unter Vermögen an.'),
      ),
    );
    return false;
  }
  final now = DateTime.now().toUtc();
  final id = const Uuid().v4();
  final database = ref.read(databaseProvider);
  await database.saveLedgerEntries([
    LedgerEntriesCompanion.insert(
      id: id,
      userId: userId,
      bookingDate: entry.date,
      amount: entry.amount,
      isIncome: Value(entry.income),
      category: entry.category,
      merchant: Value(entry.merchant),
      paymentMethod: Value(entry.paymentMethod),
      accountId: Value(account.id),
      createdAt: now,
      updatedAt: now,
    ),
  ]);
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text('Gebucht: ${money(entry.amount)} · ${entry.summary}'),
        action: SnackBarAction(
          label: 'Rückgängig',
          onPressed: () => database.deleteLedgerEntry(id, userId),
        ),
      ),
    );
  return true;
}
