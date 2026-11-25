import 'dart:async';
import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:wealthflow_core/database/app_database.dart';
import 'package:wealthflow_core/finance/amount_input.dart';
import 'package:wealthflow_core/finance/budget_period.dart';

import '../../app/app_theme.dart';
import '../../core/providers.dart';
import '../../core/widgets/common_widgets.dart';
part 'calculators_account_target.dart';
part 'calculators_freedom.dart';
part 'calculators_fuel.dart';
part 'calculators_withdrawal.dart';
part 'calculators_compound.dart';

class CalculatorsPage extends StatelessWidget {
  const CalculatorsPage({super.key});
  @override
  Widget build(BuildContext context) => const DefaultTabController(
    length: 5,
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
            Tab(icon: Icon(Icons.flag_circle_outlined), text: 'Kontoziel'),
          ],
        ),
        Expanded(
          child: TabBarView(
            children: [
              _CompoundCalculator(),
              _WithdrawalCalculator(),
              _FuelCalculator(),
              _FreedomCalculator(),
              _AccountTargetCalculator(),
            ],
          ),
        ),
      ],
    ),
  );
}

class _CalculatorScaffold extends StatelessWidget {
  const _CalculatorScaffold({
    required this.title,
    required this.input,
    required this.result,
    this.resultHeight = 480,
    this.verticalResultHeight = 660,
  });
  final String title;
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
            PageHeader(title: title),
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

double _value(String input) => parseAmount(input) ?? 0;
