import 'package:drift/drift.dart';
import 'connection/connection.dart';
import 'daos/run_dao.dart';
import 'daos/vehicle_dao.dart';
import 'migrations/migration_helpers.dart';
import 'tables/runs_table.dart';
import 'tables/vehicles_table.dart';

// Este arquivo será gerado automaticamente pelo build_runner
part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    Vehicles,
    RunsTable,
  ],
  daos: [
    VehicleDao,
    RunDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  // Usa a função de conexão isolada (createInBackground)
  AppDatabase() : super(openConnection());

  // Construtor para testes automatizados com banco em memória
  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration {
    final helper = DatabaseMigrationHelper(this);
    return MigrationStrategy(
      onCreate: helper.onCreate,
      onUpgrade: helper.onUpgrade,
      beforeOpen: helper.beforeOpen,
    );
  }
}
