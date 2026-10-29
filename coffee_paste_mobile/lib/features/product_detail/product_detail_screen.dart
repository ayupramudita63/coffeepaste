import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import 'package:coffee_paste/shared/models/product_model.dart';
import 'package:coffee_paste/providers/cart_provider.dart';
import 'widgets/option_selector_widget.dart';
import '../../shared/widgets/app_image.dart';

class ProductDetailScreen extends StatefulWidget {
  final ProductModel product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _iceIndex = 0;
  int _sugarIndex = 0;
  int _sizeIndex = 0;
  int _quantity = 1;

  final _iceOptions = const [
    OptionItem(label: 'Normal', icon: HugeIcons.strokeRoundedCube),
    OptionItem(label: 'Less Ice', icon: HugeIcons.strokeRoundedCube),
    OptionItem(label: 'No Ice', icon: HugeIcons.strokeRoundedCube),
  ];

  final _sugarOptions = const [
    OptionItem(label: 'Normal', icon: HugeIcons.strokeRoundedCube),
    OptionItem(label: 'Less Sugar', icon: HugeIcons.strokeRoundedCube),
    OptionItem(label: 'No Sugar', icon: HugeIcons.strokeRoundedCube),
  ];

  final _sizeOptions = const [
    OptionItem(label: 'Regular', icon: HugeIcons.strokeRoundedCupSoda),
    OptionItem(label: 'Large', icon: HugeIcons.strokeRoundedCupSoda),
  ];

  bool get _isDrink => widget.product.isDrink;

  String _formatPrice(int price) {
    final s = price.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      final posFromRight = s.length - i;
      buffer.write(s[i]);
      if (posFromRight > 1 && posFromRight % 3 == 1) buffer.write('.');
    }
    return 'Rp $buffer';
  }

  /// Menambahkan pilihan saat ini ke keranjang.
  void _addCurrentSelection() {
    context.read<CartProvider>().addItem(
          product: widget.product,
          quantity: _quantity,
          ice: _isDrink ? _iceOptions[_iceIndex].label : null,
          sugar: _isDrink ? _sugarOptions[_sugarIndex].label : null,
          size: _isDrink ? _sizeOptions[_sizeIndex].label : null,
        );
  }

  /// "Pesan Sekarang": tambahkan lalu langsung ke checkout (pilih tipe & pembayaran).
  /// Item lain yang sudah ada di keranjang ikut tampil di checkout.
  void _onOrderNowTap() {
    if (!widget.product.isAvailable) return;
    _addCurrentSelection();
    GoRouter.of(context).pushReplacement(AppRoutes.cart);
  }

  void _onAddToCartTap() {
    final product = widget.product;

    _addCurrentSelection();

    final router = GoRouter.of(context);
    final messenger = ScaffoldMessenger.of(context);

    router.pop();
    messenger.showSnackBar(
      SnackBar(
        content: Text('${product.name} ditambahkan ke keranjang'),
        duration: const Duration(seconds: 2),
        action: SnackBarAction(
          label: 'Lihat',
          onPressed: () {
            router.push(AppRoutes.cart);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Konten yang bisa di-scroll, termasuk gambar produk di dalamnya
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 190),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Gambar produk (rasio 3:2) — ikut ter-scroll
                Stack(
                  children: [
                    AspectRatio(
                      aspectRatio: 3 / 2,
                      child: SizedBox(
                        width: double.infinity,
                        child: product.imageUrl != null
                            ? appImage(product.imageUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => Container(
                                  color: AppColors.surfaceMuted,
                                  child: const Icon(Icons.local_cafe, size: 60, color: AppColors.primary),
                                ),
                              )
                            : Container(
                                color: AppColors.surfaceMuted,
                                child: const Icon(Icons.local_cafe, size: 60, color: AppColors.primary),
                              ),
                      ),
                    ),
                    Positioned(
                      bottom: 16,
                      right: 20,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            HugeIcon(
                              icon: HugeIcons.strokeRoundedStar,
                              size: 16,
                              color: AppColors.rating,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              product.ratingCount == 0
                                  ? 'Belum ada ulasan'
                                  : '${product.rating.toStringAsFixed(1)} '
                                      '(${product.ratingCount})',
                              style: AppTextStyles.productName,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                // Konten teks di bawah gambar
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(product.name, style: AppTextStyles.greetingTitle),
                      const SizedBox(height: 4),
                      Text(
                        _formatPrice(product.price),
                        style: AppTextStyles.greetingTitle.copyWith(fontSize: 20),
                      ),
                      const SizedBox(height: 10),
                      Text(product.description, style: AppTextStyles.ratingText),
                      const SizedBox(height: 20),

                    if (_isDrink) ...[
                      OptionSelectorWidget(
                        groupIcon: HugeIcons.strokeRoundedCube,
                        title: 'Ice Cube',
                        subtitle: 'Pilih tingkat es sesuai selera.',
                        options: _iceOptions,
                        selectedIndex: _iceIndex,
                        onSelected: (i) => setState(() => _iceIndex = i),
                      ),
                      const SizedBox(height: 14),

                      OptionSelectorWidget(
                        groupIcon: HugeIcons.strokeRoundedCube,
                        title: 'Gula',
                        subtitle: 'Pilih tingkat manis sesuai selera.',
                        options: _sugarOptions,
                        selectedIndex: _sugarIndex,
                        onSelected: (i) => setState(() => _sugarIndex = i),
                      ),
                      const SizedBox(height: 14),

                      OptionSelectorWidget(
                        groupIcon: HugeIcons.strokeRoundedCupSoda,
                        title: 'Ukuran',
                        subtitle: 'Pilih ukuran minuman.',
                        options: _sizeOptions,
                        selectedIndex: _sizeIndex,
                        onSelected: (i) => setState(() => _sizeIndex = i),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Tombol back — melayang tetap di atas, tidak ikut scroll
          Positioned(
            top: 40,
            left: 20,
            child: _CircleIconButton(
              icon: HugeIcons.strokeRoundedArrowLeft01,
              onTap: () => Navigator.of(context).maybePop(),
            ),
          ),

          // Bar bawah: quantity + tombol Add to Cart — tetap di bawah, tidak ikut scroll
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              decoration: BoxDecoration(
                color: AppColors.background,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 12,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _QuantityButton(
                        icon: HugeIcons.strokeRoundedRemove01,
                        onTap: () {
                          if (_quantity > 1) setState(() => _quantity--);
                        },
                      ),
                      const SizedBox(width: 20),
                      Text(
                        '$_quantity',
                        style:
                            AppTextStyles.greetingTitle.copyWith(fontSize: 20),
                      ),
                      const SizedBox(width: 20),
                      _QuantityButton(
                        icon: HugeIcons.strokeRoundedAdd01,
                        onTap: () => setState(() => _quantity++),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          key: const Key('add-to-cart'),
                          onPressed: _onAddToCartTap,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            side: const BorderSide(color: AppColors.primary),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              HugeIcon(
                                icon: HugeIcons.strokeRoundedShoppingCart01,
                                size: 16,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  'Keranjang',
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyles.productName.copyWith(
                                    color: AppColors.primary,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          key: const Key('order-now'),
                          onPressed:
                              product.isAvailable ? _onOrderNowTap : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            product.isAvailable ? 'Pesan Sekarang' : 'Habis',
                            style: AppTextStyles.productName.copyWith(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  final List<List<dynamic>> icon;
  final VoidCallback onTap;

  const _CircleIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: const BoxDecoration(color: AppColors.surface, shape: BoxShape.circle),
        child: Center(child: HugeIcon(icon: icon, size: 18, color: AppColors.primary)),
      ),
    );
  }
}

class _QuantityButton extends StatelessWidget {
  final List<List<dynamic>> icon;
  final VoidCallback onTap;

  const _QuantityButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
        child: Center(child: HugeIcon(icon: icon, size: 18, color: Colors.white)),
      ),
    );
  }
}