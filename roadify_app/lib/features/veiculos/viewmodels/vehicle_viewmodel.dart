import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:drift/drift.dart';
import 'package:roadify_app/core/database/app_database.dart';
import 'package:roadify_app/core/database/daos/vehicle_dao.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VehicleViewModel extends ChangeNotifier {
  static const String lastUsedVehicleIdKey = 'roadify_last_used_vehicle_id';
  static const String _collectionConfigKey = 'last_collection_configuration';

  final VehicleDao _dao;
  int? _lastUsedVehicleId;

  VehicleViewModel(this._dao) {
    unawaited(loadLastUsedVehicleId());
  }

  /// ID do último veículo selecionado ou utilizado na coleta.
  int? get lastUsedVehicleId => _lastUsedVehicleId;

  // Expõe a lista de forma reativa para a interface
  Stream<List<Vehicle>> get activeVehiclesStream =>
      _dao.watchAllActiveVehicles();

  Stream<Vehicle?> get defaultVehicleStream => _dao.watchDefaultVehicle();

  Future<List<Vehicle>> getActiveVehicles() => _dao.getAllActiveVehicles();

  Future<Vehicle?> getDefaultVehicle() => _dao.getDefaultVehicle();

  /// Carrega o ID do último veículo utilizado das preferências locais.
  Future<void> loadLastUsedVehicleId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      int? savedId = prefs.getInt(lastUsedVehicleIdKey);
      if (savedId == null) {
        final rawConfig = prefs.getString(_collectionConfigKey);
        if (rawConfig != null) {
          final decoded = jsonDecode(rawConfig);
          if (decoded is Map<String, dynamic> && decoded['vehicleId'] is int) {
            savedId = decoded['vehicleId'] as int;
          }
        }
      }
      if (savedId != _lastUsedVehicleId) {
        _lastUsedVehicleId = savedId;
        notifyListeners();
      }
    } catch (_) {}
  }

  /// Registra o ID do último veículo utilizado na coleta e notifica ouvintes.
  Future<void> setLastUsedVehicleId(int? vehicleId) async {
    if (_lastUsedVehicleId != vehicleId) {
      _lastUsedVehicleId = vehicleId;
      notifyListeners();
    }
    try {
      final prefs = await SharedPreferences.getInstance();
      if (vehicleId == null) {
        await prefs.remove(lastUsedVehicleIdKey);
      } else {
        await prefs.setInt(lastUsedVehicleIdKey, vehicleId);
      }
    } catch (_) {}
  }

  /// Seleciona um veículo como ativo/último utilizado e atualiza o padrão e a configuração de coleta.
  Future<void> setDefaultVehicle(Vehicle vehicle) async {
    await _dao.setDefaultVehicle(vehicle.id);
    _lastUsedVehicleId = vehicle.id;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(lastUsedVehicleIdKey, vehicle.id);
      final rawConfig = prefs.getString(_collectionConfigKey);
      if (rawConfig != null) {
        final decoded = jsonDecode(rawConfig);
        if (decoded is Map<String, dynamic>) {
          decoded['vehicleId'] = vehicle.id;
          decoded['initialOdometer'] = vehicle.defaultOdometer;
          await prefs.setString(_collectionConfigKey, jsonEncode(decoded));
        }
      }
    } catch (_) {}
  }

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
    if (_lastUsedVehicleId == vehicle.id) {
      await setLastUsedVehicleId(null);
    }
  }
}
