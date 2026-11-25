part of 'calculators_page.dart';

class _CompoundCalculator extends ConsumerStatefulWidget {
  const _CompoundCalculator();
  @override
  ConsumerState<_CompoundCalculator> createState() =>
      _CompoundCalculatorState();
}

class _CompoundCalculatorState extends ConsumerState<_CompoundCalculator> {
  final _start = TextEditingController(text: '10000');
  final _monthly = TextEditingController(text: '500');
  final _rate = TextEditingController(text: '7');
  final _years = TextEditingController(text: '20');
  bool _usedPortfolio = false;
  bool _advanced = false;
  final Set<String> _selectedInvestments = {};
  final Map<String, TextEditingController> _assetSavings = {};
  final Map<String, TextEditingController> _assetRates = {};
  @override
  void dispose() {
    _start.dispose();
    _monthly.dispose();
    _rate.dispose();
    _years.dispose();
    for (final controller in [..._assetSavings.values, ..._assetRates.values]) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final investments =
        ref.watch(investmentsProvider).valueOrNull ?? const <Investment>[];
    final portfolio = investments.fold<double>(
      0,
      (sum, item) =>
          sum + ref.read(currencyConverterProvider).investmentValue(item),
    );
    final start = _advanced ? 0.0 : _value(_start.text);
    final selected = investments
        .where((item) => _selectedInvestments.contains(item.id))
        .toList();
    final monthly = _advanced
        ? selected.fold<double>(
            0,
            (sum, item) => sum + _value(_savingFor(item).text),
          )
        : _value(_monthly.text);
    final rate = _value(_rate.text) / 100 / 12;
    final years = _value(_years.text).round().clamp(1, 80);
    final months = years * 12;
    final end = _advanced
        ? _advancedValue(selected, months)
        : rate == 0
        ? start + monthly * months
        : start * math.pow(1 + rate, months) +
              monthly * ((math.pow(1 + rate, months) - 1) / rate);
    final paid = start + monthly * months;
    final spots = <FlSpot>[];
    final paidSpots = <FlSpot>[];
    for (var year = 0; year <= years; year++) {
      final m = year * 12;
      final value = _advanced
          ? _advancedValue(selected, m)
          : rate == 0
          ? start + monthly * m
          : start * math.pow(1 + rate, m) +
                monthly * ((math.pow(1 + rate, m) - 1) / rate);
      spots.add(FlSpot(year.toDouble(), value.toDouble()));
      paidSpots.add(FlSpot(year.toDouble(), start + monthly * m));
    }
    return _CalculatorScaffold(
      title: 'Zinseszinsrechner',
      input: Column(
        children: [
          SegmentedButton<bool>(
            segments: const [
              ButtonSegment(
                value: false,
                icon: Icon(Icons.calculate_outlined),
                label: Text('Einfach'),
              ),
              ButtonSegment(
                value: true,
                icon: Icon(Icons.tune_rounded),
                label: Text('Erweitert'),
              ),
            ],
            selected: {_advanced},
            onSelectionChanged: (value) =>
                setState(() => _advanced = value.first),
          ),
          const SizedBox(height: 16),
          if (!_advanced) ...[
            _NumberField(
              controller: _start,
              label: 'Startkapital',
              suffix: '€',
              onChanged: (_) => setState(() {}),
            ),
            if (portfolio > 0)
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    _start.text = portfolio.toStringAsFixed(2);
                    _usedPortfolio = true;
                  });
                },
                icon: const Icon(Icons.auto_awesome_rounded),
                label: Text(
                  _usedPortfolio
                      ? 'Aktueller Depotwert übernommen'
                      : 'Aktuellen Depotwert übernehmen',
                ),
              ),
            const SizedBox(height: 12),
            _NumberField(
              controller: _monthly,
              label: 'Monatliche Sparrate',
              suffix: '€',
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),
            _NumberField(
              controller: _rate,
              label: 'Rendite p. a.',
              suffix: '%',
              onChanged: (_) => setState(() {}),
            ),
          ] else ...[
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Wähle Positionen und plane jede Sparrate einzeln',
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
              ),
            ),
            const SizedBox(height: 8),
            if (investments.isEmpty)
              const Text('Lege zuerst eine Position im Portfolio an.')
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final item in investments)
                    FilterChip(
                      label: Text(
                        item.symbol.isEmpty ? item.name : item.symbol,
                      ),
                      selected: _selectedInvestments.contains(item.id),
                      onSelected: (value) => setState(() {
                        if (value) {
                          _selectedInvestments.add(item.id);
                        } else {
                          _selectedInvestments.remove(item.id);
                        }
                      }),
                    ),
                ],
              ),
            const SizedBox(height: 12),
            for (final item in selected) ...[
              Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        item.name,
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 10),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final fields = [
                            _NumberField(
                              controller: _savingFor(item),
                              label: 'Sparrate',
                              suffix: '€/Monat',
                              onChanged: (_) => setState(() {}),
                            ),
                            _NumberField(
                              controller: _rateFor(item),
                              label: 'Rendite p. a.',
                              suffix: '%',
                              onChanged: (_) => setState(() {}),
                            ),
                          ];
                          return constraints.maxWidth < 420
                              ? Column(
                                  children: [
                                    fields.first,
                                    const SizedBox(height: 10),
                                    fields.last,
                                  ],
                                )
                              : Row(
                                  children: [
                                    Expanded(child: fields.first),
                                    const SizedBox(width: 10),
                                    Expanded(child: fields.last),
                                  ],
                                );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
          const SizedBox(height: 12),
          _NumberField(
            controller: _years,
            label: 'Laufzeit',
            suffix: 'Jahre',
            onChanged: (_) => setState(() {}),
          ),
        ],
      ),
      result: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            spacing: 20,
            runSpacing: 12,
            children: [
              _Result(label: 'Endkapital', value: money(end)),
              _Result(label: 'Einzahlungen', value: money(paid)),
              _Result(
                label: 'Ertrag',
                value: money(end - paid),
                color: WealthColors.of(context).income,
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: LineChart(
              LineChartData(
                borderData: FlBorderData(show: false),
                gridData: FlGridData(
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (_) => FlLine(
                    color: Theme.of(
                      context,
                    ).dividerColor.withValues(alpha: .25),
                    strokeWidth: 1,
                  ),
                ),
                titlesData: const FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: true, reservedSize: 28),
                  ),
                ),
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipItems: (spots) => spots
                        .map(
                          (spot) => LineTooltipItem(
                            (spot.barIndex == 0
                                    ? 'Vermögen: '
                                    : 'Einzahlungen: ') +
                                money(spot.y),
                            const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: Theme.of(context).colorScheme.primary,
                    barWidth: 4,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: .12),
                    ),
                  ),
                  LineChartBarData(
                    spots: paidSpots,
                    isCurved: false,
                    color: WealthColors.of(context).chart[2],
                    barWidth: 2,
                    dashArray: [7, 5],
                    dotData: const FlDotData(show: false),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  TextEditingController _savingFor(Investment item) => _assetSavings
      .putIfAbsent(item.id, () => TextEditingController(text: '100'));

  TextEditingController _rateFor(Investment item) =>
      _assetRates.putIfAbsent(item.id, () => TextEditingController(text: '7'));

  double _advancedValue(List<Investment> items, int months) =>
      items.fold<double>(0, (sum, item) {
        final monthly = _value(_savingFor(item).text);
        final rate = _value(_rateFor(item).text) / 100 / 12;
        final value = rate == 0
            ? monthly * months
            : monthly * ((math.pow(1 + rate, months) - 1) / rate);
        return sum + value;
      });
}
