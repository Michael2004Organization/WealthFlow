import 'dart:convert';
import 'dart:math';

import 'package:cryptography/cryptography.dart';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import 'package:wealthflow_core/database/app_database.dart';
import 'package:wealthflow_core/server/pairing.dart';

import 'passwords.dart';

/// Signed-in device as seen by a request.
final class AccessContext {
  const AccessContext({required this.userId, required this.deviceId});

  final String userId;
  final String deviceId;
}

/// Tokens handed to a device after pairing, login or refresh.
final class DeviceSession {
  const DeviceSession({
    required this.deviceId,
    required this.accessToken,
    required this.refreshToken,
    required this.accessExpiresIn,
    required this.user,
  });

  final String deviceId;
  final String accessToken;
  final String refreshToken;
  final Duration accessExpiresIn;
  final User user;

  Map<String, Object?> toJson() => {
    'deviceId': deviceId,
    'accessToken': accessToken,
    'refreshToken': refreshToken,
    'expiresIn': accessExpiresIn.inSeconds,
    'user': {
      'id': user.id,
      'email': user.email,
      'displayName': user.displayName,
      'role': user.role,
    },
  };
}

/// Why a pairing or login was refused; the message is shown in the app.
final class AccessDenied implements Exception {
  const AccessDenied(this.message, {this.status = 401});

  final String message;
  final int status;

  @override
  String toString() => message;
}

/// One registered device of a user.
final class DeviceInfo {
  const DeviceInfo({
    required this.id,
    required this.userEmail,
    required this.name,
    required this.lastSeenAt,
    required this.revoked,
  });

  final String id;
  final String userEmail;
  final String name;
  final DateTime lastSeenAt;
  final bool revoked;
}

/// Accounts, pairing codes and device tokens of the server.
///
/// Accounts are rows of the shared `users` table (password as Argon2id).
/// Devices live in the server-only table `server_devices`; refresh tokens are
/// stored as SHA-256 hashes only. Access tokens and pairing codes stay in
/// memory, a restart simply asks devices to refresh.
final class ServerAccess {
  ServerAccess(
    this._database, {
    required this.certificateFingerprint,
    this.hasher = const ServerPasswordHasher(),
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  final AppDatabase _database;
  final ServerPasswordHasher hasher;
  final DateTime Function() _clock;

  /// Fingerprint of the server certificate; bound into pairing proofs.
  final String certificateFingerprint;

  static const accessLifetime = Duration(minutes: 15);
  static const refreshLifetime = Duration(days: 30);
  static const pairingLifetime = Duration(minutes: 10);
  static const maxPairingFailures = 5;
  static const maxLoginFailures = 5;
  static const lockDuration = Duration(minutes: 5);
  static const _challengeLifetime = Duration(minutes: 2);
  static const _passwordSaltMarker = 'argon2id';

  static const _uuid = Uuid();
  final _random = Random.secure();
  final Map<String, _AccessToken> _accessTokens = {};
  final Map<String, _Challenge> _challenges = {};
  final Map<String, _Failures> _loginFailures = {};
  _PairingCode? _pairingCode;

  DateTime get _now => _clock().toUtc();

  Future<void> initialize() async {
    await _database.customStatement('''
      CREATE TABLE IF NOT EXISTS server_devices (
        id TEXT NOT NULL PRIMARY KEY,
        user_id TEXT NOT NULL REFERENCES users (id),
        name TEXT NOT NULL,
        created_at INTEGER NOT NULL,
        last_seen_at INTEGER NOT NULL,
        refresh_hash TEXT,
        refresh_expires_at INTEGER,
        revoked_at INTEGER
      )
    ''');
    await _database.customStatement(
      'CREATE UNIQUE INDEX IF NOT EXISTS server_devices_refresh '
      'ON server_devices (refresh_hash)',
    );
  }

  // ---------------------------------------------------------------- accounts

  Future<bool> hasUsers() async => await _database.userCount() > 0;

  /// Creates a server account; the first one becomes admin.
  Future<User> createUser({
    required String email,
    required String displayName,
    required String password,
  }) async {
    final normalized = email.trim().toLowerCase();
    if (!normalized.contains('@') || normalized.length < 3) {
      throw const AccessDenied('Bitte eine gültige E-Mail-Adresse angeben.');
    }
    if (displayName.trim().isEmpty) {
      throw const AccessDenied('Bitte einen Namen angeben.');
    }
    if (password.length < ServerPasswordHasher.minimumLength) {
      throw const AccessDenied(
        'Das Passwort muss mindestens '
        '${ServerPasswordHasher.minimumLength} Zeichen haben.',
      );
    }
    if (await _database.userByEmail(normalized) != null) {
      throw const AccessDenied('Für diese E-Mail gibt es schon ein Konto.');
    }
    final now = _now;
    final id = _uuid.v4();
    final role = await hasUsers() ? 'member' : 'admin';
    final hash = await hasher.hash(password);
    await _database.transaction(() async {
      await _database.createUser(
        UsersCompanion.insert(
          id: id,
          email: normalized,
          displayName: displayName.trim(),
          passwordHash: hash,
          passwordSalt: _passwordSaltMarker,
          role: Value(role),
          createdAt: now,
          updatedAt: now,
        ),
      );
      await _database.savePreferences(
        UserPreferencesCompanion.insert(userId: id, updatedAt: now),
      );
    });
    return (await _database.userById(id))!;
  }

  Future<User> _checkPassword(String email, String password) async {
    final key = email.trim().toLowerCase();
    final failures = _loginFailures[key];
    if (failures != null && failures.lockedUntil.isAfter(_now)) {
      throw const AccessDenied(
        'Zu viele falsche Versuche. Bitte in einigen Minuten erneut versuchen.',
        status: 429,
      );
    }
    final user = await _database.userByEmail(key);
    final valid =
        user != null &&
        user.passwordSalt == _passwordSaltMarker &&
        await hasher.verify(password, user.passwordHash);
    if (!valid) {
      final next = (failures?.count ?? 0) + 1;
      _loginFailures[key] = _Failures(
        next >= maxLoginFailures ? 0 : next,
        next >= maxLoginFailures ? _now.add(lockDuration) : _now,
      );
      throw const AccessDenied('E-Mail oder Passwort ist falsch.');
    }
    _loginFailures.remove(key);
    return user;
  }

  // ----------------------------------------------------------------- pairing

  /// Starts a new pairing code (the old one stops working) and returns it
  /// formatted for display.
  String startPairing() {
    final code = newPairingCode(_random);
    _pairingCode = _PairingCode(code, _now.add(pairingLifetime));
    _challenges.clear();
    return code;
  }

  /// First pairing step: the server proves it knows the code and holds the
  /// certificate the device sees.
  Future<Map<String, String>> pairingChallenge(String clientNonce) async {
    final code = _activeCode();
    if (clientNonce.length < 16 || clientNonce.length > 64) {
      throw const AccessDenied('Ungültige Anfrage.', status: 400);
    }
    _challenges.removeWhere((_, value) => value.expiresAt.isBefore(_now));
    final serverNonce = newPairingNonce(_random);
    _challenges[clientNonce] = _Challenge(
      serverNonce,
      _now.add(_challengeLifetime),
    );
    return {
      'serverNonce': serverNonce,
      'serverProof': await pairingProof(
        code: code.code,
        role: 'server',
        fingerprint: certificateFingerprint,
        clientNonce: clientNonce,
      ),
    };
  }

  /// Second pairing step: the device proves it knows the code, then signs in
  /// with email and password and gets its tokens.
  Future<DeviceSession> completePairing({
    required String clientNonce,
    required String clientProof,
    required String email,
    required String password,
    required String deviceName,
  }) async {
    final code = _activeCode();
    final challenge = _challenges.remove(clientNonce);
    if (challenge == null || challenge.expiresAt.isBefore(_now)) {
      throw const AccessDenied(
        'Die Kopplung ist abgelaufen. Bitte neu beginnen.',
      );
    }
    final expected = await pairingProof(
      code: code.code,
      role: 'client',
      fingerprint: certificateFingerprint,
      clientNonce: clientNonce,
      serverNonce: challenge.serverNonce,
    );
    if (!proofsMatch(expected, clientProof)) {
      code.failures++;
      if (code.failures >= maxPairingFailures) _pairingCode = null;
      throw const AccessDenied('Der Kopplungscode stimmt nicht.');
    }
    final user = await _checkPassword(email, password);
    // A code pairs exactly one device.
    _pairingCode = null;
    final deviceId = _uuid.v4();
    final now = _now;
    await _database.customStatement(
      'INSERT INTO server_devices (id, user_id, name, created_at, last_seen_at) '
      'VALUES (?, ?, ?, ?, ?)',
      [
        deviceId,
        user.id,
        _cleanDeviceName(deviceName),
        now.millisecondsSinceEpoch,
        now.millisecondsSinceEpoch,
      ],
    );
    return _issue(deviceId, user);
  }

  _PairingCode _activeCode() {
    final code = _pairingCode;
    if (code == null || code.expiresAt.isBefore(_now)) {
      throw const AccessDenied(
        'Kein gültiger Kopplungscode. Bitte im Server-Fenster Enter drücken '
        'und den neuen Code eingeben.',
      );
    }
    return code;
  }

  // ------------------------------------------------------------------ tokens

  /// Signs a paired device in again after it logged out.
  Future<DeviceSession> login({
    required String deviceId,
    required String email,
    required String password,
  }) async {
    final user = await _checkPassword(email, password);
    final device = await _device(deviceId);
    if (device == null || device.revoked || device.userId != user.id) {
      throw const AccessDenied(
        'Dieses Gerät ist nicht (mehr) gekoppelt. Bitte neu koppeln.',
      );
    }
    return _issue(deviceId, user);
  }

  /// Exchanges a refresh token for new tokens; the old one stops working.
  Future<DeviceSession> refresh(String refreshToken) async {
    final rows = await _database
        .customSelect(
          'SELECT id, user_id, refresh_expires_at FROM server_devices '
          'WHERE refresh_hash = ? AND revoked_at IS NULL',
          variables: [Variable.withString(await _hash(refreshToken))],
        )
        .get();
    if (rows.isEmpty) {
      throw const AccessDenied('Bitte erneut anmelden.');
    }
    final row = rows.single;
    final expiresAt = row.read<int?>('refresh_expires_at');
    if (expiresAt == null || expiresAt < _now.millisecondsSinceEpoch) {
      throw const AccessDenied('Bitte erneut anmelden.');
    }
    final user = await _database.userById(row.read<String>('user_id'));
    if (user == null) throw const AccessDenied('Bitte erneut anmelden.');
    return _issue(row.read<String>('id'), user);
  }

  /// Ends the session of a device; pairing stays.
  Future<void> logout(AccessContext context) async {
    _accessTokens.removeWhere((_, token) => token.deviceId == context.deviceId);
    await _database.customStatement(
      'UPDATE server_devices SET refresh_hash = NULL, refresh_expires_at = NULL '
      'WHERE id = ?',
      [context.deviceId],
    );
  }

  /// Checks a bearer token; null when it is unknown or expired.
  Future<AccessContext?> authenticate(String? authorization) async {
    if (authorization == null || !authorization.startsWith('Bearer ')) {
      return null;
    }
    final hash = await _hash(authorization.substring(7).trim());
    final token = _accessTokens[hash];
    if (token == null) return null;
    if (token.expiresAt.isBefore(_now)) {
      _accessTokens.remove(hash);
      return null;
    }
    return AccessContext(userId: token.userId, deviceId: token.deviceId);
  }

  Future<DeviceSession> _issue(String deviceId, User user) async {
    final now = _now;
    final accessToken = _token();
    final refreshToken = _token();
    _accessTokens.removeWhere(
      (_, token) => token.deviceId == deviceId || token.expiresAt.isBefore(now),
    );
    _accessTokens[await _hash(accessToken)] = _AccessToken(
      user.id,
      deviceId,
      now.add(accessLifetime),
    );
    await _database.customStatement(
      'UPDATE server_devices SET refresh_hash = ?, refresh_expires_at = ?, '
      'last_seen_at = ? WHERE id = ?',
      [
        await _hash(refreshToken),
        now.add(refreshLifetime).millisecondsSinceEpoch,
        now.millisecondsSinceEpoch,
        deviceId,
      ],
    );
    return DeviceSession(
      deviceId: deviceId,
      accessToken: accessToken,
      refreshToken: refreshToken,
      accessExpiresIn: accessLifetime,
      user: user,
    );
  }

  // ----------------------------------------------------------------- devices

  Future<List<DeviceInfo>> devices() async {
    final rows = await _database
        .customSelect(
          'SELECT d.id, d.name, d.last_seen_at, d.revoked_at, u.email '
          'FROM server_devices d JOIN users u ON u.id = d.user_id '
          'ORDER BY u.email, d.created_at',
        )
        .get();
    return [
      for (final row in rows)
        DeviceInfo(
          id: row.read<String>('id'),
          userEmail: row.read<String>('email'),
          name: row.read<String>('name'),
          lastSeenAt: DateTime.fromMillisecondsSinceEpoch(
            row.read<int>('last_seen_at'),
          ),
          revoked: row.read<int?>('revoked_at') != null,
        ),
    ];
  }

  /// Removes a device; it has to be paired again.
  Future<void> revokeDevice(String deviceId) async {
    _accessTokens.removeWhere((_, token) => token.deviceId == deviceId);
    await _database.customStatement(
      'UPDATE server_devices SET revoked_at = ?, refresh_hash = NULL, '
      'refresh_expires_at = NULL WHERE id = ?',
      [_now.millisecondsSinceEpoch, deviceId],
    );
  }

  Future<_Device?> _device(String deviceId) async {
    final rows = await _database
        .customSelect(
          'SELECT user_id, revoked_at FROM server_devices WHERE id = ?',
          variables: [Variable.withString(deviceId)],
        )
        .get();
    if (rows.isEmpty) return null;
    return _Device(
      rows.single.read<String>('user_id'),
      rows.single.read<int?>('revoked_at') != null,
    );
  }

  String _token() =>
      base64UrlEncode(List.generate(32, (_) => _random.nextInt(256)));

  static Future<String> _hash(String value) async {
    final digest = await Sha256().hash(utf8.encode(value));
    return base64UrlEncode(digest.bytes);
  }

  static String _cleanDeviceName(String name) {
    final trimmed = name.trim().replaceAll(RegExp(r'[\x00-\x1F]'), '');
    if (trimmed.isEmpty) return 'Gerät';
    return trimmed.length > 60 ? trimmed.substring(0, 60) : trimmed;
  }
}

final class _AccessToken {
  _AccessToken(this.userId, this.deviceId, this.expiresAt);

  final String userId;
  final String deviceId;
  final DateTime expiresAt;
}

final class _Challenge {
  _Challenge(this.serverNonce, this.expiresAt);

  final String serverNonce;
  final DateTime expiresAt;
}

final class _PairingCode {
  _PairingCode(this.code, this.expiresAt);

  final String code;
  final DateTime expiresAt;
  int failures = 0;
}

final class _Failures {
  _Failures(this.count, this.lockedUntil);

  final int count;
  final DateTime lockedUntil;
}

final class _Device {
  _Device(this.userId, this.revoked);

  final String userId;
  final bool revoked;
}
