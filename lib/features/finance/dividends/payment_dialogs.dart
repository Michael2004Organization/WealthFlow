part of '../dividends_page.dart';

Future<void> _showDividendPayments(
  BuildContext context, {
  required String title,
  required List<ProjectedDividend> payments,
  required String baseCurrency,
}) {
  var newestFirst = true;
  return showDialog<void>(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (context, setState) {
        final sorted = [...payments]
          ..sort(
            (a, b) => newestFirst
                ? b.date.compareTo(a.date)
                : a.date.compareTo(b.date),
          );
        return AlertDialog(
          title: Row(
            children: [
              Expanded(child: Text(title)),
              TextButton.icon(
                onPressed: () => setState(() => newestFirst = !newestFirst),
                icon: Icon(
                  newestFirst
                      ? Icons.arrow_downward_rounded
                      : Icons.arrow_upward_rounded,
                ),
                label: Text(newestFirst ? 'Neueste' : 'Älteste'),
              ),
            ],
          ),
          content: SizedBox(
            width: (MediaQuery.sizeOf(context).width - 64).clamp(280, 620),
            child: sorted.isEmpty
                ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 28),
                    child: Text(
                      'In diesem Zeitraum sind keine Dividenden vorhanden.',
                      textAlign: TextAlign.center,
                    ),
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    itemCount: sorted.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final payment = sorted[index];
                      final status = !payment.paymentDateKnown
                          ? 'Zahltag offen'
                          : payment.date.isAfter(DateTime.now())
                          ? 'Zukünftig'
                          : 'Eingegangen';
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(
                          child: Text(
                            payment.investment.symbol.isEmpty
                                ? payment.investment.name.substring(0, 1)
                                : payment.investment.symbol.substring(0, 1),
                          ),
                        ),
                        title: Text(payment.investment.name),
                        subtitle: Text(
                          '${DateFormat('dd.MM.yyyy').format(payment.date)} · $status',
                        ),
                        trailing: Text(
                          money(
                            payment.tax.net,
                            currency: payment.accountCurrency,
                          ),
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                        onTap: () => _showDividendPaymentDetail(
                          context,
                          payment: payment,
                        ),
                      );
                    },
                  ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Schließen'),
            ),
          ],
        );
      },
    ),
  );
}

Future<void> _showDividendPaymentDetail(
  BuildContext context, {
  required ProjectedDividend payment,
}) => showDialog<void>(
  context: context,
  builder: (dialogContext) => AlertDialog(
    title: Text('${payment.investment.name} · Brutto bis Netto'),
    content: SizedBox(
      width: (MediaQuery.sizeOf(dialogContext).width - 80).clamp(280.0, 520.0),
      child: SingleChildScrollView(
        child: DividendTaxBreakdown(
          tax: payment.tax,
          sourceCurrency: payment.sourceCurrency,
          accountCurrency: payment.accountCurrency,
          exchangeRate: payment.exchangeRate <= 0 ? 1 : payment.exchangeRate,
          withholdingTaxRate: payment.withholdingTaxRate,
          country: payment.investment.country,
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

Future<void> _showScheduleEditor(
  BuildContext context,
  WidgetRef ref, {
  required Investment investment,
  DividendSchedule? schedule,
  required String baseCurrency,
}) async {
  final existing =
      (ref.read(dividendSchedulesProvider).valueOrNull ??
              const <DividendSchedule>[])
          .where((row) => row.investmentId == investment.id)
          .toList();
  final amount = TextEditingController(
    text:
        schedule?.amountPerShare.toString() ??
        (investment.annualDividend > 0
            ? investment.annualDividend.toString()
            : ''),
  );
  var startMonth =
      schedule?.paymentMonth ?? existing.firstOrNull?.paymentMonth ?? 1;
  var months = schedule != null
      ? <int>{schedule.paymentMonth}
      : <int>{startMonth};
  var exDate = schedule?.exDate;
  var paymentDate = schedule?.paymentDate;
  final currency = TextEditingController(
    text: schedule?.currency ?? investment.dividendCurrency,
  );
  final exchangeRate = TextEditingController(
    text: (schedule?.exchangeRate ?? investment.dividendExchangeRate)
        .toString(),
  );
  final taxRate = TextEditingController(
    text:
        (schedule?.withholdingTaxRate ?? investment.dividendWithholdingTaxRate)
            .toString(),
  );
  final key = GlobalKey<FormState>();
  final result = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (context, setDialogState) => AlertDialog(
        title: Text('Auszahlung für ${investment.name}'),
        content: SizedBox(
          width: (MediaQuery.sizeOf(context).width - 64).clamp(280, 560),
          child: Form(
            key: key,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (schedule == null) ...[
                    SearchableDropdownButtonFormField<int>(
                      initialValue: startMonth,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Startmonat des Rhythmus',
                      ),
                      items: List.generate(
                        12,
                        (index) => DropdownMenuItem(
                          value: index + 1,
                          child: Text(monthNames[index]),
                        ),
                      ),
                      onChanged: (value) {
                        if (value == null) return;
                        setDialogState(() {
                          startMonth = value;
                          months = <int>{startMonth};
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                  ],
                  Text(
                    schedule == null
                        ? 'Auszahlungsmonate'
                        : 'Abweichende Auszahlung',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (var month = 1; month <= 12; month++)
                        FilterChip(
                          label: Text(monthNames[month - 1].substring(0, 3)),
                          selected: months.contains(month),
                          onSelected: schedule != null
                              ? null
                              : (selected) => setDialogState(() {
                                  if (selected) {
                                    months.add(month);
                                  } else {
                                    months.remove(month);
                                  }
                                }),
                        ),
                    ],
                  ),
                  if (months.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        'Wähle mindestens einen Auszahlungsmonat.',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: amount,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    onChanged: (_) => setDialogState(() {}),
                    decoration: InputDecoration(
                      labelText: 'Dividende je Aktie und Auszahlung',
                      suffixText: currency.text.trim().toUpperCase(),
                    ),
                    validator: (value) {
                      final parsed = parseAmount(value);
                      return parsed == null || parsed <= 0
                          ? 'Bitte einen positiven Betrag eingeben.'
                          : null;
                    },
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: months.length == 1
                        ? () async {
                            final selected = await showDatePicker(
                              context: context,
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2100),
                              initialDate: exDate ?? DateTime.now(),
                            );
                            if (selected != null) {
                              setDialogState(() => exDate = selected);
                            }
                          }
                        : null,
                    icon: const Icon(Icons.event_rounded),
                    label: Text(
                      months.length > 1
                          ? 'Ex-Datum bei Bedarf je Monat bearbeiten'
                          : exDate == null
                          ? 'Ex-Datum auswählen'
                          : 'Ex-Datum ${DateFormat('dd.MM.yyyy').format(exDate!)}',
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: months.length == 1
                        ? () async {
                            final selected = await showDatePicker(
                              context: context,
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2100),
                              initialDate: paymentDate ?? DateTime.now(),
                            );
                            if (selected != null) {
                              setDialogState(() => paymentDate = selected);
                            }
                          }
                        : null,
                    icon: const Icon(Icons.payments_outlined),
                    label: Text(
                      months.length > 1
                          ? 'Zahlungstermin bei Bedarf je Eintrag bearbeiten'
                          : paymentDate == null
                          ? 'Zahlungstermin auswählen'
                          : 'Zahlung ${DateFormat('dd.MM.yyyy').format(paymentDate!)}',
                    ),
                  ),
                  const SizedBox(height: 12),
                  SearchableDropdownButtonFormField<String>(
                    initialValue: currency.text.trim().toUpperCase(),
                    isExpanded: true,
                    decoration: const InputDecoration(labelText: 'Währung'),
                    items:
                        <String>{
                              ...supportedIsoCurrencies,
                              currency.text.trim().toUpperCase(),
                            }
                            .where((value) => value.isNotEmpty)
                            .map(
                              (value) => DropdownMenuItem(
                                value: value,
                                child: Text(value),
                              ),
                            )
                            .toList(),
                    onChanged: (value) => setDialogState(
                      () => currency.text = value ?? currency.text,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: exchangeRate,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    onChanged: (_) => setDialogState(() {}),
                    decoration: InputDecoration(
                      labelText: 'Umrechnung zu $baseCurrency',
                      helperText:
                          '1 ${currency.text.trim().toUpperCase()} = ? $baseCurrency',
                    ),
                    validator: (value) {
                      final parsed = parseAmount(value);
                      return parsed == null || parsed <= 0
                          ? 'Bitte einen positiven Kurs eingeben.'
                          : null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: taxRate,
                    readOnly: true,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    onChanged: (_) => setDialogState(() {}),
                    decoration: const InputDecoration(
                      labelText: 'Quellensteuer',
                      suffixText: '%',
                      helperText:
                          'Wird über das Land in der Administration festgelegt.',
                    ),
                    validator: (value) {
                      final parsed = parseAmount(value);
                      return parsed == null || parsed < 0 || parsed > 100
                          ? 'Wert zwischen 0 und 100 eingeben.'
                          : null;
                    },
                  ),
                  const SizedBox(height: 12),
                  Builder(
                    builder: (context) {
                      final gross = parseAmount(amount.text) ?? 0;
                      final rate = parseAmount(exchangeRate.text) ?? 0;
                      final tax = parseAmount(taxRate.text) ?? 0;
                      final sourceCurrency = currency.text.trim().toUpperCase();
                      // Without allowance: shows every tax that can apply.
                      final result = calculateInvestmentDividendTax(
                        investment,
                        grossAmount: gross * investment.quantity,
                        exchangeRate: sourceCurrency == baseCurrency ? 1 : rate,
                        withholdingTaxRate: tax,
                        allowanceRemaining: 0,
                      );
                      return DecoratedBox(
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                'Brutto bis Netto für '
                                '${investment.quantity.toStringAsFixed(6).replaceFirst(RegExp(r'\.?0+$'), '')} Stück',
                                style: Theme.of(context).textTheme.titleSmall,
                              ),
                              Text(
                                'Ohne Freistellungsauftrag gerechnet',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              const SizedBox(height: 6),
                              DividendTaxBreakdown(
                                tax: result,
                                sourceCurrency: sourceCurrency,
                                accountCurrency: baseCurrency,
                                exchangeRate: rate,
                                withholdingTaxRate:
                                    isFundAssetType(investment.assetType)
                                    ? 0
                                    : tax,
                                country: investment.country,
                                dense: true,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
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
            onPressed: () {
              if (months.isNotEmpty &&
                  (key.currentState?.validate() ?? false)) {
                Navigator.pop(dialogContext, true);
              }
            },
            child: const Text('Speichern'),
          ),
        ],
      ),
    ),
  );
  if (result == true) {
    final userId = ref.read(currentUserIdProvider);
    if (userId != null) {
      final now = DateTime.now().toUtc();
      final database = ref.read(databaseProvider);
      for (final month in months) {
        final old = schedule;
        await database.saveDividendSchedule(
          DividendSchedulesCompanion.insert(
            id: old?.id ?? const Uuid().v4(),
            userId: userId,
            investmentId: investment.id,
            paymentMonth: month,
            amountPerShare: parseAmount(amount.text)!,
            exDate: Value(months.length == 1 ? exDate : old?.exDate),
            paymentDate: Value(
              months.length == 1 ? paymentDate : old?.paymentDate,
            ),
            paymentYear: Value(
              (paymentDate ?? exDate)?.year ?? DateTime.now().year,
            ),
            currency: Value(currency.text.trim().toUpperCase()),
            exchangeRate: Value(parseAmount(exchangeRate.text)!),
            withholdingTaxRate: Value(parseAmount(taxRate.text)!),
            createdAt: old?.createdAt ?? now,
            updatedAt: now,
          ),
        );
      }
    }
  }
  disposeAfterClose(amount);
  disposeAfterClose(currency);
  disposeAfterClose(exchangeRate);
  disposeAfterClose(taxRate);
}

Future<void> _deleteSchedule(
  BuildContext context,
  WidgetRef ref,
  DividendSchedule schedule,
) async {
  if (!await confirmDelete(
    context,
    title: 'Auszahlung löschen?',
    message: 'Der Eintrag wird aus dem Dividendenkalender entfernt.',
  )) {
    return;
  }
  final userId = ref.read(currentUserIdProvider);
  if (userId != null) {
    await ref
        .read(databaseProvider)
        .deleteDividendSchedule(schedule.id, userId);
  }
}

/// Year total after taxes with the monthly bars on top of the page.
