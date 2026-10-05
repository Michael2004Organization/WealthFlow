import 'dart:convert';

import 'package:shelf/shelf.dart';
import 'package:wealthflow_core/database/app_database.dart';

/// Version shown by `/api/health`; the app compares it before syncing.
const serverVersion = '1.0.0';

/// Builds the request handler of the server.
Handler buildHandler({required AppDatabase database}) {
  return const Pipeline()
      .addMiddleware(_securityHeaders())
      .addHandler((request) => _route(request, database));
}

Future<Response> _route(Request request, AppDatabase database) async {
  final path = '/${request.url.path}';
  if (path == '/api/health' && request.method == 'GET') {
    return jsonResponse({
      'status': 'ok',
      'version': serverVersion,
      'schemaVersion': database.schemaVersion,
    });
  }
  return jsonResponse({'error': 'Nicht gefunden'}, status: 404);
}

Response jsonResponse(Object body, {int status = 200}) => Response(
  status,
  body: jsonEncode(body),
  headers: {'content-type': 'application/json; charset=utf-8'},
);

Middleware _securityHeaders() =>
    (inner) => (request) async {
      final response = await inner(request);
      return response.change(
        headers: {
          'strict-transport-security': 'max-age=31536000',
          'x-content-type-options': 'nosniff',
          'referrer-policy': 'no-referrer',
          'cache-control': 'no-store',
        },
      );
    };
