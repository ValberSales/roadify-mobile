import 'package:flutter/material.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/theme_extensions.dart';

class ParametersSectionWidget extends StatefulWidget {
  const ParametersSectionWidget({super.key});

  @override
  State<ParametersSectionWidget> createState() =>
      _ParametersSectionWidgetState();
}

class _ParametersSectionWidgetState extends State<ParametersSectionWidget> {
  late final TextEditingController _freqSensoresController;
  late final TextEditingController _freqGpsController;
  late final TextEditingController _intervaloMetrosController;

  @override
  void initState() {
    super.initState();
    _freqSensoresController = TextEditingController(text: '100');
    _freqGpsController = TextEditingController(text: '10');
    _intervaloMetrosController = TextEditingController(text: '20');
  }

  @override
  void dispose() {
    _freqSensoresController.dispose();
    _freqGpsController.dispose();
    _intervaloMetrosController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Parâmetros de Aquisição', style: context.typography.titleMedium),
        const SizedBox(height: AppDimensions.space12),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _freqSensoresController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Sensores',
                  suffixText: 'Hz',
                  prefixIcon: Icon(Icons.speed),
                ),
              ),
            ),
            const SizedBox(width: AppDimensions.space12),
            Expanded(
              child: TextFormField(
                controller: _freqGpsController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'GPS',
                  suffixText: 'Hz',
                  prefixIcon: Icon(Icons.satellite_alt_rounded),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.space16),
        TextFormField(
          controller: _intervaloMetrosController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Gravar trecho a cada',
            suffixText: 'metros',
            prefixIcon: Icon(Icons.straighten_rounded),
          ),
        ),
      ],
    );
  }
}
