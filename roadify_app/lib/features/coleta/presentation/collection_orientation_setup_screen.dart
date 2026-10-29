import 'dart:async';

import 'package:flutter/material.dart';
import 'package:roadify_app/core/theme/app_colors.dart';
import 'package:roadify_app/core/theme/app_dimensions.dart';
import 'package:roadify_app/core/theme/theme_extensions.dart';
import 'package:roadify_app/features/coleta/viewmodels/coleta_viewmodel.dart';
import 'package:roadify_app/features/coleta/services/collection_preferences.dart';
import 'package:roadify_app/features/sensores/models/nivel_bolha_state.dart';
import 'package:roadify_app/features/sensores/presentation/widgets/bubble_mode_selector.dart';
import 'package:roadify_app/features/sensores/presentation/widgets/circular_bubble_level.dart';
import 'package:roadify_app/features/sensores/presentation/widgets/t_bubble_level.dart';
import 'package:roadify_app/features/sensores/viewmodel/nivel_bolha_viewmodel.dart';

class CollectionOrientationSetupScreen extends StatefulWidget {
  final ConfiguracaoColeta configuracao;
  final CollectionPreferences preferences;

  const CollectionOrientationSetupScreen({
    super.key,
    required this.configuracao,
    required this.preferences,
  });

  @override
  State<CollectionOrientationSetupScreen> createState() =>
      _CollectionOrientationSetupScreenState();
}

class _CollectionOrientationSetupScreenState
    extends State<CollectionOrientationSetupScreen>
    with WidgetsBindingObserver {
  late final NivelBolhaViewModel _viewModel;
  late CollectionOrientation _orientation;
  late CollectionPosture _posture;

  @override
  void initState() {
    super.initState();
    final isWidgetTest = WidgetsBinding.instance.runtimeType
        .toString()
        .contains('Test');
    _viewModel = NivelBolhaViewModel(autoStart: !isWidgetTest)
      ..setMode(widget.configuracao.levelingMode)
      ..restoreCalibration(
        offsetX: widget.configuracao.calibrationOffsetX,
        offsetY: widget.configuracao.calibrationOffsetY,
        isCalibrated: widget.configuracao.isCalibrated,
      );
    _orientation = widget.configuracao.orientation;
    _posture = widget.configuracao.posture;
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    unawaited(_saveSetup());
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _continue() async {
    await _saveSetup();
    if (!mounted) return;
    Navigator.of(context).pop(_currentConfiguration());
  }

  ConfiguracaoColeta _currentConfiguration() {
    final state = _viewModel.state;
    return widget.configuracao.copyWith(
      orientation: _orientation,
      posture: _posture,
      calibrationOffsetX: state.calibOffsetX,
      calibrationOffsetY: state.calibOffsetY,
      levelingMode: state.selectedMode,
      isCalibrated: state.isCalibrated,
    );
  }

  Future<void> _saveSetup() async {
    try {
      await widget.preferences.save(_currentConfiguration());
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

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      unawaited(_saveSetup());
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Orientação e nivelamento'),
        leading: IconButton(
          tooltip: 'Voltar à configuração',
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
      ),
      body: ListenableBuilder(
        listenable: _viewModel,
        builder: (context, _) {
          final state = _viewModel.state;
          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(
                    AppDimensions.space20,
                    AppDimensions.space12,
                    AppDimensions.space20,
                    AppDimensions.space20,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Defina como o dispositivo será posicionado durante a coleta e calibre a referência antes de iniciar.',
                        style: context.typography.bodyMedium?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppDimensions.space16),
                      _selectionCard<CollectionOrientation>(
                        title: 'Orientação do dispositivo',
                        selected: _orientation,
                        options: const {
                          CollectionOrientation.vertical: 'Vertical',
                          CollectionOrientation.horizontal: 'Horizontal',
                        },
                        onChanged: (value) {
                          setState(() => _orientation = value);
                          _saveSetup();
                        },
                      ),
                      const SizedBox(height: AppDimensions.space12),
                      _selectionCard<CollectionPosture>(
                        title: 'Postura registrada',
                        selected: _posture,
                        options: const {
                          CollectionPosture.standing: 'Em pé',
                          CollectionPosture.lyingDown: 'Deitado',
                        },
                        onChanged: (value) {
                          setState(() => _posture = value);
                          _saveSetup();
                        },
                      ),
                      const SizedBox(height: AppDimensions.space16),
                      BubbleModeSelector(
                        currentMode: state.selectedMode,
                        onModeChanged: (mode) {
                          _viewModel.setMode(mode);
                          _saveSetup();
                        },
                      ),
                      const SizedBox(height: AppDimensions.space16),
                      Center(
                        child: state.activeMode == BubbleDisplayMode.circular2D
                            ? CircularBubbleLevel(state: state)
                            : TBubbleLevel(state: state),
                      ),
                      const SizedBox(height: AppDimensions.space16),
                      Row(
                        children: [
                          Expanded(
                            child: _angleCard(
                              'EIXO X (ROLL)',
                              state.calibratedAngleX,
                              state.isLevelX,
                            ),
                          ),
                          const SizedBox(width: AppDimensions.space12),
                          Expanded(
                            child: _angleCard(
                              'EIXO Y (PITCH)',
                              state.calibratedAngleY,
                              state.isLevelY,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppDimensions.space16),
                      Container(
                        padding: const EdgeInsets.all(AppDimensions.space12),
                        decoration: BoxDecoration(
                          color: state.isCalibrated
                              ? colors.primaryContainer.withValues(alpha: 0.4)
                              : colors.surfaceContainerLow,
                          borderRadius: AppDimensions.borderRadiusCard,
                          border: Border.all(color: colors.outlineVariant),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              state.isCalibrated
                                  ? Icons.verified_rounded
                                  : Icons.info_outline_rounded,
                              color: state.isCalibrated
                                  ? AppColors.success
                                  : colors.onSurfaceVariant,
                            ),
                            const SizedBox(width: AppDimensions.space8),
                            Expanded(
                              child: Text(
                                state.isCalibrated
                                    ? 'Referência calibrada. O nivelamento pode ser recalibrado antes de iniciar.'
                                    : 'Posicione o dispositivo no suporte em que será gravado e calibre a referência.',
                                style: context.typography.bodySmall,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppDimensions.space12),
                      OutlinedButton.icon(
                        key: const ValueKey('calibrate-before-recording'),
                        onPressed: () {
                          _viewModel.calibrate();
                          _saveSetup();
                        },
                        icon: const Icon(Icons.center_focus_strong_rounded),
                        label: Text(
                          state.isCalibrated
                              ? 'Recalibrar nível'
                              : 'Calibrar nível',
                        ),
                      ),
                      if (state.isCalibrated)
                        TextButton.icon(
                          onPressed: () {
                            _viewModel.resetCalibration();
                            _saveSetup();
                          },
                          icon: const Icon(Icons.restart_alt_rounded),
                          label: const Text('Remover calibração'),
                        ),
                    ],
                  ),
                ),
              ),
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppDimensions.space20,
                    AppDimensions.space8,
                    AppDimensions.space20,
                    AppDimensions.space12,
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    height: AppDimensions.buttonHeight,
                    child: FilledButton.icon(
                      key: const ValueKey('continue-to-recording'),
                      onPressed: state.isCalibrated ? _continue : null,
                      icon: const Icon(Icons.play_arrow_rounded),
                      label: const Text('Iniciar coleta'),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _selectionCard<T>({
    required String title,
    required T selected,
    required Map<T, String> options,
    required ValueChanged<T> onChanged,
  }) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.all(AppDimensions.space12),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: AppDimensions.borderRadiusCard,
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: context.typography.titleSmall),
          const SizedBox(height: AppDimensions.space8),
          SegmentedButton<T>(
            segments: options.entries
                .map(
                  (entry) => ButtonSegment<T>(
                    value: entry.key,
                    label: Text(entry.value),
                  ),
                )
                .toList(),
            selected: {selected},
            onSelectionChanged: (values) => onChanged(values.first),
          ),
        ],
      ),
    );
  }

  Widget _angleCard(String label, double angle, bool isLevel) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.all(AppDimensions.space12),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: AppDimensions.borderRadiusCard,
        border: Border.all(
          color: isLevel ? AppColors.success : colors.outlineVariant,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: context.typography.labelSmall),
          const SizedBox(height: AppDimensions.space4),
          Text(
            '${angle.toStringAsFixed(1)}°',
            style: context.typography.titleLarge?.copyWith(
              color: isLevel ? AppColors.success : colors.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
