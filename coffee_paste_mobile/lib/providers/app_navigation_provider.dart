import 'package:flutter/foundation.dart';

/// Menyimpan tab yang aktif dan kategori yang dipilih di Menu,
/// supaya Home dan Menu selalu sinkron.
class AppNavigationProvider extends ChangeNotifier {
  /// Posisi tab Pesanan pada bottom navigation.
  static const int ordersTab = 2;

  int _tabIndex = 0;
  String _menuCategoryId = 'all';

  int get tabIndex => _tabIndex;
  String get menuCategoryId => _menuCategoryId;

  void setTab(int index) {
    if (_tabIndex == index) return;
    _tabIndex = index;
    notifyListeners();
  }

  void setMenuCategory(String categoryId) {
    if (_menuCategoryId == categoryId) return;
    _menuCategoryId = categoryId;
    notifyListeners();
  }

  /// Pindah ke tab Menu (index 1), opsional sambil memilih kategori.
  void openMenu({String? categoryId}) {
    if (categoryId != null) _menuCategoryId = categoryId;
    _tabIndex = 1;
    notifyListeners();
  }
}