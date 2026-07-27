import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../../core/widgets/common_widgets.dart';

class CalculatorsPage extends StatelessWidget {
  const CalculatorsPage({super.key});
  @override
  Widget build(BuildContext context) => const DefaultTabController(
    length: 3,
    child: Column(
      children: [
        TabBar(
          isScrollable: true,
          tabs: [
            Tab(icon: Icon(Icons.show_chart_rounded), text: 'Zinseszins'),
            Tab(icon: Icon(Icons.payments_outlined), text: 'Entnahme'),
            Tab(
              icon: Icon(Icons.local_gas_station_rounded),
              text: 'Fahrtkosten',
            ),
          ],
        ),
        Expanded(
          child: TabBarView(
            children: [
              _CompoundCalculator(),
              _WithdrawalCalculator(),
              _FuelCalculator(),
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
  @override
  void dispose() {
    _start.dispose();
    _monthly.dispose();
    _rate.dispose();
    _years.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final portfolio =
        ref
            .watch(investmentsProvider)
            .valueOrNull
            ?.fold<double>(
              0,
              (sum, item) => sum + item.quantity * item.currentPrice,
            ) ??
        0;
    final start = _value(_start.text);
    final monthly = _value(_monthly.text);
    final rate = _value(_rate.text) / 100 / 12;
    final years = _value(_years.text).round().clamp(1, 80);
    final months = years * 12;
    final end = rate == 0
        ? start + monthly * months
        : start * math.pow(1 + rate, months) +
              monthly * ((math.pow(1 + rate, months) - 1) / rate);
    final paid = start + monthly * months;
    final spots = <FlSpot>[];
    for (var year = 0; year <= years; year++) {
      final m = year * 12;
      final value = rate == 0
          ? start + monthly * m
          : start * math.pow(1 + rate, m) +
                monthly * ((math.pow(1 + rate, m) - 1) / rate);
      spots.add(FlSpot(year.toDouble(), value.toDouble()));
    }
    return _CalculatorScaffold(
      title: 'Zinseszinsrechner',
      subtitle: 'Berechne, wie Sparrate und Rendite dein Vermögen entwickeln.',
      input: Column(
        children: [
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
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
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
  @override
  void dispose() {
    _capital.dispose();
    _rate.dispose();
    _years.dispose();
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
    return _CalculatorScaffold(
      title: 'Entnahmerechner',
      subtitle:
          'Ermittle eine gleichmäßige Entnahme bis zum Ende der Laufzeit.',
      input: Column(
        children: [
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
          _NumberField(
            controller: _years,
            label: 'Laufzeit',
            suffix: 'Jahre',
            onChanged: (_) => setState(() {}),
          ),
        ],
      ),
      result: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.payments_rounded,
            size: 64,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 18),
          Text(
            money(monthly),
            style: Theme.of(
              context,
            ).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w900),
          ),
          const Text('monatlich entnehmbar'),
          const SizedBox(height: 24),
          _Result(label: 'Jährliche Entnahme', value: money(monthly * 12)),
          const SizedBox(height: 10),
          Text(
            'Die Berechnung nimmt eine konstante Rendite und monatliche Entnahme an. Steuern und Inflation sind nicht enthalten.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
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
  final _trips = TextEditingController(text: '10');
  @override
  void dispose() {
    _distance.dispose();
    _consumption.dispose();
    _price.dispose();
    _trips.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final trip =
        _value(_distance.text) /
        100 *
        _value(_consumption.text) *
        _value(_price.text);
    final week = trip * _value(_trips.text);
    return _CalculatorScaffold(
      title: 'Fahrtkostenrechner',
      subtitle: 'Berechne Arbeitsweg, Urlaub oder eine beliebige Strecke.',
      input: Column(
        children: [
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
          const SizedBox(height: 12),
          _NumberField(
            controller: _price,
            label: 'Kraftstoffpreis',
            suffix: '€/l',
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 12),
          _NumberField(
            controller: _trips,
            label: 'Fahrten pro Woche',
            suffix: '',
            onChanged: (_) => setState(() {}),
          ),
        ],
      ),
      result: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _Result(label: 'Pro Fahrt', value: money(trip)),
          const SizedBox(height: 16),
          _Result(label: 'Pro Woche', value: money(week)),
          const SizedBox(height: 16),
          _Result(label: 'Pro Monat', value: money(week * 52 / 12)),
          const SizedBox(height: 16),
          _Result(
            label: 'Pro Jahr',
            value: money(week * 52),
            color: Colors.orange,
          ),
        ],
      ),
    );
  }
}

class _CalculatorScaffold extends StatelessWidget {
  const _CalculatorScaffold({
    required this.title,
    required this.subtitle,
    required this.input,
    required this.result,
  });
  final String title;
  final String subtitle;
  final Widget input;
  final Widget result;
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
                      height: vertical ? 340 : 420,
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
