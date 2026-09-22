import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_dimensions.dart';
import '../theme/theme_extensions.dart';

/// Item de navegação para a barra Pill Dock.
class PillDockItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const PillDockItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}

/// Scaffold principal com a barra de navegação flutuante em formato de pílula (Pill Dock),
/// inspirada no Samsung Galaxy OneUI e aplicações nativas do iOS.
class PillDockScaffold extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onIndexChanged;
  final List<Widget> pages;
  final PreferredSizeWidget? appBar;

  const PillDockScaffold({
    super.key,
    required this.currentIndex,
    required this.onIndexChanged,
    required this.pages,
    this.appBar,
  });

  static const List<PillDockItem> items = [
    PillDockItem(
      icon: Icons.home_outlined,
      activeIcon: Icons.home_rounded,
      label: 'Início',
    ),
    PillDockItem(
      icon: Icons.play_circle_outline_rounded,
      activeIcon: Icons.play_circle_fill_rounded,
      label: 'Coleta',
    ),
    PillDockItem(
      icon: Icons.sensors_outlined,
      activeIcon: Icons.sensors_rounded,
      label: 'Sensores',
    ),
    PillDockItem(
      icon: Icons.folder_outlined,
      activeIcon: Icons.folder_rounded,
      label: 'Dados',
    ),
    PillDockItem(
      icon: Icons.settings_outlined,
      activeIcon: Icons.settings_rounded,
      label: 'Config',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final dockTheme = context.pillDockTheme;

    return Scaffold(
      appBar: appBar,
      extendBody: true, // Permite que o body role por trás da dock translúcida
      body: IndexedStack(
        index: currentIndex,
        children: pages,
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        left: false,
        right: false,
        bottom: false,
        child: Padding(
          padding: EdgeInsets.only(
            left: AppDimensions.pillDockMarginHorizontal,
            right: AppDimensions.pillDockMarginHorizontal,
            bottom: bottomPadding > 0 ? bottomPadding + 8 : AppDimensions.pillDockMarginBottom,
          ),
          child: ClipRRect(
            borderRadius: AppDimensions.borderRadiusPill,
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: dockTheme.blurAmount,
                sigmaY: dockTheme.blurAmount,
              ),
              child: Container(
                height: AppDimensions.pillDockHeight,
                decoration: BoxDecoration(
                  color: dockTheme.backgroundColor,
                  borderRadius: AppDimensions.borderRadiusPill,
                  border: Border.all(
                    color: dockTheme.borderColor,
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: context.isDarkMode ? 0.3 : 0.08),
                      blurRadius: AppDimensions.pillDockElevation * 2,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(items.length, (index) {
                    final item = items[index];
                    final isSelected = index == currentIndex;
                    final isCenterColeta = index == 1; // Destaque na Coleta

                    return Expanded(
                      child: _PillDockButton(
                        item: item,
                        isSelected: isSelected,
                        isAccent: isCenterColeta,
                        onTap: () {
                          HapticFeedback.lightImpact();
                          onIndexChanged(index);
                        },
                      ),
                    );
                  }),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PillDockButton extends StatelessWidget {
  final PillDockItem item;
  final bool isSelected;
  final bool isAccent;
  final VoidCallback onTap;

  const _PillDockButton({
    required this.item,
    required this.isSelected,
    required this.isAccent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final dockTheme = context.pillDockTheme;
    final colors = context.colors;

    final activeColor = isAccent ? colors.primary : dockTheme.selectedItemColor;
    final inactiveColor = dockTheme.unselectedItemColor;

    return InkWell(
      onTap: onTap,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
            padding: EdgeInsets.symmetric(
              horizontal: isSelected ? 12.0 : 4.0,
              vertical: 4.0,
            ),
            decoration: BoxDecoration(
              color: isSelected
                  ? (isAccent ? colors.primary.withValues(alpha: 0.15) : dockTheme.activeIndicatorColor)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              isSelected ? item.activeIcon : item.icon,
              size: 24,
              color: isSelected ? activeColor : inactiveColor,
            ),
          ),
          const SizedBox(height: 2),
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? activeColor : inactiveColor,
              letterSpacing: -0.1,
            ),
            child: Text(
              item.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
