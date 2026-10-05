import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/runs_table.dart';

part 'run_dao.g.dart';

@DriftAccessor(tables: [RunsTable])
class RunDao extends DatabaseAccessor<AppDatabase> with _$RunDaoMixin {
  RunDao(super.db);

  /// 1. INSERÇÃO BÁSICA
  /// Insere um novo ensaio no banco local e retorna o ID gerado.
  Future<int> insertRun(Insertable<Run> run) {
    return into(runsTable).insert(run);
  }

  /// 2. CONSULTAS GERAIS
  /// Retorna todos os ensaios ordenados cronologicamente (mais recente primeiro).
  Future<List<Run>> getAllRuns() {
    return (select(runsTable)
          ..orderBy([
            (t) => OrderingTerm(expression: t.recordedAt, mode: OrderingMode.desc)
          ]))
        .get();
  }

  /// Stream reativa de todos os ensaios para a UI (Home / Dados).
  Stream<List<Run>> watchAllRuns() {
    return (select(runsTable)
          ..orderBy([
            (t) => OrderingTerm(expression: t.recordedAt, mode: OrderingMode.desc)
          ]))
        .watch();
  }

  /// Busca um ensaio específico pelo ID.
  Future<Run?> getRunById(int id) {
    return (select(runsTable)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  /// 3. CONSULTAS DE SINCRONIZAÇÃO
  /// Retorna ensaios ainda pendentes de upload para a nuvem.
  Future<List<Run>> getPendingSyncRuns() {
    return (select(runsTable)..where((t) => t.isSynced.equals(false))).get();
  }

  /// Stream de ensaios pendentes para atualizar badges de notificação.
  Stream<List<Run>> watchPendingSyncRuns() {
    return (select(runsTable)..where((t) => t.isSynced.equals(false))).watch();
  }

  /// 4. ATUALIZAÇÕES
  /// Marca um ensaio como sincronizado e registra a data/hora do sync.
  Future<bool> markAsSynced(int id) async {
    final count = await (update(runsTable)..where((t) => t.id.equals(id))).write(
      RunsTableCompanion(
        isSynced: const Value(true),
        syncedAt: Value(DateTime.now()),
      ),
    );
    return count > 0;
  }

  /// Atualiza os dados de um ensaio existente.
  Future<bool> updateRun(Insertable<Run> run) {
    return update(runsTable).replace(run);
  }

  /// 5. EXCLUSÃO
  /// Exclui um ensaio pelo ID.
  Future<int> deleteRun(int id) {
    return (delete(runsTable)..where((t) => t.id.equals(id))).go();
  }

  /// 6. AGREGADORES ÚTEIS PARA A TELA HOME
  /// Contagem total de ensaios salvos.
  Future<int> getRunsCount() async {
    final countExp = runsTable.id.count();
    final query = selectOnly(runsTable)..addColumns([countExp]);
    final result = await query.map((row) => row.read(countExp)).getSingle();
    return result ?? 0;
  }

  /// Contagem de ensaios pendentes de sincronização.
  Future<int> getPendingSyncCount() async {
    final countExp = runsTable.id.count();
    final query = selectOnly(runsTable)
      ..where(runsTable.isSynced.equals(false))
      ..addColumns([countExp]);
    final result = await query.map((row) => row.read(countExp)).getSingle();
    return result ?? 0;
  }
}
