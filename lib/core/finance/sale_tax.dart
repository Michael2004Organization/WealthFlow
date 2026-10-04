/// German flat-rate tax on security sales (Abgeltungsteuer).
///
/// Covers what a German bank applies automatically within a calendar year:
/// partial exemption for funds (Teilfreistellung), the two loss pots (share
/// losses only offset share gains) and the saver's allowance. Losses only
/// reduce later gains of the same year; a refund for gains that were already
/// taxed earlier is not modelled. Cryptocurrencies are private sales under
/// § 23 EStG and are not subject to this tax.
library;

const _capitalTaxRate = 0.25;
const _solidarityRate = 0.055;

/// Share of a fund's gain that stays tax-free (§ 20 InvStG).
///
/// Equity funds and ETFs are assumed unless the name points to a bond, money
/// market or mixed fund.
double partialExemptionRate(String assetType, String name) {
  if (assetType != 'ETF' && assetType != 'Fonds') return 0;
  final lower = name.toLowerCase();
  if (RegExp(
    r'anleihe|bond|renten|treasury|geldmarkt|money market|overnight',
  ).hasMatch(lower)) {
    return 0;
  }
  if (RegExp(r'misch|multi[- ]?asset|balanced').hasMatch(lower)) return 0.15;
  return 0.30;
}

bool isFlatRateTaxed(String assetType) => assetType != 'Kryptowährung';

/// One sale earlier in the same year, in the order it happened.
final class PriorSale {
  const PriorSale({
    required this.assetType,
    required this.name,
    required this.realizedGain,
  });

  final String assetType;
  final String name;
  final double realizedGain;
}

final class SaleTaxResult {
  const SaleTaxResult({
    required this.taxableGain,
    required this.lossOffset,
    required this.allowanceUsed,
    required this.taxPaid,
  });

  /// Gain after partial exemption, loss pots and allowance.
  final double taxableGain;

  /// Earlier losses of the year used against this gain.
  final double lossOffset;
  final double allowanceUsed;

  /// Capital gains tax plus solidarity surcharge, rounded to cents.
  final double taxPaid;
}

final class _LossPots {
  double shares = 0;
  double general = 0;

  /// Applies a sale to the pots and returns the gain that remains after
  /// offsetting earlier losses.
  ({double remaining, double offset}) apply(double base, bool isShare) {
    if (base <= 0) {
      if (isShare) {
        shares += -base;
      } else {
        general += -base;
      }
      return (remaining: 0, offset: 0);
    }
    var remaining = base;
    if (isShare) {
      final used = remaining < shares ? remaining : shares;
      shares -= used;
      remaining -= used;
    }
    final used = remaining < general ? remaining : general;
    general -= used;
    remaining -= used;
    return (remaining: remaining, offset: base - remaining);
  }
}

double _taxBase(String assetType, String name, double realizedGain) =>
    realizedGain * (1 - partialExemptionRate(assetType, name));

SaleTaxResult saleTax({
  required String assetType,
  required String name,
  required double realizedGain,
  required double allowanceAvailable,
  required List<PriorSale> priorSales,
}) {
  if (!isFlatRateTaxed(assetType)) {
    return const SaleTaxResult(
      taxableGain: 0,
      lossOffset: 0,
      allowanceUsed: 0,
      taxPaid: 0,
    );
  }
  final pots = _LossPots();
  for (final sale in priorSales) {
    if (!isFlatRateTaxed(sale.assetType)) continue;
    pots.apply(
      _taxBase(sale.assetType, sale.name, sale.realizedGain),
      sale.assetType == 'Aktie',
    );
  }
  final offset = pots.apply(
    _taxBase(assetType, name, realizedGain),
    assetType == 'Aktie',
  );
  final allowanceUsed = offset.remaining
      .clamp(0, allowanceAvailable < 0 ? 0 : allowanceAvailable)
      .toDouble();
  final taxable = offset.remaining - allowanceUsed;
  final capitalTax = taxable * _capitalTaxRate;
  final taxPaid =
      ((capitalTax + capitalTax * _solidarityRate) * 100).round() / 100;
  return SaleTaxResult(
    taxableGain: taxable,
    lossOffset: offset.offset,
    allowanceUsed: allowanceUsed,
    taxPaid: taxPaid,
  );
}
