import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:roadify_app/features/coleta/viewmodels/coleta_viewmodel.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/theme_extensions.dart';

class ParametersSectionWidget extends StatefulWidget {
  final Set<SensorColeta> sensoresSelecionados;
  final SensorSelectionChanged onSensorChanged;
  final int taxaAquisicaoHz;
  final ValueChanged<int> onTaxaAquisicaoChanged;
  final TextEditingController frequenciaGpsController;
  final TextEditingController intervaloMetrosController;
  final String? erroSelecaoSensores;

  const ParametersSectionWidget({
    super.key,
    required this.sensoresSelecionados,
    required this.onSensorChanged,
    required this.taxaAquisicaoHz,
    required this.onTaxaAquisicaoChanged,
    required this.frequenciaGpsController,
    required this.intervaloMetrosController,
    this.erroSelecaoSensores,
  });

  @override
  State<ParametersSectionWidget> createState() =>
      _ParametersSectionWidgetState();
}

class _ParametersSectionWidgetState extends State<ParametersSectionWidget> {
  static const List<int> _acelerometroPresets = [100, 200, 300, 400, 500];
  static const List<int> _gpsPresets = [1, 2, 5, 10];

  bool _customAcelerometro = false;
  late final TextEditingController _customAcelerometroController;
  bool _customGps = false;

  @override
  void initState() {
    super.initState();
    _customAcelerometro = !_acelerometroPresets.contains(widget.taxaAquisicaoHz);
    _customAcelerometroController = TextEditingController(
      text: _customAcelerometro ? widget.taxaAquisicaoHz.toString() : '',
    );
    final gpsVal = int.tryParse(widget.frequenciaGpsController.text.trim());
    _customGps = gpsVal != null && !_gpsPresets.contains(gpsVal);
  }

  @override
  void didUpdateWidget(covariant ParametersSectionWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.taxaAquisicaoHz != oldWidget.taxaAquisicaoHz) {
      if (_acelerometroPresets.contains(widget.taxaAquisicaoHz)) {
        _customAcelerometro = false;
      }
    }
  }

  @override
  void dispose() {
    _customAcelerometroController.dispose();
    super.dispose();
  }

  static String? _validateAcelerometroRate(String? value) {
    if (value == null || value.trim().isEmpty) return 'Informe a frequência';
    final rate = int.tryParse(value.trim());
    if (rate == null || rate <= 0) return 'Informe uma frequência positiva';
    if (rate > 1000) return 'Máximo suportado: 1000 Hz';
    return null;
  }

  static String? _validateGpsRate(String? value) {
    if (value == null || value.trim().isEmpty) return 'Informe a frequência';
    final rate = int.tryParse(value.trim());
    if (rate == null || rate <= 0) return 'Informe uma frequência positiva';
    if (rate > 100) return 'Máximo para GNSS: 100 Hz';
    return null;
  }

  static String? _validateInterval(String? value) {
    if (value == null || value.trim().isEmpty) return 'Obrigatório';
    final interval = double.tryParse(value.trim().replaceAll(',', '.'));
    if (interval == null || !interval.isFinite || interval <= 0) {
      return 'Informe uma distância positiva';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final acelerometroAtivo =
        widget.sensoresSelecionados.contains(SensorColeta.acelerometro);
    final gpsAtivo = widget.sensoresSelecionados.contains(SensorColeta.gps);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Sensores da coleta', style: typography.titleMedium),
        const SizedBox(height: AppDimensions.space12),

        // 1. Acelerômetro
        _SensorOption(
          sensor: SensorColeta.acelerometro,
          title: 'Acelerômetro',
          subtitle: 'Obrigatório para análise de irregularidade e vibração',
          icon: Icons.speed_rounded,
          selected: acelerometroAtivo,
          onChanged: widget.onSensorChanged,
        ),
        if (acelerometroAtivo) ...[
          const SizedBox(height: AppDimensions.space8),
          Padding(
            padding: const EdgeInsets.only(left: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Frequência do Acelerômetro',
                      style: typography.labelLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: colors.primary,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: colors.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${widget.taxaAquisicaoHz} Hz',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: colors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.space8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ..._acelerometroPresets.map((hz) {
                      final isSelected =
                          !_customAcelerometro && widget.taxaAquisicaoHz == hz;
                      return ChoiceChip(
                        key: ValueKey('chip-acc-$hz'),
                        label: Text('$hz Hz'),
                        selected: isSelected,
                        selectedColor: colors.primary.withValues(alpha: 0.18),
                        labelStyle: TextStyle(
                          fontWeight:
                              isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected ? colors.primary : colors.onSurface,
                        ),
                        onSelected: (_) {
                          setState(() {
                            _customAcelerometro = false;
                            _customAcelerometroController.text = '';
                          });
                          widget.onTaxaAquisicaoChanged(hz);
                        },
                      );
                    }),
                    ChoiceChip(
                      key: const ValueKey('chip-acc-outro'),
                      avatar: const Icon(Icons.tune_rounded, size: 14),
                      label: const Text('Outro...'),
                      selected: _customAcelerometro,
                      selectedColor: colors.primary.withValues(alpha: 0.18),
                      labelStyle: TextStyle(
                        fontWeight:
                            _customAcelerometro
                                ? FontWeight.w700
                                : FontWeight.w500,
                        color:
                            _customAcelerometro
                                ? colors.primary
                                : colors.onSurface,
                      ),
                      onSelected: (_) {
                        setState(() {
                          _customAcelerometro = true;
                          if (_customAcelerometroController.text.isEmpty) {
                            _customAcelerometroController.text =
                                widget.taxaAquisicaoHz.toString();
                          }
                        });
                      },
                    ),
                  ],
                ),
                if (_customAcelerometro) ...[
                  const SizedBox(height: AppDimensions.space12),
                  TextFormField(
                    key: const ValueKey('input-acc-custom'),
                    controller: _customAcelerometroController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: const InputDecoration(
                      labelText: 'Digitar frequência do acelerômetro',
                      hintText: 'Ex: 250',
                      suffixText: 'Hz',
                      prefixIcon: Icon(Icons.speed_rounded, size: 20),
                      helperText: 'Escala do sensor: 50 a 1000 Hz',
                      isDense: true,
                    ),
                    validator: _validateAcelerometroRate,
                    onChanged: (val) {
                      final parsed = int.tryParse(val.trim());
                      if (parsed != null && parsed > 0) {
                        widget.onTaxaAquisicaoChanged(parsed);
                      }
                    },
                  ),
                ],
              ],
            ),
          ),
        ],

        const Divider(height: AppDimensions.space16),

        // 2. Giroscópio (apenas ativação, sem seletor de frequência)
        _SensorOption(
          sensor: SensorColeta.giroscopio,
          title: 'Giroscópio',
          subtitle: 'Opcional • taxa de rotação e atitude veicular',
          icon: Icons.screen_rotation_alt_rounded,
          selected: widget.sensoresSelecionados.contains(
            SensorColeta.giroscopio,
          ),
          onChanged: widget.onSensorChanged,
        ),

        const Divider(height: AppDimensions.space16),

        // 3. GPS (com botões pre-configurados de 1, 2, 5, 10 Hz e Outro)
        _SensorOption(
          sensor: SensorColeta.gps,
          title: 'GPS',
          subtitle: 'Obrigatório para geolocalização e traçado de pista',
          icon: Icons.satellite_alt_rounded,
          selected: gpsAtivo,
          onChanged: widget.onSensorChanged,
        ),
        if (gpsAtivo) ...[
          const SizedBox(height: AppDimensions.space8),
          Padding(
            padding: const EdgeInsets.only(left: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Frequência do GPS',
                      style: typography.labelLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: colors.primary,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: colors.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${widget.frequenciaGpsController.text.isEmpty ? '?' : widget.frequenciaGpsController.text} Hz',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: colors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.space8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ..._gpsPresets.map((hz) {
                      final currentGps = int.tryParse(
                        widget.frequenciaGpsController.text.trim(),
                      );
                      final isSelected = !_customGps && currentGps == hz;
                      return ChoiceChip(
                        key: ValueKey('chip-gps-$hz'),
                        label: Text('$hz Hz'),
                        selected: isSelected,
                        selectedColor: colors.primary.withValues(alpha: 0.18),
                        labelStyle: TextStyle(
                          fontWeight:
                              isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected ? colors.primary : colors.onSurface,
                        ),
                        onSelected: (_) {
                          setState(() {
                            _customGps = false;
                            widget.frequenciaGpsController.text = hz.toString();
                          });
                        },
                      );
                    }),
                    ChoiceChip(
                      key: const ValueKey('chip-gps-outro'),
                      avatar: const Icon(Icons.tune_rounded, size: 14),
                      label: const Text('Outro...'),
                      selected: _customGps,
                      selectedColor: colors.primary.withValues(alpha: 0.18),
                      labelStyle: TextStyle(
                        fontWeight:
                            _customGps ? FontWeight.w700 : FontWeight.w500,
                        color: _customGps ? colors.primary : colors.onSurface,
                      ),
                      onSelected: (_) {
                        setState(() {
                          _customGps = true;
                        });
                      },
                    ),
                  ],
                ),
                if (_customGps) ...[
                  const SizedBox(height: AppDimensions.space12),
                  TextFormField(
                    key: const ValueKey('input-gps-custom'),
                    controller: widget.frequenciaGpsController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: const InputDecoration(
                      labelText: 'Digitar frequência do GPS',
                      hintText: 'Ex: 20',
                      suffixText: 'Hz',
                      prefixIcon: Icon(Icons.satellite_outlined, size: 20),
                      helperText:
                          'Escala GNSS: 1 Hz (padrão celular) até 20 Hz (RTK/alta precisão)',
                      isDense: true,
                    ),
                    validator: _validateGpsRate,
                    onChanged: (val) {
                      setState(() {});
                    },
                  ),
                ],
              ],
            ),
          ),
        ],

        const Divider(height: AppDimensions.space16),

        // 4. Câmera
        _SensorOption(
          sensor: SensorColeta.camera,
          title: 'Câmera',
          subtitle: 'Opcional • fotos de patologias e ocorrências na via',
          icon: Icons.photo_camera_outlined,
          selected: widget.sensoresSelecionados.contains(SensorColeta.camera),
          onChanged: widget.onSensorChanged,
        ),

        const Divider(height: AppDimensions.space16),

        // 5. Áudio
        _SensorOption(
          sensor: SensorColeta.audio,
          title: 'Áudio',
          subtitle: 'Opcional • notas de voz durante o ensaio',
          icon: Icons.mic_none_rounded,
          selected: widget.sensoresSelecionados.contains(SensorColeta.audio),
          onChanged: widget.onSensorChanged,
        ),

        if (widget.erroSelecaoSensores != null) ...[
          const SizedBox(height: AppDimensions.space8),
          Text(
            widget.erroSelecaoSensores!,
            style: TextStyle(color: colors.error),
          ),
        ],

        const SizedBox(height: AppDimensions.space24),
        Text('Parâmetros de aquisição', style: typography.titleMedium),
        const SizedBox(height: AppDimensions.space12),
        TextFormField(
          controller: widget.intervaloMetrosController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))],
          decoration: const InputDecoration(
            labelText: 'Gravar trecho a cada',
            suffixText: 'metros',
            prefixIcon: Icon(Icons.straighten_rounded),
          ),
          validator: _validateInterval,
        ),
      ],
    );
  }
}

typedef SensorSelectionChanged =
    void Function(SensorColeta sensor, bool selected);

class _SensorOption extends StatelessWidget {
  final SensorColeta sensor;
  final String title;
  final String subtitle;
  final IconData icon;
  final bool selected;
  final SensorSelectionChanged onChanged;

  const _SensorOption({
    required this.sensor,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: context.colors.primary),
        const SizedBox(width: AppDimensions.space12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: context.typography.titleSmall),
              Text(subtitle, style: context.typography.bodySmall),
            ],
          ),
        ),
        Checkbox(
          key: ValueKey('sensor-${sensor.name}-checkbox'),
          value: selected,
          onChanged: (value) => onChanged(sensor, value ?? false),
        ),
      ],
    );
  }
}
