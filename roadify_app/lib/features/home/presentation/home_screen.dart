import 'package:flutter/material.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/theme_controller.dart';
import '../../../core/theme/theme_extensions.dart';

/// Tela Inicial (Home) do Roadify Mobile.
///
/// Exibe um overview executivo: status de sincronização em nuvem,
/// diagnóstico do armazenamento interno e atalho rápido para Nova Coleta.
class HomeScreen extends StatelessWidget {
  final ThemeController themeController;
  final VoidCallback onStartCollection;

  const HomeScreen({
    super.key,
    required this.themeController,
    required this.onStartCollection,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final qualityColors = context.roadQualityColors;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppDimensions.space20,
            AppDimensions.space16,
            AppDimensions.space20,
            AppDimensions.pillDockHeight + AppDimensions.pillDockMarginBottom + 40,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Topo: Logotipo e Alternância Rápida de Tema ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(AppDimensions.space8),
                            decoration: BoxDecoration(
                              color: colors.primary,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.alt_route_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: AppDimensions.space12),
                          Text(
                            'Roadify',
                            style: typography.headlineMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: colors.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppDimensions.space4),
                      Text(
                        'Coletor de Dados de Pavimento',
                        style: typography.bodySmall,
                      ),
                    ],
                  ),
                  // Botão de alternar tema (Claro / Escuro)
                  IconButton.filledTonal(
                    tooltip: 'Alternar Tema Claro / Escuro',
                    onPressed: () => themeController.toggleTheme(),
                    icon: Icon(
                      context.isDarkMode ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                      color: colors.primary,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppDimensions.space24),

              // --- Card Principal de Ação: Nova Coleta ---
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppDimensions.space20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: context.isDarkMode
                        ? [const Color(0xFF13362B), const Color(0xFF0F261F)]
                        : [colors.primary, const Color(0xFF1B5E45)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: AppDimensions.borderRadiusCard,
                  boxShadow: [
                    BoxShadow(
                      color: colors.primary.withValues(alpha: 0.25),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppDimensions.space8,
                            vertical: AppDimensions.space4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'VEÍCULO: TOYOTA HILUX (ABC-1234)',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimensions.space12),
                    const Text(
                      'Iniciar Nova Vistoria',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.space4),
                    Text(
                      'Calibre os sensores com o nível bolha antes de rodar.',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.space16),
                    SizedBox(
                      width: double.infinity,
                      height: AppDimensions.buttonHeight,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colors.surface,
                          foregroundColor: colors.primary,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: AppDimensions.borderRadiusMedium,
                          ),
                        ),
                        onPressed: onStartCollection,
                        icon: const Icon(Icons.play_arrow_rounded, size: 22),
                        label: const Text(
                          'Iniciar Coleta em Pista',
                          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppDimensions.space20),

              // --- Card de Status de Sincronização em Nuvem ---
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppDimensions.space16),
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: AppDimensions.borderRadiusCard,
                  border: Border.all(color: colors.outlineVariant, width: 1.2),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppDimensions.space12),
                      decoration: BoxDecoration(
                        color: qualityColors.boa.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.cloud_done_rounded,
                        color: qualityColors.boa,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: AppDimensions.space16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Sincronização em Nuvem',
                            style: typography.titleMedium,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '3 ensaios sincronizados • 1 pendente',
                            style: typography.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    FilledButton.tonal(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Sincronização iniciada via API RESTful...')),
                        );
                      },
                      style: FilledButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                      ),
                      child: const Text('Subir'),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppDimensions.space16),

              // --- Card de Diagnóstico do Armazenamento Interno ---
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppDimensions.space16),
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: AppDimensions.borderRadiusCard,
                  border: Border.all(color: colors.outlineVariant, width: 1.2),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.storage_rounded, size: 20, color: colors.primary),
                            const SizedBox(width: AppDimensions.space8),
                            Text('Armazenamento do Aparelho', style: typography.titleMedium),
                          ],
                        ),
                        Text(
                          '143,3 MB usados',
                          style: typography.labelMedium?.copyWith(
                            color: colors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimensions.space12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: 0.18,
                        minHeight: 8,
                        backgroundColor: colors.surfaceContainerHighest,
                        color: colors.primary,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.space8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('4 coletas armazenadas', style: typography.bodySmall),
                        Text('42 GB disponíveis', style: typography.bodySmall),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppDimensions.space20),

              // --- Mostruário de Cores da Escala de Pavimento (Referência para o time) ---
              Text('Escala de Qualidade do Pavimento', style: typography.titleMedium),
              const SizedBox(height: AppDimensions.space8),
              Row(
                children: [
                  _QualityBadge(label: 'Excelente', color: qualityColors.excelente),
                  const SizedBox(width: 6),
                  _QualityBadge(label: 'Boa', color: qualityColors.boa),
                  const SizedBox(width: 6),
                  _QualityBadge(label: 'Média', color: qualityColors.media),
                  const SizedBox(width: 6),
                  _QualityBadge(label: 'Ruim', color: qualityColors.ruim),
                  const SizedBox(width: 6),
                  _QualityBadge(label: 'Muito Ruim', color: qualityColors.muitoRuim),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QualityBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _QualityBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color, width: 1.2),
        ),
        child: Column(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: color),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
