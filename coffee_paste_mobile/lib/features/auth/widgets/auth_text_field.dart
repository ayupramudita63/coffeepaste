import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class AuthTextField extends StatelessWidget {
  final String hintText;
  final List<List<dynamic>> prefixIcon; // diubah dari IconData
  final TextEditingController? controller;
  final bool obscureText;
  final Widget? suffixIcon;
  final TextInputType keyboardType;

  const AuthTextField({
    super.key,
    required this.hintText,
    required this.prefixIcon,
    this.controller,
    this.obscureText = false,
    this.suffixIcon,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.inputBackground,
        borderRadius: BorderRadius.circular(30),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        style: AppTextStyles.productName.copyWith(fontWeight: FontWeight.w400),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: AppTextStyles.searchHint,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
          prefixIcon: Padding(
            padding: const EdgeInsets.all(10),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.primary.withOpacity(0.12),
              child: HugeIcon(
                icon: prefixIcon,
                size: 18,
                color: AppColors.primary,
              ),
            ),
          ),
          suffixIcon: suffixIcon,
        ),
      ),
    );
  }
}