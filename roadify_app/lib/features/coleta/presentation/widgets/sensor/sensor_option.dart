import 'package:flutter/material.dart';
import 'package:roadify_app/core/theme/theme_extensions.dart';
import 'package:roadify_app/features/coleta/viewmodels/coleta_viewmodel.dart';

import '../../../../../core/theme/app_dimensions.dart';

typedef SensorSelectionChanged =
    void Function(SensorColeta sensor, bool selected);

class SensorOption extends StatelessWidget {
  final SensorColeta sensor;
  final String title;
  final String subtitle;
  final IconData icon;
  final bool selected;
  final bool requiredSensor;
  final SensorSelectionChanged? onChanged;

  const SensorOption({
    super.key,
    required this.sensor,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.selected,
    this.requiredSensor = false,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: colors.primary.withValues(alpha: 0.1),
            borderRadius: AppDimensions.borderRadiusSmall,
          ),
          child: Icon(icon, size: 20, color: colors.primary),
        ),
        const SizedBox(width: AppDimensions.space12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: context.typography.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppDimensions.space2),
              Text(
                subtitle,
                style: context.typography.bodySmall?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        if (requiredSensor)
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.space8,
              vertical: AppDimensions.space4,
            ),
            decoration: BoxDecoration(
              color: colors.primary,
              borderRadius: AppDimensions.borderRadiusSmall,
            ),
            child: Text(
              'Obrigatório',
              style: context.typography.labelSmall?.copyWith(
                color: colors.onPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          )
        else
          Checkbox(
            key: ValueKey('sensor-${sensor.name}-checkbox'),
            value: selected,
            onChanged: onChanged == null
                ? null
                : (value) => onChanged!(sensor, value ?? false),
          ),
      ],
    );
  }
}
