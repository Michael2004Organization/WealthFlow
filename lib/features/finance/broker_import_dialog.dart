import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wealthflow_core/database/app_database.dart';
import 'package:wealthflow_core/finance/trade_republic_csv.dart';

import '../../app/app_theme.dart';
import '../../core/providers.dart';
import '../../core/storage/data_export.dart';
import '../../core/widgets/common_widgets.dart';

/// Reads a Trade Republic "Transaktionsexport" and books its buys, sells
/// and dividends into the depot [accountId].
Future<void> startBrokerImport(
  BuildContext context,
  WidgetRef ref, {
  required String accountId,
}) async {
  final messenger = ScaffoldMessenger.of(context);
  final userId = ref.read(currentUserIdProvider);
  if (userId == null) return;
  final bytes = await chooseCsvFile();
  if (bytes == null || !context.mounted) return;
  final result = parseTradeRepublicCsv(
    utf8.decode(bytes, allowMalformed: true),
  );
  if (result.error != null) {
    messenger.showSnackBar(SnackBar(content: Text(result.error!)));
    return;
  }
  if (result.transactions.isEmpty) {
    messenger.showSnackBar(
      const SnackBar(
        content: Text('Keine Käufe, Verkäufe oder Dividenden in der Datei.'),
      ),
    );
    return;
  }
  final bookCash = await showDialog<bool>(
    context: context,
    builder: (_) => _BrokerImportPreview(result: result),
  );
  if (bookCash == null || !context.mounted) return;
  final summary = await ref
      .read(databaseProvider)
      .importBrokerTransactions(
        userId: userId,
        accountId: accountId,
        transactions: result.transactions,
        bookCash: bookCash,
      );
  if (!context.mounted) return;
  await showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Import abgeschlossen'),
      content: SizedBox(
        width: (MediaQuery.sizeOf(dialogContext).width - 64).clamp(280, 480),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${summary.buys} Käufe · ${summary.sells} Verkäufe · '
                '${summary.dividends} Dividenden übernommen',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              if (summary.createdPositions > 0)
                Text('${summary.createdPositions} neue Positionen angelegt'),
              if (summary.duplicates > 0)
                Text(
                  '${summary.duplicates} schon vorhanden, nicht doppelt gebucht',
                ),
              if (summary.failures.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  '${summary.failures.length} nicht übernommen:',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: WealthColors.of(dialogContext).expense,
                  ),
                ),
                for (final failure in summary.failures.take(20))
                  Text('• $failure', style: const TextStyle(fontSize: 13)),
                if (summary.failures.length > 20)
                  Text('… und ${summary.failures.length - 20} weitere'),
              ],
            ],
          ),
        ),
      ),
      actions: [
        FilledButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: const Text('Fertig'),
        ),
      ],
    ),
  );
}

class _BrokerImportPreview extends StatefulWidget {
  const _BrokerImportPreview({required this.result});

  final BrokerCsvResult result;

  @override
  State<_BrokerImportPreview> createState() => _BrokerImportPreviewState();
}

class _BrokerImportPreviewState extends State<_BrokerImportPreview> {
  var _bookCash = true;

  @override
  Widget build(BuildContext context) {
    final colors = WealthColors.of(context);
    final rows = widget.result.transactions;
    int count(BrokerTransactionKind kind) =>
        rows.where((row) => row.kind == kind).length;
    return AlertDialog(
      title: const Text('Trade Republic importieren'),
      content: SizedBox(
        width: (MediaQuery.sizeOf(context).width - 64).clamp(280, 560),
        height: (MediaQuery.sizeOf(context).height * .6).clamp(240, 520),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '${count(BrokerTransactionKind.buy)} Käufe · '
              '${count(BrokerTransactionKind.sell)} Verkäufe · '
              '${count(BrokerTransactionKind.dividend)} Dividenden',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            if (widget.result.skipped > 0)
              Text(
                '${widget.result.skipped} andere Zeilen werden übersprungen '
                '(${widget.result.skippedTypes.keys.take(4).join(', ')}).',
                style: TextStyle(fontSize: 12, color: colors.muted),
              ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: _bookCash,
              onChanged: (value) => setState(() => _bookCash = value),
              title: const Text('Geld im Depotkonto mitbuchen'),
              subtitle: const Text(
                'Käufe verringern, Dividenden erhöhen den Kontostand. '
                'Verkäufe werden immer gutgeschrieben.',
              ),
            ),
            const Divider(),
            Expanded(
              child: ListView.builder(
                itemCount: rows.length,
                itemBuilder: (context, index) {
                  final row = rows[index];
                  final label = switch (row.kind) {
                    BrokerTransactionKind.buy => 'Kauf',
                    BrokerTransactionKind.sell => 'Verkauf',
                    BrokerTransactionKind.dividend => 'Dividende',
                  };
                  return ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      row.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      '$label · ${shortDate(row.date)}'
                      '${row.kind == BrokerTransactionKind.dividend ? '' : ' · ${quantityText(row.shares)} Stück'}',
                    ),
                    trailing: Text(
                      money(
                        row.kind == BrokerTransactionKind.dividend
                            ? row.netAmount
                            : row.amount,
                      ),
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  );
                },
              ),
            ),
            Text(
              'Positionen werden über die ISIN zugeordnet, fehlende neu '
              'angelegt. Schon importierte Zeilen werden erkannt.',
              style: TextStyle(fontSize: 12, color: colors.muted),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Abbrechen'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, _bookCash),
          child: Text('${rows.length} übernehmen'),
        ),
      ],
    );
  }
}
