import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/design.dart';
import '../providers.dart';

/// Palette button that switches between Bento, Terminal and Hell & Dunkel.
///
/// With [expanded] it shows the current design next to the icon (sidebar);
/// otherwise it is an icon button (phone headers).
class DesignSwitcher extends ConsumerWidget {
  const DesignSwitcher({super.key, this.expanded = false});

  final bool expanded;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(designChoiceProvider);
    final scheme = Theme.of(context).colorScheme;
    return PopupMenuButton<DesignChoice>(
      tooltip: 'Design wechseln',
      initialValue: current,
      onSelected: (choice) => saveDesignChoice(ref, choice),
      itemBuilder: (context) => [
        for (final choice in DesignChoice.all)
          CheckedPopupMenuItem<DesignChoice>(
            value: choice,
            checked: choice == current,
            child: Text(choice.label),
          ),
      ],
      child: expanded
          ? Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
              child: Row(
                children: [
                  Icon(
                    Icons.palette_outlined,
                    size: 18,
                    color: scheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Design: ${current.label}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: scheme.onSurfaceVariant),
                    ),
                  ),
                  Icon(
                    Icons.unfold_more_rounded,
                    size: 18,
                    color: scheme.onSurfaceVariant,
                  ),
                ],
              ),
            )
          : const SizedBox(
              width: 44,
              height: 44,
              child: Icon(
                Icons.palette_outlined,
                semanticLabel: 'Design wechseln',
              ),
            ),
    );
  }
}
