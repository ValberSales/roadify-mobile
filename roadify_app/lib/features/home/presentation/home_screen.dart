import 'package:flutter/material.dart';
import '../../../core/database/app_database.dart';
import '../../../core/database/daos/run_dao.dart';
import '../../../core/di/setup_locator.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/theme_controller.dart';
import '../../../core/theme/theme_extensions.dart';

/// Modelo de apresentação para coletas na HomeScreen (utilizado tanto com Drift quanto com dados demo).
class _HomeRunItem {
  final int? id;
  final String title;
  final String dateLabel;
  final String metrics;
  final bool isSynced;

  const _HomeRunItem({
    this.id,
    required this.title,
    required this.dateLabel,
    required this.metrics,
    required this.isSynced,
  });

  _HomeRunItem copyWith({bool? isSynced}) {
    return _HomeRunItem(
      id: id,
      title: title,
      dateLabel: dateLabel,
      metrics: metrics,
      isSynced: isSynced ?? this.isSynced,
    );
  }
}

/// Tela Inicial (Home) do Roadify Mobile.
///
/// Exibe um overview executivo:
/// 1. Atalho rápido para Nova Coleta em Pista.
/// 2. Diagnóstico do armazenamento interno do aparelho.
/// 3. Cards das últimas coletas com botão/ícone de sincronização em nuvem no canto superior direito.
class HomeScreen extends StatefulWidget {
  final ThemeController themeController;
  final VoidCallback onStartCollection;
  final RunDao? runDao;

  const HomeScreen({
    super.key,
    required this.themeController,
    required this.onStartCollection,
    this.runDao,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  RunDao? get _dao => widget.runDao ?? (getIt.isRegistered<RunDao>() ? getIt<RunDao>() : null);

  // Coletas de demonstração exibidas quando o banco ainda não possuir registros gravados
  late List<_HomeRunItem> _demoRuns;

  @override
  void initState() {
    super.initState();
    _demoRuns = [
      const _HomeRunItem(
        id: -1,
        title: 'BR-101 • Trecho Norte',
        dateLabel: 'Hoje, 09:24',
        metrics: '12,8 km • 48,2 MB • CSV ;',
        isSynced: true,
      ),
      const _HomeRunItem(
        id: -2,
        title: 'Av. Paulista • Leste',
        dateLabel: '12 set, 16:08',
        metrics: '4,6 km • 21,7 MB • CSV ;',
        isSynced: false,
      ),
      const _HomeRunItem(
        id: -3,
        title: 'SP-270 • km 34-52',
        dateLabel: '10 set, 07:42',
        metrics: '18,1 km • 73,4 MB • CSV ;',
        isSynced: true,
      ),
    ];
  }

  Future<void> _handleSync(_HomeRunItem item) async {
    if (item.isSynced) return;

    if (item.id != null && item.id! > 0 && _dao != null) {
      await _dao!.markAsSynced(item.id!);
    } else {
      // Atualiza o estado da lista demo
      setState(() {
        final index = _demoRuns.indexWhere((r) => r.id == item.id);
        if (index != -1) {
          _demoRuns[index] = _demoRuns[index].copyWith(isSynced: true);
        }
      });
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Ensaio "${item.title}" sincronizado com a nuvem com sucesso!'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final isDark = context.isDarkMode;

    // Cores de alto contraste para o botão principal de coleta em pista
    final buttonBg = isDark ? AppColors.limeAccent : Colors.white;
    final buttonFg = isDark ? AppColors.backgroundDark : AppColors.primary;
    final iconBadgeBg = isDark ? AppColors.backgroundDark : AppColors.primary;
    final iconBadgeFg = isDark ? AppColors.limeAccent : Colors.white;

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
                  Expanded(
                    child: Column(
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
                            Flexible(
                              child: Text(
                                'Roadify',
                                style: typography.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: colors.primary,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppDimensions.space4),
                        Text(
                          'Coletor de Dados de Pavimento',
                          style: typography.bodySmall,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppDimensions.space8),
                  IconButton.filledTonal(
                    tooltip: 'Alternar Tema Claro / Escuro',
                    onPressed: () => widget.themeController.toggleTheme(),
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
                        Flexible(
                          child: Container(
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
                              overflow: TextOverflow.ellipsis,
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
                          backgroundColor: buttonBg,
                          foregroundColor: buttonFg,
                          elevation: 2,
                          shadowColor: Colors.black.withValues(alpha: 0.25),
                          shape: RoundedRectangleBorder(
                            borderRadius: AppDimensions.borderRadiusMedium,
                          ),
                        ),
                        onPressed: widget.onStartCollection,
                        icon: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: iconBadgeBg,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.play_arrow_rounded,
                            size: 18,
                            color: iconBadgeFg,
                          ),
                        ),
                        label: Text(
                          'Iniciar Coleta em Pista',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                            color: buttonFg,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppDimensions.space20),

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
                      children: [
                        Icon(Icons.storage_rounded, size: 20, color: colors.primary),
                        const SizedBox(width: AppDimensions.space8),
                        Expanded(
                          child: Text(
                            'Armazenamento do Aparelho',
                            style: typography.titleMedium,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimensions.space8),
                    Text(
                      '143,3 MB usados',
                      style: typography.labelMedium?.copyWith(
                        color: colors.primary,
                        fontWeight: FontWeight.w700,
                      ),
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
                        Flexible(
                          child: Text(
                            '4 coletas armazenadas',
                            style: typography.bodySmall,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: AppDimensions.space8),
                        Flexible(
                          child: Text(
                            '42 GB disponíveis',
                            style: typography.bodySmall,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.end,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppDimensions.space24),

              // --- Seção: Últimas Coletas (Cards com Botão de Sync Pequeno no Canto Superior Direito) ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Últimas Coletas',
                      style: typography.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: AppDimensions.space8),
                  Text(
                    'Recentes',
                    style: typography.bodySmall?.copyWith(color: colors.primary),
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.space12),

              // Renderiza coletas reativas do banco Drift ou coletas de demonstração
              if (_dao != null)
                StreamBuilder<List<Run>>(
                  stream: _dao!.watchAllRuns(),
                  builder: (context, snapshot) {
                    final dbRuns = snapshot.data;
                    if (dbRuns != null && dbRuns.isNotEmpty) {
                      final items = dbRuns.take(5).map((r) {
                        final dateStr = '${r.recordedAt.day.toString().padLeft(2, '0')}/${r.recordedAt.month.toString().padLeft(2, '0')} ${r.recordedAt.hour.toString().padLeft(2, '0')}:${r.recordedAt.minute.toString().padLeft(2, '0')}';
                        return _HomeRunItem(
                          id: r.id,
                          title: r.title ?? 'Ensaio #${r.id}',
                          dateLabel: dateStr,
                          metrics: '${r.distanceKm.toStringAsFixed(1)} km • Odômetro: ${r.odometer.toStringAsFixed(0)} km',
                          isSynced: r.isSynced,
                        );
                      }).toList();

                      return Column(
                        children: items.map((item) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: AppDimensions.space12),
                            child: _ColetaCard(
                              item: item,
                              onSyncTap: () => _handleSync(item),
                            ),
                          );
                        }).toList(),
                      );
                    }

                    // Se banco estiver vazio, exibe as coletas demo
                    return _buildDemoRunsList();
                  },
                )
              else
                _buildDemoRunsList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDemoRunsList() {
    return Column(
      children: _demoRuns.map((item) {
        return Padding(
          padding: const EdgeInsets.only(bottom: AppDimensions.space12),
          child: _ColetaCard(
            item: item,
            onSyncTap: () => _handleSync(item),
          ),
        );
      }).toList(),
    );
  }
}

/// Card de Coleta Individual com Ícone/Botão de Sincronização no Canto Superior Direito.
class _ColetaCard extends StatelessWidget {
  final _HomeRunItem item;
  final VoidCallback onSyncTap;

  const _ColetaCard({
    required this.item,
    required this.onSyncTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final isSynced = item.isSynced;

    return Container(
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
          // Linha Superior: Título da Coleta + Ícone Pequeno de Nuvem no Canto Superior Direito
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  item.title,
                  style: typography.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(width: AppDimensions.space8),
              // Botão / Ícone pequeno de nuvem no canto superior direito
              Tooltip(
                message: isSynced ? 'Sincronizado na Nuvem' : 'Sincronizar com a Nuvem',
                child: Material(
                  color: isSynced
                      ? colors.primary.withValues(alpha: 0.1)
                      : Colors.amber.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: isSynced ? null : onSyncTap,
                    child: Padding(
                      padding: const EdgeInsets.all(6.0),
                      child: Icon(
                        isSynced ? Icons.cloud_done_rounded : Icons.cloud_upload_outlined,
                        size: 18,
                        color: isSynced ? colors.primary : Colors.amber.shade800,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          // Data e Hora
          Text(
            item.dateLabel,
            style: typography.bodySmall?.copyWith(color: colors.onSurfaceVariant),
          ),
          const SizedBox(height: 8),
          // Métricas do Ensaio
          Text(
            item.metrics,
            style: typography.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: colors.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
