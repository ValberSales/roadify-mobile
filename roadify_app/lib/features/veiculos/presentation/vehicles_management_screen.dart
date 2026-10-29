import 'package:flutter/material.dart';
import 'package:roadify_app/core/database/app_database.dart';
import 'package:roadify_app/core/di/setup_locator.dart';
import 'package:roadify_app/core/theme/app_dimensions.dart';
import 'package:roadify_app/core/utils/snackbar_helper.dart';
import 'package:roadify_app/features/veiculos/presentation/vehicle_ui_helper.dart';
import 'package:roadify_app/features/veiculos/presentation/widgets/list/vehicle_list_widget.dart';
import 'package:roadify_app/features/veiculos/viewmodels/vehicle_viewmodel.dart';

/// Tela de Gestão de Veículos vinculada à Tela de Configurações (SP2-08).
///
/// Permite listar, cadastrar, editar, excluir e selecionar o veículo padrão para as coletas.
class VehiclesManagementScreen extends StatefulWidget {
  final VehicleViewModel? viewModel;
  final ValueChanged<Vehicle>? onDefaultVehicleSelected;

  const VehiclesManagementScreen({
    super.key,
    this.viewModel,
    this.onDefaultVehicleSelected,
  });

  @override
  State<VehiclesManagementScreen> createState() =>
      _VehiclesManagementScreenState();
}

class _VehiclesManagementScreenState extends State<VehiclesManagementScreen> {
  VehicleViewModel? get _viewModel =>
      widget.viewModel ??
      (getIt.isRegistered<VehicleViewModel>()
          ? getIt<VehicleViewModel>()
          : null);

  Future<void> _confirmDelete(BuildContext context, Vehicle vehicle) async {
    final vm = _viewModel;
    if (vm == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Excluir veículo'),
        content: Text('Deseja remover "${vehicle.name}" da lista de veículos?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await vm.deleteVehicle(vehicle);
      if (!context.mounted) return;
      SnackbarHelper.showSuccess(
        context,
        message: 'Veículo "${vehicle.name}" removido.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = _viewModel;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestão de Veículos'),
        actions: [
          if (vm != null)
            Padding(
              padding: const EdgeInsets.only(right: AppDimensions.space12),
              child: FilledButton.icon(
                key: const ValueKey('add-vehicle-button'),
                onPressed: () => VehicleUiHelper.showFormModal(context),
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('Novo'),
              ),
            ),
        ],
      ),
      body: vm == null
          ? const VehicleListWidget(vehicles: [], onVehicleTap: _noopVehicleTap)
          : StreamBuilder<List<Vehicle>>(
              stream: vm.activeVehiclesStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final vehicles = snapshot.data ?? const <Vehicle>[];
                return VehicleListWidget(
                  vehicles: vehicles,
                  onVehicleTap: (vehicle) {
                    widget.onDefaultVehicleSelected?.call(vehicle);
                    SnackbarHelper.showSuccess(
                      context,
                      message:
                          'Veículo padrão definido: ${vehicle.name} (${vehicle.licensePlate})',
                    );
                    Navigator.of(context).pop(vehicle);
                  },
                  onEditTap: (vehicle) =>
                      VehicleUiHelper.showFormModal(context, vehicle: vehicle),
                  onDeleteTap: (vehicle) => _confirmDelete(context, vehicle),
                );
              },
            ),
    );
  }

  static void _noopVehicleTap(Vehicle _) {}
}
