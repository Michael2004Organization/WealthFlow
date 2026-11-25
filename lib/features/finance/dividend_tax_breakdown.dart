import 'package:flutter/material.dart';
import 'package:wealthflow_core/finance/dividend_math.dart';
import 'package:wealthflow_core/finance/withholding_tax_defaults.dart';

import '../../app/app_theme.dart';
import '../../core/widgets/common_widgets.dart';

/// Gross to net of one dividend payout, line by line as on a bank statement:
/// foreign tax, conversion, partial exemption, allowance, German tax.
class DividendTaxBreakdown extends StatelessWidget {
  const DividendTaxBreakdown({
    required this.tax,
    required this.sourceCurrency,
    required this.accountCurrency,
    required this.exchangeRate,
    required this.withholdingTaxRate,
    required this.country,
    this.dense = false,
    super.key,
  });

  final DividendTaxResult tax;
  final String sourceCurrency;
  final String accountCurrency;
  final double exchangeRate;
  final double withholdingTaxRate;
  final String country;

  /// Compact rows for small dialogs.
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final colors = WealthColors.of(context);
    final converted =
        sourceCurrency.toUpperCase() != accountCurrency.toUpperCase();
    final rows = <Widget>[
      _TaxRow(
        label: 'Brutto',
        value: tax.grossSource,
        currency: sourceCurrency,
        emphasized: true,
        dense: dense,
      ),
      if (tax.withholdingTaxSource > 0)
        _TaxRow(
          label:
              'Quellensteuer ${_percent(withholdingTaxRate)} %'
              '${country.trim().isEmpty ? '' : ' · ${country.trim()}'}',
          value: -tax.withholdingTaxSource,
          currency: sourceCurrency,
          dense: dense,
        ),
      if (converted) ...[
        if (tax.withholdingTaxSource > 0)
          _TaxRow(
            label: 'Nach Quellensteuer',
            value: tax.grossSource - tax.withholdingTaxSource,
            currency: sourceCurrency,
            dense: dense,
          ),
        _Note(
          '${sourceCurrency.toUpperCase()} → ${accountCurrency.toUpperCase()}'
          ' · Kurs ${exchangeRate.toStringAsFixed(4)}',
        ),
        _TaxRow(
          label: 'Umgerechnet',
          value: tax.gross - tax.withholdingTax,
          currency: accountCurrency,
          dense: dense,
        ),
      ],
      if (tax.partialExemption > 0)
        _TaxRow(
          label: 'Teilfreistellung (steuerfrei)',
          value: tax.partialExemption,
          currency: accountCurrency,
          informational: true,
          dense: dense,
        ),
      if (tax.allowanceUsed > 0)
        _TaxRow(
          label: 'Freistellungsauftrag genutzt',
          value: tax.allowanceUsed,
          currency: accountCurrency,
          informational: true,
          dense: dense,
        ),
      _TaxRow(
        label: 'Steuerpflichtig',
        value: tax.taxable,
        currency: accountCurrency,
        informational: true,
        dense: dense,
      ),
      if (tax.creditableWithholdingTax > 0)
        _TaxRow(
          label: 'Angerechnete Quellensteuer',
          value: tax.creditableWithholdingTax,
          currency: accountCurrency,
          informational: true,
          dense: dense,
        ),
      _TaxRow(
        label: tax.creditableWithholdingTax > 0
            ? 'Kapitalertragsteuer 25 % nach Anrechnung'
            : 'Kapitalertragsteuer 25 %',
        value: -tax.germanCapitalTax,
        currency: accountCurrency,
        dense: dense,
      ),
      _TaxRow(
        label: 'Solidaritätszuschlag 5,5 %',
        value: -tax.solidaritySurcharge,
        currency: accountCurrency,
        dense: dense,
      ),
      if (tax.churchTax > 0)
        _TaxRow(
          label: 'Kirchensteuer',
          value: -tax.churchTax,
          currency: accountCurrency,
          dense: dense,
        ),
      Divider(height: dense ? 12 : 18),
      _TaxRow(
        label: 'Netto',
        value: tax.net,
        currency: accountCurrency,
        emphasized: true,
        dense: dense,
      ),
    ];
    final hint = dividendTaxHint(tax, country, accountCurrency);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ...rows,
        if (hint != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline_rounded, size: 16, color: colors.muted),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    hint,
                    style: TextStyle(fontSize: 12, color: colors.muted),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

/// Why part of the foreign tax was not credited, if it was not.
String? dividendTaxHint(
  DividendTaxResult tax,
  String country,
  String accountCurrency,
) {
  final open = tax.nonCreditableWithholdingTax;
  if (open <= 0) return null;
  final amount = money(open, currency: accountCurrency);
  final defaults = withholdingTaxDefaultFor(country);
  if (defaults != null && defaults.reclaimable > 0) {
    return '$amount Quellensteuer sind in Deutschland nicht anrechenbar. '
        'Bis zu ${_percent(defaults.reclaimable)} % kannst du in '
        '${defaults.country} zurückfordern.';
  }
  return '$amount Quellensteuer sind noch nicht angerechnet, weil der '
      'Freistellungsauftrag die deutsche Steuer abdeckt. Die Bank verrechnet '
      'sie später im Jahr (Quellensteuertopf).';
}

String _percent(double value) => value == value.roundToDouble()
    ? value.toStringAsFixed(0)
    : value
          .toStringAsFixed(2)
          .replaceFirst(RegExp(r'0+$'), '')
          .replaceAll('.', ',');

class _Note extends StatelessWidget {
  const _Note(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 2),
    child: Text(
      text,
      textAlign: TextAlign.right,
      style: Theme.of(context).textTheme.bodySmall,
    ),
  );
}

class _TaxRow extends StatelessWidget {
  const _TaxRow({
    required this.label,
    required this.value,
    required this.currency,
    this.emphasized = false,
    this.informational = false,
    this.dense = false,
  });

  final String label;
  final double value;
  final String currency;
  final bool emphasized;
  final bool informational;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;
    final text = Text(
      label,
      style: TextStyle(
        fontSize: dense ? 13 : null,
        fontWeight: emphasized ? FontWeight.w800 : FontWeight.w500,
        color: informational ? muted : null,
      ),
    );
    final amount = Text(
      '${value < 0 ? '−' : ''}${money(value.abs(), currency: currency)}',
      textAlign: TextAlign.right,
      style: TextStyle(
        fontSize: dense ? 13 : null,
        fontWeight: emphasized ? FontWeight.w800 : FontWeight.w600,
        color: value < 0
            ? WealthColors.of(context).expense
            : informational
            ? muted
            : null,
      ),
    );
    return Padding(
      padding: EdgeInsets.symmetric(vertical: dense ? 3 : 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: text),
          const SizedBox(width: 12),
          amount,
        ],
      ),
    );
  }
}
