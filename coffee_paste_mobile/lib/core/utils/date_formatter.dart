/// Format tanggal pesanan.
///
/// Contoh: DateTime(2026, 10, 9, 13, 5) -> "09 Okt 2026, 13:05"
String formatOrderDate(DateTime date) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'Mei',
    'Jun',
    'Jul',
    'Agu',
    'Sep',
    'Okt',
    'Nov',
    'Des',
  ];

  final day = date.day.toString().padLeft(2, '0');
  final month = months[date.month - 1];
  final year = date.year;

  final hour = date.hour.toString().padLeft(2, '0');
  final minute = date.minute.toString().padLeft(2, '0');

  return '$day $month $year, $hour:$minute';
}
