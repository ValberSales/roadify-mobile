import 'package:flutter/material.dart';
import 'package:drift/drift.dart';
import 'package:roadify_app/core/database/app_database.dart';
import 'package:roadify_app/core/database/daos/vehicle_dao.dart';

class VehicleViewModel extends ChangeNotifier {
  final VehicleDao _dao;

  VehicleViewModel(this._dao);

  // Expõe a lista de forma reativa para a interface
  Stream<List<Vehicle>> get activeVehiclesStream =>
      _dao.watchAllActiveVehicles();

  // Lógica centralizada de salvamento (criação ou atualização)
  Future<void> saveVehicle({
    Vehicle? existingVehicle,
    required String nome,
    required String modelo,
    required String placa,
    required double odometro,
    required int ano,
    String? descricao,
    String? tracao,
  }) async {
    if (existingVehicle == null) {
      await _dao.insertVehicle(
        VehiclesCompanion.insert(
          name: nome,
          model: modelo,
          licensePlate: placa,
          defaultOdometer: odometro,
          year: ano,
          description: Value(descricao), // Value() lida com nulos nativamente
          traction: Value(tracao),
        ),
      );
    } else {
      await _dao.updateVehicle(
        existingVehicle.copyWith(
          name: nome,
          model: modelo,
          licensePlate: placa,
          defaultOdometer: odometro,
          year: ano,
          description: Value(
            descricao,
          ), // Usando Value para permitir apagar o campo na edição
          traction: Value(tracao),
          updatedAt: Value(DateTime.now()),
        ),
      );
    }
  }

  // Lógica centralizada de exclusão
  Future<void> deleteVehicle(Vehicle vehicle) async {
    await _dao.softDeleteVehicle(vehicle.id);
  }
}
