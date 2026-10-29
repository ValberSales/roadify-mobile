import 'dart:async';

import 'package:flutter/material.dart';
import 'package:roadify_app/core/database/app_database.dart';
import 'package:roadify_app/core/di/setup_locator.dart';
import 'package:roadify_app/features/coleta/presentation/collection_orientation_setup_screen.dart';
import 'package:roadify_app/features/coleta/presentation/widgets/info_section_widget.dart';
import 'package:roadify_app/features/coleta/presentation/widgets/parameters_section_widget.dart';
import 'package:roadify_app/features/coleta/presentation/widgets/section_divider.dart';
import 'package:roadify_app/features/coleta/services/collection_permission_service.dart';
import 'package:roadify_app/features/coleta/services/collection_preferences.dart';
import 'package:roadify_app/features/coleta/viewmodels/coleta_viewmodel.dart';
import 'package:roadify_app/features/coleta/viewmodels/persisted_coleta_viewmodel.dart';
import 'package:roadify_app/features/veiculos/viewmodels/vehicle_viewmodel.dart';
import 'package:roadify_app/features/sensores/models/nivel_bolha_state.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/theme_extensions.dart';
import '../../gravacao/gravacao_screen.dart';

class ColetaScreen extends StatefulWidget {
  final ColetaViewModel? viewModel;
  final CollectionPermissionService? permissionService;
  final CollectionPreferences? preferences;

  const ColetaScreen({
    super.key,
    this.viewModel,
    this.permissionService,
    this.preferences,
  });

  @override
  State<ColetaScreen> createState() => _ColetaScreenState();
}

class _ColetaScreenState extends State<ColetaScreen>
    with WidgetsBindingObserver {
  final _formKey = GlobalKey<FormState>();
  late final ColetaViewModel _viewModel;
  late final CollectionPermissionService _permissionService;
  late final CollectionPreferences _preferences;
  final Set<SensorColeta> _sensoresSelecionados = {
    SensorColeta.acelerometro,
    SensorColeta.gps,
  };
  late final TextEditingController _frequenciaGpsController;
  late final TextEditingController _intervaloMetrosController;
  OptionalSensorSettings _optionalSensorSettings =
      const OptionalSensorSettings();
  int _taxaAquisicaoHz = 100;
  String? _erroSelecaoSensores;
  bool _isStartingRecording = false;
  CollectionIdentification _identification = const CollectionIdentification(
    route: '',
    identifier: '',
    vehicle: null,
    odometer: '',
  );
  ConfiguracaoColeta? _restoredConfiguration;
  Vehicle? _restoredVehicle;
  bool _isLoadingPreferences = true;

  @override
  void initState() {
    super.initState();
    _preferences = widget.preferences ?? CollectionPreferences();
    _viewModel = widget.viewModel ?? PersistedColetaViewModel(_preferences);
    _permissionService =
        widget.permissionService ?? CollectionPermissionService();
    _frequenciaGpsController = TextEditingController(text: '10');
    _intervaloMetrosController = TextEditingController(text: '20');
    _frequenciaGpsController.addListener(_persistCurrentConfiguration);
    _intervaloMetrosController.addListener(_persistCurrentConfiguration);
    WidgetsBinding.instance.addObserver(this);
    _restaurarConfiguracao();
  }

  Future<void> _restaurarConfiguracao() async {
    try {
      final configuration = await _preferences.load();
      Vehicle? vehicle;
      final savedVehicleId = configuration?.vehicleId;
      if (savedVehicleId != null) {
        if (getIt.isRegistered<VehicleViewModel>()) {
          final vehicles = await getIt<VehicleViewModel>().getActiveVehicles();
          for (final candidate in vehicles) {
            if (candidate.id == savedVehicleId) {
              vehicle = candidate;
              break;
            }
          }
        }
      }

      if (!mounted) return;
      if (configuration != null) {
        _restoredConfiguration = configuration;
        _restoredVehicle = vehicle;
        _sensoresSelecionados
          ..clear()
          ..addAll(configuration.sensoresSelecionados);
        _taxaAquisicaoHz = configuration.taxaInercialHz;
        _frequenciaGpsController.text = configuration.taxaGpsHz.toString();
        _intervaloMetrosController.text = configuration.intervaloMetros
            .toString();
        _optionalSensorSettings = configuration.sensoresOpcionais;
        _identification = CollectionIdentification(
          route: configuration.trecho,
          identifier: configuration.identificador,
          vehicle: vehicle,
          odometer: vehicle == null
              ? ''
              : configuration.odometroInicial.toString(),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Não foi possível carregar as últimas configurações: $error',
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoadingPreferences = false);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    unawaited(_persistCurrentConfiguration());
    _frequenciaGpsController.removeListener(_persistCurrentConfiguration);
    _intervaloMetrosController.removeListener(_persistCurrentConfiguration);
    _frequenciaGpsController.dispose();
    _intervaloMetrosController.dispose();
    super.dispose();
  }

  void _alternarSensor(SensorColeta sensor, bool selecionado) {
    setState(() {
      if (selecionado) {
        _sensoresSelecionados.add(sensor);
      } else {
        _sensoresSelecionados.remove(sensor);
      }
      _erroSelecaoSensores = null;
    });
    unawaited(_persistCurrentConfiguration());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      unawaited(_persistCurrentConfiguration());
    }
  }

  Future<void> _persistCurrentConfiguration() async {
    if (_isLoadingPreferences) return;

    final previous = _restoredConfiguration;
    final gpsRate = int.tryParse(_frequenciaGpsController.text.trim());
    final distance = double.tryParse(
      _intervaloMetrosController.text.trim().replaceAll(',', '.'),
    );
    final odometer = double.tryParse(
      _identification.odometer.replaceAll(',', '.'),
    );
    final configuration = ConfiguracaoColeta(
      sensoresSelecionados: _sensoresSelecionados,
      taxaInercialHz: _taxaAquisicaoHz,
      taxaGpsHz: gpsRate ?? previous?.taxaGpsHz ?? 10,
      intervaloMetros: distance ?? previous?.intervaloMetros ?? 20,
      sensoresOpcionais: _optionalSensorSettings,
      trecho: _identification.route,
      identificador: _identification.identifier,
      nomeColeta: '${_identification.route} - ${_identification.identifier}',
      orientation: previous?.orientation ?? CollectionOrientation.vertical,
      posture: previous?.posture ?? CollectionPosture.standing,
      calibrationOffsetX: previous?.calibrationOffsetX ?? 0,
      calibrationOffsetY: previous?.calibrationOffsetY ?? 0,
      levelingMode: previous?.levelingMode ?? BubbleDisplayMode.auto,
      isCalibrated: previous?.isCalibrated ?? false,
      vehicleId: _identification.vehicle?.id,
      odometroInicial:
          odometer ??
          previous?.odometroInicial ??
          _identification.vehicle?.defaultOdometer ??
          0,
    );

    try {
      await _preferences.save(configuration);
      _restoredConfiguration = configuration;
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Não foi possível salvar as preferências: $error'),
          ),
        );
      }
    }
  }

  Future<void> _iniciarColeta() async {
    if (_isStartingRecording) {
      return;
    }

    final acelerometroSelecionado = _sensoresSelecionados.contains(
      SensorColeta.acelerometro,
    );
    final gpsSelecionado = _sensoresSelecionados.contains(SensorColeta.gps);
    if (!acelerometroSelecionado || !gpsSelecionado) {
      setState(() {
        _erroSelecaoSensores =
            'Acelerômetro e GPS são obrigatórios para iniciar a coleta.';
      });
      return;
    }
    if (_formKey.currentState?.validate() != true) return;

    final taxaGps = int.tryParse(_frequenciaGpsController.text.trim());
    final intervaloMetros = double.tryParse(
      _intervaloMetrosController.text.trim().replaceAll(',', '.'),
    );
    if (taxaGps == null || intervaloMetros == null) {
      _showValidationError('Revise as frequências e a distância informadas.');
      return;
    }
    final odometroInicial = double.tryParse(
      _identification.odometer.replaceAll(',', '.'),
    );
    if (odometroInicial == null || !odometroInicial.isFinite) {
      _showValidationError('Informe uma quilometragem inicial válida.');
      return;
    }
    if (_taxaAquisicaoHz <= 0) {
      setState(() {
        _erroSelecaoSensores =
            'Informe uma frequência válida para o acelerômetro.';
      });
      return;
    }

    final configuracao = ConfiguracaoColeta(
      sensoresSelecionados: _sensoresSelecionados,
      taxaInercialHz: _taxaAquisicaoHz,
      taxaGpsHz: taxaGps,
      intervaloMetros: intervaloMetros,
      sensoresOpcionais: _optionalSensorSettings,
      nomeColeta: '${_identification.route} - ${_identification.identifier}',
      trecho: _identification.route,
      identificador: _identification.identifier,
      vehicleId: _identification.vehicle?.id,
      odometroInicial: odometroInicial,
    );
    try {
      configuracao.validarParaGravacao();
    } on StateError catch (error) {
      setState(() => _erroSelecaoSensores = error.message);
      return;
    }

    setState(() => _isStartingRecording = true);
    try {
      await _permissionService.requestForSensors(_sensoresSelecionados);
      if (!mounted) return;

      final configuredCollection = await Navigator.of(context)
          .push<ConfiguracaoColeta>(
            MaterialPageRoute(
              builder: (_) => CollectionOrientationSetupScreen(
                configuracao: configuracao,
                preferences: _preferences,
              ),
            ),
          );
      if (!mounted || configuredCollection == null) return;

      await _viewModel.prosseguirParaGravacao(
        configuracao: configuredCollection,
      );
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Coleta preparada com ${_sensoresSelecionados.length} sensores.',
          ),
        ),
      );

      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => GravacaoScreen(configuracao: configuredCollection),
        ),
      );
    } on CollectionPermissionException catch (error) {
      if (!mounted) return;
      final openSettings = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          icon: const Icon(Icons.lock_outline_rounded),
          title: const Text('Permissões necessárias'),
          content: Text(error.message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Voltar'),
            ),
            if (error.canOpenSettings)
              FilledButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                child: const Text('Abrir configurações'),
              ),
          ],
        ),
      );
      if (openSettings == true) {
        await _permissionService.openSettings(
          locationService: error.opensLocationSettings,
        );
      }
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Não foi possível iniciar a gravação: $error')),
      );
    } finally {
      if (mounted) setState(() => _isStartingRecording = false);
    }
  }

  void _showValidationError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 76,
        title: Text(
          'Nova coleta',
          style: context.typography.headlineSmall?.copyWith(
            color: context.colors.primary,
            fontWeight: FontWeight.w800,
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        bottom: false,
        child: _isLoadingPreferences
            ? const Center(child: CircularProgressIndicator())
            : Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(
                    AppDimensions.space20,
                    AppDimensions.space12,
                    AppDimensions.space20,
                    AppDimensions.pillDockHeight +
                        AppDimensions.pillDockMarginBottom +
                        40,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      IdentificacaoSectionWidget(
                        key: const ValueKey('collection-identification'),
                        initialRoute: _restoredConfiguration?.trecho,
                        initialIdentifier:
                            _restoredConfiguration?.identificador,
                        initialVehicle: _restoredVehicle,
                        initialOdometer: _restoredVehicle == null
                            ? null
                            : _restoredConfiguration?.odometroInicial,
                        onChanged: (identification) {
                          _identification = identification;
                          unawaited(_persistCurrentConfiguration());
                        },
                      ),
                      const SizedBox(height: AppDimensions.space20),
                      const SectionDivider(icon: Icons.tune_rounded),
                      const SizedBox(height: AppDimensions.space20),
                      ParametersSectionWidget(
                        sensoresSelecionados: _sensoresSelecionados,
                        onSensorChanged: _alternarSensor,
                        taxaAquisicaoHz: _taxaAquisicaoHz,
                        onTaxaAquisicaoChanged: (taxa) => setState(() {
                          _taxaAquisicaoHz = taxa;
                        }),
                        frequenciaGpsController: _frequenciaGpsController,
                        intervaloMetrosController: _intervaloMetrosController,
                        optionalSensorSettings: _optionalSensorSettings,
                        onOptionalSettingsChanged: (settings) {
                          setState(() => _optionalSensorSettings = settings);
                        },
                        onConfigurationChanged: _persistCurrentConfiguration,
                        erroSelecaoSensores: _erroSelecaoSensores,
                      ),
                      const SizedBox(height: AppDimensions.space32),
                      SizedBox(
                        width: double.infinity,
                        height: AppDimensions.buttonHeight,
                        child: FilledButton.icon(
                          onPressed: _isStartingRecording
                              ? null
                              : _iniciarColeta,
                          icon: _isStartingRecording
                              ? const SizedBox.square(
                                  dimension: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.play_circle_fill_rounded),
                          label: Text(
                            _isStartingRecording
                                ? 'Preparando gravação...'
                                : 'Prosseguir para gravação',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
