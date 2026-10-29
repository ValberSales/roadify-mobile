import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/theme_extensions.dart';
import '../models/nivel_bolha_state.dart';
import '../viewmodel/nivel_bolha_viewmodel.dart';
import 'widgets/bubble_mode_selector.dart';
import 'widgets/circular_bubble_level.dart';
import 'widgets/t_bubble_level.dart';

/// Tela de Sensores & Nível Bolha (Feature Sensores — Roadify Mobile).
///
/// Integra a arquitetura MVVM com a ViewModel desacoplada [NivelBolhaViewModel]
/// suportando modo duplo de visualização (Circular 2D e Tubular em T),
/// alternância automática por orientação e calibração de tara angular persistida.
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
    unawaited(_viewModel.loadPersistedCalibration());
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
        title: const Text('Sensores & Nivelamento'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: colors.primary,
          labelColor: colors.primary,
          tabs: const [
            Tab(text: 'Nível Bolha', icon: Icon(Icons.screen_rotation_rounded)),
            Tab(text: 'Sinais ao Vivo', icon: Icon(Icons.show_chart_rounded)),
          ],
        ),
      ),
      body: ListenableBuilder(
        listenable: _viewModel,
        builder: (context, _) {
          final state = _viewModel.state;
          final isDark = context.isDarkMode;

          return TabBarView(
            controller: _tabController,
            children: [
              // Aba 1: Nível Bolha com arquitetura MVVM e Tara Persistida (SP2-05 e SP2-06)
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
                      'Posicione o smartphone no suporte veicular ou na bancada e calibre a referência.',
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
                              color: AppColors.primary.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'Visualização: ${state.activeMode.label}',
                              style: const TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
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
                            subtitle: 'Inclinação Lateral',
                            angle: state.calibratedAngleX,
                            isLevel: state.isLevelX,
                          ),
                        ),
                        const SizedBox(width: AppDimensions.space12),
                        Expanded(
                          child: _AxisAngleCard(
                            label: 'EIXO Y (PITCH)',
                            subtitle: 'Inclinação Frontal',
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
                                      : 'Desalinhado da Referência',
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
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
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

              // Aba 2: Sinais ao Vivo conectados ao estado inercial reativo
              SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  AppDimensions.space20,
                  AppDimensions.space20,
                  AppDimensions.space20,
                  AppDimensions.pillDockHeight +
                      AppDimensions.pillDockMarginBottom +
                      40,
                ),
                child: Column(
                  children: [
                    _SensorLiveCard(
                      key: const ValueKey('live-card-accelerometer'),
                      title: 'Acelerômetro (m/s²)',
                      values:
                          'X: ${_formatSigned(state.accelX)} | Y: ${_formatSigned(state.accelY)} | Z: ${_formatSigned(state.accelZ)}',
                      color: colors.primary,
                      chart: _LiveWaveformChart(
                        key: const ValueKey('live-chart-accelerometer'),
                        sampleTick: _viewModel.sampleTick,
                        minValue: -12.0,
                        maxValue: 12.0,
                        unitLabel: 'm/s²',
                        series: [
                          _WaveformSeries(
                            label: 'Eixo X',
                            color: const Color(0xFFEF4444),
                            values: _viewModel.signalHistory
                                .map((s) => s.accelX)
                                .toList(growable: false),
                          ),
                          _WaveformSeries(
                            label: 'Eixo Y',
                            color: const Color(0xFF3B82F6),
                            values: _viewModel.signalHistory
                                .map((s) => s.accelY)
                                .toList(growable: false),
                          ),
                          _WaveformSeries(
                            label: 'Eixo Z',
                            color: colors.primary,
                            values: _viewModel.signalHistory
                                .map((s) => s.accelZ)
                                .toList(growable: false),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppDimensions.space16),
                    _SensorLiveCard(
                      key: const ValueKey('live-card-inclination'),
                      title: 'Inclinação Compensada (Graus)',
                      values:
                          'Roll (X): ${_formatSigned(state.calibratedAngleX, decimals: 1)}° | Pitch (Y): ${_formatSigned(state.calibratedAngleY, decimals: 1)}°',
                      color: AppColors.secondary,
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
                    _SensorLiveCard(
                      key: const ValueKey('live-card-tare'),
                      title: 'Referência de Tara Angular',
                      values: state.isCalibrated
                          ? 'Ativa • Offset X: ${_formatSigned(state.calibOffsetX, decimals: 1)}° | Offset Y: ${_formatSigned(state.calibOffsetY, decimals: 1)}°'
                          : 'Padrão de fábrica (0,0° / 0,0°)',
                      color: context.roadQualityColors.boa,
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

/// Card de exibição angular por eixo.
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
          Text(
            '${angle >= 0 ? '+' : ''}${angle.toStringAsFixed(1)}°',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: isLevel ? AppColors.success : colors.onSurface,
            ),
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

/// Card de sensores para a aba de Sinais ao Vivo.
class _SensorLiveCard extends StatelessWidget {
  final String title;
  final String values;
  final Color color;
  final Widget chart;

  const _SensorLiveCard({
    super.key,
    required this.title,
    required this.values,
    required this.color,
    required this.chart,
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
                child: Text(
                  title,
                  style: typography.titleMedium,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'AO VIVO',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.space12),
          chart,
          const SizedBox(height: AppDimensions.space8),
          Text(
            values,
            style: typography.bodySmall?.copyWith(fontWeight: FontWeight.w600),
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
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Legenda dos eixos
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
          SizedBox(
            height: 110,
            width: double.infinity,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
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
        ],
      ),
    );
  }
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

    // Linhas horizontais de grade (25%, 50%, 75%)
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

    // Linhas verticais de grade com deslocamento contínuo (osciloscópio)
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
      return (size.height - 6) - (normalized.clamp(0.0, 1.0) * (size.height - 12));
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
        final x = count == 1 ? size.width : (i / (count - 1)) * (size.width - 6);
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

      // Ponto luminoso na extremidade direita (leitura mais recente)
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
    // Normaliza em uma escala visual de -45° a +45°
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
              final barWidth = (clamped.abs() * halfWidth).clamp(2.0, halfWidth);
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
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.5),
        ),
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
