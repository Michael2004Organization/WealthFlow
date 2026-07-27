import 'package:shared_preferences/shared_preferences.dart';

import '../domain/models.dart';

abstract interface class FinanceRepository {
  Future<FinanceData> load();
  Future<void> save(FinanceData data);
  Future<void> clear();
}

class LocalFinanceRepository implements FinanceRepository {
  static const _key = 'wealthflow.finance.v1';
  @override
  Future<FinanceData> load() async {
    final preferences = await SharedPreferences.getInstance();
    final value = preferences.getString(_key);
    if (value == null) return const FinanceData();
    return FinanceData.decode(value);
  }
  @override
  Future<void> save(FinanceData data) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_key, data.encode());
  }
  @override
  Future<void> clear() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_key);
  }
}
