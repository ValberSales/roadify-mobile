import 'package:drift/drift.dart';
import 'vehicles_table.dart';

/// Tabela de Ensaios / Coletas (Runs)
/// Armazena os metadados principais de cada ensaio realizado no Roadify.
@DataClassName('Run')
class RunsTable extends Table {
  // 1. Identificador único do ensaio (id)
  IntColumn get id => integer().autoIncrement()();

  // 2. Data e hora de realização do ensaio (data/hora)
  DateTimeColumn get recordedAt => dateTime().withDefault(currentDateAndTime)();

  // 3. Odômetro inicial / acumulado em km (odômetro)
  RealColumn get odometer => real().withDefault(const Constant(0.0))();

  // 4. Status de sincronização com o servidor na nuvem (sincronizado)
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();

  // --- Campos complementares de negócio ---
  // Título descritivo ou trecho da rodovia (ex: "BR-101 • Trecho Norte")
  TextColumn get title => text().nullable()();

  // Distância total percorrida no ensaio (em km)
  RealColumn get distanceKm => real().withDefault(const Constant(0.0))();

  // Chave estrangeira para o veículo utilizado no ensaio
  IntColumn get vehicleId => integer().nullable().references(Vehicles, #id)();

  // Observações gerais ou anotações de campo
  TextColumn get notes => text().nullable()();

  // Data/hora em que a sincronização com a nuvem foi confirmada
  DateTimeColumn get syncedAt => dateTime().nullable()();
}
