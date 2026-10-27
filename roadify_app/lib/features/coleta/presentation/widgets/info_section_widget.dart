import 'package:flutter/material.dart';
import 'package:roadify_app/core/database/app_database.dart';
import 'package:roadify_app/core/di/setup_locator.dart';
import 'package:roadify_app/core/theme/theme_extensions.dart';
import 'package:roadify_app/features/coleta/presentation/widgets/vehicle/selected_vehicle_card.dart';
import 'package:roadify_app/features/veiculos/presentation/vehicle_ui_helper.dart';
import 'package:roadify_app/features/veiculos/presentation/widgets/list/vehicle_list_widget.dart';
import 'package:roadify_app/features/veiculos/viewmodels/vehicle_viewmodel.dart';

import '../../../../core/theme/app_dimensions.dart';

class IdentificacaoSectionWidget extends StatefulWidget {
  final ValueChanged<CollectionIdentification> onChanged;

  const IdentificacaoSectionWidget({super.key, required this.onChanged});

  @override
  State<IdentificacaoSectionWidget> createState() =>
      _IdentificacaoSectionWidgetState();
}

class _IdentificacaoSectionWidgetState
    extends State<IdentificacaoSectionWidget> {
  late final TextEditingController _collectionNameController;
  Vehicle? _selectedVehicle;

  @override
  void initState() {
    super.initState();
    _collectionNameController = TextEditingController(
      text: _formatDateTime(DateTime.now()),
    )..addListener(_notifyChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) => _notifyChanged());
  }

  @override
  void dispose() {
    _collectionNameController.removeListener(_notifyChanged);
    _collectionNameController.dispose();
    super.dispose();
  }

  void _notifyChanged() {
    if (!mounted) return;
    widget.onChanged(
      CollectionIdentification(
        name: _collectionNameController.text.trim(),
        vehicle: _selectedVehicle,
      ),
    );
  }

  static String _formatDateTime(DateTime dateTime) {
    String twoDigits(int value) => value.toString().padLeft(2, '0');

    return '${twoDigits(dateTime.day)}/${twoDigits(dateTime.month)}/${dateTime.year} - '
        '${twoDigits(dateTime.hour)}:${twoDigits(dateTime.minute)}';
  }

  void _abrirModalSelecaoVeiculo({
    required ValueChanged<Vehicle> onVehicleSelected,
  }) {
    final vehicleViewModel = getIt<VehicleViewModel>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => Container(
        height: MediaQuery.of(sheetContext).size.height * 0.9,
        decoration: BoxDecoration(
          color: Theme.of(sheetContext).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Selecione o veículo',
                    style: context.typography.titleLarge,
                  ),
                  FilledButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text('Novo'),
                    onPressed: () {
                      Navigator.pop(sheetContext);
                      VehicleUiHelper.showFormModal(
                        context,
                        onFormClosed: () => _abrirModalSelecaoVeiculo(
                          onVehicleSelected: onVehicleSelected,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: StreamBuilder<List<Vehicle>>(
                stream: vehicleViewModel.activeVehiclesStream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Não foi possível carregar os veículos: '
                        '${snapshot.error}',
                      ),
                    );
                  }

                  return VehicleListWidget(
                    vehicles: snapshot.data ?? [],
                    onEditTap: (vehicle) {
                      Navigator.pop(sheetContext);
                      VehicleUiHelper.showFormModal(
                        context,
                        vehicle: vehicle,
                        onFormClosed: () => _abrirModalSelecaoVeiculo(
                          onVehicleSelected: onVehicleSelected,
                        ),
                      );
                    },
                    onVehicleTap: (vehicle) {
                      onVehicleSelected(vehicle);
                      Navigator.pop(sheetContext);
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

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Identificação', style: context.typography.titleMedium),
        const SizedBox(height: AppDimensions.space12),
        TextFormField(
          key: const ValueKey('collection-name-field'),
          controller: _collectionNameController,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(
            labelText: 'Nome da coleta',
            prefixIcon: Icon(Icons.edit_road_rounded),
          ),
          validator: (value) => value == null || value.trim().isEmpty
              ? 'Informe o nome da coleta.'
              : null,
        ),
        const SizedBox(height: AppDimensions.space16),
        FormField<Vehicle>(
          key: const ValueKey('collection-vehicle-field'),
          validator: (vehicle) =>
              vehicle == null ? 'Selecione um veículo para a coleta.' : null,
          builder: (fieldState) {
            final vehicle = _selectedVehicle;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (vehicle == null)
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      key: const ValueKey('select-collection-vehicle'),
                      onPressed: () => _abrirModalSelecaoVeiculo(
                        onVehicleSelected: (selectedVehicle) {
                          setState(() => _selectedVehicle = selectedVehicle);
                          fieldState.didChange(selectedVehicle);
                          _notifyChanged();
                        },
                      ),
                      icon: const Icon(Icons.directions_car_rounded),
                      label: const Text('Selecionar veículo *'),
                      style: OutlinedButton.styleFrom(
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDimensions.space16,
                          vertical: AppDimensions.space16,
                        ),
                      ),
                    ),
                  )
                else
                  SelectedVehicleCard(
                    vehicle: vehicle,
                    onChange: () => _abrirModalSelecaoVeiculo(
                      onVehicleSelected: (selectedVehicle) {
                        setState(() => _selectedVehicle = selectedVehicle);
                        fieldState.didChange(selectedVehicle);
                        _notifyChanged();
                      },
                    ),
                  ),
                if (fieldState.errorText != null) ...[
                  const SizedBox(height: AppDimensions.space4),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      fieldState.errorText!,
                      style: context.typography.bodySmall?.copyWith(
                        color: colors.error,
                      ),
                    ),
                  ),
                ],
              ],
            );
          },
        ),
      ],
    );
  }
}

class CollectionIdentification {
  final String name;
  final Vehicle? vehicle;

  const CollectionIdentification({required this.name, required this.vehicle});
}
