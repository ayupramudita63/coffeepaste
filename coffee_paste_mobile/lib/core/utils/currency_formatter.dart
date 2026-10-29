/// Contoh: 22000 -> "Rp 22.000"
String formatRupiah(int amount) {
  final s = amount.toString();
  final buffer = StringBuffer();
  for (int i = 0; i < s.length; i++) {
    final posFromRight = s.length - i;
    buffer.write(s[i]);
    if (posFromRight > 1 && posFromRight % 3 == 1) buffer.write('.');
  }
  return 'Rp $buffer';
}