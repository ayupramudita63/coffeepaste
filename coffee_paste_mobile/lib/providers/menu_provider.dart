import '../features/menu/data/menu_repository.dart';
import '../shared/models/category_model.dart';
import '../shared/models/product_model.dart';
import 'base_provider.dart';

class MenuProvider extends BaseProvider {
  static const int _homeSectionLimit = 4;

  final MenuRepository _repository;

  MenuProvider(this._repository);

  List<ProductModel> _products = const [];
  List<CategoryModel> _categories = const [CategoryModel.all];

  List<ProductModel> get products => List.unmodifiable(_products);

  /// Selalu diawali kategori "Semua".
  List<CategoryModel> get categories => List.unmodifiable(_categories);

  bool get hasData => _products.isNotEmpty;

  /// Memuat menu + kategori. Aman dipanggil berulang (refresh).
  Future<void> loadMenu() async {
    if (isLoading) return;
    setLoading();

    try {
      final products = await _repository.fetchProducts();

      // Kategori gagal dimuat bukan error fatal: dibentuk dari data produk.
      List<CategoryModel> categories = const [];
      try {
        categories = await _repository.fetchCategories();
      } catch (_) {}

      _products = products;
      _categories = [
        CategoryModel.all,
        ...(categories.isNotEmpty ? categories : _categoriesFrom(products)),
      ];
      setSuccess();
    } catch (error) {
      setError(error);
    }
  }

  /// Memperbarui daftar produk (mis. rating baru setelah ulasan dikirim) tanpa
  /// memunculkan loading. Gagal = diam, data lama tetap dipakai.
  Future<void> refreshQuietly() async {
    if (isLoading) return;
    try {
      final products = await _repository.fetchProducts();
      _products = products;
      notifyListeners();
    } catch (_) {}
  }

  List<ProductModel> productsByCategory(String categoryId) {
    if (categoryId == CategoryModel.allId) return products;
    return _products.where((p) => p.categoryId == categoryId).toList();
  }

  /// Menu populer: rating terbanyak.
  List<ProductModel> get popularProducts {
    final sorted = [..._products]..sort((a, b) {
        final byCount = b.ratingCount.compareTo(a.ratingCount);
        return byCount != 0 ? byCount : b.rating.compareTo(a.rating);
      });
    return sorted;
  }

  List<ProductModel> get bestSellerProducts =>
      popularProducts.take(_homeSectionLimit).toList();

  /// Menu terbaru: berdasarkan created_at, atau urutan terakhir dari server.
  List<ProductModel> get newProducts {
    final hasDates = _products.every((p) => p.createdAt != null);
    final sorted = hasDates
        ? ([..._products]..sort((a, b) => b.createdAt!.compareTo(a.createdAt!)))
        : _products.reversed.toList();
    return sorted.take(_homeSectionLimit).toList();
  }

  List<ProductModel> search(String query) {
    final text = query.trim().toLowerCase();
    if (text.isEmpty) return const [];
    return _products
        .where((product) => product.name.toLowerCase().contains(text))
        .toList();
  }

  List<CategoryModel> _categoriesFrom(List<ProductModel> products) {
    final seen = <String, CategoryModel>{};
    for (final product in products) {
      if (product.categoryId == CategoryModel.allId) continue;
      seen.putIfAbsent(
        product.categoryId,
        () => CategoryModel(
          id: product.categoryId,
          label: product.categoryName ?? product.categoryId,
          iconKey: CategoryModel.iconKeyFromName(
            product.categoryName ?? product.categoryId,
          ),
        ),
      );
    }
    return seen.values.toList();
  }
}
