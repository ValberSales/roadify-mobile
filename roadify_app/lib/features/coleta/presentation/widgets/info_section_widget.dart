import 'package:flutter/material.dart';
import 'package:roadify_app/core/database/app_database.dart';
import 'package:roadify_app/core/di/setup_locator.dart';
import 'package:roadify_app/features/veiculos/viewmodels/vehicle_viewmodel.dart';
import 'package:roadify_app/features/veiculos/presentation/vehicle_ui_helper.dart';
import 'package:roadify_app/features/veiculos/presentation/widgets/list/vehicle_list_widget.dart';

import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/theme_extensions.dart';

class IdentificacaoSectionWidget extends StatefulWidget {
  const IdentificacaoSectionWidget({super.key});

  @override
  State<IdentificacaoSectionWidget> createState() =>
      _IdentificacaoSectionWidgetState();
}

class _IdentificacaoSectionWidgetState
    extends State<IdentificacaoSectionWidget> {
  late final TextEditingController _trechoController;
  late final TextEditingController _veiculoController;
  late final TextEditingController _placaController;

  @override
  void initState() {
    super.initState();
    _trechoController = TextEditingController(text: 'BR-101 • Trecho Norte');
    _veiculoController = TextEditingController(text: 'Selecione um veículo');
    _placaController = TextEditingController(text: '-');
  }

  @override
  void dispose() {
    _trechoController.dispose();
    _veiculoController.dispose();
    _placaController.dispose();
    super.dispose();
  }

  void _abrirModalSelecaoVeiculo() {
    final vehicleViewModel = getIt<VehicleViewModel>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Garante expansão de altura
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        height: MediaQuery.of(context).size.height * 0.9, // 90% da tela
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
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
                    'Selecione o Veículo',
                    style: context.typography.titleLarge,
                  ),
                  FilledButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text('Novo'),
                    onPressed: () {
                      Navigator.pop(context); // Fecha a lista

                      // Chama o formulário passando a função para REABRIR a lista ao fechar
                      VehicleUiHelper.showFormModal(
                        context,
                        onFormClosed: () => _abrirModalSelecaoVeiculo(),
                      );
                    },
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            // O EXPANDED AQUI É O QUE RESOLVE O BUG VISUAL AO ARRASTAR A LISTA PARA CIMA!
            Expanded(
              child: StreamBuilder<List<Vehicle>>(
                stream: vehicleViewModel.activeVehiclesStream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final vehicles = snapshot.data ?? [];
                  return VehicleListWidget(
                    vehicles: vehicles,
                    onEditTap: (vehicle) {
                      Navigator.pop(this.context);
                      VehicleUiHelper.showFormModal(
                        this.context,
                        vehicle: vehicle,
                        onFormClosed: () => _abrirModalSelecaoVeiculo(),
                      );
                    },
                    onVehicleTap: (veiculo) {
                      setState(() {
                        _veiculoController.text =
                            '${veiculo.name} · ${veiculo.model}';
                        _placaController.text = veiculo.licensePlate;
                      });
                      Navigator.pop(context);
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Identificação do Trecho', style: context.typography.titleMedium),
        const SizedBox(height: AppDimensions.space12),
        TextFormField(
          controller: _trechoController,
          decoration: const InputDecoration(
            labelText: 'Nome da Coleta / Rodovia',
            prefixIcon: Icon(Icons.edit_road_rounded),
          ),
          validator: (val) => val == null || val.isEmpty ? 'Obrigatório' : null,
        ),
        const SizedBox(height: AppDimensions.space16),
        Row(
          children: [
            Expanded(
              flex: 3,
              child: InkWell(
                onTap: _abrirModalSelecaoVeiculo,
                child: IgnorePointer(
                  child: TextFormField(
                    controller: _veiculoController,
                    decoration: const InputDecoration(
                      labelText: 'Veículo',
                      prefixIcon: Icon(Icons.directions_car_rounded),
                      suffixIcon: Icon(Icons.arrow_drop_down),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppDimensions.space12),
            Expanded(
              flex: 2,
              child: TextFormField(
                controller: _placaController,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Placa',
                  filled: true,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
