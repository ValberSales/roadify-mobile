// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Roadify';

  @override
  String get settingsTitle => 'Configuración';

  @override
  String get appearanceAndThemeTitle => 'Apariencia y Tema';

  @override
  String get appearanceDescription =>
      'Seleccione el modo de visualización preferido. El Modo Claro es el más recomendado para visibilidad en parabrisas.';

  @override
  String get themeLight => 'Claro';

  @override
  String get themeDark => 'Oscuro';

  @override
  String get themeSystem => 'Sistema';

  @override
  String get vehicleDefaultsTitle => 'Valores del Vehículo';

  @override
  String get defaultVehicleLabel => 'Vehículo Predeterminado';

  @override
  String get manageVehiclesTitle => 'Gestión de Vehículos';

  @override
  String get accelerometerRateLabel => 'Frecuencia del Acelerómetro';

  @override
  String get systemLanguageLabel => 'Idioma del Sistema';
}
