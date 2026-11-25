part of 'calculators_page.dart';

class _FreedomCalculator extends ConsumerStatefulWidget {
  const _FreedomCalculator();

  @override
  ConsumerState<_FreedomCalculator> createState() => _FreedomCalculatorState();
}

class _FreedomCalculatorState extends ConsumerState<_FreedomCalculator> {
  final _age = TextEditingController(text: '35');
  final _start = TextEditingController(text: '50000');
  final _returnRate = TextEditingController(text: '7');
  final _saving = TextEditingController(text: '800');
  final _payout = TextEditingController(text: '2500');
  final _dividends = TextEditingController(text: '0');
  final _withdrawalRate = TextEditingController(text: '4');
  final _inflation = TextEditingController(text: '2');
  final _taxRate = TextEditingController(text: '26,375');
  bool _loadedPreferences = false;
  bool _usePortfolio = true;
  bool _considerTaxes = true;
  bool _considerInflation = true;
  Timer? _saveTimer;

  @override
  void dispose() {
    _saveTimer?.cancel();
    for (final controller in [
      _age,
      _start,
      _returnRate,
      _saving,
      _payout,
      _dividends,
      _withdrawalRate,
      _inflation,
      _taxRate,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final preference = ref.watch(preferencesProvider).valueOrNull;
    final portfolio =
        ref
            .watch(investmentsProvider)
            .valueOrNull
            ?.fold<double>(
              0,
              (sum, item) =>
                  sum +
                  ref.read(currencyConverterProvider).investmentValue(item),
            ) ??
        0;
    if (!_loadedPreferences && preference != null) {
      _loadedPreferences = true;
      _age.text = preference.freedomAge.toStringAsFixed(0);
      _start.text = preference.freedomStartCapital.toStringAsFixed(2);
      _usePortfolio = preference.freedomUsePortfolio;
    }
    final age = _value(_age.text).clamp(0, 100).toDouble();
    final start = (_usePortfolio ? portfolio : _value(_start.text))
        .clamp(0, double.infinity)
        .toDouble();
    final saving = _value(_saving.text).clamp(0, double.infinity).toDouble();
    final payout = _value(_payout.text).clamp(0, double.infinity).toDouble();
    final dividends = _value(_dividends.text).clamp(0, payout).toDouble();
    final taxRate = (_value(_taxRate.text) / 100).clamp(0, .99).toDouble();
    final netDividends = _considerTaxes ? dividends * (1 - taxRate) : dividends;
    final withdrawalRate = _value(_withdrawalRate.text) / 100;
    final target = withdrawalRate <= 0
        ? double.infinity
        : (payout - netDividends) * 12 / withdrawalRate;
    final grossReturn = _value(_returnRate.text) / 100;
    final afterTaxReturn = _considerTaxes
        ? grossReturn * (1 - taxRate)
        : grossReturn;
    final inflation = _considerInflation ? _value(_inflation.text) / 100 : 0.0;
    final realAnnualReturn = (1 + afterTaxReturn) / (1 + inflation) - 1;
    final monthlyRate = realAnnualReturn / 12;
    final months = _monthsToTarget(
      start: start,
      monthlySaving: saving,
      monthlyRate: monthlyRate,
      target: target,
    );
    final years = months.isFinite ? months / 12 : double.infinity;
    final freedomAge = years.isFinite ? age + years : double.infinity;
    final chartYears = years.isFinite ? years.ceil().clamp(1, 80) : 40;
    final capitalSpots = <FlSpot>[];
    final targetSpots = <FlSpot>[];
    for (var year = 0; year <= chartYears; year++) {
      final count = year * 12;
      final value = monthlyRate == 0
          ? start + saving * count
          : start * math.pow(1 + monthlyRate, count) +
                saving * ((math.pow(1 + monthlyRate, count) - 1) / monthlyRate);
      capitalSpots.add(FlSpot(year.toDouble(), value.toDouble()));
      targetSpots.add(FlSpot(year.toDouble(), target.isFinite ? target : 0));
    }
    return _CalculatorScaffold(
      title: 'Finanzielle Freiheit',
      resultHeight: 560,
      verticalResultHeight: 760,
      input: Column(
        children: [
          _NumberField(
            controller: _age,
            label: 'Heutiges Alter',
            suffix: 'Jahre',
            onChanged: (_) => _changed(preference),
          ),
          const SizedBox(height: 18),
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            title: const Text('Startkapital aus Depot lesen'),
            subtitle: Text(
              _usePortfolio
                  ? 'Aktueller Depotwert: ${money(portfolio)}'
                  : 'Eigenen Startwert verwenden',
            ),
            value: _usePortfolio,
            onChanged: (value) {
              setState(() => _usePortfolio = value);
              _saveFreedomPreference(preference);
            },
          ),
          const SizedBox(height: 18),
          _NumberField(
            controller: _start,
            label: 'Startkapital',
            suffix: '€',
            onChanged: (_) => _changed(preference),
          ),
          const SizedBox(height: 12),
          _NumberField(
            controller: _returnRate,
            label: 'Erwartete Rendite p. a.',
            suffix: '%',
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 18),
          Card(
            margin: EdgeInsets.zero,
            child: ExpansionTile(
              leading: const Icon(Icons.tune_rounded),
              title: const Text('Steuern & Inflation'),
              subtitle: const Text('Optionale Annahmen einblenden'),
              childrenPadding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
              children: [
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Deutsche Kapitalertragsteuer'),
                  subtitle: Text(
                    _considerTaxes
                        ? 'Steuersatz wird auf Erträge und Dividenden angewendet'
                        : 'Modellrechnung ohne Steuern',
                  ),
                  value: _considerTaxes,
                  onChanged: (value) => setState(() => _considerTaxes = value),
                ),
                if (_considerTaxes)
                  _DefinitionNumberField(
                    controller: _taxRate,
                    label: 'Effektiver Steuersatz',
                    suffix: '%',
                    definition:
                        'Vereinfachter Abzug auf Kapitalerträge. Freibeträge und persönliche Kirchensteuer werden nicht automatisch berücksichtigt.',
                    onChanged: (_) => setState(() {}),
                  ),
                const SizedBox(height: 8),
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Inflation berücksichtigen'),
                  subtitle: Text(
                    _considerInflation
                        ? 'Ergebnisse werden in heutiger Kaufkraft gerechnet'
                        : 'Nominale Modellrechnung ohne Inflation',
                  ),
                  value: _considerInflation,
                  onChanged: (value) =>
                      setState(() => _considerInflation = value),
                ),
                if (_considerInflation)
                  _DefinitionNumberField(
                    controller: _inflation,
                    label: 'Erwartete Inflation p. a.',
                    suffix: '%',
                    definition:
                        'Geschätzter jährlicher Kaufkraftverlust. Aktiviert zeigt das Ergebnis Werte in heutiger Kaufkraft.',
                    onChanged: (_) => setState(() {}),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _NumberField(
            controller: _saving,
            label: 'Monatliche Sparrate',
            suffix: '€',
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 18),
          _NumberField(
            controller: _payout,
            label: 'Monatlicher Wunschbetrag',
            suffix: '€',
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 18),
          _NumberField(
            controller: _dividends,
            label: 'Weitere Dividenden monatlich',
            suffix: '€',
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 18),
          _DefinitionNumberField(
            controller: _withdrawalRate,
            label: 'Nachhaltige Entnahmerate',
            suffix: '%',
            definition:
                'Anteil des Zielkapitals, der pro Jahr entnommen wird. Eine niedrigere Rate erhöht das benötigte Zielkapital.',
            onChanged: (_) => setState(() {}),
          ),
        ],
      ),
      result: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Icon(
            Icons.beach_access_rounded,
            size: 58,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 14),
          Text(
            freedomAge.isFinite
                ? 'Mit ${freedomAge.toStringAsFixed(1)} Jahren'
                : 'Ziel nicht erreichbar',
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 22),
          Wrap(
            spacing: 28,
            runSpacing: 16,
            alignment: WrapAlignment.center,
            children: [
              _Result(label: 'Benötigtes Kapital', value: money(target)),
              _Result(
                label: 'Zeit bis zum Ziel',
                value: years.isFinite
                    ? '${years.toStringAsFixed(1)} Jahre'
                    : '–',
              ),
              _Result(
                label: 'Durch Kapital zu decken',
                value: '${money(payout - netDividends)}/Monat',
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            'Modellrechnung Deutschland · effektive Rendite '
            '${(realAnnualReturn * 100).toStringAsFixed(2)} % p. a. '
            '${_considerTaxes ? 'nach Steuer' : 'ohne Steuer'} · '
            '${_considerInflation ? 'in heutiger Kaufkraft' : 'ohne Inflation'}. '
            'Kursschwankungen und Freibeträge werden nicht simuliert.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: LineChart(
              LineChartData(
                borderData: FlBorderData(show: false),
                gridData: FlGridData(
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (_) => FlLine(
                    color: Theme.of(
                      context,
                    ).dividerColor.withValues(alpha: .22),
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
                    sideTitles: SideTitles(showTitles: true),
                  ),
                ),
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipItems: (spots) => spots
                        .map(
                          (spot) => LineTooltipItem(
                            (spot.barIndex == 0 ? 'Vermögen: ' : 'Ziel: ') +
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
                    spots: capitalSpots,
                    isCurved: true,
                    barWidth: 4,
                    color: Theme.of(context).colorScheme.primary,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: .14),
                    ),
                  ),
                  if (target.isFinite)
                    LineChartBarData(
                      spots: targetSpots,
                      barWidth: 2,
                      color: WealthColors.of(context).expense,
                      dashArray: [8, 5],
                      dotData: const FlDotData(show: false),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 4,
            runSpacing: 4,
            children: [
              Icon(
                Icons.show_chart_rounded,
                color: WealthColors.of(context).chart[3],
              ),
              const Text(' Vermögen  '),
              Icon(
                Icons.remove_rounded,
                color: WealthColors.of(context).expense,
              ),
              const Text(' Zielkapital'),
            ],
          ),
        ],
      ),
    );
  }

  void _changed(UserPreference? preference) {
    setState(() {});
    _saveFreedomPreference(preference);
  }

  /// Stores only the calculator's own fields, half a second after the last
  /// keystroke, so typing neither floods the database nor overwrites other
  /// settings with an older copy.
  void _saveFreedomPreference(UserPreference? preference) {
    if (preference == null) return;
    _saveTimer?.cancel();
    _saveTimer = Timer(const Duration(milliseconds: 500), () {
      ref
          .read(databaseProvider)
          .saveFreedomCalculator(
            preference.userId,
            age: _value(_age.text),
            startCapital: _value(_start.text),
            usePortfolio: _usePortfolio,
          );
    });
  }

  double _monthsToTarget({
    required double start,
    required double monthlySaving,
    required double monthlyRate,
    required double target,
  }) {
    if (!target.isFinite) return double.infinity;
    if (start >= target) return 0;
    if (monthlyRate <= 0) {
      return monthlySaving <= 0
          ? double.infinity
          : (target - start) / monthlySaving;
    }
    if (monthlySaving <= 0) {
      return start <= 0
          ? double.infinity
          : math.log(target / start) / math.log(1 + monthlyRate);
    }
    return math.log(
          (target + monthlySaving / monthlyRate) /
              (start + monthlySaving / monthlyRate),
        ) /
        math.log(1 + monthlyRate);
  }
}
