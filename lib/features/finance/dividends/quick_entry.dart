part of '../dividends_page.dart';

Future<void> _showQuickEntry(
  BuildContext context,
  WidgetRef ref, {
  required Investment investment,
  required List<DividendSchedule> schedules,
  required String baseCurrency,
  required int year,
}) => showDialog<void>(
  context: context,
  builder: (_) => Dialog(
    insetPadding: const EdgeInsets.all(16),
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 920, maxHeight: 760),
      child: _DividendQuickEntry(
        investment: investment,
        schedules: schedules,
        baseCurrency: baseCurrency,
        year: year,
      ),
    ),
  ),
);

class _DividendQuickEntry extends ConsumerStatefulWidget {
  const _DividendQuickEntry({
    required this.investment,
    required this.schedules,
    required this.baseCurrency,
    required this.year,
  });

  final Investment investment;
  final List<DividendSchedule> schedules;
  final String baseCurrency;
  final int year;

  @override
  ConsumerState<_DividendQuickEntry> createState() =>
      _DividendQuickEntryState();
}

class _DividendQuickEntryState extends ConsumerState<_DividendQuickEntry> {
  late final Set<int> _editableMonths = {
    ...dividendPaymentMonths(
      widget.investment.dividendFrequency,
      widget.investment.dividendStartMonth,
    ),
    ...widget.schedules.map((row) => row.paymentMonth),
  };
  late final List<TextEditingController> _amounts = List.generate(12, (index) {
    final month = index + 1;
    final row = _rowFor(month);
    return TextEditingController(
      text:
          row?.amountPerShare.toString() ??
          (widget.investment.annualDividend > 0
              ? widget.investment.annualDividend.toString()
              : ''),
    );
  });
  late final List<DateTime?> _exDates = List.generate(
    12,
    (index) => _rowFor(index + 1)?.exDate,
  );
  late final List<DateTime?> _paymentDates = List.generate(
    12,
    (index) => _rowFor(index + 1)?.paymentDate,
  );
  late final _currency = TextEditingController(
    text:
        widget.schedules.firstOrNull?.currency ??
        widget.investment.dividendCurrency,
  );
  late final _exchangeRate = TextEditingController(
    text: rateText(
      ref
          .read(currencyConverterProvider)
          .dividendRate(
            widget.schedules.firstOrNull?.exchangeRate ??
                widget.investment.dividendExchangeRate,
            widget.schedules.firstOrNull?.currency ??
                widget.investment.dividendCurrency,
            ref.read(currencyConverterProvider).baseCurrency,
          ),
    ),
  );
  late final _taxRate = TextEditingController(
    text:
        (widget.schedules.firstOrNull?.withholdingTaxRate ??
                widget.investment.dividendWithholdingTaxRate)
            .toString(),
  );
  bool _saving = false;

  DividendSchedule? _rowFor(int month) =>
      widget.schedules.where((row) => row.paymentMonth == month).firstOrNull;

  @override
  void dispose() {
    for (final controller in _amounts) {
      controller.dispose();
    }
    _currency.dispose();
    _exchangeRate.dispose();
    _taxRate.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 8, 8),
        child: Row(
          children: [
            Expanded(
              child: Text(
                'Schnellerfassung · ${widget.investment.name}',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
            ),
            IconButton(
              tooltip: 'Schließen',
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.close_rounded),
            ),
          ],
        ),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            SizedBox(
              width: 150,
              child: TextField(
                controller: _currency,
                readOnly: true,
                textCapitalization: TextCapitalization.characters,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(labelText: 'Währung'),
              ),
            ),
            SizedBox(
              width: 210,
              child: TextField(
                controller: _exchangeRate,
                readOnly: true,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  labelText: 'Kurs zu ${widget.baseCurrency}',
                  helperText: '1 Fremdwährung = ? ${widget.baseCurrency}',
                ),
              ),
            ),
            SizedBox(
              width: 180,
              child: TextField(
                controller: _taxRate,
                readOnly: true,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Quellensteuer',
                  suffixText: '%',
                  helperText: 'Aus Länder-Stammdaten',
                ),
              ),
            ),
            PopupMenuButton<int>(
              tooltip: 'Einen Monat auf alle übernehmen',
              onSelected: _copyMonthToAll,
              itemBuilder: (_) => [
                for (final month in _editableMonths)
                  PopupMenuItem(
                    value: month,
                    child: Text('${monthNames[month - 1]} auf alle übernehmen'),
                  ),
              ],
              child: const Chip(
                avatar: Icon(Icons.copy_all_rounded, size: 18),
                label: Text('Monat übernehmen'),
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 10),
      const Divider(height: 1),
      Expanded(
        child: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: _editableMonths.length,
          separatorBuilder: (_, _) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final month = _editableMonths.elementAt(index);
            return Card(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final fields = <Widget>[
                      SizedBox(
                        width: 130,
                        child: TextField(
                          controller: _amounts[month - 1],
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: InputDecoration(
                            labelText: monthNames[month - 1],
                            suffixText: _currency.text.toUpperCase(),
                          ),
                        ),
                      ),
                      _quickDateButton(
                        label: 'Ex-Datum',
                        value: _exDates[month - 1],
                        icon: Icons.event_rounded,
                        onChanged: (value) =>
                            setState(() => _exDates[month - 1] = value),
                      ),
                      _quickDateButton(
                        label: 'Zahlung',
                        value: _paymentDates[month - 1],
                        icon: Icons.payments_outlined,
                        onChanged: (value) =>
                            setState(() => _paymentDates[month - 1] = value),
                      ),
                    ];
                    return constraints.maxWidth < 650
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              for (var i = 0; i < fields.length; i++) ...[
                                fields[i],
                                if (i < fields.length - 1)
                                  const SizedBox(height: 8),
                              ],
                            ],
                          )
                        : Row(
                            children: [
                              for (var i = 0; i < fields.length; i++) ...[
                                if (i > 0) const SizedBox(width: 10),
                                if (i == 0)
                                  fields[i]
                                else
                                  Expanded(child: fields[i]),
                              ],
                            ],
                          );
                  },
                ),
              ),
            );
          },
        ),
      ),
      const Divider(height: 1),
      Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: _saving ? null : () => Navigator.pop(context),
              child: const Text('Abbrechen'),
            ),
            const SizedBox(width: 8),
            FilledButton.icon(
              onPressed: _saving ? null : _save,
              icon: _saving
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save_rounded),
              label: const Text('Alle speichern'),
            ),
          ],
        ),
      ),
    ],
  );

  Widget _quickDateButton({
    required String label,
    required DateTime? value,
    required IconData icon,
    required ValueChanged<DateTime?> onChanged,
  }) => OutlinedButton.icon(
    onPressed: () async {
      final selected = await showDatePicker(
        context: context,
        firstDate: DateTime(2000),
        lastDate: DateTime(2100),
        initialDate: value ?? DateTime.now(),
      );
      if (selected != null) onChanged(selected);
    },
    icon: Icon(icon),
    label: Text(
      value == null
          ? '$label wählen'
          : '$label ${DateFormat('dd.MM.yy').format(value)}',
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    ),
  );

  double? _number(String value) => parseAmount(value);

  Future<void> _save() async {
    final userId = ref.read(currentUserIdProvider);
    final rate = _number(_exchangeRate.text);
    final tax = _number(_taxRate.text);
    if (userId == null ||
        _currency.text.trim().isEmpty ||
        rate == null ||
        rate <= 0 ||
        tax == null ||
        tax < 0 ||
        tax > 100) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bitte Umrechnung und Steuer prüfen.')),
      );
      return;
    }
    setState(() => _saving = true);
    final database = ref.read(databaseProvider);
    final now = DateTime.now().toUtc();
    for (final month in _editableMonths) {
      final old = _rowFor(month);
      final amount = _number(_amounts[month - 1].text);
      if (amount == null || amount <= 0) {
        if (old != null) await database.deleteDividendSchedule(old.id, userId);
        continue;
      }
      await database.saveDividendSchedule(
        DividendSchedulesCompanion.insert(
          id: old?.id ?? const Uuid().v4(),
          userId: userId,
          investmentId: widget.investment.id,
          paymentMonth: month,
          amountPerShare: amount,
          exDate: Value(_exDates[month - 1]),
          paymentDate: Value(_paymentDates[month - 1]),
          paymentYear: Value(widget.year),
          currency: Value(_currency.text.trim().toUpperCase()),
          exchangeRate: Value(rate),
          withholdingTaxRate: Value(tax.clamp(0, 100)),
          createdAt: old?.createdAt ?? now,
          updatedAt: now,
        ),
      );
    }
    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Dividendenwerte wurden gespeichert.')),
      );
    }
  }

  void _copyMonthToAll(int sourceMonth) {
    final sourceIndex = sourceMonth - 1;
    setState(() {
      for (final month in _editableMonths) {
        if (month == sourceMonth) continue;
        _amounts[month - 1].text = _amounts[sourceIndex].text;
        final ex = _exDates[sourceIndex];
        final payment = _paymentDates[sourceIndex];
        _exDates[month - 1] = ex == null
            ? null
            : DateTime(widget.year, month, ex.day);
        _paymentDates[month - 1] = payment == null
            ? null
            : DateTime(widget.year, month, payment.day);
      }
    });
  }
}
