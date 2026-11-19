import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:roadify_app/core/database/app_database.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  VehiclesCompanion vehicle(String name) => VehiclesCompanion.insert(
    name: name,
    model: 'Modelo',
    licensePlate: 'ABC1234',
    defaultOdometer: 100,
    year: 2020,
  );

  test('marca automaticamente o primeiro veículo como padrão', () async {
    final firstId = await db.vehicleDao.insertVehicle(vehicle('Primeiro'));
    await db.vehicleDao.insertVehicle(vehicle('Segundo'));

    final defaultVehicle = await db.vehicleDao.getDefaultVehicle();
    expect(defaultVehicle?.id, firstId);
    expect(defaultVehicle?.isDefault, isTrue);
  });

  test('troca o padrão e escolhe outro ao excluir o veículo padrão', () async {
    final firstId = await db.vehicleDao.insertVehicle(vehicle('Primeiro'));
    final secondId = await db.vehicleDao.insertVehicle(vehicle('Segundo'));

    await db.vehicleDao.setDefaultVehicle(secondId);
    expect((await db.vehicleDao.getDefaultVehicle())?.id, secondId);

    await db.vehicleDao.softDeleteVehicle(secondId);
    final defaultVehicle = await db.vehicleDao.getDefaultVehicle();
    expect(defaultVehicle?.id, firstId);
    expect(defaultVehicle?.isDefault, isTrue);
  });

  test('não retorna veículo padrão quando todos foram removidos', () async {
    final id = await db.vehicleDao.insertVehicle(vehicle('Único'));

    await db.vehicleDao.softDeleteVehicle(id);

    expect(await db.vehicleDao.getAllActiveVehicles(), isEmpty);
    expect(await db.vehicleDao.getDefaultVehicle(), isNull);
  });
}
