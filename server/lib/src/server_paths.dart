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
  static Directory defaultRoot() =>
      Directory('${_programBase().path}${Platform.pathSeparator}daten');

  /// Built web app: `web` next to the program.
  static Directory defaultWebRoot() =>
      Directory('${_programBase().path}${Platform.pathSeparator}web');

  static Directory _programBase() {
    final executable = File(Platform.resolvedExecutable);
    final programDirectory = executable.parent;
    // The release bundle keeps the exe in `bin`; data goes next to start.cmd.
    return programDirectory.uri.pathSegments
                .where((segment) => segment.isNotEmpty)
                .lastOrNull
                ?.toLowerCase() ==
            'bin'
        ? programDirectory.parent
        : programDirectory;
  }
}
