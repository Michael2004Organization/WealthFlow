import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/providers.dart';
import '../core/widgets/common_widgets.dart';
import 'app_lock_screen.dart';

/// Reacts to the app leaving and returning to the foreground while a user is
/// signed in.
class AppLifecycleGuard extends ConsumerStatefulWidget {
  const AppLifecycleGuard({required this.child, super.key});

  final Widget child;

  @override
  ConsumerState<AppLifecycleGuard> createState() => _AppLifecycleGuardState();
}

class _AppLifecycleGuardState extends ConsumerState<AppLifecycleGuard> {
  /// How long the app may stay in the background before the lock returns.
  static const lockAfter = Duration(seconds: 30);

  late final AppLifecycleListener _listener;
  Timer? _midnight;
  DateTime? _hiddenAt;
  late bool _locked;

  @override
  void initState() {
    super.initState();
    _listener = AppLifecycleListener(onHide: _onHide, onShow: _onShow);
    _scheduleMidnight();
    // A freshly entered password counts as unlocking; a restored session
    // stays covered until the PIN check below has run.
    _locked = ref.read(authControllerProvider.notifier).sessionRestored;
    if (_locked) unawaited(_lockIfPinSet());
  }

  Future<void> _lockIfPinSet() async {
    final pin = await ref.read(appPinProvider.future);
    if (!mounted) return;
    setState(() => _locked = pin != null);
  }

  @override
  void dispose() {
    _midnight?.cancel();
    _listener.dispose();
    super.dispose();
  }

  void _onShow() {
    final hiddenAt = _hiddenAt;
    _hiddenAt = null;
    if (hiddenAt != null &&
        !_locked &&
        DateTime.now().difference(hiddenAt) >= lockAfter) {
      _locked = true;
      unawaited(_lockIfPinSet());
    }
    _applyDueEntries();
    _scheduleMidnight();
    // Fetch what other devices changed in the meantime.
    unawaited(ref.read(serverSyncProvider.notifier).syncNow());
  }

  /// Bookings dated today only reach the account balance once their day has
  /// come; an app left open overnight books them right after midnight.
  void _scheduleMidnight() {
    _midnight?.cancel();
    final now = DateTime.now();
    final next = DateTime(now.year, now.month, now.day + 1, 0, 0, 5);
    _midnight = Timer(next.difference(now), () {
      _applyDueEntries();
      _scheduleMidnight();
    });
  }

  void _applyDueEntries() {
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) return;
    unawaited(ref.read(databaseProvider).applyDueLedgerEntries(userId));
  }

  void _onHide() {
    _hiddenAt ??= DateTime.now();
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) return;
    // The app may be closed in the background; write the data file now
    // instead of waiting for the bundled update.
    unawaited(ref.read(databaseProvider).flushPendingPersist(userId));
    unawaited(ref.read(serverSyncProvider.notifier).syncNow());
  }

  @override
  Widget build(BuildContext context) {
    // Keeps the sync with the home server running while someone is signed in.
    ref.listen(serverSyncProvider, (_, _) {});
    final currency =
        ref.watch(preferencesProvider).valueOrNull?.currency.toUpperCase() ??
        'EUR';
    moneyCurrency = currency;
    // Amounts are formatted with the standard currency; rebuild everything
    // below when it changes.
    final content = KeyedSubtree(key: ValueKey(currency), child: widget.child);
    // The app stays mounted underneath, so locking keeps its state.
    return Stack(
      fit: StackFit.expand,
      children: [
        ExcludeSemantics(
          excluding: _locked,
          child: Offstage(offstage: _locked, child: content),
        ),
        if (_locked)
          Positioned.fill(
            child: AppLockScreen(
              onUnlocked: () => setState(() => _locked = false),
            ),
          ),
      ],
    );
  }
}
