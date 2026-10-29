import 'package:battery_plus/battery_plus.dart';
import 'package:flutter/material.dart';
import '../../../core/database/app_database.dart';
import '../../../core/database/daos/run_dao.dart';
import '../../../core/di/setup_locator.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/theme_controller.dart';
import '../../../core/theme/theme_extensions.dart';
import '../models/device_health_state.dart';
import '../viewmodel/home_health_viewmodel.dart';

/// Modelo de apresentação para coletas na HomeScreen (utilizado tanto com Drift quanto com dados demo).
class _HomeRunItem {
  final int? id;
  final String title;
  final String dateLabel;
  final String metrics;

  const _HomeRunItem({
    this.id,
    required this.title,
    required this.dateLabel,
    required this.metrics,
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

  const HomeScreen({
    super.key,
    required this.themeController,
    required this.onStartCollection,
    this.runDao,
    this.healthViewModel,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  RunDao? get _dao =>
      widget.runDao ?? (getIt.isRegistered<RunDao>() ? getIt<RunDao>() : null);

  late final HomeHealthViewModel _healthViewModel;
  late final bool _ownsHealthViewModel;

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

    _demoRuns = [
      const _HomeRunItem(
        id: -1,
        title: 'BR-101 • Trecho Norte',
        dateLabel: 'Hoje, 09:24',
        metrics: '12,8 km • 48,2 MB • CSV ;',
      ),
      const _HomeRunItem(
        id: -2,
        title: 'Av. Paulista • Leste',
        dateLabel: '12 set, 16:08',
        metrics: '4,6 km • 21,7 MB • CSV ;',
      ),
      const _HomeRunItem(
        id: -3,
        title: 'SP-270 • km 34-52',
        dateLabel: '10 set, 07:42',
        metrics: '18,1 km • 73,4 MB • CSV ;',
      ),
    ];
  }

  @override
  void dispose() {
    if (_ownsHealthViewModel) {
      _healthViewModel.dispose();
    }
    super.dispose();
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
                              padding: const EdgeInsets.all(
                                AppDimensions.space8,
                              ),
                              decoration: BoxDecoration(
                                color: colors.primary,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.alt_route_rounded,
                                color: Colors.white,
                                size: 20,
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
                          'Coletor de Dados de Pavimento',
                          style: typography.bodySmall,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppDimensions.space8),
                  IconButton.filledTonal(
                    tooltip: 'Alternar Tema Claro / Escuro',
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
                      color: colors.primary.withValues(alpha: 0.25),
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
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppDimensions.space8,
                              vertical: AppDimensions.space4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'VEÍCULO: TOYOTA HILUX (ABC-1234)',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimensions.space12),
                    const Text(
                      'Iniciar Nova Vistoria',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.space4),
                    Text(
                      'Calibre os sensores com o nível bolha antes de rodar.',
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
                          'Iniciar Coleta em Pista',
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
              Container(
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
                        Icon(
                          Icons.storage_rounded,
                          size: 20,
                          color: colors.primary,
                        ),
                        const SizedBox(width: AppDimensions.space8),
                        Expanded(
                          child: Text(
                            'Armazenamento do Aparelho',
                            style: typography.titleMedium,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimensions.space8),
                    Text(
                      '143,3 MB usados',
                      style: typography.labelMedium?.copyWith(
                        color: colors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.space12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: 0.18,
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
                            '4 coletas armazenadas',
                            style: typography.bodySmall,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: AppDimensions.space8),
                        Flexible(
                          child: Text(
                            '42 GB disponíveis',
                            style: typography.bodySmall,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.end,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppDimensions.space24),

              // --- Seção: Últimas Coletas ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Últimas Coletas',
                      style: typography.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: AppDimensions.space8),
                  Text(
                    'Recentes',
                    style: typography.bodySmall?.copyWith(
                      color: colors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.space12),

              // Renderiza coletas reativas do banco Drift ou coletas de demonstração
              if (_dao != null)
                StreamBuilder<List<Run>>(
                  stream: _dao!.watchAllRuns(),
                  builder: (context, snapshot) {
                    final dbRuns = snapshot.data;
                    if (dbRuns != null && dbRuns.isNotEmpty) {
                      final items = dbRuns.take(5).map((r) {
                        final dateStr =
                            '${r.recordedAt.day.toString().padLeft(2, '0')}/${r.recordedAt.month.toString().padLeft(2, '0')} ${r.recordedAt.hour.toString().padLeft(2, '0')}:${r.recordedAt.minute.toString().padLeft(2, '0')}';
                        return _HomeRunItem(
                          id: r.id,
                          title: r.title ?? 'Ensaio #${r.id}',
                          dateLabel: dateStr,
                          metrics:
                              '${r.distanceKm.toStringAsFixed(1)} km • Odômetro: ${r.odometer.toStringAsFixed(0)} km',
                        );
                      }).toList();

                      return Column(
                        children: items.map((item) {
                          return Padding(
                            padding: const EdgeInsets.only(
                              bottom: AppDimensions.space12,
                            ),
                            child: _ColetaCard(item: item),
                          );
                        }).toList(),
                      );
                    }

                    // Se banco estiver vazio, exibe as coletas demo
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

  Widget _buildDemoRunsList() {
    return Column(
      children: _demoRuns.map((item) {
        return Padding(
          padding: const EdgeInsets.only(bottom: AppDimensions.space12),
          child: _ColetaCard(item: item),
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
                  'Bateria abaixo do limite seguro ($batteryLevel%)',
                  style: typography.labelLarge?.copyWith(
                    color: AppColors.error,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Nível mínimo recomendado: ${DeviceHealthState.safeBatteryThreshold}%. Conecte o carregador veicular antes de iniciar o ensaio.',
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
                  'Bateria',
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
              state.chargingStatusLabel,
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
                  'Sinal GPS',
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
            state.gpsUncertaintyLabel,
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
              'Sinal: ${quality.label}',
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

/// Card de Coleta Individual na HomeScreen.
class _ColetaCard extends StatelessWidget {
  final _HomeRunItem item;

  const _ColetaCard({required this.item});

  @override
  Widget build(BuildContext context) {
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
          Text(
            item.title,
            style: typography.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
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
    );
  }
}
