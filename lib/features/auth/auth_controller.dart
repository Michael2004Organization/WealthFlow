import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:drift/drift.dart' show Value;

import '../../core/database/app_database.dart';
import '../../core/security/password_hasher.dart';
import '../../core/security/secure_session_store.dart';

enum AuthStatus { loading, signedOut, signedIn }

final class AuthState {
  const AuthState({
    required this.status,
    this.user,
    this.error,
    this.isBusy = false,
  });

  const AuthState.loading() : this(status: AuthStatus.loading);

  final AuthStatus status;
  final User? user;
  final String? error;
  final bool isBusy;

  AuthState copyWith({
    AuthStatus? status,
    User? user,
    String? error,
    bool? isBusy,
    bool clearError = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      error: clearError ? null : error ?? this.error,
      isBusy: isBusy ?? this.isBusy,
    );
  }
}

final class AuthController extends StateNotifier<AuthState> {
  factory AuthController({
    required AppDatabase database,
    required SecureSessionStore sessionStore,
  }) => AuthController._(database, sessionStore);

  AuthController._(this._database, this._sessionStore)
    : super(const AuthState.loading()) {
    _restoreSession();
  }

  final AppDatabase _database;
  final SecureSessionStore _sessionStore;
  static const _uuid = Uuid();

  Future<void> _restoreSession() async {
    try {
      final userId = await _sessionStore.readUserId();
      final user = userId == null ? null : await _database.userById(userId);
      if (user != null) {
        _database.setDataFileKey(
          user.id,
          await _sessionStore.dataKeyForUser(user.id),
        );
      }
      state = AuthState(
        status: user == null ? AuthStatus.signedOut : AuthStatus.signedIn,
        user: user,
      );
      if (user == null && userId != null) await _sessionStore.clear();
    } catch (_) {
      state = const AuthState(status: AuthStatus.signedOut);
    }
  }

  Future<bool> register({
    required String displayName,
    required String email,
    required String password,
    bool createInitialAdmin = false,
  }) async {
    final validation = _validate(displayName, email, password);
    if (validation != null) {
      state = state.copyWith(error: validation);
      return false;
    }
    state = state.copyWith(isBusy: true, clearError: true);
    try {
      final normalizedEmail = email.trim().toLowerCase();
      if (await _database.userByEmail(normalizedEmail) != null) {
        state = state.copyWith(
          isBusy: false,
          error: 'Für diese E-Mail-Adresse existiert bereits ein Konto.',
        );
        return false;
      }
      final digest = await compute(_hashPassword, password);
      final now = DateTime.now().toUtc();
      final userId = _uuid.v4();
      final isFirstAccount = await _database.userCount() == 0;
      await _database.transaction(() async {
        await _database.createUser(
          UsersCompanion.insert(
            id: userId,
            email: normalizedEmail,
            displayName: displayName.trim(),
            passwordHash: digest.hash,
            passwordSalt: digest.salt,
            role: Value(
              createInitialAdmin && isFirstAccount ? 'admin' : 'member',
            ),
            createdAt: now,
            updatedAt: now,
          ),
        );
        await _database.savePreferences(
          UserPreferencesCompanion.insert(userId: userId, updatedAt: now),
        );
      });
      final user = await _database.userById(userId);
      _database.setDataFileKey(
        userId,
        await _sessionStore.dataKeyForUser(userId),
      );
      state = AuthState(status: AuthStatus.signedIn, user: user);
      unawaited(_sessionStore.writeUserId(userId));
      unawaited(_database.seedDefaultMasterData(userId));
      unawaited(_database.captureNetWorth(userId));
      return true;
    } catch (_) {
      state = state.copyWith(
        isBusy: false,
        error: 'Das Konto konnte nicht angelegt werden.',
      );
      return false;
    }
  }

  Future<bool> login(String email, String password) async {
    state = state.copyWith(isBusy: true, clearError: true);
    try {
      final user = await _database.userByEmail(email.trim().toLowerCase());
      final valid =
          user != null &&
          await compute(_verifyPassword, (
            password: password,
            salt: user.passwordSalt,
            hash: user.passwordHash,
          ));
      if (!valid) {
        state = const AuthState(
          status: AuthStatus.signedOut,
          error: 'E-Mail-Adresse oder Passwort ist nicht korrekt.',
        );
        return false;
      }
      _database.setDataFileKey(
        user.id,
        await _sessionStore.dataKeyForUser(user.id),
      );
      state = AuthState(status: AuthStatus.signedIn, user: user);
      unawaited(_sessionStore.writeUserId(user.id));
      unawaited(_database.preferencesFor(user.id));
      unawaited(_database.seedDefaultMasterData(user.id));
      unawaited(_database.captureNetWorth(user.id));
      return true;
    } catch (_) {
      state = const AuthState(
        status: AuthStatus.signedOut,
        error: 'Die Anmeldung ist momentan nicht möglich.',
      );
      return false;
    }
  }

  Future<bool> changePassword(String current, String replacement) async {
    final user = state.user;
    if (user == null) return false;
    if (replacement.length < 10) {
      state = state.copyWith(error: 'Das neue Passwort muss 10 Zeichen haben.');
      return false;
    }
    state = state.copyWith(isBusy: true, clearError: true);
    final valid = await compute(_verifyPassword, (
      password: current,
      salt: user.passwordSalt,
      hash: user.passwordHash,
    ));
    if (!valid) {
      state = state.copyWith(
        isBusy: false,
        error: 'Das aktuelle Passwort ist nicht korrekt.',
      );
      return false;
    }
    final digest = await compute(_hashPassword, replacement);
    await _database.updateUserPassword(user.id, digest.hash, digest.salt);
    final refreshed = await _database.userById(user.id);
    state = AuthState(status: AuthStatus.signedIn, user: refreshed);
    return true;
  }

  Future<void> logout() async {
    final userId = state.user?.id;
    await _sessionStore.clear();
    if (userId != null) _database.clearDataFileKey(userId);
    state = const AuthState(status: AuthStatus.signedOut);
  }

  void clearError() => state = state.copyWith(clearError: true);

  String? _validate(String name, String email, String password) {
    if (name.trim().length < 2) return 'Bitte gib deinen Namen ein.';
    final normalized = email.trim();
    if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(normalized)) {
      return 'Bitte gib eine gültige E-Mail-Adresse ein.';
    }
    if (password.length < 10 ||
        !password.contains(RegExp('[A-Za-z]')) ||
        !password.contains(RegExp('[0-9]'))) {
      return 'Das Passwort braucht mindestens 10 Zeichen, Buchstaben und Zahlen.';
    }
    return null;
  }
}

PasswordDigest _hashPassword(String password) =>
    const PasswordHasher().hash(password);

bool _verifyPassword(({String password, String salt, String hash}) request) =>
    const PasswordHasher().verify(request.password, request.salt, request.hash);
