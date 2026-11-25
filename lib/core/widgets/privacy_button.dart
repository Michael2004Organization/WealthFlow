import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers.dart';

/// Eye button that hides all amounts in the app.
class PrivacyButton extends ConsumerWidget {
  const PrivacyButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hidden = ref.watch(privacyModeProvider);
    return IconButton(
      tooltip: hidden ? 'Beträge zeigen' : 'Beträge verbergen',
      isSelected: hidden,
      onPressed: () => togglePrivacyMode(ref),
      icon: const Icon(Icons.visibility_outlined),
      selectedIcon: const Icon(Icons.visibility_off_outlined),
    );
  }
}
