import 'dart:io';

import 'package:shelf/shelf.dart';

/// Headers for the web version. COOP/COEP give the browser database its
/// fast mode; the CSP only allows code from this server. Flutter loads
/// missing fallback fonts from Google, everything else comes from here.
const webAppHeaders = {
  'cross-origin-opener-policy': 'same-origin',
  'cross-origin-embedder-policy': 'require-corp',
  'cross-origin-resource-policy': 'same-origin',
  'x-frame-options': 'DENY',
  'content-security-policy':
      "default-src 'self'; "
      "script-src 'self' 'wasm-unsafe-eval'; "
      "style-src 'self' 'unsafe-inline'; "
      "img-src 'self' data: blob:; "
      "font-src 'self' data: https://fonts.gstatic.com; "
      "connect-src 'self' https://fonts.gstatic.com; "
      "worker-src 'self' blob:; "
      "object-src 'none'; base-uri 'self'; frame-ancestors 'none'",
};

const _contentTypes = {
  'html': 'text/html; charset=utf-8',
  'js': 'text/javascript; charset=utf-8',
  'mjs': 'text/javascript; charset=utf-8',
  'json': 'application/json; charset=utf-8',
  'wasm': 'application/wasm',
  'css': 'text/css; charset=utf-8',
  'png': 'image/png',
  'jpg': 'image/jpeg',
  'svg': 'image/svg+xml',
  'ico': 'image/x-icon',
  'ttf': 'font/ttf',
  'otf': 'font/otf',
  'woff2': 'font/woff2',
  'bin': 'application/octet-stream',
  'frag': 'application/octet-stream',
  'symbols': 'text/plain; charset=utf-8',
};

/// Serves the built web app from [directory] (the `web` folder next to
/// `start.cmd`). Unknown paths get `index.html`, so reloading a page works.
final class WebApp {
  WebApp(this.directory);

  final Directory directory;

  bool get isAvailable => File(_join('index.html')).existsSync();

  String _join(String relative) =>
      '${directory.path}${Platform.pathSeparator}'
      '${relative.replaceAll('/', Platform.pathSeparator)}';

  Future<Response> serve(Request request) async {
    final segments = request.url.pathSegments;
    // No way out of the folder: no "..", no hidden files, no backslashes.
    final unsafe = segments.any(
      (segment) =>
          segment.startsWith('.') ||
          segment.contains(r'\') ||
          segment.contains(':'),
    );
    if (unsafe) return Response.notFound('Nicht gefunden');
    var relative = segments.isEmpty ? 'index.html' : segments.join('/');
    var file = File(_join(relative));
    if (!await file.exists()) {
      // Files with an extension really are missing; app routes are not.
      if (segments.isNotEmpty && segments.last.contains('.')) {
        return Response.notFound('Nicht gefunden');
      }
      relative = 'index.html';
      file = File(_join(relative));
      if (!await file.exists()) return Response.notFound('Nicht gefunden');
    }
    final extension = relative.split('.').last.toLowerCase();
    final bytes = await file.readAsBytes();
    return Response.ok(
      request.method == 'HEAD' ? null : bytes,
      headers: {
        ...webAppHeaders,
        'content-type': _contentTypes[extension] ?? 'application/octet-stream',
        'content-length': '${bytes.length}',
      },
    );
  }
}
