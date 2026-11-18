import '../../shared/models/product_model.dart';

class CartItemModel {
  final ProductModel product;
  final String? ice;
  final String? sugar;
  final String? size;
  int quantity;

  CartItemModel({
    required this.product,
    this.ice,
    this.sugar,
    this.size,
    this.quantity = 1,
  });

  /// Kunci unik: produk sama dengan pilihan berbeda = baris berbeda.
  String get key => '${product.id}|${ice ?? ''}|${sugar ?? ''}|${size ?? ''}';

  /// Harga satuan sesuai ukuran yang dipilih (Regular / Large).
  int get unitPrice => product.priceFor(size);

  int get subtotal => unitPrice * quantity;

  List<String> get optionParts {
    final parts = <String>[];
    if (size != null) parts.add(size!);
    if (ice != null) parts.add(ice == 'Normal' ? 'Normal Ice' : ice!);
    if (sugar != null) parts.add(sugar == 'Normal' ? 'Normal Sugar' : sugar!);
    return parts;
  }

  String get optionsSummary => optionParts.join('  |  ');
}