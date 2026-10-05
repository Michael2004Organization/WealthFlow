import 'dart:io';

/// Everything the server writes lives below one data directory, so deleting
/// the server folder removes it completely.
final class ServerPaths {
  ServerPaths(this.root);

  final Directory root;

  String _child(String name) => '${root.path}${Platform.pathSeparator}$name';

  File get database => File(_child('wealthflow-server.sqlite'));
  Directory get certificates => Directory(_child('zertifikat'));
  File get settings => File(_child('einstellungen.json'));

  /// Default data directory: `daten` next to the program.
  static Directory defaultRoot() {
    final executable = File(Platform.resolvedExecutable);
    final programDirectory = executable.parent;
    // The release bundle keeps the exe in `bin`; data goes next to start.cmd.
    final base =
        programDirectory.uri.pathSegments
                .where((segment) => segment.isNotEmpty)
                .lastOrNull
                ?.toLowerCase() ==
            'bin'
        ? programDirectory.parent
        : programDirectory;
    return Directory('${base.path}${Platform.pathSeparator}daten');
  }
}
