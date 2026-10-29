import 'package:flutter/material.dart';

import '../../core/utils/json_utils.dart';

class CategoryModel {
  static const String allId = 'all';

  final String id;
  final String label;

  /// Kunci ikon: all, coffee, non_coffee, matcha, chocolate, tea, food, pastry.
  final String iconKey;

  const CategoryModel({
    required this.id,
    required this.label,
    this.iconKey = 'all',
  });

  static const CategoryModel all = CategoryModel(
    id: allId,
    label: 'Semua',
    iconKey: 'all',
  );

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    final name = JsonUtils.asString(
      JsonUtils.pick(json, ['name', 'nama', 'label', 'filter', 'title']),
      fallback: 'Kategori',
    );

    return CategoryModel(
      id: JsonUtils.asString(JsonUtils.pick(json, ['id', 'category_id'])),
      label: name,
      iconKey: iconKeyFromName(name),
    );
  }

  /// Menebak ikon dari nama kategori supaya tidak perlu field ikon di database.
  static String iconKeyFromName(String name) {
    final text = name.toLowerCase();
    if (text.contains('non') && text.contains('coffee') ||
        text.contains('non kopi') ||
        text.contains('non-kopi')) {
      return 'non_coffee';
    }
    if (text.contains('coffee') || text.contains('kopi')) return 'coffee';
    if (text.contains('matcha')) return 'matcha';
    if (text.contains('choco') || text.contains('coklat')) return 'chocolate';
    if (text.contains('tea') || text.contains('teh')) return 'tea';
    if (text.contains('pastry') || text.contains('bakery')) return 'pastry';
    if (text.contains('food') ||
        text.contains('makan') ||
        text.contains('snack') ||
        text.contains('dessert')) {
      return 'food';
    }
    return 'all';
  }

  IconData get icon {
    switch (iconKey) {
      case 'coffee':
        return Icons.coffee_outlined;
      case 'non_coffee':
        return Icons.local_drink_outlined;
      case 'matcha':
        return Icons.emoji_food_beverage_outlined;
      case 'chocolate':
        return Icons.cookie_outlined;
      case 'tea':
        return Icons.eco_outlined;
      case 'food':
        return Icons.restaurant_outlined;
      case 'pastry':
        return Icons.bakery_dining_outlined;
      case 'all':
      default:
        return Icons.grid_view_rounded;
    }
  }
}
