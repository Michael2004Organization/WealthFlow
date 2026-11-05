part of '../investments_page.dart';

class _PhysicalAssetTile extends ConsumerWidget {
  const _PhysicalAssetTile({required this.asset});

  final PhysicalAsset asset;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentValue = asset.weightGrams * asset.currentPricePerGram;
    final gain = currentValue - asset.purchasePrice;
    final positive = gain >= 0;
    return Card(
      child: ListTile(
        leading: const CircleAvatar(child: Icon(Icons.diamond_outlined)),
        title: Text(asset.name),
        subtitle: Text(
          [
            asset.category,
            if (asset.metalType.isNotEmpty) asset.metalType,
            '${asset.quantity.toStringAsFixed(2)} Einheiten',
            if (asset.weightGrams > 0)
              '${asset.weightGrams.toStringAsFixed(2)} g',
            '${money(asset.currentPricePerGram)}/g',
            if (asset.purchaseDate != null)
              'Kauf ${DateFormat('dd.MM.yyyy').format(asset.purchaseDate!)}',
            money(asset.purchasePrice),
          ].join(' · '),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  money(currentValue),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  '${positive ? '+' : ''}${money(gain)}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: positive
                        ? WealthColors.of(context).income
                        : WealthColors.of(context).expense,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            PopupMenuButton<String>(
              onSelected: (value) async {
                if (value == 'edit') {
                  await _showPhysicalAssetEditor(
                    context,
                    ref,
                    accountId: asset.accountId,
                    asset: asset,
                  );
                } else if (value == 'sell') {
                  await _showPhysicalSaleDialog(context, ref, asset);
                } else if (value == 'delete' &&
                    await confirmDelete(
                      context,
                      title: 'Wertgegenstand löschen?',
                      message: '${asset.name} wird aus dem Portfolio entfernt.',
                    )) {
                  final userId = ref.read(currentUserIdProvider);
                  if (userId != null) {
                    await ref
                        .read(databaseProvider)
                        .deletePhysicalAsset(asset.id, userId);
                  }
                }
              },
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'edit', child: Text('Bearbeiten')),
                PopupMenuItem(value: 'sell', child: Text('Verkaufen')),
                PopupMenuItem(value: 'delete', child: Text('Löschen')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> _showPhysicalAssetEditor(
  BuildContext context,
  WidgetRef ref, {
  required String accountId,
  PhysicalAsset? asset,
}) async {
  final name = TextEditingController(text: asset?.name);
  final quantity = TextEditingController(
    text: asset?.quantity.toString() ?? '1',
  );
  final weightGrams = TextEditingController(
    text: asset?.weightGrams.toString() ?? '0',
  );
  final purchasePrice = TextEditingController(
    text: asset?.purchasePrice.toString() ?? '0',
  );
  final currentPricePerGram = TextEditingController(
    text: asset?.currentPricePerGram.toString() ?? '0',
  );
  final notes = TextEditingController(text: asset?.notes);
  var category = asset?.category ?? 'Edelmetall';
  var metalType = asset?.metalType ?? 'Gold';
  DateTime? purchaseDate = asset?.purchaseDate ?? DateTime.now();
  final key = GlobalKey<FormState>();
  final saved = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (context, setDialogState) => AlertDialog(
        title: Text(
          asset == null
              ? 'Wertgegenstand hinzufügen'
              : 'Wertgegenstand bearbeiten',
        ),
        content: SizedBox(
          width: (MediaQuery.sizeOf(context).width - 64).clamp(280, 520),
          child: Form(
            key: key,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  TextFormField(
                    controller: name,
                    decoration: const InputDecoration(labelText: 'Bezeichnung'),
                    validator: (value) =>
                        (value?.trim().isEmpty ?? true) ? 'Pflichtfeld' : null,
                  ),
                  const SizedBox(height: 12),
                  SearchableDropdownButtonFormField<String>(
                    initialValue: category,
                    decoration: const InputDecoration(labelText: 'Kategorie'),
                    items:
                        const [
                              'Edelmetall',
                              'Schmuck',
                              'Kunst',
                              'Sammlerstück',
                              'Sonstiges',
                            ]
                            .map(
                              (value) => DropdownMenuItem(
                                value: value,
                                child: Text(value),
                              ),
                            )
                            .toList(),
                    onChanged: (value) =>
                        setDialogState(() => category = value ?? category),
                  ),
                  if (category == 'Edelmetall') ...[
                    const SizedBox(height: 12),
                    SearchableDropdownButtonFormField<String>(
                      initialValue: metalType,
                      decoration: const InputDecoration(
                        labelText: 'Edelmetall',
                      ),
                      items: const ['Gold', 'Silber', 'Platin']
                          .map(
                            (value) => DropdownMenuItem(
                              value: value,
                              child: Text(value),
                            ),
                          )
                          .toList(),
                      onChanged: (value) =>
                          setDialogState(() => metalType = value ?? metalType),
                    ),
                  ],
                  const SizedBox(height: 12),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final fieldWidth = constraints.maxWidth < 460
                          ? constraints.maxWidth
                          : (constraints.maxWidth - 12) / 2;
                      return Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          for (final field in [
                            (quantity, 'Menge', ''),
                            (weightGrams, 'Gewicht', 'g'),
                            (purchasePrice, 'Kaufpreis gesamt', '€'),
                            (
                              currentPricePerGram,
                              'Aktueller Kurs pro Gramm',
                              '€/g',
                            ),
                          ])
                            SizedBox(
                              width: fieldWidth,
                              child: TextFormField(
                                controller: field.$1,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                decoration: InputDecoration(
                                  labelText: field.$2,
                                  suffixText: field.$3,
                                ),
                                validator: (value) {
                                  final parsed = parseAmount(value);
                                  return parsed == null || parsed < 0
                                      ? 'Ungültiger Wert'
                                      : null;
                                },
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final selected = await showDatePicker(
                          context: context,
                          firstDate: DateTime(1900),
                          lastDate: DateTime.now(),
                          initialDate: purchaseDate ?? DateTime.now(),
                        );
                        if (selected != null) {
                          setDialogState(() => purchaseDate = selected);
                        }
                      },
                      icon: const Icon(Icons.calendar_month_rounded),
                      label: Text(
                        purchaseDate == null
                            ? 'Kaufdatum angeben'
                            : 'Kaufdatum: ${DateFormat('dd.MM.yyyy').format(purchaseDate!)}',
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: notes,
                    decoration: const InputDecoration(labelText: 'Notizen'),
                    maxLines: 2,
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
        final now = DateTime.now().toUtc();
        double number(TextEditingController value) => parseAmount(value.text)!;
        await ref
            .read(databaseProvider)
            .savePhysicalAsset(
              PhysicalAssetsCompanion.insert(
                id: asset?.id ?? const Uuid().v4(),
                userId: userId,
                accountId: Value(accountId),
                name: name.text.trim(),
                category: Value(category),
                metalType: Value(category == 'Edelmetall' ? metalType : ''),
                quantity: Value(number(quantity)),
                weightGrams: Value(number(weightGrams)),
                purchaseDate: Value(purchaseDate),
                purchasePrice: Value(number(purchasePrice)),
                currentValue: Value(
                  number(weightGrams) * number(currentPricePerGram),
                ),
                currentPricePerGram: Value(number(currentPricePerGram)),
                notes: Value(notes.text.trim()),
                createdAt: asset?.createdAt ?? now,
                updatedAt: now,
              ),
            );
      }
    }, source: 'Sachwert speichern');
  }
  for (final controller in [
    name,
    quantity,
    weightGrams,
    purchasePrice,
    currentPricePerGram,
    notes,
  ]) {
    controller.dispose();
  }
}

Future<void> _showPhysicalSaleDialog(
  BuildContext context,
  WidgetRef ref,
  PhysicalAsset asset,
) async {
  final accounts = ref.read(accountsProvider).valueOrNull ?? const <Account>[];
  const historyOnly = '__history_only__';
  var destinationAccountId = accounts.any((item) => item.id == asset.accountId)
      ? asset.accountId
      : historyOnly;
  final grams = TextEditingController(text: asset.weightGrams.toString());
  final price = TextEditingController(
    text: asset.currentPricePerGram.toString(),
  );
  final fee = TextEditingController(text: '0');
  final key = GlobalKey<FormState>();
  var date = DateTime.now();
  final saved = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: Text('${asset.name} verkaufen'),
        content: SizedBox(
          width: 460,
          child: Form(
            key: key,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: grams,
                  decoration: InputDecoration(
                    labelText: 'Gewicht',
                    suffixText: 'g',
                    helperText:
                        'Verfügbar: ${asset.weightGrams.toStringAsFixed(2)} g',
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  validator: (value) {
                    final parsed = _parseNumber(value);
                    if (parsed == null || parsed <= 0) {
                      return 'Ungültiges Gewicht';
                    }
                    if (parsed > asset.weightGrams) return 'Mehr als verfügbar';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: price,
                  decoration: const InputDecoration(
                    labelText: 'Verkaufskurs pro Gramm',
                    suffixText: '€/g',
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
                SearchableDropdownButtonFormField<String>(
                  initialValue: destinationAccountId,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Verkaufserlös',
                    prefixIcon: Icon(Icons.account_balance_rounded),
                  ),
                  items: [
                    const DropdownMenuItem(
                      value: historyOnly,
                      child: Text('Nicht buchen – nur Historie'),
                    ),
                    ...accounts.map(
                      (account) => DropdownMenuItem(
                        value: account.id,
                        child: Text(
                          '${account.label} · ${account.bankName}',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                  onChanged: (value) =>
                      destinationAccountId = value ?? historyOnly,
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () async {
                    final selected = await showDatePicker(
                      context: context,
                      firstDate: asset.purchaseDate ?? DateTime(1900),
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
            .sellPhysicalAsset(
              userId: userId,
              assetId: asset.id,
              grams: _parseNumber(grams.text)!,
              pricePerGram: _parseNumber(price.text)!,
              fees: _parseNumber(fee.text)!,
              soldAt: date,
              destinationAccountId: destinationAccountId == historyOnly
                  ? null
                  : destinationAccountId,
            );
      }
    }, source: 'Sachwert-Verkauf speichern');
  }
  grams.dispose();
  price.dispose();
  fee.dispose();
}
