import 'dart:async';
import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wealthflow_core/database/app_database.dart';

import 'server_client.dart';
import 'server_connection.dart';

/// What the server did with the additional data file in the last sync.
enum ServerDataFile {
  off,
  needsBackupPassword,
  written,
  failed,
  unknown;

  static ServerDataFile parse(Object? value) => ServerDataFile.values
      .firstWhere((item) => item.name == value, orElse: () => unknown);

  String get description => switch (this) {
    off =>
      'Der Server schreibt keine Datendatei (beim ersten Start wurde kein '
          'Ordner gewählt).',
    needsBackupPassword =>
      'Für die Datendatei auf dem PC bitte unten ein Backup-Passwort '
          'festlegen.',
    written => 'Die Datendatei auf dem PC ist aktuell.',
    failed => 'Die Datendatei auf dem PC konnte nicht geschrieben werden.',
    unknown => '',
  };
}

final class ServerSyncState {
  const ServerSyncState({
    this.isRunning = false,
    this.lastSyncAt,
    this.error,
    this.dataFile,
    this.awaitingFirstSync = false,
  });

  final bool isRunning;

  /// Connected, but the data of this device has not been transferred yet;
  /// nothing is sent before the person confirmed it.
  final bool awaitingFirstSync;
  final DateTime? lastSyncAt;
  final String? error;
  final ServerDataFile? dataFile;

  ServerSyncState copyWith({
    bool? isRunning,
    DateTime? lastSyncAt,
    String? error,
    ServerDataFile? dataFile,
    bool? awaitingFirstSync,
  }) => ServerSyncState(
    isRunning: isRunning ?? this.isRunning,
    lastSyncAt: lastSyncAt ?? this.lastSyncAt,
    error: error ?? this.error,
    dataFile: dataFile ?? this.dataFile,
    awaitingFirstSync: awaitingFirstSync ?? this.awaitingFirstSync,
  );
}

/// Keeps the local database and the home server in step.
///
/// A sync sends the complete export of the account and merges the server's
/// answer; both sides use [AppDatabase.mergeUserData], so newer changes win
/// per row and deletions travel along. It runs on start, a few seconds after
/// local changes and every few minutes for changes of other devices. When
/// the server is unreachable the app keeps working and tries again later.
final class ServerSyncController extends StateNotifier<ServerSyncState> {
  ServerSyncController({
    required this.database,
    required this.userId,
    required this.connection,
    this.interval = const Duration(minutes: 5),
    this.debounce = const Duration(seconds: 3),
    this.active = true,
  }) : super(const ServerSyncState()) {
    if (active) start();
  }

  /// Connected and signed in; otherwise the controller does nothing.
  final bool active;

  final AppDatabase database;
  final ServerConnectionController connection;
  final String userId;
  final Duration interval;
  final Duration debounce;

  StreamSubscription<void>? _changes;
  Timer? _debounceTimer;
  Timer? _periodic;
  Future<bool>? _running;
  String? _syncedDigest;

  Future<void> start() async {
    final preference = await database.preferencesFor(userId);
    // A transfer confirmed in the meantime already started everything.
    if (!mounted || _changes != null) return;
    if (preference.lastSyncAt == null) {
      state = state.copyWith(awaitingFirstSync: true);
      return;
    }
    state = state.copyWith(lastSyncAt: preference.lastSyncAt);
    _startAutomatic();
    unawaited(syncNow());
  }

  void _startAutomatic() {
    _changes ??= database.tableUpdates().listen((_) => _scheduleOnChange());
    _periodic ??= Timer.periodic(interval, (_) => unawaited(syncNow()));
  }

  /// First sync after connecting, once the person confirmed the transfer:
  /// sends all data of this device and fetches what the server has. Running
  /// it twice creates no duplicates, entries are matched by their id.
  Future<bool> transfer() async {
    if (!active) return false;
    final ok = await _join();
    if (ok && mounted) _startAutomatic();
    return ok;
  }

  void _scheduleOnChange() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(debounce, () async {
      // The sync itself writes; compare once it is done.
      if (_running != null) return _scheduleOnChange();
      final digest = _digest(await database.exportUserData(userId));
      if (digest != _syncedDigest) unawaited(syncNow());
    });
  }

  /// Syncs now; returns whether it succeeded. A call during a running sync
  /// joins it; changes made meanwhile are picked up by the change check.
  Future<bool> syncNow() async {
    if (!active || state.awaitingFirstSync) return false;
    return _join();
  }

  Future<bool> _join() async {
    final running = _running;
    if (running != null) return running;
    final current = _running = _sync();
    try {
      return await current;
    } finally {
      _running = null;
    }
  }

  /// Completes once no sync is running.
  @visibleForTesting
  Future<void> get idle async => await _running;

  Future<bool> _sync() async {
    if (!mounted) return false;
    state = state.copyWith(isRunning: true);
    try {
      final export = await database.exportUserData(userId);
      final response = await connection.authorized(
        (link, token) => connection.client.send(
          link,
          token,
          'POST',
          '/api/sync',
          body: {
            'schemaVersion': database.schemaVersion,
            'data': export,
            'backupKey': database.backupKeyFor(userId)?.toJson(),
          },
        ),
      );
      final data = response['data'];
      if (data is! Map) {
        throw const ServerException('Der Server antwortet nicht wie erwartet.');
      }
      await database.mergeUserData(userId, Map<String, dynamic>.from(data));
      _syncedDigest = _digest(await database.exportUserData(userId));
      final now = DateTime.now();
      final link = connection.state.link;
      await database.saveServerState(
        userId,
        connected: true,
        serverUrl: link?.baseUrl ?? '',
        serverUsername: link?.email ?? '',
        lastSyncAt: now,
      );
      if (mounted) {
        state = ServerSyncState(
          lastSyncAt: now,
          dataFile: ServerDataFile.parse(response['dataFile']),
        );
      }
      return true;
    } on ServerException catch (error) {
      return _failed(error.message);
    } catch (error) {
      return _failed('Abgleich fehlgeschlagen: $error');
    }
  }

  bool _failed(String message) {
    if (mounted) state = state.copyWith(isRunning: false, error: message);
    return false;
  }

  /// Fingerprint of the data itself, so writing only the sync time or the
  /// merge result of the last sync does not start another one.
  static String _digest(Map<String, Object?> export) {
    final data = {
      for (final entry in export.entries)
        if (!AppDatabase.volatileExportKeys.contains(entry.key))
          entry.key: entry.value,
    };
    return sha256.convert(utf8.encode(jsonEncode(data))).toString();
  }

  @override
  void dispose() {
    _changes?.cancel();
    _debounceTimer?.cancel();
    _periodic?.cancel();
    super.dispose();
  }
}
