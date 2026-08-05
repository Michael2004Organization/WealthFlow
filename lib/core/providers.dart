import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/auth/auth_controller.dart';
import 'database/app_database.dart';
import 'security/secure_session_store.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  final database = AppDatabase();
  ref.onDispose(database.close);
  return database;
});

final secureSessionStoreProvider = Provider<SecureSessionStore>(
  (_) => SecureSessionStore(),
);

final authControllerProvider = StateNotifierProvider<AuthController, AuthState>(
  (ref) {
    return AuthController(
      database: ref.watch(databaseProvider),
      sessionStore: ref.watch(secureSessionStoreProvider),
    );
  },
);

final currentUserIdProvider = Provider<String?>((ref) {
  return ref.watch(authControllerProvider).user?.id;
});

final accountsProvider = StreamProvider<List<Account>>((ref) {
  final userId = ref.watch(currentUserIdProvider);
  return userId == null
      ? Stream.value(const <Account>[])
      : ref.watch(databaseProvider).watchAccounts(userId);
});

final investmentsProvider = StreamProvider<List<Investment>>((ref) {
  final userId = ref.watch(currentUserIdProvider);
  return userId == null
      ? Stream.value(const <Investment>[])
      : ref.watch(databaseProvider).watchInvestments(userId);
});

final investmentPurchasesProvider = StreamProvider<List<InvestmentPurchase>>((
  ref,
) {
  final userId = ref.watch(currentUserIdProvider);
  return userId == null
      ? Stream.value(const [])
      : ref.watch(databaseProvider).watchInvestmentPurchases(userId);
});

final dividendSchedulesProvider = StreamProvider<List<DividendSchedule>>((ref) {
  final userId = ref.watch(currentUserIdProvider);
  return userId == null
      ? Stream.value(const <DividendSchedule>[])
      : ref.watch(databaseProvider).watchDividendSchedules(userId);
});

final ledgerEntriesProvider = StreamProvider<List<LedgerEntry>>((ref) {
  final userId = ref.watch(currentUserIdProvider);
  return userId == null
      ? Stream.value(const <LedgerEntry>[])
      : ref.watch(databaseProvider).watchLedgerEntries(userId);
});

final masterDataProvider = StreamProvider<List<MasterDataData>>((ref) {
  final userId = ref.watch(currentUserIdProvider);
  return userId == null
      ? Stream.value(const <MasterDataData>[])
      : ref.watch(databaseProvider).watchMasterData(userId);
});

final vehiclesProvider = StreamProvider<List<Vehicle>>((ref) {
  final userId = ref.watch(currentUserIdProvider);
  return userId == null
      ? Stream.value(const <Vehicle>[])
      : ref.watch(databaseProvider).watchVehicles(userId);
});

final vehicleCostsProvider = StreamProvider<List<VehicleCost>>((ref) {
  final userId = ref.watch(currentUserIdProvider);
  return userId == null
      ? Stream.value(const <VehicleCost>[])
      : ref.watch(databaseProvider).watchVehicleCosts(userId);
});

final preferencesProvider = StreamProvider<UserPreference?>((ref) {
  final userId = ref.watch(currentUserIdProvider);
  return userId == null
      ? Stream.value(null)
      : ref.watch(databaseProvider).watchPreferences(userId);
});

final netWorthSnapshotsProvider = StreamProvider<List<NetWorthSnapshot>>((ref) {
  final userId = ref.watch(currentUserIdProvider);
  return userId == null
      ? Stream.value(const <NetWorthSnapshot>[])
      : ref.watch(databaseProvider).watchNetWorthSnapshots(userId);
});

final themeModeProvider = Provider<ThemeMode>((ref) {
  final preference = ref.watch(preferencesProvider).valueOrNull;
  return switch (preference?.themeMode) {
    'light' => ThemeMode.light,
    'dark' => ThemeMode.dark,
    _ => ThemeMode.system,
  };
});

final shellIndexProvider = StateProvider<int>((_) => 0);

/// Keeps nested destinations addressable while their pages stay alive inside
/// the shell's [IndexedStack].
final financeTabProvider = StateProvider<int>((_) => 0);
final moreDestinationProvider = StateProvider<String?>((_) => null);

void openFinance(WidgetRef ref, int tab) {
  ref.read(financeTabProvider.notifier).state = tab;
  ref.read(shellIndexProvider.notifier).state = 1;
}

void openMore(WidgetRef ref, String destination) {
  ref.read(moreDestinationProvider.notifier).state = destination;
  ref.read(shellIndexProvider.notifier).state = 4;
}

void selectShellDestination(WidgetRef ref, int destination) {
  if (destination == 1) {
    ref.read(financeTabProvider.notifier).state = 0;
  }
  if (destination == 4) {
    ref.read(moreDestinationProvider.notifier).state = null;
  }
  ref.read(shellIndexProvider.notifier).state = destination;
}
