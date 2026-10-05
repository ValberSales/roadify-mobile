import 'package:flutter/material.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/theme_extensions.dart';

enum _SortOption {
  data('Data de criação', Icons.calendar_today_outlined),
  quilometragem('Quilometragem', Icons.route_outlined),
  alfabetica('Ordem alfabética', Icons.sort_by_alpha_rounded),
  tamanho('Tamanho do arquivo', Icons.sd_storage_outlined);

  const _SortOption(this.label, this.icon);
  final String label;
  final IconData icon;
}

String _fmt(double value) => value.toStringAsFixed(1).replaceAll('.', ',');

String _normalize(String input) {
  const from = 'áàâãäéèêëíìîïóòôõöúùûüçñ';
  const to = 'aaaaaeeeeiiiiooooouuuucn';
  var out = input.toLowerCase();
  for (var i = 0; i < from.length; i++) {
    out = out.replaceAll(from[i], to[i]);
  }
  return out;
}

class _Run {
  final String title;
  final String dateLabel;
  final DateTime createdAt;
  final double km;
  final double sizeMb;
  final bool isSynced;
  final Color qualityColor;

  const _Run({
    required this.title,
    required this.dateLabel,
    required this.createdAt,
    required this.km,
    required this.sizeMb,
    required this.isSynced,
    required this.qualityColor,
  });

  String get metrics => '${_fmt(km)} km • ${_fmt(sizeMb)} MB • CSV';
}

class DadosScreen extends StatefulWidget {
  const DadosScreen({super.key});

  @override
  State<DadosScreen> createState() => _DadosScreenState();
}

class _DadosScreenState extends State<DadosScreen> {
  bool? _syncFilter;
  _SortOption _sort = _SortOption.data;
  String _searchQuery = '';

  void _toggleSyncFilter(bool value) {
    setState(() => _syncFilter = _syncFilter == value ? null : value);
  }

  List<_Run> _applyFilterAndSort(List<_Run> source) {
    final normalizedQuery = _normalize(_searchQuery.trim());

    final list = source.where((r) {
      final matchesSync = _syncFilter == null || r.isSynced == _syncFilter;
      if (!matchesSync) return false;

      if (normalizedQuery.isEmpty) return true;

      final titleNormalized = _normalize(r.title);
      final dateNormalized = _normalize(r.dateLabel);

      return titleNormalized.contains(normalizedQuery) ||
          dateNormalized.contains(normalizedQuery);
    }).toList();

    // Ordenação
    switch (_sort) {
      case _SortOption.data:
        list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      case _SortOption.quilometragem:
        list.sort((a, b) => b.km.compareTo(a.km));
      case _SortOption.alfabetica:
        list.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
      case _SortOption.tamanho:
        list.sort((a, b) => b.sizeMb.compareTo(a.sizeMb));
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final qualityColors = context.roadQualityColors;

    final allRuns = <_Run>[
      _Run(
        title: 'BR-101 • Trecho Norte',
        dateLabel: 'Hoje, 09:24',
        createdAt: DateTime(2025, 9, 14, 9, 24),
        km: 12.8,
        sizeMb: 48.2,
        isSynced: true,
        qualityColor: qualityColors.boa,
      ),
      _Run(
        title: 'Av. Paulista • Leste',
        dateLabel: '12 set, 16:08',
        createdAt: DateTime(2025, 9, 12, 16, 8),
        km: 4.6,
        sizeMb: 21.7,
        isSynced: false,
        qualityColor: qualityColors.media,
      ),
      _Run(
        title: 'SP-270 • km 34-52',
        dateLabel: '10 set, 07:42',
        createdAt: DateTime(2025, 9, 10, 7, 42),
        km: 18.1,
        sizeMb: 73.4,
        isSynced: true,
        qualityColor: qualityColors.excelente,
      ),
    ];

    final totalMb = allRuns.fold<double>(0, (sum, r) => sum + r.sizeMb);
    final visibleRuns = _applyFilterAndSort(allRuns);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gravações'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppDimensions.space8),
            child: IconButton.filled(
              icon: const Icon(Icons.cloud_upload_outlined),
              tooltip: 'Sincronizar todas',
              style: IconButton.styleFrom(
                backgroundColor: colors.primary,
                foregroundColor: colors.onPrimary,
              ),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Upload em lote iniciado para o servidor.')),
                );
              },
            ),
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
              '${allRuns.length} coletas • ${_fmt(totalMb)} MB no dispositivo',
              style: typography.bodyMedium,
            ),
            const SizedBox(height: AppDimensions.space12),

            // Barra de busca
            SearchBar(
              hintText: 'Buscar por nome, data ou rodovia',
              leading: const Icon(Icons.search_rounded),
              elevation: const WidgetStatePropertyAll(0),
              backgroundColor: WidgetStatePropertyAll(colors.surfaceContainerHighest.withValues(alpha: 0.5)),
              onChanged: (value) {
                setState(() => _searchQuery = value);
              },
              trailing: _searchQuery.isNotEmpty
                  ? [
                IconButton(
                  icon: const Icon(Icons.clear_rounded),
                  onPressed: () {
                    setState(() => _searchQuery = '');
                  },
                ),
              ]
                  : null,
            ),

            const SizedBox(height: AppDimensions.space12),

            Row(
              children: [
                FilterChip(
                  avatar: Icon(Icons.cloud_done_rounded, size: 16, color: colors.primary),
                  label: const Text('Nuvem'),
                  selected: _syncFilter == true,
                  showCheckmark: false,
                  onSelected: (_) => _toggleSyncFilter(true),
                ),
                const SizedBox(width: AppDimensions.space8),
                FilterChip(
                  avatar: const Icon(Icons.cloud_upload_outlined, size: 16, color: Colors.amber),
                  label: const Text('Pendente'),
                  selected: _syncFilter == false,
                  showCheckmark: false,
                  onSelected: (_) => _toggleSyncFilter(false),
                ),
                const Spacer(),
                MenuAnchor(
                  menuChildren: [
                    for (final option in _SortOption.values)
                      MenuItemButton(
                        leadingIcon: Icon(option.icon),
                        trailingIcon: option == _sort
                            ? Icon(Icons.check_rounded, color: colors.primary)
                            : null,
                        onPressed: () => setState(() => _sort = option),
                        child: Text(option.label),
                      ),
                  ],
                  builder: (context, controller, _) {
                    return OutlinedButton.icon(
                      onPressed: () =>
                      controller.isOpen ? controller.close() : controller.open(),
                      icon: const Icon(Icons.swap_vert_rounded, size: 18),
                      label: const Text('Ordenar'),
                      style: OutlinedButton.styleFrom(visualDensity: VisualDensity.compact),
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: AppDimensions.space20),

            // Cards de Ensaios
            if (visibleRuns.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppDimensions.space20),
                child: Center(
                  child: Text('Nenhuma coleta encontrada.', style: typography.bodyMedium),
                ),
              )
            else
              for (var i = 0; i < visibleRuns.length; i++) ...[
                if (i > 0) const SizedBox(height: AppDimensions.space12),
                _RunItemCard(run: visibleRuns[i]),
              ],

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
  final _Run run;

  const _RunItemCard({required this.run});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final isSynced = run.isSynced;

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
                  run.title,
                  style: typography.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              Tooltip(
                message: isSynced ? 'Nuvem' : 'Pendente',
                triggerMode: TooltipTriggerMode.tap,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: isSynced
                        ? colors.primary.withValues(alpha: 0.1)
                        : Colors.amber.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    isSynced ? Icons.cloud_done_rounded : Icons.cloud_upload_outlined,
                    size: 18,
                    color: isSynced ? colors.primary : Colors.amber,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(run.dateLabel, style: typography.bodySmall),
          const SizedBox(height: 8),
          Text(run.metrics, style: typography.bodySmall?.copyWith(fontWeight: FontWeight.w600)),
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
                        SnackBar(content: Text('Upload do ensaio ${run.title} iniciado...')),
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