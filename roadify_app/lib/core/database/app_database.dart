import 'package:drift/drift.dart';
import 'connection/connection.dart';
import 'tables/vehicles_table.dart';
import 'daos/vehicle_dao.dart';

// Este arquivo será gerado automaticamente pelo build_runner
part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    Vehicles,
  ], // Adicione novas tabelas aqui no futuro (ex: RunsTable, GpsTable)
  daos: [VehicleDao], // Adicione novos DAOs aqui
)
class AppDatabase extends _$AppDatabase {
  // Usa a função de conexão isolada (createInBackground)
  AppDatabase() : super(openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        // Regras de migração futura entrarão aqui
      },
      beforeOpen: (details) async {
        // Habilita as chaves estrangeiras (Foreign Keys) para integridade relacional
        await customStatement('PRAGMA foreign_keys = ON');

        // Habilita Write-Ahead Logging (WAL)
        // Essencial para aplicações de alta frequência de escrita (200 Hz),
        // evitando travamentos de banco "locked" durante os ensaios.
        await customStatement('PRAGMA journal_mode=WAL');
      },
    );
  }
}
