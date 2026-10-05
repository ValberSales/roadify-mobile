import 'package:flutter/material.dart';
import 'package:roadify_app/core/database/app_database.dart';
import 'package:roadify_app/core/theme/theme_extensions.dart';
import 'package:roadify_app/features/veiculos/presentation/widgets/form/vehicle_form_controller.dart';

typedef OnSaveVehicle =
    Future<void> Function(
      String nome,
      String modelo,
      String placa,
      double odometro,
      int ano,
      String? descricao,
      String? tracao,
    );

class VehicleFormWidget extends StatefulWidget {
  final Vehicle? vehicleToEdit;
  final VoidCallback onBack;
  final OnSaveVehicle onSave;

  const VehicleFormWidget({
    super.key,
    this.vehicleToEdit,
    required this.onSave,
    required this.onBack,
  });

  @override
  State<VehicleFormWidget> createState() => _VehicleFormWidgetState();
}

class _VehicleFormWidgetState extends State<VehicleFormWidget> {
  late final VehicleFormController _controller;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _controller = VehicleFormController(vehicleToEdit: widget.vehicleToEdit);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);
    try {
      await _controller.submit(widget.onSave);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // 1. COMPONENTE: Cabeçalho
          _FormHeader(
            isEditing: widget.vehicleToEdit != null,
            onBack: widget.onBack,
          ),
          const Divider(height: 1),

          // 2. COMPONENTE: Corpo do Formulário
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                top: 24,
                left: 24,
                right: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Form(
                key: _controller.formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 3. COMPONENTE: Campos de Input
                    _FormInputFields(controller: _controller),

                    const SizedBox(height: 32),

                    // 4. COMPONENTE: Botão de Salvar
                    _SubmitButton(isSaving: _isSaving, onPressed: _submit),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// WIDGETS PRIVADOS (COMPONENTES EXTRAÍDOS)
// ============================================================================

class _FormHeader extends StatelessWidget {
  final bool isEditing;
  final VoidCallback onBack;

  const _FormHeader({required this.isEditing, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 16, 16, 8),
      child: Row(
        children: [
          IconButton(icon: const Icon(Icons.arrow_back), onPressed: onBack),
          Expanded(
            child: Text(
              isEditing ? 'Editar Veículo' : 'Cadastrar Veículo',
              style: context.typography.titleLarge,
            ),
          ),
        ],
      ),
    );
  }
}

class _SubmitButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isSaving;

  const _SubmitButton({required this.onPressed, required this.isSaving});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return SizedBox(
      height: 56,
      child: FilledButton(
        style: FilledButton.styleFrom(backgroundColor: colors.primary),
        onPressed: isSaving ? null : onPressed,
        child: isSaving
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: colors.onPrimary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Salvando...',
                    style: context.typography.labelLarge?.copyWith(
                      color: colors.onPrimary,
                    ),
                  ),
                ],
              )
            : Text(
                'Salvar Veículo',
                style: context.typography.labelLarge?.copyWith(
                  color: colors.onPrimary,
                ),
              ),
      ),
    );
  }
}

class _FormInputFields extends StatelessWidget {
  final VehicleFormController controller;

  const _FormInputFields({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextFormField(
          controller: controller.nomeController,
          decoration: const InputDecoration(
            labelText: 'Identificação (Ex: Caminhonete 01)',
          ),
          validator: (val) =>
              controller.validateText(val, max: 30), // Correção aplicada aqui!
        ),
        const SizedBox(height: 16),

        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: TextFormField(
                controller: controller.modeloController,
                decoration: const InputDecoration(
                  labelText: 'Marca / Modelo (Ex: Toyota Hilux)',
                ),
                validator: (val) => controller.validateText(val, max: 30),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 1,
              child: TextFormField(
                controller: controller.anoController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Ano'),
                validator: controller.validateYear,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        TextFormField(
          controller: controller.placaController,
          textCapitalization: TextCapitalization.characters,
          decoration: const InputDecoration(labelText: 'Placa'),
          validator: controller.validatePlate,
        ),
        const SizedBox(height: 16),

        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                initialValue: controller.tracaoSelecionada,
                decoration: const InputDecoration(
                  labelText: 'Tração (Opcional)',
                ),
                items: const [
                  DropdownMenuItem(value: '4x2', child: Text('4x2')),
                  DropdownMenuItem(value: '4x4', child: Text('4x4')),
                  DropdownMenuItem(value: 'AWD', child: Text('AWD')),
                ],
                onChanged: (val) => controller.tracaoSelecionada = val,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        TextFormField(
          controller: controller.odometroController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(labelText: 'Odômetro Padrão (km)'),
          validator: controller.validateOdometer,
        ),
        const SizedBox(height: 16),

        TextFormField(
          controller: controller.descricaoController,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Observações / Descrição (Opcional)',
            alignLabelWithHint: true,
          ),
          validator: controller.validateDescription,
        ),
      ],
    );
  }
}
