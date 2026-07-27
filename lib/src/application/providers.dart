import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../data/finance_repository.dart';
import '../domain/models.dart';

final repositoryProvider = Provider<FinanceRepository>((ref) => LocalFinanceRepository());
final financeProvider = AsyncNotifierProvider<FinanceController, FinanceData>(FinanceController.new);

class FinanceController extends AsyncNotifier<FinanceData> {
  FinanceRepository get _repository => ref.read(repositoryProvider);
  @override
  Future<FinanceData> build() => _repository.load();
  Future<void> _update(FinanceData Function(FinanceData) change) async {
    final current = state.valueOrNull ?? await _repository.load();
    final next = change(current);
    state = AsyncData(next);
    await _repository.save(next);
  }
  Future<void> addAccount({required String name, required String bank, required int balance}) => _update((data) => data.copyWith(accounts: [...data.accounts, Account(id: const Uuid().v4(), name: name, bank: bank, balance: balance)]));
  Future<void> removeAccount(String id) => _update((data) => data.copyWith(accounts: data.accounts.where((e) => e.id != id).toList()));
  Future<void> addEntry({required int amount, required TransactionKind kind, required String category, required String merchant}) => _update((data) => data.copyWith(entries: [...data.entries, LedgerEntry(id: const Uuid().v4(), date: DateTime.now(), amount: amount, kind: kind, category: category, merchant: merchant)]));
  Future<void> removeEntry(String id) => _update((data) => data.copyWith(entries: data.entries.where((e) => e.id != id).toList()));
  Future<void> addPosition({required String name, required String symbol, required AssetType type, required double quantity, required int purchasePrice, required int currentPrice}) => _update((data) => data.copyWith(positions: [...data.positions, Position(id: const Uuid().v4(), name: name, symbol: symbol, type: type, quantity: quantity, purchasePrice: purchasePrice, currentPrice: currentPrice)]));
  Future<void> removePosition(String id) => _update((data) => data.copyWith(positions: data.positions.where((e) => e.id != id).toList()));
  Future<void> addVehicle({required String name, required String kind, required int year}) => _update((data) => data.copyWith(vehicles: [...data.vehicles, Vehicle(id: const Uuid().v4(), name: name, kind: kind, year: year)]));
  String exportJson() => state.requireValue.encode();
  Future<void> importJson(String json) async {
    jsonDecode(json);
    final data = FinanceData.decode(json);
    state = AsyncData(data);
    await _repository.save(data);
  }
}

final themeProvider = AsyncNotifierProvider<ThemeController, ThemeMode>(ThemeController.new);
class ThemeController extends AsyncNotifier<ThemeMode> {
  static const _key = 'wealthflow.theme';
  @override
  Future<ThemeMode> build() async {
    final value = (await SharedPreferences.getInstance()).getString(_key);
    return ThemeMode.values.where((e) => e.name == value).firstOrNull ?? ThemeMode.system;
  }
  Future<void> set(ThemeMode mode) async {
    state = AsyncData(mode);
    await (await SharedPreferences.getInstance()).setString(_key, mode.name);
  }
}
