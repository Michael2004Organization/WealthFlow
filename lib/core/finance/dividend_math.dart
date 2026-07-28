double dividendPerMonth(double monthlyPerShare, double quantity) =>
    monthlyPerShare * quantity;

double dividendPerQuarterFromMonth(double monthlyTotal) => monthlyTotal * 3;

double dividendPerYearFromMonth(double monthlyTotal) => monthlyTotal * 12;
