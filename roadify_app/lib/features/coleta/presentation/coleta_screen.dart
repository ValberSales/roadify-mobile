import 'package:flutter/material.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/theme_extensions.dart';

/// Tela de Coleta (Feature Coleta — Alocada para o Dev 2).
///
/// Interface com o formulário de parâmetros pré-inspeção estilizada pelo tema.
class ColetaScreen extends StatelessWidget {
  const ColetaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nova Coleta'),
        centerTitle: false,
      ),
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppDimensions.space20,
            AppDimensions.space12,
            AppDimensions.space20,
            AppDimensions.pillDockHeight + AppDimensions.pillDockMarginBottom + 40,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Identificação do Trecho', style: typography.titleMedium),
              const SizedBox(height: AppDimensions.space12),
              TextFormField(
                initialValue: 'BR-101 • Trecho Norte',
                decoration: const InputDecoration(
                  labelText: 'Nome da Coleta / Rodovia',
                  prefixIcon: Icon(Icons.edit_road_rounded),
                ),
              ),
              const SizedBox(height: AppDimensions.space16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      initialValue: 'SUV',
                      decoration: const InputDecoration(
                        labelText: 'Veículo',
                        prefixIcon: Icon(Icons.directions_car_rounded),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppDimensions.space12),
                  Expanded(
                    child: TextFormField(
                      initialValue: 'RDL-2042',
                      decoration: const InputDecoration(
                        labelText: 'Placa',
                        prefixIcon: Icon(Icons.badge_rounded),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.space24),
              Text('Parâmetros de Aquisição', style: typography.titleMedium),
              const SizedBox(height: AppDimensions.space12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      initialValue: '100',
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Sensores (Hz)',
                        suffixText: 'Hz',
                      ),
                    ),
                  ),
                  const SizedBox(width: AppDimensions.space12),
                  Expanded(
                    child: TextFormField(
                      initialValue: '10',
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'GPS (Hz)',
                        suffixText: 'Hz',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.space16),
              TextFormField(
                initialValue: '20',
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Gravar trecho a cada N metros',
                  suffixText: 'metros',
                  prefixIcon: Icon(Icons.straighten_rounded),
                ),
              ),
              const SizedBox(height: AppDimensions.space24),
              Container(
                padding: const EdgeInsets.all(AppDimensions.space16),
                decoration: BoxDecoration(
                  color: colors.surfaceContainerHighest.withValues(alpha: 0.5),
                  borderRadius: AppDimensions.borderRadiusMedium,
                  border: Border.all(color: colors.outlineVariant),
                ),
                child: Row(
                  children: [
                    Icon(Icons.description_outlined, color: colors.primary),
                    const SizedBox(width: AppDimensions.space12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Formato do Arquivo', style: typography.titleSmall),
                          Text('CSV • separador ponto e vírgula (;)', style: typography.bodySmall),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppDimensions.space32),
              SizedBox(
                width: double.infinity,
                height: AppDimensions.buttonHeight,
                child: FilledButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Fluxo de coleta do Dev 2 iniciado.')),
                    );
                  },
                  icon: const Icon(Icons.play_circle_fill_rounded),
                  label: const Text('Continuar para Seleção de Sensores'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
