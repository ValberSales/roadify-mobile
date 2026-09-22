import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/theme_extensions.dart';

/// Tela de Sensores & Nível Bolha (Feature Sensores — Alocada para o Dev 3).
class SensoresScreen extends StatefulWidget {
  const SensoresScreen({super.key});

  @override
  State<SensoresScreen> createState() => _SensoresScreenState();
}

class _SensoresScreenState extends State<SensoresScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
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
          // Aba 1: Nível Bolha
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              AppDimensions.space20,
              AppDimensions.space20,
              AppDimensions.space20,
              AppDimensions.pillDockHeight + AppDimensions.pillDockMarginBottom + 40,
            ),
            child: Column(
              children: [
                Text(
                  'Posicione o smartphone no suporte veicular e calibre o alinhamento.',
                  style: typography.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppDimensions.space24),
                // Mira do Nível Bolha
                Center(
                  child: Container(
                    width: 240,
                    height: 240,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: context.isDarkMode ? const Color(0xFF0F261F) : const Color(0xFFE8F5E9),
                      border: Border.all(color: AppColors.primary, width: 2),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Círculos concêntricos
                        Container(
                          width: 160,
                          height: 160,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.primary.withValues(alpha: 0.4), width: 1.2),
                          ),
                        ),
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.primary.withValues(alpha: 0.6), width: 1.2),
                          ),
                        ),
                        // Cruz de mira
                        Divider(color: AppColors.primary.withValues(alpha: 0.3), thickness: 1),
                        VerticalDivider(color: AppColors.primary.withValues(alpha: 0.3), thickness: 1),
                        // Bolha fluida verde limão
                        Container(
                          width: 38,
                          height: 38,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.limeAccent,
                            boxShadow: [
                              BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 3)),
                            ],
                          ),
                        ),
                        // Leitura angular central
                        const Positioned(
                          bottom: 24,
                          child: Text(
                            '0,4°',
                            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppDimensions.space24),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(AppDimensions.space12),
                        decoration: BoxDecoration(
                          color: colors.surface,
                          borderRadius: AppDimensions.borderRadiusCard,
                          border: Border.all(color: colors.outlineVariant),
                        ),
                        child: Column(
                          children: [
                            Text('EIXO X', style: typography.labelMedium),
                            const Text('-0,2°', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: AppDimensions.space12),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(AppDimensions.space12),
                        decoration: BoxDecoration(
                          color: colors.surface,
                          borderRadius: AppDimensions.borderRadiusCard,
                          border: Border.all(color: colors.outlineVariant),
                        ),
                        child: Column(
                          children: [
                            Text('EIXO Y', style: typography.labelMedium),
                            const Text('+0,4°', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.space20),
                SizedBox(
                  width: double.infinity,
                  height: AppDimensions.buttonHeight,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Tara realizada! Referência angular zerada.')),
                      );
                    },
                    icon: const Icon(Icons.filter_center_focus_rounded),
                    label: const Text('Calibrar Nível (Zerar Tara)'),
                  ),
                ),
              ],
            ),
          ),

          // Aba 2: Sinais ao Vivo
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
