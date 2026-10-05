import 'package:flutter/material.dart';
import 'package:roadify_app/core/database/app_database.dart';
import 'package:roadify_app/core/di/setup_locator.dart';
import 'package:roadify_app/core/utils/snackbar_helper.dart';
import 'package:roadify_app/features/veiculos/presentation/widgets/form/vehicle_form_widget.dart';
import 'package:roadify_app/features/veiculos/viewmodels/vehicle_viewmodel.dart';

class VehicleUiHelper {
  static void showFormModal(
    BuildContext context, {
    Vehicle? vehicle,
    VoidCallback? onFormClosed,
  }) {
    final viewModel = getIt<VehicleViewModel>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => VehicleFormWidget(
        vehicleToEdit: vehicle,
        onBack: () {
          Navigator.pop(context);
          onFormClosed
              ?.call(); // CORREÇÃO: Chama a função apenas se ela não for nula
        },
        onSave: (nome, modelo, placa, odometro, ano, descricao, tracao) async {
          // 1. INICIA O TRY-CATCH
          try {
            await viewModel.saveVehicle(
              existingVehicle: vehicle,
              nome: nome,
              modelo: modelo,
              placa: placa,
              odometro: odometro,
              ano: ano,
              descricao: descricao,
              tracao: tracao,
            );

            // 2. VERIFICA SE O WIDGET AINDA EXISTE NA TELA APÓS O 'AWAIT'
            if (!context.mounted) return;

            Navigator.pop(context); // Fecha o formulário

            SnackbarHelper.showSuccess(
              context,
              message: 'Veículo salvo com sucesso!',
            );

            onFormClosed?.call(); // CORREÇÃO: Atualiza a lista da tela de trás
          } catch (error, stackTrace) {
            debugPrint('Falha ao salvar veículo: $error');
            debugPrintStack(stackTrace: stackTrace);

            // 3. CAPTURA O ERRO E EXIBE VISUALMENTE
            if (!context.mounted) return;

            SnackbarHelper.showError(
              context,
              message: 'Não foi possível salvar o veículo. Tente novamente.',
            );
          }
        },
      ),
    );
  }
}
