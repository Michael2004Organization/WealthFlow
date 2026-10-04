import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wealthflow/core/widgets/save_feedback.dart';

void main() {
  test('own errors keep their reason, others get a generic hint', () {
    expect(
      saveErrorMessage(StateError('Konto fehlt.'), 'Speichern fehlgeschlagen'),
      'Speichern fehlgeschlagen: Konto fehlt.',
    );
    expect(
      saveErrorMessage(
        Exception('SqliteException(19)'),
        'Löschen fehlgeschlagen',
      ),
      'Löschen fehlgeschlagen. Bitte erneut versuchen.',
    );
  });

  testWidgets('a failed save shows a message instead of failing silently', (
    tester,
  ) async {
    late BuildContext context;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (value) {
              context = value;
              return const SizedBox();
            },
          ),
        ),
      ),
    );

    final saved = await saveWithFeedback(
      context,
      () async => throw StateError('Das Konto ist nicht verfügbar.'),
    );
    await tester.pump();

    expect(saved, isFalse);
    expect(
      find.text('Speichern fehlgeschlagen: Das Konto ist nicht verfügbar.'),
      findsOneWidget,
    );
  });
}
