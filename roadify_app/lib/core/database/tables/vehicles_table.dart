import 'package:drift/drift.dart';

@DataClassName('Vehicle')
class Vehicles extends Table {
  IntColumn get id => integer().autoIncrement()();

  // Colunas Obrigatórias
  TextColumn get name => text()(); // Ex: "Caminhonete do João"
  TextColumn get model => text()(); // Ex: "Toyota Hilux"
  TextColumn get licensePlate => text()();
  RealColumn get defaultOdometer => real()();
  IntColumn get year => integer()();

  // Colunas Opcionais
  TextColumn get description => text().nullable()();
  TextColumn get traction => text().nullable()(); // Ex: "4x4", "4x2"

  // Controle de Estado
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().nullable()();
}
