import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wealthflow/app/app_shell.dart';
import 'package:wealthflow/app/app_theme.dart';
import 'package:wealthflow/app/design.dart';
import 'package:wealthflow/core/providers.dart';
import 'package:wealthflow/core/security/secure_session_store.dart';
import 'package:wealthflow_core/database/app_database.dart';

const _userId = 'owner';

/// A household with an account, bookings, a standing order and a budget.
Future<AppDatabase> _seed(String themeMode) async {
  final database = AppDatabase.forTesting(NativeDatabase.memory());
  final now = DateTime.now();
  final created = now.toUtc();
  await database.createUser(
    UsersCompanion.insert(
      id: _userId,
      email: 'owner@example.test',
      displayName: 'Owner',
      passwordHash: 'hash',
      passwordSalt: 'salt',
      role: const Value('admin'),
      createdAt: created,
      updatedAt: created,
    ),
  );
  await database.savePreferences(
    UserPreferencesCompanion.insert(
      userId: _userId,
      themeMode: Value(themeMode),
      updatedAt: created,
    ),
  );
  await database.seedDefaultMasterData(_userId);
  await database.saveAccount(
    AccountsCompanion.insert(
      id: 'giro',
      userId: _userId,
      bankName: 'Bank',
      label: 'Giro',
      balance: const Value(2078.40),
      usageType: const Value('household'),
      createdAt: created,
      updatedAt: created,
    ),
  );
  final day = DateTime(now.year, now.month, now.day > 1 ? now.day - 1 : 1);
  await database.saveLedgerEntries([
    for (final (id, amount, income, category, merchant) in [
      ('salary', 3250.0, true, 'Gehalt', 'Arbeitgeber'),
      ('food', 54.20, false, 'Lebensmittel', 'Rewe'),
      ('fuel', 68.0, false, 'Tanken', 'Tankstelle'),
    ])
      LedgerEntriesCompanion.insert(
        id: id,
        userId: _userId,
        bookingDate: day,
        amount: amount,
        isIncome: Value(income),
        category: category,
        merchant: Value(merchant),
        accountId: const Value('giro'),
        createdAt: created,
        updatedAt: created,
      ),
  ]);
  await database.saveStandingOrder(
    StandingOrdersCompanion.insert(
      id: 'rent',
      userId: _userId,
      accountId: 'giro',
      amount: 820,
      category: const Value('Wohnen'),
      merchant: const Value('Miete'),
      dayOfMonth: 1,
      startDate: DateTime(now.year - 1, 1, 1),
      createdAt: created,
      updatedAt: created,
    ),
  );
  await database
      .into(database.categoryBudgets)
      .insert(
        CategoryBudgetsCompanion.insert(
          id: 'food-budget',
          userId: _userId,
          category: 'Lebensmittel',
          monthlyLimit: 450,
          startMonth: DateTime(now.year, now.month),
          createdAt: created,
          updatedAt: created,
        ),
      );
  return database;
}

Future<ProviderContainer> _pumpApp(
  WidgetTester tester,
  AppDatabase database,
  Size size,
) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final container = ProviderContainer(
    overrides: [
      databaseProvider.overrideWithValue(database),
      currentUserIdProvider.overrideWithValue(_userId),
      secureSessionStoreProvider.overrideWithValue(SecureSessionStore()),
    ],
  );
  // Unmount the app first so its stream listeners end; only then can the
  // database close without waiting for them.
  addTearDown(() async {
    await tester.pumpWidget(const SizedBox());
    container.dispose();
    await tester.pump(const Duration(milliseconds: 100));
  });
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: Consumer(
        builder: (context, ref, _) {
          final design = ref.watch(designProvider);
          return MaterialApp(
            theme: AppTheme.light(design),
            darkTheme: AppTheme.dark(design),
            themeMode: ref.watch(themeModeProvider),
            home: const AppShell(),
          );
        },
      ),
    ),
  );
  // Streams from the database arrive over several frames.
  for (var i = 0; i < 10; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
  return container;
}

DesignStyle _currentStyle(WidgetTester tester) =>
    DesignStyle.of(tester.element(find.byType(AppShell)));

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    FlutterSecureStorage.setMockInitialValues({});
  });

  for (final mode in ['bento', 'terminal', 'light', 'dark']) {
    for (final size in const [Size(390, 844), Size(1440, 900)]) {
      testWidgets('all pages build in $mode at ${size.width.toInt()} px', (
        tester,
      ) async {
        final database = await _seed(mode);
        addTearDown(() => tester.runAsync(database.close));
        await _pumpApp(tester, database, size);

        expect(tester.takeException(), isNull);
        expect(_currentStyle(tester).design, DesignChoice.parse(mode).design);
        // The cockpit's main figure is on the start page.
        expect(
          find.textContaining(RegExp('frei bis', caseSensitive: false)),
          findsWidgets,
        );
        expect(find.byTooltip('Beträge verbergen'), findsOneWidget);
      });
    }
  }

  testWidgets('the palette button switches the design and stores it', (
    tester,
  ) async {
    final database = await _seed('light');
    addTearDown(() => tester.runAsync(database.close));
    await _pumpApp(tester, database, const Size(1440, 900));
    expect(_currentStyle(tester).design, AppDesign.classic);

    await tester.tap(find.byTooltip('Design wechseln').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Terminal').last);
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    expect(_currentStyle(tester).design, AppDesign.terminal);
    expect((await database.preferencesFor(_userId)).themeMode, 'terminal');
    expect(tester.takeException(), isNull);
  });

  testWidgets('quick entry books on the household account, with undo', (
    tester,
  ) async {
    final database = await _seed('bento');
    addTearDown(() => tester.runAsync(database.close));
    await _pumpApp(tester, database, const Size(1440, 900));

    final field = find.widgetWithText(
      TextField,
      'Was ist passiert? z. B. „12,50 Bäcker bar“',
    );
    await tester.enterText(field, '12,50 Bäcker bar');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    var entries = (await tester.runAsync(
      () => database.watchLedgerEntries(_userId).first,
    ))!;
    final booked = entries.where((e) => e.merchant == 'Bäcker').single;
    expect(booked.amount, 12.5);
    expect(booked.isIncome, isFalse);
    expect(booked.paymentMethod, 'Bar');
    expect(booked.accountId, 'giro');
    expect(find.textContaining('Gebucht:'), findsOneWidget);

    await tester.tap(find.text('Rückgängig'));
    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    entries = (await tester.runAsync(
      () => database.watchLedgerEntries(_userId).first,
    ))!;
    expect(entries.where((e) => e.merchant == 'Bäcker'), isEmpty);
  });

  testWidgets('privacy button hides cockpit amounts', (tester) async {
    final database = await _seed('bento');
    addTearDown(() => tester.runAsync(database.close));
    await _pumpApp(tester, database, const Size(1440, 900));
    expect(find.text('•••• €'), findsNothing);

    await tester.tap(find.byTooltip('Beträge verbergen').first);
    await tester.pump();
    expect(find.textContaining('•••• €'), findsWidgets);
    // On the PC the button sits in the sidebar, on every page.
    expect(find.byTooltip('Beträge zeigen'), findsOneWidget);

    // The whole app, not only the cockpit.
    await tester.tap(find.text('Haushalt').first);
    await tester.pumpAndSettle();
    expect(find.textContaining('•••• €'), findsWidgets);
    expect(find.textContaining(RegExp(r'[0-9],[0-9][0-9] €')), findsNothing);

    await tester.tap(find.byTooltip('Beträge zeigen').first);
    await tester.pump();
    expect(find.textContaining('•••• €'), findsNothing);
  });
}
