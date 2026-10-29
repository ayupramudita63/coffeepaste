import '../../core/utils/option_labels.dart';
import '../../shared/models/product_model.dart';
import 'models/order_model.dart';

/// Satu baris yang akan dimasukkan ke keranjang.
class ReorderLine {
  final ProductModel product;
  final int quantity;
  final String? ice;
  final String? sugar;
  final String? size;

  const ReorderLine({
    required this.product,
    required this.quantity,
    this.ice,
    this.sugar,
    this.size,
  });
}

/// Hasil menyalin pesanan lama ke keranjang ("Pesan Lagi").
///
/// Harga selalu dari menu saat ini (bukan harga pesanan lama). Menu yang sudah
/// dihapus atau sedang habis dilewati dan namanya dicatat di [unavailableNames].
class ReorderPlan {
  final List<ReorderLine> lines;
  final List<String> unavailableNames;

  const ReorderPlan({required this.lines, required this.unavailableNames});

  factory ReorderPlan.from(OrderModel order, List<ProductModel> menu) {
    final byId = {for (final product in menu) product.id: product};
    final lines = <ReorderLine>[];
    final unavailable = <String>[];

    for (final item in order.items) {
      final product = item.menuItemId == null ? null : byId[item.menuItemId];

      if (product == null || !product.isAvailable) {
        if (!unavailable.contains(item.name)) unavailable.add(item.name);
        continue;
      }

      final isDrink = product.isDrink;
      lines.add(
        ReorderLine(
          product: product,
          quantity: item.quantity,
          // Minuman selalu punya pilihan; data lama tanpa pilihan memakai default.
          ice: isDrink ? (OptionLabels.cartIce(item.ice) ?? 'Normal') : null,
          sugar:
              isDrink ? (OptionLabels.cartSugar(item.sugar) ?? 'Normal') : null,
          size: isDrink ? (item.size ?? 'Regular') : null,
        ),
      );
    }

    return ReorderPlan(lines: lines, unavailableNames: unavailable);
  }
}
