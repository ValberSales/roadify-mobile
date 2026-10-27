import 'package:drift/drift.dart';
import 'runs_table.dart';

@DataClassName('SensorReading')
class SensorReadingsTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get runId =>
      integer().references(RunsTable, #id, onDelete: KeyAction.cascade)();
  DateTimeColumn get recordedAt => dateTime()();
  RealColumn get accelerometerX => real()();
  RealColumn get accelerometerY => real()();
  RealColumn get accelerometerZ => real()();
  RealColumn get gyroscopeX => real().nullable()();
  RealColumn get gyroscopeY => real().nullable()();
  RealColumn get gyroscopeZ => real().nullable()();
}
