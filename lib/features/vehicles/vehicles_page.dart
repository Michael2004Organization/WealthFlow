import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../core/database/app_database.dart';
import '../../core/providers.dart';
import '../../core/widgets/common_widgets.dart';

class VehiclesPage extends ConsumerWidget {
  const VehiclesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vehicles = ref.watch(vehiclesProvider);
    final costs =
        ref.watch(vehicleCostsProvider).valueOrNull ?? const <VehicleCost>[];
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1180),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              PageHeader(
                title: 'Fahrzeuge',
                subtitle:
                    'Autos, Motorräder und ihre vollständige Kostenhistorie.',
                action: FilledButton.icon(
                  onPressed: () => showVehicleEditor(context, ref),
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Fahrzeug'),
                ),
              ),
              Expanded(
                child: vehicles.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (error, _) => Center(
                    child: Text(
                      'Fahrzeuge konnten nicht geladen werden: $error',
                    ),
                  ),
                  data: (items) {
                    if (items.isEmpty) {
                      return EmptyState(
                        icon: Icons.directions_car_rounded,
                        title: 'Noch kein Fahrzeug',
                        message:
                            'Lege ein Auto oder Motorrad an und erfasse anschließend Tanken, Wartung und weitere Kosten.',
                        action: FilledButton.icon(
                          onPressed: () => showVehicleEditor(context, ref),
                          icon: const Icon(Icons.add_rounded),
                          label: const Text('Fahrzeug anlegen'),
                        ),
                      );
                    }
                    final total = costs.fold<double>(
                      0,
                      (sum, cost) => sum + cost.amount,
                    );
                    return ListView(
                      children: [
                        MetricCard(
                          title: 'Fahrzeugkosten gesamt',
                          value: money(total),
                          caption:
                              '${costs.length} Einträge für ${items.length} Fahrzeuge',
                          icon: Icons.car_repair_rounded,
                          color: Colors.orange,
                        ),
                        const SizedBox(height: 16),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final width = constraints.maxWidth < 700
                                ? constraints.maxWidth
                                : (constraints.maxWidth - 16) / 2;
                            return Wrap(
                              spacing: 16,
                              runSpacing: 16,
                              children: [
                                for (final vehicle in items)
                                  SizedBox(
                                    width: width,
                                    child: _VehicleCard(
                                      vehicle: vehicle,
                                      costs: costs
                                          .where(
                                            (cost) =>
                                                cost.vehicleId == vehicle.id,
                                          )
                                          .toList(),
                                    ),
                                  ),
                              ],
                            );
                          },
                        ),
                        if (costs.isNotEmpty) ...[
                          const SizedBox(height: 24),
                          Text(
                            'Letzte Kosten',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 10),
                          Card(
                            child: Column(
                              children: [
                                for (final cost in costs.take(12))
                                  ListTile(
                                    leading: const CircleAvatar(
                                      child: Icon(Icons.receipt_rounded),
                                    ),
                                    title: Text(cost.category),
                                    subtitle: Text(
                                      '${DateFormat('dd.MM.yyyy').format(cost.bookingDate)}${cost.notes.isEmpty ? '' : ' · ${cost.notes}'}',
                                    ),
                                    trailing: Text(
                                      money(cost.amount),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                              ],
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
}

class _VehicleCard extends ConsumerWidget {
  const _VehicleCard({required this.vehicle, required this.costs});
  final Vehicle vehicle;
  final List<VehicleCost> costs;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final total = costs.fold<double>(0, (sum, cost) => sum + cost.amount);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  child: Icon(
                    vehicle.vehicleType == 'Motorrad'
                        ? Icons.two_wheeler_rounded
                        : Icons.directions_car_rounded,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${vehicle.make} ${vehicle.model}',
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                      Text(
                        '${vehicle.vehicleType} · ${vehicle.year}${vehicle.licensePlate.isEmpty ? '' : ' · ${vehicle.licensePlate}'}',
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) async {
                    if (value == 'edit') {
                      await showVehicleEditor(context, ref, vehicle: vehicle);
                      return;
                    }
                    if (value == 'delete') {
                      final confirmed = await confirmDelete(
                        context,
                        title: 'Fahrzeug löschen?',
                        message:
                            'Das Fahrzeug wird aus deiner Übersicht entfernt.',
                      );
                      if (!context.mounted || !confirmed) return;
                      final userId = ref.read(currentUserIdProvider);
                      if (userId != null) {
                        await ref
                            .read(databaseProvider)
                            .deleteVehicle(vehicle.id, userId);
                      }
                    }
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(value: 'edit', child: Text('Bearbeiten')),
                    PopupMenuItem(value: 'delete', child: Text('Löschen')),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 18),
            Text(
              money(total),
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
            Text(
              '${costs.length} Kosteneinträge · ${vehicle.fuelType} · ${vehicle.tankCapacity.toStringAsFixed(0)} l',
            ),
            const SizedBox(height: 16),
            FilledButton.tonalIcon(
              onPressed: () => showVehicleCostEditor(context, ref, vehicle),
              icon: const Icon(Icons.add_card_rounded),
              label: const Text('Kosten erfassen'),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> showVehicleEditor(
  BuildContext context,
  WidgetRef ref, {
  Vehicle? vehicle,
}) async {
  final result = await showDialog<VehiclesCompanion>(
    context: context,
    builder: (_) => _VehicleEditor(vehicle: vehicle),
  );
  if (result != null) await ref.read(databaseProvider).saveVehicle(result);
}

class _VehicleEditor extends StatefulWidget {
  const _VehicleEditor({this.vehicle});
  final Vehicle? vehicle;
  @override
  State<_VehicleEditor> createState() => _VehicleEditorState();
}

class _VehicleEditorState extends State<_VehicleEditor> {
  final _key = GlobalKey<FormState>();
  late final _make = TextEditingController(text: widget.vehicle?.make);
  late final _model = TextEditingController(text: widget.vehicle?.model);
  late final _plate = TextEditingController(text: widget.vehicle?.licensePlate);
  late final _year = TextEditingController(
    text: widget.vehicle?.year.toString() ?? DateTime.now().year.toString(),
  );
  late final _tank = TextEditingController(
    text: widget.vehicle?.tankCapacity.toString() ?? '50',
  );
  late String _type = widget.vehicle?.vehicleType ?? 'Auto';
  late String _fuel = widget.vehicle?.fuelType ?? 'Benzin';
  @override
  void dispose() {
    _make.dispose();
    _model.dispose();
    _plate.dispose();
    _year.dispose();
    _tank.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(
      widget.vehicle == null ? 'Fahrzeug anlegen' : 'Fahrzeug bearbeiten',
    ),
    content: SizedBox(
      width: 520,
      child: Form(
        key: _key,
        child: SingleChildScrollView(
          child: Column(
            children: [
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(
                    value: 'Auto',
                    icon: Icon(Icons.directions_car_rounded),
                    label: Text('Auto'),
                  ),
                  ButtonSegment(
                    value: 'Motorrad',
                    icon: Icon(Icons.two_wheeler_rounded),
                    label: Text('Motorrad'),
                  ),
                ],
                selected: {_type},
                onSelectionChanged: (value) =>
                    setState(() => _type = value.first),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _requiredField(_make, 'Marke')),
                  const SizedBox(width: 12),
                  Expanded(child: _requiredField(_model, 'Modell')),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _plate,
                decoration: const InputDecoration(labelText: 'Kennzeichen'),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _year,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Baujahr'),
                      validator: (value) {
                        final year = int.tryParse(value ?? '');
                        return year == null ||
                                year < 1886 ||
                                year > DateTime.now().year + 1
                            ? 'Ungültig'
                            : null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _fuel,
                      decoration: const InputDecoration(
                        labelText: 'Kraftstoff',
                      ),
                      items:
                          const [
                                'Benzin',
                                'Diesel',
                                'Elektro',
                                'Hybrid',
                                'Gas',
                                'Sonstiges',
                              ]
                              .map(
                                (v) =>
                                    DropdownMenuItem(value: v, child: Text(v)),
                              )
                              .toList(),
                      onChanged: (value) => _fuel = value ?? 'Benzin',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _tank,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Tank / Akku',
                      ),
                      validator: (value) =>
                          _number(value) == null ? 'Ungültig' : null,
                    ),
                  ),
                ],
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

  Widget _requiredField(TextEditingController controller, String label) =>
      TextFormField(
        controller: controller,
        decoration: InputDecoration(labelText: label),
        validator: (value) =>
            (value?.trim().isEmpty ?? true) ? 'Pflichtfeld' : null,
      );
  double? _number(String? value) =>
      double.tryParse((value ?? '').replaceAll(',', '.'));
  void _save() {
    if (!(_key.currentState?.validate() ?? false)) return;
    final userId = ProviderScope.containerOf(
      context,
      listen: false,
    ).read(currentUserIdProvider);
    if (userId == null) return;
    final now = DateTime.now().toUtc();
    Navigator.pop(
      context,
      VehiclesCompanion.insert(
        id: widget.vehicle?.id ?? const Uuid().v4(),
        userId: userId,
        vehicleType: _type,
        make: _make.text.trim(),
        model: _model.text.trim(),
        licensePlate: Value(_plate.text.trim().toUpperCase()),
        year: int.parse(_year.text),
        fuelType: Value(_fuel),
        tankCapacity: Value(_number(_tank.text) ?? 0),
        createdAt: widget.vehicle?.createdAt ?? now,
        updatedAt: now,
      ),
    );
  }
}

Future<void> showVehicleCostEditor(
  BuildContext context,
  WidgetRef ref,
  Vehicle vehicle,
) async {
  final result = await showDialog<VehicleCostsCompanion>(
    context: context,
    builder: (_) => _CostEditor(vehicle: vehicle),
  );
  if (result != null) await ref.read(databaseProvider).saveVehicleCost(result);
}

class _CostEditor extends StatefulWidget {
  const _CostEditor({required this.vehicle});
  final Vehicle vehicle;
  @override
  State<_CostEditor> createState() => _CostEditorState();
}

class _CostEditorState extends State<_CostEditor> {
  final _key = GlobalKey<FormState>();
  final _amount = TextEditingController();
  final _odometer = TextEditingController();
  final _notes = TextEditingController();
  String _category = 'Tanken';
  DateTime _date = DateTime.now();
  @override
  void dispose() {
    _amount.dispose();
    _odometer.dispose();
    _notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text('Kosten · ${widget.vehicle.make} ${widget.vehicle.model}'),
    content: SizedBox(
      width: 480,
      child: Form(
        key: _key,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              initialValue: _category,
              decoration: const InputDecoration(labelText: 'Kostenart'),
              items: const [
                'Tanken',
                'Laden',
                'Reparatur',
                'Wartung',
                'TÜV',
                'Versicherung',
                'Steuer',
                'Reifen',
                'Ölwechsel',
                'Sonstiges',
              ].map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
              onChanged: (value) => _category = value ?? 'Sonstiges',
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _amount,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Betrag',
                prefixText: '€ ',
              ),
              validator: (value) =>
                  (_number(value) ?? 0) <= 0 ? 'Ungültiger Betrag' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _odometer,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Kilometerstand (optional)',
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _notes,
              decoration: const InputDecoration(labelText: 'Notizen'),
              maxLines: 2,
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _pickDate,
              icon: const Icon(Icons.calendar_month_rounded),
              label: Text(DateFormat('dd.MM.yyyy').format(_date)),
            ),
          ],
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
  double? _number(String? value) =>
      double.tryParse((value ?? '').replaceAll(',', '.'));
  Future<void> _pickDate() async {
    final value = await showDatePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDate: _date,
    );
    if (value != null) setState(() => _date = value);
  }

  void _save() {
    if (!(_key.currentState?.validate() ?? false)) return;
    final userId = ProviderScope.containerOf(
      context,
      listen: false,
    ).read(currentUserIdProvider);
    if (userId == null) return;
    final now = DateTime.now().toUtc();
    Navigator.pop(
      context,
      VehicleCostsCompanion.insert(
        id: const Uuid().v4(),
        userId: userId,
        vehicleId: widget.vehicle.id,
        bookingDate: _date,
        category: _category,
        amount: _number(_amount.text) ?? 0,
        odometer: Value(_number(_odometer.text)),
        notes: Value(_notes.text.trim()),
        createdAt: now,
        updatedAt: now,
      ),
    );
  }
}
