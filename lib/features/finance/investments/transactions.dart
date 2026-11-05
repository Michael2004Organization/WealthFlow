part of '../investments_page.dart';

Future<void> _showInvestmentSaleDialog(
  BuildContext context,
  WidgetRef ref,
  Investment investment,
) async {
  final quantity = TextEditingController(text: investment.quantity.toString());
  final price = TextEditingController(text: investment.currentPrice.toString());
  final fee = TextEditingController(
    text: (ref.read(preferencesProvider).valueOrNull?.defaultInvestmentFee ?? 0)
        .toString(),
  );
  final key = GlobalKey<FormState>();
  var date = DateTime.now();
  final saved = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: Text('${investment.name} verkaufen'),
        content: SizedBox(
          width: 460,
          child: Form(
            key: key,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: quantity,
                  decoration: InputDecoration(
                    labelText: 'Stückzahl',
                    helperText:
                        'Verfügbar: ${quantityText(investment.quantity)} Stück',
                    suffixIcon: TextButton(
                      onPressed: () =>
                          quantity.text = investment.quantity.toString(),
                      child: const Text('Alles'),
                    ),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  validator: (value) {
                    final parsed = _parseNumber(value);
                    if (parsed == null || parsed <= 0) return 'Ungültige Menge';
                    if (parsed > investment.quantity) {
                      return 'Mehr als verfügbar';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: price,
                  decoration: const InputDecoration(
                    labelText: 'Verkaufskurs je Stück',
                    suffixText: '€',
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  validator: _positiveNumberValidator,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: fee,
                  decoration: const InputDecoration(
                    labelText: 'Gebühren',
                    suffixText: '€',
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  validator: _positiveNumberValidator,
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () async {
                    final selected = await showDatePicker(
                      context: context,
                      firstDate: investment.purchaseDate,
                      lastDate: DateTime.now(),
                      initialDate: date,
                    );
                    if (selected != null) setState(() => date = selected);
                  },
                  icon: const Icon(Icons.calendar_month_rounded),
                  label: Text(DateFormat('dd.MM.yyyy').format(date)),
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
              if (key.currentState?.validate() ?? false) {
                Navigator.pop(dialogContext, true);
              }
            },
            child: const Text('Verkauf buchen'),
          ),
        ],
      ),
    ),
  );
  if (saved == true && context.mounted) {
    await saveWithFeedback(context, () async {
      final userId = ref.read(currentUserIdProvider);
      if (userId != null) {
        await ref
            .read(databaseProvider)
            .sellInvestment(
              userId: userId,
              investmentId: investment.id,
              quantity: _parseNumber(quantity.text)!,
              pricePerUnit: _parseNumber(price.text)!,
              fees: _parseNumber(fee.text)!,
              soldAt: date,
            );
      }
    }, source: 'Verkauf speichern');
  }
  quantity.dispose();
  price.dispose();
  fee.dispose();
}

Future<void> _showPurchaseEditor(
  BuildContext context,
  WidgetRef ref,
  InvestmentPurchase purchase,
) async {
  final investment =
      (ref.read(allInvestmentsProvider).valueOrNull ?? const <Investment>[])
          .where((item) => item.id == purchase.investmentId)
          .firstOrNull;
  final quantity = TextEditingController(text: purchase.quantity.toString());
  final price = TextEditingController(text: purchase.purchasePrice.toString());
  final fee = TextEditingController(text: purchase.fees.toString());
  final dividend = TextEditingController(
    text: investment?.annualDividend.toString() ?? '0',
  );
  final instrumentCurrency = investment == null
      ? moneyCurrency
      : _instrumentCurrency(investment);
  final accountCurrency = investment == null
      ? moneyCurrency
      : _accountCurrencyOf(ref, investment);
  final foreign = instrumentCurrency.toUpperCase() != accountCurrency;
  final rate = TextEditingController(text: purchase.exchangeRate.toString());
  final key = GlobalKey<FormState>();
  var date = purchase.purchaseDate;
  final saved = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: const Text('Kauf bearbeiten'),
        content: Form(
          key: key,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: quantity,
                decoration: const InputDecoration(labelText: 'Stückzahl'),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (value) => (_parseNumber(value) ?? 0) <= 0
                    ? 'Muss größer als 0 sein'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: price,
                decoration: InputDecoration(
                  labelText: 'Kaufkurs',
                  suffixText: instrumentCurrency,
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: _positiveNumberValidator,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: fee,
                decoration: InputDecoration(
                  labelText: 'Gebühren',
                  suffixText: instrumentCurrency,
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: _positiveNumberValidator,
              ),
              if (foreign) ...[
                const SizedBox(height: 12),
                TextFormField(
                  controller: rate,
                  decoration: InputDecoration(
                    labelText: 'Wechselkurs am Kauftag',
                    prefixText: '1 $instrumentCurrency = ',
                    suffixText: accountCurrency,
                    helperText: purchase.exchangeRate == 1
                        ? 'Noch nicht erfasst. Den Kurs findest du in der Kaufabrechnung.'
                        : null,
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  validator: (value) => (_parseNumber(value) ?? 0) <= 0
                      ? 'Muss größer als 0 sein'
                      : null,
                ),
              ],
              const SizedBox(height: 12),
              TextFormField(
                controller: dividend,
                decoration: InputDecoration(
                  labelText: 'Dividende je Stück/Ausschüttung',
                  suffixText: investment?.dividendCurrency ?? 'EUR',
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: _positiveNumberValidator,
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () async {
                  final selected = await showDatePicker(
                    context: context,
                    firstDate: DateTime(1950),
                    lastDate: DateTime.now(),
                    initialDate: date,
                  );
                  if (selected != null) setState(() => date = selected);
                },
                icon: const Icon(Icons.calendar_month_rounded),
                label: Text(DateFormat('dd.MM.yyyy').format(date)),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Abbrechen'),
          ),
          FilledButton(
            onPressed: () {
              if (key.currentState?.validate() ?? false) {
                Navigator.pop(dialogContext, true);
              }
            },
            child: const Text('Speichern'),
          ),
        ],
      ),
    ),
  );
  if (saved == true && context.mounted) {
    await saveWithFeedback(context, () async {
      final userId = ref.read(currentUserIdProvider);
      if (userId != null) {
        await ref
            .read(databaseProvider)
            .updateInvestmentPurchase(
              userId: userId,
              purchaseId: purchase.id,
              purchaseDate: date,
              purchasePrice: _parseNumber(price.text)!,
              quantity: _parseNumber(quantity.text)!,
              fees: _parseNumber(fee.text)!,
              exchangeRate: foreign ? _parseNumber(rate.text) : null,
            );
        if (investment != null) {
          await ref
              .read(databaseProvider)
              .updateInvestmentDividend(
                id: investment.id,
                userId: userId,
                dividendPerShare: _parseNumber(dividend.text)!,
              );
        }
      }
      if (context.mounted) Navigator.pop(context);
    }, source: 'Kauf bearbeiten');
  }
  quantity.dispose();
  price.dispose();
  fee.dispose();
  dividend.dispose();
  rate.dispose();
}

Future<void> _showPortfolioActivity(
  BuildContext context, {
  required WidgetRef ref,
  required List<PortfolioSale> sales,
  required List<PortfolioAuditLog> auditLogs,
}) async {
  final userId = ref.read(currentUserIdProvider);
  final database = ref.read(databaseProvider);
  final deletedInvestments = userId == null
      ? const <Investment>[]
      : await database.deletedInvestmentsFor(userId);
  final deletedPhysicalAssets = userId == null
      ? const <PhysicalAsset>[]
      : await database.deletedPhysicalAssetsFor(userId);
  if (!context.mounted) return;
  await showDialog<void>(
    context: context,
    builder: (dialogContext) => DefaultTabController(
      length: 3,
      child: AlertDialog(
        insetPadding: const EdgeInsets.all(16),
        title: const Text('Portfolio-Aktivitäten'),
        content: SizedBox(
          width: (MediaQuery.sizeOf(context).width - 64).clamp(300, 760),
          height: (MediaQuery.sizeOf(context).height - 220).clamp(320, 620),
          child: Column(
            children: [
              const TabBar(
                tabs: [
                  Tab(text: 'Verkäufe'),
                  Tab(text: 'Papierkorb'),
                  Tab(text: 'Protokoll'),
                ],
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    sales.isEmpty
                        ? const Center(child: Text('Noch keine Verkäufe.'))
                        : ListView.separated(
                            itemCount: sales.length,
                            separatorBuilder: (_, _) =>
                                const Divider(height: 1),
                            itemBuilder: (_, index) {
                              final sale = sales[index];
                              final positive = sale.realizedGain >= 0;
                              return ListTile(
                                onTap: () => _showSaleDetail(
                                  context,
                                  sale: sale,
                                  baseCurrency:
                                      ref
                                          .read(preferencesProvider)
                                          .valueOrNull
                                          ?.currency ??
                                      'EUR',
                                ),
                                leading: CircleAvatar(
                                  child: Icon(
                                    sale.assetKind == 'physical'
                                        ? Icons.diamond_outlined
                                        : Icons.trending_down_rounded,
                                  ),
                                ),
                                title: Text(sale.assetName),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${DateFormat('dd.MM.yyyy').format(sale.soldAt)} · '
                                      '${quantityText(sale.quantity)} ${sale.unit}',
                                    ),
                                    Text(
                                      '${positive ? 'Gewinn' : 'Verlust'} '
                                      '${positive ? '+' : ''}${money(sale.realizedGain)}'
                                      '${sale.taxPaid > 0 ? ' · Steuer ${money(sale.taxPaid)}' : ''}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            color: positive
                                                ? WealthColors.of(
                                                    context,
                                                  ).income
                                                : WealthColors.of(
                                                    context,
                                                  ).expense,
                                            fontWeight: FontWeight.w800,
                                          ),
                                    ),
                                  ],
                                ),
                                trailing: Text(
                                  money(sale.proceeds),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              );
                            },
                          ),
                    deletedInvestments.isEmpty && deletedPhysicalAssets.isEmpty
                        ? const Center(child: Text('Der Papierkorb ist leer.'))
                        : ListView(
                            children: [
                              for (final item in deletedInvestments)
                                ListTile(
                                  leading: const CircleAvatar(
                                    child: Icon(Icons.show_chart_rounded),
                                  ),
                                  title: Text(item.name),
                                  subtitle: const Text('Gelöschtes Wertpapier'),
                                  trailing: FilledButton.tonalIcon(
                                    onPressed: () async {
                                      final userId = ref.read(
                                        currentUserIdProvider,
                                      );
                                      if (userId != null) {
                                        await ref
                                            .read(databaseProvider)
                                            .restoreInvestment(item.id, userId);
                                      }
                                      if (dialogContext.mounted) {
                                        Navigator.pop(dialogContext);
                                      }
                                    },
                                    icon: const Icon(Icons.restore_rounded),
                                    label: const Text('Wiederherstellen'),
                                  ),
                                ),
                              for (final asset in deletedPhysicalAssets)
                                ListTile(
                                  leading: const CircleAvatar(
                                    child: Icon(Icons.diamond_outlined),
                                  ),
                                  title: Text(asset.name),
                                  subtitle: const Text(
                                    'Gelöschter Wertgegenstand',
                                  ),
                                  trailing: FilledButton.tonalIcon(
                                    onPressed: () async {
                                      final userId = ref.read(
                                        currentUserIdProvider,
                                      );
                                      if (userId != null) {
                                        await ref
                                            .read(databaseProvider)
                                            .restorePhysicalAsset(
                                              asset.id,
                                              userId,
                                            );
                                      }
                                      if (dialogContext.mounted) {
                                        Navigator.pop(dialogContext);
                                      }
                                    },
                                    icon: const Icon(Icons.restore_rounded),
                                    label: const Text('Wiederherstellen'),
                                  ),
                                ),
                            ],
                          ),
                    auditLogs.isEmpty
                        ? const Center(child: Text('Noch keine Löschvorgänge.'))
                        : ListView.separated(
                            itemCount: auditLogs.length,
                            separatorBuilder: (_, _) =>
                                const Divider(height: 1),
                            itemBuilder: (_, index) {
                              final log = auditLogs[index];
                              return ListTile(
                                leading: const CircleAvatar(
                                  child: Icon(Icons.delete_outline_rounded),
                                ),
                                title: Text(log.displayName),
                                subtitle: Text(
                                  '${DateFormat('dd.MM.yyyy · HH:mm').format(log.occurredAt.toLocal())}'
                                  '${log.details.isEmpty ? '' : ' · ${log.details}'}',
                                ),
                              );
                            },
                          ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Schließen'),
          ),
        ],
      ),
    ),
  );
}

Future<void> _showSaleDetail(
  BuildContext context, {
  required PortfolioSale sale,
  required String baseCurrency,
}) {
  final gross = sale.quantity * sale.pricePerUnit;
  final capitalTax = sale.taxPaid / 1.055;
  final solidarity = sale.taxPaid - capitalTax;
  return showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Verkaufsdetails'),
      content: SizedBox(
        width: 620,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    child: Icon(
                      sale.assetKind == 'physical'
                          ? Icons.diamond_outlined
                          : Icons.show_chart_rounded,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          sale.assetName,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        Text(
                          '${DateFormat('dd.MM.yyyy').format(sale.soldAt)} · '
                          '${quantityText(sale.quantity)} ${sale.unit} zu '
                          '${money(sale.pricePerUnit, currency: sale.sourceCurrency)}',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _SaleHighlight(
                        label: 'Netto-Auszahlung',
                        value: money(sale.proceeds, currency: baseCurrency),
                      ),
                    ),
                    const SizedBox(
                      height: 44,
                      child: VerticalDivider(width: 24),
                    ),
                    Expanded(
                      child: _SaleHighlight(
                        label: sale.realizedGain >= 0 ? 'Gewinn' : 'Verlust',
                        value:
                            '${sale.realizedGain >= 0 ? '+' : ''}${money(sale.realizedGain, currency: baseCurrency)}',
                        color: sale.realizedGain >= 0
                            ? WealthColors.of(context).income
                            : WealthColors.of(context).expense,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Brutto bis Netto',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 6),
              _SaleTaxRow(
                label: 'Brutto-Verkaufserlös',
                value: gross,
                sale: sale,
                baseCurrency: baseCurrency,
                emphasized: true,
              ),
              _SaleTaxRow(
                label: 'Gebühren',
                value: -sale.fees,
                sale: sale,
                baseCurrency: baseCurrency,
              ),
              _SaleTaxRow(
                label: 'Anschaffungskosten',
                value: -sale.costBasis,
                sale: sale,
                baseCurrency: baseCurrency,
              ),
              _SaleTaxRow(
                label: 'Realisierter Gewinn/Verlust',
                value: sale.realizedGain,
                sale: sale,
                baseCurrency: baseCurrency,
                emphasized: true,
              ),
              const Divider(height: 18),
              _SaleTaxRow(
                label: 'Genutzter Freistellungsauftrag',
                value: sale.allowanceUsed,
                sale: sale,
                baseCurrency: baseCurrency,
                informational: true,
              ),
              _SaleTaxRow(
                label: 'Kapitalertragsteuer',
                value: -capitalTax,
                sale: sale,
                baseCurrency: baseCurrency,
              ),
              _SaleTaxRow(
                label: 'Solidaritätszuschlag',
                value: -solidarity,
                sale: sale,
                baseCurrency: baseCurrency,
              ),
              const Divider(height: 18),
              _SaleTaxRow(
                label: 'Netto-Auszahlung',
                value: sale.proceeds,
                sale: sale,
                baseCurrency: baseCurrency,
                emphasized: true,
              ),
              const SizedBox(height: 12),
              if (sale.sourceCurrency != baseCurrency || sale.exchangeRate != 1)
                Text(
                  '${sale.sourceCurrency} → $baseCurrency · Kurs ${sale.exchangeRate.toStringAsFixed(6)}',
                  textAlign: TextAlign.right,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  sale.accountCredited
                      ? Icons.account_balance_rounded
                      : Icons.receipt_long_outlined,
                ),
                title: Text(
                  sale.accountCredited
                      ? 'Auszahlung auf Konto gebucht'
                      : 'Nur im Verkaufsprotokoll erfasst',
                ),
                subtitle: sale.destinationAccountId == null
                    ? null
                    : Text('Zielkonto: ${sale.destinationAccountId}'),
              ),
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

class _SaleHighlight extends StatelessWidget {
  const _SaleHighlight({required this.label, required this.value, this.color});

  final String label;
  final String value;
  final Color? color;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: Theme.of(context).textTheme.labelMedium),
      Text(
        value,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w800,
          color: color,
        ),
      ),
    ],
  );
}

class _SaleTaxRow extends StatelessWidget {
  const _SaleTaxRow({
    required this.label,
    required this.value,
    required this.sale,
    required this.baseCurrency,
    this.emphasized = false,
    this.informational = false,
  });

  final String label;
  final double value;
  final PortfolioSale sale;
  final String baseCurrency;
  final bool emphasized;
  final bool informational;

  @override
  Widget build(BuildContext context) {
    final rate = sale.exchangeRate <= 0 ? 1.0 : sale.exchangeRate;
    final showSource = sale.sourceCurrency != baseCurrency || rate != 1;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          if (showSource)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Text(
                money(value / rate, currency: sale.sourceCurrency),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          Text(
            money(value, currency: baseCurrency),
            style: TextStyle(
              fontWeight: emphasized ? FontWeight.w800 : FontWeight.w600,
              color: informational
                  ? Theme.of(context).colorScheme.primary
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}

double? _parseNumber(String? value) => parseAmount(value);

String? _positiveNumberValidator(String? value) {
  final parsed = _parseNumber(value);
  return parsed == null || parsed < 0 ? 'Ungültiger Wert' : null;
}
