part of 'household_page.dart';

/// Opens the booking editor from anywhere in the app, on the household
/// account the user last chose.
Future<void> startNewBooking(BuildContext context, WidgetRef ref) async {
  final accounts = ref.read(accountsProvider).valueOrNull ?? const <Account>[];
  final investments =
      ref.read(allInvestmentsProvider).valueOrNull ?? const <Investment>[];
  final physicalAssets =
      ref.read(physicalAssetsProvider).valueOrNull ?? const <PhysicalAsset>[];
  final preference = ref.read(preferencesProvider).valueOrNull;
  final household = householdAccounts(
    accounts,
    investments: investments,
    physicalAssets: physicalAssets,
  );
  final preferred = household
      .where((account) => account.id == preference?.selectedHouseholdAccountId)
      .firstOrNull;
  final account =
      preferred ??
      household.where((item) => item.usageType == 'household').firstOrNull ??
      household.firstOrNull;
  if (account == null) {
    selectShellDestination(ref, ShellPage.household);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Lege zuerst ein Haushaltskonto unter Vermögen an.'),
      ),
    );
    return;
  }
  await showEntryEditor(context, ref, defaultAccountId: account.id);
}

Future<void> showEntryEditor(
  BuildContext context,
  WidgetRef ref, {
  LedgerEntry? entry,
  DateTime? initialDate,
  String? defaultAccountId,
  bool editSeries = false,
}) async {
  final vehicles = ref.read(vehiclesProvider).valueOrNull ?? const <Vehicle>[];
  final accounts = ref.read(accountsProvider).valueOrNull ?? const <Account>[];
  final masterData =
      ref.read(masterDataProvider).valueOrNull ?? const <MasterDataData>[];
  final ledgerEntries =
      ref.read(ledgerEntriesProvider).valueOrNull ?? const <LedgerEntry>[];
  Future<void> persist(_EntrySubmission result) =>
      _persistSubmission(ref, result, entry: entry, editSeries: editSeries);
  final phone = MediaQuery.sizeOf(context).width < 600;
  Widget editor(BuildContext _) => _EntryEditor(
    entry: entry,
    initialDate: initialDate,
    vehicles: vehicles,
    accounts: accounts,
    defaultAccountId: defaultAccountId,
    masterData: masterData,
    ledgerEntries: ledgerEntries,
    editSeries: editSeries,
    fullscreen: phone,
    onSaveAndNext: entry == null ? persist : null,
  );
  final result = phone
      ? await showModalBottomSheet<_EntrySubmission>(
          context: context,
          isScrollControlled: true,
          useSafeArea: true,
          showDragHandle: false,
          builder: editor,
        )
      : await showDialog<_EntrySubmission>(context: context, builder: editor);
  if (result != null && context.mounted) {
    await saveWithFeedback(
      context,
      () => persist(result),
      failure: 'Buchung nicht gespeichert',
      source: 'Buchung speichern',
    );
  }
}

Future<void> _persistSubmission(
  WidgetRef ref,
  _EntrySubmission result, {
  required LedgerEntry? entry,
  required bool editSeries,
}) async {
  final database = ref.read(databaseProvider);
  final userId = ref.read(currentUserIdProvider);
  if (editSeries && entry != null && userId != null) {
    await database.updateLedgerSeries(
      entry.recurrenceId,
      userId,
      result.entries.first,
      edited: entry,
    );
  } else if (entry != null && result.entries.length == 1) {
    await database.saveLedgerEntryWithCounterpart(result.entries.first);
  } else {
    await database.saveLedgerEntries(result.entries);
  }
  if (userId == null) return;
  if (result.reminderTitle != null && result.reminderAt != null) {
    final reminderId = const Uuid().v4();
    final now = DateTime.now().toUtc();
    await database.saveReminder(
      RemindersCompanion.insert(
        id: reminderId,
        userId: userId,
        title: result.reminderTitle!,
        scheduledAt: result.reminderAt!.toUtc(),
        ledgerEntryId: Value(result.entries.first.id.value),
        createdAt: now,
        updatedAt: now,
      ),
    );
    final notifications = ref.read(notificationServiceProvider);
    await notifications.requestPermissions();
    await notifications.schedule(
      id: reminderId,
      title: result.reminderTitle!,
      scheduledAt: result.reminderAt!,
    );
  }
  for (final item in {
    if (result.merchant.isNotEmpty) 'merchant': result.merchant,
    if (result.paymentMethod.isNotEmpty) 'paymentMethod': result.paymentMethod,
    if (result.category.isNotEmpty) 'category': result.category,
  }.entries) {
    await database.saveMasterDatum(
      MasterDataCompanion.insert(
        id: const Uuid().v4(),
        userId: userId,
        kind: item.key,
        value: item.value,
        createdAt: DateTime.now().toUtc(),
      ),
    );
  }
}

class _EntrySubmission {
  const _EntrySubmission(
    this.entries, {
    required this.merchant,
    required this.paymentMethod,
    required this.category,
    this.reminderTitle,
    this.reminderAt,
  });
  final List<LedgerEntriesCompanion> entries;
  final String merchant;
  final String paymentMethod;
  final String category;
  final String? reminderTitle;
  final DateTime? reminderAt;
}

class _EntryEditor extends StatefulWidget {
  const _EntryEditor({
    required this.vehicles,
    required this.accounts,
    required this.defaultAccountId,
    required this.masterData,
    required this.ledgerEntries,
    required this.editSeries,
    required this.fullscreen,
    this.entry,
    this.initialDate,
    this.onSaveAndNext,
  });

  final LedgerEntry? entry;
  final DateTime? initialDate;
  final List<Vehicle> vehicles;
  final List<Account> accounts;
  final String? defaultAccountId;
  final List<MasterDataData> masterData;
  final List<LedgerEntry> ledgerEntries;
  final bool editSeries;
  final bool fullscreen;

  /// Saves without closing the editor; only offered for new entries.
  final Future<void> Function(_EntrySubmission)? onSaveAndNext;

  @override
  State<_EntryEditor> createState() => _EntryEditorState();
}

class _EntryEditorState extends State<_EntryEditor> {
  final _formKey = GlobalKey<FormState>();
  final _amountFocus = FocusNode();
  late final _amount = TextEditingController(
    text: widget.entry == null ? '' : formatAmountInput(widget.entry!.amount),
  );
  late final _merchant = TextEditingController(text: widget.entry?.merchant);
  late final _description = TextEditingController(
    text: widget.entry?.description,
  );
  late final _payment = TextEditingController(
    text: widget.entry?.paymentMethod,
  );
  late final _category = TextEditingController(
    text: widget.entry?.category ?? '',
  );
  final _reminderTitle = TextEditingController();
  final _months = TextEditingController(text: '12');

  /// One of `expense`, `income`, `transfer` or `saving`.
  late String _kind = switch (widget.entry?.sourceType) {
    'transfer' => 'transfer',
    'saving' => 'saving',
    _ => (widget.entry?.isIncome ?? false) ? 'income' : 'expense',
  };
  late DateTime _date =
      widget.entry?.bookingDate ?? widget.initialDate ?? DateTime.now();
  late String _vehicleId = widget.entry?.vehicleId ?? '';
  late final String _accountId =
      widget.entry?.accountId ?? widget.defaultAccountId ?? '';
  String _targetAccountId = '';
  late int _budgetOffset = _initialBudgetOffset();
  bool _repeatMonthly = false;
  String _timing = 'selected';
  bool _addReminder = false;
  bool _categoryEdited = false;
  bool _saving = false;
  String? _notice;
  DateTime _reminderAt = DateTime.now().add(const Duration(days: 1));

  bool get _isNew => widget.entry == null;

  /// Editing one side of a transfer or saving booking; the other side
  /// follows on save.
  bool get _isLinkedEdit =>
      !_isNew &&
      (widget.entry!.sourceType == 'transfer' ||
          widget.entry!.sourceType == 'saving');
  bool get _income => _kind == 'income';
  String get _bookingKind => switch (_kind) {
    'transfer' => 'transfer',
    'saving' => 'saving',
    _ => 'standard',
  };
  int get _monthCount => int.tryParse(_months.text.trim()) ?? 0;

  @override
  void dispose() {
    _amountFocus.dispose();
    _amount.dispose();
    _merchant.dispose();
    _description.dispose();
    _payment.dispose();
    _category.dispose();
    _reminderTitle.dispose();
    _months.dispose();
    super.dispose();
  }

  String get _title => _isNew
      ? 'Buchung erfassen'
      : widget.editSeries
      ? 'Ganze Serie bearbeiten'
      : 'Buchung bearbeiten';

  String get _accountLine {
    final account = _selectedAccount;
    if (account == null) return 'Kein Haushaltskonto ausgewählt';
    return '${account.label} · ${money(account.balance, currency: account.currency)}';
  }

  @override
  Widget build(BuildContext context) {
    final form = Form(key: _formKey, child: _formFields(context));
    if (widget.fullscreen) {
      final colors = WealthColors.of(context);
      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * .94,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 10),
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    color: colors.border,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
                child: Row(
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Abbrechen',
                        style: TextStyle(color: colors.neutral),
                      ),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            _title,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          Text(
                            _accountLine,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 12, color: colors.muted),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 88),
                  ],
                ),
              ),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                  child: form,
                ),
              ),
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
                  child: Row(
                    children: [
                      if (widget.onSaveAndNext != null) ...[
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _saving ? null : _saveAndNext,
                            child: const Text('Speichern & nächste'),
                          ),
                        ),
                        const SizedBox(width: 12),
                      ],
                      Expanded(
                        child: FilledButton(
                          onPressed: _saving ? null : _save,
                          child: const Text('Speichern'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
    return AlertDialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_title),
          const SizedBox(height: 2),
          Text(_accountLine, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
      content: SizedBox(
        width: (MediaQuery.sizeOf(context).width - 80).clamp(280.0, 560.0),
        child: SingleChildScrollView(child: form),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Abbrechen'),
        ),
        if (widget.onSaveAndNext != null)
          OutlinedButton(
            onPressed: _saving ? null : _saveAndNext,
            child: const Text('Speichern & nächste'),
          ),
        FilledButton(
          onPressed: _saving ? null : _save,
          child: const Text('Speichern'),
        ),
      ],
    );
  }

  Widget _formFields(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      if (_notice != null) ...[
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.secondaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Icon(Icons.check_circle_rounded, size: 18),
              const SizedBox(width: 8),
              Expanded(child: Text(_notice!)),
            ],
          ),
        ),
        const SizedBox(height: 12),
      ],
      _kindSelector(),
      const SizedBox(height: 8),
      _amountField(context),
      if (_bookingKind == 'standard') ...[
        const SizedBox(height: 4),
        _categoryChips(context),
      ],
      const SizedBox(height: 12),
      _DateField(
        label: 'Datum',
        value: DateFormat('dd.MM.yyyy').format(_date),
        onTap: _pickDate,
      ),
      if (_isNew && _bookingKind != 'standard') ...[
        const SizedBox(height: 12),
        SearchableDropdownButtonFormField<String>(
          initialValue: _targetAccountId.isEmpty ? null : _targetAccountId,
          isExpanded: true,
          decoration: InputDecoration(
            labelText: _bookingKind == 'saving'
                ? 'Zielkonto / Investkonto *'
                : 'Zielkonto *',
            prefixIcon: const Icon(Icons.redo_rounded),
          ),
          items: widget.accounts
              .where((account) => account.id != _accountId)
              .map(
                (account) => DropdownMenuItem(
                  value: account.id,
                  child: Text(
                    '${account.label} · ${money(account.balance, currency: account.currency)}',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              )
              .toList(),
          validator: (value) =>
              _bookingKind != 'standard' && (value == null || value.isEmpty)
              ? 'Bitte ein Zielkonto auswählen.'
              : null,
          onChanged: (value) => _targetAccountId = value ?? '',
        ),
      ],
      const SizedBox(height: 12),
      _responsiveFields([
        _EditableSuggestionField(
          controller: _merchant,
          label: 'Händler / Quelle',
          suggestions: _masterEntries('merchant'),
          onChanged: _suggestCategory,
        ),
        _EditableSuggestionField(
          controller: _category,
          label: 'Kategorie',
          suggestions: {
            ..._categories.skip(1),
            ...widget.masterData
                .where((item) => item.kind == 'category')
                .map((item) => item.value),
          }.toList(),
          onChanged: (_) => setState(() => _categoryEdited = true),
        ),
      ]),
      const SizedBox(height: 12),
      TextFormField(
        controller: _description,
        decoration: const InputDecoration(
          labelText: 'Beschreibung',
          prefixIcon: Icon(Icons.notes_rounded),
        ),
        minLines: 1,
        maxLines: 3,
      ),
      const SizedBox(height: 4),
      Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: EdgeInsets.zero,
          childrenPadding: const EdgeInsets.only(bottom: 4),
          initiallyExpanded: _hasExtraOptions,
          title: const Text('Weitere Optionen'),
          children: _extraOptions(context),
        ),
      ),
    ],
  );

  /// The amount as the centre of the editor: large, coloured by direction.
  Widget _amountField(BuildContext context) {
    final colors = WealthColors.of(context);
    final color = switch (_kind) {
      'expense' => colors.expense,
      'income' => colors.income,
      _ => Theme.of(context).colorScheme.onSurface,
    };
    return TextFormField(
      key: const Key('entry-amount'),
      controller: _amount,
      focusNode: _amountFocus,
      autofocus: _isNew,
      textAlign: TextAlign.center,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      textInputAction: TextInputAction.next,
      style: TextStyle(
        fontFamily: AppTheme.displayFont,
        fontSize: 40,
        fontWeight: FontWeight.w800,
        letterSpacing: -.5,
        color: color,
      ),
      decoration: InputDecoration(
        hintText: '0,00',
        hintStyle: TextStyle(
          fontFamily: AppTheme.displayFont,
          fontSize: 40,
          fontWeight: FontWeight.w800,
          color: colors.border,
        ),
        helper: Center(
          child: Text(
            _selectedAccount?.currency ?? 'EUR',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: colors.muted,
            ),
          ),
        ),
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        errorBorder: InputBorder.none,
        focusedErrorBorder: InputBorder.none,
        filled: false,
        errorStyle: const TextStyle(height: 1.2),
        contentPadding: const EdgeInsets.symmetric(vertical: 8),
      ),
      validator: (value) => (parseAmount(value) ?? 0) <= 0
          ? 'Bitte einen positiven Betrag eingeben.'
          : null,
    );
  }

  /// The categories used most for this direction, one tap to pick.
  Widget _categoryChips(BuildContext context) {
    final counts = <String, int>{};
    for (final entry in widget.ledgerEntries) {
      if (entry.isIncome != _income ||
          entry.category.isEmpty ||
          entry.sourceType == 'transfer' ||
          entry.sourceType == 'saving') {
        continue;
      }
      counts.update(entry.category, (count) => count + 1, ifAbsent: () => 1);
    }
    final ranked = counts.keys.toList()
      ..sort((a, b) => counts[b]!.compareTo(counts[a]!));
    final fallback = _income
        ? const ['Gehalt', 'Dividende', 'Sonstiges']
        : const ['Einkaufen', 'Wohnen', 'Tanken', 'Freizeit', 'Sonstiges'];
    final chips = {
      ...ranked.take(6),
      if (ranked.length < 4) ...fallback,
    }.take(7).toList();
    final current = _category.text.trim();
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          for (final category in chips)
            Padding(
              padding: const EdgeInsets.only(right: 6),
              child: ChoiceChip(
                label: Text(category),
                selected: current == category,
                showCheckmark: false,
                visualDensity: VisualDensity.compact,
                onSelected: (selected) => setState(() {
                  _category.text = selected ? category : '';
                  _categoryEdited = true;
                }),
              ),
            ),
        ],
      ),
    );
  }

  bool get _hasExtraOptions =>
      _vehicleId.isNotEmpty ||
      _payment.text.trim().isNotEmpty ||
      _budgetOffset != 0;

  Widget _kindSelector() {
    if (_isLinkedEdit) {
      final saving = _kind == 'saving';
      return ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Icon(
          saving ? Icons.savings_rounded : Icons.swap_horiz_rounded,
        ),
        title: Text(saving ? 'Sparbuchung' : 'Umbuchung'),
        subtitle: const Text(
          'Betrag, Datum und Texte werden auch auf der Gegenseite angepasst.',
        ),
      );
    }
    final segments = [
      const ButtonSegment(
        value: 'expense',
        icon: Icon(Icons.north_east_rounded),
        label: _SegmentLabel('Ausgabe'),
      ),
      const ButtonSegment(
        value: 'income',
        icon: Icon(Icons.south_west_rounded),
        label: _SegmentLabel('Einnahme'),
      ),
      if (_isNew) ...[
        const ButtonSegment(
          value: 'transfer',
          icon: Icon(Icons.swap_horiz_rounded),
          label: _SegmentLabel('Umbuchung'),
        ),
        const ButtonSegment(
          value: 'saving',
          icon: Icon(Icons.savings_rounded),
          label: _SegmentLabel('Sparen'),
        ),
      ],
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 480;
        return SegmentedButton<String>(
          showSelectedIcon: false,
          style: compact
              ? const ButtonStyle(
                  visualDensity: VisualDensity.compact,
                  padding: WidgetStatePropertyAll(
                    EdgeInsets.symmetric(horizontal: 4),
                  ),
                )
              : null,
          segments: [
            for (final segment in segments)
              ButtonSegment(
                value: segment.value,
                icon: compact ? null : segment.icon,
                label: segment.label,
                tooltip: compact && segment.label is _SegmentLabel
                    ? (segment.label! as _SegmentLabel).text
                    : null,
              ),
          ],
          selected: {_kind},
          onSelectionChanged: (value) => setState(() => _kind = value.first),
        );
      },
    );
  }

  List<Widget> _extraOptions(BuildContext context) => [
    _responsiveFields([
      _EditableSuggestionField(
        controller: _payment,
        label: 'Zahlungsmethode',
        suggestions: _masterEntries('paymentMethod'),
      ),
      SearchableDropdownButtonFormField<String>(
        initialValue: _vehicleId,
        isExpanded: true,
        decoration: const InputDecoration(
          labelText: 'Fahrzeug',
          prefixIcon: Icon(Icons.directions_car_rounded),
        ),
        items: [
          const DropdownMenuItem(value: '', child: Text('Kein Fahrzeug')),
          for (final vehicle in widget.vehicles)
            DropdownMenuItem(
              value: vehicle.id,
              child: Text('${vehicle.make} ${vehicle.model}'),
            ),
        ],
        onChanged: (value) => _vehicleId = value ?? '',
      ),
    ]),
    const SizedBox(height: 12),
    SearchableDropdownButtonFormField<int>(
      key: ValueKey('budget-$_budgetOffset'),
      initialValue: _budgetOffset,
      isExpanded: true,
      decoration: const InputDecoration(
        labelText: 'Wirtschaftlicher Buchungsmonat',
      ),
      items: const [
        DropdownMenuItem(value: 0, child: Text('Monat des Datums')),
        DropdownMenuItem(value: 1, child: Text('Nächster Monat')),
      ],
      onChanged: (value) => setState(() => _budgetOffset = value ?? 0),
    ),
    const SizedBox(height: 4),
    SwitchListTile.adaptive(
      contentPadding: EdgeInsets.zero,
      secondary: const Icon(Icons.notifications_outlined),
      title: const Text('Erinnerung'),
      value: _addReminder,
      onChanged: (value) => setState(() => _addReminder = value),
    ),
    if (_addReminder) ...[
      TextFormField(
        controller: _reminderTitle,
        decoration: const InputDecoration(
          labelText: 'Erinnerung *',
          hintText: 'z. B. Abo kündigen',
        ),
        validator: (value) => _addReminder && (value?.trim().isEmpty ?? true)
            ? 'Bitte einen Erinnerungstext eingeben.'
            : null,
      ),
      const SizedBox(height: 10),
      _responsiveFields([
        OutlinedButton.icon(
          onPressed: _pickReminderDate,
          icon: const Icon(Icons.event_rounded),
          label: Text(DateFormat('dd.MM.yyyy').format(_reminderAt)),
        ),
        OutlinedButton.icon(
          onPressed: _pickReminderTime,
          icon: const Icon(Icons.schedule_rounded),
          label: Text('${DateFormat('HH:mm').format(_reminderAt)} Uhr'),
        ),
      ]),
      const SizedBox(height: 8),
    ],
    if (_isNew) ...[
      SwitchListTile.adaptive(
        contentPadding: EdgeInsets.zero,
        secondary: const Icon(Icons.repeat_rounded),
        title: const Text('Mehrere Monate buchen'),
        value: _repeatMonthly,
        onChanged: (value) => setState(() => _repeatMonthly = value),
      ),
      if (_repeatMonthly) ...[
        _responsiveFields([
          SearchableDropdownButtonFormField<String>(
            key: ValueKey(_timing),
            initialValue: _timing,
            isExpanded: true,
            decoration: const InputDecoration(labelText: 'Buchungstag'),
            items: [
              DropdownMenuItem(
                value: 'selected',
                child: Text('Am ${_date.day}. jedes Monats'),
              ),
              const DropdownMenuItem(
                value: 'start',
                child: Text('Erster Werktag'),
              ),
              const DropdownMenuItem(
                value: 'middle',
                child: Text('Monatsmitte (15.)'),
              ),
              const DropdownMenuItem(
                value: 'end',
                child: Text('Letzter Werktag'),
              ),
            ],
            onChanged: (value) => setState(() => _timing = value ?? 'selected'),
          ),
          TextFormField(
            controller: _months,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Laufzeit (Monate)'),
            onChanged: (_) => setState(() {}),
            validator: (_) =>
                _repeatMonthly && (_monthCount < 2 || _monthCount > 120)
                ? 'Bitte 2 bis 120 Monate eingeben.'
                : null,
          ),
        ]),
        const SizedBox(height: 8),
        Text(_seriesPreview(), style: Theme.of(context).textTheme.bodySmall),
      ],
    ],
  ];

  Widget _responsiveFields(List<Widget> fields) => LayoutBuilder(
    builder: (context, constraints) {
      if (constraints.maxWidth < 440) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var index = 0; index < fields.length; index++) ...[
              fields[index],
              if (index < fields.length - 1) const SizedBox(height: 12),
            ],
          ],
        );
      }
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var index = 0; index < fields.length; index++) ...[
            Expanded(child: fields[index]),
            if (index < fields.length - 1) const SizedBox(width: 12),
          ],
        ],
      );
    },
  );

  Account? get _selectedAccount =>
      widget.accounts.where((account) => account.id == _accountId).firstOrNull;

  void _suggestCategory(String merchant) {
    if (!_isNew || _categoryEdited) return;
    final key = merchant.trim().toLowerCase();
    if (key.isEmpty) return;
    final previous = widget.ledgerEntries
        .where(
          (entry) =>
              entry.merchant.trim().toLowerCase() == key &&
              entry.category.isNotEmpty &&
              entry.sourceType != 'transfer' &&
              entry.sourceType != 'saving',
        )
        .firstOrNull;
    if (previous == null) return;
    setState(() => _category.text = previous.category);
    if (_payment.text.trim().isEmpty && previous.paymentMethod.isNotEmpty) {
      _payment.text = previous.paymentMethod;
    }
  }

  Future<void> _pickDate() async {
    final value = await showDatePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
      initialDate: _date,
    );
    if (value != null) setState(() => _date = value);
  }

  _EntrySubmission? _submission() {
    if (!(_formKey.currentState?.validate() ?? false)) return null;
    final userId = ProviderScope.containerOf(
      context,
      listen: false,
    ).read(currentUserIdProvider);
    if (userId == null) return null;
    final now = DateTime.now().toUtc();
    final amount = parseAmount(_amount.text) ?? 0;
    final category = _category.text.trim().isEmpty
        ? 'Sonstiges'
        : _category.text.trim();
    final repeatCount = _isNew && _repeatMonthly ? _monthCount : 1;
    final timing = _repeatMonthly ? _timing : 'selected';
    final recurrenceId = repeatCount > 1 ? const Uuid().v4() : '';
    final entries = <LedgerEntriesCompanion>[];
    for (var index = 0; index < repeatCount; index++) {
      final transferId = _bookingKind == 'standard' ? '' : const Uuid().v4();
      final seriesMonth = DateTime(_date.year, _date.month + index);
      final date = !_isNew
          ? _date
          : paymentDateForBudgetMonth(
              budgetMonth: seriesMonth,
              timing: timing,
              selectedDay: _date.day,
            );
      final budgetMonth = DateTime(date.year, date.month + _budgetOffset);
      entries.add(
        LedgerEntriesCompanion.insert(
          id: widget.entry?.id ?? const Uuid().v4(),
          userId: userId,
          bookingDate: date,
          budgetMonth: Value(budgetMonth),
          amount: amount,
          // A linked edit keeps the side it is on (outgoing or incoming).
          isIncome: Value(_isLinkedEdit ? widget.entry!.isIncome : _income),
          category: category,
          merchant: Value(_merchant.text.trim()),
          description: Value(_description.text.trim()),
          paymentMethod: Value(_payment.text.trim()),
          recurrenceId: Value(widget.entry?.recurrenceId ?? recurrenceId),
          sourceType: Value(
            widget.entry?.sourceType ??
                (_bookingKind == 'standard' ? 'manual' : _bookingKind),
          ),
          sourceId: Value(widget.entry?.sourceId ?? transferId),
          vehicleId: Value(_vehicleId),
          accountId: Value(_accountId),
          createdAt: widget.entry?.createdAt ?? now,
          updatedAt: now,
        ),
      );
      if (_isNew && _bookingKind != 'standard') {
        entries.add(
          LedgerEntriesCompanion.insert(
            id: const Uuid().v4(),
            userId: userId,
            bookingDate: date,
            budgetMonth: Value(budgetMonth),
            amount: amount,
            isIncome: const Value(true),
            category: _bookingKind == 'saving'
                ? 'Sparen / Investieren'
                : 'Umbuchung',
            merchant: Value(_merchant.text.trim()),
            description: Value(_description.text.trim()),
            paymentMethod: Value(_payment.text.trim()),
            recurrenceId: Value(recurrenceId),
            sourceType: Value(_bookingKind),
            sourceId: Value(transferId),
            accountId: Value(_targetAccountId),
            createdAt: now,
            updatedAt: now,
          ),
        );
      }
    }
    return _EntrySubmission(
      entries,
      merchant: _merchant.text.trim(),
      paymentMethod: _payment.text.trim(),
      category: category,
      reminderTitle: _addReminder ? _reminderTitle.text.trim() : null,
      reminderAt: _addReminder ? _reminderAt : null,
    );
  }

  void _save() {
    final submission = _submission();
    if (submission != null) Navigator.pop(context, submission);
  }

  Future<void> _saveAndNext() async {
    final submission = _submission();
    if (submission == null) return;
    setState(() => _saving = true);
    try {
      await widget.onSaveAndNext!(submission);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _notice = error.toString().replaceFirst('Bad state: ', '');
      });
      return;
    }
    if (!mounted) return;
    final label = submission.merchant.isNotEmpty
        ? submission.merchant
        : submission.category;
    final amount = money(
      parseAmount(_amount.text) ?? 0,
      currency: _selectedAccount?.currency ?? 'EUR',
    );
    setState(() {
      _saving = false;
      _notice = 'Gespeichert: $label · $amount';
      _amount.clear();
      _merchant.clear();
      _category.clear();
      _description.clear();
      _reminderTitle.clear();
      _categoryEdited = false;
      _addReminder = false;
      _repeatMonthly = false;
    });
    _amountFocus.requestFocus();
  }

  List<String> _masterEntries(String kind) => widget.masterData
      .where((item) => item.kind == kind)
      .map((item) => item.value)
      .toList();

  int _initialBudgetOffset() {
    final budgetMonth = widget.entry?.budgetMonth;
    final bookingDate = widget.entry?.bookingDate;
    if (budgetMonth == null || bookingDate == null) return 0;
    return ((budgetMonth.year - bookingDate.year) * 12 +
            budgetMonth.month -
            bookingDate.month)
        .clamp(0, 1);
  }

  String _seriesPreview() {
    final first = paymentDateForBudgetMonth(
      budgetMonth: DateTime(_date.year, _date.month),
      timing: _timing,
      selectedDay: _date.day,
    );
    final count = _monthCount.clamp(2, 120);
    final last = DateTime(_date.year, _date.month + count - 1);
    return 'Erste Buchung am ${DateFormat('dd.MM.yyyy').format(first)}, '
        'letzte im ${monthLabel(last)}.';
  }

  Future<void> _pickReminderDate() async {
    final selected = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
      initialDate: _reminderAt,
    );
    if (selected != null) {
      setState(
        () => _reminderAt = DateTime(
          selected.year,
          selected.month,
          selected.day,
          _reminderAt.hour,
          _reminderAt.minute,
        ),
      );
    }
  }

  Future<void> _pickReminderTime() async {
    final selected = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_reminderAt),
    );
    if (selected != null) {
      setState(
        () => _reminderAt = DateTime(
          _reminderAt.year,
          _reminderAt.month,
          _reminderAt.day,
          selected.hour,
          selected.minute,
        ),
      );
    }
  }
}

class _SegmentLabel extends StatelessWidget {
  const _SegmentLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => FittedBox(
    fit: BoxFit.scaleDown,
    child: Text(text, maxLines: 1, softWrap: false),
  );
}

class _DateField extends StatelessWidget {
  const _DateField({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(12),
    child: InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.event_rounded),
      ),
      child: Text(value),
    ),
  );
}

class _EditableSuggestionField extends StatelessWidget {
  const _EditableSuggestionField({
    required this.controller,
    required this.label,
    required this.suggestions,
    this.onChanged,
  });

  final TextEditingController controller;
  final String label;
  final List<String> suggestions;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) => TextFormField(
    controller: controller,
    onChanged: onChanged,
    decoration: InputDecoration(
      labelText: label,
      suffixIcon: suggestions.isEmpty
          ? null
          : PopupMenuButton<String>(
              tooltip: 'Vorhandene Werte anzeigen',
              icon: const Icon(Icons.arrow_drop_down_rounded),
              onSelected: (value) {
                controller
                  ..text = value
                  ..selection = TextSelection.collapsed(offset: value.length);
                onChanged?.call(value);
              },
              itemBuilder: (context) => suggestions
                  .map(
                    (value) =>
                        PopupMenuItem<String>(value: value, child: Text(value)),
                  )
                  .toList(),
            ),
    ),
  );
}

DateTime _month(DateTime value) => DateTime(value.year, value.month);

/// The household account as one tappable line under the title on phones;
/// the choice opens in a bottom sheet.
class _AccountRow extends StatelessWidget {
  const _AccountRow({
    required this.accounts,
    required this.selectedId,
    required this.balanceOf,
    required this.onSelected,
  });

  final List<Account> accounts;
  final String? selectedId;
  final double Function(Account account) balanceOf;
  final ValueChanged<String?> onSelected;

  @override
  Widget build(BuildContext context) {
    final colors = WealthColors.of(context);
    final selected =
        accounts.where((account) => account.id == selectedId).firstOrNull ??
        accounts.first;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: accounts.length < 2
            ? null
            : () async {
                final chosen = await showModalBottomSheet<String>(
                  context: context,
                  showDragHandle: true,
                  builder: (sheetContext) => SafeArea(
                    child: ListView(
                      shrinkWrap: true,
                      children: [
                        for (final account in accounts)
                          ListTile(
                            leading: const Icon(Icons.account_balance_rounded),
                            title: Text(account.label),
                            subtitle: Text(account.bankName),
                            trailing: Text(
                              money(
                                balanceOf(account),
                                currency: account.currency,
                              ),
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            selected: account.id == selected.id,
                            onTap: () =>
                                Navigator.pop(sheetContext, account.id),
                          ),
                      ],
                    ),
                  ),
                );
                if (chosen != null) onSelected(chosen);
              },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
          child: Row(
            children: [
              Icon(
                Icons.account_balance_rounded,
                size: 18,
                color: colors.muted,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  selected.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              Text(
                ' · ${money(balanceOf(selected), currency: selected.currency)}',
                style: TextStyle(color: colors.muted),
              ),
              if (accounts.length > 1)
                Icon(Icons.expand_more_rounded, size: 20, color: colors.muted),
            ],
          ),
        ),
      ),
    );
  }
}
