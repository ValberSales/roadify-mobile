// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'Roadify';

  @override
  String get settingsTitle => 'Configurações';

  @override
  String get appearanceAndThemeTitle => 'Aparência e Tema';

  @override
  String get appearanceDescription =>
      'Selecione o modo de exibição preferido. O Modo Claro é o mais recomendado para visibilidade em para-brisas.';

  @override
  String get themeLight => 'Claro';

  @override
  String get themeDark => 'Escuro';

  @override
  String get themeSystem => 'Sistema';

  @override
  String get vehicleDefaultsTitle => 'Padrões do Veículo';

  @override
  String get defaultVehicleLabel => 'Veículo Padrão';

  @override
  String get manageVehiclesTitle => 'Gestão de Veículos';

  @override
  String get accelerometerRateLabel => 'Taxa do Acelerômetro';

  @override
  String get systemLanguageLabel => 'Idioma do Sistema';
}
