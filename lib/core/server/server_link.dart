/// The server a local account is connected to, stored per local user.
final class ServerLink {
  const ServerLink({
    required this.baseUrl,
    required this.fingerprint,
    required this.deviceId,
    required this.serverUserId,
    required this.email,
    required this.displayName,
  });

  /// For example `https://meinpc:8443`.
  final String baseUrl;

  /// SHA-256 fingerprint of the server certificate; the only certificate the
  /// app accepts for this server. Empty on the web, where the browser checks.
  final String fingerprint;
  final String deviceId;
  final String serverUserId;
  final String email;
  final String displayName;

  Map<String, Object?> toJson() => {
    'baseUrl': baseUrl,
    'fingerprint': fingerprint,
    'deviceId': deviceId,
    'serverUserId': serverUserId,
    'email': email,
    'displayName': displayName,
  };

  static ServerLink? fromJson(Object? json) {
    if (json is! Map) return null;
    final values = Map<String, Object?>.from(json);
    String? text(String key) =>
        values[key] is String ? values[key] as String : null;
    final baseUrl = text('baseUrl'), deviceId = text('deviceId');
    final serverUserId = text('serverUserId');
    if (baseUrl == null || deviceId == null || serverUserId == null) {
      return null;
    }
    return ServerLink(
      baseUrl: baseUrl,
      fingerprint: text('fingerprint') ?? '',
      deviceId: deviceId,
      serverUserId: serverUserId,
      email: text('email') ?? '',
      displayName: text('displayName') ?? '',
    );
  }
}

/// Port the server listens on unless the address names another one.
const defaultServerPort = 8443;

/// Turns what the user typed (`meinpc`, `192.168.178.20:8443`,
/// `https://meinpc:8443/`) into the server's base URL; null when unusable.
Uri? parseServerAddress(String input) {
  var text = input.trim();
  if (text.isEmpty) return null;
  if (text.startsWith('http://')) return null;
  if (!text.startsWith('https://')) text = 'https://$text';
  final uri = Uri.tryParse(text);
  if (uri == null || uri.host.isEmpty) return null;
  return Uri(
    scheme: 'https',
    host: uri.host,
    port: uri.hasPort ? uri.port : defaultServerPort,
  );
}
