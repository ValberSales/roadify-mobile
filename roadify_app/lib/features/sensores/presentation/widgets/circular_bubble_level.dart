import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/theme_extensions.dart';
import '../../models/nivel_bolha_state.dart';

/// Widget de Nível Bolha Circular 2D (Modo Mesa / Superfície Horizontal).
class CircularBubbleLevel extends StatelessWidget {
  final NivelBolhaState state;

  const CircularBubbleLevel({
    super.key,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDark = context.isDarkMode;
    final isLevel = state.isLevel;

    // Dimensões do nível
    const double containerSize = 250.0;
    const double bubbleDiameter = 44.0;
    const double maxRadius = (containerSize / 2) - (bubbleDiameter / 2) - 8.0;

    // Sensibilidade: pixels por grau de inclinação
    const double pixelsPerDegree = 16.0;

    // Em uma bolha de nível real, a bolha sobe para o lado mais elevado (oposta ao vetor gravidade)
    double targetOffsetX = -state.calibratedAngleX * pixelsPerDegree;
    double targetOffsetY = state.calibratedAngleY * pixelsPerDegree;

    // Limita o deslocamento dentro do raio máximo do círculo
    final currentDistance = math.sqrt(targetOffsetX * targetOffsetX + targetOffsetY * targetOffsetY);
    if (currentDistance > maxRadius && currentDistance > 0) {
      final ratio = maxRadius / currentDistance;
      targetOffsetX *= ratio;
      targetOffsetY *= ratio;
    }

    return Center(
      child: Container(
        width: containerSize,
        height: containerSize,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isDark ? const Color(0xFF0F261F) : const Color(0xFFE8F5E9),
          border: Border.all(
            color: isLevel ? AppColors.success : AppColors.primary,
            width: isLevel ? 3.0 : 2.0,
          ),
          boxShadow: [
            BoxShadow(
              color: isLevel
                  ? AppColors.success.withValues(alpha: 0.25)
                  : Colors.black.withValues(alpha: isDark ? 0.4 : 0.08),
              blurRadius: isLevel ? 18 : 12,
              spreadRadius: isLevel ? 2 : 0,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipOval(
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Anel externo secundário (170px)
              Container(
                width: 170,
                height: 170,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.25),
                    width: 1.2,
                  ),
                ),
              ),

              // Anel de mira central / Tolerância de calibração (85px)
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: 85,
                height: 85,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isLevel
                      ? AppColors.success.withValues(alpha: 0.12)
                      : Colors.transparent,
                  border: Border.all(
                    color: isLevel
                        ? AppColors.success
                        : AppColors.primary.withValues(alpha: 0.6),
                    width: isLevel ? 2.0 : 1.2,
                  ),
                ),
              ),

              // Cruz de mira (Linha horizontal)
              Divider(
                color: AppColors.primary.withValues(alpha: 0.25),
                thickness: 1,
              ),

              // Cruz de mira (Linha vertical)
              VerticalDivider(
                color: AppColors.primary.withValues(alpha: 0.25),
                thickness: 1,
              ),

              // Círculo de centro exato
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withValues(alpha: 0.4),
                ),
              ),

              // Bolha fluida verde limão animada
              AnimatedPositioned(
                duration: const Duration(milliseconds: 90),
                curve: Curves.easeOutQuad,
                left: (containerSize / 2) - (bubbleDiameter / 2) + targetOffsetX,
                top: (containerSize / 2) - (bubbleDiameter / 2) + targetOffsetY,
                child: Container(
                  width: bubbleDiameter,
                  height: bubbleDiameter,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const RadialGradient(
                      center: Alignment(-0.3, -0.3),
                      radius: 0.8,
                      colors: [
                        Color(0xFFD9F99D), // Verde limão brilhante claro
                        AppColors.limeAccent,
                        Color(0xFF65A30D), // Sombra da bolha
                      ],
                    ),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.8),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                      if (isLevel)
                        BoxShadow(
                          color: AppColors.limeAccent.withValues(alpha: 0.8),
                          blurRadius: 10,
                          spreadRadius: 1,
                        ),
                    ],
                  ),
                  child: Center(
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                  ),
                ),
              ),

              // Leitura angular central inferior
              Positioned(
                bottom: 18,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: (isDark ? colors.surface : Colors.white).withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isLevel ? AppColors.success : colors.outlineVariant,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isLevel) ...[
                        const Icon(
                          Icons.check_circle_rounded,
                          size: 14,
                          color: AppColors.success,
                        ),
                        const SizedBox(width: 4),
                      ],
                      Text(
                        '${state.totalInclination.toStringAsFixed(1)}°',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                          color: isLevel ? AppColors.success : null,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
