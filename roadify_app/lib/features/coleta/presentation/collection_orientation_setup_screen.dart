import 'package:roadify_app/l10n/app_localizations_catalog.dart';
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
            content: Text(
              AppLocalizations.of(context)
                  .text('savePreferencesError')
                  .replaceAll('{error}', '$error'),
            ),
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
        title: Text(AppLocalizations.of(context).text('collectionOrientation')),
        leading: IconButton(
          tooltip: AppLocalizations.of(context).text('backToSettings'),
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
                        AppLocalizations.of(context)
                            .text('orientationSetupDescription'),
                        style: context.typography.bodyMedium?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppDimensions.space16),
                      _selectionCard<CollectionOrientation>(
                        title: AppLocalizations.of(context)
                            .text('deviceOrientationTitle'),
                        selected: _orientation,
                        options: {
                          CollectionOrientation.vertical:
                              AppLocalizations.of(context)
                                  .text('verticalOrientation'),
                          CollectionOrientation.horizontal:
                              AppLocalizations.of(context)
                                  .text('horizontalOrientation'),
                        },
                        onChanged: (value) {
                          setState(() => _orientation = value);
                          _saveSetup();
                        },
                      ),
                      const SizedBox(height: AppDimensions.space12),
                      _selectionCard<CollectionPosture>(
                        title: AppLocalizations.of(context)
                            .text('recordedPostureTitle'),
                        selected: _posture,
                        options: {
                          CollectionPosture.standing:
                              AppLocalizations.of(context)
                                  .text('standingPosture'),
                          CollectionPosture.lyingDown:
                              AppLocalizations.of(context)
                                  .text('lyingDownPosture'),
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
                              AppLocalizations.of(context).text('axisXRoll'),
                              state.calibratedAngleX,
                              state.isLevelX,
                            ),
                          ),
                          const SizedBox(width: AppDimensions.space12),
                          Expanded(
                            child: _angleCard(
                              AppLocalizations.of(context).text('axisYPitch'),
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
                                    ? AppLocalizations.of(context)
                                          .text('referenceCalibratedMsg')
                                    : AppLocalizations.of(context)
                                          .text('positionDeviceInMountMsg'),
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
                              ? AppLocalizations.of(context).text('recalibrateLevel')
                              : AppLocalizations.of(context).text('calibrateLevel'),
                        ),
                      ),
                      if (state.isCalibrated)
                        TextButton.icon(
                          onPressed: () {
                            _viewModel.resetCalibration();
                            _saveSetup();
                          },
                          icon: const Icon(Icons.restart_alt_rounded),
                          label: Text(AppLocalizations.of(context).text('removeCalibration')),
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
                      label: Text(AppLocalizations.of(context).text('startCollection')),
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
