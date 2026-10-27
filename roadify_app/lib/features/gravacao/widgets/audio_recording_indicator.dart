import 'package:flutter/material.dart';

class AudioRecordingIndicator extends StatelessWidget {
  final bool isRecording;
  final Duration elapsed;
  final int maxDurationSeconds;
  final double amplitudeDb;

  const AudioRecordingIndicator({
    super.key,
    required this.isRecording,
    required this.elapsed,
    required this.maxDurationSeconds,
    required this.amplitudeDb,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final level = ((amplitudeDb + 60) / 60).clamp(0.08, 1.0);
    final progress = (elapsed.inMilliseconds / (maxDurationSeconds * 1000))
        .clamp(0.0, 1.0);

    return Container(
      key: const ValueKey('audio-recording-indicator'),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isRecording ? colors.errorContainer : colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isRecording
              ? colors.error.withValues(alpha: 0.45)
              : colors.outlineVariant,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                isRecording ? Icons.fiber_manual_record : Icons.mic_none,
                color: isRecording ? colors.error : colors.onSurfaceVariant,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  isRecording ? 'ÁUDIO GRAVANDO' : 'Áudio pronto',
                  style: TextStyle(
                    color: isRecording ? colors.error : colors.onSurfaceVariant,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
              Text(
                '${elapsed.inMinutes.toString().padLeft(2, '0')}:'
                '${(elapsed.inSeconds % 60).toString().padLeft(2, '0')}',
                key: const ValueKey('audio-recording-duration'),
                style: const TextStyle(
                  fontFeatures: [FontFeature.tabularFigures()],
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 34,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: List.generate(24, (index) {
                final modulation = (index % 5 + 2) / 6;
                final height = isRecording
                    ? (5 + level * 27 * modulation).toDouble()
                    : 5.0;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 4,
                  height: height,
                  decoration: BoxDecoration(
                    color: isRecording ? colors.error : colors.outlineVariant,
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: isRecording ? progress : 0,
              minHeight: 4,
              backgroundColor: colors.surfaceContainerHighest,
              color: colors.error,
            ),
          ),
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              'Limite de $maxDurationSeconds s',
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ),
        ],
      ),
    );
  }
}
