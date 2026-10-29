import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class HomeSearchBar extends StatefulWidget {
  final ValueChanged<String> onChanged;
  final String initialValue;

  const HomeSearchBar({
    super.key,
    required this.onChanged,
    this.initialValue = '',
  });

  @override
  State<HomeSearchBar> createState() => _HomeSearchBarState();
}

class _HomeSearchBarState extends State<HomeSearchBar> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: widget.onChanged,
      controller: _controller,
      decoration: InputDecoration(
        hintText: 'Cari kopi atau minuman favoritmu...',
        hintStyle: TextStyle(
          color: AppColors.textSecondary.withValues(alpha: 0.8),
          fontSize: 12,
        ),
        prefixIcon: const Icon(
          Icons.search,
          color: AppColors.primary,
          size: 22,
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: AppColors.primary.withValues(alpha: 0.12),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: AppColors.primary,
            width: 1.2,
          ),
        ),
      ),
    );
  }
}