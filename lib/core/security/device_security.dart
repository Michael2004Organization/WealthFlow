import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Security settings that belong to this device, not to the account.

const _lockDelayKey = 'security.lockAfterSeconds';
const _screenProtectionKey = 'security.screenProtection';

/// Choices for how long the app may stay in the background before the PIN
/// is asked again.
final lockDelayChoices = <Duration, String>{
  Duration.zero: 'Sofort',
  Duration(seconds: 30): '30 Sekunden',
  Duration(minutes: 1): '1 Minute',
  Duration(minutes: 5): '5 Minuten',
  Duration(minutes: 15): '15 Minuten',
};

const defaultLockDelay = Duration(seconds: 30);

final lockDelayProvider = FutureProvider<Duration>((ref) async {
  final preferences = await SharedPreferences.getInstance();
  final seconds = preferences.getInt(_lockDelayKey);
  final delay = seconds == null ? defaultLockDelay : Duration(seconds: seconds);
  return lockDelayChoices.containsKey(delay) ? delay : defaultLockDelay;
});

Future<void> setLockDelay(WidgetRef ref, Duration delay) async {
  final preferences = await SharedPreferences.getInstance();
  await preferences.setInt(_lockDelayKey, delay.inSeconds);
  ref.invalidate(lockDelayProvider);
}

/// Whether screenshots and the app switcher preview are blocked. Only
/// Android supports it; on by default.
bool get screenProtectionSupported =>
    !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

final screenProtectionProvider = FutureProvider<bool>((ref) async {
  final preferences = await SharedPreferences.getInstance();
  return preferences.getBool(_screenProtectionKey) ?? true;
});

Future<void> setScreenProtection(WidgetRef ref, bool enabled) async {
  final preferences = await SharedPreferences.getInstance();
  await preferences.setBool(_screenProtectionKey, enabled);
  ref.invalidate(screenProtectionProvider);
  await applyScreenProtection(enabled);
}

const _window = MethodChannel('wealthflow/window');

/// Sets or clears FLAG_SECURE on the Android window.
Future<void> applyScreenProtection(bool enabled) async {
  if (!screenProtectionSupported) return;
  try {
    await _window.invokeMethod<void>('setSecure', enabled);
  } on MissingPluginException {
    // Older native side without the channel: nothing to do.
  } on PlatformException catch (error) {
    debugPrint('Bildschirmschutz nicht gesetzt: $error');
  }
}
