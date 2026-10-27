import 'package:drift/drift.dart';
import 'runs_table.dart';

@DataClassName('MediaRecord')
class MediaRecordsTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get runId =>
      integer().references(RunsTable, #id, onDelete: KeyAction.cascade)();
  TextColumn get mediaType => text()();
  TextColumn get filePath => text()();
  DateTimeColumn get recordedAt => dateTime()();
  RealColumn get latitude => real().nullable()();
  RealColumn get longitude => real().nullable()();
}
