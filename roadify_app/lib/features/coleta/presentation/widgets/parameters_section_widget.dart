import 'package:flutter/material.dart';
import 'package:roadify_app/features/coleta/presentation/widgets/acquisition_parameters_section.dart';
import 'package:roadify_app/features/coleta/presentation/widgets/section_divider.dart';
import 'package:roadify_app/features/coleta/presentation/widgets/sensor/optional_sensors_section.dart';
import 'package:roadify_app/features/coleta/presentation/widgets/sensor/required_sensors_section.dart';
import 'package:roadify_app/features/coleta/presentation/widgets/sensor/sensor_option.dart';
import 'package:roadify_app/features/coleta/viewmodels/coleta_viewmodel.dart';

import '../../../../core/theme/app_dimensions.dart';

class ParametersSectionWidget extends StatefulWidget {
  final Set<SensorColeta> sensoresSelecionados;
  final SensorSelectionChanged onSensorChanged;
  final int taxaAquisicaoHz;
  final ValueChanged<int> onTaxaAquisicaoChanged;
  final TextEditingController frequenciaGpsController;
  final TextEditingController intervaloMetrosController;
  final String? erroSelecaoSensores;
  final OptionalSensorSettings optionalSensorSettings;
  final ValueChanged<OptionalSensorSettings> onOptionalSettingsChanged;

  const ParametersSectionWidget({
    super.key,
    required this.sensoresSelecionados,
    required this.onSensorChanged,
    required this.taxaAquisicaoHz,
    required this.onTaxaAquisicaoChanged,
    required this.frequenciaGpsController,
    required this.intervaloMetrosController,
    required this.optionalSensorSettings,
    required this.onOptionalSettingsChanged,
    this.erroSelecaoSensores,
  });

  @override
  State<ParametersSectionWidget> createState() =>
      _ParametersSectionWidgetState();
}

class _ParametersSectionWidgetState extends State<ParametersSectionWidget> {
  late final TextEditingController _accelerometerFrequencyController;

  @override
  void initState() {
    super.initState();
    _accelerometerFrequencyController = TextEditingController(
      text:
          RequiredSensorsSection.acelerometroPresets.contains(
            widget.taxaAquisicaoHz,
          )
          ? ''
          : widget.taxaAquisicaoHz.toString(),
    );
  }

  @override
  void dispose() {
    _accelerometerFrequencyController.dispose();
    super.dispose();
  }

  static String? _validateAccelerometerRate(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Informe a frequência.';
    }
    final rate = int.tryParse(value.trim());
    if (rate == null) return 'Informe uma frequência inteira.';
    if (rate < 50 || rate > 500) {
      return 'Use um valor entre 50 e 500 Hz.';
    }
    return null;
  }

  static String? _validateGpsRate(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Informe a frequência.';
    }
    final rate = int.tryParse(value.trim());
    if (rate == null) return 'Informe uma frequência inteira.';
    if (rate < 1 || rate > 10) return 'Use um valor entre 1 e 10 Hz.';
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

  void _updateGpsRate(int rate) {
    setState(() {
      widget.frequenciaGpsController.text = rate.toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RequiredSensorsSection(
          accelerometerRate: widget.taxaAquisicaoHz,
          onAccelerometerRateChanged: widget.onTaxaAquisicaoChanged,
          onGpsRateChanged: _updateGpsRate,
          accelerometerFrequencyController: _accelerometerFrequencyController,
          gpsFrequencyController: widget.frequenciaGpsController,
          selectionError: widget.erroSelecaoSensores,
          validateAccelerometerRate: _validateAccelerometerRate,
          validateGpsRate: _validateGpsRate,
        ),
        const SizedBox(height: AppDimensions.space20),
        const SectionDivider(icon: Icons.add_rounded),
        const SizedBox(height: AppDimensions.space20),
        OptionalSensorsSection(
          selectedSensors: widget.sensoresSelecionados,
          onSensorChanged: widget.onSensorChanged,
          settings: widget.optionalSensorSettings,
          onSettingsChanged: widget.onOptionalSettingsChanged,
        ),
        const SizedBox(height: AppDimensions.space20),
        const SectionDivider(icon: Icons.straighten_rounded),
        const SizedBox(height: AppDimensions.space20),
        AcquisitionParametersSection(
          intervalController: widget.intervaloMetrosController,
          validator: _validateInterval,
        ),
      ],
    );
  }
}
