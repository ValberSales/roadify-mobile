import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Controlador de idioma (i18n) do aplicativo Roadify (SP2-08).
class LocaleController extends ChangeNotifier {
  static const String _prefKey = 'roadify_system_locale';

  Locale _locale = const Locale('pt');

  LocaleController({Locale initialLocale = const Locale('pt')})
    : _locale = initialLocale;

  Locale get locale => _locale;

  static const List<Locale> supportedLocales = [
    Locale('pt'),
    Locale('en'),
    Locale('es'),
  ];

  String get currentLanguageLabel => labelForLocale(_locale);

  static String labelForLocale(Locale locale) {
    return switch (locale.languageCode) {
      'en' => 'English (US)',
      'es' => 'Español',
      _ => 'Português (Brasil)',
    };
  }

  Future<void> loadSavedLocale() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final code = prefs.getString(_prefKey);
      if (code != null &&
          supportedLocales.any((l) => l.languageCode == code) &&
          code != _locale.languageCode) {
        _locale = Locale(code);
        notifyListeners();
      }
    } catch (_) {}
  }

  void setLocale(Locale newLocale) {
    if (_locale.languageCode == newLocale.languageCode) return;
    _locale = newLocale;
    notifyListeners();
    unawaited(_persistLocale(newLocale.languageCode));
  }

  Future<void> _persistLocale(String code) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefKey, code);
    } catch (_) {}
  }
}
