import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/database/app_database.dart';
import '../../../core/l10n/locale_controller.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/theme_controller.dart';
import '../../../core/theme/theme_extensions.dart';
import '../../../l10n/app_localizations.dart';
import '../../veiculos/presentation/vehicles_management_screen.dart';
import 'login_screen.dart';

/// Tela de Configurações e Perfil (Feature Auth/Config — SP2-08).
///
/// Funcionalidades:
/// 1. Opções de tema (Claro / Escuro / Sistema) funcionando em tempo real.
/// 2. Link para a tela de Gestão de Veículos (`VehiclesManagementScreen`).
/// 3. Seletor de idioma e internacionalização (`AppLocalizations` + `LocaleController`).
class ConfigScreen extends StatefulWidget {
  final ThemeController themeController;
  final LocaleController? localeController;

  const ConfigScreen({
    super.key,
    required this.themeController,
    this.localeController,
  });

  @override
  State<ConfigScreen> createState() => _ConfigScreenState();
}

class _ConfigScreenState extends State<ConfigScreen> {
  static const String _prefDefaultVehicleLabelKey =
      'roadify_default_vehicle_label';
  static const String _prefDefaultAccelHzKey = 'roadify_default_accel_hz';
  static const String _prefWifiOnlyKey = 'roadify_sync_wifi_only';

  late final LocaleController _localeController;
  late final bool _ownsLocaleController;

  String _defaultVehicleLabel = 'Toyota Hilux (ABC-1234)';
  int _defaultAccelerometerHz = 200;
  bool _wifiOnlySync = true;

  @override
  void initState() {
    super.initState();
    _ownsLocaleController = widget.localeController == null;
    _localeController = widget.localeController ?? LocaleController();
    unawaited(_loadPreferences());
  }

  @override
  void dispose() {
    if (_ownsLocaleController) {
      _localeController.dispose();
    }
    super.dispose();
  }

  Future<void> _loadPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedVehicle = prefs.getString(_prefDefaultVehicleLabelKey);
      final savedHz = prefs.getInt(_prefDefaultAccelHzKey);
      final savedWifi = prefs.getBool(_prefWifiOnlyKey);
      if (!mounted) return;
      setState(() {
        if (savedVehicle != null && savedVehicle.isNotEmpty) {
          _defaultVehicleLabel = savedVehicle;
        }
        if (savedHz != null) {
          _defaultAccelerometerHz = savedHz;
        }
        if (savedWifi != null) {
          _wifiOnlySync = savedWifi;
        }
      });
    } catch (_) {}
  }

  Future<void> _openVehiclesManagement() async {
    final selected = await Navigator.of(context).push<Vehicle>(
      MaterialPageRoute(
        builder: (_) => VehiclesManagementScreen(
          onDefaultVehicleSelected: (vehicle) {
            final label = '${vehicle.name} (${vehicle.licensePlate})';
            setState(() => _defaultVehicleLabel = label);
            unawaited(_saveDefaultVehicleLabel(label));
          },
        ),
      ),
    );

    if (selected != null && mounted) {
      final label = '${selected.name} (${selected.licensePlate})';
      setState(() => _defaultVehicleLabel = label);
      await _saveDefaultVehicleLabel(label);
    }
  }

  Future<void> _saveDefaultVehicleLabel(String label) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefDefaultVehicleLabelKey, label);
    } catch (_) {}
  }

  Future<void> _selectAccelerometerRate() async {
    const options = [50, 100, 200, 500];
    final chosen = await showModalBottomSheet<int>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.space20,
                  vertical: AppDimensions.space8,
                ),
                child: Text(
                  'Taxa Padrão do Acelerômetro',
                  style: context.typography.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              for (final hz in options)
                ListTile(
                  leading: const Icon(Icons.speed_rounded),
                  title: Text(
                    hz == 200 ? '$hz Hz (Recomendado)' : '$hz Hz',
                  ),
                  trailing: _defaultAccelerometerHz == hz
                      ? Icon(Icons.check_rounded, color: context.colors.primary)
                      : null,
                  onTap: () => Navigator.of(sheetContext).pop(hz),
                ),
              const SizedBox(height: AppDimensions.space12),
            ],
          ),
        );
      },
    );

    if (chosen != null && mounted) {
      setState(() => _defaultAccelerometerHz = chosen);
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt(_prefDefaultAccelHzKey, chosen);
      } catch (_) {}
    }
  }

  Future<void> _selectLanguage() async {
    final chosen = await showModalBottomSheet<Locale>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.space20,
                  vertical: AppDimensions.space8,
                ),
                child: Text(
                  'Selecionar Idioma',
                  style: context.typography.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              for (final locale in LocaleController.supportedLocales)
                ListTile(
                  key: ValueKey('language-option-${locale.languageCode}'),
                  leading: const Icon(Icons.language_rounded),
                  title: Text(LocaleController.labelForLocale(locale)),
                  trailing:
                      _localeController.locale.languageCode ==
                          locale.languageCode
                      ? Icon(Icons.check_rounded, color: context.colors.primary)
                      : null,
                  onTap: () => Navigator.of(sheetContext).pop(locale),
                ),
              const SizedBox(height: AppDimensions.space12),
            ],
          ),
        );
      },
    );

    if (chosen != null && mounted) {
      _localeController.setLocale(chosen);
    }
  }

  Future<void> _toggleWifiOnly(bool value) async {
    setState(() => _wifiOnlySync = value);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_prefWifiOnlyKey, value);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final l10n = AppLocalizations.of(context);

    return ListenableBuilder(
      listenable: _localeController,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(
            title: Text(l10n?.settingsTitle ?? 'Configurações'),
          ),
          body: SafeArea(
            bottom: false,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                AppDimensions.space20,
                AppDimensions.space12,
                AppDimensions.space20,
                AppDimensions.pillDockHeight +
                    AppDimensions.pillDockMarginBottom +
                    40,
              ),
              children: [
                // --- Seção: Conta de Usuário ---
                Material(
                  color: colors.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: AppDimensions.borderRadiusCard,
                    side: BorderSide(color: colors.outlineVariant),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: colors.primary,
                      child: const Text(
                        'R',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    title: Text(l10n?.userAccountTitle ?? 'Conta de Usuário'),
                    subtitle: Text(
                      l10n?.userAccountSubtitle ??
                          'Entrar ou criar conta para sincronizar',
                    ),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                      );
                    },
                  ),
                ),

                const SizedBox(height: AppDimensions.space20),

                // --- Seção: Aparência e Temas Globais ---
                Text(
                  l10n?.appearanceAndThemeTitle ?? 'Aparência e Tema',
                  style: typography.titleMedium,
                ),
                const SizedBox(height: AppDimensions.space8),
                Container(
                  padding: const EdgeInsets.all(AppDimensions.space16),
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: AppDimensions.borderRadiusCard,
                    border: Border.all(color: colors.outlineVariant),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n?.appearanceDescription ??
                            'Selecione o modo de exibição preferido. O Modo Claro é o mais recomendado para visibilidade em para-brisas.',
                        style: typography.bodySmall,
                      ),
                      const SizedBox(height: AppDimensions.space16),
                      Center(
                        child: SizedBox(
                          width: double.infinity,
                          child: ListenableBuilder(
                            listenable: widget.themeController,
                            builder: (context, _) {
                              return SegmentedButton<ThemeMode>(
                                showSelectedIcon: false,
                                segments: [
                                  ButtonSegment(
                                    value: ThemeMode.light,
                                    label: Text(l10n?.themeLight ?? 'Claro'),
                                    icon: const Icon(Icons.light_mode_rounded),
                                  ),
                                  ButtonSegment(
                                    value: ThemeMode.dark,
                                    label: Text(l10n?.themeDark ?? 'Escuro'),
                                    icon: const Icon(Icons.dark_mode_rounded),
                                  ),
                                  ButtonSegment(
                                    value: ThemeMode.system,
                                    label: Text(
                                      l10n?.themeSystem ?? 'Sistema',
                                    ),
                                    icon: const Icon(
                                      Icons.brightness_auto_rounded,
                                    ),
                                  ),
                                ],
                                selected: {widget.themeController.themeMode},
                                onSelectionChanged: (newSelection) {
                                  widget.themeController.setThemeMode(
                                    newSelection.first,
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppDimensions.space24),

                // --- Seção: Preferências Padrão de Coleta & Gestão de Veículos (SP2-08) ---
                Text(
                  l10n?.vehicleDefaultsTitle ?? 'Padrões do Veículo',
                  style: typography.titleMedium,
                ),
                const SizedBox(height: AppDimensions.space8),
                Material(
                  color: colors.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: AppDimensions.borderRadiusCard,
                    side: BorderSide(color: colors.outlineVariant),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    children: [
                      ListTile(
                        key: const ValueKey('config-manage-vehicles-tile'),
                        leading: const Icon(Icons.directions_car_rounded),
                        title: Text(
                          l10n?.defaultVehicleLabel ?? 'Veículo Padrão',
                        ),
                        subtitle: Text(_defaultVehicleLabel),
                        trailing: const Icon(Icons.chevron_right_rounded),
                        onTap: _openVehiclesManagement,
                      ),
                      const Divider(height: 1),
                      ListTile(
                        key: const ValueKey('config-accelerometer-rate-tile'),
                        leading: const Icon(Icons.speed_rounded),
                        title: Text(
                          l10n?.accelerometerRateLabel ??
                              'Taxa do Acelerômetro',
                        ),
                        subtitle: Text(
                          _defaultAccelerometerHz == 200
                              ? '200 Hz (Recomendado)'
                              : '$_defaultAccelerometerHz Hz',
                        ),
                        trailing: const Icon(Icons.chevron_right_rounded),
                        onTap: _selectAccelerometerRate,
                      ),
                      const Divider(height: 1),
                      ListTile(
                        key: const ValueKey('config-system-language-tile'),
                        leading: const Icon(Icons.language_rounded),
                        title: Text(
                          l10n?.systemLanguageLabel ?? 'Idioma do Sistema',
                        ),
                        subtitle: Text(_localeController.currentLanguageLabel),
                        trailing: const Icon(Icons.chevron_right_rounded),
                        onTap: _selectLanguage,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppDimensions.space24),

                // --- Seção: Servidor e API RESTful ---
                Text(
                  l10n?.serverConnectionTitle ?? 'Conexão com o Servidor',
                  style: typography.titleMedium,
                ),
                const SizedBox(height: AppDimensions.space8),
                Material(
                  color: colors.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: AppDimensions.borderRadiusCard,
                    side: BorderSide(color: colors.outlineVariant),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.cloud_queue_rounded),
                        title: Text(
                          l10n?.apiEndpointLabel ?? 'Endpoint da API Roadify',
                        ),
                        subtitle: const Text(
                          'https://roadify.app.pb.utfpr.edu.br/api',
                        ),
                        trailing: const Icon(Icons.chevron_right_rounded),
                        onTap: () {},
                      ),
                      const Divider(height: 1),
                      SwitchListTile(
                        secondary: const Icon(Icons.wifi_rounded),
                        title: Text(
                          l10n?.wifiOnlySyncTitle ??
                              'Sincronizar apenas no Wi-Fi',
                        ),
                        subtitle: Text(
                          l10n?.wifiOnlySyncSubtitle ??
                              'Economiza franquia de dados móveis',
                        ),
                        value: _wifiOnlySync,
                        onChanged: _toggleWifiOnly,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
