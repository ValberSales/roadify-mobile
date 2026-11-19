import 'package:flutter/material.dart';
import 'package:roadify_app/l10n/app_localizations.dart';
import 'package:roadify_app/core/database/app_database.dart';
import 'package:roadify_app/core/di/setup_locator.dart';
import 'package:roadify_app/core/theme/theme_extensions.dart';
import 'package:roadify_app/core/utils/snackbar_helper.dart';
import 'package:roadify_app/features/veiculos/presentation/widgets/form/vehicle_form_widget.dart';
import 'package:roadify_app/features/veiculos/presentation/widgets/list/vehicle_list_widget.dart';
import 'package:roadify_app/features/veiculos/viewmodels/vehicle_viewmodel.dart';

class VehicleUiHelper {
  /// Abre o modal deslizante para selecionar um veículo cadastrado (ou cadastrar/editar um).
  static Future<Vehicle?> showSelectionModal(
    BuildContext context, {
    required ValueChanged<Vehicle> onVehicleSelected,
    VehicleViewModel? viewModel,
  }) {
    final resolvedViewModel =
        viewModel ??
        (getIt.isRegistered<VehicleViewModel>()
            ? getIt<VehicleViewModel>()
            : null);

    return showModalBottomSheet<Vehicle>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => Container(
        key: const ValueKey('vehicle-selection-modal'),
        height: MediaQuery.of(sheetContext).size.height * 0.85,
        decoration: BoxDecoration(
          color: Theme.of(sheetContext).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      AppLocalizations.of(sheetContext)!.text('selectVehicle'),
                      style: sheetContext.typography.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (resolvedViewModel != null)
                    FilledButton.icon(
                      icon: const Icon(Icons.add_rounded, size: 18),
                      label: Text(
                        AppLocalizations.of(sheetContext)!.text('newItem'),
                      ),
                      onPressed: () {
                        Navigator.pop(sheetContext);
                        showFormModal(
                          context,
                          viewModel: resolvedViewModel,
                          onFormClosed: () => showSelectionModal(
                            context,
                            onVehicleSelected: onVehicleSelected,
                            viewModel: resolvedViewModel,
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: resolvedViewModel == null
                  ? VehicleListWidget(
                      vehicles: const [],
                      onVehicleTap: (_) {},
                    )
                  : StreamBuilder<List<Vehicle>>(
                      stream: resolvedViewModel.activeVehiclesStream,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        if (snapshot.hasError) {
                          return Center(
                            child: Text(
                              '${AppLocalizations.of(context)!.text('loadVehiclesError')}${snapshot.error}',
                            ),
                          );
                        }

                        return VehicleListWidget(
                          vehicles: snapshot.data ?? const [],
                          onEditTap: (vehicle) {
                            Navigator.pop(sheetContext);
                            showFormModal(
                              thisContextOrParent(context),
                              vehicle: vehicle,
                              viewModel: resolvedViewModel,
                              onFormClosed: () => showSelectionModal(
                                context,
                                onVehicleSelected: onVehicleSelected,
                                viewModel: resolvedViewModel,
                              ),
                            );
                          },
                          onVehicleTap: (vehicle) {
                            onVehicleSelected(vehicle);
                            Navigator.pop(sheetContext, vehicle);
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  static BuildContext thisContextOrParent(BuildContext context) => context;

  static void showFormModal(
    BuildContext context, {
    Vehicle? vehicle,
    VoidCallback? onFormClosed,
    VehicleViewModel? viewModel,
  }) {
    final resolvedViewModel = viewModel ?? getIt<VehicleViewModel>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => VehicleFormWidget(
        vehicleToEdit: vehicle,
        onBack: () {
          Navigator.pop(sheetContext);
          onFormClosed?.call();
        },
        onSave: (nome, modelo, placa, odometro, ano, descricao, tracao) async {
          try {
            await resolvedViewModel.saveVehicle(
              existingVehicle: vehicle,
              nome: nome,
              modelo: modelo,
              placa: placa,
              odometro: odometro,
              ano: ano,
              descricao: descricao,
              tracao: tracao,
            );

            if (!sheetContext.mounted) return;
            Navigator.pop(sheetContext);

            if (context.mounted) {
              SnackbarHelper.showSuccess(
                context,
                message: AppLocalizations.of(
                  context,
                )!.text('saveVehicleSuccess'),
              );
            }

            onFormClosed?.call();
          } catch (error, stackTrace) {
            debugPrint('Falha ao salvar veículo: $error');
            debugPrintStack(stackTrace: stackTrace);

            if (!context.mounted) return;

            SnackbarHelper.showError(
              context,
              message: AppLocalizations.of(context)!.text('saveVehicleError'),
            );
          }
        },
      ),
    );
  }
}
