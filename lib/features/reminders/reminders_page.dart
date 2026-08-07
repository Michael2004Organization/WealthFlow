import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../core/database/app_database.dart';
import '../../core/providers.dart';
import '../../core/widgets/common_widgets.dart';

class RemindersPage extends ConsumerWidget {
  const RemindersPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reminders = ref.watch(remindersProvider);
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              PageHeader(
                title: 'Erinnerungen',
                subtitle:
                    'Termine planen und als Systembenachrichtigung erhalten.',
                action: FilledButton.icon(
                  onPressed: () => showReminderEditor(context, ref),
                  icon: const Icon(Icons.add_alert_rounded),
                  label: const Text('Erinnerung'),
                ),
              ),
              Expanded(
                child: reminders.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (error, _) => Center(
                    child: Text(
                      'Erinnerungen konnten nicht geladen werden: $error',
                    ),
                  ),
                  data: (items) => items.isEmpty
                      ? EmptyState(
                          icon: Icons.notifications_active_outlined,
                          title: 'Noch keine Erinnerungen',
                          message:
                              'Lege einen Termin wie „Abo kündigen“ an oder verknüpfe ihn direkt mit einer Buchung.',
                          action: FilledButton.icon(
                            onPressed: () => showReminderEditor(context, ref),
                            icon: const Icon(Icons.add_rounded),
                            label: const Text('Erinnerung erstellen'),
                          ),
                        )
                      : ListView.separated(
                          itemCount: items.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 8),
                          itemBuilder: (context, index) =>
                              _ReminderTile(reminder: items[index]),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReminderTile extends ConsumerWidget {
  const _ReminderTile({required this.reminder});

  final AppReminder reminder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final local = reminder.scheduledAt.toLocal();
    final overdue = local.isBefore(DateTime.now());
    return Card(
      child: ListTile(
        onTap: () => showReminderEditor(context, ref, reminder: reminder),
        leading: CircleAvatar(
          backgroundColor: (overdue ? Colors.grey : Colors.deepPurple)
              .withValues(alpha: .14),
          child: Icon(
            overdue ? Icons.notifications_off_outlined : Icons.alarm_rounded,
            color: overdue ? Colors.grey : Colors.deepPurple,
          ),
        ),
        title: Text(
          reminder.title,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: Text(
          DateFormat('dd.MM.yyyy · HH:mm').format(local) +
              (reminder.ledgerEntryId.isEmpty
                  ? ''
                  : ' · mit Buchung verknüpft'),
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) async {
            if (value == 'edit') {
              await showReminderEditor(context, ref, reminder: reminder);
              return;
            }
            final userId = ref.read(currentUserIdProvider);
            if (userId == null ||
                !await confirmDelete(
                  context,
                  title: 'Erinnerung löschen?',
                  message:
                      'Die geplante Benachrichtigung wird ebenfalls entfernt.',
                )) {
              return;
            }
            await ref.read(notificationServiceProvider).cancel(reminder.id);
            await ref
                .read(databaseProvider)
                .deleteReminder(reminder.id, userId);
          },
          itemBuilder: (_) => const [
            PopupMenuItem(value: 'edit', child: Text('Bearbeiten')),
            PopupMenuItem(value: 'delete', child: Text('Löschen')),
          ],
        ),
      ),
    );
  }
}

Future<void> showReminderEditor(
  BuildContext context,
  WidgetRef ref, {
  AppReminder? reminder,
  String ledgerEntryId = '',
  String? suggestedTitle,
}) async {
  final userId = ref.read(currentUserIdProvider);
  if (userId == null) return;
  final title = TextEditingController(
    text: reminder?.title ?? suggestedTitle ?? '',
  );
  var scheduledAt =
      reminder?.scheduledAt.toLocal() ??
      DateTime.now().add(const Duration(days: 1));
  final formKey = GlobalKey<FormState>();
  final saved = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (context, setDialogState) => AlertDialog(
        title: Text(
          reminder == null ? 'Erinnerung erstellen' : 'Erinnerung bearbeiten',
        ),
        content: SizedBox(
          width: (MediaQuery.sizeOf(context).width - 64).clamp(280, 520),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: title,
                  autofocus: true,
                  decoration: const InputDecoration(
                    labelText: 'Woran möchtest du erinnert werden?',
                    prefixIcon: Icon(Icons.notifications_outlined),
                  ),
                  validator: (value) => (value?.trim().isEmpty ?? true)
                      ? 'Bitte einen Titel eingeben.'
                      : null,
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: () async {
                    final selected = await showDatePicker(
                      context: context,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 3650)),
                      initialDate: scheduledAt,
                    );
                    if (selected != null) {
                      setDialogState(
                        () => scheduledAt = DateTime(
                          selected.year,
                          selected.month,
                          selected.day,
                          scheduledAt.hour,
                          scheduledAt.minute,
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.calendar_month_rounded),
                  label: Text(DateFormat('dd.MM.yyyy').format(scheduledAt)),
                ),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: () async {
                    final selected = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.fromDateTime(scheduledAt),
                    );
                    if (selected != null) {
                      setDialogState(
                        () => scheduledAt = DateTime(
                          scheduledAt.year,
                          scheduledAt.month,
                          scheduledAt.day,
                          selected.hour,
                          selected.minute,
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.schedule_rounded),
                  label: Text(
                    '${DateFormat('HH:mm').format(scheduledAt)} Uhr',
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Abbrechen'),
          ),
          FilledButton(
            onPressed: () {
              if (formKey.currentState?.validate() ?? false) {
                Navigator.pop(dialogContext, true);
              }
            },
            child: const Text('Speichern'),
          ),
        ],
      ),
    ),
  );
  if (saved == true) {
    final id = reminder?.id ?? const Uuid().v4();
    final now = DateTime.now().toUtc();
    final value = RemindersCompanion.insert(
      id: id,
      userId: userId,
      title: title.text.trim(),
      scheduledAt: scheduledAt.toUtc(),
      ledgerEntryId: Value(reminder?.ledgerEntryId ?? ledgerEntryId),
      createdAt: reminder?.createdAt ?? now,
      updatedAt: now,
    );
    await ref.read(databaseProvider).saveReminder(value);
    final notifications = ref.read(notificationServiceProvider);
    await notifications.requestPermissions();
    await notifications.schedule(
      id: id,
      title: title.text.trim(),
      scheduledAt: scheduledAt,
    );
  }
  title.dispose();
}
