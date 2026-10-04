import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/providers.dart';
import '../features/auth/auth_controller.dart';

/// Covers the app until the PIN of the app lock is entered.
class AppLockScreen extends ConsumerStatefulWidget {
  const AppLockScreen({required this.onUnlocked, super.key});

  final VoidCallback onUnlocked;

  @override
  ConsumerState<AppLockScreen> createState() => _AppLockScreenState();
}

class _AppLockScreenState extends ConsumerState<AppLockScreen> {
  final _pin = TextEditingController();
  var _busy = false;
  var _failures = 0;
  DateTime? _blockedUntil;
  String? _error;

  @override
  void dispose() {
    _pin.dispose();
    super.dispose();
  }

  Future<void> _unlock() async {
    final blockedUntil = _blockedUntil;
    if (blockedUntil != null && DateTime.now().isBefore(blockedUntil)) {
      setState(() => _error = 'Zu viele Versuche. Bitte kurz warten.');
      return;
    }
    final stored = await ref.read(appPinProvider.future);
    if (stored == null) {
      widget.onUnlocked();
      return;
    }
    setState(() => _busy = true);
    final valid = await verifyAppPin(_pin.text, stored);
    if (!mounted) return;
    if (valid) {
      widget.onUnlocked();
      return;
    }
    _failures++;
    setState(() {
      _busy = false;
      _pin.clear();
      if (_failures >= 5) {
        _blockedUntil = DateTime.now().add(const Duration(seconds: 30));
        _failures = 0;
        _error = 'Zu viele Versuche. Bitte 30 Sekunden warten.';
      } else {
        _error = 'Die PIN ist nicht korrekt.';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authControllerProvider).user;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 360),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(Icons.lock_rounded, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    'WealthFlow ist gesperrt',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  if (user != null) ...[
                    const SizedBox(height: 4),
                    Text(user.displayName, textAlign: TextAlign.center),
                  ],
                  const SizedBox(height: 24),
                  TextField(
                    controller: _pin,
                    autofocus: true,
                    obscureText: true,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    maxLength: 8,
                    decoration: InputDecoration(
                      labelText: 'PIN',
                      errorText: _error,
                      counterText: '',
                    ),
                    onSubmitted: (_) => unawaited(_unlock()),
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: _busy ? null : () => unawaited(_unlock()),
                    child: Text(_busy ? 'Wird geprüft …' : 'Entsperren'),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: _busy
                        ? null
                        : () => ref
                              .read(authControllerProvider.notifier)
                              .logout(),
                    child: const Text('PIN vergessen? Abmelden'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
