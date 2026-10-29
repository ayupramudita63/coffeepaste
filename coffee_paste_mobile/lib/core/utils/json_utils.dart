/// Helper parsing JSON yang toleran terhadap perbedaan tipe
/// (misalnya harga datang sebagai `22000`, `22000.0`, atau `"22000.00"`).
class JsonUtils {
  JsonUtils._();

  /// Ambil nilai dari key pertama yang ada dan tidak null.
  static dynamic pick(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value != null) return value;
    }
    return null;
  }

  static String asString(dynamic value, {String fallback = ''}) {
    if (value == null) return fallback;
    final text = value.toString().trim();
    return text.isEmpty ? fallback : text;
  }

  static String? asNullableString(dynamic value) {
    if (value == null) return null;
    final text = value.toString().trim();
    return text.isEmpty ? null : text;
  }

  static int asInt(dynamic value, {int fallback = 0}) {
    if (value is int) return value;
    if (value is num) return value.round();
    if (value is String) {
      final parsed = double.tryParse(value.trim());
      if (parsed != null) return parsed.round();
    }
    return fallback;
  }

  static double asDouble(dynamic value, {double fallback = 0}) {
    if (value is num) return value.toDouble();
    if (value is String) {
      return double.tryParse(value.trim()) ?? fallback;
    }
    return fallback;
  }

  static bool? asNullableBool(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      final text = value.trim().toLowerCase();
      if (text == 'true' || text == '1') return true;
      if (text == 'false' || text == '0') return false;
    }
    return null;
  }

  static DateTime? asDateTime(dynamic value) {
    if (value is DateTime) return value;
    if (value is String && value.trim().isNotEmpty) {
      return DateTime.tryParse(value.trim())?.toLocal();
    }
    return null;
  }

  static Map<String, dynamic>? asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return null;
  }

  /// Menerima list langsung, atau object yang membungkus list
  /// (`{"items": [...]}`, `{"menus": [...]}`, dst).
  static List<Map<String, dynamic>> asMapList(
    dynamic value, {
    List<String> wrapperKeys = const [],
  }) {
    dynamic source = value;

    if (source is Map) {
      source = null;
      for (final key in wrapperKeys) {
        if (value[key] is List) {
          source = value[key];
          break;
        }
      }
    }

    if (source is! List) return const [];

    return source
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }
}
