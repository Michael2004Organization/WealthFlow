import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wealthflow/app/app_lock_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wealthflow/core/database/app_database.dart';
import 'package:wealthflow/core/providers.dart';
import 'package:wealthflow/features/auth/auth_controller.dart';

void main() {
  testWidgets('unlocks only with the right PIN', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final digest = (await tester.runAsync(() => hashAppPin('4711')))!;
    var unlocked = false;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWith((ref) {
            final database = AppDatabase.forTesting(NativeDatabase.memory());
            ref.onDispose(database.close);
            return database;
          }),
          appPinProvider.overrideWith(
            (ref) async => (hash: digest.hash, salt: digest.salt),
          ),
        ],
        child: MaterialApp(
          home: AppLockScreen(onUnlocked: () => unlocked = true),
        ),
      ),
    );

    await tester.enterText(find.byType(TextField), '1234');
    await tester.runAsync(() async {
      await tester.tap(find.text('Entsperren'));
      await Future<void>.delayed(const Duration(seconds: 3));
    });
    await tester.pump();
    expect(unlocked, isFalse);
    expect(find.text('Die PIN ist nicht korrekt.'), findsOneWidget);

    await tester.enterText(find.byType(TextField), '4711');
    await tester.runAsync(() async {
      await tester.tap(find.text('Entsperren'));
      await Future<void>.delayed(const Duration(seconds: 3));
    });
    await tester.pump();
    expect(unlocked, isTrue);
  });
}
