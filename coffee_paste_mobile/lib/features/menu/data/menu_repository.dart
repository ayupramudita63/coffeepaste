import '../../../shared/models/category_model.dart';
import '../../../shared/models/product_model.dart';

/// Kontrak data menu. UI/provider hanya tahu kelas ini, sehingga sumber data
/// (mock atau API) bisa diganti tanpa mengubah UI.
abstract class MenuRepository {
  Future<List<ProductModel>> fetchProducts();

  Future<List<CategoryModel>> fetchCategories();
}
