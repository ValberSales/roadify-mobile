import 'package:flutter/material.dart';
import 'package:roadify_app/core/database/app_database.dart';
import 'package:roadify_app/core/theme/theme_extensions.dart';
import 'package:roadify_app/core/widgets/empty_state_widget.dart';

class VehicleListWidget extends StatelessWidget {
  final List<Vehicle> vehicles;
  final Function(Vehicle) onVehicleTap;
  final Function(Vehicle)? onEditTap;
  final Function(Vehicle)? onDeleteTap;

  const VehicleListWidget({
    Key? key,
    required this.vehicles,
    required this.onVehicleTap,
    this.onEditTap,
    this.onDeleteTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (vehicles.isEmpty) {
      return const EmptyStateWidget(
        icon: Icons.directions_car_outlined,
        message: 'Nenhum veículo cadastrado.',
      );
    }

    final colors = context.colors;
    final typography = context.typography;

    return ListView.separated(
      shrinkWrap: true,
      // 1. CORREÇÃO DO BUG: Força a lista a aceitar rolagem sempre,
      // matando o conflito de gestos com o BottomSheet
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      padding: const EdgeInsets.only(bottom: 24, left: 16, right: 16, top: 8),
      itemCount: vehicles.length,
      // 2. LAYOUT: Espaçamento no lugar de linhas divisórias secas
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final vehicle = vehicles[index];

        return InkWell(
          onTap: () => onVehicleTap(vehicle),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colors.outlineVariant.withOpacity(0.5)),
              boxShadow: [
                BoxShadow(
                  color: colors.shadow.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // 3. ÍCONE CUSTOMIZADO: Retângulo arredondado com nova cor
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: colors.tertiaryContainer, // Cor de fundo destacada
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    Icons.directions_car_rounded,
                    color: colors.onTertiaryContainer,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),

                // 4. INFORMAÇÕES DO VEÍCULO (Título, Placa e Km)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        vehicle.name,
                        style: typography.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colors.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        vehicle.model,
                        style: typography.bodyMedium?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          _VehicleDetail(
                            label: vehicle.licensePlate,
                            background: colors.surfaceContainerHighest,
                            foreground: colors.onSurfaceVariant,
                            emphasized: true,
                          ),
                          _VehicleDetail(
                            label: vehicle.year.toString(),
                            background: colors.surfaceContainer,
                            foreground: colors.onSurface,
                          ),
                          if (vehicle.traction?.isNotEmpty == true)
                            _VehicleDetail(
                              label: vehicle.traction!,
                              background: colors.secondaryContainer,
                              foreground: colors.onSecondaryContainer,
                            ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.speed_rounded,
                                size: 14,
                                color: colors.onSurfaceVariant,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${_formatOdometer(vehicle.defaultOdometer)} km',
                                style: typography.bodySmall?.copyWith(
                                  color: colors.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      if (vehicle.description?.trim().isNotEmpty == true) ...[
                        const SizedBox(height: 8),
                        Text(
                          vehicle.description!,
                          style: typography.bodySmall?.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),

                // 5. AÇÕES (Editar / Excluir)
                if (onEditTap != null || onDeleteTap != null)
                  _buildTrailingActions(vehicle, colors),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatOdometer(double value) =>
      value == value.truncateToDouble() ? value.toStringAsFixed(0) : '$value';

  Widget _buildTrailingActions(Vehicle vehicle, dynamic colors) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (onEditTap != null)
          IconButton(
            icon: Icon(Icons.edit_rounded, color: colors.primary, size: 22),
            tooltip: 'Editar Veículo',
            onPressed: () => onEditTap!(vehicle),
          ),
        if (onDeleteTap != null)
          IconButton(
            icon: Icon(
              Icons.delete_outline_rounded,
              color: colors.error,
              size: 22,
            ),
            tooltip: 'Excluir Veículo',
            onPressed: () => onDeleteTap!(vehicle),
          ),
      ],
    );
  }
}

class _VehicleDetail extends StatelessWidget {
  final String label;
  final Color background;
  final Color foreground;
  final bool emphasized;

  const _VehicleDetail({
    required this.label,
    required this.background,
    required this.foreground,
    this.emphasized = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(6),
        border: emphasized
            ? Border.all(color: context.colors.outlineVariant)
            : null,
      ),
      child: Text(
        label,
        style:
            (emphasized
                    ? context.typography.labelMedium
                    : context.typography.labelSmall)
                ?.copyWith(
                  color: foreground,
                  fontWeight: emphasized ? FontWeight.w700 : null,
                ),
      ),
    );
  }
}
