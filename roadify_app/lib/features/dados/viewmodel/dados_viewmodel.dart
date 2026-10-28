import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:roadify_app/core/database/app_database.dart';
import 'package:roadify_app/core/database/daos/run_dao.dart';
import '../services/run_export_service.dart';

@immutable
class RunListItem {
  final int id;
  final String title;
  final DateTime createdAt;
  final double km;
  final double sizeMb;
  final bool isSynced;
  final bool isFinished;

  const RunListItem({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.km,
    required this.sizeMb,
    required this.isSynced,
    required this.isFinished,
  });

  String get dateLabel => formatRunDate(createdAt);

  String get metrics =>
      '${formatDecimal(km)} km • ${formatDecimal(sizeMb)} MB'
          '${isFinished ? '' : ' • Incompleta'}';
}

String formatDecimal(double value) =>
    value.toStringAsFixed(1).replaceAll('.', ',');

String formatRunDate(DateTime utcOrLocal, {DateTime? now}) {
  const months = [
    'jan', 'fev', 'mar', 'abr', 'mai', 'jun',
    'jul', 'ago', 'set', 'out', 'nov', 'dez',
  ];
  final date = utcOrLocal.toLocal();
  final today = now ?? DateTime.now();
  final hh = date.hour.toString().padLeft(2, '0');
  final mm = date.minute.toString().padLeft(2, '0');

  final dayOnly = DateTime(date.year, date.month, date.day);
  final todayOnly = DateTime(today.year, today.month, today.day);
  final diff = todayOnly.difference(dayOnly).inDays;

  if (diff == 0) return 'Hoje, $hh:$mm';
  if (diff == 1) return 'Ontem, $hh:$mm';
  final base = '${date.day} ${months[date.month - 1]}';
  return date.year == today.year ? '$base, $hh:$mm' : '$base ${date.year}, $hh:$mm';
}

/// Observa o banco Drift e expõe as coletas gravadas para a tela de Dados.
class DadosViewModel extends ChangeNotifier {
  // Estimativa de bytes por linha CSV exportada (amostra / ponto GPS).
  static const _bytesPerSensorSample = 64;
  static const _bytesPerGpsPoint = 80;

  final RunDao _dao;
  final RunExportService _exportService;
  final Future<Directory> Function() _documentsDirectory;

  StreamSubscription<List<Run>>? _subscription;
  int _generation = 0;
  bool _disposed = false;

  List<RunListItem> _items = const [];
  bool _isLoading = true;
  Object? _error;

  // Progresso (0.0–1.0) das exportações em andamento, por id de coleta.
  final Map<int, double> _exportProgress = {};

  DadosViewModel(
      this._dao,
      this._exportService, {
        Future<Directory> Function()? documentsDirectory,
      }) : _documentsDirectory = documentsDirectory ?? getApplicationDocumentsDirectory {
    _listen();
  }

  List<RunListItem> get items => _items;
  bool get isLoading => _isLoading;
  Object? get error => _error;
  bool isExporting(int runId) => _exportProgress.containsKey(runId);
  double? exportProgress(int runId) => _exportProgress[runId];
  double get totalMb => _items.fold(0, (sum, r) => sum + r.sizeMb);

  void _listen() {
    _subscription?.cancel();
    _isLoading = true;
    _error = null;
    _subscription = _dao.watchAllRuns().listen(
      _onRuns,
      onError: (Object e) {
        _error = e;
        _isLoading = false;
        _notify();
      },
    );
  }

  /// Reinicia a observação (usado pelo "puxar para atualizar" e por "tentar novamente").
  Future<void> refresh() async {
    final runs = await _dao.getAllRuns();
    await _onRuns(runs);
  }

  void retry() => _listen();

  Future<void> _onRuns(List<Run> runs) async {
    // Descarta resultados antigos caso chegue um evento novo durante o cálculo de tamanho.
    final generation = ++_generation;
    final sizes = await _mediaSizesByRun(runs);
    if (_disposed || generation != _generation) return;

    _items = runs.map((r) {
      final dataBytes = r.accelerometerSampleCount * _bytesPerSensorSample +
          r.gpsPointCount * _bytesPerGpsPoint;
      final totalBytes = dataBytes + (sizes[r.id] ?? 0);
      return RunListItem(
        id: r.id,
        title: (r.title?.trim().isNotEmpty ?? false) ? r.title!.trim() : 'Coleta #${r.id}',
        createdAt: r.recordedAt,
        km: r.distanceKm,
        sizeMb: totalBytes / (1024 * 1024),
        isSynced: r.isSynced,
        isFinished: r.endedAt != null,
      );
    }).toList(growable: false);
    _isLoading = false;
    _error = null;
    _notify();
  }

  /// Soma o tamanho real das mídias gravadas em `<documentos>/roadify/runs/<id>/`.
  Future<Map<int, int>> _mediaSizesByRun(List<Run> runs) async {
    final result = <int, int>{};
    try {
      final root = p.join((await _documentsDirectory()).path, 'roadify', 'runs');
      for (final run in runs) {
        if (run.mediaCount == 0) continue;
        final dir = Directory(p.join(root, run.id.toString()));
        if (!await dir.exists()) continue;
        var total = 0;
        await for (final entity in dir.list(recursive: true, followLinks: false)) {
          if (entity is File) {
            try {
              total += await entity.length();
            } on FileSystemException {
              // Arquivo removido durante a leitura: ignora.
            }
          }
        }
        result[run.id] = total;
      }
    } catch (_) {
      // Falha ao ler o disco não deve impedir a listagem.
    }
    return result;
  }

  /// Gera o ZIP da coleta e pede ao usuário onde salvá-lo.
  /// Retorna o caminho salvo, ou `null` se foi cancelado (ou já havia exportação em curso).
  /// Erros são propagados para a UI exibir a mensagem.
  Future<String?> exportRun(int runId) async {
    if (isExporting(runId)) return null;
    _exportProgress[runId] = 0;
    _notify();
    try {
      return await _exportService.exportRun(
        runId,
        onProgress: (progress) {
          // Evita redesenhar a tela a cada página de CSV: só notifica a cada ~1%.
          final previous = _exportProgress[runId] ?? 0;
          if (progress - previous >= 0.01 || progress >= 1.0) {
            _exportProgress[runId] = progress;
            _notify();
          }
        },
      );
    } finally {
      _exportProgress.remove(runId);
      _notify();
    }
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _subscription?.cancel();
    super.dispose();
  }
}