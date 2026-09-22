import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Extensão de tema para os 5 níveis da escala de qualidade do pavimento do Roadify.
class RoadQualityThemeExtension extends ThemeExtension<RoadQualityThemeExtension> {
  final Color excelente;
  final Color boa;
  final Color media;
  final Color ruim;
  final Color muitoRuim;

  const RoadQualityThemeExtension({
    required this.excelente,
    required this.boa,
    required this.media,
    required this.ruim,
    required this.muitoRuim,
  });

  static const light = RoadQualityThemeExtension(
    excelente: AppColors.qualityExcelente,
    boa: AppColors.qualityBoa,
    media: AppColors.qualityMedia,
    ruim: AppColors.qualityRuim,
    muitoRuim: AppColors.qualityMuitoRuim,
  );

  static const dark = RoadQualityThemeExtension(
    excelente: AppColors.qualityExcelente,
    boa: AppColors.qualityBoa,
    media: AppColors.qualityMedia,
    ruim: AppColors.qualityRuim,
    muitoRuim: AppColors.qualityMuitoRuim,
  );

  @override
  ThemeExtension<RoadQualityThemeExtension> copyWith({
    Color? excelente,
    Color? boa,
    Color? media,
    Color? ruim,
    Color? muitoRuim,
  }) {
    return RoadQualityThemeExtension(
      excelente: excelente ?? this.excelente,
      boa: boa ?? this.boa,
      media: media ?? this.media,
      ruim: ruim ?? this.ruim,
      muitoRuim: muitoRuim ?? this.muitoRuim,
    );
  }

  @override
  ThemeExtension<RoadQualityThemeExtension> lerp(
    covariant ThemeExtension<RoadQualityThemeExtension>? other,
    double t,
  ) {
    if (other is! RoadQualityThemeExtension) return this;
    return RoadQualityThemeExtension(
      excelente: Color.lerp(excelente, other.excelente, t) ?? excelente,
      boa: Color.lerp(boa, other.boa, t) ?? boa,
      media: Color.lerp(media, other.media, t) ?? media,
      ruim: Color.lerp(ruim, other.ruim, t) ?? ruim,
      muitoRuim: Color.lerp(muitoRuim, other.muitoRuim, t) ?? muitoRuim,
    );
  }
}

/// Extensão de tema para estilização da barra de navegação Pill Dock (OneUI / iOS).
class PillDockThemeExtension extends ThemeExtension<PillDockThemeExtension> {
  final Color backgroundColor;
  final Color borderColor;
  final Color selectedItemColor;
  final Color unselectedItemColor;
  final Color activeIndicatorColor;
  final double blurAmount;

  const PillDockThemeExtension({
    required this.backgroundColor,
    required this.borderColor,
    required this.selectedItemColor,
    required this.unselectedItemColor,
    required this.activeIndicatorColor,
    required this.blurAmount,
  });

  static final light = PillDockThemeExtension(
    backgroundColor: Colors.white.withValues(alpha: 0.88),
    borderColor: const Color(0xFFE2E8F0),
    selectedItemColor: AppColors.primary,
    unselectedItemColor: const Color(0xFF64748B),
    activeIndicatorColor: const Color(0xFFE6F4EA),
    blurAmount: 20.0,
  );

  static final dark = PillDockThemeExtension(
    backgroundColor: const Color(0xFF111E1A).withValues(alpha: 0.88),
    borderColor: const Color(0xFF233630),
    selectedItemColor: AppColors.limeAccent,
    unselectedItemColor: const Color(0xFF94A3B8),
    activeIndicatorColor: const Color(0xFF1B382C),
    blurAmount: 20.0,
  );

  @override
  ThemeExtension<PillDockThemeExtension> copyWith({
    Color? backgroundColor,
    Color? borderColor,
    Color? selectedItemColor,
    Color? unselectedItemColor,
    Color? activeIndicatorColor,
    double? blurAmount,
  }) {
    return PillDockThemeExtension(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      borderColor: borderColor ?? this.borderColor,
      selectedItemColor: selectedItemColor ?? this.selectedItemColor,
      unselectedItemColor: unselectedItemColor ?? this.unselectedItemColor,
      activeIndicatorColor: activeIndicatorColor ?? this.activeIndicatorColor,
      blurAmount: blurAmount ?? this.blurAmount,
    );
  }

  @override
  ThemeExtension<PillDockThemeExtension> lerp(
    covariant ThemeExtension<PillDockThemeExtension>? other,
    double t,
  ) {
    if (other is! PillDockThemeExtension) return this;
    return PillDockThemeExtension(
      backgroundColor: Color.lerp(backgroundColor, other.backgroundColor, t) ?? backgroundColor,
      borderColor: Color.lerp(borderColor, other.borderColor, t) ?? borderColor,
      selectedItemColor: Color.lerp(selectedItemColor, other.selectedItemColor, t) ?? selectedItemColor,
      unselectedItemColor: Color.lerp(unselectedItemColor, other.unselectedItemColor, t) ?? unselectedItemColor,
      activeIndicatorColor: Color.lerp(activeIndicatorColor, other.activeIndicatorColor, t) ?? activeIndicatorColor,
      blurAmount: (blurAmount + (other.blurAmount - blurAmount) * t),
    );
  }
}

/// Extensões convenientes no BuildContext para acesso rápido a temas por qualquer membro do time.
extension ThemeContextExtensions on BuildContext {
  /// Acessa o ThemeData completo
  ThemeData get theme => Theme.of(this);

  /// Acessa o ColorScheme do Material 3
  ColorScheme get colors => theme.colorScheme;

  /// Acessa o TextTheme padronizado
  TextTheme get typography => theme.textTheme;

  /// Acessa as 5 cores de severidade de pavimento (Excelente a Muito Ruim)
  RoadQualityThemeExtension get roadQualityColors =>
      theme.extension<RoadQualityThemeExtension>() ?? RoadQualityThemeExtension.light;

  /// Acessa os tokens da barra de navegação Pill Dock
  PillDockThemeExtension get pillDockTheme =>
      theme.extension<PillDockThemeExtension>() ?? PillDockThemeExtension.light;

  /// Verifica se o tema atual é escuro
  bool get isDarkMode => theme.brightness == Brightness.dark;
}
