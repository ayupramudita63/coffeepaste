/// Ulasan satu produk yang akan dikirim ke backend.
class ProductReviewDraft {
  /// ID menu di backend.
  final String menuItemId;

  /// 1 sampai 5.
  final int rating;

  /// Boleh kosong (rating saja).
  final String comment;

  const ProductReviewDraft({
    required this.menuItemId,
    required this.rating,
    this.comment = '',
  });

  Map<String, dynamic> toJson() => {
        'menuItemId': int.tryParse(menuItemId) ?? menuItemId,
        'rating': rating,
        'comment': comment.trim(),
      };
}
