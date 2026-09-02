const supportedPortfolioAssetClasses = <String>[
  'Aktie',
  'ETF',
  'Kryptowährung',
  'Anleihe',
  'Fonds',
  'Hebelprodukt',
  'Derivate',
];

String normalizePortfolioIdentityPart(String value) =>
    value.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');

String portfolioMasterIdentity({
  required String assetType,
  required String name,
  String symbol = '',
  String isin = '',
  String wkn = '',
  String instrumentSubtype = '',
  String issuer = '',
  String underlying = '',
  DateTime? maturityDate,
}) {
  final type = normalizePortfolioIdentityPart(assetType);
  final normalizedIsin = isin.trim().toUpperCase();
  final normalizedWkn = wkn.trim().toUpperCase();
  final normalizedSymbol = symbol.trim().toUpperCase();
  if (normalizedIsin.isNotEmpty) return '$type|isin:$normalizedIsin';
  if (normalizedWkn.isNotEmpty) return '$type|wkn:$normalizedWkn';
  if (normalizedSymbol.isNotEmpty) return '$type|symbol:$normalizedSymbol';

  final normalizedName = normalizePortfolioIdentityPart(name);
  final subtype = normalizePortfolioIdentityPart(instrumentSubtype);
  final normalizedIssuer = normalizePortfolioIdentityPart(issuer);
  final normalizedUnderlying = normalizePortfolioIdentityPart(underlying);
  final maturity = maturityDate == null
      ? ''
      : '${maturityDate.year.toString().padLeft(4, '0')}-'
            '${maturityDate.month.toString().padLeft(2, '0')}-'
            '${maturityDate.day.toString().padLeft(2, '0')}';
  return '$type|name:$normalizedName|type:$subtype|issuer:$normalizedIssuer|'
      'underlying:$normalizedUnderlying|maturity:$maturity';
}

String? portfolioMasterValidationError({
  required String assetType,
  required String name,
  String symbol = '',
  String isin = '',
  String wkn = '',
  String instrumentSubtype = '',
  String issuer = '',
  String underlying = '',
}) {
  if (!supportedPortfolioAssetClasses.contains(assetType)) {
    return 'Unzulässige Anlageklasse.';
  }
  if (name.trim().isEmpty) return 'Name fehlt.';
  if (assetType == 'Kryptowährung' && symbol.trim().isEmpty) {
    return 'Für Kryptowährungen ist ein Symbol erforderlich.';
  }
  if (const {'Aktie', 'ETF', 'Fonds'}.contains(assetType) &&
      symbol.trim().isEmpty &&
      isin.trim().isEmpty &&
      wkn.trim().isEmpty) {
    return 'Symbol, ISIN oder WKN fehlt.';
  }
  if (assetType == 'Anleihe' &&
      isin.trim().isEmpty &&
      wkn.trim().isEmpty &&
      issuer.trim().isEmpty) {
    return 'ISIN, WKN oder Emittent fehlt.';
  }
  if (const {'Derivate', 'Hebelprodukt'}.contains(assetType) &&
      (instrumentSubtype.trim().isEmpty || underlying.trim().isEmpty)) {
    return 'Typ und Basiswert sind erforderlich.';
  }
  return null;
}
