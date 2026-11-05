import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wealthflow_core/database/app_database.dart';

import '../../app/app_theme.dart';
import '../../core/providers.dart';
import '../../core/widgets/common_widgets.dart';
import '../finance/investments_page.dart';
import '../household/household_page.dart';

/// Opens the search above the current page (Ctrl+K, the search field in the
/// sidebar or the magnifier on phones). A hit closes the search and opens
/// the booking or position directly.
Future<void> showSearchOverlay(BuildContext context, WidgetRef ref) async {
  final phone = MediaQuery.sizeOf(context).width < 600;
  final hit = await showDialog<_SearchResult>(
    context: context,
    barrierColor: Colors.black.withValues(alpha: .35),
    builder: (_) => phone
        ? const Dialog.fullscreen(child: _SearchPanel())
        : Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 72, 24, 24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 640,
                  maxHeight: 560,
                ),
                child: Material(
                  type: MaterialType.card,
                  borderRadius: const BorderRadius.all(Radius.circular(20)),
                  clipBehavior: Clip.antiAlias,
                  child: const _SearchPanel(),
                ),
              ),
            ),
          ),
  );
  if (hit == null || !context.mounted) return;
  await hit.open(context, ref);
}

const _types = ['Alle', 'Buchungen', 'Depot', 'Konten', 'Fahrzeuge'];

class _SearchPanel extends ConsumerStatefulWidget {
  const _SearchPanel();

  @override
  ConsumerState<_SearchPanel> createState() => _SearchPanelState();
}

class _SearchPanelState extends ConsumerState<_SearchPanel> {
  String _query = '';
  String _type = 'Alle';

  @override
  Widget build(BuildContext context) {
    final colors = WealthColors.of(context);
    final results = _results();
    final phone = MediaQuery.sizeOf(context).width < 600;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(phone ? 4 : 16, 8, 8, 0),
          child: Row(
            children: [
              if (phone)
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back_rounded),
                  tooltip: 'Zurück',
                )
              else
                Icon(Icons.search_rounded, color: colors.muted),
              const SizedBox(width: 8),
              Expanded(
                child: CallbackShortcuts(
                  bindings: {
                    const SingleActivator(LogicalKeyboardKey.enter): () {
                      if (results.isNotEmpty) {
                        Navigator.pop(context, results.first);
                      }
                    },
                  },
                  child: TextField(
                    autofocus: true,
                    textInputAction: TextInputAction.search,
                    onChanged: (value) => setState(() => _query = value),
                    onSubmitted: (_) {
                      if (results.isNotEmpty) {
                        Navigator.pop(context, results.first);
                      }
                    },
                    style: const TextStyle(fontSize: 17),
                    decoration: const InputDecoration(
                      hintText: 'Buchungen, Positionen, Konten suchen',
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      filled: false,
                    ),
                  ),
                ),
              ),
              if (!phone)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: colors.border),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'Esc',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: colors.muted,
                    ),
                  ),
                ),
            ],
          ),
        ),
        SizedBox(
          height: 44,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            children: [
              for (final type in _types)
                Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: ChoiceChip(
                    label: Text(type),
                    selected: _type == type,
                    showCheckmark: false,
                    visualDensity: VisualDensity.compact,
                    onSelected: (_) => setState(() => _type = type),
                  ),
                ),
            ],
          ),
        ),
        Divider(height: 1, color: colors.border),
        Flexible(
          fit: phone ? FlexFit.tight : FlexFit.loose,
          child: _query.trim().isEmpty
              ? _Hint(
                  text:
                      'Name, Händler, Kategorie, Betrag, ISIN oder Kennzeichen',
                )
              : results.isEmpty
              ? const _Hint(text: 'Keine Treffer')
              : ListView(
                  shrinkWrap: !phone,
                  padding: const EdgeInsets.fromLTRB(8, 8, 8, 12),
                  children: [
                    for (final (index, result) in results.indexed) ...[
                      if (index == 0 || results[index - 1].type != result.type)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
                          child: Eyebrow(result.type),
                        ),
                      ListTile(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        leading: IconTile(icon: result.icon, size: 36),
                        title: Text(
                          result.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(
                          result.subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: result.value,
                        onTap: () => Navigator.pop(context, result),
                      ),
                    ],
                  ],
                ),
        ),
      ],
    );
  }

  List<_SearchResult> _results() {
    final terms = _query
        .toLowerCase()
        .split(RegExp(r'\s+'))
        .where((term) => term.isNotEmpty)
        .toList();
    if (terms.isEmpty) return const [];
    bool matches(String text) {
      final haystack = text.toLowerCase();
      return terms.every(haystack.contains);
    }

    bool wanted(String type) => _type == 'Alle' || _type == type;
    final output = <_SearchResult>[];
    if (wanted('Buchungen')) {
      final entries = [...?ref.watch(ledgerEntriesProvider).valueOrNull]
        ..sort((a, b) => b.bookingDate.compareTo(a.bookingDate));
      output.addAll(
        entries
            .where(
              (item) => matches(
                '${item.merchant} ${item.description} ${item.category} '
                '${item.paymentMethod} ${money(item.amount)} '
                '${shortDate(item.bookingDate)} ${item.bookingDate.year}',
              ),
            )
            .take(30)
            .map(
              (item) => _SearchResult(
                type: 'Buchungen',
                title: item.merchant.isNotEmpty
                    ? item.merchant
                    : item.description.isNotEmpty
                    ? item.description
                    : item.category,
                subtitle: [
                  if (item.category.isNotEmpty) item.category,
                  '${shortDate(item.bookingDate)} ${item.bookingDate.year}',
                ].join(' · '),
                value: AmountText(item.amount, income: item.isIncome),
                icon: item.isIncome
                    ? Icons.south_west_rounded
                    : Icons.north_east_rounded,
                open: (context, ref) async {
                  selectShellDestination(ref, 2);
                  await showEntryEditor(context, ref, entry: item);
                },
              ),
            ),
      );
    }
    if (wanted('Depot')) {
      final converter = ref.watch(currencyConverterProvider);
      for (final item
          in ref.watch(investmentsProvider).valueOrNull ??
              const <Investment>[]) {
        if (!matches(
          '${item.name} ${item.symbol} ${item.isin} ${item.wkn} '
          '${item.assetType} ${item.broker} ${item.sector} ${item.country}',
        )) {
          continue;
        }
        output.add(
          _SearchResult(
            type: 'Depot',
            title: item.name,
            subtitle: [
              item.assetType,
              if (item.symbol.isNotEmpty) item.symbol,
              '${quantityText(item.quantity)} Stück',
            ].join(' · '),
            value: Text(
              money(converter.investmentValue(item)),
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            icon: Icons.candlestick_chart_rounded,
            open: (context, ref) async {
              openFinance(ref, 1);
              await showInvestmentDetails(context, ref, item);
            },
          ),
        );
      }
    }
    if (wanted('Konten')) {
      for (final item
          in ref.watch(accountsProvider).valueOrNull ?? const <Account>[]) {
        if (!matches(
          '${item.bankName} ${item.label} ${item.holder} ${item.iban}',
        )) {
          continue;
        }
        output.add(
          _SearchResult(
            type: 'Konten',
            title: item.label,
            subtitle: item.bankName,
            value: Text(
              money(item.balance, currency: item.currency),
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            icon: Icons.account_balance_rounded,
            open: (context, ref) async => openFinance(ref, 0),
          ),
        );
      }
    }
    if (wanted('Fahrzeuge')) {
      for (final item
          in ref.watch(vehiclesProvider).valueOrNull ?? const <Vehicle>[]) {
        if (!matches(
          '${item.make} ${item.model} ${item.licensePlate} ${item.fuelType}',
        )) {
          continue;
        }
        output.add(
          _SearchResult(
            type: 'Fahrzeuge',
            title: '${item.make} ${item.model}',
            subtitle: [
              item.vehicleType,
              if (item.licensePlate.isNotEmpty) item.licensePlate,
            ].join(' · '),
            icon: item.vehicleType == 'Motorrad'
                ? Icons.two_wheeler_rounded
                : Icons.directions_car_rounded,
            open: (context, ref) async => selectShellDestination(ref, 5),
          ),
        );
      }
    }
    return output;
  }
}

class _Hint extends StatelessWidget {
  const _Hint({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
    child: Text(
      text,
      textAlign: TextAlign.center,
      style: TextStyle(color: WealthColors.of(context).muted),
    ),
  );
}

class _SearchResult {
  const _SearchResult({
    required this.type,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.open,
    this.value,
  });

  final String type;
  final String title;
  final String subtitle;
  final Widget? value;
  final IconData icon;
  final Future<void> Function(BuildContext context, WidgetRef ref) open;
}
