import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/database/app_database.dart';
import '../../core/providers.dart';
import '../../core/widgets/common_widgets.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preference = ref.watch(preferencesProvider).valueOrNull;
    final user = ref.watch(authControllerProvider).user;
    if (preference == null || user == null) {
      return const Center(child: CircularProgressIndicator());
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const PageHeader(
                title: 'Einstellungen',
                subtitle: 'Darstellung, Konto, Sicherheit und Datenmodus.',
              ),
              _Section(
                title: 'Profil',
                icon: Icons.person_rounded,
                children: [
                  ListTile(
                    leading: CircleAvatar(
                      radius: 26,
                      child: Text(user.displayName[0].toUpperCase()),
                    ),
                    title: Text(
                      user.displayName,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    subtitle: Text(user.email),
                  ),
                  ListTile(
                    leading: const Icon(Icons.password_rounded),
                    title: const Text('Passwort ändern'),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => _changePassword(context, ref),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _Section(
                title: 'Darstellung & Region',
                icon: Icons.palette_rounded,
                children: [
                  _DropdownTile(
                    icon: Icons.brightness_6_rounded,
                    title: 'Farbschema',
                    value: preference.themeMode,
                    values: const {
                      'system': 'System',
                      'light': 'Hell',
                      'dark': 'Dunkel',
                    },
                    onChanged: (value) =>
                        _savePreference(ref, preference, themeMode: value),
                  ),
                  _DropdownTile(
                    icon: Icons.language_rounded,
                    title: 'Sprache',
                    value: preference.locale,
                    values: const {'de': 'Deutsch', 'en': 'English'},
                    onChanged: (value) =>
                        _savePreference(ref, preference, locale: value),
                  ),
                  _DropdownTile(
                    icon: Icons.euro_rounded,
                    title: 'Standardwährung',
                    value: preference.currency,
                    values: const {
                      'EUR': 'EUR',
                      'USD': 'USD',
                      'CHF': 'CHF',
                      'GBP': 'GBP',
                    },
                    onChanged: (value) =>
                        _savePreference(ref, preference, currency: value),
                  ),
                  _DropdownTile(
                    icon: Icons.calendar_month_rounded,
                    title: 'Datumsformat',
                    value: preference.dateFormat,
                    values: const {
                      'dd.MM.yyyy': '31.12.2026',
                      'yyyy-MM-dd': '2026-12-31',
                      'MM/dd/yyyy': '12/31/2026',
                    },
                    onChanged: (value) =>
                        _savePreference(ref, preference, dateFormat: value),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _Section(
                title: 'Datenspeicherung',
                icon: Icons.storage_rounded,
                children: [
                  SwitchListTile(
                    secondary: Icon(
                      preference.serverMode
                          ? Icons.cloud_done_rounded
                          : Icons.smartphone_rounded,
                    ),
                    title: Text(
                      preference.serverMode ? 'Servermodus' : 'Lokaler Modus',
                    ),
                    subtitle: Text(
                      preference.serverMode
                          ? 'Die Verbindungseinstellungen für den kompatiblen Server sind hinterlegt.'
                          : 'Alle Daten liegen ausschließlich auf diesem Gerät.',
                    ),
                    value: preference.serverMode,
                    onChanged: (value) async {
                      if (value) {
                        await _configureServer(context, ref, preference);
                      } else {
                        await _savePreference(
                          ref,
                          preference,
                          serverMode: false,
                        );
                      }
                    },
                  ),
                  if (preference.serverMode)
                    ListTile(
                      leading: const Icon(Icons.dns_rounded),
                      title: Text(preference.serverUrl),
                      subtitle: Text(
                        '${preference.serverUsername} · Port ${preference.serverPort}',
                      ),
                      trailing: const Icon(Icons.edit_rounded),
                      onTap: () => _configureServer(context, ref, preference),
                    ),
                  const ListTile(
                    leading: Icon(Icons.shield_rounded),
                    title: Text('Sichere lokale Speicherung'),
                    subtitle: Text(
                      'Finanzdaten liegen lokal in SQLite beziehungsweise im Web-Speicher. Die Sitzung nutzt den Plattform-Schlüsselspeicher mit lokalem Cache als Fallback.',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () =>
                    ref.read(authControllerProvider.notifier).logout(),
                icon: const Icon(Icons.logout_rounded),
                label: const Text('Abmelden'),
              ),
              const SizedBox(height: 24),
              Text(
                'WealthFlow 1.0.0 · Lokale Datenbankversion 2',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _savePreference(
    WidgetRef ref,
    UserPreference current, {
    String? themeMode,
    String? locale,
    String? currency,
    String? dateFormat,
    bool? serverMode,
    String? serverUrl,
    int? serverPort,
    String? serverUsername,
  }) {
    return ref
        .read(databaseProvider)
        .savePreferences(
          UserPreferencesCompanion.insert(
            userId: current.userId,
            themeMode: Value(themeMode ?? current.themeMode),
            locale: Value(locale ?? current.locale),
            currency: Value(currency ?? current.currency),
            dateFormat: Value(dateFormat ?? current.dateFormat),
            serverMode: Value(serverMode ?? current.serverMode),
            serverUrl: Value(serverUrl ?? current.serverUrl),
            serverPort: Value(serverPort ?? current.serverPort),
            serverUsername: Value(serverUsername ?? current.serverUsername),
            updatedAt: DateTime.now().toUtc(),
          ),
        );
  }

  Future<void> _changePassword(BuildContext context, WidgetRef ref) async {
    final current = TextEditingController();
    final replacement = TextEditingController();
    final confirm = TextEditingController();
    final key = GlobalKey<FormState>();
    final submitted = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Passwort ändern'),
        content: SizedBox(
          width: 440,
          child: Form(
            key: key,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: current,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Aktuelles Passwort',
                  ),
                  validator: (value) =>
                      (value?.isEmpty ?? true) ? 'Pflichtfeld' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: replacement,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Neues Passwort',
                  ),
                  validator: (value) => (value?.length ?? 0) < 10
                      ? 'Mindestens 10 Zeichen'
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: confirm,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Neues Passwort bestätigen',
                  ),
                  validator: (value) => value != replacement.text
                      ? 'Passwörter stimmen nicht überein'
                      : null,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Abbrechen'),
          ),
          FilledButton(
            onPressed: () {
              if (key.currentState?.validate() ?? false) {
                Navigator.pop(context, true);
              }
            },
            child: const Text('Ändern'),
          ),
        ],
      ),
    );
    if (submitted == true && context.mounted) {
      final ok = await ref
          .read(authControllerProvider.notifier)
          .changePassword(current.text, replacement.text);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              ok
                  ? 'Passwort wurde geändert.'
                  : ref.read(authControllerProvider).error ??
                        'Passwort konnte nicht geändert werden.',
            ),
          ),
        );
      }
    }
    current.dispose();
    replacement.dispose();
    confirm.dispose();
  }

  Future<void> _configureServer(
    BuildContext context,
    WidgetRef ref,
    UserPreference current,
  ) async {
    final url = TextEditingController(
      text: current.serverUrl.isEmpty ? 'https://' : current.serverUrl,
    );
    final port = TextEditingController(text: current.serverPort.toString());
    final username = TextEditingController(text: current.serverUsername);
    final password = TextEditingController();
    final apiKey = TextEditingController();
    final key = GlobalKey<FormState>();
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Server konfigurieren'),
        content: SizedBox(
          width: 520,
          child: Form(
            key: key,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  TextFormField(
                    controller: url,
                    decoration: const InputDecoration(
                      labelText: 'Serveradresse',
                    ),
                    validator: (value) {
                      final uri = Uri.tryParse(value ?? '');
                      return uri == null ||
                              uri.scheme != 'https' ||
                              uri.host.isEmpty
                          ? 'Eine gültige HTTPS-Adresse ist erforderlich.'
                          : null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: port,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Port'),
                    validator: (value) {
                      final number = int.tryParse(value ?? '');
                      return number == null || number < 1 || number > 65535
                          ? 'Port 1–65535'
                          : null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: username,
                    decoration: const InputDecoration(
                      labelText: 'Benutzername',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: password,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Passwort',
                      helperText:
                          'Leer lassen, um das gespeicherte Passwort beizubehalten.',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: apiKey,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'API-Key',
                      helperText:
                          'Wird ausschließlich im sicheren Schlüsselspeicher abgelegt.',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Abbrechen'),
          ),
          FilledButton(
            onPressed: () {
              if (key.currentState?.validate() ?? false) {
                Navigator.pop(context, true);
              }
            },
            child: const Text('Sicher speichern'),
          ),
        ],
      ),
    );
    if (result == true) {
      await ref
          .read(secureSessionStoreProvider)
          .writeServerSecrets(
            userId: current.userId,
            password: password.text,
            apiKey: apiKey.text,
          );
      await _savePreference(
        ref,
        current,
        serverMode: true,
        serverUrl: url.text.trim(),
        serverPort: int.parse(port.text),
        serverUsername: username.text.trim(),
      );
    }
    url.dispose();
    port.dispose();
    username.dispose();
    password.dispose();
    apiKey.dispose();
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.title,
    required this.icon,
    required this.children,
  });
  final String title;
  final IconData icon;
  final List<Widget> children;
  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 10, 18, 8),
            child: Row(
              children: [
                Icon(icon, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          ...children,
        ],
      ),
    ),
  );
}

class _DropdownTile extends StatelessWidget {
  const _DropdownTile({
    required this.icon,
    required this.title,
    required this.value,
    required this.values,
    required this.onChanged,
  });
  final IconData icon;
  final String title;
  final String value;
  final Map<String, String> values;
  final ValueChanged<String> onChanged;
  @override
  Widget build(BuildContext context) => ListTile(
    leading: Icon(icon),
    title: Text(title),
    trailing: DropdownButton<String>(
      value: value,
      underline: const SizedBox.shrink(),
      items: values.entries
          .map(
            (entry) =>
                DropdownMenuItem(value: entry.key, child: Text(entry.value)),
          )
          .toList(),
      onChanged: (newValue) {
        if (newValue != null) onChanged(newValue);
      },
    ),
  );
}
