import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/theme_extensions.dart';
import '../../models/nivel_bolha_state.dart';

/// Seletor de modo do Nível Bolha (Automático, Circular 2D, Tubular T).
class BubbleModeSelector extends StatelessWidget {
  final BubbleDisplayMode currentMode;
  final ValueChanged<BubbleDisplayMode> onModeChanged;

  const BubbleModeSelector({
    super.key,
    required this.currentMode,
    required this.onModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDark = context.isDarkMode;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF14241F) : const Color(0xFFE9F0EC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.6),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          _ModeButton(
            title: 'Auto',
            icon: Icons.autorenew_rounded,
            isSelected: currentMode == BubbleDisplayMode.auto,
            onTap: () => onModeChanged(BubbleDisplayMode.auto),
          ),
          const SizedBox(width: 4),
          _ModeButton(
            title: 'Circular 2D',
            icon: Icons.track_changes_rounded,
            isSelected: currentMode == BubbleDisplayMode.circular2D,
            onTap: () => onModeChanged(BubbleDisplayMode.circular2D),
          ),
          const SizedBox(width: 4),
          _ModeButton(
            title: 'Tubular T',
            icon: Icons.splitscreen_rounded,
            isSelected: currentMode == BubbleDisplayMode.tubularT,
            onTap: () => onModeChanged(BubbleDisplayMode.tubularT),
          ),
        ],
      ),
    );
  }
}

class _ModeButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _ModeButton({
    required this.title,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDark = context.isDarkMode;

    final selectedBg = isDark ? AppColors.primary : AppColors.primary;
    final selectedFg = Colors.white;
    final unselectedFg = isDark ? colors.onSurfaceVariant : const Color(0xFF4A5568);

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? selectedBg : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 16,
                  color: isSelected ? selectedFg : unselectedFg,
                ),
                const SizedBox(width: 6),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? selectedFg : unselectedFg,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
