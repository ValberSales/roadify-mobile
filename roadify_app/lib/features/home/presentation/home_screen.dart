import 'dart:async';

import 'package:battery_plus/battery_plus.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:roadify_app/l10n/app_localizations_catalog.dart';
import '../../../core/database/app_database.dart';
import '../../../core/database/daos/run_dao.dart';
import '../../../core/di/setup_locator.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/theme_controller.dart';
import '../../../core/theme/theme_extensions.dart';
import '../../../core/utils/snackbar_helper.dart';
import '../../dados/presentation/dados_screen.dart';
import '../../dados/services/run_export_service.dart';
import '../../dados/viewmodel/dados_viewmodel.dart';
import '../../veiculos/presentation/vehicle_ui_helper.dart';
import '../../veiculos/viewmodels/vehicle_viewmodel.dart';
import '../models/device_health_state.dart';
import '../viewmodel/home_health_viewmodel.dart';

/// Modelo de apresentação para coletas na HomeScreen (utilizado tanto com Drift quanto com dados demo).
class _HomeRunItem {
  final int? id;
  final String title;
  final String dateLabel;
  final String metrics;
  final RunListItem runDetails;
  final RunGpsCoordinatesSummary? demoCoordinates;
  final String? demoVehicleLabel;

  const _HomeRunItem({
    this.id,
    required this.title,
    required this.dateLabel,
    required this.metrics,
    required this.runDetails,
    this.demoCoordinates,
    this.demoVehicleLabel,
  });
}

/// Tela Inicial (Home) do Roadify Mobile.
///
/// Exibe um overview executivo:
/// 1. Atalho rápido para Nova Coleta em Pista.
/// 2. Cards de Saúde de Bateria e Precisão do Sinal de GPS (SP2-02) + Alerta de Bateria Baixa.
/// 3. Diagnóstico do armazenamento interno do aparelho.
/// 4. Cards das últimas coletas armazenadas localmente.
class HomeScreen extends StatefulWidget {
  final ThemeController themeController;
  final VoidCallback onStartCollection;
  final RunDao? runDao;
  final HomeHealthViewModel? healthViewModel;
  final VehicleViewModel? vehicleViewModel;

  const HomeScreen({
    super.key,
    required this.themeController,
    required this.onStartCollection,
    this.runDao,
    this.healthViewModel,
    this.vehicleViewModel,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  RunDao? get _dao =>
      widget.runDao ?? (getIt.isRegistered<RunDao>() ? getIt<RunDao>() : null);

  VehicleViewModel? get _vehicleViewModel =>
      widget.vehicleViewModel ??
      (getIt.isRegistered<VehicleViewModel>()
          ? getIt<VehicleViewModel>()
          : null);

  late final HomeHealthViewModel _healthViewModel;
  late final bool _ownsHealthViewModel;
  Vehicle? _selectedVehicleOverride;
  Stream<List<Vehicle>>? _activeVehiclesStream;
  Stream<List<Run>>? _runsStream;

  // Coletas de demonstração exibidas quando o banco ainda não possuir registros gravados
  late List<_HomeRunItem> _demoRuns;

  @override
  void initState() {
    super.initState();
    final isWidgetTest = WidgetsBinding.instance.runtimeType
        .toString()
        .contains('Test');
    _ownsHealthViewModel = widget.healthViewModel == null;
    _healthViewModel =
        widget.healthViewModel ?? HomeHealthViewModel(autoStart: !isWidgetTest);
    _initStreams();

    _demoRuns = [
      _HomeRunItem(
        id: -1,
        title: 'BR-101 • Trecho Norte',
        dateLabel: 'Hoje, 09:24',
        metrics: '12,8 km • 48,2 MB • CSV ;',
        runDetails: RunListItem(
          id: -1,
          title: 'BR-101 • Trecho Norte',
          createdAt: DateTime(2026, 9, 14, 9, 24),
          endedAt: DateTime(2026, 9, 14, 9, 42),
          km: 12.8,
          initialOdometer: 15420.0,
          sizeMb: 48.2,
          isFinished: true,
          accelerometerSampleCount: 216000,
          gpsPointCount: 640,
          mediaCount: 4,
          photoCount: 3,
          videoCount: 1,
          durationSeconds: 1080,
          deviceManufacturer: 'Samsung',
          deviceModel: 'SM-S936B',
          initialBatteryPercent: 92,
        ),
        demoCoordinates: const RunGpsCoordinatesSummary(
          startLatitude: -26.22861,
          startLongitude: -52.67083,
          endLatitude: -26.18420,
          endLongitude: -52.60115,
        ),
        demoVehicleLabel: 'Toyota Hilux • ABC-1234',
      ),
      _HomeRunItem(
        id: -2,
        title: 'Av. Paulista • Leste',
        dateLabel: '12 set, 16:08',
        metrics: '4,6 km • 21,7 MB • CSV ;',
        runDetails: RunListItem(
          id: -2,
          title: 'Av. Paulista • Leste',
          createdAt: DateTime(2026, 9, 12, 16, 8),
          endedAt: DateTime(2026, 9, 12, 16, 20),
          km: 4.6,
          initialOdometer: 15380.0,
          sizeMb: 21.7,
          isFinished: true,
          accelerometerSampleCount: 144000,
          gpsPointCount: 230,
          mediaCount: 2,
          photoCount: 2,
          videoCount: 0,
          durationSeconds: 720,
          deviceManufacturer: 'Samsung',
          deviceModel: 'SM-S936B',
          initialBatteryPercent: 84,
        ),
        demoCoordinates: const RunGpsCoordinatesSummary(
          startLatitude: -23.56141,
          startLongitude: -46.65588,
          endLatitude: -23.57030,
          endLongitude: -46.64512,
        ),
        demoVehicleLabel: 'Toyota Hilux • ABC-1234',
      ),
      _HomeRunItem(
        id: -3,
        title: 'SP-270 • km 34-52',
        dateLabel: '10 set, 07:42',
        metrics: '18,1 km • 73,4 MB • CSV ;',
        runDetails: RunListItem(
          id: -3,
          title: 'SP-270 • km 34-52',
          createdAt: DateTime(2026, 9, 10, 7, 42),
          endedAt: DateTime(2026, 9, 10, 8, 8),
          km: 18.1,
          initialOdometer: 15210.0,
          sizeMb: 73.4,
          isFinished: true,
          accelerometerSampleCount: 312000,
          gpsPointCount: 905,
          mediaCount: 6,
          photoCount: 5,
          videoCount: 1,
          durationSeconds: 1560,
          deviceManufacturer: 'Samsung',
          deviceModel: 'SM-S936B',
          initialBatteryPercent: 96,
        ),
        demoCoordinates: const RunGpsCoordinatesSummary(
          startLatitude: -23.51240,
          startLongitude: -47.45210,
          endLatitude: -23.48890,
          endLongitude: -47.31050,
        ),
        demoVehicleLabel: 'Toyota Hilux • ABC-1234',
      ),
    ];
  }

  @override
  void didUpdateWidget(covariant HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.vehicleViewModel != widget.vehicleViewModel ||
        oldWidget.runDao != widget.runDao) {
      _initStreams();
    }
  }

  void _initStreams() {
    _activeVehiclesStream = _vehicleViewModel?.activeVehiclesStream;
    _runsStream = _dao?.watchAllRuns();
  }

  @override
  void dispose() {
    if (_ownsHealthViewModel) {
      _healthViewModel.dispose();
    }
    super.dispose();
  }

  Vehicle? _resolveLastUsedVehicle(
    List<Vehicle> activeVehicles,
    List<Run> recentRuns,
  ) {
    if (activeVehicles.isEmpty) return null;

    // 1. Prioriza o veículo explicitamente selecionado ou último utilizado salvo nas preferências
    final preferredId =
        _selectedVehicleOverride?.id ?? _vehicleViewModel?.lastUsedVehicleId;
    if (preferredId != null) {
      for (final vehicle in activeVehicles) {
        if (vehicle.id == preferredId) return vehicle;
      }
    }

    // 2. Verifica o veículo vinculado à coleta mais recente gravada no banco
    for (final run in recentRuns) {
      final runVehicleId = run.vehicleId;
      if (runVehicleId != null) {
        for (final vehicle in activeVehicles) {
          if (vehicle.id == runVehicleId) return vehicle;
        }
      }
    }

    // 3. Fallback para o veículo marcado como padrão ou o primeiro veículo ativo
    for (final vehicle in activeVehicles) {
      if (vehicle.isDefault) return vehicle;
    }
    return activeVehicles.first;
  }

  Future<void> _openVehicleSelectionModal() async {
    unawaited(HapticFeedback.selectionClick());
    await VehicleUiHelper.showSelectionModal(
      context,
      viewModel: _vehicleViewModel,
      onVehicleSelected: (vehicle) async {
        unawaited(HapticFeedback.mediumImpact());
        setState(() => _selectedVehicleOverride = vehicle);
        try {
          await _vehicleViewModel?.setDefaultVehicle(vehicle);
          if (!mounted) return;
          SnackbarHelper.showSuccess(
            context,
            message: AppLocalizations.of(context)
                .text('defaultVehicleSet')
                .replaceAll('{name}', vehicle.name)
                .replaceAll('{plate}', vehicle.licensePlate),
          );
        } catch (error) {
          if (!mounted) return;
          SnackbarHelper.showError(
            context,
            message: 'Não foi possível selecionar o veículo: $error',
          );
        }
      },
    );
  }

  Widget _buildVehicleLabelText(String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.directions_car_filled_rounded,
          color: Colors.white,
          size: 14,
        ),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 4),
        const Icon(
          Icons.keyboard_arrow_down_rounded,
          color: Colors.white,
          size: 16,
        ),
      ],
    );
  }

  Widget _buildLastUsedVehicleSummary() {
    final l10n = AppLocalizations.of(context);
    final vehicleVm = _vehicleViewModel;
    if (vehicleVm == null) {
      final override = _selectedVehicleOverride;
      final label = override == null
          ? l10n.text('vehicleNoneRegistered')
          : '${l10n.text('vehiclePrefix')}: ${override.name} (${override.licensePlate})';
      return _buildVehicleLabelText(label);
    }

    final vehiclesStream =
        _activeVehiclesStream ?? vehicleVm.activeVehiclesStream;
    final runsStream =
        _runsStream ??
        (_dao != null
            ? _dao!.watchAllRuns()
            : Stream<List<Run>>.value(const <Run>[]));

    return StreamBuilder<List<Vehicle>>(
      stream: vehiclesStream,
      builder: (context, vehiclesSnapshot) {
        if (vehiclesSnapshot.hasError) {
          return _buildVehicleLabelText(l10n.text('vehicleUnavailable'));
        }
        if (vehiclesSnapshot.connectionState == ConnectionState.waiting &&
            !vehiclesSnapshot.hasData) {
          return _buildVehicleLabelText(l10n.text('vehicleLoading'));
        }
        final activeVehicles = vehiclesSnapshot.data ?? const <Vehicle>[];
        return StreamBuilder<List<Run>>(
          stream: runsStream,
          builder: (context, runsSnapshot) {
            final recentRuns = runsSnapshot.data ?? const <Run>[];
            return ListenableBuilder(
              listenable: vehicleVm,
              builder: (context, _) {
                final vehicle = _resolveLastUsedVehicle(
                  activeVehicles,
                  recentRuns,
                );
                final label = vehicle == null
                    ? l10n.text('vehicleNoneRegistered')
                    : '${l10n.text('vehiclePrefix')}: ${vehicle.name} (${vehicle.licensePlate})';
                return _buildVehicleLabelText(label);
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final isDark = context.isDarkMode;

    // Cores de alto contraste para o botão principal de coleta em pista
    final buttonBg = isDark ? AppColors.limeAccent : Colors.white;
    final buttonFg = isDark ? AppColors.backgroundDark : AppColors.primary;
    final iconBadgeBg = isDark ? AppColors.backgroundDark : AppColors.primary;
    final iconBadgeFg = isDark ? AppColors.limeAccent : Colors.white;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppDimensions.space20,
            AppDimensions.space16,
            AppDimensions.space20,
            AppDimensions.pillDockHeight +
                AppDimensions.pillDockMarginBottom +
                40,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Topo: Logotipo e Alternância Rápida de Tema ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              key: const ValueKey('home-brand-logo-badge'),
                              padding: const EdgeInsets.all(
                                AppDimensions.space8,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(10),
                                border: isDark
                                    ? Border.all(
                                        color: AppColors.limeAccent.withValues(
                                          alpha: 0.35,
                                        ),
                                        width: 1,
                                      )
                                    : null,
                              ),
                              child: Image.asset(
                                'assets/images/roadify_mark.png',
                                width: 44,
                                height: 18,
                                fit: BoxFit.contain,
                              ),
                            ),
                            const SizedBox(width: AppDimensions.space12),
                            Flexible(
                              child: Text(
                                'Roadify',
                                style: typography.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: colors.primary,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppDimensions.space4),
                        Text(
                          AppLocalizations.of(context).text('dataCollector'),
                          style: typography.bodySmall,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppDimensions.space8),
                  IconButton.filledTonal(
                    tooltip: AppLocalizations.of(context).text('themeToggle'),
                    onPressed: () => widget.themeController.toggleTheme(),
                    icon: Icon(
                      context.isDarkMode
                          ? Icons.light_mode_rounded
                          : Icons.dark_mode_rounded,
                      color: colors.primary,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppDimensions.space24),

              // --- Card Principal de Ação: Nova Coleta ---
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppDimensions.space20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: context.isDarkMode
                        ? [const Color(0xFF13362B), const Color(0xFF0F261F)]
                        : [colors.primary, const Color(0xFF1B5E45)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: AppDimensions.borderRadiusCard,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.25),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              key: const ValueKey('home-select-vehicle-chip'),
                              borderRadius: BorderRadius.circular(6),
                              onTap: _openVehicleSelectionModal,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppDimensions.space8,
                                  vertical: AppDimensions.space4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: _buildLastUsedVehicleSummary(),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimensions.space12),
                    Text(
                      AppLocalizations.of(context).text('startNewInspection'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.space4),
                    Text(
                      AppLocalizations.of(context).text('calibrateBeforeDriving'),
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.space16),
                    SizedBox(
                      width: double.infinity,
                      height: AppDimensions.buttonHeight,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: buttonBg,
                          foregroundColor: buttonFg,
                          elevation: 2,
                          shadowColor: Colors.black.withValues(alpha: 0.25),
                          shape: RoundedRectangleBorder(
                            borderRadius: AppDimensions.borderRadiusMedium,
                          ),
                        ),
                        onPressed: widget.onStartCollection,
                        icon: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: iconBadgeBg,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.play_arrow_rounded,
                            size: 18,
                            color: iconBadgeFg,
                          ),
                        ),
                        label: Text(
                          AppLocalizations.of(context).text('startTrackCollection'),
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                            color: buttonFg,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppDimensions.space20),

              // --- SP2-02: Cards de Saúde de Bateria e Sinal GPS + Alerta de Bateria ---
              ListenableBuilder(
                listenable: _healthViewModel,
                builder: (context, _) {
                  final health = _healthViewModel.state;
                  return _DeviceHealthSection(state: health);
                },
              ),

              const SizedBox(height: AppDimensions.space16),

              // --- Card de Diagnóstico do Armazenamento Interno ---
              _buildStorageCard(context),

              const SizedBox(height: AppDimensions.space24),

              // --- Seção: Últimas Coletas (somente as 3 últimas) ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      AppLocalizations.of(context).text('latestCollections'),
                      style: typography.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: AppDimensions.space8),
                  Text(
                    AppLocalizations.of(context).text('recentLabel'),
                    style: typography.bodySmall?.copyWith(
                      color: colors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.space12),

              // Renderiza as 3 últimas coletas reativas do banco Drift ou coletas de demonstração
              if (_dao != null)
                StreamBuilder<List<Run>>(
                  stream: _runsStream ?? _dao!.watchAllRuns(),
                  builder: (context, snapshot) {
                    final dbRuns = snapshot.data;
                    if (dbRuns != null && dbRuns.isNotEmpty) {
                      final l10n = AppLocalizations.of(context);
                      final items = dbRuns.take(3).map((r) {
                        final dateStr =
                            '${r.recordedAt.day.toString().padLeft(2, '0')}/${r.recordedAt.month.toString().padLeft(2, '0')} ${r.recordedAt.hour.toString().padLeft(2, '0')}:${r.recordedAt.minute.toString().padLeft(2, '0')}';
                        final title =
                            (r.title?.trim().isNotEmpty ?? false)
                            ? r.title!.trim()
                            : l10n
                                  .text('testRunNumber')
                                  .replaceAll('{id}', '${r.id}');
                        final dataBytes =
                            (r.accelerometerSampleCount * 64) +
                            (r.gpsPointCount * 80) +
                            (r.mediaCount * 512 * 1024);
                        final runDetails = RunListItem(
                          id: r.id,
                          title: title,
                          createdAt: r.recordedAt,
                          endedAt: r.endedAt,
                          km: r.distanceKm,
                          initialOdometer: r.odometer,
                          sizeMb: dataBytes / (1024 * 1024),
                          isFinished: r.endedAt != null,
                          accelerometerSampleCount: r.accelerometerSampleCount,
                          gpsPointCount: r.gpsPointCount,
                          mediaCount: r.mediaCount,
                          photoCount: r.mediaCount,
                          videoCount: 0,
                          durationSeconds: r.durationSeconds,
                          vehicleId: r.vehicleId,
                          deviceManufacturer: r.deviceManufacturer,
                          deviceModel: r.deviceModel,
                          initialBatteryPercent: r.initialBatteryPercent,
                          notes: r.notes,
                        );
                        return _HomeRunItem(
                          id: r.id,
                          title: title,
                          dateLabel: dateStr,
                          metrics:
                              '${r.distanceKm.toStringAsFixed(1)} km • ${l10n.text('odometerShort')}: ${r.odometer.toStringAsFixed(0)} km',
                          runDetails: runDetails,
                        );
                      }).toList();

                      return Column(
                        children: items.map((item) {
                          return Padding(
                            padding: const EdgeInsets.only(
                              bottom: AppDimensions.space12,
                            ),
                            child: _ColetaCard(
                              item: item,
                              onTap: () => _openRunDetailsModal(item),
                            ),
                          );
                        }).toList(),
                      );
                    }

                    // Se banco estiver vazio, exibe as 3 coletas demo
                    return _buildDemoRunsList();
                  },
                )
              else
                _buildDemoRunsList(),
            ],
          ),
        ),
      ),
    );
  }

  Future<RunGpsCoordinatesSummary> _fetchRunGpsCoordinates(
    _HomeRunItem item,
  ) async {
    if (item.demoCoordinates != null) return item.demoCoordinates!;
    final runId = item.id;
    final dao = _dao;
    if (runId == null || runId <= 0 || dao == null) {
      return const RunGpsCoordinatesSummary();
    }
    try {
      final db = dao.attachedDatabase;
      final firstPoint =
          await (db.select(db.gpsPointsTable)
                ..where((t) => t.runId.equals(runId))
                ..orderBy([
                  (t) => OrderingTerm(
                    expression: t.recordedAt,
                    mode: OrderingMode.asc,
                  ),
                  (t) => OrderingTerm(expression: t.id, mode: OrderingMode.asc),
                ])
                ..limit(1))
              .getSingleOrNull();

      final lastPoint =
          await (db.select(db.gpsPointsTable)
                ..where((t) => t.runId.equals(runId))
                ..orderBy([
                  (t) => OrderingTerm(
                    expression: t.recordedAt,
                    mode: OrderingMode.desc,
                  ),
                  (t) =>
                      OrderingTerm(expression: t.id, mode: OrderingMode.desc),
                ])
                ..limit(1))
              .getSingleOrNull();

      return RunGpsCoordinatesSummary(
        startLatitude: firstPoint?.latitude,
        startLongitude: firstPoint?.longitude,
        endLatitude: lastPoint?.latitude,
        endLongitude: lastPoint?.longitude,
      );
    } catch (_) {
      return const RunGpsCoordinatesSummary();
    }
  }

  Future<String?> _fetchRunVehicleLabel(_HomeRunItem item) async {
    if (item.demoVehicleLabel != null) return item.demoVehicleLabel;
    final vehicleId = item.runDetails.vehicleId;
    final dao = _dao;
    if (vehicleId == null || dao == null) return null;
    try {
      final v = await dao.attachedDatabase.vehicleDao.getVehicleById(vehicleId);
      final plate = v.licensePlate.trim();
      return plate.isEmpty ? v.name : '${v.name} • $plate';
    } catch (_) {
      return null;
    }
  }

  Future<void> _exportRunFromHome(RunListItem run) async {
    if (run.id <= 0) return;
    final dao = _dao;
    final exportService = getIt.isRegistered<RunExportService>()
        ? getIt<RunExportService>()
        : (dao != null ? RunExportService(dao.attachedDatabase) : null);
    if (exportService == null) return;

    try {
      final savedPath = await exportService.exportRun(run.id);
      if (!mounted || savedPath == null) return;
      SnackbarHelper.showSuccess(
        context,
        message: AppLocalizations.of(context)
            .text('zipSavedSuccess')
            .replaceAll('{title}', run.title),
      );
    } catch (e) {
      if (!mounted) return;
      SnackbarHelper.showError(
        context,
        message: AppLocalizations.of(context)
            .text('exportRunError')
            .replaceAll('{error}', '$e'),
      );
    }
  }

  void _openRunDetailsModal(_HomeRunItem item) {
    unawaited(HapticFeedback.selectionClick());
    final gpsFuture = _fetchRunGpsCoordinates(item);
    final vehicleFuture = _fetchRunVehicleLabel(item);

    RunDetailsBottomSheet.show(
      context,
      run: item.runDetails,
      gpsCoordinatesFuture: gpsFuture,
      vehicleLabelFuture: vehicleFuture,
      onExport: () => _exportRunFromHome(item.runDetails),
    );
  }

  Widget _buildStorageCard(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final dao = _dao;
    if (dao == null) {
      return _buildStorageCardContent(
        context,
        usedLabel: l10n.text('storageUsedMb').replaceAll('{mb}', '143,3'),
        runsCountLabel: l10n
            .text('storedMultipleRuns')
            .replaceAll('{count}', '4'),
        progressValue: 0.18,
      );
    }

    return StreamBuilder<List<Run>>(
      stream: _runsStream ?? dao.watchAllRuns(),
      builder: (context, snapshot) {
        final dbRuns = snapshot.data;
        if (dbRuns == null || dbRuns.isEmpty) {
          return _buildStorageCardContent(
            context,
            usedLabel: l10n.text('storageUsedMb').replaceAll('{mb}', '143,3'),
            runsCountLabel: l10n
                .text('storedMultipleRuns')
                .replaceAll('{count}', '4'),
            progressValue: 0.18,
          );
        }

        double totalBytes = 0;
        for (final r in dbRuns) {
          totalBytes +=
              (r.accelerometerSampleCount * 64) +
              (r.gpsPointCount * 80) +
              (r.mediaCount * 512 * 1024);
        }
        final totalMb = totalBytes / (1024 * 1024);
        final formattedMb = totalMb.toStringAsFixed(1).replaceAll('.', ',');
        final count = dbRuns.length;
        final runsLabel = count == 1
            ? l10n.text('storedSingleRun')
            : l10n
                  .text('storedMultipleRuns')
                  .replaceAll('{count}', '$count');
        final progress = (totalMb / 1024.0).clamp(0.02, 1.0);

        return _buildStorageCardContent(
          context,
          usedLabel: l10n
              .text('storageUsedMb')
              .replaceAll('{mb}', formattedMb),
          runsCountLabel: runsLabel,
          progressValue: progress,
        );
      },
    );
  }

  Widget _buildStorageCardContent(
    BuildContext context, {
    required String usedLabel,
    required String runsCountLabel,
    required double progressValue,
  }) {
    final colors = context.colors;
    final typography = context.typography;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.space16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: AppDimensions.borderRadiusCard,
        border: Border.all(color: colors.outlineVariant, width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.storage_rounded, size: 20, color: colors.primary),
              const SizedBox(width: AppDimensions.space8),
              Expanded(
                child: Text(
                  AppLocalizations.of(context).text('deviceStorage'),
                  style: typography.titleMedium,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.space8),
          Text(
            usedLabel,
            style: typography.labelMedium?.copyWith(
              color: colors.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppDimensions.space12),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progressValue,
              minHeight: 8,
              backgroundColor: colors.surfaceContainerHighest,
              color: colors.primary,
            ),
          ),
          const SizedBox(height: AppDimensions.space8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  runsCountLabel,
                  style: typography.bodySmall,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: AppDimensions.space8),
              Flexible(
                child: Text(
                  AppLocalizations.of(context).text('availableStorage'),
                  style: typography.bodySmall,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.end,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDemoRunsList() {
    return Column(
      children: _demoRuns.take(3).map((item) {
        return Padding(
          padding: const EdgeInsets.only(bottom: AppDimensions.space12),
          child: _ColetaCard(
            item: item,
            onTap: () => _openRunDetailsModal(item),
          ),
        );
      }).toList(),
    );
  }
}

/// Seção dos Cards de Saúde de Bateria e Sinal GPS + Alerta Visual de Bateria Baixa (SP2-02).
class _DeviceHealthSection extends StatelessWidget {
  final DeviceHealthState state;

  const _DeviceHealthSection({required this.state});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (state.isBatteryBelowSafeLimit) ...[
          _LowBatteryAlertBanner(batteryLevel: state.batteryLevel),
          const SizedBox(height: AppDimensions.space12),
        ],
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _BatteryHealthCard(state: state)),
            const SizedBox(width: AppDimensions.space12),
            Expanded(child: _GpsHealthCard(state: state)),
          ],
        ),
      ],
    );
  }
}

/// Alerta visual exibido quando o nível de bateria está abaixo do limite seguro (< 20%) (SP2-02).
class _LowBatteryAlertBanner extends StatelessWidget {
  final int batteryLevel;

  const _LowBatteryAlertBanner({required this.batteryLevel});

  @override
  Widget build(BuildContext context) {
    final typography = context.typography;

    return Container(
      key: const ValueKey('low-battery-alert-banner'),
      padding: const EdgeInsets.all(AppDimensions.space12),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.12),
        borderRadius: AppDimensions.borderRadiusCard,
        border: Border.all(color: AppColors.error, width: 1.4),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.battery_alert_rounded,
            color: AppColors.error,
            size: 22,
          ),
          const SizedBox(width: AppDimensions.space8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context)
                      .text('lowBattery')
                      .replaceAll('{batteryLevel}', '$batteryLevel'),
                  style: typography.labelLarge?.copyWith(
                    color: AppColors.error,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  AppLocalizations.of(context)
                      .text('batteryRecommendation')
                      .replaceAll(
                        '{threshold}',
                        '${DeviceHealthState.safeBatteryThreshold}',
                      ),
                  style: typography.bodySmall?.copyWith(
                    color: context.colors.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Card de Saúde da Bateria com percentual real e status de carregamento (SP2-02).
class _BatteryHealthCard extends StatelessWidget {
  final DeviceHealthState state;

  const _BatteryHealthCard({required this.state});

  IconData _resolveBatteryIcon() {
    if (state.batteryState == BatteryState.charging) {
      return Icons.battery_charging_full_rounded;
    }
    if (state.isBatteryBelowSafeLimit) {
      return Icons.battery_alert_rounded;
    }
    if (state.batteryLevel >= 80) {
      return Icons.battery_full_rounded;
    }
    if (state.batteryLevel >= 40) {
      return Icons.battery_5_bar_rounded;
    }
    return Icons.battery_2_bar_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final isLow = state.isBatteryBelowSafeLimit;
    final accentColor = isLow
        ? AppColors.error
        : (state.isCharging ? AppColors.success : colors.primary);

    return Container(
      key: const ValueKey('home-battery-health-card'),
      padding: const EdgeInsets.all(AppDimensions.space12),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: AppDimensions.borderRadiusCard,
        border: Border.all(
          color: isLow ? AppColors.error : colors.outlineVariant,
          width: isLow ? 1.5 : 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(_resolveBatteryIcon(), size: 18, color: accentColor),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  AppLocalizations.of(context).text('batteryTitle'),
                  style: typography.labelMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.space8),
          Text(
            '${state.batteryLevel}%',
            style: typography.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
              color: isLow ? AppColors.error : colors.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              state.localizedChargingStatus(context),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: accentColor,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

/// Card de Precisão do Sinal GPS (Fraco / Médio / Forte) e raio de incerteza em metros (SP2-02).
class _GpsHealthCard extends StatelessWidget {
  final DeviceHealthState state;

  const _GpsHealthCard({required this.state});

  Color _qualityColor(BuildContext context, GpsSignalQuality quality) {
    return switch (quality) {
      GpsSignalQuality.forte => AppColors.success,
      GpsSignalQuality.medio => Colors.amber.shade800,
      GpsSignalQuality.fraco => AppColors.error,
    };
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final quality = state.gpsSignalQuality;
    final badgeColor = _qualityColor(context, quality);

    return Container(
      key: const ValueKey('home-gps-health-card'),
      padding: const EdgeInsets.all(AppDimensions.space12),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: AppDimensions.borderRadiusCard,
        border: Border.all(color: colors.outlineVariant, width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.gps_fixed_rounded, size: 18, color: badgeColor),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  AppLocalizations.of(context).text('gpsSignalTitle'),
                  style: typography.labelMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.space8),
          Text(
            state.localizedGpsUncertainty(context),
            style: typography.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: colors.onSurface,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: badgeColor.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              AppLocalizations.of(context)
                  .text('gpsSignalQualityLabel')
                  .replaceAll('{quality}', quality.localizedLabel(context)),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: badgeColor,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

/// Card de Coleta Individual na HomeScreen (clicável para abrir o modal de detalhes).
class _ColetaCard extends StatelessWidget {
  final _HomeRunItem item;
  final VoidCallback onTap;

  const _ColetaCard({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;

    return Material(
      color: colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: AppDimensions.borderRadiusCard,
        side: BorderSide(color: colors.outlineVariant, width: 1.2),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        key: ValueKey('home-run-card-${item.id}'),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.space16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      item.title,
                      style: typography.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: colors.onSurfaceVariant,
                  ),
                ],
              ),
              const SizedBox(height: 4),
              // Data e Hora
              Text(
                item.dateLabel,
                style: typography.bodySmall?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              // Métricas do Ensaio
              Text(
                item.metrics,
                style: typography.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colors.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
