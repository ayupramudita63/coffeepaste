import '../../../shared/models/category_model.dart';
import '../../../shared/models/product_model.dart';

/// Data contoh untuk mode mock. Dipakai oleh [MockMenuRepository] dan
/// [MockOrderRepository]; tidak boleh diimpor langsung oleh UI.
class MockMenuData {
  MockMenuData._();

  static const String _image = 'assets/images/latte.jpg';

  static const List<CategoryModel> categories = [
    CategoryModel(id: 'coffee', label: 'Coffee', iconKey: 'coffee'),
    CategoryModel(id: 'non_coffee', label: 'Non Coffee', iconKey: 'non_coffee'),
    CategoryModel(id: 'food', label: 'Makanan', iconKey: 'food'),
    CategoryModel(id: 'snack', label: 'Snack', iconKey: 'pastry'),
  ];

  static DateTime _daysAgo(int days) =>
      DateTime.now().subtract(Duration(days: days));

  /// Produk bernomor besar = lebih baru (dipakai untuk "Menu Baru").
  static List<ProductModel> products() => [
        ProductModel(
          id: 'p1',
          name: 'Coffee Latte',
          price: 22000,
          rating: 4.8,
          ratingCount: 1200,
          imageUrl: _image,
          categoryId: 'coffee',
          categoryName: 'Coffee',
          description:
              'Espresso dengan susu steamed lembut, cocok untuk memulai hari.',
          createdAt: _daysAgo(120),
        ),
        ProductModel(
          id: 'p2',
          name: 'Iced Americano',
          price: 18000,
          rating: 4.6,
          ratingCount: 892,
          imageUrl: _image,
          categoryId: 'coffee',
          categoryName: 'Coffee',
          description:
              'Espresso murni dengan air dingin, rasa kopi yang kuat dan segar.',
          createdAt: _daysAgo(118),
        ),
        ProductModel(
          id: 'p3',
          name: 'Matcha Latte',
          price: 24000,
          rating: 4.7,
          ratingCount: 1000,
          imageUrl: _image,
          categoryId: 'non_coffee',
          categoryName: 'Non Coffee',
          description:
              'Bubuk matcha premium dipadukan susu creamy, manis dan menenangkan.',
          createdAt: _daysAgo(110),
        ),
        ProductModel(
          id: 'p4',
          name: 'Chocolate Milk',
          price: 20000,
          rating: 4.5,
          ratingCount: 430,
          imageUrl: _image,
          categoryId: 'non_coffee',
          categoryName: 'Non Coffee',
          description:
              'Coklat premium dengan susu segar, favorit untuk yang tidak suka kopi.',
          createdAt: _daysAgo(100),
        ),
        ProductModel(
          id: 'p5',
          name: 'Croissant Butter',
          price: 19000,
          rating: 4.5,
          ratingCount: 310,
          imageUrl: _image,
          categoryId: 'food',
          categoryName: 'Makanan',
          description:
              'Pastry berlapis dengan butter asli, renyah di luar lembut di dalam.',
          createdAt: _daysAgo(90),
        ),
        ProductModel(
          id: 'p6',
          name: 'Banana Cake',
          price: 17000,
          rating: 4.4,
          ratingCount: 220,
          imageUrl: _image,
          categoryId: 'food',
          categoryName: 'Makanan',
          description: 'Cake pisang lembut dengan taburan kenari panggang.',
          createdAt: _daysAgo(80),
        ),
        ProductModel(
          id: 'p7',
          name: 'French Fries',
          price: 15000,
          rating: 4.3,
          ratingCount: 180,
          imageUrl: _image,
          categoryId: 'snack',
          categoryName: 'Snack',
          description:
              'Kentang goreng renyah dengan bumbu spesial, cocok untuk teman ngopi.',
          createdAt: _daysAgo(70),
        ),
        ProductModel(
          id: 'p8',
          name: 'Cookies',
          price: 12000,
          rating: 4.6,
          ratingCount: 340,
          imageUrl: _image,
          categoryId: 'snack',
          categoryName: 'Snack',
          description:
              'Cookies coklat chip homemade, renyah di pinggir lumer di tengah.',
          createdAt: _daysAgo(60),
        ),
        ProductModel(
          id: 'p9',
          name: 'Iced Caramel Latte',
          price: 25000,
          rating: 4.9,
          ratingCount: 756,
          imageUrl: _image,
          categoryId: 'coffee',
          categoryName: 'Coffee',
          description:
              'Perpaduan sempurna antara kopi, susu, dan karamel yang nikmat.',
          createdAt: _daysAgo(40),
        ),
        ProductModel(
          id: 'p10',
          name: 'Matcha Cream',
          price: 25000,
          rating: 4.7,
          ratingCount: 640,
          imageUrl: _image,
          categoryId: 'non_coffee',
          categoryName: 'Non Coffee',
          description: 'Matcha creamy dengan whipped cream di atasnya.',
          createdAt: _daysAgo(9),
        ),
        ProductModel(
          id: 'p11',
          name: 'Caramel Latte',
          price: 24000,
          rating: 4.5,
          ratingCount: 530,
          imageUrl: _image,
          categoryId: 'coffee',
          categoryName: 'Coffee',
          description: 'Latte dengan saus karamel manis yang lembut.',
          createdAt: _daysAgo(6),
        ),
        ProductModel(
          id: 'p12',
          name: 'Chocolate Frappe',
          price: 26000,
          rating: 4.6,
          ratingCount: 412,
          imageUrl: _image,
          categoryId: 'non_coffee',
          categoryName: 'Non Coffee',
          description:
              'Coklat dingin blend dengan topping krim dan serutan coklat.',
          createdAt: _daysAgo(3),
        ),
        ProductModel(
          id: 'p13',
          name: 'Hazelnut Latte',
          price: 25000,
          rating: 4.4,
          ratingCount: 210,
          imageUrl: _image,
          categoryId: 'coffee',
          categoryName: 'Coffee',
          description: 'Latte dengan sirup hazelnut yang harum.',
          createdAt: _daysAgo(1),
        ),
      ];
}
