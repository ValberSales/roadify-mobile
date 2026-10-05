import 'package:flutter/material.dart';
import 'package:roadify_app/core/theme/theme_extensions.dart';

class EmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String message;

  const EmptyStateWidget({
    super.key,
    required this.icon,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          // Força a rolagem para evitar conflitos em BottomSheets e Listas
          physics: const AlwaysScrollableScrollPhysics(),
          child: Container(
            height: constraints.maxHeight,
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 48, color: colors.primary.withOpacity(0.5)),
                  const SizedBox(height: 16),
                  Text(
                    message,
                    textAlign:
                        TextAlign.center, // Centraliza textos mais longos
                    style: typography.bodyMedium?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
