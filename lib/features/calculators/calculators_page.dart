import 'dart:math' as math;

import 'package:drift/drift.dart' show Value;
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../../core/database/app_database.dart';
import '../../core/widgets/common_widgets.dart';

class CalculatorsPage extends StatelessWidget {
  const CalculatorsPage({super.key});
  @override
  Widget build(BuildContext context) => const DefaultTabController(
    length: 4,
    child: Column(
      children: [
        TabBar(
          isScrollable: true,
          tabs: [
            Tab(icon: Icon(Icons.show_chart_rounded), text: 'Zinseszins'),
            Tab(icon: Icon(Icons.payments_outlined), text: 'Entnahme'),
            Tab(
              icon: Icon(Icons.local_gas_station_rounded),
              text: 'Spritkosten',
            ),
            Tab(icon: Icon(Icons.beach_access_rounded), text: 'Freiheit'),
          ],
        ),
        Expanded(
          child: TabBarView(
            children: [
              _CompoundCalculator(),
              _WithdrawalCalculator(),
              _FuelCalculator(),
              _FreedomCalculator(),
            ],
          ),
        ),
      ],
    ),
  );
}

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
      (sum, item) => sum + item.quantity * item.currentPrice,
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
      subtitle: 'Berechne, wie Sparrate und Rendite dein Vermögen entwickeln.',
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
                color: Colors.green,
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
                    color: Colors.teal,
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

class _WithdrawalCalculator extends StatefulWidget {
  const _WithdrawalCalculator();
  @override
  State<_WithdrawalCalculator> createState() => _WithdrawalCalculatorState();
}

class _WithdrawalCalculatorState extends State<_WithdrawalCalculator> {
  final _capital = TextEditingController(text: '500000');
  final _rate = TextEditingController(text: '5');
  final _years = TextEditingController(text: '30');
  final _withdrawal = TextEditingController(text: '2000');
  String _mode = 'amount';
  @override
  void dispose() {
    _capital.dispose();
    _rate.dispose();
    _years.dispose();
    _withdrawal.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final capital = _value(_capital.text);
    final monthlyRate = _value(_rate.text) / 100 / 12;
    final months = (_value(_years.text).clamp(1, 100) * 12).round();
    final monthly = monthlyRate == 0
        ? capital / months
        : capital * monthlyRate / (1 - math.pow(1 + monthlyRate, -months));
    final wanted = _value(_withdrawal.text);
    final durationMonths = wanted <= 0
        ? 0.0
        : monthlyRate == 0
        ? capital / wanted
        : wanted <= capital * monthlyRate
        ? double.infinity
        : -math.log(1 - capital * monthlyRate / wanted) /
              math.log(1 + monthlyRate);
    final chartWithdrawal = _mode == 'amount' ? monthly : wanted;
    final chartMonths = _mode == 'amount'
        ? months
        : durationMonths.isFinite
        ? durationMonths.ceil().clamp(1, 1200)
        : 600;
    final remaining = <FlSpot>[FlSpot(0, capital.clamp(0, double.infinity))];
    var balance = capital;
    for (var month = 1; month <= chartMonths; month++) {
      balance = (balance * (1 + monthlyRate) - chartWithdrawal)
          .clamp(0, double.infinity)
          .toDouble();
      if (month % 12 == 0 || month == chartMonths) {
        remaining.add(FlSpot(month / 12, balance));
      }
    }
    return _CalculatorScaffold(
      title: 'Entnahmerechner',
      subtitle: 'Berechne den Monatsbetrag oder wie lange dein Kapital reicht.',
      resultHeight: 560,
      verticalResultHeight: 680,
      input: Column(
        children: [
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'amount', label: Text('Betrag')),
              ButtonSegment(value: 'duration', label: Text('Reichweite')),
            ],
            selected: {_mode},
            onSelectionChanged: (value) => setState(() => _mode = value.first),
          ),
          const SizedBox(height: 16),
          _NumberField(
            controller: _capital,
            label: 'Depotwert',
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
          const SizedBox(height: 12),
          if (_mode == 'amount')
            _NumberField(
              controller: _years,
              label: 'Laufzeit',
              suffix: 'Jahre',
              onChanged: (_) => setState(() {}),
            )
          else
            _NumberField(
              controller: _withdrawal,
              label: 'Gewünschte monatliche Entnahme',
              suffix: '€',
              onChanged: (_) => setState(() {}),
            ),
        ],
      ),
      result: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Icon(
            Icons.payments_rounded,
            size: 64,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 18),
          Text(
            _mode == 'amount'
                ? money(monthly)
                : durationMonths.isInfinite
                ? 'Dauerhaft'
                : '${(durationMonths / 12).toStringAsFixed(1)} Jahre',
            style: Theme.of(
              context,
            ).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w900),
          ),
          Text(
            _mode == 'amount'
                ? 'monatlich entnehmbar'
                : durationMonths.isInfinite
                ? 'Rendite deckt die Entnahme rechnerisch'
                : 'mit ${money(wanted)} pro Monat',
          ),
          const SizedBox(height: 24),
          _Result(
            label: _mode == 'amount' ? 'Jährliche Entnahme' : 'Gesamte Monate',
            value: _mode == 'amount'
                ? money(monthly * 12)
                : durationMonths.isInfinite
                ? '∞'
                : '${durationMonths.floor()}',
          ),
          const SizedBox(height: 10),
          Text(
            'Die Berechnung nimmt eine konstante Rendite und monatliche Entnahme an. Steuern und Inflation sind nicht enthalten.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 18),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Kapitalverlauf',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: LineChart(
              LineChartData(
                minY: 0,
                borderData: FlBorderData(show: false),
                gridData: FlGridData(
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (_) => FlLine(
                    color: Theme.of(context).dividerColor.withValues(alpha: .2),
                  ),
                ),
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    axisNameWidget: const Text('Jahre'),
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      interval: (chartMonths / 12 / 5).clamp(1, 20).toDouble(),
                    ),
                  ),
                ),
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipItems: (spots) => spots
                        .map(
                          (spot) => LineTooltipItem(
                            '${spot.x.toStringAsFixed(1)} Jahre\n${money(spot.y)}',
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
                    spots: remaining,
                    isCurved: true,
                    barWidth: 4,
                    color: Theme.of(context).colorScheme.primary,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: .16),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

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
      subtitle: 'Vergleiche zwei Preise für eine Strecke oder Tankfüllung.',
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
                  color: Colors.indigo,
                ),
                _FuelPriceCard(
                  label: 'PREIS B',
                  fuelPrice: _value(_priceB.text),
                  cost: costB,
                  color: Colors.teal,
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
                color: Colors.orange,
              ),
              _Result(
                label: 'Direkte Differenz',
                value: money(difference),
                color: Colors.deepOrange,
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
            fuelPrice.toStringAsFixed(3).replaceAll('.', ',') + ' €/l',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
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

  @override
  void dispose() {
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
              (sum, item) => sum + item.quantity * item.currentPrice,
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
      subtitle:
          'Berechne Zielkapital und Alter, ab dem passive Einnahmen deinen Wunschbetrag decken.',
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
                  ? 'Aktueller Depotwert: ' + money(portfolio)
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
                value: money(payout - netDividends) + '/Monat',
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            'Modellrechnung Deutschland · effektive Rendite ' +
                (realAnnualReturn * 100).toStringAsFixed(2) +
                ' % p. a. ' +
                (_considerTaxes ? 'nach Steuer' : 'ohne Steuer') +
                ' · ' +
                (_considerInflation
                    ? 'in heutiger Kaufkraft'
                    : 'ohne Inflation') +
                '. Kursschwankungen und Freibeträge werden nicht simuliert.',
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
                      color: Colors.orange,
                      dashArray: [8, 5],
                      dotData: const FlDotData(show: false),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 4,
            runSpacing: 4,
            children: [
              Icon(Icons.show_chart_rounded, color: Colors.indigo),
              Text(' Vermögen  '),
              Icon(Icons.remove_rounded, color: Colors.orange),
              Text(' Zielkapital'),
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

  Future<void> _saveFreedomPreference(UserPreference? preference) async {
    if (preference == null) return;
    await ref
        .read(databaseProvider)
        .savePreferences(
          UserPreferencesCompanion.insert(
            userId: preference.userId,
            themeMode: Value(preference.themeMode),
            locale: Value(preference.locale),
            currency: Value(preference.currency),
            dateFormat: Value(preference.dateFormat),
            serverMode: Value(preference.serverMode),
            serverUrl: Value(preference.serverUrl),
            serverPort: Value(preference.serverPort),
            serverUsername: Value(preference.serverUsername),
            selectedHouseholdAccountId: Value(
              preference.selectedHouseholdAccountId,
            ),
            dataFilePath: Value(preference.dataFilePath),
            freedomAge: Value(_value(_age.text)),
            freedomStartCapital: Value(_value(_start.text)),
            freedomUsePortfolio: Value(_usePortfolio),
            lastSyncAt: Value(preference.lastSyncAt),
            updatedAt: DateTime.now().toUtc(),
          ),
        );
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

class _CalculatorScaffold extends StatelessWidget {
  const _CalculatorScaffold({
    required this.title,
    required this.subtitle,
    required this.input,
    required this.result,
    this.resultHeight = 480,
    this.verticalResultHeight = 660,
  });
  final String title;
  final String subtitle;
  final Widget input;
  final Widget result;
  final double resultHeight;
  final double verticalResultHeight;
  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: const EdgeInsets.all(24),
    child: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PageHeader(title: title, subtitle: subtitle),
            LayoutBuilder(
              builder: (context, constraints) {
                final vertical = constraints.maxWidth < 760;
                final inputs = Card(
                  child: Padding(
                    padding: const EdgeInsets.all(22),
                    child: input,
                  ),
                );
                final results = Card(
                  child: Padding(
                    padding: const EdgeInsets.all(22),
                    child: SizedBox(
                      height: vertical ? verticalResultHeight : resultHeight,
                      child: result,
                    ),
                  ),
                );
                return vertical
                    ? Column(
                        children: [inputs, const SizedBox(height: 16), results],
                      )
                    : Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(width: 350, child: inputs),
                          const SizedBox(width: 16),
                          Expanded(child: results),
                        ],
                      );
              },
            ),
          ],
        ),
      ),
    ),
  );
}

class _NumberField extends StatelessWidget {
  const _NumberField({
    required this.controller,
    required this.label,
    required this.suffix,
    required this.onChanged,
  });
  final TextEditingController controller;
  final String label;
  final String suffix;
  final ValueChanged<String> onChanged;
  @override
  Widget build(BuildContext context) => TextField(
    controller: controller,
    keyboardType: const TextInputType.numberWithOptions(decimal: true),
    onChanged: onChanged,
    decoration: InputDecoration(labelText: label, suffixText: suffix),
  );
}

class _DefinitionNumberField extends StatefulWidget {
  const _DefinitionNumberField({
    required this.controller,
    required this.label,
    required this.suffix,
    required this.definition,
    required this.onChanged,
  });

  final TextEditingController controller;
  final String label;
  final String suffix;
  final String definition;
  final ValueChanged<String> onChanged;

  @override
  State<_DefinitionNumberField> createState() => _DefinitionNumberFieldState();
}

class _DefinitionNumberFieldState extends State<_DefinitionNumberField> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      _NumberField(
        controller: widget.controller,
        label: widget.label,
        suffix: widget.suffix,
        onChanged: widget.onChanged,
      ),
      Align(
        alignment: Alignment.centerLeft,
        child: TextButton.icon(
          onPressed: () => setState(() => _expanded = !_expanded),
          icon: Icon(
            _expanded ? Icons.expand_less_rounded : Icons.info_outline_rounded,
            size: 18,
          ),
          label: Text(_expanded ? 'Erklärung ausblenden' : 'Was bedeutet das?'),
        ),
      ),
      if (_expanded)
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
          child: Text(widget.definition),
        ),
    ],
  );
}

class _Result extends StatelessWidget {
  const _Result({required this.label, required this.value, this.color});
  final String label;
  final String value;
  final Color? color;
  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(label),
      Text(
        value,
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.w800,
          color: color,
        ),
      ),
    ],
  );
}

double _value(String input) =>
    double.tryParse(input.trim().replaceAll(',', '.')) ?? 0;
