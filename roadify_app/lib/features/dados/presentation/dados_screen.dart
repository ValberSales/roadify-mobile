import 'package:flutter/material.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/theme_extensions.dart';

/// Tela de Dados e Gravações Locais (Feature Dados — Alocada para o Dev 4).
class DadosScreen extends StatelessWidget {
  const DadosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final qualityColors = context.roadQualityColors;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gravações'),
        actions: [
          IconButton(
            icon: const Icon(Icons.cloud_upload_outlined),
            tooltip: 'Sincronizar todas',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Upload em lote iniciado para o servidor.')),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppDimensions.space20,
            AppDimensions.space12,
            AppDimensions.space20,
            AppDimensions.pillDockHeight + AppDimensions.pillDockMarginBottom + 40,
          ),
          children: [
            Text(
              '3 coletas • 143,3 MB no dispositivo',
              style: typography.bodyMedium,
            ),
            const SizedBox(height: AppDimensions.space12),

            // Barra de busca
            SearchBar(
              hintText: 'Buscar por nome, data ou rodovia',
              leading: const Icon(Icons.search_rounded),
              elevation: const WidgetStatePropertyAll(0),
              backgroundColor: WidgetStatePropertyAll(colors.surfaceContainerHighest.withValues(alpha: 0.5)),
            ),

            const SizedBox(height: AppDimensions.space20),

            // Cards de Ensaios
            _RunItemCard(
              title: 'BR-101 • Trecho Norte',
              date: 'Hoje, 09:24',
              metrics: '12,8 km • 48,2 MB • CSV ;',
              isSynced: true,
              qualityColor: qualityColors.boa,
            ),
            const SizedBox(height: AppDimensions.space12),
            _RunItemCard(
              title: 'Av. Paulista • Leste',
              date: '12 set, 16:08',
              metrics: '4,6 km • 21,7 MB • CSV ;',
              isSynced: false,
              qualityColor: qualityColors.media,
            ),
            const SizedBox(height: AppDimensions.space12),
            _RunItemCard(
              title: 'SP-270 • km 34-52',
              date: '10 set, 07:42',
              metrics: '18,1 km • 73,4 MB • CSV ;',
              isSynced: true,
              qualityColor: qualityColors.excelente,
            ),

            const SizedBox(height: AppDimensions.space20),

            // Banner Informativo Verde Claro
            Container(
              padding: const EdgeInsets.all(AppDimensions.space16),
              decoration: BoxDecoration(
                color: qualityColors.boa.withValues(alpha: 0.12),
                borderRadius: AppDimensions.borderRadiusCard,
                border: Border.all(color: qualityColors.boa.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle_outline_rounded, color: qualityColors.boa),
                  const SizedBox(width: AppDimensions.space12),
                  const Expanded(
                    child: Text(
                      'Arquivos salvos localmente com Drift e prontos para sincronização.',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RunItemCard extends StatelessWidget {
  final String title;
  final String date;
  final String metrics;
  final bool isSynced;
  final Color qualityColor;

  const _RunItemCard({
    required this.title,
    required this.date,
    required this.metrics,
    required this.isSynced,
    required this.qualityColor,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;

    return Container(
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
                  style: typography.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              if (isSynced)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: colors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.cloud_done_rounded, size: 14, color: colors.primary),
                      const SizedBox(width: 4),
                      Text('Nuvem', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: colors.primary)),
                    ],
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.cloud_upload_outlined, size: 14, color: Colors.amber),
                      SizedBox(width: 4),
                      Text('Pendente', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.amber)),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(date, style: typography.bodySmall),
          const SizedBox(height: 8),
          Text(metrics, style: typography.bodySmall?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: AppDimensions.space12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.share_outlined, size: 16),
                  label: const Text('Exportar ZIP'),
                  style: OutlinedButton.styleFrom(visualDensity: VisualDensity.compact),
                ),
              ),
              const SizedBox(width: AppDimensions.space8),
              if (!isSynced)
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Upload do ensaio $title iniciado...')),
                      );
                    },
                    icon: const Icon(Icons.cloud_upload_rounded, size: 16),
                    label: const Text('Subir API'),
                    style: FilledButton.styleFrom(visualDensity: VisualDensity.compact),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
