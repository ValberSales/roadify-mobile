import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:roadify_app/features/coleta/viewmodels/coleta_viewmodel.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/theme_extensions.dart';

class ParametersSectionWidget extends StatelessWidget {
  final Set<SensorColeta> sensoresSelecionados;
  final SensorSelectionChanged onSensorChanged;
  final int taxaAquisicaoHz;
  final ValueChanged<int> onTaxaAquisicaoChanged;
  final TextEditingController frequenciaGpsController;
  final TextEditingController intervaloMetrosController;
  final String? erroSelecaoSensores;

  const ParametersSectionWidget({
    super.key,
    required this.sensoresSelecionados,
    required this.onSensorChanged,
    required this.taxaAquisicaoHz,
    required this.onTaxaAquisicaoChanged,
    required this.frequenciaGpsController,
    required this.intervaloMetrosController,
    this.erroSelecaoSensores,
  });

  static String? _validateGpsRate(String? value) {
    if (value == null || value.trim().isEmpty) return 'Obrigatório';
    final rate = int.tryParse(value.trim());
    if (rate == null || rate <= 0) return 'Informe uma frequência positiva';
    return null;
  }

  static String? _validateInterval(String? value) {
    if (value == null || value.trim().isEmpty) return 'Obrigatório';
    final interval = double.tryParse(value.trim().replaceAll(',', '.'));
    if (interval == null || !interval.isFinite || interval <= 0) {
      return 'Informe uma distância positiva';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final sensoresInerciaisSelecionados =
        sensoresSelecionados.contains(SensorColeta.acelerometro) ||
        sensoresSelecionados.contains(SensorColeta.giroscopio);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Sensores da coleta', style: context.typography.titleMedium),
        const SizedBox(height: AppDimensions.space12),
        _SensorOption(
          sensor: SensorColeta.acelerometro,
          title: 'Acelerômetro',
          subtitle: 'Obrigatório para a coleta inercial',
          icon: Icons.speed_rounded,
          selected: sensoresSelecionados.contains(SensorColeta.acelerometro),
          onChanged: onSensorChanged,
        ),
        const Divider(height: AppDimensions.space16),
        _SensorOption(
          sensor: SensorColeta.giroscopio,
          title: 'Giroscópio',
          subtitle: 'Opcional • movimento angular',
          icon: Icons.screen_rotation_alt_rounded,
          selected: sensoresSelecionados.contains(SensorColeta.giroscopio),
          onChanged: onSensorChanged,
        ),
        if (sensoresInerciaisSelecionados) ...[
          const SizedBox(height: AppDimensions.space8),
          Text('Frequência inercial', style: context.typography.labelLarge),
          const SizedBox(height: AppDimensions.space8),
          SegmentedButton<int>(
            segments: const [
              ButtonSegment<int>(value: 100, label: Text('100 Hz')),
              ButtonSegment<int>(value: 200, label: Text('200 Hz')),
            ],
            selected: {taxaAquisicaoHz},
            onSelectionChanged: (selection) =>
                onTaxaAquisicaoChanged(selection.first),
          ),
        ],
        const Divider(height: AppDimensions.space16),
        _SensorOption(
          sensor: SensorColeta.gps,
          title: 'GPS',
          subtitle: 'Obrigatório para geolocalização',
          icon: Icons.satellite_alt_rounded,
          selected: sensoresSelecionados.contains(SensorColeta.gps),
          onChanged: onSensorChanged,
        ),
        if (sensoresSelecionados.contains(SensorColeta.gps)) ...[
          const SizedBox(height: AppDimensions.space8),
          TextFormField(
            controller: frequenciaGpsController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(
              labelText: 'Frequência do GPS',
              suffixText: 'Hz',
            ),
            validator: _validateGpsRate,
          ),
        ],
        const Divider(height: AppDimensions.space16),
        _SensorOption(
          sensor: SensorColeta.camera,
          title: 'Câmera',
          subtitle: 'Opcional • fotos de anomalias',
          icon: Icons.photo_camera_outlined,
          selected: sensoresSelecionados.contains(SensorColeta.camera),
          onChanged: onSensorChanged,
        ),
        const Divider(height: AppDimensions.space16),
        _SensorOption(
          sensor: SensorColeta.audio,
          title: 'Áudio',
          subtitle: 'Opcional • captura durante o ensaio',
          icon: Icons.mic_none_rounded,
          selected: sensoresSelecionados.contains(SensorColeta.audio),
          onChanged: onSensorChanged,
        ),
        if (erroSelecaoSensores != null) ...[
          const SizedBox(height: AppDimensions.space8),
          Text(
            erroSelecaoSensores!,
            style: TextStyle(color: context.colors.error),
          ),
        ],
        const SizedBox(height: AppDimensions.space24),
        Text('Parâmetros de aquisição', style: context.typography.titleMedium),
        const SizedBox(height: AppDimensions.space12),
        TextFormField(
          controller: intervaloMetrosController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
          ],
          decoration: const InputDecoration(
            labelText: 'Gravar trecho a cada',
            suffixText: 'metros',
            prefixIcon: Icon(Icons.straighten_rounded),
          ),
          validator: _validateInterval,
        ),
      ],
    );
  }
}

typedef SensorSelectionChanged =
    void Function(SensorColeta sensor, bool selected);

class _SensorOption extends StatelessWidget {
  final SensorColeta sensor;
  final String title;
  final String subtitle;
  final IconData icon;
  final bool selected;
  final SensorSelectionChanged onChanged;

  const _SensorOption({
    required this.sensor,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: context.colors.primary),
        const SizedBox(width: AppDimensions.space12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: context.typography.titleSmall),
              Text(subtitle, style: context.typography.bodySmall),
            ],
          ),
        ),
        Checkbox(
          key: ValueKey('sensor-${sensor.name}-checkbox'),
          value: selected,
          onChanged: (value) => onChanged(sensor, value ?? false),
        ),
      ],
    );
  }
}
