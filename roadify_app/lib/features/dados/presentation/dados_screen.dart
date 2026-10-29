import 'package:flutter/material.dart';
import 'package:roadify_app/core/database/daos/run_dao.dart';
import 'package:roadify_app/core/di/setup_locator.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/theme_extensions.dart';
import '../../../core/utils/snackbar_helper.dart';
import '../services/run_export_service.dart';
import '../viewmodel/dados_viewmodel.dart';

enum _SortOption {
  data('Data de criação', Icons.calendar_today_outlined),
  quilometragem('Quilometragem', Icons.route_outlined),
  alfabetica('Ordem alfabética', Icons.sort_by_alpha_rounded),
  tamanho('Tamanho do arquivo', Icons.sd_storage_outlined);

  const _SortOption(this.label, this.icon);
  final String label;
  final IconData icon;
}

String _normalize(String input) {
  const from = 'áàâãäéèêëíìîïóòôõöúùûüçñ';
  const to = 'aaaaaeeeeiiiiooooouuuucn';
  var out = input.toLowerCase();
  for (var i = 0; i < from.length; i++) {
    out = out.replaceAll(from[i], to[i]);
  }
  return out;
}

class DadosScreen extends StatefulWidget {
  final DadosViewModel? viewModel;

  const DadosScreen({super.key, this.viewModel});

  @override
  State<DadosScreen> createState() => _DadosScreenState();
}

class _DadosScreenState extends State<DadosScreen> {
  late final DadosViewModel _viewModel;
  late final bool _ownsViewModel;
  bool? _syncFilter;
  _SortOption _sort = _SortOption.data;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _ownsViewModel = widget.viewModel == null;
    _viewModel = widget.viewModel ?? DadosViewModel(getIt<RunDao>(), getIt<RunExportService>());
  }

  @override
  void dispose() {
    if (_ownsViewModel) _viewModel.dispose();
    super.dispose();
  }

  Future<void> _exportRun(RunListItem run) async {
    try {
      final savedPath = await _viewModel.exportRun(run.id);
      if (!mounted || savedPath == null) return; // null = usuário cancelou
      SnackbarHelper.showSuccess(context, message: 'ZIP de "${run.title}" salvo no dispositivo.');
    } catch (e) {
      if (!mounted) return;
      SnackbarHelper.showError(context, message: 'Falha ao exportar a coleta: $e');
    }
  }

  void _toggleSyncFilter(bool value) {
    setState(() => _syncFilter = _syncFilter == value ? null : value);
  }

  List<RunListItem> _applyFilterAndSort(List<RunListItem> source) {
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gravações'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppDimensions.space8),
            // child: IconButton.filled(
            //   icon: const Icon(Icons.cloud_upload_outlined),
            //   //tooltip: 'Sincronizar todas',
            //   style: IconButton.styleFrom(
            //     backgroundColor: colors.primary,
            //     foregroundColor: colors.onPrimary,
            //   ),
            //   onPressed: () {
            //     //ScaffoldMessenger.of(context).showSnackBar(
            //       //const SnackBar(content: Text('Upload em lote iniciado para o servidor.')),
            //     //);
            //   },
            // ),
          ),
        ],
      ),
      body: SafeArea(
        bottom: false,
        child: ListenableBuilder(
          listenable: _viewModel,
          builder: (context, _) => _buildBody(context),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final qualityColors = context.roadQualityColors;

    if (_viewModel.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_viewModel.error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.space20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline_rounded, size: 48, color: colors.error),
              const SizedBox(height: AppDimensions.space12),
              Text('Não foi possível carregar as gravações.',
                  style: typography.bodyMedium, textAlign: TextAlign.center),
              const SizedBox(height: AppDimensions.space12),
              OutlinedButton(onPressed: _viewModel.retry, child: const Text('Tentar novamente')),
            ],
          ),
        ),
      );
    }

    final allRuns = _viewModel.items;
    final visibleRuns = _applyFilterAndSort(allRuns);

    return RefreshIndicator(
      onRefresh: _viewModel.refresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          AppDimensions.space20,
          AppDimensions.space12,
          AppDimensions.space20,
          AppDimensions.pillDockHeight + AppDimensions.pillDockMarginBottom + 40,
        ),
        children: [
          Text(
            '${allRuns.length} coletas • ${formatDecimal(_viewModel.totalMb)} MB no dispositivo',
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
              // FilterChip(
              //   avatar: Icon(Icons.cloud_done_rounded, size: 16, color: colors.primary),
              //   label: const Text('Nuvem'),
              //   selected: _syncFilter == true,
              //   showCheckmark: false,
              //   onSelected: (_) => _toggleSyncFilter(true),
              // ),
              // const SizedBox(width: AppDimensions.space8),
              // FilterChip(
              //   avatar: const Icon(Icons.cloud_upload_outlined, size: 16, color: Colors.amber),
              //   label: const Text('Pendente'),
              //   selected: _syncFilter == false,
              //   showCheckmark: false,
              //   onSelected: (_) => _toggleSyncFilter(false),
              // ),
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
                child: Text(
                  allRuns.isEmpty
                      ? 'Nenhuma coleta gravada ainda. Inicie uma na aba Coleta.'
                      : 'Nenhuma coleta encontrada.',
                  style: typography.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ),
            )
          else
            for (var i = 0; i < visibleRuns.length; i++) ...[
              if (i > 0) const SizedBox(height: AppDimensions.space12),
              _RunItemCard(
                run: visibleRuns[i],
                isExporting: _viewModel.isExporting(visibleRuns[i].id),
                exportProgress: _viewModel.exportProgress(visibleRuns[i].id),
                onExport: () => _exportRun(visibleRuns[i]),
              ),
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
                    'Coletas salvas localmente e prontas para sincronização.',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RunItemCard extends StatelessWidget {
  final RunListItem run;
  final bool isExporting;
  final double? exportProgress;
  final VoidCallback onExport;

  const _RunItemCard({
    required this.run,
    required this.isExporting,
    required this.exportProgress,
    required this.onExport,
  });

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
              // Tooltip(
              //   message: isSynced ? 'Nuvem' : 'Pendente',
              //   triggerMode: TooltipTriggerMode.tap,
              //   child: Container(
              //     padding: const EdgeInsets.all(6),
              //     decoration: BoxDecoration(
              //       color: isSynced
              //           ? colors.primary.withValues(alpha: 0.1)
              //           : Colors.amber.withValues(alpha: 0.15),
              //       borderRadius: BorderRadius.circular(8),
              //     ),
              //     child: Icon(
              //       isSynced ? Icons.cloud_done_rounded : Icons.cloud_upload_outlined,
              //       size: 18,
              //       color: isSynced ? colors.primary : Colors.amber,
              //     ),
              //   ),
              // ),
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
                  onPressed: isExporting ? null : onExport,
                  icon: isExporting
                      ? SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2, value: exportProgress),
                  )
                      : const Icon(Icons.download_rounded, size: 16),
                  label: Text(
                    isExporting
                        ? 'Exportando ${((exportProgress ?? 0) * 100).round()}%'
                        : 'Exportar ZIP',
                  ),
                  style: OutlinedButton.styleFrom(visualDensity: VisualDensity.compact),
                ),
              ),
              const SizedBox(width: AppDimensions.space8),
              // if (!isSynced)
              //   Expanded(
              //     child: FilledButton.icon(
              //       onPressed: () {
              //         ScaffoldMessenger.of(context).showSnackBar(
              //           SnackBar(content: Text('Upload do ensaio ${run.title} iniciado...')),
              //         );
              //       },
              //       icon: const Icon(Icons.cloud_upload_rounded, size: 16),
              //       label: const Text('Subir API'),
              //       style: FilledButton.styleFrom(visualDensity: VisualDensity.compact),
              //     ),
              //   ),
            ],
          ),
        ],
      ),
    );
  }
}