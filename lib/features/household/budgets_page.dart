import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:wealthflow_core/database/app_database.dart';
import 'package:wealthflow_core/finance/amount_input.dart';
import 'package:wealthflow_core/finance/category_budget.dart';

import '../../app/app_theme.dart';
import '../../core/providers.dart';
import '../../core/widgets/common_widgets.dart';
import '../../core/widgets/save_feedback.dart';

class BudgetsPage extends ConsumerStatefulWidget {
  const BudgetsPage({super.key});

  @override
  ConsumerState<BudgetsPage> createState() => _BudgetsPageState();
}

class _BudgetsPageState extends ConsumerState<BudgetsPage> {
  DateTime _month = DateTime(DateTime.now().year, DateTime.now().month);

  @override
  Widget build(BuildContext context) {
    final budgets = ref.watch(categoryBudgetsProvider);
    final entries =
        ref.watch(ledgerEntriesProvider).valueOrNull ?? const <LedgerEntry>[];
    final now = DateTime.now();
    final current = DateTime(now.year, now.month);
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              PageHeader(
                title: 'Budgets',
                action: FilledButton.icon(
                  onPressed: () => showBudgetEditor(context, ref),
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Budget'),
                ),
              ),
              Expanded(
                child: budgets.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (error, _) => LoadErrorMessage(
                    'Budgets konnten nicht geladen werden',
                    error: error,
                  ),
                  data: (items) {
                    if (items.isEmpty) {
                      return EmptyState(
                        icon: Icons.donut_large_rounded,
                        title: 'Noch keine Budgets',
                        message:
                            'Lege fest, wie viel du im Monat zum Beispiel '
                            'für Lebensmittel oder Freizeit ausgeben '
                            'möchtest. Ab 80 % wird der Balken orange.',
                        action: FilledButton.icon(
                          onPressed: () => showBudgetEditor(context, ref),
                          icon: const Icon(Icons.add_rounded),
                          label: const Text('Budget festlegen'),
                        ),
                      );
                    }
                    final progress = buildBudgetProgress(
                      items,
                      entries,
                      _month,
                    );
                    return ListView(
                      children: [
                        Row(
                          children: [
                            IconButton(
                              tooltip: 'Vormonat',
                              onPressed: () => setState(
                                () => _month = DateTime(
                                  _month.year,
                                  _month.month - 1,
                                ),
                              ),
                              icon: const Icon(Icons.chevron_left_rounded),
                            ),
                            Expanded(
                              child: Text(
                                monthLabel(_month),
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.w700),
                              ),
                            ),
                            IconButton(
                              tooltip: 'Nächster Monat',
                              onPressed: _month.isBefore(current)
                                  ? () => setState(
                                      () => _month = DateTime(
                                        _month.year,
                                        _month.month + 1,
                                      ),
                                    )
                                  : null,
                              icon: const Icon(Icons.chevron_right_rounded),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        if (progress.isEmpty)
                          Padding(
                            padding: const EdgeInsets.all(24),
                            child: Text(
                              'In diesem Monat galt noch kein Budget.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: WealthColors.of(context).muted,
                              ),
                            ),
                          )
                        else ...[
                          _MonthSummary(
                            progress: progress,
                            finished: _month.isBefore(current),
                          ),
                          const SizedBox(height: 12),
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Column(
                                children: [
                                  for (final item in progress)
                                    BudgetBar(
                                      progress: item,
                                      onTap: () => showBudgetEditor(
                                        context,
                                        ref,
                                        budget: item.budget,
                                      ),
                                      onDelete: () => _delete(item.budget),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _delete(CategoryBudget budget) async {
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) return;
    final confirmed = await confirmDelete(
      context,
      title: 'Budget löschen?',
      message:
          'Das Budget für ${budget.category} wird entfernt. Buchungen '
          'bleiben unverändert.',
    );
    if (!confirmed || !mounted) return;
    await saveWithFeedback(
      context,
      () => ref.read(databaseProvider).deleteCategoryBudget(budget.id, userId),
      failure: 'Löschen fehlgeschlagen',
      source: 'Budget löschen',
    );
  }
}

/// Total of all budgets, and for a finished month how many were kept.
class _MonthSummary extends StatelessWidget {
  const _MonthSummary({required this.progress, required this.finished});

  final List<BudgetProgress> progress;
  final bool finished;

  @override
  Widget build(BuildContext context) {
    final colors = WealthColors.of(context);
    final spent = progress.fold(0.0, (sum, item) => sum + item.spent);
    final available = progress.fold(0.0, (sum, item) => sum + item.available);
    final kept = progress
        .where((item) => item.state != BudgetState.over)
        .length;
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Eyebrow(finished ? 'Rückblick' : 'Alle Budgets'),
            const SizedBox(height: 6),
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: money(spent),
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  TextSpan(
                    text: ' von ${money(available)}',
                    style: TextStyle(color: colors.muted),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              finished
                  ? '$kept von ${progress.length} Budgets eingehalten'
                  : spent <= available
                  ? '${money(available - spent)} noch frei'
                  : '${money(spent - available)} über dem Plan',
              style: TextStyle(
                color: finished && kept == progress.length
                    ? colors.income
                    : colors.muted,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// One budget: "212 € von 450 €", a bar that turns orange from 80 % and
/// red above 100 %, and what is left or how far it is exceeded.
class BudgetBar extends StatelessWidget {
  const BudgetBar({
    required this.progress,
    this.onTap,
    this.onDelete,
    this.dense = false,
    super.key,
  });

  final BudgetProgress progress;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final colors = WealthColors.of(context);
    final color = switch (progress.state) {
      BudgetState.over => colors.expense,
      BudgetState.warning => colors.warning,
      BudgetState.ok => Theme.of(context).colorScheme.primary,
    };
    final left = progress.left;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          dense ? 0 : 20,
          dense ? 6 : 10,
          dense || onDelete == null ? (dense ? 0 : 20) : 4,
          dense ? 6 : 10,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    progress.budget.category,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                Text(
                  '${money(progress.spent)} von ${money(progress.available)}',
                  style: TextStyle(fontSize: 13, color: colors.muted),
                ),
                if (onDelete != null && !dense)
                  PopupMenuButton<String>(
                    onSelected: (value) =>
                        value == 'edit' ? onTap?.call() : onDelete!(),
                    itemBuilder: (_) => const [
                      PopupMenuItem(value: 'edit', child: Text('Bearbeiten')),
                      PopupMenuItem(value: 'delete', child: Text('Löschen')),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress.ratio.clamp(0, 1).toDouble(),
                minHeight: 8,
                backgroundColor: colors.neutralSoft,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              [
                left >= 0 ? '${money(left)} frei' : '${money(-left)} drüber',
                if (progress.carried > 0)
                  'inkl. ${money(progress.carried)} aus Vormonaten',
              ].join(' · '),
              style: TextStyle(
                fontSize: 12,
                color: left < 0 ? colors.expense : colors.muted,
                fontWeight: left < 0 ? FontWeight.w600 : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> showBudgetEditor(
  BuildContext context,
  WidgetRef ref, {
  CategoryBudget? budget,
}) async {
  final userId = ref.read(currentUserIdProvider);
  if (userId == null) return;
  final entries = await ref.read(ledgerEntriesProvider.future);
  final budgets = await ref.read(categoryBudgetsProvider.future);
  if (!context.mounted) return;
  // Categories used for expenses, most used first.
  final counts = <String, int>{};
  for (final entry in entries) {
    if (entry.isIncome ||
        entry.category.isEmpty ||
        entry.sourceType == 'transfer' ||
        entry.sourceType == 'saving') {
      continue;
    }
    counts.update(entry.category, (count) => count + 1, ifAbsent: () => 1);
  }
  final taken = {
    for (final item in budgets)
      if (item.id != budget?.id) item.category,
  };
  final suggestions =
      counts.keys.where((category) => !taken.contains(category)).toList()
        ..sort((a, b) => counts[b]!.compareTo(counts[a]!));
  final result = await showDialog<CategoryBudgetInput>(
    context: context,
    builder: (_) => _BudgetEditor(
      userId: userId,
      budget: budget,
      suggestions: suggestions,
      averages: {
        for (final category in suggestions.take(12))
          category: _monthlyAverage(entries, category),
      },
    ),
  );
  if (result == null || !context.mounted) return;
  await saveWithFeedback(
    context,
    () => ref.read(databaseProvider).saveCategoryBudget(result),
    failure: 'Budget nicht gespeichert',
    source: 'Budget speichern',
  );
}

/// Average monthly spending of [category] over the last three full months.
double _monthlyAverage(List<LedgerEntry> entries, String category) {
  final now = DateTime.now();
  final from = DateTime(now.year, now.month - 3);
  final to = DateTime(now.year, now.month);
  final byMonth = expensesByMonthAndCategory(entries);
  var total = 0.0;
  for (final MapEntry(key: month, value: categories) in byMonth.entries) {
    if (!month.isBefore(from) && month.isBefore(to)) {
      total += categories[category] ?? 0;
    }
  }
  return total / 3;
}

class _BudgetEditor extends StatefulWidget {
  const _BudgetEditor({
    required this.userId,
    required this.budget,
    required this.suggestions,
    required this.averages,
  });

  final String userId;
  final CategoryBudget? budget;
  final List<String> suggestions;
  final Map<String, double> averages;

  @override
  State<_BudgetEditor> createState() => _BudgetEditorState();
}

class _BudgetEditorState extends State<_BudgetEditor> {
  final _formKey = GlobalKey<FormState>();
  late final _category = TextEditingController(
    text: widget.budget?.category ?? '',
  );
  late final _limit = TextEditingController(
    text: widget.budget == null
        ? ''
        : formatAmountInput(widget.budget!.monthlyLimit),
  );
  late bool _carryOver = widget.budget?.carryOver ?? false;

  @override
  void dispose() {
    _category.dispose();
    _limit.dispose();
    super.dispose();
  }

  void _pick(String category) {
    setState(() => _category.text = category);
    final average = widget.averages[category] ?? 0;
    if (_limit.text.trim().isEmpty && average > 0) {
      // A round suggestion just above what the category usually costs.
      _limit.text = formatAmountInput((average / 10).ceil() * 10.0);
    }
  }

  void _save() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final now = DateTime.now();
    Navigator.pop(
      context,
      CategoryBudgetInput(
        id: widget.budget?.id ?? const Uuid().v4(),
        userId: widget.userId,
        category: _category.text.trim(),
        monthlyLimit: parseAmount(_limit.text) ?? 0,
        carryOver: _carryOver,
        startMonth: DateTime(now.year, now.month),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final current = _category.text.trim();
    final average = widget.averages[current];
    return AlertDialog(
      title: Text(
        widget.budget == null ? 'Budget festlegen' : 'Budget bearbeiten',
      ),
      content: SizedBox(
        width: (MediaQuery.sizeOf(context).width - 64).clamp(280, 480),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _category,
                  autofocus: widget.budget == null,
                  onChanged: (_) => setState(() {}),
                  decoration: const InputDecoration(
                    labelText: 'Kategorie *',
                    prefixIcon: Icon(Icons.sell_outlined),
                  ),
                  validator: (value) => (value?.trim().isEmpty ?? true)
                      ? 'Bitte eine Kategorie wählen.'
                      : null,
                ),
                if (widget.suggestions.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      for (final category in widget.suggestions.take(8))
                        ChoiceChip(
                          label: Text(category),
                          selected: current == category,
                          showCheckmark: false,
                          visualDensity: VisualDensity.compact,
                          onSelected: (_) => _pick(category),
                        ),
                    ],
                  ),
                ],
                const SizedBox(height: 16),
                TextFormField(
                  key: const Key('budget-limit'),
                  controller: _limit,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Pro Monat *',
                    prefixIcon: const Icon(Icons.euro_rounded),
                    helperText: average != null && average > 0
                        ? 'Bisher im Schnitt ${money(average)} pro Monat'
                        : null,
                  ),
                  validator: (value) => (parseAmount(value) ?? 0) <= 0
                      ? 'Bitte einen positiven Betrag eingeben.'
                      : null,
                ),
                const SizedBox(height: 8),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _carryOver,
                  onChanged: (value) => setState(() => _carryOver = value),
                  title: const Text('Rest übertragen'),
                  subtitle: const Text(
                    'Was in einem Monat übrig bleibt, kommt zum nächsten dazu.',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Abbrechen'),
        ),
        FilledButton(onPressed: _save, child: const Text('Speichern')),
      ],
    );
  }
}
