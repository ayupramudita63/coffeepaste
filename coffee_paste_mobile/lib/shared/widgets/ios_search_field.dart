import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_style.dart';

/// Kolom cari bergaya iOS: abu-abu lembut, ikon kaca pembesar di kiri,
/// tombol hapus (x) muncul saat ada teks.
class IosSearchField extends StatefulWidget {
  final String hint;
  final ValueChanged<String> onChanged;
  final TextEditingController? controller;
  final String initialValue;

  const IosSearchField({
    super.key,
    required this.hint,
    required this.onChanged,
    this.controller,
    this.initialValue = '',
  });

  @override
  State<IosSearchField> createState() => _IosSearchFieldState();
}

class _IosSearchFieldState extends State<IosSearchField> {
  late final TextEditingController _controller;
  late final bool _ownsController;

  @override
  void initState() {
    super.initState();
    _ownsController = widget.controller == null;
    _controller =
        widget.controller ?? TextEditingController(text: widget.initialValue);
    _controller.addListener(_refresh);
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller.removeListener(_refresh);
    if (_ownsController) _controller.dispose();
    super.dispose();
  }

  void _clear() {
    _controller.clear();
    widget.onChanged('');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 46,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: AppColors.inputBackground,
        borderRadius: BorderRadius.circular(AppStyle.innerRadius),
      ),
      child: Row(
        children: [
          Icon(Icons.search_rounded, size: 21, color: AppColors.textMuted),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _controller,
              onChanged: widget.onChanged,
              textInputAction: TextInputAction.search,
              cursorColor: AppColors.primary,
              style: TextStyle(fontSize: 14, color: AppColors.textPrimary),
              decoration: InputDecoration(
                isCollapsed: true,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                filled: false,
                hintText: widget.hint,
                hintStyle: TextStyle(fontSize: 14, color: AppColors.textMuted),
              ),
            ),
          ),
          if (_controller.text.isNotEmpty)
            GestureDetector(
              onTap: _clear,
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Icon(
                  Icons.cancel,
                  size: 18,
                  color: AppColors.textMuted,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
