/// One part of the wealth split, with an optional target share.
class AllocationSlice {
  const AllocationSlice({
    required this.label,
    required this.value,
    required this.share,
    this.target,
    this.toBuy = 0,
  });

  final String label;
  final double value;

  /// Part of the total, 0 to 1.
  final double share;

  /// Target share, 0 to 1, when the user set one.
  final double? target;

  /// Amount to buy so the part reaches its target without selling anything
  /// else; 0 when it is at or above target.
  final double toBuy;
}

/// Splits [values] into shares, largest first, and compares them with
/// [targets] (label → share in percent). Parts that only have a target are
/// listed with a value of 0.
List<AllocationSlice> buildAllocation(
  Map<String, double> values, {
  Map<String, double> targets = const {},
}) {
  final positive = {
    for (final MapEntry(:key, :value) in values.entries)
      if (value > 0) key: value,
  };
  final total = positive.values.fold(0.0, (sum, value) => sum + value);
  final labels = {...positive.keys, ...targets.keys};
  final slices = [
    for (final label in labels)
      () {
        final value = positive[label] ?? 0;
        final target = targets[label] == null ? null : targets[label]! / 100;
        // Buying x lifts the total too: (value + x) / (total + x) = target.
        final gap = target == null || target >= 1
            ? 0.0
            : (target * total - value) / (1 - target);
        return AllocationSlice(
          label: label,
          value: value,
          share: total <= 0 ? 0 : value / total,
          target: target,
          toBuy: gap > 0.005 ? gap : 0,
        );
      }(),
  ]..sort((a, b) => b.value.compareTo(a.value));
  return slices;
}

/// Targets are kept as master data entries "Klasse=40".
const allocationTargetKind = 'allocationTarget';

Map<String, double> parseAllocationTargets(Iterable<String> values) => {
  for (final value in values)
    if (value.lastIndexOf('=') case final index when index > 0)
      value.substring(0, index): ?double.tryParse(value.substring(index + 1)),
};
