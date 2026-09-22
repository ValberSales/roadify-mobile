import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_dimensions.dart';
import 'app_typography.dart';
import 'theme_extensions.dart';

/// Fábrica e gerenciador mestre de temas globais do Roadify Mobile.
///
/// Utiliza o FlexColorScheme para gerar esquemas Material 3 consistentes,
/// com suporte completo a modo claro/escuro e adaptações nativas para iOS e Android.
abstract final class AppTheme {
  // Esquema de cores customizado baseado na identidade institucional Roadify
  static const FlexSchemeColor _roadifyFlexSchemeLight = FlexSchemeColor(
    primary: AppColors.primary,
    primaryContainer: Color(0xFFE6F4EA),
    secondary: AppColors.secondary,
    secondaryContainer: Color(0xFFCCECE8),
    tertiary: AppColors.limeAccentDark,
    tertiaryContainer: Color(0xFFECFCCA),
    appBarColor: AppColors.surfaceLight,
    error: AppColors.error,
  );

  static const FlexSchemeColor _roadifyFlexSchemeDark = FlexSchemeColor(
    primary: AppColors.limeAccent,
    primaryContainer: Color(0xFF1B382C),
    secondary: AppColors.secondaryLight,
    secondaryContainer: Color(0xFF163E3B),
    tertiary: AppColors.limeAccent,
    tertiaryContainer: Color(0xFF2E4515),
    appBarColor: AppColors.surfaceDark,
    error: AppColors.error,
  );

  /// Subtemas configurados para componentes Material 3 e estilo OneUI / iOS
  static const FlexSubThemesData _subThemes = FlexSubThemesData(
    interactionEffects: true,
    useM2StyleDividerInM3: false,
    defaultRadius: AppDimensions.radiusCard,
    adaptiveRadius: FlexAdaptive.all(),

    // Botões Elevados
    elevatedButtonSchemeColor: SchemeColor.onPrimary,
    elevatedButtonSecondarySchemeColor: SchemeColor.primary,
    elevatedButtonElevation: 0.0,
    elevatedButtonRadius: AppDimensions.radiusMedium,

    // Botões Contornados
    outlinedButtonRadius: AppDimensions.radiusMedium,
    outlinedButtonBorderWidth: 1.2,

    // Cards
    cardRadius: AppDimensions.radiusCard,
    cardElevation: 0.0,

    // Campos de Entrada de Texto
    inputDecoratorBorderType: FlexInputBorderType.outline,
    inputDecoratorRadius: AppDimensions.radiusMedium,
    inputDecoratorUnfocusedHasBorder: true,
    inputDecoratorFocusedHasBorder: true,
    inputDecoratorBorderWidth: 1.2,
    inputDecoratorFocusedBorderWidth: 1.8,

    // Barras de Diálogo e BottomSheet
    dialogRadius: AppDimensions.radiusLarge,
    bottomSheetRadius: AppDimensions.radiusLarge,

    // Switches
    switchThumbSchemeColor: SchemeColor.primary,

    // Chips
    chipRadius: AppDimensions.radiusSmall,
    chipSchemeColor: SchemeColor.primaryContainer,
  );

  /// Tema Claro (Light Mode) — Otimizado para alto contraste sob a luz solar
  static ThemeData get light {
    final theme = FlexThemeData.light(
      colors: _roadifyFlexSchemeLight,
      surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
      blendLevel: 5,
      subThemesData: _subThemes,
      keyColors: const FlexKeyColors(
        useSecondary: true,
        useTertiary: true,
      ),
      visualDensity: VisualDensity.adaptivePlatformDensity,
      platform: defaultTargetPlatform,
      scaffoldBackground: AppColors.backgroundLight,
    );

    final typography = AppTypography.createTextTheme(
      AppColors.textPrimaryLight,
      AppColors.textSecondaryLight,
    );

    return theme.copyWith(
      textTheme: typography,
      extensions: <ThemeExtension<dynamic>>[
        RoadQualityThemeExtension.light,
        PillDockThemeExtension.light,
      ],
      appBarTheme: theme.appBarTheme.copyWith(
        elevation: 0,
        backgroundColor: Colors.transparent,
        scrolledUnderElevation: 0,
        titleTextStyle: typography.titleLarge?.copyWith(
          color: AppColors.textPrimaryLight,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  /// Tema Escuro (Dark Mode) — Otimizado para uso noturno e condução
  static ThemeData get dark {
    final theme = FlexThemeData.dark(
      colors: _roadifyFlexSchemeDark,
      surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
      blendLevel: 8,
      subThemesData: _subThemes,
      keyColors: const FlexKeyColors(
        useSecondary: true,
        useTertiary: true,
      ),
      visualDensity: VisualDensity.adaptivePlatformDensity,
      platform: defaultTargetPlatform,
      scaffoldBackground: AppColors.backgroundDark,
    );

    final typography = AppTypography.createTextTheme(
      AppColors.textPrimaryDark,
      AppColors.textSecondaryDark,
    );

    return theme.copyWith(
      textTheme: typography,
      extensions: <ThemeExtension<dynamic>>[
        RoadQualityThemeExtension.dark,
        PillDockThemeExtension.dark,
      ],
      appBarTheme: theme.appBarTheme.copyWith(
        elevation: 0,
        backgroundColor: Colors.transparent,
        scrolledUnderElevation: 0,
        titleTextStyle: typography.titleLarge?.copyWith(
          color: AppColors.textPrimaryDark,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
