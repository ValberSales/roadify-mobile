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

  Stream<Vehicle?> watchDefaultVehicle() {
    return watchAllActiveVehicles().map(_defaultFromVehicles);
  }

  Future<Vehicle?> getDefaultVehicle() async {
    final activeVehicles = await getAllActiveVehicles();
    return _defaultFromVehicles(activeVehicles);
  }

  Vehicle? _defaultFromVehicles(List<Vehicle> activeVehicles) {
    for (final vehicle in activeVehicles) {
      if (vehicle.isDefault) return vehicle;
    }
    return null;
  }

  Future<Vehicle> getVehicleById(int id) {
    return (select(vehicles)..where((v) => v.id.equals(id))).getSingle();
  }

  Future<int> insertVehicle(VehiclesCompanion vehicle) {
    return transaction(() async {
      final currentDefault = await getDefaultVehicle();
      final makeDefault =
          (vehicle.isDefault.present && vehicle.isDefault.value) ||
          currentDefault == null;
      if (makeDefault) {
        await _clearDefaultVehicle();
      }
      return into(
        vehicles,
      ).insert(vehicle.copyWith(isDefault: Value(makeDefault)));
    });
  }

  Future<void> setDefaultVehicle(int id) {
    return transaction(() async {
      final vehicle = await getVehicleById(id);
      if (!vehicle.isActive) {
        throw StateError('Não é possível selecionar um veículo inativo.');
      }
      await _clearDefaultVehicle();
      await (update(vehicles)..where((v) => v.id.equals(id))).write(
        VehiclesCompanion(
          isDefault: const Value(true),
          updatedAt: Value(DateTime.now()),
        ),
      );
    });
  }

  Future<void> _clearDefaultVehicle() async {
    await (update(
      vehicles,
    )..where((v) => v.isActive.equals(true) & v.isDefault.equals(true))).write(
      VehiclesCompanion(
        isDefault: const Value(false),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> _assignDefaultIfMissing() async {
    if (await getDefaultVehicle() != null) return;
    final activeVehicles = await getAllActiveVehicles();
    if (activeVehicles.isEmpty) return;
    final candidate = activeVehicles.first;
    await (update(vehicles)..where((v) => v.id.equals(candidate.id))).write(
      VehiclesCompanion(
        isDefault: const Value(true),
        updatedAt: Value(DateTime.now()),
      ),
    );
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
    return transaction(() async {
      final vehicle = await getVehicleById(id);
      final deletedRows =
          await (update(vehicles)..where((v) => v.id.equals(id))).write(
            VehiclesCompanion(
              isActive: const Value(false),
              isDefault: const Value(false),
              updatedAt: Value(DateTime.now()),
            ),
          );
      if (vehicle.isDefault || await getDefaultVehicle() == null) {
        await _assignDefaultIfMissing();
      }
      return deletedRows;
    });
  }
}
