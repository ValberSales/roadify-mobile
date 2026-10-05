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
/// alternância automática por orientação e calibração de tara angular.
class SensoresScreen extends StatefulWidget {
  const SensoresScreen({super.key});

  @override
  State<SensoresScreen> createState() => _SensoresScreenState();
}

class _SensoresScreenState extends State<SensoresScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late final NivelBolhaViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    final isWidgetTest = WidgetsBinding.instance.runtimeType.toString().contains('Test');
    _viewModel = NivelBolhaViewModel(autoStart: !isWidgetTest);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _viewModel.dispose();
    super.dispose();
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
      body: TabBarView(
        controller: _tabController,
        children: [
          // Aba 1: Nível Bolha com arquitetura MVVM
          ListenableBuilder(
            listenable: _viewModel,
            builder: (context, _) {
              final state = _viewModel.state;
              final isDark = context.isDarkMode;

              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  AppDimensions.space20,
                  AppDimensions.space16,
                  AppDimensions.space20,
                  AppDimensions.pillDockHeight + AppDimensions.pillDockMarginBottom + 40,
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
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: (isDark ? colors.surfaceContainerHighest : Colors.grey.shade100)
                            .withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.5)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                state.detectedOrientation == DeviceOrientationMode.horizontal
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
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
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
                            scale: Tween<double>(begin: 0.95, end: 1.0).animate(animation),
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
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: state.isLevel
                            ? AppColors.success.withValues(alpha: 0.1)
                            : colors.surface,
                        borderRadius: AppDimensions.borderRadiusCard,
                        border: Border.all(
                          color: state.isLevel ? AppColors.success : colors.outlineVariant,
                          width: state.isLevel ? 1.5 : 1.0,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            state.isLevel ? Icons.verified_rounded : Icons.info_outline_rounded,
                            color: state.isLevel ? AppColors.success : colors.onSurfaceVariant,
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
                                    color: state.isLevel ? AppColors.success : colors.onSurface,
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
                              content: Text('Nível calibrado e zerado em 0,0°!'),
                              behavior: SnackBarBehavior.floating,
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                        child: const Text(
                          'Calibrar Nível (Zerar Nível)',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          // Aba 2: Sinais ao Vivo (Preservada da Sprint 1)
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              AppDimensions.space20,
              AppDimensions.space20,
              AppDimensions.space20,
              AppDimensions.pillDockHeight + AppDimensions.pillDockMarginBottom + 40,
            ),
            child: Column(
              children: [
                _SensorLiveCard(
                  title: 'Acelerômetro (m/s²)',
                  values: 'X: +0,12 | Y: -0,04 | Z: +9,81',
                  color: colors.primary,
                ),
                const SizedBox(height: AppDimensions.space16),
                _SensorLiveCard(
                  title: 'Giroscópio (rad/s)',
                  values: 'X: 0,8°/s | Y: 1,4°/s | Z: -0,2°/s',
                  color: AppColors.secondary,
                ),
                const SizedBox(height: AppDimensions.space16),
                _SensorLiveCard(
                  title: 'Velocidade GPS',
                  values: 'Atual: 43,2 km/h • Média: 41,8 km/h',
                  color: context.roadQualityColors.boa,
                ),
              ],
            ),
          ),
        ],
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

  const _SensorLiveCard({
    required this.title,
    required this.values,
    required this.color,
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
              Text(title, style: typography.titleMedium),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'AO VIVO',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: color),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.space12),
          Container(
            height: 70,
            width: double.infinity,
            decoration: BoxDecoration(
              color: colors.surfaceContainerHighest.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Icon(Icons.show_chart_rounded, size: 48, color: color.withValues(alpha: 0.6)),
            ),
          ),
          const SizedBox(height: AppDimensions.space8),
          Text(values, style: typography.bodySmall?.copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
