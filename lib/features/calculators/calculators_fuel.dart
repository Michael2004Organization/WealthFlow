part of 'calculators_page.dart';

class _FuelCalculator extends StatefulWidget {
  const _FuelCalculator();
  @override
  State<_FuelCalculator> createState() => _FuelCalculatorState();
}

class _FuelCalculatorState extends State<_FuelCalculator> {
  final _distance = TextEditingController(text: '25');
  final _consumption = TextEditingController(text: '7');
  final _price = TextEditingController(text: '1,80');
  final _priceB = TextEditingController(text: '1,72');
  final _trips = TextEditingController(text: '10');
  final _tank = TextEditingController(text: '50');
  String _mode = 'trip';
  @override
  void dispose() {
    _distance.dispose();
    _consumption.dispose();
    _price.dispose();
    _priceB.dispose();
    _trips.dispose();
    _tank.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final liters = _mode == 'trip'
        ? _value(_distance.text) / 100 * _value(_consumption.text)
        : _value(_tank.text);
    final costA = liters * _value(_price.text);
    final costB = liters * _value(_priceB.text);
    final difference = (costA - costB).abs();
    final annualDifference = _mode == 'trip'
        ? difference * _value(_trips.text) * 52
        : difference;
    final cheaper = costA == costB
        ? 'Beide Preise sind gleich'
        : costA < costB
        ? 'Preis A ist günstiger'
        : 'Preis B ist günstiger';
    return _CalculatorScaffold(
      title: 'Spritkosten-Vergleich',
      input: Column(
        children: [
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'trip', label: Text('Strecke')),
              ButtonSegment(value: 'tank', label: Text('Tankinhalt')),
            ],
            selected: {_mode},
            onSelectionChanged: (value) => setState(() => _mode = value.first),
          ),
          const SizedBox(height: 12),
          if (_mode == 'trip') ...[
            _NumberField(
              controller: _distance,
              label: 'Kilometer pro Fahrt',
              suffix: 'km',
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),
            _NumberField(
              controller: _consumption,
              label: 'Verbrauch',
              suffix: 'l/100 km',
              onChanged: (_) => setState(() {}),
            ),
          ] else
            _NumberField(
              controller: _tank,
              label: 'Tankinhalt',
              suffix: 'Liter',
              onChanged: (_) => setState(() {}),
            ),
          const SizedBox(height: 12),
          _NumberField(
            controller: _price,
            label: 'Kraftstoffpreis A',
            suffix: '€/l',
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 12),
          _NumberField(
            controller: _priceB,
            label: 'Kraftstoffpreis B',
            suffix: '€/l',
            onChanged: (_) => setState(() {}),
          ),
          if (_mode == 'trip') ...[
            const SizedBox(height: 12),
            _NumberField(
              controller: _trips,
              label: 'Fahrten pro Woche',
              suffix: '',
              onChanged: (_) => setState(() {}),
            ),
          ],
        ],
      ),
      result: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            cheaper,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 20),
          LayoutBuilder(
            builder: (context, constraints) {
              final cards = [
                _FuelPriceCard(
                  label: 'PREIS A',
                  fuelPrice: _value(_price.text),
                  cost: costA,
                  color: WealthColors.of(context).chart[3],
                ),
                _FuelPriceCard(
                  label: 'PREIS B',
                  fuelPrice: _value(_priceB.text),
                  cost: costB,
                  color: WealthColors.of(context).chart[2],
                ),
              ];
              return constraints.maxWidth < 520
                  ? Column(
                      children: [
                        cards.first,
                        const SizedBox(height: 12),
                        cards.last,
                      ],
                    )
                  : Row(
                      children: [
                        Expanded(child: cards.first),
                        const SizedBox(width: 16),
                        Expanded(child: cards.last),
                      ],
                    );
            },
          ),
          const SizedBox(height: 22),
          Wrap(
            alignment: WrapAlignment.spaceEvenly,
            spacing: 28,
            runSpacing: 18,
            children: [
              _Result(
                label: _mode == 'trip'
                    ? 'Ersparnis pro Jahr'
                    : 'Ersparnis je Tankfüllung',
                value: money(annualDifference),
                color: WealthColors.of(context).expense,
              ),
              _Result(
                label: 'Direkte Differenz',
                value: money(difference),
                color: WealthColors.of(context).warning,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FuelPriceCard extends StatelessWidget {
  const _FuelPriceCard({
    required this.label,
    required this.fuelPrice,
    required this.cost,
    required this.color,
  });

  final String label;
  final double fuelPrice;
  final double cost;
  final Color color;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: color.withValues(alpha: .12),
      borderRadius: BorderRadius.circular(22),
      border: Border.all(color: color.withValues(alpha: .35)),
    ),
    child: Padding(
      padding: const EdgeInsets.all(22),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.4,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '${fuelPrice.toStringAsFixed(3).replaceAll('.', ',')} €/l',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 14),
          Text(
            money(cost),
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
          Text('Kosten im gewählten Vergleich'),
        ],
      ),
    ),
  );
}
