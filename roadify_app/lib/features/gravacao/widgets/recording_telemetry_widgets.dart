import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:roadify_app/l10n/app_localizations_catalog.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/theme_extensions.dart';
import '../services/sensor_trace_buffer.dart';

/// Card de métrica de recurso do dispositivo (RAM / Bateria) no HUD de gravação.
class DeviceResourceMetric extends StatelessWidget {
  final String label;
  final String value;
  final String detail;
  final IconData icon;
  final Color? valueColor;

  const DeviceResourceMetric({
    super.key,
    required this.label,
    required this.value,
    required this.detail,
    required this.icon,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    return Container(
      padding: const EdgeInsets.all(AppDimensions.space12),
      decoration: BoxDecoration(
        border: Border.all(color: colors.outlineVariant),
        borderRadius: AppDimensions.borderRadiusMedium,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: colors.primary),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  label,
                  style: typography.labelSmall?.copyWith(
                    color: colors.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: typography.titleLarge?.copyWith(
              color: valueColor,
              fontWeight: FontWeight.w800,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(height: 2),
          Text(
            detail,
            style: typography.bodySmall?.copyWith(
              color: colors.onSurfaceVariant,
              fontSize: 10,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

/// Métrica fixa no cabeçalho da gravação (Velocidade GPS / Distância).
class StickyMetric extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final bool prominent;

  const StickyMetric({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.prominent = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: colors.primary),
            const SizedBox(width: 4),
            Text(
              label,
              style: typography.labelSmall?.copyWith(
                fontSize: prominent ? 10 : 9,
                color: colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
        Text(
          value,
          key: prominent ? const ValueKey('speedometer-value') : null,
          style: (prominent ? typography.titleLarge : typography.titleSmall)
              ?.copyWith(
                color: prominent ? colors.primary : null,
                fontWeight: FontWeight.w800,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
        ),
      ],
    );
  }
}

/// Badge compacto de valor por eixo (X, Y, Z) do acelerômetro.
class AxisValueBadge extends StatelessWidget {
  final String label;
  final double value;
  final Color color;

  const AxisValueBadge({
    super.key,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        '$label: ${value >= 0 ? '+' : ''}${value.toStringAsFixed(1)}',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

/// Gráfico de osciloscópio do acelerômetro ao vivo durante a gravação com semântica a11y.
class RecordingAccelerometerChart extends StatelessWidget {
  final ValueListenable<int> telemetryRevision;
  final SensorTraceBuffer sensorTrace;
  final double Function() currentX;
  final double Function() currentY;
  final double Function() currentZ;

  const RecordingAccelerometerChart({
    super.key,
    required this.telemetryRevision,
    required this.sensorTrace,
    required this.currentX,
    required this.currentY,
    required this.currentZ,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final typography = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);

    return Semantics(
      label: l10n.text('liveAccelerometerTitle'),
      child: Container(
        key: const ValueKey('live-chart-accelerometer'),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: AppDimensions.borderRadiusCard,
          border: Border.all(color: colors.outlineVariant),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 6,
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.show_chart_rounded,
                      size: 18,
                      color: colors.primary,
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        l10n.text('liveAccelerometerTitle'),
                        style: typography.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                ValueListenableBuilder<int>(
                  valueListenable: telemetryRevision,
                  builder: (context, _, _) => Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      AxisValueBadge(
                        label: 'X',
                        value: currentX(),
                        color: const Color(0xFF10B981),
                      ),
                      AxisValueBadge(
                        label: 'Y',
                        value: currentY(),
                        color: const Color(0xFF06B6D4),
                      ),
                      AxisValueBadge(
                        label: 'Z',
                        value: currentZ(),
                        color: const Color(0xFFF59E0B),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ValueListenableBuilder<int>(
              valueListenable: telemetryRevision,
              builder: (context, _, _) => SizedBox(
                height: 150,
                width: double.infinity,
                child: RepaintBoundary(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CustomPaint(
                      painter: OscilloscopePainter(
                        bufferX: sensorTrace.xSamples,
                        bufferY: sensorTrace.ySamples,
                        bufferZ: sensorTrace.zSamples,
                        sampleTick: sensorTrace.sampleTick,
                        windowCapacity: SensorTraceBuffer.capacity,
                        colorX: const Color(0xFF10B981),
                        colorY: const Color(0xFF06B6D4),
                        colorZ: const Color(0xFFF59E0B),
                        gridColor: colors.outlineVariant.withValues(alpha: 0.5),
                        backgroundColor: context.isDarkMode
                            ? const Color(0xFF0D1F18)
                            : const Color(0xFFF1F5F3),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '-60s',
                  style: typography.labelSmall?.copyWith(
                    fontSize: 10,
                    color: colors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  '-30s',
                  style: typography.labelSmall?.copyWith(
                    fontSize: 10,
                    color: colors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    l10n.text('timeWindow1MinLabel'),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: typography.labelSmall?.copyWith(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  '0s',
                  style: typography.labelSmall?.copyWith(
                    fontSize: 10,
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// CustomPainter para desenhar as ondas do acelerômetro em tempo real (janela contínua de 1 minuto).
class OscilloscopePainter extends CustomPainter {
  final List<double> bufferX;
  final List<double> bufferY;
  final List<double> bufferZ;
  final int sampleTick;
  final int windowCapacity;
  final Color colorX;
  final Color colorY;
  final Color colorZ;
  final Color gridColor;
  final Color backgroundColor;

  OscilloscopePainter({
    required this.bufferX,
    required this.bufferY,
    required this.bufferZ,
    this.sampleTick = 0,
    this.windowCapacity = SensorTraceBuffer.capacity,
    required this.colorX,
    required this.colorY,
    required this.colorZ,
    required this.gridColor,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = backgroundColor);

    final centerY = size.height / 2;
    final gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 1.0;

    canvas.drawLine(Offset(0, centerY), Offset(size.width, centerY), gridPaint);
    canvas.drawLine(
      Offset(0, centerY - size.height * 0.35),
      Offset(size.width, centerY - size.height * 0.35),
      gridPaint,
    );
    canvas.drawLine(
      Offset(0, centerY + size.height * 0.35),
      Offset(size.width, centerY + size.height * 0.35),
      gridPaint,
    );

    // 6 divisões verticais de 10 segundos cada = janela de 60 segundos (1 minuto)
    const verticalDivisions = 6;
    final gridStepX = size.width / verticalDivisions;
    final samplesPerDivision = math.max(
      1,
      windowCapacity ~/ verticalDivisions,
    );
    final shift =
        (sampleTick % samplesPerDivision) / samplesPerDivision * gridStepX;
    for (var i = 0; i <= verticalDivisions + 1; i++) {
      final x = (i * gridStepX) - shift;
      if (x >= 0 && x <= size.width) {
        canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
      }
    }

    if (bufferX.length < 2) return;

    const range = 15.0;
    final effectiveWindow = math.max(2, math.max(windowCapacity, bufferX.length));

    double mapY(double val) {
      final normalized = (val / range).clamp(-1.0, 1.0);
      return centerY - (normalized * (size.height * 0.45));
    }

    void drawTrace(List<double> buffer, Color color) {
      final paint = Paint()
        ..color = color
        ..strokeWidth = 1.8
        ..style = PaintingStyle.stroke
        ..strokeJoin = StrokeJoin.round;

      final path = Path();
      final stepX = size.width / (effectiveWindow - 1);

      for (var i = 0; i < buffer.length; i++) {
        final x = i * stepX;
        final y = mapY(buffer[i]);
        if (i == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }

      canvas.drawPath(path, paint);
    }

    drawTrace(bufferZ, colorZ);
    drawTrace(bufferY, colorY);
    drawTrace(bufferX, colorX);
  }

  @override
  bool shouldRepaint(covariant OscilloscopePainter oldDelegate) => true;
}
