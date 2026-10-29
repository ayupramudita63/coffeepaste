import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../providers/order_provider.dart';
import '../../../shared/widgets/app_image.dart';
import '../models/order_model.dart';
import '../models/product_review_draft.dart';

/// Bottom sheet "Beri Ulasan": bintang 1-5 dan komentar untuk tiap produk
/// yang belum diulas pada pesanan. Mengembalikan true (lewat Navigator.pop)
/// bila ulasan berhasil dikirim.
class ReviewOrderSheet extends StatefulWidget {
  final OrderModel order;

  const ReviewOrderSheet({super.key, required this.order});

  static Future<bool?> show(BuildContext context, OrderModel order) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => ChangeNotifierProvider<OrderProvider>.value(
        value: context.read<OrderProvider>(),
        child: ReviewOrderSheet(order: order),
      ),
    );
  }

  @override
  State<ReviewOrderSheet> createState() => _ReviewOrderSheetState();
}

class _ReviewOrderSheetState extends State<ReviewOrderSheet> {
  static const int _maxComment = 500;

  late final List<OrderItem> _items;
  late final Map<String, int> _ratings;
  late final Map<String, TextEditingController> _comments;
  String? _error;

  @override
  void initState() {
    super.initState();
    _items = widget.order.reviewableItems;
    _ratings = {for (final item in _items) item.menuItemId!: 0};
    _comments = {
      for (final item in _items) item.menuItemId!: TextEditingController(),
    };
  }

  @override
  void dispose() {
    for (final controller in _comments.values) {
      controller.dispose();
    }
    super.dispose();
  }

  bool get _hasAnyRating => _ratings.values.any((rating) => rating > 0);

  Future<void> _submit() async {
    final drafts = [
      for (final item in _items)
        if (_ratings[item.menuItemId]! > 0)
          ProductReviewDraft(
            menuItemId: item.menuItemId!,
            rating: _ratings[item.menuItemId]!,
            comment: _comments[item.menuItemId]!.text,
          ),
    ];
    if (drafts.isEmpty) return;

    setState(() => _error = null);

    final provider = context.read<OrderProvider>();
    final ok = await provider.submitReviews(widget.order, drafts);
    if (!mounted) return;

    if (ok) {
      Navigator.of(context).pop(true);
    } else {
      setState(() => _error = provider.submitError ?? 'Gagal mengirim ulasan.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSubmitting = context.select<OrderProvider, bool>(
      (provider) => provider.isSubmitting,
    );
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 14, 20, 16 + bottomInset),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 42,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Beri Ulasan',
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Pesanan ${widget.order.orderLabel}. Pilih bintang untuk produk '
            'yang ingin kamu ulas; yang dikosongkan akan dilewati.',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 12.5),
          ),
          const SizedBox(height: 14),
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: _items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 14),
              itemBuilder: (_, index) => _buildItem(_items[index]),
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 10),
            Text(
              _error!,
              key: const Key('review-error'),
              style: TextStyle(color: Colors.red.shade700, fontSize: 12.5),
            ),
          ],
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              key: const Key('review-submit'),
              onPressed: (_hasAnyRating && !isSubmitting) ? _submit : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22),
                ),
              ),
              child: isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Kirim Ulasan'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItem(OrderItem item) {
    final id = item.menuItemId!;
    final rating = _ratings[id]!;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: appImage(
                  item.imagePath,
                  width: 44,
                  height: 44,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 44,
                    height: 44,
                    color: AppColors.surface,
                    child: Icon(Icons.coffee, color: AppColors.primary),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  item.name,
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              for (var star = 1; star <= 5; star++)
                GestureDetector(
                  key: Key('star-$id-$star'),
                  behavior: HitTestBehavior.opaque,
                  onTap: () => setState(() => _ratings[id] = star),
                  child: Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: Icon(
                      star <= rating
                          ? Icons.star_rounded
                          : Icons.star_outline_rounded,
                      color: AppColors.rating,
                      size: 34,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            key: Key('comment-$id'),
            controller: _comments[id],
            maxLength: _maxComment,
            maxLines: 3,
            minLines: 1,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              hintText: 'Ceritakan pengalamanmu (opsional)',
              filled: true,
              fillColor: AppColors.surface,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.border),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
