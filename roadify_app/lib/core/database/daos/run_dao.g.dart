// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'run_dao.dart';

// ignore_for_file: type=lint
mixin _$RunDaoMixin on DatabaseAccessor<AppDatabase> {
  $VehiclesTable get vehicles => attachedDatabase.vehicles;
  $RunsTableTable get runsTable => attachedDatabase.runsTable;
  RunDaoManager get managers => RunDaoManager(this);
}

class RunDaoManager {
  final _$RunDaoMixin _db;
  RunDaoManager(this._db);
  $$VehiclesTableTableManager get vehicles =>
      $$VehiclesTableTableManager(_db.attachedDatabase, _db.vehicles);
  $$RunsTableTableTableManager get runsTable =>
      $$RunsTableTableTableManager(_db.attachedDatabase, _db.runsTable);
}
