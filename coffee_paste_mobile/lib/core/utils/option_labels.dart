/// Penerjemah pilihan minuman antara label di layar dan nilai di backend.
///
/// Layar: "Less Ice", "No Ice", "Less Sugar", "No Sugar", "Normal".
/// Backend: "Normal" | "Less" | "No" (ukuran: "Regular" | "Large", sama).
class OptionLabels {
  OptionLabels._();

  /// Label layar -> nilai backend. null tetap null (item bukan minuman).
  static String? toApiLevel(String? label) {
    if (label == null) return null;
    final text = label.trim().toLowerCase();
    if (text.isEmpty) return null;
    if (text.contains('less')) return 'Less';
    if (text == 'no' || text.startsWith('no ')) return 'No';
    return 'Normal';
  }

  /// Nilai backend -> label pilihan di layar detail produk dan keranjang:
  /// "Normal" / "Less Ice" / "No Ice" (gula: "Normal" / "Less Sugar" / "No Sugar").
  /// null tetap null. Dipakai saat "Pesan Lagi" mengisi ulang keranjang.
  static String? cartIce(String? raw) => _cartLabel(raw, 'Ice');

  static String? cartSugar(String? raw) => _cartLabel(raw, 'Sugar');

  static String? _cartLabel(String? raw, String noun) {
    final text = raw?.trim().toLowerCase() ?? '';
    if (text.isEmpty) return null;
    if (text == 'less') return 'Less $noun';
    if (text == 'no') return 'No $noun';
    return 'Normal';
  }

  /// Nilai backend -> label layar untuk es. Nilai tak dikenal dibiarkan.
  static String iceLabel(String raw) => _label(raw, 'Ice');

  /// Nilai backend -> label layar untuk gula.
  static String sugarLabel(String raw) => _label(raw, 'Sugar');

  static String _label(String raw, String noun) {
    switch (raw.trim().toLowerCase()) {
      case 'normal':
        return 'Normal $noun';
      case 'less':
        return 'Less $noun';
      case 'no':
        return 'No $noun';
      default:
        return raw;
    }
  }
}
