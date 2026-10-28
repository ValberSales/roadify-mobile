import 'package:flutter/material.dart';
import 'package:roadify_app/core/theme/theme_extensions.dart';

import '../../../../../core/theme/app_dimensions.dart';

class SensorSectionHeading extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const SensorSectionHeading({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: colors.primaryContainer,
            borderRadius: AppDimensions.borderRadiusSmall,
          ),
          child: Icon(icon, size: 20, color: colors.onPrimaryContainer),
        ),
        const SizedBox(width: AppDimensions.space12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: typography.titleMedium),
              const SizedBox(height: AppDimensions.space2),
              Text(subtitle, style: typography.bodySmall),
            ],
          ),
        ),
      ],
    );
  }
}
