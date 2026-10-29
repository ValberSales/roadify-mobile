// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Roadify';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get appearanceAndThemeTitle => 'Appearance & Theme';

  @override
  String get appearanceDescription =>
      'Select your preferred display mode. Light Mode is recommended for windshield visibility.';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get themeSystem => 'System';

  @override
  String get vehicleDefaultsTitle => 'Vehicle Defaults';

  @override
  String get defaultVehicleLabel => 'Default Vehicle';

  @override
  String get manageVehiclesTitle => 'Vehicle Management';

  @override
  String get accelerometerRateLabel => 'Accelerometer Rate';

  @override
  String get systemLanguageLabel => 'System Language';
}
