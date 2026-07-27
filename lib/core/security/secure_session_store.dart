import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final class SecureSessionStore {
  SecureSessionStore({FlutterSecureStorage? storage})
    : _storage =
          storage ??
          const FlutterSecureStorage(
            aOptions: AndroidOptions(migrateWithBackup: true),
          );

  static const _userKey = 'wealthflow.current_user_id';
  final FlutterSecureStorage _storage;

  Future<String?> readUserId() => _storage.read(key: _userKey);

  Future<void> writeUserId(String userId) =>
      _storage.write(key: _userKey, value: userId);

  Future<void> clear() => _storage.delete(key: _userKey);

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
