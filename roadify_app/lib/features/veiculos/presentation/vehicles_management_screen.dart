import 'package:roadify_app/l10n/app_localizations_catalog.dart';
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
        title: Text(AppLocalizations.of(context).text('deleteVehicle')),
        content: Text(
          AppLocalizations.of(context).text('removeVehicleConfirm')
              .replaceAll('{name}', vehicle.name),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(AppLocalizations.of(context).text('cancel')),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(AppLocalizations.of(context).text('delete')),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await vm.deleteVehicle(vehicle);
        if (!context.mounted) return;
        SnackbarHelper.showSuccess(
          context,
          message: AppLocalizations.of(context)
              .text('vehicleRemoved')
              .replaceAll('{name}', vehicle.name),
        );
      } catch (error) {
        if (!context.mounted) return;
        SnackbarHelper.showError(
          context,
          message: 'Não foi possível remover o veículo: $error',
        );
      }
    }
  }

  Future<void> _selectDefaultVehicle(Vehicle vehicle) async {
    final vm = _viewModel;
    if (vm == null) return;
    try {
      await vm.setDefaultVehicle(vehicle);
      if (!mounted) return;
      widget.onDefaultVehicleSelected?.call(vehicle);
      SnackbarHelper.showSuccess(
        context,
        message: AppLocalizations.of(context)
            .text('defaultVehicleSet')
            .replaceAll('{name}', vehicle.name)
            .replaceAll('{plate}', vehicle.licensePlate),
      );
      Navigator.of(context).pop(vehicle);
    } catch (error) {
      if (!mounted) return;
      SnackbarHelper.showError(
        context,
        message: 'Não foi possível definir o veículo padrão: $error',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = _viewModel;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).text('manageVehiclesTitle')),
        actions: [
          if (vm != null)
            Padding(
              padding: const EdgeInsets.only(right: AppDimensions.space12),
              child: FilledButton.icon(
                key: const ValueKey('add-vehicle-button'),
                onPressed: () => VehicleUiHelper.showFormModal(context),
                icon: const Icon(Icons.add_rounded, size: 18),
                label: Text(AppLocalizations.of(context).text('newItem')),
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
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Não foi possível carregar os veículos: ${snapshot.error}',
                      textAlign: TextAlign.center,
                    ),
                  );
                }
                final vehicles = snapshot.data ?? const <Vehicle>[];
                return VehicleListWidget(
                  vehicles: vehicles,
                  onVehicleTap: _selectDefaultVehicle,
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
