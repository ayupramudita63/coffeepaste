class ApiConfig {
  ApiConfig._();

  /// Alamat backend Go (PORT di .env backend, default 8000). Ubah lewat:
  /// flutter run --dart-define=API_BASE_URL=http://192.168.1.10:8000/api
  ///
  /// Default 10.0.2.2 = localhost komputer jika dijalankan di emulator Android.
  /// HP fisik: pakai IP laptop di jaringan yang sama. Produksi (Railway):
  /// --dart-define=API_BASE_URL=https://coffeepaste-production.up.railway.app/api
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8000/api',
  );

  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 20);
  static const Duration sendTimeout = Duration(seconds: 20);

  static Uri get _baseUri => Uri.parse(baseUrl);

  /// Mengubah path gambar dari backend menjadi URL yang bisa dimuat.
  ///
  /// - kosong            -> null
  /// - assets/...        -> dibiarkan (gambar lokal)
  /// - /uploads/a.jpg    -> http://host:port/uploads/a.jpg
  /// - http://localhost  -> host diganti agar bisa diakses dari emulator/HP
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
