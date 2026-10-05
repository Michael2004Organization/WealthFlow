import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../security/secure_session_store.dart';
import 'server_client.dart';
import 'server_link.dart';

/// Connection of the signed-in local account to the home server.
final class ServerConnectionState {
  const ServerConnectionState({
    this.link,
    this.isBusy = false,
    this.error,
    this.needsLogin = false,
  });

  final ServerLink? link;
  final bool isBusy;
  final String? error;

  /// The server ended the session (logout, removed device, 30 days unused);
  /// the password has to be entered again.
  final bool needsLogin;

  bool get isConnected => link != null;
}

/// Pairs, signs in and keeps the access token fresh. The refresh token lives
/// in the platform key store, the short-lived access token only in memory.
final class ServerConnectionController
    extends StateNotifier<ServerConnectionState> {
  ServerConnectionController({
    required this.userId,
    required SecureSessionStore sessionStore,
    ServerClient? client,
  }) : _store = sessionStore,
       client = client ?? ServerClient(),
       super(const ServerConnectionState()) {
    if (userId != null) _load();
  }

  final String? userId;
  final SecureSessionStore _store;
  final ServerClient client;
  String? _accessToken;

  Future<void> _load() async {
    final link = await _store.readServerLink(userId!);
    if (!mounted) return;
    state = ServerConnectionState(link: link);
  }

  /// Pairs this device; returns true on success, otherwise [state] carries
  /// the reason.
  Future<bool> pair({
    required String address,
    required String code,
    required String email,
    required String password,
  }) async {
    final id = userId;
    if (id == null) return false;
    state = ServerConnectionState(link: state.link, isBusy: true);
    try {
      final session = await client.pair(
        address: address,
        code: code,
        email: email,
        password: password,
        deviceName: deviceName(),
      );
      await _store.writeServerLink(id, session.link);
      await _store.writeServerRefreshToken(id, session.tokens.refreshToken);
      _accessToken = session.tokens.accessToken;
      if (mounted) state = ServerConnectionState(link: session.link);
      return true;
    } on ServerException catch (error) {
      if (mounted) {
        state = ServerConnectionState(link: state.link, error: error.message);
      }
      return false;
    }
  }

  /// Signs in again after the server ended the session.
  Future<bool> login({required String password}) async {
    final id = userId, link = state.link;
    if (id == null || link == null) return false;
    state = ServerConnectionState(link: link, isBusy: true);
    try {
      final session = await client.login(
        link,
        email: link.email,
        password: password,
      );
      await _store.writeServerRefreshToken(id, session.tokens.refreshToken);
      _accessToken = session.tokens.accessToken;
      if (mounted) state = ServerConnectionState(link: link);
      return true;
    } on ServerException catch (error) {
      if (mounted) {
        state = ServerConnectionState(
          link: link,
          error: error.message,
          needsLogin: error.needsLogin,
        );
      }
      return false;
    }
  }

  /// Forgets the server on this device. Local data stays untouched.
  Future<void> disconnect() async {
    final id = userId, link = state.link;
    if (id == null) return;
    final token = _accessToken;
    if (link != null && token != null) {
      try {
        await client.logout(link, token);
      } on ServerException {
        // The local link is removed anyway; the device can be removed in the
        // server window later.
      }
    }
    _accessToken = null;
    await _store.writeServerLink(id, null);
    await _store.writeServerRefreshToken(id, null);
    if (mounted) state = const ServerConnectionState();
  }

  /// Runs [call] with a valid access token, refreshing it once when the
  /// server rejects it.
  Future<T> authorized<T>(
    Future<T> Function(ServerLink link, String accessToken) call,
  ) async {
    final id = userId, link = state.link;
    if (id == null || link == null) {
      throw const ServerException('Nicht mit einem Server verbunden.');
    }
    var token = _accessToken ?? await _refresh(id, link);
    try {
      return await call(link, token);
    } on ServerException catch (error) {
      if (!error.needsLogin) rethrow;
      token = await _refresh(id, link);
      return call(link, token);
    }
  }

  Future<String> _refresh(String id, ServerLink link) async {
    final refreshToken = await _store.readServerRefreshToken(id);
    if (refreshToken == null) return _sessionEnded(link);
    try {
      final tokens = await client.refresh(link, refreshToken);
      await _store.writeServerRefreshToken(id, tokens.refreshToken);
      _accessToken = tokens.accessToken;
      if (mounted && state.needsLogin) {
        state = ServerConnectionState(link: link);
      }
      return tokens.accessToken;
    } on ServerException catch (error) {
      if (error.needsLogin) {
        await _store.writeServerRefreshToken(id, null);
        return _sessionEnded(link);
      }
      rethrow;
    }
  }

  Never _sessionEnded(ServerLink link) {
    _accessToken = null;
    if (mounted) {
      state = ServerConnectionState(
        link: link,
        needsLogin: true,
        error: 'Bitte am Server erneut anmelden.',
      );
    }
    throw const ServerException(
      'Bitte am Server erneut anmelden.',
      status: 401,
    );
  }

  /// Name the server window shows for this device.
  static String deviceName() => switch (defaultTargetPlatform) {
    _ when kIsWeb => 'Browser',
    TargetPlatform.android => 'Android-Handy',
    TargetPlatform.iOS => 'iPhone',
    TargetPlatform.windows => 'Windows-PC',
    TargetPlatform.macOS => 'Mac',
    TargetPlatform.linux => 'Linux-PC',
    TargetPlatform.fuchsia => 'Gerät',
  };
}
