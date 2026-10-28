import 'package:drift/drift.dart';
import 'runs_table.dart';

@DataClassName('GpsPoint')
class GpsPointsTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get runId =>
      integer().references(RunsTable, #id, onDelete: KeyAction.cascade)();
  DateTimeColumn get recordedAt => dateTime()();
  RealColumn get latitude => real()();
  RealColumn get longitude => real()();
  RealColumn get altitudeMeters => real().nullable()();
  RealColumn get speedMetersPerSecond => real().nullable()();
  RealColumn get headingDegrees => real().nullable()();
  RealColumn get accuracyMeters => real().nullable()();
}
