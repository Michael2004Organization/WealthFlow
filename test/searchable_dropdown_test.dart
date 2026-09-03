import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wealthflow/core/widgets/common_widgets.dart';

void main() {
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
