class ApiConfig {
  ApiConfig._();

  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://coffeepastebackendnew-production.up.railway.app/api',
  );

  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 20);
  static const Duration sendTimeout = Duration(seconds: 20);

  static Uri get _baseUri => Uri.parse(baseUrl);

  static String? resolveImageUrl(String? raw) {
    if (raw == null) return null;
    final value = raw.trim();
    if (value.isEmpty) return null;

    if (value.startsWith('assets/')) return value;

    if (value.startsWith('http://') || value.startsWith('https://')) {
      final uri = Uri.tryParse(value);
      if (uri == null) return value;
      const localHosts = {'localhost', '127.0.0.1', '0.0.0.0'};
      if (localHosts.contains(uri.host)) {
        return uri
            .replace(
              scheme: _baseUri.scheme,
              host: _baseUri.host,
              port: _baseUri.hasPort ? _baseUri.port : null,
            )
            .toString();
      }
      return value;
    }

    final origin = _baseUri.origin;
    return value.startsWith('/') ? '$origin$value' : '$origin/$value';
  }
}
