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

  /// 3. ATUALIZAÇÕES
  /// Atualiza os dados de um ensaio existente.
  Future<bool> updateRun(Insertable<Run> run) {
    return update(runsTable).replace(run);
  }

  /// 4. EXCLUSÃO
  /// Exclui um ensaio pelo ID.
  Future<int> deleteRun(int id) {
    return (delete(runsTable)..where((t) => t.id.equals(id))).go();
  }

  /// 5. AGREGADORES ÚTEIS PARA A TELA HOME
  /// Contagem total de ensaios salvos.
  Future<int> getRunsCount() async {
    final countExp = runsTable.id.count();
    final query = selectOnly(runsTable)..addColumns([countExp]);
    final result = await query.map((row) => row.read(countExp)).getSingle();
    return result ?? 0;
  }
}
