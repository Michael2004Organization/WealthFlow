import 'dart:convert';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';

import '../../core/database/app_database.dart';
import '../../core/providers.dart';
import '../../core/storage/data_export.dart';
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
                title: 'Marktdaten-API',
                icon: Icons.key_rounded,
                children: [
                  FutureBuilder<String?>(
                    future: ref
                        .read(secureSessionStoreProvider)
                        .readMarketApiKey(user.id),
                    builder: (context, snapshot) {
                      final configured = snapshot.data?.isNotEmpty ?? false;
                      return ListTile(
                        leading: Icon(
                          configured
                              ? Icons.verified_user_rounded
                              : Icons.key_off_rounded,
                        ),
                        title: const Text('Financial Modeling Prep API-Key'),
                        subtitle: Text(
                          configured
                              ? 'Sicher im Plattform-Schlüsselspeicher hinterlegt'
                              : 'Nicht eingerichtet – Aktienabfragen bleiben deaktiviert',
                        ),
                        trailing: const Icon(Icons.chevron_right_rounded),
                        onTap: () => _editMarketApiKey(context, ref, user.id),
                      );
                    },
                  ),
                  const ListTile(
                    leading: Icon(Icons.schedule_rounded),
                    title: Text('Sparsame Aktualisierung vorbereitet'),
                    subtitle: Text(
                      'Ein globaler Aktienpool, Batch-Abfragen und Cache-Zeitfenster um 10:00, 15:00 und 19:00 Uhr. Bis die endgültige Datenquelle feststeht, werden keine Requests gesendet.',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _Section(
                title: 'Datenspeicherung',
                icon: Icons.storage_rounded,
                children: [
                  const ListTile(
                    leading: Icon(Icons.smartphone_rounded),
                    title: Text('Lokale Datenbank'),
                    subtitle: Text(
                      'Es findet keine Remote-Übertragung statt. SQLite und die optionale Datendatei bleiben unter deiner Kontrolle.',
                    ),
                  ),
                  const ListTile(
                    leading: Icon(Icons.shield_rounded),
                    title: Text('Sichere lokale Speicherung'),
                    subtitle: Text(
                      'Die App-Datenbank liegt im privaten App-Speicher. Die optionale .wflow-Datei wird zusätzlich mit AES-256-GCM verschlüsselt; Sitzung und Dateischlüssel nutzen den Plattform-Schlüsselspeicher.',
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.folder_open_rounded),
                    title: const Text('Ordner für Datendatei festlegen'),
                    subtitle: Text(
                      preference.dataFilePath.isEmpty
                          ? 'Noch kein Ordner ausgewählt'
                          : preference.dataFilePath,
                    ),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => _chooseDataFile(context, ref, preference),
                  ),
                  ListTile(
                    leading: const Icon(Icons.merge_type_rounded),
                    title: const Text('Datendatei zusammenführen'),
                    subtitle: const Text(
                      'Verschlüsselte .wflow- oder ältere JSON-Datei importieren',
                    ),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => _importDataFile(context, ref, preference),
                  ),
                  ListTile(
                    leading: const Icon(Icons.visibility_outlined),
                    title: const Text('Lokale Daten schreibgeschützt ansehen'),
                    subtitle: const Text(
                      'Benutzerbezogener JSON-Export ohne Passwörter',
                    ),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => _showLocalData(context, ref, user.id),
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
                'WealthFlow 1.0.0 · Lokale Datenbankversion 7',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showLocalData(
    BuildContext context,
    WidgetRef ref,
    String userId,
  ) async {
    final data = await ref.read(databaseProvider).exportUserData(userId);
    final json = const JsonEncoder.withIndent('  ').convert(data);
    if (!context.mounted) return;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        insetPadding: const EdgeInsets.all(16),
        title: const Text('Lokale Daten (schreibgeschützt)'),
        content: SizedBox(
          width: (MediaQuery.sizeOf(dialogContext).width - 64).clamp(280, 760),
          height: (MediaQuery.sizeOf(dialogContext).height - 220).clamp(
            260,
            620,
          ),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Theme.of(dialogContext).colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(12),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(14),
              child: SelectableText(
                json,
                style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
              ),
            ),
          ),
        ),
        actions: [
          TextButton.icon(
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: json));
              if (dialogContext.mounted) {
                ScaffoldMessenger.of(dialogContext).showSnackBar(
                  const SnackBar(content: Text('Export wurde kopiert.')),
                );
              }
            },
            icon: const Icon(Icons.copy_rounded),
            label: const Text('Kopieren'),
          ),
          FilledButton.icon(
            onPressed: () async {
              final date = DateTime.now().toIso8601String().substring(0, 10);
              final saved = await downloadReadonlyExport(
                json,
                'wealthflow-export-$date.json',
              );
              if (dialogContext.mounted && !saved) {
                ScaffoldMessenger.of(dialogContext).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Kein Speicherort gewählt. Auf diesem Gerät kann der Export weiterhin kopiert werden.',
                    ),
                  ),
                );
              }
            },
            icon: const Icon(Icons.download_rounded),
            label: const Text('JSON speichern'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Schließen'),
          ),
        ],
      ),
    );
  }

  Future<void> _editMarketApiKey(
    BuildContext context,
    WidgetRef ref,
    String userId,
  ) async {
    final store = ref.read(secureSessionStoreProvider);
    final current = await store.readMarketApiKey(userId) ?? '';
    if (!context.mounted) return;
    final controller = TextEditingController(text: current);
    var obscure = true;
    final submitted = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('FMP API-Key'),
          content: SizedBox(
            width: 480,
            child: TextField(
              controller: controller,
              obscureText: obscure,
              autocorrect: false,
              enableSuggestions: false,
              decoration: InputDecoration(
                labelText: 'API-Key',
                helperText: 'Leer speichern entfernt den vorhandenen Key.',
                suffixIcon: IconButton(
                  onPressed: () => setDialogState(() => obscure = !obscure),
                  icon: Icon(
                    obscure
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Abbrechen'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Sicher speichern'),
            ),
          ],
        ),
      ),
    );
    if (submitted == true) {
      final saved = await store.writeMarketApiKey(userId, controller.text);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              saved
                  ? 'API-Key wurde sicher gespeichert.'
                  : 'Der Plattform-Schlüsselspeicher ist nicht verfügbar. Der Key wurde nicht gespeichert.',
            ),
          ),
        );
      }
    }
    controller.dispose();
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
    String? selectedHouseholdAccountId,
    String? dataFilePath,
    double? freedomAge,
    double? freedomStartCapital,
    bool? freedomUsePortfolio,
    DateTime? lastSyncAt,
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
            selectedHouseholdAccountId: Value(
              selectedHouseholdAccountId ?? current.selectedHouseholdAccountId,
            ),
            dataFilePath: Value(dataFilePath ?? current.dataFilePath),
            freedomAge: Value(freedomAge ?? current.freedomAge),
            freedomStartCapital: Value(
              freedomStartCapital ?? current.freedomStartCapital,
            ),
            freedomUsePortfolio: Value(
              freedomUsePortfolio ?? current.freedomUsePortfolio,
            ),
            lastSyncAt: Value(lastSyncAt ?? current.lastSyncAt),
            updatedAt: DateTime.now().toUtc(),
          ),
        );
  }

  Future<void> _chooseDataFile(
    BuildContext context,
    WidgetRef ref,
    UserPreference preference,
  ) async {
    final path = await chooseDataFilePath('wealthflow-data.wflow');
    if (path == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Im Browser verhindert die Sicherheitsumgebung einen dauerhaft beschreibbaren Dateipfad. Nutze dort den JSON-Download.',
            ),
          ),
        );
      }
      return;
    }
    await _savePreference(ref, preference, dataFilePath: path);
    final saved = await ref
        .read(databaseProvider)
        .persistUserFile(preference.userId);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            saved
                ? 'Verschlüsselte Datendatei im gewählten Ordner gespeichert.'
                : 'Der Speicherort konnte nicht beschrieben werden.',
          ),
        ),
      );
    }
  }

  Future<void> _importDataFile(
    BuildContext context,
    WidgetRef ref,
    UserPreference preference,
  ) async {
    try {
      final content = await chooseDataImport();
      if (content == null) return;
      final decoded = await ref
          .read(databaseProvider)
          .decodeUserDataFile(preference.userId, content);
      await ref
          .read(databaseProvider)
          .mergeUserData(preference.userId, decoded);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Datendatei wurde verlustarm mit den lokalen Daten zusammengeführt.',
            ),
          ),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Die gewählte Datei ist kein gültiger WealthFlow-Export.',
            ),
          ),
        );
      }
    }
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
