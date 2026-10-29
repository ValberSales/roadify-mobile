import 'package:flutter/material.dart';
import 'package:roadify_app/core/database/app_database.dart';
import 'package:roadify_app/core/theme/theme_extensions.dart';
import 'package:roadify_app/features/coleta/presentation/widgets/section_divider.dart';

import '../../../../../core/theme/app_dimensions.dart';

class SelectedVehicleCard extends StatelessWidget {
  final Vehicle vehicle;
  final VoidCallback onChange;

  const SelectedVehicleCard({
    super.key,
    required this.vehicle,
    required this.onChange,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;

    return Container(
      key: const ValueKey('selected-collection-vehicle'),
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.space16),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: AppDimensions.borderRadiusCard,
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: colors.primaryContainer,
                  borderRadius: AppDimensions.borderRadiusSmall,
                ),
                child: Icon(
                  Icons.directions_car_rounded,
                  color: colors.onPrimaryContainer,
                ),
              ),
              const SizedBox(width: AppDimensions.space12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      vehicle.name,
                      style: typography.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      vehicle.model,
                      style: typography.bodyMedium?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(onPressed: onChange, child: const Text('Alterar')),
            ],
          ),
          const SizedBox(height: AppDimensions.space12),
          const SectionDivider(),
          const SizedBox(height: AppDimensions.space12),
          Wrap(
            spacing: AppDimensions.space8,
            runSpacing: AppDimensions.space8,
            children: [
              _VehicleDetail(label: 'Placa', value: vehicle.licensePlate),
              _VehicleDetail(label: 'Ano', value: vehicle.year.toString()),
              if (vehicle.traction?.trim().isNotEmpty == true)
                _VehicleDetail(label: 'Tração', value: vehicle.traction!),
            ],
          ),
          if (vehicle.description?.trim().isNotEmpty == true) ...[
            const SizedBox(height: AppDimensions.space12),
            Text(
              'Descrição',
              style: typography.labelMedium?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppDimensions.space2),
            Text(vehicle.description!, style: typography.bodyMedium),
          ],
        ],
      ),
    );
  }
}

class _VehicleDetail extends StatelessWidget {
  final String label;
  final String value;

  const _VehicleDetail({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.space8,
        vertical: AppDimensions.space4,
      ),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest,
        borderRadius: AppDimensions.borderRadiusSmall,
      ),
      child: Text(
        '$label: $value',
        style: context.typography.labelMedium?.copyWith(
          color: colors.onSurfaceVariant,
        ),
      ),
    );
  }
}
