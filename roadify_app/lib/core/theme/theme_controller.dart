import 'package:flutter/material.dart';

/// Controlador reativo para alternância dinâmica de tema (Claro / Escuro / Sistema).
class ThemeController extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light; // Padrão Modo Claro conforme requisitos de luz solar

  ThemeMode get themeMode => _themeMode;

  bool get isDarkMode => _themeMode == ThemeMode.dark;

  void setThemeMode(ThemeMode mode) {
    if (_themeMode == mode) return;
    _themeMode = mode;
    notifyListeners();
  }

  void toggleTheme() {
    if (_themeMode == ThemeMode.dark) {
      setThemeMode(ThemeMode.light);
    } else {
      setThemeMode(ThemeMode.dark);
    }
  }
}
