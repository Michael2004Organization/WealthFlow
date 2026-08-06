import 'dart:convert';
import 'dart:math';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  final FlutterSecureStorage _storage;
  static String? _memoryUserId;
  static final Map<String, List<int>> _memoryDataKeys = {};

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
    } catch (_) {
      // Never place encryption keys in the unencrypted preferences fallback.
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
}
