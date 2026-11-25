part of 'administration_page.dart';

class _ErrorLogsAdmin extends ConsumerWidget {
  const _ErrorLogsAdmin();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logs = ref.watch(errorLogsProvider);
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PageHeader(
            title: 'Fehlerprotokoll',
            action: OutlinedButton.icon(
              onPressed: () async {
                final actor = ref.read(currentUserIdProvider);
                if (actor != null) {
                  await ref.read(databaseProvider).clearErrorLogs(actor);
                }
              },
              icon: const Icon(Icons.delete_sweep_outlined),
              label: const Text('Leeren'),
            ),
          ),
          Expanded(
            child: logs.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(child: Text('$error')),
              data: (items) => items.isEmpty
                  ? const EmptyState(
                      icon: Icons.check_circle_outline_rounded,
                      title: 'Keine Fehler protokolliert',
                      message: 'Aktuell liegen keine Anwendungsfehler vor.',
                    )
                  : ListView.builder(
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final log = items[index];
                        return Card(
                          child: ExpansionTile(
                            leading: const Icon(Icons.error_outline_rounded),
                            title: Text(
                              _errorUserSummary(log),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Text(
                              '${_errorArea(log)} · ${log.source} · '
                              '${DateFormat('dd.MM.yyyy HH:mm:ss').format(log.occurredAt.toLocal())}',
                            ),
                            childrenPadding: const EdgeInsets.fromLTRB(
                              16,
                              0,
                              16,
                              16,
                            ),
                            expandedCrossAxisAlignment:
                                CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                'Technische Meldung',
                                style: Theme.of(context).textTheme.labelLarge,
                              ),
                              const SizedBox(height: 4),
                              SelectableText(log.message),
                              if (log.details.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: SelectableText(log.details),
                                ),
                              if (log.stackTrace.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                SelectableText(
                                  log.stackTrace,
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                              const SizedBox(height: 12),
                              Align(
                                alignment: Alignment.centerRight,
                                child: OutlinedButton.icon(
                                  onPressed: () async {
                                    await Clipboard.setData(
                                      ClipboardData(text: _copyableError(log)),
                                    );
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Fehler wurde kopiert.',
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                  icon: const Icon(Icons.copy_rounded),
                                  label: const Text('Fehler kopieren'),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

String _errorArea(AppErrorLog log) {
  final technical = '${log.details}\n${log.stackTrace}'.toLowerCase();
  // Most specific first; files of one page share its folder or prefix.
  const areas = <String, String>{
    'finance/dividend': 'Dividenden',
    'finance/accounts_page': 'Konten',
    'finance/': 'Portfolio',
    'features/statistics/': 'Statistik',
    'features/dashboard/': 'Cockpit',
    'features/household/': 'Haushaltsbuch',
    'settings/administration': 'Administration',
    'settings/master_data': 'Stammdaten',
    'features/settings/': 'Einstellungen',
    'features/vehicles/': 'Fahrzeuge',
    'features/calculators/': 'Rechner',
    'features/search/': 'Suche',
  };
  for (final entry in areas.entries) {
    if (technical.contains(entry.key)) return entry.value;
  }
  return 'Anwendung';
}

String _errorUserSummary(AppErrorLog log) {
  final technical = '${log.message}\n${log.details}\n${log.stackTrace}'
      .toLowerCase();
  final area = _errorArea(log);
  if (technical.contains('date_format') ||
      technical.contains('localeexists') ||
      technical.contains('intl')) {
    return '$area: Ein Datum konnte nicht angezeigt werden.';
  }
  if (technical.contains('database') || technical.contains('drift')) {
    return '$area: Daten konnten nicht gelesen oder gespeichert werden.';
  }
  if (technical.contains('overflow')) {
    return '$area: Ein Inhalt passte nicht in den verfügbaren Platz.';
  }
  if (technical.contains('network') ||
      technical.contains('socket') ||
      technical.contains('http')) {
    return '$area: Eine Netzwerkabfrage ist fehlgeschlagen.';
  }
  return '$area: Ein unerwarteter Fehler ist aufgetreten.';
}

String _copyableError(AppErrorLog log) =>
    'Kurzbeschreibung: ${_errorUserSummary(log)}\n'
    'Bereich: ${_errorArea(log)}\n'
    'Quelle: ${log.source}\n'
    'Zeitpunkt: ${DateFormat('dd.MM.yyyy HH:mm:ss').format(log.occurredAt.toLocal())}\n'
    'Meldung: ${log.message}\n'
    '${log.details.isEmpty ? '' : 'Details: ${log.details}\n'}'
    '${log.stackTrace.isEmpty ? '' : 'Stacktrace:\n${log.stackTrace}'}';
