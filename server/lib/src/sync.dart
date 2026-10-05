import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:drift/drift.dart';
import 'package:wealthflow_core/database/app_database.dart';
import 'package:wealthflow_core/security/data_cipher.dart';

import 'access.dart';
import 'server_settings.dart';

/// What happened to the additional data file during a sync.
enum DataFileResult {
  /// No folder was chosen on the first start.
  off,

  /// The app has no backup password yet; without it nobody could open the
  /// file on another device.
  needsBackupPassword,
  written,
  failed,
}

/// Merges the data a device sends into the server database and answers with
/// the merged state.
///
/// Both sides use the same [AppDatabase.mergeUserData]: newer changes win
/// per row, deletions travel as `deletedAt`, and account balances are
/// corrected by every booking the other side did not know yet. Running the
/// merge on the server and then on the device brings both to the same data.
final class ServerSync {
  ServerSync(this._database, {required this.settings});

  final AppDatabase _database;
  final ServerSettings settings;

  /// Key for the data file when no backup password is set; never used for
  /// writing, because the server only writes password-protected files.
  final List<int> _unusedDeviceKey = List.generate(
    32,
    (_) => Random.secure().nextInt(256),
  );
  final Map<String, Future<void>> _running = {};

  /// Export keys and the tables behind them that belong to one user.
  static const userTables = {
    'accounts': 'accounts',
    'accountBalanceHistories': 'account_balance_histories',
    'investments': 'investments',
    'physicalAssets': 'physical_assets',
    'investmentPurchases': 'investment_purchases',
    'portfolioSales': 'portfolio_sales',
    'portfolioAuditLogs': 'portfolio_audit_logs',
    'dividendSchedules': 'dividend_schedules',
    'ledgerEntries': 'ledger_entries',
    'vehicles': 'vehicles',
    'vehicleCosts': 'vehicle_costs',
    'masterData': 'master_data',
    'reminders': 'reminders',
    'netWorthSnapshots': 'net_worth_snapshots',
  };

  Future<({Map<String, Object?> data, DataFileResult dataFile})> sync(
    AccessContext context,
    Map<String, Object?> incoming, {
    BackupKey? backupKey,
  }) {
    // Two devices of the same user sync one after the other.
    final previous = _running[context.userId] ?? Future<void>.value();
    final result = previous.then(
      (_) => _sync(context.userId, incoming, backupKey),
    );
    final done = result.then<void>((_) {}, onError: (_) {});
    _running[context.userId] = done;
    unawaited(
      done.whenComplete(() {
        if (identical(_running[context.userId], done)) {
          _running.remove(context.userId);
        }
      }),
    );
    return result;
  }

  Future<({Map<String, Object?> data, DataFileResult dataFile})> _sync(
    String userId,
    Map<String, Object?> incoming,
    BackupKey? backupKey,
  ) async {
    final data = await _withoutForeignRows(userId, incoming);
    await _database.mergeUserData(userId, data);
    final dataFile = await _writeDataFile(userId, backupKey);
    return (data: await _database.exportUserData(userId), dataFile: dataFile);
  }

  /// Drops rows whose id already belongs to another account, so one person's
  /// device can never overwrite or take over another person's data.
  Future<Map<String, dynamic>> _withoutForeignRows(
    String userId,
    Map<String, Object?> incoming,
  ) async {
    final cleaned = Map<String, dynamic>.from(incoming);
    for (final MapEntry(key: key, value: table) in userTables.entries) {
      final rows = incoming[key];
      if (rows is! List) continue;
      final ids = [
        for (final row in rows)
          if (row is Map && row['id'] is String) row['id'] as String,
      ];
      final foreign = <String>{};
      for (var start = 0; start < ids.length; start += 500) {
        final chunk = ids.sublist(start, min(start + 500, ids.length));
        final found = await _database
            .customSelect(
              'SELECT id FROM $table WHERE user_id <> ? AND id IN '
              '(${List.filled(chunk.length, '?').join(', ')})',
              variables: [
                Variable.withString(userId),
                for (final id in chunk) Variable.withString(id),
              ],
            )
            .get();
        foreign.addAll(found.map((row) => row.read<String>('id')));
      }
      cleaned[key] = [
        for (final row in rows)
          if (row is Map && !foreign.contains(row['id'])) row,
      ];
    }
    return cleaned;
  }

  Future<DataFileResult> _writeDataFile(
    String userId,
    BackupKey? backupKey,
  ) async {
    final directory = settings.dataFileDirectory;
    if (directory.isEmpty) return DataFileResult.off;
    if (backupKey == null) return DataFileResult.needsBackupPassword;
    final user = await _database.userById(userId);
    if (user == null) return DataFileResult.failed;
    final name = user.email.replaceAll(RegExp(r'[^A-Za-z0-9@._-]'), '_');
    await _database.setDataFilePath(
      userId,
      '$directory${Platform.pathSeparator}wealthflow-$name.wflow',
    );
    _database
      ..setDataFileKey(userId, _unusedDeviceKey)
      ..setBackupKey(userId, backupKey);
    final written = await _database.persistUserFile(userId);
    return written ? DataFileResult.written : DataFileResult.failed;
  }
}
