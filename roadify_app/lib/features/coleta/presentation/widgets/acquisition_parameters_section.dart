import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:roadify_app/core/theme/theme_extensions.dart';
import 'package:roadify_app/features/coleta/presentation/widgets/sensor/sensor_section_heading.dart';

import '../../../../core/theme/app_dimensions.dart';

class AcquisitionParametersSection extends StatelessWidget {
  final TextEditingController intervalController;
  final String? Function(String?) validator;

  const AcquisitionParametersSection({
    super.key,
    required this.intervalController,
    required this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SensorSectionHeading(
          title: 'Parâmetros',
          subtitle: 'Defina a distância entre cada registro do percurso.',
          icon: Icons.straighten_rounded,
        ),
        const SizedBox(height: AppDimensions.space12),
        Container(
          decoration: BoxDecoration(
            color: colors.surfaceContainerLow,
            borderRadius: AppDimensions.borderRadiusCard,
            border: Border.all(color: colors.outlineVariant),
          ),
          padding: const EdgeInsets.all(AppDimensions.space12),
          child: TextFormField(
            controller: intervalController,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
            ],
            decoration: const InputDecoration(
              labelText: 'Gravar trecho a cada',
              suffixText: 'metros',
              prefixIcon: Icon(Icons.straighten_rounded),
            ),
            validator: validator,
          ),
        ),
      ],
    );
  }
}
