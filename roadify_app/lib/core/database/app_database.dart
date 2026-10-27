import 'package:drift/drift.dart';
import 'connection/connection.dart';
import 'daos/run_dao.dart';
import 'daos/vehicle_dao.dart';
import 'migrations/migration_helpers.dart';
import 'tables/runs_table.dart';
import 'tables/sensor_readings_table.dart';
import 'tables/gps_points_table.dart';
import 'tables/media_records_table.dart';
import 'tables/vehicles_table.dart';

// Este arquivo será gerado automaticamente pelo build_runner
part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    Vehicles,
    RunsTable,
    SensorReadingsTable,
    GpsPointsTable,
    MediaRecordsTable,
  ],
  daos: [VehicleDao, RunDao],
)
class AppDatabase extends _$AppDatabase {
  // Usa a função de conexão isolada (createInBackground)
  AppDatabase() : super(openConnection());

  // Construtor para testes automatizados com banco em memória
  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 2;

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
