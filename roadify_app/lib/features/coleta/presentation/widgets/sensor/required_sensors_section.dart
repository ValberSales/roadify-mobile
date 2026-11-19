import 'package:flutter/material.dart';
import 'package:roadify_app/l10n/app_localizations_catalog.dart';
import 'package:roadify_app/core/theme/theme_extensions.dart';
import 'package:roadify_app/features/coleta/presentation/widgets/sensor/sensor_configuration_card.dart';
import 'package:roadify_app/features/coleta/presentation/widgets/sensor/sensor_frequency_selector.dart';
import 'package:roadify_app/features/coleta/presentation/widgets/sensor/sensor_section_heading.dart';
import 'package:roadify_app/features/coleta/viewmodels/coleta_viewmodel.dart';

import '../../../../../core/theme/app_dimensions.dart';

class RequiredSensorsSection extends StatelessWidget {
  static const List<int> acelerometroPresets = [100, 200, 300, 400, 500];
  static const List<int> gpsPresets = [1, 2, 5, 10];

  final int accelerometerRate;
  final ValueChanged<int> onAccelerometerRateChanged;
  final ValueChanged<int> onGpsRateChanged;
  final TextEditingController accelerometerFrequencyController;
  final TextEditingController gpsFrequencyController;
  final String? selectionError;
  final String? Function(String?) validateAccelerometerRate;
  final String? Function(String?) validateGpsRate;

  const RequiredSensorsSection({
    super.key,
    required this.accelerometerRate,
    required this.onAccelerometerRateChanged,
    required this.onGpsRateChanged,
    required this.accelerometerFrequencyController,
    required this.gpsFrequencyController,
    required this.selectionError,
    required this.validateAccelerometerRate,
    required this.validateGpsRate,
  });

  @override
  Widget build(BuildContext context) {
    final typography = context.typography;
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SensorSectionHeading(
          title: 'Sensores Obrigatórios',
          subtitle: AppLocalizations.of(context).text('requiredSensorsSubtitle'),
          icon: Icons.priority_high_rounded,
        ),
        const SizedBox(height: AppDimensions.space12),
        SensorConfigurationCard(
          sensor: SensorColeta.acelerometro,
          title: 'Acelerômetro',
          subtitle: AppLocalizations.of(context).text('roadIrregularity'),
          icon: Icons.speed_rounded,
          selected: true,
          requiredSensor: true,
          settings: SensorFrequencySelector(
            keyPrefix: 'acc',
            minimum: 50,
            maximum: 500,
            title: 'Frequência do acelerômetro',
            unit: 'Hz',
            presets: acelerometroPresets,
            currentValue: accelerometerRate,
            customController: accelerometerFrequencyController,
            onChanged: onAccelerometerRateChanged,
            validator: validateAccelerometerRate,
            inputHint: 'Ex: 250',
            inputHelper: AppLocalizations.of(context).text('sensorSafetyLimit'),
            inputIcon: Icons.speed_rounded,
          ),
        ),
        const SizedBox(height: AppDimensions.space12),
        SensorConfigurationCard(
          sensor: SensorColeta.gps,
          title: 'GPS',
          subtitle: AppLocalizations.of(context).text('gpsRoads'),
          icon: Icons.satellite_alt_rounded,
          selected: true,
          requiredSensor: true,
          settings: SensorFrequencySelector(
            keyPrefix: 'gps',
            minimum: 1,
            maximum: 10,
            title: 'Frequência do GPS',
            unit: 'Hz',
            presets: gpsPresets,
            currentValue: int.tryParse(gpsFrequencyController.text.trim()),
            customController: gpsFrequencyController,
            onChanged: onGpsRateChanged,
            validator: validateGpsRate,
            inputHint: 'Ex: 8',
            inputHelper: AppLocalizations.of(context).text('gnssRange'),
            inputIcon: Icons.satellite_outlined,
          ),
        ),
        if (selectionError != null) ...[
          const SizedBox(height: AppDimensions.space8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppDimensions.space12),
            decoration: BoxDecoration(
              color: colors.errorContainer,
              borderRadius: AppDimensions.borderRadiusMedium,
            ),
            child: Text(
              selectionError!,
              style: typography.bodySmall?.copyWith(
                color: colors.onErrorContainer,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
