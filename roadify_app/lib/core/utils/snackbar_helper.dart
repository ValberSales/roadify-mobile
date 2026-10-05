import 'package:flutter/material.dart';
import 'package:roadify_app/core/theme/theme_extensions.dart';

class SnackbarHelper {
  static void showError(BuildContext context, {required String message}) {
    final colors = context.colors;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar() // Oculta o anterior se o usuário clicar várias vezes
      ..showSnackBar(
        SnackBar(
          backgroundColor: colors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          content: Row(
            children: [
              Icon(Icons.error_outline_rounded, color: colors.onError),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: context.typography.bodyMedium?.copyWith(
                    color: colors.onError,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
  }

  static void showSuccess(BuildContext context, {required String message}) {
    // Exemplo de como você pode reaproveitar a lógica para mensagens de sucesso
    final colors = context.colors;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          backgroundColor: colors.primary, // Cor verde institucional do Roadify
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          content: Row(
            children: [
              Icon(Icons.check_circle_outline_rounded, color: colors.onPrimary),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: context.typography.bodyMedium?.copyWith(
                    color: colors.onPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
  }
}
