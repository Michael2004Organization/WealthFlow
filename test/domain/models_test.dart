import 'package:flutter_test/flutter_test.dart';
import 'package:wealthflow/src/domain/models.dart';

void main() {
  test('FinanceData survives JSON round trip', () {
    const source = FinanceData(accounts: [Account(id: 'a', name: 'Giro', bank: 'Bank', balance: 12345)]);
    final restored = FinanceData.decode(source.encode());
    expect(restored.accounts.single.name, 'Giro');
    expect(restored.accountTotal, 12345);
  });
  test('position calculates value, gain and performance', () {
    const position = Position(id: 'p', name: 'ETF', symbol: 'ETF', type: AssetType.etf, quantity: 2, purchasePrice: 1000, currentPrice: 1250, fees: 100);
    expect(position.value, 2500);
    expect(position.gain, 400);
    expect(position.performance, 25);
  });
}
