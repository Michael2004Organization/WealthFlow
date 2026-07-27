class CompoundInterestResult {
  const CompoundInterestResult({required this.finalCapital, required this.deposits});
  final double finalCapital;
  final double deposits;
  double get profit => finalCapital - deposits;
}

CompoundInterestResult compoundInterest({required double initialCapital, required double monthlyContribution, required double annualRatePercent, required int years}) {
  if (initialCapital < 0 || monthlyContribution < 0 || annualRatePercent < 0 || years < 0) throw ArgumentError('Financial inputs must not be negative.');
  final months = years * 12;
  final monthlyRate = annualRatePercent / 100 / 12;
  var capital = initialCapital;
  for (var month = 0; month < months; month++) {
    capital = capital * (1 + monthlyRate) + monthlyContribution;
  }
  return CompoundInterestResult(finalCapital: capital, deposits: initialCapital + monthlyContribution * months);
}

class TripCostResult {
  const TripCostResult({required this.perTrip, required this.perWeek});
  final double perTrip;
  final double perWeek;
  double get perMonth => perWeek * 52 / 12;
  double get perYear => perWeek * 52;
}

TripCostResult tripCosts({required double kilometers, required double litersPer100Km, required double pricePerLiter, required double tripsPerWeek}) {
  if ([kilometers, litersPer100Km, pricePerLiter, tripsPerWeek].any((value) => value < 0)) throw ArgumentError('Trip inputs must not be negative.');
  final perTrip = kilometers / 100 * litersPer100Km * pricePerLiter;
  return TripCostResult(perTrip: perTrip, perWeek: perTrip * tripsPerWeek);
}
