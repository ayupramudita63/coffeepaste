import 'package:flutter/material.dart';
import '../features/cart/cart_item_model.dart';
import '../shared/models/product_model.dart';
import '../core/constants/app_constants.dart';

class CartProvider extends ChangeNotifier {
  final List<CartItemModel> _items = [];

  List<CartItemModel> get items => List.unmodifiable(_items);

  bool get isEmpty => _items.isEmpty;

  int get totalItemCount =>
      _items.fold(0, (sum, item) => sum + item.quantity);

   int get totalPrice =>
      _items.fold(0, (sum, item) => sum + item.subtotal);

  /// Nominal pajak (PPN), dibulatkan ke rupiah terdekat
  int get taxAmount => (totalPrice * AppConstants.taxRate).round();

  /// Total akhir yang harus dibayar (subtotal + pajak)
  int get grandTotal => totalPrice + taxAmount;

  void addItem({
    required ProductModel product,
    int quantity = 1,
    String? ice,
    String? sugar,
    String? size,
  }) {
    final newItem = CartItemModel(
      product: product,
      ice: ice,
      sugar: sugar,
      size: size,
      quantity: quantity,
    );

    final index = _items.indexWhere((item) => item.key == newItem.key);
    if (index != -1) {
      _items[index].quantity += quantity;
    } else {
      _items.add(newItem);
    }
    notifyListeners();
  }

  void increaseQuantity(String key) {
    final index = _items.indexWhere((item) => item.key == key);
    if (index == -1) return;
    _items[index].quantity++;
    notifyListeners();
  }

  /// Kalau jumlah sudah 1, item dihapus dari keranjang.
  void decreaseQuantity(String key) {
    final index = _items.indexWhere((item) => item.key == key);
    if (index == -1) return;
    if (_items[index].quantity > 1) {
      _items[index].quantity--;
    } else {
      _items.removeAt(index);
    }
    notifyListeners();
  }

  void removeItem(String key) {
    _items.removeWhere((item) => item.key == key);
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}