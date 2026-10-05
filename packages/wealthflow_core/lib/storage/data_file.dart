import 'dart:io';

/// Daily copies of the data file that are kept next to it.
const dataFileGenerations = 7;

/// Writes [content] to a temporary file first and only then replaces [path],
/// so a crash or a full disk never leaves a half-written data file behind.
/// Before the first write of a new day the previous file is kept as a dated
/// copy; only the newest [dataFileGenerations] copies remain.
Future<bool> writeDataFile(String content, String path) async {
  if (path.trim().isEmpty) return false;
  final target = File(path);
  final temp = File('$path.tmp');
  await temp.writeAsString(content, flush: true);
  if (await target.exists()) {
    await _keepDailyCopy(target);
  }
  await temp.rename(path);
  return true;
}

Future<void> _keepDailyCopy(File target) async {
  final modified = await target.lastModified();
  final now = DateTime.now();
  if (modified.year == now.year &&
      modified.month == now.month &&
      modified.day == now.day) {
    return;
  }
  final name = target.uri.pathSegments.last;
  final dot = name.lastIndexOf('.');
  final stem = dot <= 0 ? name : name.substring(0, dot);
  final extension = dot <= 0 ? '' : name.substring(dot);
  String two(int value) => value.toString().padLeft(2, '0');
  final day = '${modified.year}-${two(modified.month)}-${two(modified.day)}';
  final directory = target.parent;
  final separator = Platform.pathSeparator;
  await target.copy('${directory.path}$separator$stem.$day$extension');
  final pattern = RegExp(
    '^${RegExp.escape(stem)}\\.\\d{4}-\\d{2}-\\d{2}${RegExp.escape(extension)}\$',
  );
  final copies =
      directory
          .listSync()
          .whereType<File>()
          .where((file) => pattern.hasMatch(file.uri.pathSegments.last))
          .toList()
        ..sort(
          (a, b) => a.uri.pathSegments.last.compareTo(b.uri.pathSegments.last),
        );
  for (final old in copies.take(
    (copies.length - dataFileGenerations).clamp(0, copies.length),
  )) {
    await old.delete();
  }
}
