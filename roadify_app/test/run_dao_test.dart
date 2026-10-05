import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:roadify_app/core/database/app_database.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    // Inicia um banco SQLite isolado em memória para os testes
    db = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  group('RunDao Tests', () {
    test('deve inserir e consultar um ensaio com sucesso', () async {
      final now = DateTime(2026, 10, 5, 10, 30);
      final runCompanion = RunsTableCompanion.insert(
        title: const Value('BR-101 • Trecho Sul'),
        recordedAt: Value(now),
        odometer: const Value(120.5),
        distanceKm: const Value(15.2),
        isSynced: const Value(false),
      );

      final id = await db.runDao.insertRun(runCompanion);
      expect(id, isPositive);

      final retrieved = await db.runDao.getRunById(id);
      expect(retrieved, isNotNull);
      expect(retrieved!.id, equals(id));
      expect(retrieved.title, equals('BR-101 • Trecho Sul'));
      expect(retrieved.odometer, equals(120.5));
      expect(retrieved.distanceKm, equals(15.2));
      expect(retrieved.isSynced, isFalse);
    });

    test('deve listar ensaios ordenados por data decrescente', () async {
      final d1 = DateTime(2026, 10, 1);
      final d2 = DateTime(2026, 10, 5);

      await db.runDao.insertRun(RunsTableCompanion.insert(
        title: const Value('Ensaio 1'),
        recordedAt: Value(d1),
        odometer: const Value(50.0),
      ));

      await db.runDao.insertRun(RunsTableCompanion.insert(
        title: const Value('Ensaio 2'),
        recordedAt: Value(d2),
        odometer: const Value(80.0),
      ));

      final allRuns = await db.runDao.getAllRuns();
      expect(allRuns.length, equals(2));
      expect(allRuns.first.title, equals('Ensaio 2'));
      expect(allRuns.last.title, equals('Ensaio 1'));
    });

    test('deve filtrar ensaios pendentes de sincronização e marcar como sincronizado', () async {
      final id1 = await db.runDao.insertRun(RunsTableCompanion.insert(
        title: const Value('Ensaio Pendente'),
        isSynced: const Value(false),
      ));

      await db.runDao.insertRun(RunsTableCompanion.insert(
        title: const Value('Ensaio Já Sincronizado'),
        isSynced: const Value(true),
      ));

      var pending = await db.runDao.getPendingSyncRuns();
      expect(pending.length, equals(1));
      expect(pending.first.id, equals(id1));

      var pendingCount = await db.runDao.getPendingSyncCount();
      expect(pendingCount, equals(1));

      final marked = await db.runDao.markAsSynced(id1);
      expect(marked, isTrue);

      final updated = await db.runDao.getRunById(id1);
      expect(updated!.isSynced, isTrue);
      expect(updated.syncedAt, isNotNull);

      pending = await db.runDao.getPendingSyncRuns();
      expect(pending, isEmpty);

      pendingCount = await db.runDao.getPendingSyncCount();
      expect(pendingCount, equals(0));
    });

    test('deve excluir um ensaio pelo ID', () async {
      final id = await db.runDao.insertRun(RunsTableCompanion.insert(
        title: const Value('Para Excluir'),
      ));

      final beforeCount = await db.runDao.getRunsCount();
      expect(beforeCount, equals(1));

      final deletedRows = await db.runDao.deleteRun(id);
      expect(deletedRows, equals(1));

      final after = await db.runDao.getRunById(id);
      expect(after, isNull);

      final afterCount = await db.runDao.getRunsCount();
      expect(afterCount, equals(0));
    });

    test('deve emitir atualizações no watchAllRuns reativo', () async {
      final stream = db.runDao.watchAllRuns();
      // Estado inicial: vazio
      expect(await stream.first, isEmpty);

      // Ao inserir novo registro, emite o estado atualizado
      final nextEmission = stream.skip(1).first;
      await db.runDao.insertRun(RunsTableCompanion.insert(
        title: const Value('Ensaio Reativo'),
      ));

      final updatedList = await nextEmission;
      expect(updatedList.length, equals(1));
      expect(updatedList.first.title, equals('Ensaio Reativo'));
    });
  });
}
