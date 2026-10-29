import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// Garis putus-putus selebar parent-nya.
class DashedDivider extends StatelessWidget {
  const DashedDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const dashWidth = 5.0;
        const dashGap = 4.0;

        final count = (constraints.maxWidth / (dashWidth + dashGap)).floor();

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(
            count,
            (_) => const SizedBox(
              width: dashWidth,
              height: 1,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.border,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
