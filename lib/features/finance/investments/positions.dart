part of '../investments_page.dart';

/// Currency in which prices of [investment] are entered.
String _accountCurrencyOf(WidgetRef ref, Investment investment) =>
    ((ref.read(accountsProvider).valueOrNull ?? const <Account>[])
                .where((account) => account.id == investment.accountId)
                .firstOrNull
                ?.currency ??
            moneyCurrency)
        .toUpperCase();

/// Purchases in a foreign currency saved before the rate was recorded carry
/// a rate of exactly 1, which books the wrong amount on the account.
bool _missingPurchaseRate(
  WidgetRef ref,
  Investment investment,
  InvestmentPurchase purchase,
) =>
    purchase.exchangeRate == 1 &&
    _instrumentCurrency(investment).toUpperCase() !=
        _accountCurrencyOf(ref, investment);

String _instrumentCurrency(Investment investment) =>
    investment.instrumentCurrency.isEmpty
    ? moneyCurrency
    : investment.instrumentCurrency;

class _InvestmentTile extends ConsumerWidget {
  const _InvestmentTile({required this.item, required this.purchaseCount});
  final Investment item;
  final int purchaseCount;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final converter = ref.watch(currencyConverterProvider);
    final value = converter.investmentValue(item);
    final cost = converter.toBase(
      item.quantity * item.purchasePrice + item.fees,
      _instrumentCurrency(item),
    );
    final gain = value - cost;
    final positive = gain >= 0;
    final purchases =
        ref.watch(investmentPurchasesProvider).valueOrNull ??
        const <InvestmentPurchase>[];
    final percent = cost == 0 ? null : gain / cost * 100;
    final colors = WealthColors.of(context);
    return ListTile(
      contentPadding: const EdgeInsets.fromLTRB(16, 6, 4, 6),
      onTap: () => _showInvestmentDetails(
        context,
        ref,
        item,
        purchases
            .where((purchase) => purchase.investmentId == item.id)
            .toList(),
      ),
      leading: IconTile(
        size: 40,
        label: (item.symbol.isEmpty ? item.name : item.symbol)
            .substring(
              0,
              (item.symbol.isEmpty ? item.name : item.symbol).length.clamp(
                1,
                4,
              ),
            )
            .toUpperCase(),
      ),
      title: Text(
        item.name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        '${quantityText(item.quantity)} Stück · ${item.assetType}',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                money(value),
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              Text(
                percent == null
                    ? signedMoney(gain, income: positive)
                    : '${positive ? '+' : '−'}${percent.abs().toStringAsFixed(1).replaceAll('.', ',')} %',
                style: TextStyle(
                  fontSize: 12,
                  color: colors.amount(income: positive),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'history') {
                await _showInvestmentDetails(
                  context,
                  ref,
                  item,
                  purchases
                      .where((purchase) => purchase.investmentId == item.id)
                      .toList(),
                );
              } else if (value == 'edit') {
                await showInvestmentEditor(context, ref, investment: item);
              } else if (value == 'sell') {
                await _showInvestmentSaleDialog(context, ref, item);
              } else if (value == 'delete' &&
                  await confirmDelete(
                    context,
                    title: 'Position löschen?',
                    message: '${item.name} wird aus deinem Portfolio entfernt.',
                  )) {
                final userId = ref.read(currentUserIdProvider);
                if (userId != null) {
                  await ref
                      .read(databaseProvider)
                      .deleteInvestment(item.id, userId);
                }
              }
            },
            itemBuilder: (_) => [
              const PopupMenuItem(
                value: 'history',
                child: Text('Details & Kaufhistorie'),
              ),
              PopupMenuItem(
                value: 'edit',
                enabled: purchaseCount <= 1,
                child: Text(
                  purchaseCount <= 1
                      ? 'Bearbeiten'
                      : 'Gesamtposition nicht bearbeitbar',
                ),
              ),
              const PopupMenuItem(value: 'sell', child: Text('Verkaufen')),
              const PopupMenuItem(value: 'delete', child: Text('Löschen')),
            ],
          ),
        ],
      ),
    );
  }
}

/// Opens the purchase history of [investment], e.g. from the search.
Future<void> showInvestmentDetails(
  BuildContext context,
  WidgetRef ref,
  Investment investment,
) => _showInvestmentDetails(
  context,
  ref,
  investment,
  (ref.read(investmentPurchasesProvider).valueOrNull ??
          const <InvestmentPurchase>[])
      .where((purchase) => purchase.investmentId == investment.id)
      .toList(),
);

Future<void> _showInvestmentDetails(
  BuildContext context,
  WidgetRef ref,
  Investment investment,
  List<InvestmentPurchase> purchases,
) async {
  await showDialog<void>(
    context: context,
    builder: (context) {
      final sorted = [...purchases]
        ..sort((a, b) => b.purchaseDate.compareTo(a.purchaseDate));
      return AlertDialog(
        insetPadding: const EdgeInsets.all(16),
        title: Row(
          children: [
            Expanded(child: Text(investment.name)),
            IconButton(
              tooltip: sorted.length > 1
                  ? 'Bei mehreren Käufen bitte einzelne Käufe bearbeiten'
                  : 'Position bearbeiten',
              onPressed: sorted.length > 1
                  ? null
                  : () {
                      Navigator.pop(context);
                      showInvestmentEditor(
                        context,
                        ref,
                        investment: investment,
                      );
                    },
              icon: const Icon(Icons.edit_outlined),
            ),
          ],
        ),
        content: SizedBox(
          width: (MediaQuery.sizeOf(context).width - 64).clamp(280, 680),
          height: (MediaQuery.sizeOf(context).height - 240).clamp(280, 600),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  Chip(
                    avatar: const Icon(Icons.inventory_2_outlined, size: 18),
                    label: Text('${quantityText(investment.quantity)} Stück'),
                  ),
                  Chip(
                    avatar: const Icon(Icons.calculate_outlined, size: 18),
                    label: Text(
                      'Ø Kaufkurs ${money(investment.purchasePrice, currency: _instrumentCurrency(investment))}',
                    ),
                  ),
                  Chip(
                    avatar: const Icon(Icons.show_chart_rounded, size: 18),
                    label: Text(
                      'Kurs ${money(investment.currentPrice, currency: _instrumentCurrency(investment))}',
                    ),
                  ),
                  ActionChip(
                    avatar: const Icon(Icons.edit_rounded, size: 18),
                    label: const Text('Aktuellen Kurs bearbeiten'),
                    onPressed: () async {
                      await _editCurrentPrice(context, ref, investment);
                      if (context.mounted) Navigator.pop(context);
                    },
                  ),
                  if (investment.isin.isNotEmpty)
                    Chip(label: Text('ISIN ${investment.isin}')),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Kaufhistorie',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: sorted.isEmpty
                    ? const Center(
                        child: Text(
                          'Für diese ältere Position ist noch kein Kauf hinterlegt.',
                        ),
                      )
                    : ListView.separated(
                        itemCount: sorted.length,
                        separatorBuilder: (_, _) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final purchase = sorted[index];
                          final missingRate = _missingPurchaseRate(
                            ref,
                            investment,
                            purchase,
                          );
                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const CircleAvatar(
                              child: Icon(Icons.add_chart_rounded),
                            ),
                            title: Text(
                              '${quantityText(purchase.quantity)} Stück · ${money(purchase.purchasePrice, currency: _instrumentCurrency(investment))}',
                            ),
                            subtitle: Text.rich(
                              TextSpan(
                                text:
                                    DateFormat(
                                      'dd.MM.yyyy',
                                    ).format(purchase.purchaseDate) +
                                    (purchase.fees == 0
                                        ? ''
                                        : ' · Gebühren ${money(purchase.fees, currency: _instrumentCurrency(investment))}'),
                                children: [
                                  if (missingRate)
                                    TextSpan(
                                      text:
                                          '\nWechselkurs fehlt – bitte im Kauf eintragen',
                                      style: TextStyle(
                                        color: WealthColors.of(context).expense,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  money(
                                    purchase.quantity * purchase.purchasePrice +
                                        purchase.fees,
                                    currency: _instrumentCurrency(investment),
                                  ),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                PopupMenuButton<String>(
                                  onSelected: (value) async {
                                    if (value == 'edit') {
                                      await _showPurchaseEditor(
                                        context,
                                        ref,
                                        purchase,
                                      );
                                    } else if (value == 'delete' &&
                                        await confirmDelete(
                                          context,
                                          title: 'Diesen Kauf löschen?',
                                          message:
                                              'Nur dieser Eintrag wird aus der Kaufhistorie entfernt.',
                                        )) {
                                      final userId = ref.read(
                                        currentUserIdProvider,
                                      );
                                      if (userId != null) {
                                        await ref
                                            .read(databaseProvider)
                                            .deleteInvestmentPurchase(
                                              purchase.id,
                                              userId,
                                            );
                                      }
                                      if (context.mounted) {
                                        Navigator.pop(context);
                                      }
                                    }
                                  },
                                  itemBuilder: (_) => const [
                                    PopupMenuItem(
                                      value: 'edit',
                                      child: Text('Kauf bearbeiten'),
                                    ),
                                    PopupMenuItem(
                                      value: 'delete',
                                      child: Text('Kauf löschen'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Schließen'),
          ),
        ],
      );
    },
  );
}

Future<void> _editCurrentPrice(
  BuildContext context,
  WidgetRef ref,
  Investment investment,
) async {
  final controller = TextEditingController(
    text: investment.currentPrice.toStringAsFixed(2),
  );
  final key = GlobalKey<FormState>();
  final saved = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text('Aktueller Kurs · ${investment.name}'),
      content: Form(
        key: key,
        child: TextFormField(
          controller: controller,
          autofocus: true,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            labelText: 'Kurs für die gesamte Position',
            suffixText: '€',
            helperText: 'Gilt einmalig für alle Käufe dieser Position.',
          ),
          validator: _positiveNumberValidator,
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
          child: const Text('Kurs speichern'),
        ),
      ],
    ),
  );
  if (saved == true && context.mounted) {
    await saveWithFeedback(context, () async {
      final userId = ref.read(currentUserIdProvider);
      if (userId != null) {
        await ref
            .read(databaseProvider)
            .updateInvestmentCurrentPrice(
              id: investment.id,
              userId: userId,
              currentPrice: _parseNumber(controller.text)!,
            );
      }
    }, source: 'Kurs speichern');
  }
  controller.dispose();
}
