import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/utils/json_utils.dart';
import '../../../shared/models/category_model.dart';
import '../../../shared/models/product_model.dart';
import 'menu_repository.dart';

class ApiMenuRepository implements MenuRepository {
  final ApiClient _client;

  ApiMenuRepository(this._client);

  @override
  Future<List<ProductModel>> fetchProducts() async {
    final body = await _client.get(ApiEndpoints.menus);

    return JsonUtils.asMapList(
      body,
      wrapperKeys: const ['items', 'menus', 'products'],
    ).map(ProductModel.fromJson).toList();
  }

  @override
  Future<List<CategoryModel>> fetchCategories() async {
    final body = await _client.get(ApiEndpoints.categories);

    return JsonUtils.asMapList(
      body,
      wrapperKeys: const ['items', 'categories'],
    ).map(CategoryModel.fromJson).toList();
  }
}
