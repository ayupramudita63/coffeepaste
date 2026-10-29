import 'package:flutter/material.dart';

class CornerLeafDecoration extends StatelessWidget {
  final String imagePath;
  final double width;

  const CornerLeafDecoration({
    super.key,
    required this.imagePath,
    this.width = 130,
  });

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      imagePath,
      width: width,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
    );
  }
}