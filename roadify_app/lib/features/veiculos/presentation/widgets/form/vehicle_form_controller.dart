import 'package:flutter/material.dart';
import 'package:roadify_app/core/database/app_database.dart';

class VehicleFormController {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  late final TextEditingController nomeController;
  late final TextEditingController modeloController;
  late final TextEditingController placaController;
  late final TextEditingController odometroController;
  late final TextEditingController anoController;
  late final TextEditingController descricaoController;

  String? tracaoSelecionada;

  VehicleFormController({Vehicle? vehicleToEdit}) {
    nomeController = TextEditingController(text: vehicleToEdit?.name ?? '');
    modeloController = TextEditingController(text: vehicleToEdit?.model ?? '');
    placaController = TextEditingController(
      text: vehicleToEdit?.licensePlate ?? '',
    );
    descricaoController = TextEditingController(
      text: vehicleToEdit?.description ?? '',
    );
    odometroController = TextEditingController(
      text: vehicleToEdit != null
          ? vehicleToEdit.defaultOdometer.toString()
          : '',
    );
    anoController = TextEditingController(
      text: vehicleToEdit != null ? vehicleToEdit.year.toString() : '',
    );
    tracaoSelecionada = vehicleToEdit?.traction;
  }

  // 1. Validação Genérica de Texto (Nome e Modelo)
  String? validateText(String? value, {int min = 2, int max = 50}) {
    if (value == null || value.trim().isEmpty) return 'Obrigatório';
    final length = value.trim().length;
    if (length < min) return 'Mínimo de $min caracteres';
    if (length > max) return 'Máximo de $max caracteres';
    return null;
  }

  // 2. Validação da Placa (Regex Mercosul e Antiga)
  String? validatePlate(String? value) {
    if (value == null || value.trim().isEmpty) return 'Obrigatório';

    // Remove hifens e espaços para validar apenas os caracteres
    final normalized = value.trim().toUpperCase().replaceAll(
      RegExp(r'[-\s]'),
      '',
    );

    // Aceita ABC1234 (Antiga) ou ABC1D23 (Mercosul)
    final plateRegex = RegExp(r'^[A-Z]{3}\d[A-Z]\d{2}$|^[A-Z]{3}\d{4}$');

    if (!plateRegex.hasMatch(normalized)) {
      return 'Placa inválida (Ex: ABC-1234 ou ABC1D23)';
    }
    return null;
  }

  // 3. Validação do Ano (Min/Max realistas)
  String? validateYear(String? value) {
    if (value == null || value.trim().isEmpty) return 'Obrigatório';
    final year = int.tryParse(value.trim());
    final currentYear = DateTime.now().year;

    if (year == null) return 'Ano inválido';
    if (year < 1950) return 'Ano muito antigo (Min: 1950)';
    if (year > currentYear + 1) return 'Ano futuro inválido';
    return null;
  }

  // 4. Validação do Odômetro (Impede negativos e absurdos)
  String? validateOdometer(String? value) {
    if (value == null || value.trim().isEmpty) return 'Obrigatório';

    final sanitizedValue = value.trim().replaceAll(',', '.');
    final km = double.tryParse(sanitizedValue);

    if (km == null || !km.isFinite) return 'Valor numérico inválido';
    if (km < 0) return 'Não pode ser negativo';
    if (km > 2000000) return 'Valor máximo excedido';
    return null;
  }

  // 5. Validação Opcional para Descrição
  String? validateDescription(String? value) {
    if (value != null && value.trim().length > 250) {
      return 'Máximo de 250 caracteres alcançado';
    }
    return null;
  }

  // Formata a placa corretamente antes de enviar para o SQLite
  String _formatPlateForDatabase(String rawPlate) {
    final clean = rawPlate.trim().toUpperCase().replaceAll(
      RegExp(r'[-\s]'),
      '',
    );
    final regexAntiga = RegExp(r'^[A-Z]{3}\d{4}$');

    if (regexAntiga.hasMatch(clean)) {
      return '${clean.substring(0, 3)}-${clean.substring(3)}'; // ABC-1234
    }
    return clean; // ABC1D23
  }

  Future<void> submit(
    Future<void> Function(String, String, String, double, int, String?, String?)
    onSave,
  ) {
    if (formKey.currentState?.validate() != true) return Future.value();

    final odometro = double.tryParse(
      odometroController.text.trim().replaceAll(',', '.'),
    );
    final ano = int.tryParse(anoController.text.trim());
    if (odometro == null || !odometro.isFinite || ano == null) {
      return Future.value();
    }

    final placaFormatada = _formatPlateForDatabase(placaController.text);
    return onSave(
      nomeController.text.trim(),
      modeloController.text.trim(),
      placaFormatada,
      odometro,
      ano,
      descricaoController.text.trim().isEmpty
          ? null
          : descricaoController.text.trim(),
      tracaoSelecionada,
    );
  }

  void dispose() {
    nomeController.dispose();
    modeloController.dispose();
    placaController.dispose();
    odometroController.dispose();
    anoController.dispose();
    descricaoController.dispose();
  }
}
