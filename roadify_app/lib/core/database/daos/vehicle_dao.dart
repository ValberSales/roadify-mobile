import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/vehicles_table.dart';

part 'vehicle_dao.g.dart';

@DriftAccessor(tables: [Vehicles])
class VehicleDao extends DatabaseAccessor<AppDatabase> with _$VehicleDaoMixin {
  VehicleDao(super.db);

  Stream<List<Vehicle>> watchAllActiveVehicles() {
    return (select(vehicles)..where((v) => v.isActive.equals(true))).watch();
  }

  Future<List<Vehicle>> getAllActiveVehicles() {
    return (select(vehicles)..where((v) => v.isActive.equals(true))).get();
  }

  Future<Vehicle> getVehicleById(int id) {
    return (select(vehicles)..where((v) => v.id.equals(id))).getSingle();
  }

  Future<int> insertVehicle(VehiclesCompanion vehicle) {
    return into(vehicles).insert(vehicle);
  }

  Future<bool> updateVehicle(Insertable<Vehicle> vehicle) {
    return update(vehicles).replace(vehicle);
  }

  Future<int> updateOdometer({required int id, required double odometer}) {
    return (update(vehicles)..where((vehicle) => vehicle.id.equals(id))).write(
      VehiclesCompanion(
        defaultOdometer: Value(odometer),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  // 6. EXCLUSÃO LÓGICA (Soft Delete)
  Future<int> softDeleteVehicle(int id) {
    return (update(vehicles)..where((v) => v.id.equals(id))).write(
      VehiclesCompanion(
        isActive: const Value(false),
        updatedAt: Value(
          DateTime.now(),
        ), // Registra o momento exato da exclusão
      ),
    );
  }
}
