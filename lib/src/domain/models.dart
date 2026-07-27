import 'dart:convert';

enum AssetType { stock, etf, crypto, bond, leveraged, knockout, fund, metal }

enum TransactionKind { income, expense }

class Account {
  const Account({required this.id, required this.name, required this.bank, required this.balance, this.currency = 'EUR', this.iban = '', this.bic = '', this.owner = '', this.available, this.notes = ''});
  final String id;
  final String name;
  final String bank;
  final int balance;
  final String currency;
  final String iban;
  final String bic;
  final String owner;
  final int? available;
  final String notes;
  Map<String, Object?> toJson() => {'id': id, 'name': name, 'bank': bank, 'balance': balance, 'currency': currency, 'iban': iban, 'bic': bic, 'owner': owner, 'available': available, 'notes': notes};
  factory Account.fromJson(Map<String, Object?> json) => Account(id: json['id']! as String, name: json['name']! as String, bank: json['bank']! as String, balance: json['balance']! as int, currency: json['currency']! as String, iban: json['iban'] as String? ?? '', bic: json['bic'] as String? ?? '', owner: json['owner'] as String? ?? '', available: json['available'] as int?, notes: json['notes'] as String? ?? '');
}

class Position {
  const Position({required this.id, required this.name, required this.symbol, required this.type, required this.quantity, required this.purchasePrice, required this.currentPrice, this.broker = '', this.isin = '', this.fees = 0, this.notes = ''});
  final String id;
  final String name;
  final String symbol;
  final AssetType type;
  final double quantity;
  final int purchasePrice;
  final int currentPrice;
  final String broker;
  final String isin;
  final int fees;
  final String notes;
  int get value => (quantity * currentPrice).round();
  int get gain => value - (quantity * purchasePrice).round() - fees;
  double get performance => purchasePrice == 0 ? 0 : (currentPrice / purchasePrice - 1) * 100;
  Map<String, Object?> toJson() => {'id': id, 'name': name, 'symbol': symbol, 'type': type.name, 'quantity': quantity, 'purchasePrice': purchasePrice, 'currentPrice': currentPrice, 'broker': broker, 'isin': isin, 'fees': fees, 'notes': notes};
  factory Position.fromJson(Map<String, Object?> json) => Position(id: json['id']! as String, name: json['name']! as String, symbol: json['symbol']! as String, type: AssetType.values.byName(json['type']! as String), quantity: (json['quantity']! as num).toDouble(), purchasePrice: json['purchasePrice']! as int, currentPrice: json['currentPrice']! as int, broker: json['broker'] as String? ?? '', isin: json['isin'] as String? ?? '', fees: json['fees'] as int? ?? 0, notes: json['notes'] as String? ?? '');
}

class LedgerEntry {
  const LedgerEntry({required this.id, required this.date, required this.amount, required this.kind, required this.category, this.merchant = '', this.description = '', this.paymentMethod = ''});
  final String id;
  final DateTime date;
  final int amount;
  final TransactionKind kind;
  final String category;
  final String merchant;
  final String description;
  final String paymentMethod;
  Map<String, Object?> toJson() => {'id': id, 'date': date.toIso8601String(), 'amount': amount, 'kind': kind.name, 'category': category, 'merchant': merchant, 'description': description, 'paymentMethod': paymentMethod};
  factory LedgerEntry.fromJson(Map<String, Object?> json) => LedgerEntry(id: json['id']! as String, date: DateTime.parse(json['date']! as String), amount: json['amount']! as int, kind: TransactionKind.values.byName(json['kind']! as String), category: json['category']! as String, merchant: json['merchant'] as String? ?? '', description: json['description'] as String? ?? '', paymentMethod: json['paymentMethod'] as String? ?? '');
}

class Vehicle {
  const Vehicle({required this.id, required this.name, required this.kind, required this.year, this.plate = '', this.fuel = '', this.tankSize = 0, this.cost = 0});
  final String id;
  final String name;
  final String kind;
  final int year;
  final String plate;
  final String fuel;
  final double tankSize;
  final int cost;
  Map<String, Object?> toJson() => {'id': id, 'name': name, 'kind': kind, 'year': year, 'plate': plate, 'fuel': fuel, 'tankSize': tankSize, 'cost': cost};
  factory Vehicle.fromJson(Map<String, Object?> json) => Vehicle(id: json['id']! as String, name: json['name']! as String, kind: json['kind']! as String, year: json['year']! as int, plate: json['plate'] as String? ?? '', fuel: json['fuel'] as String? ?? '', tankSize: (json['tankSize'] as num?)?.toDouble() ?? 0, cost: json['cost'] as int? ?? 0);
}

class FinanceData {
  const FinanceData({this.accounts = const [], this.positions = const [], this.entries = const [], this.vehicles = const []});
  final List<Account> accounts;
  final List<Position> positions;
  final List<LedgerEntry> entries;
  final List<Vehicle> vehicles;
  int get accountTotal => accounts.fold(0, (sum, item) => sum + item.balance);
  int get portfolioTotal => positions.fold(0, (sum, item) => sum + item.value);
  int get income => entries.where((e) => e.kind == TransactionKind.income).fold(0, (sum, e) => sum + e.amount);
  int get expenses => entries.where((e) => e.kind == TransactionKind.expense).fold(0, (sum, e) => sum + e.amount);
  FinanceData copyWith({List<Account>? accounts, List<Position>? positions, List<LedgerEntry>? entries, List<Vehicle>? vehicles}) => FinanceData(accounts: accounts ?? this.accounts, positions: positions ?? this.positions, entries: entries ?? this.entries, vehicles: vehicles ?? this.vehicles);
  String encode() => jsonEncode({'accounts': accounts.map((e) => e.toJson()).toList(), 'positions': positions.map((e) => e.toJson()).toList(), 'entries': entries.map((e) => e.toJson()).toList(), 'vehicles': vehicles.map((e) => e.toJson()).toList()});
  factory FinanceData.decode(String source) {
    final json = jsonDecode(source) as Map<String, Object?>;
    return FinanceData(accounts: (json['accounts']! as List).cast<Map<String, Object?>>().map(Account.fromJson).toList(), positions: (json['positions']! as List).cast<Map<String, Object?>>().map(Position.fromJson).toList(), entries: (json['entries']! as List).cast<Map<String, Object?>>().map(LedgerEntry.fromJson).toList(), vehicles: (json['vehicles']! as List).cast<Map<String, Object?>>().map(Vehicle.fromJson).toList());
  }
}
