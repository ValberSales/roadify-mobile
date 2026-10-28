import 'package:flutter/material.dart';
import 'package:roadify_app/core/theme/theme_extensions.dart';

import '../../../../core/theme/app_dimensions.dart';

class SectionDivider extends StatelessWidget {
  final IconData? icon;

  const SectionDivider({super.key, this.icon});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Row(
      children: [
        Expanded(child: Divider(height: 1, color: colors.outlineVariant)),
        if (icon != null) ...[
          const SizedBox(width: AppDimensions.space12),
          Icon(icon, size: 16, color: colors.onSurfaceVariant),
          const SizedBox(width: AppDimensions.space12),
        ] else ...[
          const SizedBox(width: AppDimensions.space12),
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: 0.55),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: AppDimensions.space12),
        ],
        Expanded(child: Divider(height: 1, color: colors.outlineVariant)),
      ],
    );
  }
}
