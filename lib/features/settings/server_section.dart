import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/providers.dart';
import '../../core/server/server_sync.dart';
import '../../core/storage/import_preview.dart';

/// Settings tiles for the connection to the home server.
class ServerConnectionTiles extends ConsumerWidget {
  const ServerConnectionTiles({super.key, required this.accountEmail});

  /// Email of the local account, suggested for the server account.
  final String accountEmail;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connection = ref.watch(serverConnectionProvider);
    final link = connection.link;
    if (link == null) {
      return ListTile(
        leading: const Icon(Icons.lan_rounded),
        title: const Text('Mit Server verbinden'),
        subtitle: const Text(
          'Adresse und Kopplungscode zeigt das Server-Fenster auf dem PC an '
          '(Enter drücken für einen neuen Code).',
        ),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: () => _pair(context, ref),
      );
    }
    return Column(
      children: [
        ListTile(
          leading: Icon(
            connection.needsLogin
                ? Icons.lock_clock_rounded
                : Icons.verified_user_rounded,
          ),
          title: Text('Verbunden mit ${_host(link.baseUrl)}'),
          subtitle: Text(
            connection.needsLogin
                ? 'Die Anmeldung ist abgelaufen. Bitte erneut anmelden.'
                : 'Angemeldet als ${link.email}. Nur dieser Server wird '
                      'akzeptiert (Zertifikat ${link.fingerprint.isEmpty ? 'vom Browser geprüft' : link.fingerprint.substring(0, 8)}…).',
          ),
        ),
        if (!connection.needsLogin) const _SyncStatusTile(),
        if (connection.needsLogin)
          ListTile(
            leading: const Icon(Icons.login_rounded),
            title: const Text('Erneut anmelden'),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => _login(context, ref, link.email),
          ),
        ListTile(
          leading: const Icon(Icons.link_off_rounded),
          title: const Text('Verbindung trennen'),
          subtitle: const Text('Die Daten auf diesem Gerät bleiben erhalten.'),
          onTap: () => _disconnect(context, ref),
        ),
      ],
    );
  }

  static String _host(String baseUrl) {
    final uri = Uri.tryParse(baseUrl);
    return uri == null ? baseUrl : '${uri.host}:${uri.port}';
  }

  Future<void> _pair(BuildContext context, WidgetRef ref) async {
    // Opened from the server itself: the browser already knows the address.
    final address = TextEditingController(
      text: kIsWeb && Uri.base.scheme == 'https' ? Uri.base.authority : '',
    );
    final code = TextEditingController();
    final email = TextEditingController(text: accountEmail);
    final password = TextEditingController();
    final formKey = GlobalKey<FormState>();
    String? error;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) {
          final busy = ref.watch(serverConnectionProvider).isBusy;
          Future<void> submit() async {
            if (!(formKey.currentState?.validate() ?? false)) return;
            final ok = await ref
                .read(serverConnectionProvider.notifier)
                .pair(
                  address: address.text,
                  code: code.text,
                  email: email.text,
                  password: password.text,
                );
            if (!dialogContext.mounted) return;
            if (ok) {
              Navigator.pop(dialogContext);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Mit dem Server verbunden.')),
              );
              await transferToServer(context, ref);
            } else {
              setDialogState(
                () => error = ref.read(serverConnectionProvider).error,
              );
            }
          }

          return AlertDialog(
            title: const Text('Mit Server verbinden'),
            content: SizedBox(
              width: 440,
              child: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: address,
                        enabled: !busy,
                        keyboardType: TextInputType.url,
                        decoration: const InputDecoration(
                          labelText: 'Adresse',
                          hintText: 'z. B. 192.168.178.20:8443',
                        ),
                        validator: (value) => (value?.trim().isEmpty ?? true)
                            ? 'Pflichtfeld'
                            : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: code,
                        enabled: !busy,
                        textCapitalization: TextCapitalization.characters,
                        decoration: const InputDecoration(
                          labelText: 'Kopplungscode',
                          hintText: 'ABCD-EFGH-JKMN',
                        ),
                        validator: (value) => (value?.trim().isEmpty ?? true)
                            ? 'Pflichtfeld'
                            : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: email,
                        enabled: !busy,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'E-Mail des Server-Kontos',
                        ),
                        validator: (value) => (value?.contains('@') ?? false)
                            ? null
                            : 'Bitte E-Mail angeben',
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: password,
                        enabled: !busy,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Passwort des Server-Kontos',
                        ),
                        validator: (value) =>
                            (value?.isEmpty ?? true) ? 'Pflichtfeld' : null,
                        onFieldSubmitted: (_) => submit(),
                      ),
                      if (error != null) ...[
                        const SizedBox(height: 16),
                        Text(
                          error!,
                          style: TextStyle(
                            color: Theme.of(dialogContext).colorScheme.error,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: busy ? null : () => Navigator.pop(dialogContext),
                child: const Text('Abbrechen'),
              ),
              FilledButton(
                onPressed: busy ? null : submit,
                child: busy
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Verbinden'),
              ),
            ],
          );
        },
      ),
    );
    address.dispose();
    code.dispose();
    email.dispose();
    password.dispose();
  }

  Future<void> _login(BuildContext context, WidgetRef ref, String email) async {
    final password = TextEditingController();
    final submitted = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Am Server anmelden'),
        content: SizedBox(
          width: 400,
          child: TextField(
            controller: password,
            obscureText: true,
            autofocus: true,
            decoration: InputDecoration(labelText: 'Passwort für $email'),
            onSubmitted: (_) => Navigator.pop(dialogContext, true),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Abbrechen'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Anmelden'),
          ),
        ],
      ),
    );
    final text = password.text;
    password.dispose();
    if (submitted != true || !context.mounted) return;
    final ok = await ref
        .read(serverConnectionProvider.notifier)
        .login(password: text);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok
              ? 'Wieder am Server angemeldet.'
              : ref.read(serverConnectionProvider).error ??
                    'Anmeldung fehlgeschlagen.',
        ),
      ),
    );
  }

  Future<void> _disconnect(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Verbindung trennen?'),
        content: const Text(
          'Dieses Gerät gleicht danach nicht mehr mit dem Server ab. Die Daten '
          'auf diesem Gerät und auf dem Server bleiben erhalten. Zum erneuten '
          'Verbinden brauchst du einen neuen Kopplungscode.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Abbrechen'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Trennen'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(serverConnectionProvider.notifier).disconnect();
      final userId = ref.read(currentUserIdProvider);
      if (userId != null) {
        await ref
            .read(databaseProvider)
            .saveServerState(userId, connected: false);
      }
    }
  }
}

/// Last sync with the server, the state of the data file on the PC and a
/// button to sync right away.
class _SyncStatusTile extends ConsumerWidget {
  const _SyncStatusTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sync = ref.watch(serverSyncProvider);
    if (sync.awaitingFirstSync) {
      return ListTile(
        leading: const Icon(Icons.cloud_upload_rounded),
        title: const Text('Daten auf Server übertragen'),
        subtitle: Text(
          sync.error ??
              'Noch nicht abgeglichen. Vorher siehst du, was übertragen wird.',
        ),
        trailing: sync.isRunning
            ? const SizedBox.square(
                dimension: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.chevron_right_rounded),
        onTap: sync.isRunning ? null : () => transferToServer(context, ref),
      );
    }
    final last = sync.lastSyncAt;
    final lines = [
      if (sync.isRunning)
        'Gleicht gerade ab …'
      else if (last == null)
        'Noch nicht abgeglichen.'
      else
        'Zuletzt abgeglichen: ${DateFormat('dd.MM.yyyy, HH:mm').format(last.toLocal())} Uhr.',
      if (sync.error != null) sync.error!,
      if (sync.error == null &&
          sync.dataFile != null &&
          sync.dataFile != ServerDataFile.unknown)
        sync.dataFile!.description,
    ];
    return ListTile(
      leading: Icon(
        sync.error == null ? Icons.sync_rounded : Icons.sync_problem_rounded,
        color: sync.error == null ? null : Theme.of(context).colorScheme.error,
      ),
      title: const Text('Abgleich'),
      subtitle: Text(lines.join('\n')),
      trailing: TextButton(
        onPressed: sync.isRunning
            ? null
            : () => ref.read(serverSyncProvider.notifier).syncNow(),
        child: const Text('Jetzt abgleichen'),
      ),
    );
  }
}

/// Shows what this device sends and starts the first sync on confirmation.
Future<void> transferToServer(BuildContext context, WidgetRef ref) async {
  final userId = ref.read(currentUserIdProvider);
  if (userId == null) return;
  final preview = ImportPreview.fromData(
    await ref.read(databaseProvider).exportUserData(userId),
  );
  if (!context.mounted) return;
  final empty =
      preview.accounts +
          preview.ledgerEntries +
          preview.investments +
          preview.vehicles +
          preview.reminders ==
      0;
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Daten auf Server übertragen?'),
      content: Text(
        empty
            ? 'Auf diesem Gerät gibt es noch keine Daten. Es holt die Daten, '
                  'die schon auf dem Server liegen.'
            : 'Von diesem Gerät gehen an den Server:\n\n'
                  '${preview.accounts} Konten\n'
                  '${preview.ledgerEntries} Buchungen\n'
                  '${preview.investments} Depotpositionen\n'
                  '${preview.vehicles} Fahrzeuge\n'
                  '${preview.reminders} Erinnerungen\n\n'
                  'Sie werden mit den Daten auf dem Server zusammengeführt. '
                  'Gleiche Einträge entstehen nicht doppelt, bei Unterschieden '
                  'gilt die neuere Fassung. Danach gleicht dieses Gerät '
                  'automatisch ab.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, false),
          child: const Text('Später'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(dialogContext, true),
          child: Text(empty ? 'Daten holen' : 'Übertragen'),
        ),
      ],
    ),
  );
  if (confirmed != true) return;
  final ok = await ref.read(serverSyncProvider.notifier).transfer();
  if (!context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        ok
            ? 'Daten mit dem Server abgeglichen.'
            : ref.read(serverSyncProvider).error ??
                  'Übertragung fehlgeschlagen.',
      ),
    ),
  );
}
