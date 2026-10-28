import 'package:flutter/material.dart';
import 'package:roadify_app/core/theme/theme_extensions.dart';
import 'package:roadify_app/features/coleta/presentation/widgets/sensor/sensor_option.dart';
import 'package:roadify_app/features/coleta/viewmodels/coleta_viewmodel.dart';

import '../../../../../core/theme/app_dimensions.dart';

class SensorConfigurationCard extends StatelessWidget {
  final SensorColeta sensor;
  final String title;
  final String subtitle;
  final IconData icon;
  final bool selected;
  final SensorSelectionChanged? onChanged;
  final bool requiredSensor;
  final Widget? settings;

  const SensorConfigurationCard({
    super.key,
    required this.sensor,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.selected,
    this.onChanged,
    this.requiredSensor = false,
    this.settings,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      decoration: BoxDecoration(
        color: selected
            ? colors.primaryContainer.withValues(alpha: 0.32)
            : colors.surfaceContainerLow,
        borderRadius: AppDimensions.borderRadiusCard,
        border: Border.all(
          color: selected
              ? colors.primary.withValues(alpha: 0.45)
              : colors.outlineVariant,
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.space12,
              vertical: AppDimensions.space8,
            ),
            child: SensorOption(
              sensor: sensor,
              title: title,
              subtitle: subtitle,
              icon: icon,
              selected: selected,
              requiredSensor: requiredSensor,
              onChanged: onChanged,
            ),
          ),
          if (selected && settings != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppDimensions.space12,
                0,
                AppDimensions.space12,
                AppDimensions.space16,
              ),
              child: settings,
            ),
        ],
      ),
    );
  }
}
