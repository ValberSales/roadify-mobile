import 'package:flutter/material.dart';

/// Constantes de espaçamento, dimensões e raios de borda baseados no grid de 8pt.
abstract final class AppDimensions {
  // --- Espaçamentos (Padding / Margin) ---
  static const double space2 = 2.0;
  static const double space4 = 4.0;
  static const double space8 = 8.0;
  static const double space12 = 12.0;
  static const double space16 = 16.0;
  static const double space20 = 20.0;
  static const double space24 = 24.0;
  static const double space32 = 32.0;
  static const double space40 = 40.0;
  static const double space48 = 48.0;

  // --- Raios de Borda (Border Radius) ---
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusCard = 16.0;
  static const double radiusLarge = 24.0;
  static const double radiusPill = 32.0; // Utilizado no Pill Dock OneUI/iOS

  static const BorderRadius borderRadiusSmall = BorderRadius.all(Radius.circular(radiusSmall));
  static const BorderRadius borderRadiusMedium = BorderRadius.all(Radius.circular(radiusMedium));
  static const BorderRadius borderRadiusCard = BorderRadius.all(Radius.circular(radiusCard));
  static const BorderRadius borderRadiusPill = BorderRadius.all(Radius.circular(radiusPill));

  // --- Especificações do Pill-Shaped Dock ---
  static const double pillDockHeight = 66.0;
  static const double pillDockMarginBottom = 16.0;
  static const double pillDockMarginHorizontal = 16.0;
  static const double pillDockBlur = 20.0;
  static const double pillDockElevation = 8.0;

  // --- Alturas de Botões e Controles ---
  static const double buttonHeight = 52.0;
  static const double buttonHeightSmall = 40.0;
  static const double inputHeight = 54.0;
}
