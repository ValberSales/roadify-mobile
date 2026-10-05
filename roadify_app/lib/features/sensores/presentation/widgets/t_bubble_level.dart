import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/theme_extensions.dart';
import '../../models/nivel_bolha_state.dart';

/// Widget de Nível Tubular em Formato T (Modo Smartphone em Pé / Suporte Veicular).
///
/// Apresenta dois níveis de tubo de bolha de precisão:
/// 1. Tubo Horizontal Superior: Mede o Roll (inclinação lateral do suporte/veículo).
/// 2. Tubo Vertical Central: Mede o Pitch (inclinação frontal/longitudinal da via).
class TBubbleLevel extends StatelessWidget {
  final NivelBolhaState state;

  const TBubbleLevel({
    super.key,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDark = context.isDarkMode;

    final isLevelX = state.isLevelX;
    final isLevelY = state.isLevelY;
    final isTotalLevel = state.isLevel;

    return Center(
      child: Container(
        width: 310,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF0F261F) : const Color(0xFFEBF4EE),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isTotalLevel ? AppColors.success : AppColors.primary,
            width: isTotalLevel ? 2.5 : 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: isTotalLevel
                  ? AppColors.success.withValues(alpha: 0.2)
                  : Colors.black.withValues(alpha: isDark ? 0.35 : 0.08),
              blurRadius: isTotalLevel ? 16 : 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Cabeçalho do Nível em T
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.splitscreen_rounded,
                      size: 18,
                      color: isTotalLevel ? AppColors.success : AppColors.primary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'NÍVEL TUBULAR (T)',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                        color: isTotalLevel ? AppColors.success : colors.onSurface,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: (isTotalLevel ? AppColors.success : AppColors.primary).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    isTotalLevel ? 'NIVELADO' : 'AJUSTAR',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: isTotalLevel ? AppColors.success : AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // 1. Tubo Horizontal (Barra superior do T) - Eixo Roll / Lateral
            _HorizontalTubeWidget(
              angle: state.calibratedAngleX,
              isLevel: isLevelX,
              isDark: isDark,
            ),

            const SizedBox(height: 10),

            // 2. Tubo Vertical (Caule do T) - Eixo Pitch / Frontal
            _VerticalTubeWidget(
              angle: state.calibratedAngleY,
              isLevel: isLevelY,
              isDark: isDark,
            ),
          ],
        ),
      ),
    );
  }
}

/// Tubo horizontal de bolha para o nível em T.
class _HorizontalTubeWidget extends StatelessWidget {
  final double angle;
  final bool isLevel;
  final bool isDark;

  const _HorizontalTubeWidget({
    required this.angle,
    required this.isLevel,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    const double tubeWidth = 270.0;
    const double tubeHeight = 42.0;
    const double bubbleWidth = 44.0;
    const double maxOffset = (tubeWidth / 2) - (bubbleWidth / 2) - 6.0;

    // Sensibilidade: deslocamento da bolha por grau
    const double pixelsPerDegree = 14.0;
    double offset = -angle * pixelsPerDegree;
    offset = offset.clamp(-maxOffset, maxOffset);

    return Column(
      children: [
        Container(
          width: tubeWidth,
          height: tubeHeight,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF071B14) : const Color(0xFFD6E8DC),
            borderRadius: BorderRadius.circular(21),
            border: Border.all(
              color: isLevel ? AppColors.success : AppColors.primary.withValues(alpha: 0.6),
              width: isLevel ? 2.0 : 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(21),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Linhas centrais de tolerância (alvo)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 1.5,
                      height: tubeHeight,
                      color: (isLevel ? AppColors.success : Colors.black45),
                    ),
                    const SizedBox(width: 48),
                    Container(
                      width: 1.5,
                      height: tubeHeight,
                      color: (isLevel ? AppColors.success : Colors.black45),
                    ),
                  ],
                ),

                // Graduações da escala
                Positioned(
                  top: 2,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _GraduationMark(label: '-5°'),
                      const SizedBox(width: 60),
                      _GraduationMark(label: '0°', isCenter: true),
                      const SizedBox(width: 60),
                      _GraduationMark(label: '+5°'),
                    ],
                  ),
                ),

                // Bolha cilíndrica horizontal
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 90),
                  curve: Curves.easeOutQuad,
                  left: (tubeWidth / 2) - (bubbleWidth / 2) + offset,
                  child: Container(
                    width: bubbleWidth,
                    height: 28,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      gradient: const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0xFFE2FBD3),
                          AppColors.limeAccent,
                          Color(0xFF65A30D),
                        ],
                      ),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.8),
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.25),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                        if (isLevel)
                          BoxShadow(
                            color: AppColors.limeAccent.withValues(alpha: 0.7),
                            blurRadius: 8,
                            spreadRadius: 1,
                          ),
                      ],
                    ),
                    child: Center(
                      child: Container(
                        width: 12,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.8),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Tubo vertical de bolha para o nível em T.
class _VerticalTubeWidget extends StatelessWidget {
  final double angle;
  final bool isLevel;
  final bool isDark;

  const _VerticalTubeWidget({
    required this.angle,
    required this.isLevel,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    const double tubeWidth = 42.0;
    const double tubeHeight = 210.0;
    const double bubbleHeight = 44.0;
    const double maxOffset = (tubeHeight / 2) - (bubbleHeight / 2) - 6.0;

    // Sensibilidade: deslocamento da bolha por grau
    const double pixelsPerDegree = 14.0;
    double offset = angle * pixelsPerDegree;
    offset = offset.clamp(-maxOffset, maxOffset);

    return Container(
      width: tubeWidth,
      height: tubeHeight,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF071B14) : const Color(0xFFD6E8DC),
        borderRadius: BorderRadius.circular(21),
        border: Border.all(
          color: isLevel ? AppColors.success : AppColors.primary.withValues(alpha: 0.6),
          width: isLevel ? 2.0 : 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(21),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Linhas de tolerância centrais verticais
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: tubeWidth,
                  height: 1.5,
                  color: (isLevel ? AppColors.success : Colors.black45),
                ),
                const SizedBox(height: 48),
                Container(
                  width: tubeWidth,
                  height: 1.5,
                  color: (isLevel ? AppColors.success : Colors.black45),
                ),
              ],
            ),

            // Graduações da escala vertical
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    _GraduationMark(label: '-5°'),
                    _GraduationMark(label: '0°', isCenter: true),
                    _GraduationMark(label: '+5°'),
                  ],
                ),
              ),
            ),

            // Bolha cilíndrica vertical
            AnimatedPositioned(
              duration: const Duration(milliseconds: 90),
              curve: Curves.easeOutQuad,
              top: (tubeHeight / 2) - (bubbleHeight / 2) + offset,
              child: Container(
                width: 28,
                height: bubbleHeight,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  gradient: const LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      Color(0xFFE2FBD3),
                      AppColors.limeAccent,
                      Color(0xFF65A30D),
                    ],
                  ),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.8),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.25),
                      blurRadius: 4,
                      offset: const Offset(2, 0),
                    ),
                    if (isLevel)
                      BoxShadow(
                        color: AppColors.limeAccent.withValues(alpha: 0.7),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                  ],
                ),
                child: Center(
                  child: Container(
                    width: 4,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GraduationMark extends StatelessWidget {
  final String label;
  final bool isCenter;

  const _GraduationMark({required this.label, this.isCenter = false});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 9,
        fontWeight: isCenter ? FontWeight.bold : FontWeight.w500,
        color: isCenter ? AppColors.primary : Colors.black45,
      ),
    );
  }
}
