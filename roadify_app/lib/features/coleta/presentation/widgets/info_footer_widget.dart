import 'package:flutter/material.dart';

import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/theme_extensions.dart';

class InfoFooterWidget extends StatelessWidget {
  const InfoFooterWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
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
                Text(
                  'Formato do Arquivo',
                  style: context.typography.titleSmall,
                ),
                Text(
                  'CSV • separador ponto e vírgula (;)',
                  style: context.typography.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
