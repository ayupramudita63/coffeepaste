import '../../../shared/models/category_model.dart';
import '../../../shared/models/product_model.dart';
import 'menu_repository.dart';
import 'mock_menu_data.dart';

/// Repository palsu: data dari memori, dengan jeda kecil agar loading terlihat.
class MockMenuRepository implements MenuRepository {
  final Duration latency;

  MockMenuRepository({this.latency = const Duration(milliseconds: 600)});

  @override
  Future<List<ProductModel>> fetchProducts() async {
    await Future<void>.delayed(latency);
    return MockMenuData.products();
  }

  @override
  Future<List<CategoryModel>> fetchCategories() async {
    await Future<void>.delayed(latency);
    return MockMenuData.categories;
  }
}
