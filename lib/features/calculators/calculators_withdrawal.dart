part of 'calculators_page.dart';

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
