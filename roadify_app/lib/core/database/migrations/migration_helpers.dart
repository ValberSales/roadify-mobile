import 'package:drift/drift.dart';
import '../app_database.dart';

/// Helpers utilitários para estratégias de migração de esquema no Drift SQLite.
class DatabaseMigrationHelper {
  final AppDatabase db;

  const DatabaseMigrationHelper(this.db);

  /// Executa operações de criação inicial de todas as tabelas e índices.
  Future<void> onCreate(Migrator m) async {
    await m.createAll();
  }

  /// Gerencia migrações incrementais de esquema versão a versão.
  Future<void> onUpgrade(Migrator m, int from, int to) async {
    // Desativa foreign keys temporariamente durante operações DDL complexas
    await db.customStatement('PRAGMA foreign_keys = OFF;');

    for (var version = from + 1; version <= to; version++) {
      await _executeMigrationStep(m, version);
    }

    // Reativa foreign keys após a conclusão das migrações
    await db.customStatement('PRAGMA foreign_keys = ON;');
  }

  /// Passos individuais de migração conforme o schemaVersion evolui
  Future<void> _executeMigrationStep(Migrator m, int targetVersion) async {
    switch (targetVersion) {
      case 2:
        // Exemplo: se no futuro forem adicionadas novas tabelas ou colunas:
        // await m.createTable(db.runsTable);
        // await m.addColumn(db.runsTable, db.runsTable.notes);
        break;
      default:
        break;
    }
  }

  /// Configuração de PRAGMAs antes da abertura de conexões.
  Future<void> beforeOpen(OpeningDetails details) async {
    // Habilita as chaves estrangeiras (Foreign Keys) para integridade relacional
    await db.customStatement('PRAGMA foreign_keys = ON;');

    // Habilita Write-Ahead Logging (WAL)
    // Essencial para aplicações de alta frequência de escrita (200 Hz),
    // evitando travamentos de banco "locked" durante os ensaios.
    await db.customStatement('PRAGMA journal_mode = WAL;');
  }
}
