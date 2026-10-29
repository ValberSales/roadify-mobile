import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:roadify_app/core/theme/theme_extensions.dart';
import 'package:roadify_app/features/coleta/presentation/widgets/sensor/sensor_configuration_card.dart';
import 'package:roadify_app/features/coleta/presentation/widgets/sensor/sensor_frequency_selector.dart';
import 'package:roadify_app/features/coleta/presentation/widgets/sensor/sensor_option.dart';
import 'package:roadify_app/features/coleta/presentation/widgets/sensor/sensor_section_heading.dart';
import 'package:roadify_app/features/coleta/viewmodels/coleta_viewmodel.dart';

import '../../../../../core/theme/app_dimensions.dart';

class OptionalSensorsSection extends StatefulWidget {
  final Set<SensorColeta> selectedSensors;
  final SensorSelectionChanged onSensorChanged;
  final OptionalSensorSettings settings;
  final ValueChanged<OptionalSensorSettings> onSettingsChanged;

  const OptionalSensorsSection({
    super.key,
    required this.selectedSensors,
    required this.onSensorChanged,
    required this.settings,
    required this.onSettingsChanged,
  });

  @override
  State<OptionalSensorsSection> createState() => _OptionalSensorsSectionState();
}

class _OptionalSensorsSectionState extends State<OptionalSensorsSection> {
  late final TextEditingController _gyroscopeController;
  late final TextEditingController _cameraIntervalController;
  late final TextEditingController _audioIntervalController;
  late final TextEditingController _audioDurationController;
  bool _customGyroscopeFrequency = false;

  static const _gyroscopePresets = [50, 100, 200, 400, 500];
  static const _maximumVideoDurationSeconds = 120;
  static const _maximumAudioDurationSeconds = 300;

  @override
  void initState() {
    super.initState();
    final settings = widget.settings;
    _customGyroscopeFrequency = !_gyroscopePresets.contains(
      settings.gyroscopeFrequencyHz,
    );
    _gyroscopeController = TextEditingController(
      text: _customGyroscopeFrequency
          ? settings.gyroscopeFrequencyHz.toString()
          : '',
    );
    _cameraIntervalController = TextEditingController(
      text: settings.camera.interval.toString(),
    );
    _audioIntervalController = TextEditingController(
      text: settings.audio.interval.toString(),
    );
    _audioDurationController = TextEditingController(
      text: settings.audio.durationSeconds.toString(),
    );
  }

  @override
  void dispose() {
    _gyroscopeController.dispose();
    _cameraIntervalController.dispose();
    _audioIntervalController.dispose();
    _audioDurationController.dispose();
    super.dispose();
  }

  void _updateSettings({
    int? gyroscopeFrequencyHz,
    CameraCaptureSettings? camera,
    AudioCaptureSettings? audio,
  }) {
    final current = widget.settings;
    widget.onSettingsChanged(
      OptionalSensorSettings(
        gyroscopeFrequencyHz:
            gyroscopeFrequencyHz ?? current.gyroscopeFrequencyHz,
        camera: camera ?? current.camera,
        audio: audio ?? current.audio,
      ),
    );
  }

  String? _validateGyroscopeFrequency(String? value) {
    final rate = int.tryParse(value?.trim() ?? '');
    if (rate == null) return 'Informe uma frequência inteira.';
    if (rate < 50 || rate > 500) {
      return 'Use um valor entre 50 e 500 Hz.';
    }
    return null;
  }

  String? _validateInterval(String? value, CaptureIntervalUnit unit) {
    final interval = int.tryParse(value?.trim() ?? '');
    if (interval == null) return 'Informe um intervalo inteiro.';
    final (minimum, maximum) = switch (unit) {
      CaptureIntervalUnit.minutes => (1, 59),
      CaptureIntervalUnit.hours => (1, 24),
      CaptureIntervalUnit.meters => (1, 9999),
      CaptureIntervalUnit.kilometers => (1, 999),
    };
    if (interval < minimum || interval > maximum) {
      return 'Use um valor entre $minimum e $maximum.';
    }
    return null;
  }

  String? _validateAudioDuration(String? value) {
    final duration = int.tryParse(value?.trim() ?? '');
    if (duration == null) return 'Informe uma duração inteira.';
    if (duration < 1 || duration > _maximumAudioDurationSeconds) {
      return 'Use uma duração entre 1 e '
          '$_maximumAudioDurationSeconds segundos.';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SensorSectionHeading(
          title: 'Sensores complementares',
          subtitle: 'Ative e configure os recursos adicionais da coleta.',
          icon: Icons.tune_rounded,
        ),
        const SizedBox(height: AppDimensions.space12),
        SensorConfigurationCard(
          sensor: SensorColeta.giroscopio,
          title: 'Giroscópio',
          subtitle: 'Taxa de rotação e atitude veicular',
          icon: Icons.screen_rotation_alt_rounded,
          selected: widget.selectedSensors.contains(SensorColeta.giroscopio),
          onChanged: widget.onSensorChanged,
          settings: SensorFrequencySelector(
            keyPrefix: 'gyro',
            minimum: 50,
            maximum: 500,
            title: 'Frequência do giroscópio',
            unit: 'Hz',
            presets: _gyroscopePresets,
            currentValue: widget.settings.gyroscopeFrequencyHz,
            customController: _gyroscopeController,
            onChanged: (rate) => _updateSettings(gyroscopeFrequencyHz: rate),
            validator: _validateGyroscopeFrequency,
            inputHint: 'Ex: 250',
            inputHelper: 'Faixa permitida',
            inputIcon: Icons.screen_rotation_alt_rounded,
          ),
        ),
        const SizedBox(height: AppDimensions.space12),
        SensorConfigurationCard(
          sensor: SensorColeta.camera,
          title: 'Câmera',
          subtitle: 'Fotos ou vídeos de ocorrências na via',
          icon: Icons.photo_camera_outlined,
          selected: widget.selectedSensors.contains(SensorColeta.camera),
          onChanged: widget.onSensorChanged,
          settings: _cameraSettings(),
        ),
        const SizedBox(height: AppDimensions.space12),
        SensorConfigurationCard(
          sensor: SensorColeta.audio,
          title: 'Áudio',
          subtitle: 'Gravação de voz durante a coleta',
          icon: Icons.mic_none_rounded,
          selected: widget.selectedSensors.contains(SensorColeta.audio),
          onChanged: widget.onSensorChanged,
          settings: _audioSettings(),
        ),
      ],
    );
  }

  Widget _cameraSettings() {
    final camera = widget.settings.camera;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Conteúdo', style: context.typography.labelLarge),
        const SizedBox(height: AppDimensions.space8),
        Wrap(
          spacing: AppDimensions.space8,
          children: CameraMediaType.values.map((type) {
            final (label, icon) = switch (type) {
              CameraMediaType.photos => ('Fotos', Icons.photo_outlined),
              CameraMediaType.videos => ('Vídeos', Icons.videocam_outlined),
              CameraMediaType.photosAndVideos => (
                'Fotos e vídeos',
                Icons.perm_media_outlined,
              ),
            };
            final selected = camera.mediaType == type;
            return ChoiceChip(
              key: ValueKey('camera-media-${type.name}'),
              avatar: Icon(icon, size: 18),
              label: Text(label),
              selected: selected,
              selectedColor: context.colors.primary,
              labelStyle: TextStyle(
                color: selected
                    ? context.colors.onPrimary
                    : context.colors.onSurface,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
              onSelected: (_) => _updateSettings(
                camera: CameraCaptureSettings(
                  mediaType: type,
                  facing: camera.facing,
                  automatic: camera.automatic,
                  interval: camera.interval,
                  intervalUnit: camera.intervalUnit,
                  videoDurationSeconds: camera.videoDurationSeconds,
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: AppDimensions.space12),
        Text('Câmera utilizada', style: context.typography.labelLarge),
        const SizedBox(height: AppDimensions.space8),
        Wrap(
          spacing: AppDimensions.space8,
          children: CameraFacing.values.map((facing) {
            final selected = camera.facing == facing;
            final isFront = facing == CameraFacing.front;
            return ChoiceChip(
              key: ValueKey('camera-facing-${facing.name}'),
              avatar: Icon(
                isFront
                    ? Icons.camera_front_outlined
                    : Icons.camera_rear_outlined,
                size: 18,
              ),
              label: Text(isFront ? 'Frontal' : 'Traseira'),
              selected: selected,
              selectedColor: context.colors.primary,
              labelStyle: TextStyle(
                color: selected
                    ? context.colors.onPrimary
                    : context.colors.onSurface,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
              onSelected: (_) => _updateSettings(
                camera: CameraCaptureSettings(
                  mediaType: camera.mediaType,
                  facing: facing,
                  automatic: camera.automatic,
                  interval: camera.interval,
                  intervalUnit: camera.intervalUnit,
                  videoDurationSeconds: camera.videoDurationSeconds,
                ),
              ),
            );
          }).toList(),
        ),
        if (camera.mediaType != CameraMediaType.photos) ...[
          const SizedBox(height: AppDimensions.space12),
          TextFormField(
            key: const ValueKey('video-duration-seconds'),
            initialValue: camera.videoDurationSeconds.toString(),
            autovalidateMode: AutovalidateMode.always,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(
              labelText: 'Duração máxima do vídeo',
              suffixText: 'segundos',
              prefixIcon: Icon(Icons.timer_outlined),
              helperText:
                  'Entre 1 e 120 segundos (2 minutos) para limitar o armazenamento.',
            ),
            validator: (value) {
              final duration = int.tryParse(value?.trim() ?? '');
              if (duration == null || duration < 1) {
                return 'Informe uma duração entre 1 e 120 segundos.';
              }
              if (duration > _maximumVideoDurationSeconds) {
                return 'Máximo seguro: $_maximumVideoDurationSeconds segundos '
                    '(2 minutos).';
              }
              return null;
            },
            onChanged: (value) {
              final duration = int.tryParse(value);
              if (duration != null &&
                  duration > 0 &&
                  duration <= _maximumVideoDurationSeconds) {
                _updateSettings(
                  camera: CameraCaptureSettings(
                    mediaType: camera.mediaType,
                    facing: camera.facing,
                    automatic: camera.automatic,
                    interval: camera.interval,
                    intervalUnit: camera.intervalUnit,
                    videoDurationSeconds: duration,
                  ),
                );
              }
            },
          ),
        ],
        const SizedBox(height: AppDimensions.space8),
        _AutoCaptureSwitch(
          controlKey: const ValueKey('camera-auto-capture'),
          title: 'Captura automática',
          subtitle: 'Opcional • por tempo ou distância percorrida',
          value: camera.automatic,
          onChanged: (automatic) => _updateSettings(
            camera: CameraCaptureSettings(
              mediaType: camera.mediaType,
              facing: camera.facing,
              automatic: automatic,
              interval: camera.interval,
              intervalUnit: camera.intervalUnit,
              videoDurationSeconds: camera.videoDurationSeconds,
            ),
          ),
        ),
        if (camera.automatic)
          _CaptureIntervalEditor(
            key: const ValueKey('camera-capture-interval'),
            controller: _cameraIntervalController,
            unit: camera.intervalUnit,
            onUnitChanged: (unit) {
              _updateSettings(
                camera: CameraCaptureSettings(
                  mediaType: camera.mediaType,
                  facing: camera.facing,
                  automatic: camera.automatic,
                  interval: camera.interval,
                  intervalUnit: unit,
                  videoDurationSeconds: camera.videoDurationSeconds,
                ),
              );
            },
            onValueChanged: (value) => _updateSettings(
              camera: CameraCaptureSettings(
                mediaType: camera.mediaType,
                facing: camera.facing,
                automatic: camera.automatic,
                interval: int.tryParse(value) ?? camera.interval,
                intervalUnit: camera.intervalUnit,
                videoDurationSeconds: camera.videoDurationSeconds,
              ),
            ),
            validator: (value) => _validateInterval(value, camera.intervalUnit),
            keyPrefix: 'camera',
          ),
      ],
    );
  }

  Widget _audioSettings() {
    final audio = widget.settings.audio;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _AutoCaptureSwitch(
          controlKey: const ValueKey('audio-auto-capture'),
          title: 'Gravação automática',
          subtitle: 'Opcional • por tempo ou distância percorrida',
          value: audio.automatic,
          onChanged: (automatic) => _updateSettings(
            audio: AudioCaptureSettings(
              automatic: automatic,
              interval: audio.interval,
              intervalUnit: audio.intervalUnit,
              durationSeconds: audio.durationSeconds,
            ),
          ),
        ),
        if (audio.automatic) ...[
          _CaptureIntervalEditor(
            key: const ValueKey('audio-capture-interval'),
            controller: _audioIntervalController,
            unit: audio.intervalUnit,
            onUnitChanged: (unit) {
              _updateSettings(
                audio: AudioCaptureSettings(
                  automatic: audio.automatic,
                  interval: audio.interval,
                  intervalUnit: unit,
                  durationSeconds: audio.durationSeconds,
                ),
              );
            },
            onValueChanged: (value) => _updateSettings(
              audio: AudioCaptureSettings(
                automatic: audio.automatic,
                interval: int.tryParse(value) ?? audio.interval,
                intervalUnit: audio.intervalUnit,
                durationSeconds: audio.durationSeconds,
              ),
            ),
            validator: (value) => _validateInterval(value, audio.intervalUnit),
            keyPrefix: 'audio',
          ),
          const SizedBox(height: AppDimensions.space12),
          TextFormField(
            key: const ValueKey('audio-capture-duration'),
            controller: _audioDurationController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            autovalidateMode: AutovalidateMode.onUserInteraction,
            decoration: const InputDecoration(
              labelText: 'Duração de cada gravação',
              suffixText: 'segundos',
              prefixIcon: Icon(Icons.timer_outlined),
              helperText:
                  'Entre 1 e 300 segundos para limitar o armazenamento.',
            ),
            validator: _validateAudioDuration,
            onChanged: (value) {
              final duration = int.tryParse(value);
              if (duration != null &&
                  duration > 0 &&
                  duration <= _maximumAudioDurationSeconds) {
                _updateSettings(
                  audio: AudioCaptureSettings(
                    automatic: audio.automatic,
                    interval: audio.interval,
                    intervalUnit: audio.intervalUnit,
                    durationSeconds: duration,
                  ),
                );
              }
            },
          ),
        ],
      ],
    );
  }
}

class _AutoCaptureSwitch extends StatelessWidget {
  final Key controlKey;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _AutoCaptureSwitch({
    required this.controlKey,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppDimensions.space8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: context.typography.titleSmall),
                Text(
                  subtitle,
                  style: context.typography.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(key: controlKey, value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

class _CaptureIntervalEditor extends StatelessWidget {
  final TextEditingController controller;
  final CaptureIntervalUnit unit;
  final ValueChanged<CaptureIntervalUnit> onUnitChanged;
  final ValueChanged<String> onValueChanged;
  final String? Function(String?) validator;
  final String keyPrefix;

  const _CaptureIntervalEditor({
    super.key,
    required this.controller,
    required this.unit,
    required this.onUnitChanged,
    required this.onValueChanged,
    required this.validator,
    required this.keyPrefix,
  });

  String get _unitLabel => switch (unit) {
    CaptureIntervalUnit.minutes => 'minutos',
    CaptureIntervalUnit.hours => 'horas',
    CaptureIntervalUnit.meters => 'metros',
    CaptureIntervalUnit.kilometers => 'quilômetros',
  };

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: TextFormField(
            key: ValueKey('$keyPrefix-capture-interval-value'),
            controller: controller,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            autovalidateMode: AutovalidateMode.onUserInteraction,
            decoration: InputDecoration(
              labelText: 'A cada',
              suffixText: _unitLabel,
            ),
            validator: validator,
            onChanged: onValueChanged,
          ),
        ),
        const SizedBox(width: AppDimensions.space8),
        Expanded(
          child: DropdownButtonFormField<CaptureIntervalUnit>(
            key: ValueKey('$keyPrefix-capture-interval-unit'),
            initialValue: unit,
            decoration: const InputDecoration(labelText: 'Unidade'),
            items: const [
              DropdownMenuItem(
                value: CaptureIntervalUnit.minutes,
                child: Text('Minutos'),
              ),
              DropdownMenuItem(
                value: CaptureIntervalUnit.hours,
                child: Text('Horas'),
              ),
              DropdownMenuItem(
                value: CaptureIntervalUnit.meters,
                child: Text('Metros'),
              ),
              DropdownMenuItem(
                value: CaptureIntervalUnit.kilometers,
                child: Text('Quilômetros'),
              ),
            ],
            onChanged: (value) {
              if (value != null) onUnitChanged(value);
            },
          ),
        ),
      ],
    );
  }
}
