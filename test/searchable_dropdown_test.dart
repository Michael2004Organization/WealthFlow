import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wealthflow/core/widgets/common_widgets.dart';

void main() {
  for (final expanded in [false, true]) {
    testWidgets(
      'dropdown supports intrinsic dialog sizing (expanded: $expanded)',
      (tester) async {
        String? selected;
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) => TextButton(
                  onPressed: () => showDialog<void>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Auswahl'),
                      content: SearchableDropdownButtonFormField<String>(
                        isExpanded: expanded,
                        items: const [
                          DropdownMenuItem(
                            value: 'alpha',
                            child: Text('Alpha'),
                          ),
                          DropdownMenuItem(value: 'beta', child: Text('Beta')),
                        ],
                        onChanged: (value) => selected = value,
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Schließen'),
                        ),
                      ],
                    ),
                  ),
                  child: const Text('Öffnen'),
                ),
              ),
            ),
          ),
        );
        final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
        await mouse.addPointer(location: const Offset(400, 300));
        addTearDown(mouse.removePointer);
        await tester.tap(find.text('Öffnen'));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);

        final input = find.byType(TextField);
        await mouse.moveTo(tester.getCenter(input));
        await tester.tap(input);
        await tester.enterText(input, 'Be');
        await tester.pumpAndSettle();
        final option = find.text('Beta').hitTestable();
        await mouse.moveTo(tester.getCenter(option));
        await tester.tap(option);
        await tester.pumpAndSettle();
        expect(selected, 'beta');
        await tester.tap(find.text('Schließen'));
        await tester.pumpAndSettle();
        await mouse.moveTo(const Offset(10, 10));
        await tester.pump();
        expect(find.byType(AlertDialog), findsNothing);
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets('dropdown filters options while typing', (tester) async {
    String? selected;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 320,
            child: SearchableDropdownButtonFormField<String>(
              initialValue: 'beta',
              isExpanded: true,
              decoration: const InputDecoration(labelText: 'Auswahl'),
              items: const [
                DropdownMenuItem(value: 'alpha', child: Text('Alpha')),
                DropdownMenuItem(value: 'alpine', child: Text('Alpine')),
                DropdownMenuItem(value: 'beta', child: Text('Beta')),
              ],
              onChanged: (value) => selected = value,
            ),
          ),
        ),
      ),
    );

    final input = find.byType(TextField);
    await tester.tap(input);
    await tester.enterText(input, 'Al');
    await tester.pumpAndSettle();

    expect(find.text('Alpha'), findsOneWidget);
    expect(find.text('Alpine'), findsOneWidget);
    expect(find.text('Beta'), findsNothing);

    await tester.tap(find.text('Alpha'));
    await tester.pumpAndSettle();
    expect(selected, 'alpha');
  });
}
