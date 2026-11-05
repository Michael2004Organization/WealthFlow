import 'package:flutter_test/flutter_test.dart';
import 'package:wealthflow_core/finance/allocation.dart';

void main() {
  test('Anteile, Ziele und Nachkauf ohne Verkauf', () {
    final slices = buildAllocation(
      {'ETF': 6000, 'Konten': 3000, 'Aktie': 1000, 'Leer': 0},
      targets: parseAllocationTargets([
        'ETF=60',
        'Aktie=20',
        'Gold=10',
        'kaputt',
      ]),
    );
    expect(slices.map((slice) => slice.label), [
      'ETF',
      'Konten',
      'Aktie',
      'Gold',
    ]);
    expect(slices.first.share, .6);
    expect(slices.first.toBuy, 0);
    // (1000 + x) / (10000 + x) = 0.2 → x = 1250
    expect(slices[2].toBuy, closeTo(1250, 1e-6));
    expect(slices[3].value, 0);
    expect(slices[3].toBuy, closeTo(1000 / .9, 1e-6));
    expect(slices[1].target, isNull);
  });
}
