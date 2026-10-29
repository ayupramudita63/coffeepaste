import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// Progress 4 langkah: diterima -> disiapkan -> siap diambil -> selesai.
///
/// [currentStep] bernilai 0..3 (lihat `OrderStatus.stepIndex`).
class OrderProgressBar extends StatelessWidget {
  final int currentStep;

  const OrderProgressBar({
    super.key,
    required this.currentStep,
  });

  static const _labels = [
    'Pesanan\nditerima',
    'Sedang\ndisiapkan',
    'Siap\ndiambil',
    'Selesai',
  ];

  @override
  Widget build(BuildContext context) {
    final lastIndex = _labels.length - 1;

    return Column(
      children: [
        Row(
          children: List.generate(_labels.length, (index) {
            return Expanded(
              child: Row(
                children: [
                  _ProgressCircle(
                    completed: index < currentStep,
                    current: index == currentStep,
                  ),
                  if (index != lastIndex)
                    Expanded(
                      child: Container(
                        height: 3,
                        color: index < currentStep
                            ? AppColors.primary
                            : AppColors.border.withOpacity(0.5),
                      ),
                    ),
                ],
              ),
            );
          }),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: _labels.map((label) {
            return SizedBox(
              width: 65,
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                  height: 1.3,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _ProgressCircle extends StatelessWidget {
  final bool completed;
  final bool current;

  const _ProgressCircle({
    required this.completed,
    required this.current,
  });

  @override
  Widget build(BuildContext context) {
    if (completed) {
      return Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.check,
          color: Colors.white,
          size: 19,
        ),
      );
    }

    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(
          color: current ? AppColors.primary : AppColors.border,
          width: 4,
        ),
      ),
      child: current
          ? Container(
              margin: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
            )
          : null,
    );
  }
}
