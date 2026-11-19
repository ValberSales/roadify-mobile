import 'package:roadify_app/l10n/app_localizations.dart';
import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:roadify_app/core/widgets/app_loading_indicator.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/theme_extensions.dart';
import '../models/nivel_bolha_state.dart';
import '../viewmodel/nivel_bolha_viewmodel.dart';
import 'widgets/bubble_mode_selector.dart';
import 'widgets/circular_bubble_level.dart';
import 'widgets/t_bubble_level.dart';

/// Tela de Sensores & Nível Bolha (Feature Sensores — Sprint 4).
///
/// Integra a arquitetura MVVM com a ViewModel desacoplada [NivelBolhaViewModel]
/// suportando modo duplo de visualização (Circular 2D e Tubular em T),
/// alternância automática por postura veicular, calibração de tara angular persistida,
/// e osciloscópios em tempo real a 60 FPS com buffer circular de 50 amostras (Acelerômetro, Giroscópio e GPS).
class SensoresScreen extends StatefulWidget {
  final NivelBolhaViewModel? viewModel;

  const SensoresScreen({super.key, this.viewModel});

  @override
  State<SensoresScreen> createState() => _SensoresScreenState();
}

class _SensoresScreenState extends State<SensoresScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late final NivelBolhaViewModel _viewModel;
  late final bool _ownsViewModel;
  bool _isLoadingCalibration = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    final isWidgetTest = WidgetsBinding.instance.runtimeType
        .toString()
        .contains('Test');
    _ownsViewModel = widget.viewModel == null;
    _viewModel =
        widget.viewModel ?? NivelBolhaViewModel(autoStart: !isWidgetTest);
    unawaited(_loadPersistedCalibration());
  }

  Future<void> _loadPersistedCalibration() async {
    await _viewModel.loadPersistedCalibration();
    if (!mounted) return;
    setState(() => _isLoadingCalibration = false);
  }

  @override
  void dispose() {
    _tabController.dispose();
    if (_ownsViewModel) {
      _viewModel.dispose();
    }
    super.dispose();
  }

  String _formatSigned(double value, {int decimals = 2}) {
    final sign = value >= 0 ? '+' : '';
    return '$sign${value.toStringAsFixed(decimals).replaceAll('.', ',')}';
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.text('sensorScreenTitle')),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: colors.primary,
          labelColor: colors.primary,
          tabs: [
            Tab(text: AppLocalizations.of(context)!.text('bubbleLevel'), icon: Icon(Icons.screen_rotation_rounded)),
            Tab(text: AppLocalizations.of(context)!.text('liveSignals'), icon: Icon(Icons.show_chart_rounded)),
          ],
        ),
      ),
      body: ListenableBuilder(
        listenable: _viewModel,
        builder: (context, _) {
          final state = _viewModel.state;
          final isDark = context.isDarkMode;

          if (_isLoadingCalibration) {
            return const AppLoadingIndicator();
          }

          return TabBarView(
            controller: _tabController,
            children: [
              // Aba 1: Nível Bolha com arquitetura MVVM e Tara Persistida
              SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  AppDimensions.space20,
                  AppDimensions.space16,
                  AppDimensions.space20,
                  AppDimensions.pillDockHeight +
                      AppDimensions.pillDockMarginBottom +
                      40,
                ),
                child: Column(
                  children: [
                    // Texto orientativo de alinhamento veicular
                    Text(
                      AppLocalizations.of(context)!.text('levelingInstruction'),
                      style: typography.bodyMedium?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppDimensions.space16),

                    // Seletor de Modo (Auto / Circular 2D / Tubular T)
                    BubbleModeSelector(
                      currentMode: state.selectedMode,
                      onModeChanged: _viewModel.setMode,
                    ),
                    const SizedBox(height: AppDimensions.space12),

                    // Banner de status da orientação e modo ativo
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color:
                            (isDark
                                    ? colors.surfaceContainerHighest
                                    : Colors.grey.shade100)
                                .withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: colors.outlineVariant.withValues(alpha: 0.5),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                state.detectedOrientation ==
                                        DeviceOrientationMode.horizontal
                                    ? Icons.table_restaurant_rounded
                                    : Icons.stay_current_portrait_rounded,
                                size: 16,
                                color: colors.primary,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Postura: ${state.detectedOrientation.label}',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w600,
                                  color: colors.onSurface,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: colors.primary.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              AppLocalizations.of(context)!
                                  .text('view')
                                  .replaceAll('{mode}', state.activeMode.label),
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                                color: colors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppDimensions.space20),

                    // Exibição Dinâmica do Nível com transição suave
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      transitionBuilder: (child, animation) {
                        return FadeTransition(
                          opacity: animation,
                          child: ScaleTransition(
                            scale: Tween<double>(
                              begin: 0.95,
                              end: 1.0,
                            ).animate(animation),
                            child: child,
                          ),
                        );
                      },
                      child: state.activeMode == BubbleDisplayMode.circular2D
                          ? CircularBubbleLevel(
                              key: const ValueKey('circular_level'),
                              state: state,
                            )
                          : TBubbleLevel(
                              key: const ValueKey('t_level'),
                              state: state,
                            ),
                    ),
                    const SizedBox(height: AppDimensions.space20),

                    // Cards com Leituras dos Eixos X e Y
                    Row(
                      children: [
                        Expanded(
                          child: _AxisAngleCard(
                            label: 'EIXO X (ROLL)',
                            subtitle: AppLocalizations.of(context)!.text('sideTilt'),
                            angle: state.calibratedAngleX,
                            isLevel: state.isLevelX,
                          ),
                        ),
                        const SizedBox(width: AppDimensions.space12),
                        Expanded(
                          child: _AxisAngleCard(
                            label: 'EIXO Y (PITCH)',
                            subtitle: AppLocalizations.of(context)!.text('frontTilt'),
                            angle: state.calibratedAngleY,
                            isLevel: state.isLevelY,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimensions.space12),

                    // Card de Status do Nivelamento Geral
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: state.isLevel
                            ? AppColors.success.withValues(alpha: 0.1)
                            : colors.surface,
                        borderRadius: AppDimensions.borderRadiusCard,
                        border: Border.all(
                          color: state.isLevel
                              ? AppColors.success
                              : colors.outlineVariant,
                          width: state.isLevel ? 1.5 : 1.0,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            state.isLevel
                                ? Icons.verified_rounded
                                : Icons.info_outline_rounded,
                            color: state.isLevel
                                ? AppColors.success
                                : colors.onSurfaceVariant,
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  state.isLevel
                                      ? 'Smartphone Perfeitamente Nivelado!'
                                      : AppLocalizations.of(context)!.text('misaligned'),
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                    color: state.isLevel
                                        ? AppColors.success
                                        : colors.onSurface,
                                  ),
                                ),
                              Text(
                                state.isLevel
                                    ? 'Tolerância angular <= 0,5° atingida com sucesso.'
                                    : 'Ajuste o suporte ou calibre a tara angular na posição atual.',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: colors.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppDimensions.space20),

                  // Botão Principal: Calibrar Nível (Zerar Nível)
                  SizedBox(
                    width: double.infinity,
                    height: AppDimensions.buttonHeight,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colors.primary,
                        foregroundColor: colors.onPrimary,
                        shape: const RoundedRectangleBorder(
                          borderRadius: AppDimensions.borderRadiusMedium,
                        ),
                      ),
                      onPressed: () {
                        _viewModel.calibrate();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Nível calibrado e zerado em 0,0°! Tara salva na sessão.',
                            ),
                            behavior: SnackBarBehavior.floating,
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                      child: Text(
                        state.isCalibrated
                            ? 'Recalibrar Nível (Zerar Nível)'
                            : 'Calibrar Nível (Zerar Nível)',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  if (state.isCalibrated) ...[
                    const SizedBox(height: AppDimensions.space8),
                    TextButton.icon(
                      onPressed: () {
                        _viewModel.resetCalibration();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Tara angular removida.'),
                            behavior: SnackBarBehavior.floating,
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                      icon: const Icon(Icons.restart_alt_rounded, size: 18),
                      label: Text(
                        'Remover Tara (Offsets: ${_formatSigned(state.calibOffsetX, decimals: 1)}° / ${_formatSigned(state.calibOffsetY, decimals: 1)}°)',
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Aba 2: Sinais ao Vivo (Sprint 4 — Osciloscópios com Buffer Circular de 50 Amostras e 60 FPS)
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                AppDimensions.space20,
                AppDimensions.space16,
                AppDimensions.space20,
                AppDimensions.pillDockHeight +
                    AppDimensions.pillDockMarginBottom +
                    40,
              ),
              child: Column(
                children: [
                  // Banner de Telemetria de Alta Performance (60 FPS & Buffer Circular 50 Amostras)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: (isDark
                              ? colors.surfaceContainerHighest
                              : Colors.grey.shade100)
                          .withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: colors.outlineVariant.withValues(alpha: 0.5),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                            color: Color(0xFF10B981),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Osciloscópio Contínuo • 60 FPS • Buffer Circular: 50 amostras',
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: colors.onSurface,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'LIVE',
                            style: TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF10B981),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppDimensions.space16),

                  // 1. SINAL DO ACELERÔMETRO (Eixos X, Y, Z com cores diferenciadas)
                  _SensorLiveCard(
                    key: const ValueKey('live-card-accelerometer'),
                    title: 'Acelerômetro Triaxial (m/s²)',
                    subtitle: 'Vibrações e aceleração instantânea da via',
                    color: const Color(0xFF3B82F6),
                    footerBadges: [
                      _AxisPillBadge(
                        label: 'Eixo X',
                        value: _formatSigned(state.accelX),
                        unit: 'm/s²',
                        color: const Color(0xFFEF4444),
                      ),
                      _AxisPillBadge(
                        label: 'Eixo Y',
                        value: _formatSigned(state.accelY),
                        unit: 'm/s²',
                        color: const Color(0xFF10B981),
                      ),
                      _AxisPillBadge(
                        label: 'Eixo Z',
                        value: _formatSigned(state.accelZ),
                        unit: 'm/s²',
                        color: const Color(0xFF3B82F6),
                      ),
                    ],
                    chart: _LiveWaveformChart(
                      key: const ValueKey('live-chart-accelerometer'),
                      sampleTick: _viewModel.sampleTick,
                      minValue: -14.0,
                      maxValue: 14.0,
                      unitLabel: 'm/s²',
                      series: [
                        _WaveformSeries(
                          label: 'Eixo X (Lateral)',
                          color: const Color(0xFFEF4444), // Vermelho
                          values: _viewModel.signalHistory
                              .map((s) => s.accelX)
                              .toList(growable: false),
                        ),
                        _WaveformSeries(
                          label: 'Eixo Y (Longitudinal)',
                          color: const Color(0xFF10B981), // Verde
                          values: _viewModel.signalHistory
                              .map((s) => s.accelY)
                              .toList(growable: false),
                        ),
                        _WaveformSeries(
                          label: 'Eixo Z (Vertical)',
                          color: const Color(0xFF3B82F6), // Azul
                          values: _viewModel.signalHistory
                              .map((s) => s.accelZ)
                              .toList(growable: false),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppDimensions.space16),

                  // 2. SINAL DO GIROSCÓPIO (Eixos X, Y, Z com cores diferenciadas)
                  _SensorLiveCard(
                    key: const ValueKey('live-card-gyroscope'),
                    title: 'Giroscópio Triaxial (rad/s)',
                    subtitle: 'Taxa de rotação angular e guinada do veículo',
                    color: const Color(0xFF8B5CF6),
                    footerBadges: [
                      _AxisPillBadge(
                        label: 'Giro X',
                        value: _formatSigned(state.gyroX),
                        unit: 'rad/s',
                        color: const Color(0xFFF59E0B),
                      ),
                      _AxisPillBadge(
                        label: 'Giro Y',
                        value: _formatSigned(state.gyroY),
                        unit: 'rad/s',
                        color: const Color(0xFF8B5CF6),
                      ),
                      _AxisPillBadge(
                        label: 'Giro Z',
                        value: _formatSigned(state.gyroZ),
                        unit: 'rad/s',
                        color: const Color(0xFF06B6D4),
                      ),
                    ],
                    chart: _LiveWaveformChart(
                      key: const ValueKey('live-chart-gyroscope'),
                      sampleTick: _viewModel.sampleTick,
                      minValue: -3.0,
                      maxValue: 3.0,
                      unitLabel: 'rad/s',
                      series: [
                        _WaveformSeries(
                          label: 'Roll Rate (X)',
                          color: const Color(0xFFF59E0B), // Âmbar
                          values: _viewModel.signalHistory
                              .map((s) => s.gyroX)
                              .toList(growable: false),
                        ),
                        _WaveformSeries(
                          label: 'Pitch Rate (Y)',
                          color: const Color(0xFF8B5CF6), // Roxo
                          values: _viewModel.signalHistory
                              .map((s) => s.gyroY)
                              .toList(growable: false),
                        ),
                        _WaveformSeries(
                          label: 'Yaw Rate (Z)',
                          color: const Color(0xFF06B6D4), // Ciano
                          values: _viewModel.signalHistory
                              .map((s) => s.gyroZ)
                              .toList(growable: false),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppDimensions.space16),

                  // 3. TELEMETRIA GPS EM TEMPO REAL
                  _GpsTelemetryCard(
                    key: const ValueKey('live-card-gps'),
                    speedKmh: state.gpsSpeed,
                    accuracyMeters: state.gpsAccuracy,
                    altitudeMeters: state.gpsAltitude,
                    latitude: state.gpsLatitude,
                    longitude: state.gpsLongitude,
                    hasSignal: state.hasGpsSignal,
                  ),
                  const SizedBox(height: AppDimensions.space16),

                  // 4. INCLINAÇÃO COMPENSADA (ROLL E PITCH)
                  _SensorLiveCard(
                    key: const ValueKey('live-card-inclination'),
                    title: 'Inclinação Compensada (Graus)',
                    subtitle: 'Ângulos nivelados em relação à tara veicular',
                    color: AppColors.secondary,
                    footerBadges: [
                      _AxisPillBadge(
                        label: 'Roll (X)',
                        value: _formatSigned(state.calibratedAngleX, decimals: 1),
                        unit: '°',
                        color: AppColors.secondary,
                      ),
                      _AxisPillBadge(
                        label: 'Pitch (Y)',
                        value: _formatSigned(state.calibratedAngleY, decimals: 1),
                        unit: '°',
                        color: colors.primary,
                      ),
                    ],
                    chart: _LiveWaveformChart(
                      key: const ValueKey('live-chart-inclination'),
                      sampleTick: _viewModel.sampleTick,
                      minValue: -30.0,
                      maxValue: 30.0,
                      unitLabel: '°',
                      series: [
                        _WaveformSeries(
                          label: 'Roll (X)',
                          color: AppColors.secondary,
                          values: _viewModel.signalHistory
                              .map((s) => s.roll)
                              .toList(growable: false),
                        ),
                        _WaveformSeries(
                          label: 'Pitch (Y)',
                          color: colors.primary,
                          values: _viewModel.signalHistory
                              .map((s) => s.pitch)
                              .toList(growable: false),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppDimensions.space16),

                  // 5. REFERÊNCIA DE TARA ANGULAR
                  _SensorLiveCard(
                    key: const ValueKey('live-card-tare'),
                    title: 'Referência de Tara Angular',
                    subtitle: state.isCalibrated
                        ? 'Tara de instalação ativa (compensa desnível do suporte)'
                        : 'Padrão horizontal de fábrica',
                    color: context.roadQualityColors.boa,
                    footerBadges: [
                      _AxisPillBadge(
                        label: 'Offset X',
                        value: _formatSigned(state.calibOffsetX, decimals: 1),
                        unit: '°',
                        color: context.roadQualityColors.boa,
                      ),
                      _AxisPillBadge(
                        label: 'Offset Y',
                        value: _formatSigned(state.calibOffsetY, decimals: 1),
                        unit: '°',
                        color: AppColors.secondary,
                      ),
                    ],
                    chart: _TareReferenceBarChart(
                      offsetX: state.calibOffsetX,
                      offsetY: state.calibOffsetY,
                      isCalibrated: state.isCalibrated,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    ),
  );
}
}

/// Badge compacto de leitura instantânea por eixo.
class _AxisPillBadge extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final Color color;

  const _AxisPillBadge({
    required this.label,
    required this.value,
    required this.unit,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          Text(
            '$value $unit',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

/// Card de sensores com osciloscópio e badges informativos.
class _SensorLiveCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Color color;
  final Widget chart;
  final List<Widget> footerBadges;

  const _SensorLiveCard({
    super.key,
    required this.title,
    this.subtitle,
    required this.color,
    required this.chart,
    this.footerBadges = const [],
  });

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
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: typography.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: typography.bodySmall?.copyWith(
                          fontSize: 11,
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  AppLocalizations.of(context)!.text('live'),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.space12),
          chart,
          if (footerBadges.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: footerBadges,
            ),
          ],
        ],
      ),
    );
  }
}

/// Card de Telemetria GPS em Tempo Real.
class _GpsTelemetryCard extends StatelessWidget {
  final double speedKmh;
  final double accuracyMeters;
  final double altitudeMeters;
  final double latitude;
  final double longitude;
  final bool hasSignal;

  const _GpsTelemetryCard({
    super.key,
    required this.speedKmh,
    required this.accuracyMeters,
    required this.altitudeMeters,
    required this.latitude,
    required this.longitude,
    required this.hasSignal,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    const gpsColor = Color(0xFF0EA5E9);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.space16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: AppDimensions.borderRadiusCard,
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.satellite_alt_rounded, size: 20, color: gpsColor),
                  const SizedBox(width: 8),
                  Text(
                    'GPS & Cinemática em Tempo Real',
                    style: typography.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: (hasSignal ? const Color(0xFF10B981) : Colors.orange)
                      .withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  hasSignal ? 'SINAL OK' : 'LOCALIZAÇÃO',
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                    color: hasSignal ? const Color(0xFF10B981) : Colors.orange,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              // Velocidade
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: gpsColor.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: gpsColor.withValues(alpha: 0.25)),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Velocidade',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        speedKmh.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: gpsColor,
                        ),
                      ),
                      const Text(
                        'km/h',
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // Altitude
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colors.surfaceContainerHighest.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.5)),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Altitude',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${altitudeMeters.toStringAsFixed(0)}m',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: colors.onSurface,
                        ),
                      ),
                      Text(
                        'Precisão: ±${accuracyMeters.toStringAsFixed(1)}m',
                        style: TextStyle(
                          fontSize: 9.5,
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: colors.surfaceContainerHighest.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Coordenadas:',
                  style: TextStyle(fontSize: 11, color: colors.onSurfaceVariant),
                ),
                Text(
                  '${latitude.toStringAsFixed(5)}°, ${longitude.toStringAsFixed(5)}°',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'monospace',
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

/// Gráfico temporal ao vivo (osciloscópio multicanal) renderizado via [CustomPaint].
class _LiveWaveformChart extends StatelessWidget {
  final List<_WaveformSeries> series;
  final int sampleTick;
  final double minValue;
  final double maxValue;
  final String unitLabel;

  const _LiveWaveformChart({
    super.key,
    required this.series,
    required this.sampleTick,
    required this.minValue,
    required this.maxValue,
    required this.unitLabel,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Legenda dos eixos com cores diferenciadas
          Wrap(
            spacing: 12,
            runSpacing: 4,
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (var i = 0; i < series.length; i++) ...[
                    if (i > 0) const SizedBox(width: 10),
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: series[i].color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      series[i].label,
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
              Text(
                '${minValue.toStringAsFixed(0)}$unitLabel a +${maxValue.toStringAsFixed(0)}$unitLabel',
                style: TextStyle(
                  fontSize: 10,
                  color: colors.onSurfaceVariant.withValues(alpha: 0.75),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          // Área de osciloscópio com RepaintBoundary para 60 FPS garantidos
          SizedBox(
            height: 110,
            width: double.infinity,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: RepaintBoundary(
                child: CustomPaint(
                  painter: _LiveWaveformPainter(
                    series: series,
                    sampleTick: sampleTick,
                    minValue: minValue,
                    maxValue: maxValue,
                    gridColor: colors.outlineVariant.withValues(alpha: 0.45),
                    zeroLineColor: colors.onSurfaceVariant.withValues(alpha: 0.4),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WaveformSeries {
  final String label;
  final Color color;
  final List<double> values;

  const _WaveformSeries({
    required this.label,
    required this.color,
    required this.values,
  });
}

class _LiveWaveformPainter extends CustomPainter {
  final List<_WaveformSeries> series;
  final int sampleTick;
  final double minValue;
  final double maxValue;
  final Color gridColor;
  final Color zeroLineColor;

  const _LiveWaveformPainter({
    required this.series,
    required this.sampleTick,
    required this.minValue,
    required this.maxValue,
    required this.gridColor,
    required this.zeroLineColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 0.8;

    // Linhas horizontais de grade (20%, 50%, 80%)
    for (final ratio in const [0.2, 0.5, 0.8]) {
      final y = size.height * ratio;
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        ratio == 0.5
            ? (Paint()
                ..color = zeroLineColor
                ..strokeWidth = 1.1)
            : gridPaint,
      );
    }

    // Linhas verticais de grade com deslocamento contínuo (efeito osciloscópio em varredura)
    const verticalDivisions = 6;
    final stepX = size.width / verticalDivisions;
    final shift = (sampleTick % 10) / 10.0 * stepX;
    for (var i = 0; i <= verticalDivisions + 1; i++) {
      final x = (i * stepX) - shift;
      if (x >= 0 && x <= size.width) {
        canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
      }
    }

    // Calcula alcance dinâmico caso valores ultrapassem [minValue, maxValue]
    var effectiveMin = minValue;
    var effectiveMax = maxValue;
    for (final s in series) {
      for (final v in s.values) {
        if (v < effectiveMin) effectiveMin = v - 2.0;
        if (v > effectiveMax) effectiveMax = v + 2.0;
      }
    }
    final range = math.max(1e-3, effectiveMax - effectiveMin);

    double mapY(double value) {
      final normalized = (value - effectiveMin) / range;
      return (size.height - 6) -
          (normalized.clamp(0.0, 1.0) * (size.height - 12));
    }

    for (final s in series) {
      if (s.values.isEmpty) continue;

      final linePaint = Paint()
        ..color = s.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;

      final path = Path();
      final count = s.values.length;
      Offset lastPoint = Offset.zero;

      for (var i = 0; i < count; i++) {
        final x = count == 1
            ? size.width
            : (i / (count - 1)) * (size.width - 6);
        final y = mapY(s.values[i]);
        final pt = Offset(x, y);
        if (i == 0) {
          path.moveTo(pt.dx, pt.dy);
        } else {
          path.lineTo(pt.dx, pt.dy);
        }
        lastPoint = pt;
      }

      canvas.drawPath(path, linePaint);

      // Ponto luminoso na extremidade direita (leitura mais recente em tempo real)
      final glowPaint = Paint()
        ..color = s.color.withValues(alpha: 0.28)
        ..style = PaintingStyle.fill;
      final dotPaint = Paint()
        ..color = s.color
        ..style = PaintingStyle.fill;

      canvas.drawCircle(lastPoint, 6.0, glowPaint);
      canvas.drawCircle(lastPoint, 3.2, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _LiveWaveformPainter oldDelegate) {
    return oldDelegate.sampleTick != sampleTick ||
        oldDelegate.series != series ||
        oldDelegate.minValue != minValue ||
        oldDelegate.maxValue != maxValue;
  }
}

/// Visualizador gráfico de barras de compensação para a Referência de Tara Angular.
class _TareReferenceBarChart extends StatelessWidget {
  final double offsetX;
  final double offsetY;
  final bool isCalibrated;

  const _TareReferenceBarChart({
    required this.offsetX,
    required this.offsetY,
    required this.isCalibrated,
  });

  Widget _buildOffsetRow(
    BuildContext context, {
    required String label,
    required double offsetDeg,
    required Color color,
  }) {
    final colors = context.colors;
    final clamped = (offsetDeg / 45.0).clamp(-1.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: colors.onSurfaceVariant,
              ),
            ),
            Text(
              '${offsetDeg >= 0 ? '+' : ''}${offsetDeg.toStringAsFixed(1)}°',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: isCalibrated ? color : colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        SizedBox(
          height: 10,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final halfWidth = constraints.maxWidth / 2;
              final barWidth = (clamped.abs() * halfWidth).clamp(
                2.0,
                halfWidth,
              );
              final left = clamped >= 0 ? halfWidth : halfWidth - barWidth;
              return Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: colors.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  Positioned(
                    left: halfWidth - 0.5,
                    top: 0,
                    bottom: 0,
                    child: Container(
                      width: 1,
                      color: colors.onSurfaceVariant.withValues(alpha: 0.5),
                    ),
                  ),
                  Positioned(
                    left: left,
                    top: 1,
                    bottom: 1,
                    width: barWidth,
                    child: Container(
                      decoration: BoxDecoration(
                        color: isCalibrated ? color : colors.outline,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final goodColor = context.roadQualityColors.boa;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Column(
        children: [
          _buildOffsetRow(
            context,
            label: 'Compensação Eixo X (Roll)',
            offsetDeg: offsetX,
            color: goodColor,
          ),
          const SizedBox(height: 10),
          _buildOffsetRow(
            context,
            label: 'Compensação Eixo Y (Pitch)',
            offsetDeg: offsetY,
            color: AppColors.secondary,
          ),
        ],
      ),
    );
  }
}

/// Card de exibição angular por eixo no Nível Bolha.
class _AxisAngleCard extends StatelessWidget {
  final String label;
  final String subtitle;
  final double angle;
  final bool isLevel;

  const _AxisAngleCard({
    required this.label,
    required this.subtitle,
    required this.angle,
    required this.isLevel,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;

    return Container(
      padding: const EdgeInsets.all(AppDimensions.space12),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: AppDimensions.borderRadiusCard,
        border: Border.all(
          color: isLevel ? AppColors.success : colors.outlineVariant,
          width: isLevel ? 1.5 : 1.0,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: typography.labelMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: isLevel ? AppColors.success : colors.onSurfaceVariant,
                ),
              ),
              if (isLevel) ...[
                const SizedBox(width: 4),
                const Icon(
                  Icons.check_circle_rounded,
                  size: 14,
                  color: AppColors.success,
                ),
              ],
            ],
          ),
          const SizedBox(height: 2),
          TweenAnimationBuilder<double>(
            tween: Tween<double>(end: angle),
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            builder: (context, animAngle, _) {
              return Text(
                '${animAngle >= 0 ? '+' : ''}${animAngle.toStringAsFixed(1)}°',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: isLevel ? AppColors.success : colors.onSurface,
                ),
              );
            },
          ),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 10,
              color: colors.onSurfaceVariant.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }
}
