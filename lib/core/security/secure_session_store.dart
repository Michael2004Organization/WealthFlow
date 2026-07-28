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
  final FlutterSecureStorage _storage;
  static String? _memoryUserId;

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

  Future<void> writeServerSecrets({
    required String userId,
    required String password,
    required String apiKey,
  }) async {
    if (password.isNotEmpty) {
      await _storage.write(
        key: 'wealthflow.server.$userId.password',
        value: password,
      );
    }
    if (apiKey.isNotEmpty) {
      await _storage.write(
        key: 'wealthflow.server.$userId.api_key',
        value: apiKey,
      );
    }
  }
}
