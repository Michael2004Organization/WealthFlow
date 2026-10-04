import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wealthflow/core/providers.dart';
import 'package:wealthflow/features/more/more_page.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  Future<ProviderContainer> pumpMore(WidgetTester tester, Size size) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final container = ProviderContainer(
      overrides: [
        currentUserIdProvider.overrideWithValue('more-user'),
        isAdminProvider.overrideWithValue(false),
      ],
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: Scaffold(body: MorePage())),
      ),
    );
    await tester.pumpAndSettle();
    return container;
  }

  testWidgets('phones reach Rechner and Fahrzeuge through Mehr', (
    tester,
  ) async {
    final container = await pumpMore(tester, const Size(360, 800));

    expect(find.text('Fahrzeuge'), findsOneWidget);
    await tester.tap(find.text('Rechner'));
    await tester.pumpAndSettle();

    expect(container.read(shellIndexProvider), 4);
  });

  testWidgets('wide screens keep Rechner in the side navigation', (
    tester,
  ) async {
    await pumpMore(tester, const Size(1280, 900));

    expect(find.text('Rechner'), findsNothing);
    expect(find.text('Fahrzeuge'), findsNothing);
  });
}
