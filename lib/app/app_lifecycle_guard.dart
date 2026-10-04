import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/providers.dart';
import '../core/widgets/common_widgets.dart';

/// Reacts to the app leaving and returning to the foreground while a user is
/// signed in.
class AppLifecycleGuard extends ConsumerStatefulWidget {
  const AppLifecycleGuard({required this.child, super.key});

  final Widget child;

  @override
  ConsumerState<AppLifecycleGuard> createState() => _AppLifecycleGuardState();
}

class _AppLifecycleGuardState extends ConsumerState<AppLifecycleGuard> {
  late final AppLifecycleListener _listener;

  @override
  void initState() {
    super.initState();
    _listener = AppLifecycleListener(onHide: _onHide);
  }

  @override
  void dispose() {
    _listener.dispose();
    super.dispose();
  }

  void _onHide() {
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) return;
    // The app may be closed in the background; write the data file now
    // instead of waiting for the bundled update.
    unawaited(ref.read(databaseProvider).flushPendingPersist(userId));
  }

  @override
  Widget build(BuildContext context) {
    final currency =
        ref.watch(preferencesProvider).valueOrNull?.currency.toUpperCase() ??
        'EUR';
    moneyCurrency = currency;
    // Amounts are formatted with the standard currency; rebuild everything
    // below when it changes.
    return KeyedSubtree(key: ValueKey(currency), child: widget.child);
  }
}
