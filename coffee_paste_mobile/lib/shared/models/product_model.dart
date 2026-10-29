import '../../core/network/api_config.dart';
import '../../core/utils/json_utils.dart';
import 'category_model.dart';

class ProductModel {
  final String id;
  final String name;
  final int price;
  final double rating;
  final int ratingCount;
  final String? imageUrl;
  final bool isAvailable;
  final String description;
  final String categoryId;
  final String? categoryName;
  final DateTime? createdAt;

  const ProductModel({
    required this.id,
    required this.name,
    required this.price,
    this.rating = 0,
    this.ratingCount = 0,
    this.imageUrl,
    this.isAvailable = true,
    this.description = '',
    this.categoryId = 'all',
    this.categoryName,
    this.createdAt,
  });

  /// Minuman (kopi / non kopi) punya pilihan es, gula, dan ukuran.
  /// Dihitung dari nama kategori karena id kategori dari backend berupa slug
  /// (mis. "minuman-kopi"). Aturan akhir tetap di backend (is_customizable).
  bool get isDrink {
    final key = CategoryModel.iconKeyFromName(categoryName ?? categoryId);
    return key == 'coffee' || key == 'non_coffee';
  }

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    final categoryRaw = json['category'];
    final categoryMap = JsonUtils.asMap(categoryRaw);

    final categoryName = JsonUtils.asNullableString(
      categoryMap != null
          ? JsonUtils.pick(categoryMap, ['name', 'nama'])
          : (categoryRaw is String
              ? categoryRaw
              : JsonUtils.pick(json, ['category_name', 'categoryName'])),
    );

    final categoryId = JsonUtils.asString(
      JsonUtils.pick(json, ['category_id', 'categoryId']) ??
          categoryMap?['id'],
      fallback: categoryName ?? 'all',
    );

    return ProductModel(
      id: JsonUtils.asString(JsonUtils.pick(json, ['id', 'menu_id'])),
      name: JsonUtils.asString(
        JsonUtils.pick(json, ['name', 'nama']),
        fallback: 'Tanpa nama',
      ),
      price: JsonUtils.asInt(JsonUtils.pick(json, ['price', 'harga'])),
      rating: JsonUtils.asDouble(json['rating']),
      ratingCount: JsonUtils.asInt(
        JsonUtils.pick(json, ['rating_count', 'ratingCount', 'reviews']),
      ),
      imageUrl: ApiConfig.resolveImageUrl(
        JsonUtils.asNullableString(
          JsonUtils.pick(json, [
            'image_url',
            'imageUrl',
            'image',
            'photo',
            'foto',
          ]),
        ),
      ),
      isAvailable: _parseAvailability(json),
      description: JsonUtils.asString(
        JsonUtils.pick(json, ['description', 'deskripsi']),
      ),
      categoryId: categoryId,
      categoryName: categoryName,
      createdAt: JsonUtils.asDateTime(
        JsonUtils.pick(json, ['created_at', 'createdAt']),
      ),
    );
  }

  static bool _parseAvailability(Map<String, dynamic> json) {
    final status = JsonUtils.asNullableString(json['status']);
    if (status != null) {
      final text = status.toLowerCase();
      if (text == 'habis' || text == 'sold_out' || text == 'unavailable') {
        return false;
      }
      if (text == 'tersedia' || text == 'available' || text == 'active') {
        return true;
      }
    }

    return JsonUtils.asNullableBool(
          JsonUtils.pick(json, ['is_available', 'isAvailable', 'available']),
        ) ??
        true;
  }
}
