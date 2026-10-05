import 'dart:convert';
import 'dart:math';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wealthflow_core/security/data_cipher.dart';

import '../server/server_link.dart';

final class SecureSessionStore {
  SecureSessionStore({FlutterSecureStorage? storage})
    : _storage =
          storage ??
          const FlutterSecureStorage(
            aOptions: AndroidOptions(migrateWithBackup: true),
          );

  static const _userKey = 'wealthflow.current_user_id';
  static const _dataKeyPrefix = 'wealthflow.data_key.';
  static const _marketApiKeyPrefix = 'wealthflow.market_api_key.';
  static const _exchangeApiKeyPrefix = 'wealthflow.exchange_api_key.';
  static const _backupKeyPrefix = 'wealthflow.backup_key.';
  static const _appPinPrefix = 'wealthflow.app_pin.';
  static const _serverLinkPrefix = 'wealthflow.server_link.';
  static const _serverRefreshPrefix = 'wealthflow.server_refresh.';
  static final Map<String, String> _memoryServerValues = {};
  final FlutterSecureStorage _storage;
  static String? _memoryUserId;
  static final Map<String, List<int>> _memoryDataKeys = {};
  static final Set<String> _volatileDataKeys = {};
  static final Map<String, BackupKey> _memoryBackupKeys = {};
  static final Set<String> _volatileBackupKeys = {};

  /// False when the device key of [userId] only lives in memory because the
  /// platform key store is unavailable. Files written with it become
  /// unreadable after the next start.
  bool isDataKeyPersistent(String userId) =>
      !_volatileDataKeys.contains(userId);

  /// False when the backup key could not be saved in the platform key store
  /// and the backup password must be entered again after a restart.
  bool isBackupKeyPersistent(String userId) =>
      !_volatileBackupKeys.contains(userId);

  /// Hash and salt of the app lock PIN, or null when the lock is off.
  Future<({String hash, String salt})?> readAppPin(String userId) async {
    try {
      final encoded = await _storage.read(key: _appPinPrefix + userId);
      if (encoded == null) return null;
      final value = jsonDecode(encoded);
      if (value is! Map) return null;
      return (hash: value['hash'] as String, salt: value['salt'] as String);
    } catch (_) {
      return null;
    }
  }

  /// Stores the PIN hash only in the platform key store; returns false when
  /// that is unavailable, so the lock is not offered without it.
  Future<bool> writeAppPin(
    String userId,
    ({String hash, String salt})? value,
  ) async {
    try {
      final key = _appPinPrefix + userId;
      if (value == null) {
        await _storage.delete(key: key);
      } else {
        await _storage.write(
          key: key,
          value: jsonEncode({'hash': value.hash, 'salt': value.salt}),
        );
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<BackupKey?> readBackupKey(String userId) async {
    final memory = _memoryBackupKeys[userId];
    if (memory != null) return memory;
    try {
      final encoded = await _storage.read(key: _backupKeyPrefix + userId);
      if (encoded == null) return null;
      final value = BackupKey.fromJson(jsonDecode(encoded));
      if (value != null) _memoryBackupKeys[userId] = value;
      return value;
    } catch (_) {
      return null;
    }
  }

  /// Keeps the derived key, never the password, in the platform key store.
  Future<bool> writeBackupKey(String userId, BackupKey value) async {
    _memoryBackupKeys[userId] = value;
    try {
      await _storage.write(
        key: _backupKeyPrefix + userId,
        value: jsonEncode(value.toJson()),
      );
      _volatileBackupKeys.remove(userId);
      return true;
    } catch (_) {
      _volatileBackupKeys.add(userId);
      return false;
    }
  }

  Future<String?> readUserId() async {
    try {
      final secured = await _storage.read(key: _userKey);
      if (secured != null) {
        _memoryUserId = secured;
        return secured;
      }
    } catch (_) {
      // Some Windows, Linux and web environments do not expose a usable
      // platform key store. The non-secret user id remains available below.
    }
    try {
      final cached = (await SharedPreferences.getInstance()).getString(
        _userKey,
      );
      _memoryUserId = cached ?? _memoryUserId;
    } catch (_) {
      // The in-memory value still keeps a just-created session usable.
    }
    return _memoryUserId;
  }

  Future<void> writeUserId(String userId) async {
    _memoryUserId = userId;
    try {
      await _storage.write(key: _userKey, value: userId);
    } catch (_) {
      // The durable cache below is the cross-platform fallback.
    }
    try {
      await (await SharedPreferences.getInstance()).setString(_userKey, userId);
    } catch (_) {
      // Registration/login must not fail only because session caching failed.
    }
  }

  Future<void> clear() async {
    _memoryUserId = null;
    try {
      await _storage.delete(key: _userKey);
    } catch (_) {
      // Keep clearing the fallback even if the platform key store is absent.
    }
    try {
      await (await SharedPreferences.getInstance()).remove(_userKey);
    } catch (_) {
      // The in-memory session has already been removed.
    }
  }

  Future<List<int>> dataKeyForUser(String userId) async {
    final memory = _memoryDataKeys[userId];
    if (memory != null) return memory;
    try {
      final encoded = await _storage.read(key: _dataKeyPrefix + userId);
      if (encoded != null) {
        final value = base64Decode(encoded);
        _memoryDataKeys[userId] = value;
        return value;
      }
    } catch (_) {
      // A fresh in-memory key keeps encryption available for this session.
    }
    final random = Random.secure();
    final created = List<int>.generate(32, (_) => random.nextInt(256));
    _memoryDataKeys[userId] = created;
    try {
      await _storage.write(
        key: _dataKeyPrefix + userId,
        value: base64Encode(created),
      );
      _volatileDataKeys.remove(userId);
    } catch (_) {
      // Never place encryption keys in the unencrypted preferences fallback.
      _volatileDataKeys.add(userId);
    }
    return created;
  }

  Future<String?> readMarketApiKey(String userId) async {
    try {
      return await _storage.read(key: _marketApiKeyPrefix + userId);
    } catch (_) {
      return null;
    }
  }

  /// Stores the key only in the platform credential store. There is
  /// deliberately no plaintext SharedPreferences fallback for this secret.
  Future<bool> writeMarketApiKey(String userId, String value) async {
    try {
      final key = _marketApiKeyPrefix + userId;
      if (value.trim().isEmpty) {
        await _storage.delete(key: key);
      } else {
        await _storage.write(key: key, value: value.trim());
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<String?> readExchangeApiKey(String userId) async {
    try {
      return await _storage.read(key: _exchangeApiKeyPrefix + userId);
    } catch (_) {
      return null;
    }
  }

  Future<bool> writeExchangeApiKey(String userId, String value) async {
    try {
      final key = _exchangeApiKeyPrefix + userId;
      if (value.trim().isEmpty) {
        await _storage.delete(key: key);
      } else {
        await _storage.write(key: key, value: value.trim());
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Server connection of [userId] (address, certificate fingerprint,
  /// device id), or null when this account is not connected.
  Future<ServerLink?> readServerLink(String userId) async {
    final encoded = await _readServerValue(_serverLinkPrefix + userId);
    if (encoded == null) return null;
    try {
      return ServerLink.fromJson(jsonDecode(encoded));
    } on FormatException {
      return null;
    }
  }

  Future<void> writeServerLink(String userId, ServerLink? link) =>
      _writeServerValue(
        _serverLinkPrefix + userId,
        link == null ? null : jsonEncode(link.toJson()),
      );

  /// Refresh token of the server session; only in the platform key store.
  Future<String?> readServerRefreshToken(String userId) =>
      _readServerValue(_serverRefreshPrefix + userId);

  Future<void> writeServerRefreshToken(String userId, String? token) =>
      _writeServerValue(_serverRefreshPrefix + userId, token);

  Future<String?> _readServerValue(String key) async {
    final memory = _memoryServerValues[key];
    if (memory != null) return memory;
    try {
      final stored = await _storage.read(key: key);
      if (stored != null) _memoryServerValues[key] = stored;
      return stored;
    } catch (_) {
      return null;
    }
  }

  Future<void> _writeServerValue(String key, String? value) async {
    if (value == null) {
      _memoryServerValues.remove(key);
    } else {
      _memoryServerValues[key] = value;
    }
    try {
      if (value == null) {
        await _storage.delete(key: key);
      } else {
        await _storage.write(key: key, value: value);
      }
    } catch (_) {
      // Without a key store the connection lasts until the app closes.
    }
  }
}
