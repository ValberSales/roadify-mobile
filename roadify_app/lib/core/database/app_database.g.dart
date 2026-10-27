// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $VehiclesTable extends Vehicles with TableInfo<$VehiclesTable, Vehicle> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VehiclesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _modelMeta = const VerificationMeta('model');
  @override
  late final GeneratedColumn<String> model = GeneratedColumn<String>(
    'model',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _licensePlateMeta = const VerificationMeta(
    'licensePlate',
  );
  @override
  late final GeneratedColumn<String> licensePlate = GeneratedColumn<String>(
    'license_plate',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _defaultOdometerMeta = const VerificationMeta(
    'defaultOdometer',
  );
  @override
  late final GeneratedColumn<double> defaultOdometer = GeneratedColumn<double>(
    'default_odometer',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _yearMeta = const VerificationMeta('year');
  @override
  late final GeneratedColumn<int> year = GeneratedColumn<int>(
    'year',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _tractionMeta = const VerificationMeta(
    'traction',
  );
  @override
  late final GeneratedColumn<String> traction = GeneratedColumn<String>(
    'traction',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    model,
    licensePlate,
    defaultOdometer,
    year,
    description,
    traction,
    isActive,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'vehicles';
  @override
  VerificationContext validateIntegrity(
    Insertable<Vehicle> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('model')) {
      context.handle(
        _modelMeta,
        model.isAcceptableOrUnknown(data['model']!, _modelMeta),
      );
    } else if (isInserting) {
      context.missing(_modelMeta);
    }
    if (data.containsKey('license_plate')) {
      context.handle(
        _licensePlateMeta,
        licensePlate.isAcceptableOrUnknown(
          data['license_plate']!,
          _licensePlateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_licensePlateMeta);
    }
    if (data.containsKey('default_odometer')) {
      context.handle(
        _defaultOdometerMeta,
        defaultOdometer.isAcceptableOrUnknown(
          data['default_odometer']!,
          _defaultOdometerMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_defaultOdometerMeta);
    }
    if (data.containsKey('year')) {
      context.handle(
        _yearMeta,
        year.isAcceptableOrUnknown(data['year']!, _yearMeta),
      );
    } else if (isInserting) {
      context.missing(_yearMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('traction')) {
      context.handle(
        _tractionMeta,
        traction.isAcceptableOrUnknown(data['traction']!, _tractionMeta),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Vehicle map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Vehicle(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      model: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}model'],
      )!,
      licensePlate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}license_plate'],
      )!,
      defaultOdometer: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}default_odometer'],
      )!,
      year: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}year'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      traction: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}traction'],
      ),
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      ),
    );
  }

  @override
  $VehiclesTable createAlias(String alias) {
    return $VehiclesTable(attachedDatabase, alias);
  }
}

class Vehicle extends DataClass implements Insertable<Vehicle> {
  final int id;
  final String name;
  final String model;
  final String licensePlate;
  final double defaultOdometer;
  final int year;
  final String? description;
  final String? traction;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;
  const Vehicle({
    required this.id,
    required this.name,
    required this.model,
    required this.licensePlate,
    required this.defaultOdometer,
    required this.year,
    this.description,
    this.traction,
    required this.isActive,
    required this.createdAt,
    this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['model'] = Variable<String>(model);
    map['license_plate'] = Variable<String>(licensePlate);
    map['default_odometer'] = Variable<double>(defaultOdometer);
    map['year'] = Variable<int>(year);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    if (!nullToAbsent || traction != null) {
      map['traction'] = Variable<String>(traction);
    }
    map['is_active'] = Variable<bool>(isActive);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    return map;
  }

  VehiclesCompanion toCompanion(bool nullToAbsent) {
    return VehiclesCompanion(
      id: Value(id),
      name: Value(name),
      model: Value(model),
      licensePlate: Value(licensePlate),
      defaultOdometer: Value(defaultOdometer),
      year: Value(year),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      traction: traction == null && nullToAbsent
          ? const Value.absent()
          : Value(traction),
      isActive: Value(isActive),
      createdAt: Value(createdAt),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
    );
  }

  factory Vehicle.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Vehicle(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      model: serializer.fromJson<String>(json['model']),
      licensePlate: serializer.fromJson<String>(json['licensePlate']),
      defaultOdometer: serializer.fromJson<double>(json['defaultOdometer']),
      year: serializer.fromJson<int>(json['year']),
      description: serializer.fromJson<String?>(json['description']),
      traction: serializer.fromJson<String?>(json['traction']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'model': serializer.toJson<String>(model),
      'licensePlate': serializer.toJson<String>(licensePlate),
      'defaultOdometer': serializer.toJson<double>(defaultOdometer),
      'year': serializer.toJson<int>(year),
      'description': serializer.toJson<String?>(description),
      'traction': serializer.toJson<String?>(traction),
      'isActive': serializer.toJson<bool>(isActive),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
    };
  }

  Vehicle copyWith({
    int? id,
    String? name,
    String? model,
    String? licensePlate,
    double? defaultOdometer,
    int? year,
    Value<String?> description = const Value.absent(),
    Value<String?> traction = const Value.absent(),
    bool? isActive,
    DateTime? createdAt,
    Value<DateTime?> updatedAt = const Value.absent(),
  }) => Vehicle(
    id: id ?? this.id,
    name: name ?? this.name,
    model: model ?? this.model,
    licensePlate: licensePlate ?? this.licensePlate,
    defaultOdometer: defaultOdometer ?? this.defaultOdometer,
    year: year ?? this.year,
    description: description.present ? description.value : this.description,
    traction: traction.present ? traction.value : this.traction,
    isActive: isActive ?? this.isActive,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
  );
  Vehicle copyWithCompanion(VehiclesCompanion data) {
    return Vehicle(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      model: data.model.present ? data.model.value : this.model,
      licensePlate: data.licensePlate.present
          ? data.licensePlate.value
          : this.licensePlate,
      defaultOdometer: data.defaultOdometer.present
          ? data.defaultOdometer.value
          : this.defaultOdometer,
      year: data.year.present ? data.year.value : this.year,
      description: data.description.present
          ? data.description.value
          : this.description,
      traction: data.traction.present ? data.traction.value : this.traction,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Vehicle(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('model: $model, ')
          ..write('licensePlate: $licensePlate, ')
          ..write('defaultOdometer: $defaultOdometer, ')
          ..write('year: $year, ')
          ..write('description: $description, ')
          ..write('traction: $traction, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    model,
    licensePlate,
    defaultOdometer,
    year,
    description,
    traction,
    isActive,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Vehicle &&
          other.id == this.id &&
          other.name == this.name &&
          other.model == this.model &&
          other.licensePlate == this.licensePlate &&
          other.defaultOdometer == this.defaultOdometer &&
          other.year == this.year &&
          other.description == this.description &&
          other.traction == this.traction &&
          other.isActive == this.isActive &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class VehiclesCompanion extends UpdateCompanion<Vehicle> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> model;
  final Value<String> licensePlate;
  final Value<double> defaultOdometer;
  final Value<int> year;
  final Value<String?> description;
  final Value<String?> traction;
  final Value<bool> isActive;
  final Value<DateTime> createdAt;
  final Value<DateTime?> updatedAt;
  const VehiclesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.model = const Value.absent(),
    this.licensePlate = const Value.absent(),
    this.defaultOdometer = const Value.absent(),
    this.year = const Value.absent(),
    this.description = const Value.absent(),
    this.traction = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  VehiclesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String model,
    required String licensePlate,
    required double defaultOdometer,
    required int year,
    this.description = const Value.absent(),
    this.traction = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : name = Value(name),
       model = Value(model),
       licensePlate = Value(licensePlate),
       defaultOdometer = Value(defaultOdometer),
       year = Value(year);
  static Insertable<Vehicle> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? model,
    Expression<String>? licensePlate,
    Expression<double>? defaultOdometer,
    Expression<int>? year,
    Expression<String>? description,
    Expression<String>? traction,
    Expression<bool>? isActive,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (model != null) 'model': model,
      if (licensePlate != null) 'license_plate': licensePlate,
      if (defaultOdometer != null) 'default_odometer': defaultOdometer,
      if (year != null) 'year': year,
      if (description != null) 'description': description,
      if (traction != null) 'traction': traction,
      if (isActive != null) 'is_active': isActive,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  VehiclesCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String>? model,
    Value<String>? licensePlate,
    Value<double>? defaultOdometer,
    Value<int>? year,
    Value<String?>? description,
    Value<String?>? traction,
    Value<bool>? isActive,
    Value<DateTime>? createdAt,
    Value<DateTime?>? updatedAt,
  }) {
    return VehiclesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      model: model ?? this.model,
      licensePlate: licensePlate ?? this.licensePlate,
      defaultOdometer: defaultOdometer ?? this.defaultOdometer,
      year: year ?? this.year,
      description: description ?? this.description,
      traction: traction ?? this.traction,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (model.present) {
      map['model'] = Variable<String>(model.value);
    }
    if (licensePlate.present) {
      map['license_plate'] = Variable<String>(licensePlate.value);
    }
    if (defaultOdometer.present) {
      map['default_odometer'] = Variable<double>(defaultOdometer.value);
    }
    if (year.present) {
      map['year'] = Variable<int>(year.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (traction.present) {
      map['traction'] = Variable<String>(traction.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VehiclesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('model: $model, ')
          ..write('licensePlate: $licensePlate, ')
          ..write('defaultOdometer: $defaultOdometer, ')
          ..write('year: $year, ')
          ..write('description: $description, ')
          ..write('traction: $traction, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $RunsTableTable extends RunsTable with TableInfo<$RunsTableTable, Run> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RunsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _recordedAtMeta = const VerificationMeta(
    'recordedAt',
  );
  @override
  late final GeneratedColumn<DateTime> recordedAt = GeneratedColumn<DateTime>(
    'recorded_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _odometerMeta = const VerificationMeta(
    'odometer',
  );
  @override
  late final GeneratedColumn<double> odometer = GeneratedColumn<double>(
    'odometer',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _isSyncedMeta = const VerificationMeta(
    'isSynced',
  );
  @override
  late final GeneratedColumn<bool> isSynced = GeneratedColumn<bool>(
    'is_synced',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_synced" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _distanceKmMeta = const VerificationMeta(
    'distanceKm',
  );
  @override
  late final GeneratedColumn<double> distanceKm = GeneratedColumn<double>(
    'distance_km',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _vehicleIdMeta = const VerificationMeta(
    'vehicleId',
  );
  @override
  late final GeneratedColumn<int> vehicleId = GeneratedColumn<int>(
    'vehicle_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES vehicles (id)',
    ),
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _syncedAtMeta = const VerificationMeta(
    'syncedAt',
  );
  @override
  late final GeneratedColumn<DateTime> syncedAt = GeneratedColumn<DateTime>(
    'synced_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _endedAtMeta = const VerificationMeta(
    'endedAt',
  );
  @override
  late final GeneratedColumn<DateTime> endedAt = GeneratedColumn<DateTime>(
    'ended_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _durationSecondsMeta = const VerificationMeta(
    'durationSeconds',
  );
  @override
  late final GeneratedColumn<int> durationSeconds = GeneratedColumn<int>(
    'duration_seconds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _configurationJsonMeta = const VerificationMeta(
    'configurationJson',
  );
  @override
  late final GeneratedColumn<String> configurationJson =
      GeneratedColumn<String>(
        'configuration_json',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _deviceManufacturerMeta =
      const VerificationMeta('deviceManufacturer');
  @override
  late final GeneratedColumn<String> deviceManufacturer =
      GeneratedColumn<String>(
        'device_manufacturer',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _deviceModelMeta = const VerificationMeta(
    'deviceModel',
  );
  @override
  late final GeneratedColumn<String> deviceModel = GeneratedColumn<String>(
    'device_model',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _initialBatteryPercentMeta =
      const VerificationMeta('initialBatteryPercent');
  @override
  late final GeneratedColumn<int> initialBatteryPercent = GeneratedColumn<int>(
    'initial_battery_percent',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _initialBatteryTemperatureCMeta =
      const VerificationMeta('initialBatteryTemperatureC');
  @override
  late final GeneratedColumn<double> initialBatteryTemperatureC =
      GeneratedColumn<double>(
        'initial_battery_temperature_c',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _accelerometerSampleCountMeta =
      const VerificationMeta('accelerometerSampleCount');
  @override
  late final GeneratedColumn<int> accelerometerSampleCount =
      GeneratedColumn<int>(
        'accelerometer_sample_count',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
        defaultValue: const Constant(0),
      );
  static const VerificationMeta _gpsPointCountMeta = const VerificationMeta(
    'gpsPointCount',
  );
  @override
  late final GeneratedColumn<int> gpsPointCount = GeneratedColumn<int>(
    'gps_point_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _mediaCountMeta = const VerificationMeta(
    'mediaCount',
  );
  @override
  late final GeneratedColumn<int> mediaCount = GeneratedColumn<int>(
    'media_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    recordedAt,
    odometer,
    isSynced,
    title,
    distanceKm,
    vehicleId,
    notes,
    syncedAt,
    endedAt,
    durationSeconds,
    configurationJson,
    deviceManufacturer,
    deviceModel,
    initialBatteryPercent,
    initialBatteryTemperatureC,
    accelerometerSampleCount,
    gpsPointCount,
    mediaCount,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'runs_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<Run> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('recorded_at')) {
      context.handle(
        _recordedAtMeta,
        recordedAt.isAcceptableOrUnknown(data['recorded_at']!, _recordedAtMeta),
      );
    }
    if (data.containsKey('odometer')) {
      context.handle(
        _odometerMeta,
        odometer.isAcceptableOrUnknown(data['odometer']!, _odometerMeta),
      );
    }
    if (data.containsKey('is_synced')) {
      context.handle(
        _isSyncedMeta,
        isSynced.isAcceptableOrUnknown(data['is_synced']!, _isSyncedMeta),
      );
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    }
    if (data.containsKey('distance_km')) {
      context.handle(
        _distanceKmMeta,
        distanceKm.isAcceptableOrUnknown(data['distance_km']!, _distanceKmMeta),
      );
    }
    if (data.containsKey('vehicle_id')) {
      context.handle(
        _vehicleIdMeta,
        vehicleId.isAcceptableOrUnknown(data['vehicle_id']!, _vehicleIdMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('synced_at')) {
      context.handle(
        _syncedAtMeta,
        syncedAt.isAcceptableOrUnknown(data['synced_at']!, _syncedAtMeta),
      );
    }
    if (data.containsKey('ended_at')) {
      context.handle(
        _endedAtMeta,
        endedAt.isAcceptableOrUnknown(data['ended_at']!, _endedAtMeta),
      );
    }
    if (data.containsKey('duration_seconds')) {
      context.handle(
        _durationSecondsMeta,
        durationSeconds.isAcceptableOrUnknown(
          data['duration_seconds']!,
          _durationSecondsMeta,
        ),
      );
    }
    if (data.containsKey('configuration_json')) {
      context.handle(
        _configurationJsonMeta,
        configurationJson.isAcceptableOrUnknown(
          data['configuration_json']!,
          _configurationJsonMeta,
        ),
      );
    }
    if (data.containsKey('device_manufacturer')) {
      context.handle(
        _deviceManufacturerMeta,
        deviceManufacturer.isAcceptableOrUnknown(
          data['device_manufacturer']!,
          _deviceManufacturerMeta,
        ),
      );
    }
    if (data.containsKey('device_model')) {
      context.handle(
        _deviceModelMeta,
        deviceModel.isAcceptableOrUnknown(
          data['device_model']!,
          _deviceModelMeta,
        ),
      );
    }
    if (data.containsKey('initial_battery_percent')) {
      context.handle(
        _initialBatteryPercentMeta,
        initialBatteryPercent.isAcceptableOrUnknown(
          data['initial_battery_percent']!,
          _initialBatteryPercentMeta,
        ),
      );
    }
    if (data.containsKey('initial_battery_temperature_c')) {
      context.handle(
        _initialBatteryTemperatureCMeta,
        initialBatteryTemperatureC.isAcceptableOrUnknown(
          data['initial_battery_temperature_c']!,
          _initialBatteryTemperatureCMeta,
        ),
      );
    }
    if (data.containsKey('accelerometer_sample_count')) {
      context.handle(
        _accelerometerSampleCountMeta,
        accelerometerSampleCount.isAcceptableOrUnknown(
          data['accelerometer_sample_count']!,
          _accelerometerSampleCountMeta,
        ),
      );
    }
    if (data.containsKey('gps_point_count')) {
      context.handle(
        _gpsPointCountMeta,
        gpsPointCount.isAcceptableOrUnknown(
          data['gps_point_count']!,
          _gpsPointCountMeta,
        ),
      );
    }
    if (data.containsKey('media_count')) {
      context.handle(
        _mediaCountMeta,
        mediaCount.isAcceptableOrUnknown(data['media_count']!, _mediaCountMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Run map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Run(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      recordedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}recorded_at'],
      )!,
      odometer: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}odometer'],
      )!,
      isSynced: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_synced'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      ),
      distanceKm: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}distance_km'],
      )!,
      vehicleId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}vehicle_id'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      syncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}synced_at'],
      ),
      endedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}ended_at'],
      ),
      durationSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_seconds'],
      )!,
      configurationJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}configuration_json'],
      ),
      deviceManufacturer: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_manufacturer'],
      ),
      deviceModel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_model'],
      ),
      initialBatteryPercent: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}initial_battery_percent'],
      ),
      initialBatteryTemperatureC: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}initial_battery_temperature_c'],
      ),
      accelerometerSampleCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}accelerometer_sample_count'],
      )!,
      gpsPointCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}gps_point_count'],
      )!,
      mediaCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}media_count'],
      )!,
    );
  }

  @override
  $RunsTableTable createAlias(String alias) {
    return $RunsTableTable(attachedDatabase, alias);
  }
}

class Run extends DataClass implements Insertable<Run> {
  final int id;
  final DateTime recordedAt;
  final double odometer;
  final bool isSynced;
  final String? title;
  final double distanceKm;
  final int? vehicleId;
  final String? notes;
  final DateTime? syncedAt;
  final DateTime? endedAt;
  final int durationSeconds;
  final String? configurationJson;
  final String? deviceManufacturer;
  final String? deviceModel;
  final int? initialBatteryPercent;
  final double? initialBatteryTemperatureC;
  final int accelerometerSampleCount;
  final int gpsPointCount;
  final int mediaCount;
  const Run({
    required this.id,
    required this.recordedAt,
    required this.odometer,
    required this.isSynced,
    this.title,
    required this.distanceKm,
    this.vehicleId,
    this.notes,
    this.syncedAt,
    this.endedAt,
    required this.durationSeconds,
    this.configurationJson,
    this.deviceManufacturer,
    this.deviceModel,
    this.initialBatteryPercent,
    this.initialBatteryTemperatureC,
    required this.accelerometerSampleCount,
    required this.gpsPointCount,
    required this.mediaCount,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['recorded_at'] = Variable<DateTime>(recordedAt);
    map['odometer'] = Variable<double>(odometer);
    map['is_synced'] = Variable<bool>(isSynced);
    if (!nullToAbsent || title != null) {
      map['title'] = Variable<String>(title);
    }
    map['distance_km'] = Variable<double>(distanceKm);
    if (!nullToAbsent || vehicleId != null) {
      map['vehicle_id'] = Variable<int>(vehicleId);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    if (!nullToAbsent || syncedAt != null) {
      map['synced_at'] = Variable<DateTime>(syncedAt);
    }
    if (!nullToAbsent || endedAt != null) {
      map['ended_at'] = Variable<DateTime>(endedAt);
    }
    map['duration_seconds'] = Variable<int>(durationSeconds);
    if (!nullToAbsent || configurationJson != null) {
      map['configuration_json'] = Variable<String>(configurationJson);
    }
    if (!nullToAbsent || deviceManufacturer != null) {
      map['device_manufacturer'] = Variable<String>(deviceManufacturer);
    }
    if (!nullToAbsent || deviceModel != null) {
      map['device_model'] = Variable<String>(deviceModel);
    }
    if (!nullToAbsent || initialBatteryPercent != null) {
      map['initial_battery_percent'] = Variable<int>(initialBatteryPercent);
    }
    if (!nullToAbsent || initialBatteryTemperatureC != null) {
      map['initial_battery_temperature_c'] = Variable<double>(
        initialBatteryTemperatureC,
      );
    }
    map['accelerometer_sample_count'] = Variable<int>(accelerometerSampleCount);
    map['gps_point_count'] = Variable<int>(gpsPointCount);
    map['media_count'] = Variable<int>(mediaCount);
    return map;
  }

  RunsTableCompanion toCompanion(bool nullToAbsent) {
    return RunsTableCompanion(
      id: Value(id),
      recordedAt: Value(recordedAt),
      odometer: Value(odometer),
      isSynced: Value(isSynced),
      title: title == null && nullToAbsent
          ? const Value.absent()
          : Value(title),
      distanceKm: Value(distanceKm),
      vehicleId: vehicleId == null && nullToAbsent
          ? const Value.absent()
          : Value(vehicleId),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      syncedAt: syncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(syncedAt),
      endedAt: endedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(endedAt),
      durationSeconds: Value(durationSeconds),
      configurationJson: configurationJson == null && nullToAbsent
          ? const Value.absent()
          : Value(configurationJson),
      deviceManufacturer: deviceManufacturer == null && nullToAbsent
          ? const Value.absent()
          : Value(deviceManufacturer),
      deviceModel: deviceModel == null && nullToAbsent
          ? const Value.absent()
          : Value(deviceModel),
      initialBatteryPercent: initialBatteryPercent == null && nullToAbsent
          ? const Value.absent()
          : Value(initialBatteryPercent),
      initialBatteryTemperatureC:
          initialBatteryTemperatureC == null && nullToAbsent
          ? const Value.absent()
          : Value(initialBatteryTemperatureC),
      accelerometerSampleCount: Value(accelerometerSampleCount),
      gpsPointCount: Value(gpsPointCount),
      mediaCount: Value(mediaCount),
    );
  }

  factory Run.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Run(
      id: serializer.fromJson<int>(json['id']),
      recordedAt: serializer.fromJson<DateTime>(json['recordedAt']),
      odometer: serializer.fromJson<double>(json['odometer']),
      isSynced: serializer.fromJson<bool>(json['isSynced']),
      title: serializer.fromJson<String?>(json['title']),
      distanceKm: serializer.fromJson<double>(json['distanceKm']),
      vehicleId: serializer.fromJson<int?>(json['vehicleId']),
      notes: serializer.fromJson<String?>(json['notes']),
      syncedAt: serializer.fromJson<DateTime?>(json['syncedAt']),
      endedAt: serializer.fromJson<DateTime?>(json['endedAt']),
      durationSeconds: serializer.fromJson<int>(json['durationSeconds']),
      configurationJson: serializer.fromJson<String?>(
        json['configurationJson'],
      ),
      deviceManufacturer: serializer.fromJson<String?>(
        json['deviceManufacturer'],
      ),
      deviceModel: serializer.fromJson<String?>(json['deviceModel']),
      initialBatteryPercent: serializer.fromJson<int?>(
        json['initialBatteryPercent'],
      ),
      initialBatteryTemperatureC: serializer.fromJson<double?>(
        json['initialBatteryTemperatureC'],
      ),
      accelerometerSampleCount: serializer.fromJson<int>(
        json['accelerometerSampleCount'],
      ),
      gpsPointCount: serializer.fromJson<int>(json['gpsPointCount']),
      mediaCount: serializer.fromJson<int>(json['mediaCount']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'recordedAt': serializer.toJson<DateTime>(recordedAt),
      'odometer': serializer.toJson<double>(odometer),
      'isSynced': serializer.toJson<bool>(isSynced),
      'title': serializer.toJson<String?>(title),
      'distanceKm': serializer.toJson<double>(distanceKm),
      'vehicleId': serializer.toJson<int?>(vehicleId),
      'notes': serializer.toJson<String?>(notes),
      'syncedAt': serializer.toJson<DateTime?>(syncedAt),
      'endedAt': serializer.toJson<DateTime?>(endedAt),
      'durationSeconds': serializer.toJson<int>(durationSeconds),
      'configurationJson': serializer.toJson<String?>(configurationJson),
      'deviceManufacturer': serializer.toJson<String?>(deviceManufacturer),
      'deviceModel': serializer.toJson<String?>(deviceModel),
      'initialBatteryPercent': serializer.toJson<int?>(initialBatteryPercent),
      'initialBatteryTemperatureC': serializer.toJson<double?>(
        initialBatteryTemperatureC,
      ),
      'accelerometerSampleCount': serializer.toJson<int>(
        accelerometerSampleCount,
      ),
      'gpsPointCount': serializer.toJson<int>(gpsPointCount),
      'mediaCount': serializer.toJson<int>(mediaCount),
    };
  }

  Run copyWith({
    int? id,
    DateTime? recordedAt,
    double? odometer,
    bool? isSynced,
    Value<String?> title = const Value.absent(),
    double? distanceKm,
    Value<int?> vehicleId = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    Value<DateTime?> syncedAt = const Value.absent(),
    Value<DateTime?> endedAt = const Value.absent(),
    int? durationSeconds,
    Value<String?> configurationJson = const Value.absent(),
    Value<String?> deviceManufacturer = const Value.absent(),
    Value<String?> deviceModel = const Value.absent(),
    Value<int?> initialBatteryPercent = const Value.absent(),
    Value<double?> initialBatteryTemperatureC = const Value.absent(),
    int? accelerometerSampleCount,
    int? gpsPointCount,
    int? mediaCount,
  }) => Run(
    id: id ?? this.id,
    recordedAt: recordedAt ?? this.recordedAt,
    odometer: odometer ?? this.odometer,
    isSynced: isSynced ?? this.isSynced,
    title: title.present ? title.value : this.title,
    distanceKm: distanceKm ?? this.distanceKm,
    vehicleId: vehicleId.present ? vehicleId.value : this.vehicleId,
    notes: notes.present ? notes.value : this.notes,
    syncedAt: syncedAt.present ? syncedAt.value : this.syncedAt,
    endedAt: endedAt.present ? endedAt.value : this.endedAt,
    durationSeconds: durationSeconds ?? this.durationSeconds,
    configurationJson: configurationJson.present
        ? configurationJson.value
        : this.configurationJson,
    deviceManufacturer: deviceManufacturer.present
        ? deviceManufacturer.value
        : this.deviceManufacturer,
    deviceModel: deviceModel.present ? deviceModel.value : this.deviceModel,
    initialBatteryPercent: initialBatteryPercent.present
        ? initialBatteryPercent.value
        : this.initialBatteryPercent,
    initialBatteryTemperatureC: initialBatteryTemperatureC.present
        ? initialBatteryTemperatureC.value
        : this.initialBatteryTemperatureC,
    accelerometerSampleCount:
        accelerometerSampleCount ?? this.accelerometerSampleCount,
    gpsPointCount: gpsPointCount ?? this.gpsPointCount,
    mediaCount: mediaCount ?? this.mediaCount,
  );
  Run copyWithCompanion(RunsTableCompanion data) {
    return Run(
      id: data.id.present ? data.id.value : this.id,
      recordedAt: data.recordedAt.present
          ? data.recordedAt.value
          : this.recordedAt,
      odometer: data.odometer.present ? data.odometer.value : this.odometer,
      isSynced: data.isSynced.present ? data.isSynced.value : this.isSynced,
      title: data.title.present ? data.title.value : this.title,
      distanceKm: data.distanceKm.present
          ? data.distanceKm.value
          : this.distanceKm,
      vehicleId: data.vehicleId.present ? data.vehicleId.value : this.vehicleId,
      notes: data.notes.present ? data.notes.value : this.notes,
      syncedAt: data.syncedAt.present ? data.syncedAt.value : this.syncedAt,
      endedAt: data.endedAt.present ? data.endedAt.value : this.endedAt,
      durationSeconds: data.durationSeconds.present
          ? data.durationSeconds.value
          : this.durationSeconds,
      configurationJson: data.configurationJson.present
          ? data.configurationJson.value
          : this.configurationJson,
      deviceManufacturer: data.deviceManufacturer.present
          ? data.deviceManufacturer.value
          : this.deviceManufacturer,
      deviceModel: data.deviceModel.present
          ? data.deviceModel.value
          : this.deviceModel,
      initialBatteryPercent: data.initialBatteryPercent.present
          ? data.initialBatteryPercent.value
          : this.initialBatteryPercent,
      initialBatteryTemperatureC: data.initialBatteryTemperatureC.present
          ? data.initialBatteryTemperatureC.value
          : this.initialBatteryTemperatureC,
      accelerometerSampleCount: data.accelerometerSampleCount.present
          ? data.accelerometerSampleCount.value
          : this.accelerometerSampleCount,
      gpsPointCount: data.gpsPointCount.present
          ? data.gpsPointCount.value
          : this.gpsPointCount,
      mediaCount: data.mediaCount.present
          ? data.mediaCount.value
          : this.mediaCount,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Run(')
          ..write('id: $id, ')
          ..write('recordedAt: $recordedAt, ')
          ..write('odometer: $odometer, ')
          ..write('isSynced: $isSynced, ')
          ..write('title: $title, ')
          ..write('distanceKm: $distanceKm, ')
          ..write('vehicleId: $vehicleId, ')
          ..write('notes: $notes, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('configurationJson: $configurationJson, ')
          ..write('deviceManufacturer: $deviceManufacturer, ')
          ..write('deviceModel: $deviceModel, ')
          ..write('initialBatteryPercent: $initialBatteryPercent, ')
          ..write('initialBatteryTemperatureC: $initialBatteryTemperatureC, ')
          ..write('accelerometerSampleCount: $accelerometerSampleCount, ')
          ..write('gpsPointCount: $gpsPointCount, ')
          ..write('mediaCount: $mediaCount')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    recordedAt,
    odometer,
    isSynced,
    title,
    distanceKm,
    vehicleId,
    notes,
    syncedAt,
    endedAt,
    durationSeconds,
    configurationJson,
    deviceManufacturer,
    deviceModel,
    initialBatteryPercent,
    initialBatteryTemperatureC,
    accelerometerSampleCount,
    gpsPointCount,
    mediaCount,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Run &&
          other.id == this.id &&
          other.recordedAt == this.recordedAt &&
          other.odometer == this.odometer &&
          other.isSynced == this.isSynced &&
          other.title == this.title &&
          other.distanceKm == this.distanceKm &&
          other.vehicleId == this.vehicleId &&
          other.notes == this.notes &&
          other.syncedAt == this.syncedAt &&
          other.endedAt == this.endedAt &&
          other.durationSeconds == this.durationSeconds &&
          other.configurationJson == this.configurationJson &&
          other.deviceManufacturer == this.deviceManufacturer &&
          other.deviceModel == this.deviceModel &&
          other.initialBatteryPercent == this.initialBatteryPercent &&
          other.initialBatteryTemperatureC == this.initialBatteryTemperatureC &&
          other.accelerometerSampleCount == this.accelerometerSampleCount &&
          other.gpsPointCount == this.gpsPointCount &&
          other.mediaCount == this.mediaCount);
}

class RunsTableCompanion extends UpdateCompanion<Run> {
  final Value<int> id;
  final Value<DateTime> recordedAt;
  final Value<double> odometer;
  final Value<bool> isSynced;
  final Value<String?> title;
  final Value<double> distanceKm;
  final Value<int?> vehicleId;
  final Value<String?> notes;
  final Value<DateTime?> syncedAt;
  final Value<DateTime?> endedAt;
  final Value<int> durationSeconds;
  final Value<String?> configurationJson;
  final Value<String?> deviceManufacturer;
  final Value<String?> deviceModel;
  final Value<int?> initialBatteryPercent;
  final Value<double?> initialBatteryTemperatureC;
  final Value<int> accelerometerSampleCount;
  final Value<int> gpsPointCount;
  final Value<int> mediaCount;
  const RunsTableCompanion({
    this.id = const Value.absent(),
    this.recordedAt = const Value.absent(),
    this.odometer = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.title = const Value.absent(),
    this.distanceKm = const Value.absent(),
    this.vehicleId = const Value.absent(),
    this.notes = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.endedAt = const Value.absent(),
    this.durationSeconds = const Value.absent(),
    this.configurationJson = const Value.absent(),
    this.deviceManufacturer = const Value.absent(),
    this.deviceModel = const Value.absent(),
    this.initialBatteryPercent = const Value.absent(),
    this.initialBatteryTemperatureC = const Value.absent(),
    this.accelerometerSampleCount = const Value.absent(),
    this.gpsPointCount = const Value.absent(),
    this.mediaCount = const Value.absent(),
  });
  RunsTableCompanion.insert({
    this.id = const Value.absent(),
    this.recordedAt = const Value.absent(),
    this.odometer = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.title = const Value.absent(),
    this.distanceKm = const Value.absent(),
    this.vehicleId = const Value.absent(),
    this.notes = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.endedAt = const Value.absent(),
    this.durationSeconds = const Value.absent(),
    this.configurationJson = const Value.absent(),
    this.deviceManufacturer = const Value.absent(),
    this.deviceModel = const Value.absent(),
    this.initialBatteryPercent = const Value.absent(),
    this.initialBatteryTemperatureC = const Value.absent(),
    this.accelerometerSampleCount = const Value.absent(),
    this.gpsPointCount = const Value.absent(),
    this.mediaCount = const Value.absent(),
  });
  static Insertable<Run> custom({
    Expression<int>? id,
    Expression<DateTime>? recordedAt,
    Expression<double>? odometer,
    Expression<bool>? isSynced,
    Expression<String>? title,
    Expression<double>? distanceKm,
    Expression<int>? vehicleId,
    Expression<String>? notes,
    Expression<DateTime>? syncedAt,
    Expression<DateTime>? endedAt,
    Expression<int>? durationSeconds,
    Expression<String>? configurationJson,
    Expression<String>? deviceManufacturer,
    Expression<String>? deviceModel,
    Expression<int>? initialBatteryPercent,
    Expression<double>? initialBatteryTemperatureC,
    Expression<int>? accelerometerSampleCount,
    Expression<int>? gpsPointCount,
    Expression<int>? mediaCount,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (recordedAt != null) 'recorded_at': recordedAt,
      if (odometer != null) 'odometer': odometer,
      if (isSynced != null) 'is_synced': isSynced,
      if (title != null) 'title': title,
      if (distanceKm != null) 'distance_km': distanceKm,
      if (vehicleId != null) 'vehicle_id': vehicleId,
      if (notes != null) 'notes': notes,
      if (syncedAt != null) 'synced_at': syncedAt,
      if (endedAt != null) 'ended_at': endedAt,
      if (durationSeconds != null) 'duration_seconds': durationSeconds,
      if (configurationJson != null) 'configuration_json': configurationJson,
      if (deviceManufacturer != null) 'device_manufacturer': deviceManufacturer,
      if (deviceModel != null) 'device_model': deviceModel,
      if (initialBatteryPercent != null)
        'initial_battery_percent': initialBatteryPercent,
      if (initialBatteryTemperatureC != null)
        'initial_battery_temperature_c': initialBatteryTemperatureC,
      if (accelerometerSampleCount != null)
        'accelerometer_sample_count': accelerometerSampleCount,
      if (gpsPointCount != null) 'gps_point_count': gpsPointCount,
      if (mediaCount != null) 'media_count': mediaCount,
    });
  }

  RunsTableCompanion copyWith({
    Value<int>? id,
    Value<DateTime>? recordedAt,
    Value<double>? odometer,
    Value<bool>? isSynced,
    Value<String?>? title,
    Value<double>? distanceKm,
    Value<int?>? vehicleId,
    Value<String?>? notes,
    Value<DateTime?>? syncedAt,
    Value<DateTime?>? endedAt,
    Value<int>? durationSeconds,
    Value<String?>? configurationJson,
    Value<String?>? deviceManufacturer,
    Value<String?>? deviceModel,
    Value<int?>? initialBatteryPercent,
    Value<double?>? initialBatteryTemperatureC,
    Value<int>? accelerometerSampleCount,
    Value<int>? gpsPointCount,
    Value<int>? mediaCount,
  }) {
    return RunsTableCompanion(
      id: id ?? this.id,
      recordedAt: recordedAt ?? this.recordedAt,
      odometer: odometer ?? this.odometer,
      isSynced: isSynced ?? this.isSynced,
      title: title ?? this.title,
      distanceKm: distanceKm ?? this.distanceKm,
      vehicleId: vehicleId ?? this.vehicleId,
      notes: notes ?? this.notes,
      syncedAt: syncedAt ?? this.syncedAt,
      endedAt: endedAt ?? this.endedAt,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      configurationJson: configurationJson ?? this.configurationJson,
      deviceManufacturer: deviceManufacturer ?? this.deviceManufacturer,
      deviceModel: deviceModel ?? this.deviceModel,
      initialBatteryPercent:
          initialBatteryPercent ?? this.initialBatteryPercent,
      initialBatteryTemperatureC:
          initialBatteryTemperatureC ?? this.initialBatteryTemperatureC,
      accelerometerSampleCount:
          accelerometerSampleCount ?? this.accelerometerSampleCount,
      gpsPointCount: gpsPointCount ?? this.gpsPointCount,
      mediaCount: mediaCount ?? this.mediaCount,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (recordedAt.present) {
      map['recorded_at'] = Variable<DateTime>(recordedAt.value);
    }
    if (odometer.present) {
      map['odometer'] = Variable<double>(odometer.value);
    }
    if (isSynced.present) {
      map['is_synced'] = Variable<bool>(isSynced.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (distanceKm.present) {
      map['distance_km'] = Variable<double>(distanceKm.value);
    }
    if (vehicleId.present) {
      map['vehicle_id'] = Variable<int>(vehicleId.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (syncedAt.present) {
      map['synced_at'] = Variable<DateTime>(syncedAt.value);
    }
    if (endedAt.present) {
      map['ended_at'] = Variable<DateTime>(endedAt.value);
    }
    if (durationSeconds.present) {
      map['duration_seconds'] = Variable<int>(durationSeconds.value);
    }
    if (configurationJson.present) {
      map['configuration_json'] = Variable<String>(configurationJson.value);
    }
    if (deviceManufacturer.present) {
      map['device_manufacturer'] = Variable<String>(deviceManufacturer.value);
    }
    if (deviceModel.present) {
      map['device_model'] = Variable<String>(deviceModel.value);
    }
    if (initialBatteryPercent.present) {
      map['initial_battery_percent'] = Variable<int>(
        initialBatteryPercent.value,
      );
    }
    if (initialBatteryTemperatureC.present) {
      map['initial_battery_temperature_c'] = Variable<double>(
        initialBatteryTemperatureC.value,
      );
    }
    if (accelerometerSampleCount.present) {
      map['accelerometer_sample_count'] = Variable<int>(
        accelerometerSampleCount.value,
      );
    }
    if (gpsPointCount.present) {
      map['gps_point_count'] = Variable<int>(gpsPointCount.value);
    }
    if (mediaCount.present) {
      map['media_count'] = Variable<int>(mediaCount.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RunsTableCompanion(')
          ..write('id: $id, ')
          ..write('recordedAt: $recordedAt, ')
          ..write('odometer: $odometer, ')
          ..write('isSynced: $isSynced, ')
          ..write('title: $title, ')
          ..write('distanceKm: $distanceKm, ')
          ..write('vehicleId: $vehicleId, ')
          ..write('notes: $notes, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('configurationJson: $configurationJson, ')
          ..write('deviceManufacturer: $deviceManufacturer, ')
          ..write('deviceModel: $deviceModel, ')
          ..write('initialBatteryPercent: $initialBatteryPercent, ')
          ..write('initialBatteryTemperatureC: $initialBatteryTemperatureC, ')
          ..write('accelerometerSampleCount: $accelerometerSampleCount, ')
          ..write('gpsPointCount: $gpsPointCount, ')
          ..write('mediaCount: $mediaCount')
          ..write(')'))
        .toString();
  }
}

class $SensorReadingsTableTable extends SensorReadingsTable
    with TableInfo<$SensorReadingsTableTable, SensorReading> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SensorReadingsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _runIdMeta = const VerificationMeta('runId');
  @override
  late final GeneratedColumn<int> runId = GeneratedColumn<int>(
    'run_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES runs_table (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _recordedAtMeta = const VerificationMeta(
    'recordedAt',
  );
  @override
  late final GeneratedColumn<DateTime> recordedAt = GeneratedColumn<DateTime>(
    'recorded_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _accelerometerXMeta = const VerificationMeta(
    'accelerometerX',
  );
  @override
  late final GeneratedColumn<double> accelerometerX = GeneratedColumn<double>(
    'accelerometer_x',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _accelerometerYMeta = const VerificationMeta(
    'accelerometerY',
  );
  @override
  late final GeneratedColumn<double> accelerometerY = GeneratedColumn<double>(
    'accelerometer_y',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _accelerometerZMeta = const VerificationMeta(
    'accelerometerZ',
  );
  @override
  late final GeneratedColumn<double> accelerometerZ = GeneratedColumn<double>(
    'accelerometer_z',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _gyroscopeXMeta = const VerificationMeta(
    'gyroscopeX',
  );
  @override
  late final GeneratedColumn<double> gyroscopeX = GeneratedColumn<double>(
    'gyroscope_x',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _gyroscopeYMeta = const VerificationMeta(
    'gyroscopeY',
  );
  @override
  late final GeneratedColumn<double> gyroscopeY = GeneratedColumn<double>(
    'gyroscope_y',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _gyroscopeZMeta = const VerificationMeta(
    'gyroscopeZ',
  );
  @override
  late final GeneratedColumn<double> gyroscopeZ = GeneratedColumn<double>(
    'gyroscope_z',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    runId,
    recordedAt,
    accelerometerX,
    accelerometerY,
    accelerometerZ,
    gyroscopeX,
    gyroscopeY,
    gyroscopeZ,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sensor_readings_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<SensorReading> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('run_id')) {
      context.handle(
        _runIdMeta,
        runId.isAcceptableOrUnknown(data['run_id']!, _runIdMeta),
      );
    } else if (isInserting) {
      context.missing(_runIdMeta);
    }
    if (data.containsKey('recorded_at')) {
      context.handle(
        _recordedAtMeta,
        recordedAt.isAcceptableOrUnknown(data['recorded_at']!, _recordedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_recordedAtMeta);
    }
    if (data.containsKey('accelerometer_x')) {
      context.handle(
        _accelerometerXMeta,
        accelerometerX.isAcceptableOrUnknown(
          data['accelerometer_x']!,
          _accelerometerXMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_accelerometerXMeta);
    }
    if (data.containsKey('accelerometer_y')) {
      context.handle(
        _accelerometerYMeta,
        accelerometerY.isAcceptableOrUnknown(
          data['accelerometer_y']!,
          _accelerometerYMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_accelerometerYMeta);
    }
    if (data.containsKey('accelerometer_z')) {
      context.handle(
        _accelerometerZMeta,
        accelerometerZ.isAcceptableOrUnknown(
          data['accelerometer_z']!,
          _accelerometerZMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_accelerometerZMeta);
    }
    if (data.containsKey('gyroscope_x')) {
      context.handle(
        _gyroscopeXMeta,
        gyroscopeX.isAcceptableOrUnknown(data['gyroscope_x']!, _gyroscopeXMeta),
      );
    }
    if (data.containsKey('gyroscope_y')) {
      context.handle(
        _gyroscopeYMeta,
        gyroscopeY.isAcceptableOrUnknown(data['gyroscope_y']!, _gyroscopeYMeta),
      );
    }
    if (data.containsKey('gyroscope_z')) {
      context.handle(
        _gyroscopeZMeta,
        gyroscopeZ.isAcceptableOrUnknown(data['gyroscope_z']!, _gyroscopeZMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SensorReading map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SensorReading(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      runId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}run_id'],
      )!,
      recordedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}recorded_at'],
      )!,
      accelerometerX: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}accelerometer_x'],
      )!,
      accelerometerY: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}accelerometer_y'],
      )!,
      accelerometerZ: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}accelerometer_z'],
      )!,
      gyroscopeX: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}gyroscope_x'],
      ),
      gyroscopeY: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}gyroscope_y'],
      ),
      gyroscopeZ: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}gyroscope_z'],
      ),
    );
  }

  @override
  $SensorReadingsTableTable createAlias(String alias) {
    return $SensorReadingsTableTable(attachedDatabase, alias);
  }
}

class SensorReading extends DataClass implements Insertable<SensorReading> {
  final int id;
  final int runId;
  final DateTime recordedAt;
  final double accelerometerX;
  final double accelerometerY;
  final double accelerometerZ;
  final double? gyroscopeX;
  final double? gyroscopeY;
  final double? gyroscopeZ;
  const SensorReading({
    required this.id,
    required this.runId,
    required this.recordedAt,
    required this.accelerometerX,
    required this.accelerometerY,
    required this.accelerometerZ,
    this.gyroscopeX,
    this.gyroscopeY,
    this.gyroscopeZ,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['run_id'] = Variable<int>(runId);
    map['recorded_at'] = Variable<DateTime>(recordedAt);
    map['accelerometer_x'] = Variable<double>(accelerometerX);
    map['accelerometer_y'] = Variable<double>(accelerometerY);
    map['accelerometer_z'] = Variable<double>(accelerometerZ);
    if (!nullToAbsent || gyroscopeX != null) {
      map['gyroscope_x'] = Variable<double>(gyroscopeX);
    }
    if (!nullToAbsent || gyroscopeY != null) {
      map['gyroscope_y'] = Variable<double>(gyroscopeY);
    }
    if (!nullToAbsent || gyroscopeZ != null) {
      map['gyroscope_z'] = Variable<double>(gyroscopeZ);
    }
    return map;
  }

  SensorReadingsTableCompanion toCompanion(bool nullToAbsent) {
    return SensorReadingsTableCompanion(
      id: Value(id),
      runId: Value(runId),
      recordedAt: Value(recordedAt),
      accelerometerX: Value(accelerometerX),
      accelerometerY: Value(accelerometerY),
      accelerometerZ: Value(accelerometerZ),
      gyroscopeX: gyroscopeX == null && nullToAbsent
          ? const Value.absent()
          : Value(gyroscopeX),
      gyroscopeY: gyroscopeY == null && nullToAbsent
          ? const Value.absent()
          : Value(gyroscopeY),
      gyroscopeZ: gyroscopeZ == null && nullToAbsent
          ? const Value.absent()
          : Value(gyroscopeZ),
    );
  }

  factory SensorReading.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SensorReading(
      id: serializer.fromJson<int>(json['id']),
      runId: serializer.fromJson<int>(json['runId']),
      recordedAt: serializer.fromJson<DateTime>(json['recordedAt']),
      accelerometerX: serializer.fromJson<double>(json['accelerometerX']),
      accelerometerY: serializer.fromJson<double>(json['accelerometerY']),
      accelerometerZ: serializer.fromJson<double>(json['accelerometerZ']),
      gyroscopeX: serializer.fromJson<double?>(json['gyroscopeX']),
      gyroscopeY: serializer.fromJson<double?>(json['gyroscopeY']),
      gyroscopeZ: serializer.fromJson<double?>(json['gyroscopeZ']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'runId': serializer.toJson<int>(runId),
      'recordedAt': serializer.toJson<DateTime>(recordedAt),
      'accelerometerX': serializer.toJson<double>(accelerometerX),
      'accelerometerY': serializer.toJson<double>(accelerometerY),
      'accelerometerZ': serializer.toJson<double>(accelerometerZ),
      'gyroscopeX': serializer.toJson<double?>(gyroscopeX),
      'gyroscopeY': serializer.toJson<double?>(gyroscopeY),
      'gyroscopeZ': serializer.toJson<double?>(gyroscopeZ),
    };
  }

  SensorReading copyWith({
    int? id,
    int? runId,
    DateTime? recordedAt,
    double? accelerometerX,
    double? accelerometerY,
    double? accelerometerZ,
    Value<double?> gyroscopeX = const Value.absent(),
    Value<double?> gyroscopeY = const Value.absent(),
    Value<double?> gyroscopeZ = const Value.absent(),
  }) => SensorReading(
    id: id ?? this.id,
    runId: runId ?? this.runId,
    recordedAt: recordedAt ?? this.recordedAt,
    accelerometerX: accelerometerX ?? this.accelerometerX,
    accelerometerY: accelerometerY ?? this.accelerometerY,
    accelerometerZ: accelerometerZ ?? this.accelerometerZ,
    gyroscopeX: gyroscopeX.present ? gyroscopeX.value : this.gyroscopeX,
    gyroscopeY: gyroscopeY.present ? gyroscopeY.value : this.gyroscopeY,
    gyroscopeZ: gyroscopeZ.present ? gyroscopeZ.value : this.gyroscopeZ,
  );
  SensorReading copyWithCompanion(SensorReadingsTableCompanion data) {
    return SensorReading(
      id: data.id.present ? data.id.value : this.id,
      runId: data.runId.present ? data.runId.value : this.runId,
      recordedAt: data.recordedAt.present
          ? data.recordedAt.value
          : this.recordedAt,
      accelerometerX: data.accelerometerX.present
          ? data.accelerometerX.value
          : this.accelerometerX,
      accelerometerY: data.accelerometerY.present
          ? data.accelerometerY.value
          : this.accelerometerY,
      accelerometerZ: data.accelerometerZ.present
          ? data.accelerometerZ.value
          : this.accelerometerZ,
      gyroscopeX: data.gyroscopeX.present
          ? data.gyroscopeX.value
          : this.gyroscopeX,
      gyroscopeY: data.gyroscopeY.present
          ? data.gyroscopeY.value
          : this.gyroscopeY,
      gyroscopeZ: data.gyroscopeZ.present
          ? data.gyroscopeZ.value
          : this.gyroscopeZ,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SensorReading(')
          ..write('id: $id, ')
          ..write('runId: $runId, ')
          ..write('recordedAt: $recordedAt, ')
          ..write('accelerometerX: $accelerometerX, ')
          ..write('accelerometerY: $accelerometerY, ')
          ..write('accelerometerZ: $accelerometerZ, ')
          ..write('gyroscopeX: $gyroscopeX, ')
          ..write('gyroscopeY: $gyroscopeY, ')
          ..write('gyroscopeZ: $gyroscopeZ')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    runId,
    recordedAt,
    accelerometerX,
    accelerometerY,
    accelerometerZ,
    gyroscopeX,
    gyroscopeY,
    gyroscopeZ,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SensorReading &&
          other.id == this.id &&
          other.runId == this.runId &&
          other.recordedAt == this.recordedAt &&
          other.accelerometerX == this.accelerometerX &&
          other.accelerometerY == this.accelerometerY &&
          other.accelerometerZ == this.accelerometerZ &&
          other.gyroscopeX == this.gyroscopeX &&
          other.gyroscopeY == this.gyroscopeY &&
          other.gyroscopeZ == this.gyroscopeZ);
}

class SensorReadingsTableCompanion extends UpdateCompanion<SensorReading> {
  final Value<int> id;
  final Value<int> runId;
  final Value<DateTime> recordedAt;
  final Value<double> accelerometerX;
  final Value<double> accelerometerY;
  final Value<double> accelerometerZ;
  final Value<double?> gyroscopeX;
  final Value<double?> gyroscopeY;
  final Value<double?> gyroscopeZ;
  const SensorReadingsTableCompanion({
    this.id = const Value.absent(),
    this.runId = const Value.absent(),
    this.recordedAt = const Value.absent(),
    this.accelerometerX = const Value.absent(),
    this.accelerometerY = const Value.absent(),
    this.accelerometerZ = const Value.absent(),
    this.gyroscopeX = const Value.absent(),
    this.gyroscopeY = const Value.absent(),
    this.gyroscopeZ = const Value.absent(),
  });
  SensorReadingsTableCompanion.insert({
    this.id = const Value.absent(),
    required int runId,
    required DateTime recordedAt,
    required double accelerometerX,
    required double accelerometerY,
    required double accelerometerZ,
    this.gyroscopeX = const Value.absent(),
    this.gyroscopeY = const Value.absent(),
    this.gyroscopeZ = const Value.absent(),
  }) : runId = Value(runId),
       recordedAt = Value(recordedAt),
       accelerometerX = Value(accelerometerX),
       accelerometerY = Value(accelerometerY),
       accelerometerZ = Value(accelerometerZ);
  static Insertable<SensorReading> custom({
    Expression<int>? id,
    Expression<int>? runId,
    Expression<DateTime>? recordedAt,
    Expression<double>? accelerometerX,
    Expression<double>? accelerometerY,
    Expression<double>? accelerometerZ,
    Expression<double>? gyroscopeX,
    Expression<double>? gyroscopeY,
    Expression<double>? gyroscopeZ,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (runId != null) 'run_id': runId,
      if (recordedAt != null) 'recorded_at': recordedAt,
      if (accelerometerX != null) 'accelerometer_x': accelerometerX,
      if (accelerometerY != null) 'accelerometer_y': accelerometerY,
      if (accelerometerZ != null) 'accelerometer_z': accelerometerZ,
      if (gyroscopeX != null) 'gyroscope_x': gyroscopeX,
      if (gyroscopeY != null) 'gyroscope_y': gyroscopeY,
      if (gyroscopeZ != null) 'gyroscope_z': gyroscopeZ,
    });
  }

  SensorReadingsTableCompanion copyWith({
    Value<int>? id,
    Value<int>? runId,
    Value<DateTime>? recordedAt,
    Value<double>? accelerometerX,
    Value<double>? accelerometerY,
    Value<double>? accelerometerZ,
    Value<double?>? gyroscopeX,
    Value<double?>? gyroscopeY,
    Value<double?>? gyroscopeZ,
  }) {
    return SensorReadingsTableCompanion(
      id: id ?? this.id,
      runId: runId ?? this.runId,
      recordedAt: recordedAt ?? this.recordedAt,
      accelerometerX: accelerometerX ?? this.accelerometerX,
      accelerometerY: accelerometerY ?? this.accelerometerY,
      accelerometerZ: accelerometerZ ?? this.accelerometerZ,
      gyroscopeX: gyroscopeX ?? this.gyroscopeX,
      gyroscopeY: gyroscopeY ?? this.gyroscopeY,
      gyroscopeZ: gyroscopeZ ?? this.gyroscopeZ,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (runId.present) {
      map['run_id'] = Variable<int>(runId.value);
    }
    if (recordedAt.present) {
      map['recorded_at'] = Variable<DateTime>(recordedAt.value);
    }
    if (accelerometerX.present) {
      map['accelerometer_x'] = Variable<double>(accelerometerX.value);
    }
    if (accelerometerY.present) {
      map['accelerometer_y'] = Variable<double>(accelerometerY.value);
    }
    if (accelerometerZ.present) {
      map['accelerometer_z'] = Variable<double>(accelerometerZ.value);
    }
    if (gyroscopeX.present) {
      map['gyroscope_x'] = Variable<double>(gyroscopeX.value);
    }
    if (gyroscopeY.present) {
      map['gyroscope_y'] = Variable<double>(gyroscopeY.value);
    }
    if (gyroscopeZ.present) {
      map['gyroscope_z'] = Variable<double>(gyroscopeZ.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SensorReadingsTableCompanion(')
          ..write('id: $id, ')
          ..write('runId: $runId, ')
          ..write('recordedAt: $recordedAt, ')
          ..write('accelerometerX: $accelerometerX, ')
          ..write('accelerometerY: $accelerometerY, ')
          ..write('accelerometerZ: $accelerometerZ, ')
          ..write('gyroscopeX: $gyroscopeX, ')
          ..write('gyroscopeY: $gyroscopeY, ')
          ..write('gyroscopeZ: $gyroscopeZ')
          ..write(')'))
        .toString();
  }
}

class $GpsPointsTableTable extends GpsPointsTable
    with TableInfo<$GpsPointsTableTable, GpsPoint> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GpsPointsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _runIdMeta = const VerificationMeta('runId');
  @override
  late final GeneratedColumn<int> runId = GeneratedColumn<int>(
    'run_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES runs_table (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _recordedAtMeta = const VerificationMeta(
    'recordedAt',
  );
  @override
  late final GeneratedColumn<DateTime> recordedAt = GeneratedColumn<DateTime>(
    'recorded_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _latitudeMeta = const VerificationMeta(
    'latitude',
  );
  @override
  late final GeneratedColumn<double> latitude = GeneratedColumn<double>(
    'latitude',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _longitudeMeta = const VerificationMeta(
    'longitude',
  );
  @override
  late final GeneratedColumn<double> longitude = GeneratedColumn<double>(
    'longitude',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _altitudeMetersMeta = const VerificationMeta(
    'altitudeMeters',
  );
  @override
  late final GeneratedColumn<double> altitudeMeters = GeneratedColumn<double>(
    'altitude_meters',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _speedMetersPerSecondMeta =
      const VerificationMeta('speedMetersPerSecond');
  @override
  late final GeneratedColumn<double> speedMetersPerSecond =
      GeneratedColumn<double>(
        'speed_meters_per_second',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _headingDegreesMeta = const VerificationMeta(
    'headingDegrees',
  );
  @override
  late final GeneratedColumn<double> headingDegrees = GeneratedColumn<double>(
    'heading_degrees',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _accuracyMetersMeta = const VerificationMeta(
    'accuracyMeters',
  );
  @override
  late final GeneratedColumn<double> accuracyMeters = GeneratedColumn<double>(
    'accuracy_meters',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    runId,
    recordedAt,
    latitude,
    longitude,
    altitudeMeters,
    speedMetersPerSecond,
    headingDegrees,
    accuracyMeters,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'gps_points_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<GpsPoint> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('run_id')) {
      context.handle(
        _runIdMeta,
        runId.isAcceptableOrUnknown(data['run_id']!, _runIdMeta),
      );
    } else if (isInserting) {
      context.missing(_runIdMeta);
    }
    if (data.containsKey('recorded_at')) {
      context.handle(
        _recordedAtMeta,
        recordedAt.isAcceptableOrUnknown(data['recorded_at']!, _recordedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_recordedAtMeta);
    }
    if (data.containsKey('latitude')) {
      context.handle(
        _latitudeMeta,
        latitude.isAcceptableOrUnknown(data['latitude']!, _latitudeMeta),
      );
    } else if (isInserting) {
      context.missing(_latitudeMeta);
    }
    if (data.containsKey('longitude')) {
      context.handle(
        _longitudeMeta,
        longitude.isAcceptableOrUnknown(data['longitude']!, _longitudeMeta),
      );
    } else if (isInserting) {
      context.missing(_longitudeMeta);
    }
    if (data.containsKey('altitude_meters')) {
      context.handle(
        _altitudeMetersMeta,
        altitudeMeters.isAcceptableOrUnknown(
          data['altitude_meters']!,
          _altitudeMetersMeta,
        ),
      );
    }
    if (data.containsKey('speed_meters_per_second')) {
      context.handle(
        _speedMetersPerSecondMeta,
        speedMetersPerSecond.isAcceptableOrUnknown(
          data['speed_meters_per_second']!,
          _speedMetersPerSecondMeta,
        ),
      );
    }
    if (data.containsKey('heading_degrees')) {
      context.handle(
        _headingDegreesMeta,
        headingDegrees.isAcceptableOrUnknown(
          data['heading_degrees']!,
          _headingDegreesMeta,
        ),
      );
    }
    if (data.containsKey('accuracy_meters')) {
      context.handle(
        _accuracyMetersMeta,
        accuracyMeters.isAcceptableOrUnknown(
          data['accuracy_meters']!,
          _accuracyMetersMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  GpsPoint map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GpsPoint(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      runId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}run_id'],
      )!,
      recordedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}recorded_at'],
      )!,
      latitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}latitude'],
      )!,
      longitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}longitude'],
      )!,
      altitudeMeters: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}altitude_meters'],
      ),
      speedMetersPerSecond: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}speed_meters_per_second'],
      ),
      headingDegrees: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}heading_degrees'],
      ),
      accuracyMeters: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}accuracy_meters'],
      ),
    );
  }

  @override
  $GpsPointsTableTable createAlias(String alias) {
    return $GpsPointsTableTable(attachedDatabase, alias);
  }
}

class GpsPoint extends DataClass implements Insertable<GpsPoint> {
  final int id;
  final int runId;
  final DateTime recordedAt;
  final double latitude;
  final double longitude;
  final double? altitudeMeters;
  final double? speedMetersPerSecond;
  final double? headingDegrees;
  final double? accuracyMeters;
  const GpsPoint({
    required this.id,
    required this.runId,
    required this.recordedAt,
    required this.latitude,
    required this.longitude,
    this.altitudeMeters,
    this.speedMetersPerSecond,
    this.headingDegrees,
    this.accuracyMeters,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['run_id'] = Variable<int>(runId);
    map['recorded_at'] = Variable<DateTime>(recordedAt);
    map['latitude'] = Variable<double>(latitude);
    map['longitude'] = Variable<double>(longitude);
    if (!nullToAbsent || altitudeMeters != null) {
      map['altitude_meters'] = Variable<double>(altitudeMeters);
    }
    if (!nullToAbsent || speedMetersPerSecond != null) {
      map['speed_meters_per_second'] = Variable<double>(speedMetersPerSecond);
    }
    if (!nullToAbsent || headingDegrees != null) {
      map['heading_degrees'] = Variable<double>(headingDegrees);
    }
    if (!nullToAbsent || accuracyMeters != null) {
      map['accuracy_meters'] = Variable<double>(accuracyMeters);
    }
    return map;
  }

  GpsPointsTableCompanion toCompanion(bool nullToAbsent) {
    return GpsPointsTableCompanion(
      id: Value(id),
      runId: Value(runId),
      recordedAt: Value(recordedAt),
      latitude: Value(latitude),
      longitude: Value(longitude),
      altitudeMeters: altitudeMeters == null && nullToAbsent
          ? const Value.absent()
          : Value(altitudeMeters),
      speedMetersPerSecond: speedMetersPerSecond == null && nullToAbsent
          ? const Value.absent()
          : Value(speedMetersPerSecond),
      headingDegrees: headingDegrees == null && nullToAbsent
          ? const Value.absent()
          : Value(headingDegrees),
      accuracyMeters: accuracyMeters == null && nullToAbsent
          ? const Value.absent()
          : Value(accuracyMeters),
    );
  }

  factory GpsPoint.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GpsPoint(
      id: serializer.fromJson<int>(json['id']),
      runId: serializer.fromJson<int>(json['runId']),
      recordedAt: serializer.fromJson<DateTime>(json['recordedAt']),
      latitude: serializer.fromJson<double>(json['latitude']),
      longitude: serializer.fromJson<double>(json['longitude']),
      altitudeMeters: serializer.fromJson<double?>(json['altitudeMeters']),
      speedMetersPerSecond: serializer.fromJson<double?>(
        json['speedMetersPerSecond'],
      ),
      headingDegrees: serializer.fromJson<double?>(json['headingDegrees']),
      accuracyMeters: serializer.fromJson<double?>(json['accuracyMeters']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'runId': serializer.toJson<int>(runId),
      'recordedAt': serializer.toJson<DateTime>(recordedAt),
      'latitude': serializer.toJson<double>(latitude),
      'longitude': serializer.toJson<double>(longitude),
      'altitudeMeters': serializer.toJson<double?>(altitudeMeters),
      'speedMetersPerSecond': serializer.toJson<double?>(speedMetersPerSecond),
      'headingDegrees': serializer.toJson<double?>(headingDegrees),
      'accuracyMeters': serializer.toJson<double?>(accuracyMeters),
    };
  }

  GpsPoint copyWith({
    int? id,
    int? runId,
    DateTime? recordedAt,
    double? latitude,
    double? longitude,
    Value<double?> altitudeMeters = const Value.absent(),
    Value<double?> speedMetersPerSecond = const Value.absent(),
    Value<double?> headingDegrees = const Value.absent(),
    Value<double?> accuracyMeters = const Value.absent(),
  }) => GpsPoint(
    id: id ?? this.id,
    runId: runId ?? this.runId,
    recordedAt: recordedAt ?? this.recordedAt,
    latitude: latitude ?? this.latitude,
    longitude: longitude ?? this.longitude,
    altitudeMeters: altitudeMeters.present
        ? altitudeMeters.value
        : this.altitudeMeters,
    speedMetersPerSecond: speedMetersPerSecond.present
        ? speedMetersPerSecond.value
        : this.speedMetersPerSecond,
    headingDegrees: headingDegrees.present
        ? headingDegrees.value
        : this.headingDegrees,
    accuracyMeters: accuracyMeters.present
        ? accuracyMeters.value
        : this.accuracyMeters,
  );
  GpsPoint copyWithCompanion(GpsPointsTableCompanion data) {
    return GpsPoint(
      id: data.id.present ? data.id.value : this.id,
      runId: data.runId.present ? data.runId.value : this.runId,
      recordedAt: data.recordedAt.present
          ? data.recordedAt.value
          : this.recordedAt,
      latitude: data.latitude.present ? data.latitude.value : this.latitude,
      longitude: data.longitude.present ? data.longitude.value : this.longitude,
      altitudeMeters: data.altitudeMeters.present
          ? data.altitudeMeters.value
          : this.altitudeMeters,
      speedMetersPerSecond: data.speedMetersPerSecond.present
          ? data.speedMetersPerSecond.value
          : this.speedMetersPerSecond,
      headingDegrees: data.headingDegrees.present
          ? data.headingDegrees.value
          : this.headingDegrees,
      accuracyMeters: data.accuracyMeters.present
          ? data.accuracyMeters.value
          : this.accuracyMeters,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GpsPoint(')
          ..write('id: $id, ')
          ..write('runId: $runId, ')
          ..write('recordedAt: $recordedAt, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('altitudeMeters: $altitudeMeters, ')
          ..write('speedMetersPerSecond: $speedMetersPerSecond, ')
          ..write('headingDegrees: $headingDegrees, ')
          ..write('accuracyMeters: $accuracyMeters')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    runId,
    recordedAt,
    latitude,
    longitude,
    altitudeMeters,
    speedMetersPerSecond,
    headingDegrees,
    accuracyMeters,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GpsPoint &&
          other.id == this.id &&
          other.runId == this.runId &&
          other.recordedAt == this.recordedAt &&
          other.latitude == this.latitude &&
          other.longitude == this.longitude &&
          other.altitudeMeters == this.altitudeMeters &&
          other.speedMetersPerSecond == this.speedMetersPerSecond &&
          other.headingDegrees == this.headingDegrees &&
          other.accuracyMeters == this.accuracyMeters);
}

class GpsPointsTableCompanion extends UpdateCompanion<GpsPoint> {
  final Value<int> id;
  final Value<int> runId;
  final Value<DateTime> recordedAt;
  final Value<double> latitude;
  final Value<double> longitude;
  final Value<double?> altitudeMeters;
  final Value<double?> speedMetersPerSecond;
  final Value<double?> headingDegrees;
  final Value<double?> accuracyMeters;
  const GpsPointsTableCompanion({
    this.id = const Value.absent(),
    this.runId = const Value.absent(),
    this.recordedAt = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.altitudeMeters = const Value.absent(),
    this.speedMetersPerSecond = const Value.absent(),
    this.headingDegrees = const Value.absent(),
    this.accuracyMeters = const Value.absent(),
  });
  GpsPointsTableCompanion.insert({
    this.id = const Value.absent(),
    required int runId,
    required DateTime recordedAt,
    required double latitude,
    required double longitude,
    this.altitudeMeters = const Value.absent(),
    this.speedMetersPerSecond = const Value.absent(),
    this.headingDegrees = const Value.absent(),
    this.accuracyMeters = const Value.absent(),
  }) : runId = Value(runId),
       recordedAt = Value(recordedAt),
       latitude = Value(latitude),
       longitude = Value(longitude);
  static Insertable<GpsPoint> custom({
    Expression<int>? id,
    Expression<int>? runId,
    Expression<DateTime>? recordedAt,
    Expression<double>? latitude,
    Expression<double>? longitude,
    Expression<double>? altitudeMeters,
    Expression<double>? speedMetersPerSecond,
    Expression<double>? headingDegrees,
    Expression<double>? accuracyMeters,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (runId != null) 'run_id': runId,
      if (recordedAt != null) 'recorded_at': recordedAt,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (altitudeMeters != null) 'altitude_meters': altitudeMeters,
      if (speedMetersPerSecond != null)
        'speed_meters_per_second': speedMetersPerSecond,
      if (headingDegrees != null) 'heading_degrees': headingDegrees,
      if (accuracyMeters != null) 'accuracy_meters': accuracyMeters,
    });
  }

  GpsPointsTableCompanion copyWith({
    Value<int>? id,
    Value<int>? runId,
    Value<DateTime>? recordedAt,
    Value<double>? latitude,
    Value<double>? longitude,
    Value<double?>? altitudeMeters,
    Value<double?>? speedMetersPerSecond,
    Value<double?>? headingDegrees,
    Value<double?>? accuracyMeters,
  }) {
    return GpsPointsTableCompanion(
      id: id ?? this.id,
      runId: runId ?? this.runId,
      recordedAt: recordedAt ?? this.recordedAt,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      altitudeMeters: altitudeMeters ?? this.altitudeMeters,
      speedMetersPerSecond: speedMetersPerSecond ?? this.speedMetersPerSecond,
      headingDegrees: headingDegrees ?? this.headingDegrees,
      accuracyMeters: accuracyMeters ?? this.accuracyMeters,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (runId.present) {
      map['run_id'] = Variable<int>(runId.value);
    }
    if (recordedAt.present) {
      map['recorded_at'] = Variable<DateTime>(recordedAt.value);
    }
    if (latitude.present) {
      map['latitude'] = Variable<double>(latitude.value);
    }
    if (longitude.present) {
      map['longitude'] = Variable<double>(longitude.value);
    }
    if (altitudeMeters.present) {
      map['altitude_meters'] = Variable<double>(altitudeMeters.value);
    }
    if (speedMetersPerSecond.present) {
      map['speed_meters_per_second'] = Variable<double>(
        speedMetersPerSecond.value,
      );
    }
    if (headingDegrees.present) {
      map['heading_degrees'] = Variable<double>(headingDegrees.value);
    }
    if (accuracyMeters.present) {
      map['accuracy_meters'] = Variable<double>(accuracyMeters.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GpsPointsTableCompanion(')
          ..write('id: $id, ')
          ..write('runId: $runId, ')
          ..write('recordedAt: $recordedAt, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('altitudeMeters: $altitudeMeters, ')
          ..write('speedMetersPerSecond: $speedMetersPerSecond, ')
          ..write('headingDegrees: $headingDegrees, ')
          ..write('accuracyMeters: $accuracyMeters')
          ..write(')'))
        .toString();
  }
}

class $MediaRecordsTableTable extends MediaRecordsTable
    with TableInfo<$MediaRecordsTableTable, MediaRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MediaRecordsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _runIdMeta = const VerificationMeta('runId');
  @override
  late final GeneratedColumn<int> runId = GeneratedColumn<int>(
    'run_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES runs_table (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _mediaTypeMeta = const VerificationMeta(
    'mediaType',
  );
  @override
  late final GeneratedColumn<String> mediaType = GeneratedColumn<String>(
    'media_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _filePathMeta = const VerificationMeta(
    'filePath',
  );
  @override
  late final GeneratedColumn<String> filePath = GeneratedColumn<String>(
    'file_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _recordedAtMeta = const VerificationMeta(
    'recordedAt',
  );
  @override
  late final GeneratedColumn<DateTime> recordedAt = GeneratedColumn<DateTime>(
    'recorded_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _latitudeMeta = const VerificationMeta(
    'latitude',
  );
  @override
  late final GeneratedColumn<double> latitude = GeneratedColumn<double>(
    'latitude',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _longitudeMeta = const VerificationMeta(
    'longitude',
  );
  @override
  late final GeneratedColumn<double> longitude = GeneratedColumn<double>(
    'longitude',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    runId,
    mediaType,
    filePath,
    recordedAt,
    latitude,
    longitude,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'media_records_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<MediaRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('run_id')) {
      context.handle(
        _runIdMeta,
        runId.isAcceptableOrUnknown(data['run_id']!, _runIdMeta),
      );
    } else if (isInserting) {
      context.missing(_runIdMeta);
    }
    if (data.containsKey('media_type')) {
      context.handle(
        _mediaTypeMeta,
        mediaType.isAcceptableOrUnknown(data['media_type']!, _mediaTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_mediaTypeMeta);
    }
    if (data.containsKey('file_path')) {
      context.handle(
        _filePathMeta,
        filePath.isAcceptableOrUnknown(data['file_path']!, _filePathMeta),
      );
    } else if (isInserting) {
      context.missing(_filePathMeta);
    }
    if (data.containsKey('recorded_at')) {
      context.handle(
        _recordedAtMeta,
        recordedAt.isAcceptableOrUnknown(data['recorded_at']!, _recordedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_recordedAtMeta);
    }
    if (data.containsKey('latitude')) {
      context.handle(
        _latitudeMeta,
        latitude.isAcceptableOrUnknown(data['latitude']!, _latitudeMeta),
      );
    }
    if (data.containsKey('longitude')) {
      context.handle(
        _longitudeMeta,
        longitude.isAcceptableOrUnknown(data['longitude']!, _longitudeMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MediaRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MediaRecord(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      runId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}run_id'],
      )!,
      mediaType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}media_type'],
      )!,
      filePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}file_path'],
      )!,
      recordedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}recorded_at'],
      )!,
      latitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}latitude'],
      ),
      longitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}longitude'],
      ),
    );
  }

  @override
  $MediaRecordsTableTable createAlias(String alias) {
    return $MediaRecordsTableTable(attachedDatabase, alias);
  }
}

class MediaRecord extends DataClass implements Insertable<MediaRecord> {
  final int id;
  final int runId;
  final String mediaType;
  final String filePath;
  final DateTime recordedAt;
  final double? latitude;
  final double? longitude;
  const MediaRecord({
    required this.id,
    required this.runId,
    required this.mediaType,
    required this.filePath,
    required this.recordedAt,
    this.latitude,
    this.longitude,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['run_id'] = Variable<int>(runId);
    map['media_type'] = Variable<String>(mediaType);
    map['file_path'] = Variable<String>(filePath);
    map['recorded_at'] = Variable<DateTime>(recordedAt);
    if (!nullToAbsent || latitude != null) {
      map['latitude'] = Variable<double>(latitude);
    }
    if (!nullToAbsent || longitude != null) {
      map['longitude'] = Variable<double>(longitude);
    }
    return map;
  }

  MediaRecordsTableCompanion toCompanion(bool nullToAbsent) {
    return MediaRecordsTableCompanion(
      id: Value(id),
      runId: Value(runId),
      mediaType: Value(mediaType),
      filePath: Value(filePath),
      recordedAt: Value(recordedAt),
      latitude: latitude == null && nullToAbsent
          ? const Value.absent()
          : Value(latitude),
      longitude: longitude == null && nullToAbsent
          ? const Value.absent()
          : Value(longitude),
    );
  }

  factory MediaRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MediaRecord(
      id: serializer.fromJson<int>(json['id']),
      runId: serializer.fromJson<int>(json['runId']),
      mediaType: serializer.fromJson<String>(json['mediaType']),
      filePath: serializer.fromJson<String>(json['filePath']),
      recordedAt: serializer.fromJson<DateTime>(json['recordedAt']),
      latitude: serializer.fromJson<double?>(json['latitude']),
      longitude: serializer.fromJson<double?>(json['longitude']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'runId': serializer.toJson<int>(runId),
      'mediaType': serializer.toJson<String>(mediaType),
      'filePath': serializer.toJson<String>(filePath),
      'recordedAt': serializer.toJson<DateTime>(recordedAt),
      'latitude': serializer.toJson<double?>(latitude),
      'longitude': serializer.toJson<double?>(longitude),
    };
  }

  MediaRecord copyWith({
    int? id,
    int? runId,
    String? mediaType,
    String? filePath,
    DateTime? recordedAt,
    Value<double?> latitude = const Value.absent(),
    Value<double?> longitude = const Value.absent(),
  }) => MediaRecord(
    id: id ?? this.id,
    runId: runId ?? this.runId,
    mediaType: mediaType ?? this.mediaType,
    filePath: filePath ?? this.filePath,
    recordedAt: recordedAt ?? this.recordedAt,
    latitude: latitude.present ? latitude.value : this.latitude,
    longitude: longitude.present ? longitude.value : this.longitude,
  );
  MediaRecord copyWithCompanion(MediaRecordsTableCompanion data) {
    return MediaRecord(
      id: data.id.present ? data.id.value : this.id,
      runId: data.runId.present ? data.runId.value : this.runId,
      mediaType: data.mediaType.present ? data.mediaType.value : this.mediaType,
      filePath: data.filePath.present ? data.filePath.value : this.filePath,
      recordedAt: data.recordedAt.present
          ? data.recordedAt.value
          : this.recordedAt,
      latitude: data.latitude.present ? data.latitude.value : this.latitude,
      longitude: data.longitude.present ? data.longitude.value : this.longitude,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MediaRecord(')
          ..write('id: $id, ')
          ..write('runId: $runId, ')
          ..write('mediaType: $mediaType, ')
          ..write('filePath: $filePath, ')
          ..write('recordedAt: $recordedAt, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    runId,
    mediaType,
    filePath,
    recordedAt,
    latitude,
    longitude,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MediaRecord &&
          other.id == this.id &&
          other.runId == this.runId &&
          other.mediaType == this.mediaType &&
          other.filePath == this.filePath &&
          other.recordedAt == this.recordedAt &&
          other.latitude == this.latitude &&
          other.longitude == this.longitude);
}

class MediaRecordsTableCompanion extends UpdateCompanion<MediaRecord> {
  final Value<int> id;
  final Value<int> runId;
  final Value<String> mediaType;
  final Value<String> filePath;
  final Value<DateTime> recordedAt;
  final Value<double?> latitude;
  final Value<double?> longitude;
  const MediaRecordsTableCompanion({
    this.id = const Value.absent(),
    this.runId = const Value.absent(),
    this.mediaType = const Value.absent(),
    this.filePath = const Value.absent(),
    this.recordedAt = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
  });
  MediaRecordsTableCompanion.insert({
    this.id = const Value.absent(),
    required int runId,
    required String mediaType,
    required String filePath,
    required DateTime recordedAt,
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
  }) : runId = Value(runId),
       mediaType = Value(mediaType),
       filePath = Value(filePath),
       recordedAt = Value(recordedAt);
  static Insertable<MediaRecord> custom({
    Expression<int>? id,
    Expression<int>? runId,
    Expression<String>? mediaType,
    Expression<String>? filePath,
    Expression<DateTime>? recordedAt,
    Expression<double>? latitude,
    Expression<double>? longitude,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (runId != null) 'run_id': runId,
      if (mediaType != null) 'media_type': mediaType,
      if (filePath != null) 'file_path': filePath,
      if (recordedAt != null) 'recorded_at': recordedAt,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
    });
  }

  MediaRecordsTableCompanion copyWith({
    Value<int>? id,
    Value<int>? runId,
    Value<String>? mediaType,
    Value<String>? filePath,
    Value<DateTime>? recordedAt,
    Value<double?>? latitude,
    Value<double?>? longitude,
  }) {
    return MediaRecordsTableCompanion(
      id: id ?? this.id,
      runId: runId ?? this.runId,
      mediaType: mediaType ?? this.mediaType,
      filePath: filePath ?? this.filePath,
      recordedAt: recordedAt ?? this.recordedAt,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (runId.present) {
      map['run_id'] = Variable<int>(runId.value);
    }
    if (mediaType.present) {
      map['media_type'] = Variable<String>(mediaType.value);
    }
    if (filePath.present) {
      map['file_path'] = Variable<String>(filePath.value);
    }
    if (recordedAt.present) {
      map['recorded_at'] = Variable<DateTime>(recordedAt.value);
    }
    if (latitude.present) {
      map['latitude'] = Variable<double>(latitude.value);
    }
    if (longitude.present) {
      map['longitude'] = Variable<double>(longitude.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MediaRecordsTableCompanion(')
          ..write('id: $id, ')
          ..write('runId: $runId, ')
          ..write('mediaType: $mediaType, ')
          ..write('filePath: $filePath, ')
          ..write('recordedAt: $recordedAt, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $VehiclesTable vehicles = $VehiclesTable(this);
  late final $RunsTableTable runsTable = $RunsTableTable(this);
  late final $SensorReadingsTableTable sensorReadingsTable =
      $SensorReadingsTableTable(this);
  late final $GpsPointsTableTable gpsPointsTable = $GpsPointsTableTable(this);
  late final $MediaRecordsTableTable mediaRecordsTable =
      $MediaRecordsTableTable(this);
  late final VehicleDao vehicleDao = VehicleDao(this as AppDatabase);
  late final RunDao runDao = RunDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    vehicles,
    runsTable,
    sensorReadingsTable,
    gpsPointsTable,
    mediaRecordsTable,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'runs_table',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('sensor_readings_table', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'runs_table',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('gps_points_table', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'runs_table',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('media_records_table', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$VehiclesTableCreateCompanionBuilder =
    VehiclesCompanion Function({
      Value<int> id,
      required String name,
      required String model,
      required String licensePlate,
      required double defaultOdometer,
      required int year,
      Value<String?> description,
      Value<String?> traction,
      Value<bool> isActive,
      Value<DateTime> createdAt,
      Value<DateTime?> updatedAt,
    });
typedef $$VehiclesTableUpdateCompanionBuilder =
    VehiclesCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String> model,
      Value<String> licensePlate,
      Value<double> defaultOdometer,
      Value<int> year,
      Value<String?> description,
      Value<String?> traction,
      Value<bool> isActive,
      Value<DateTime> createdAt,
      Value<DateTime?> updatedAt,
    });

final class $$VehiclesTableReferences
    extends BaseReferences<_$AppDatabase, $VehiclesTable, Vehicle> {
  $$VehiclesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$RunsTableTable, List<Run>> _runsTableRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.runsTable,
    aliasName: 'vehicles__id__runs_table__vehicle_id',
  );

  $$RunsTableTableProcessedTableManager get runsTableRefs {
    final manager = $$RunsTableTableTableManager(
      $_db,
      $_db.runsTable,
    ).filter((f) => f.vehicleId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_runsTableRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$VehiclesTableFilterComposer
    extends Composer<_$AppDatabase, $VehiclesTable> {
  $$VehiclesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get model => $composableBuilder(
    column: $table.model,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get licensePlate => $composableBuilder(
    column: $table.licensePlate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get defaultOdometer => $composableBuilder(
    column: $table.defaultOdometer,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get year => $composableBuilder(
    column: $table.year,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get traction => $composableBuilder(
    column: $table.traction,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> runsTableRefs(
    Expression<bool> Function($$RunsTableTableFilterComposer f) f,
  ) {
    final $$RunsTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.runsTable,
      getReferencedColumn: (t) => t.vehicleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RunsTableTableFilterComposer(
            $db: $db,
            $table: $db.runsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$VehiclesTableOrderingComposer
    extends Composer<_$AppDatabase, $VehiclesTable> {
  $$VehiclesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get model => $composableBuilder(
    column: $table.model,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get licensePlate => $composableBuilder(
    column: $table.licensePlate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get defaultOdometer => $composableBuilder(
    column: $table.defaultOdometer,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get year => $composableBuilder(
    column: $table.year,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get traction => $composableBuilder(
    column: $table.traction,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$VehiclesTableAnnotationComposer
    extends Composer<_$AppDatabase, $VehiclesTable> {
  $$VehiclesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get model =>
      $composableBuilder(column: $table.model, builder: (column) => column);

  GeneratedColumn<String> get licensePlate => $composableBuilder(
    column: $table.licensePlate,
    builder: (column) => column,
  );

  GeneratedColumn<double> get defaultOdometer => $composableBuilder(
    column: $table.defaultOdometer,
    builder: (column) => column,
  );

  GeneratedColumn<int> get year =>
      $composableBuilder(column: $table.year, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get traction =>
      $composableBuilder(column: $table.traction, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> runsTableRefs<T extends Object>(
    Expression<T> Function($$RunsTableTableAnnotationComposer a) f,
  ) {
    final $$RunsTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.runsTable,
      getReferencedColumn: (t) => t.vehicleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RunsTableTableAnnotationComposer(
            $db: $db,
            $table: $db.runsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$VehiclesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $VehiclesTable,
          Vehicle,
          $$VehiclesTableFilterComposer,
          $$VehiclesTableOrderingComposer,
          $$VehiclesTableAnnotationComposer,
          $$VehiclesTableCreateCompanionBuilder,
          $$VehiclesTableUpdateCompanionBuilder,
          (Vehicle, $$VehiclesTableReferences),
          Vehicle,
          PrefetchHooks Function({bool runsTableRefs})
        > {
  $$VehiclesTableTableManager(_$AppDatabase db, $VehiclesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VehiclesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$VehiclesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$VehiclesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> model = const Value.absent(),
                Value<String> licensePlate = const Value.absent(),
                Value<double> defaultOdometer = const Value.absent(),
                Value<int> year = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String?> traction = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
              }) => VehiclesCompanion(
                id: id,
                name: name,
                model: model,
                licensePlate: licensePlate,
                defaultOdometer: defaultOdometer,
                year: year,
                description: description,
                traction: traction,
                isActive: isActive,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required String model,
                required String licensePlate,
                required double defaultOdometer,
                required int year,
                Value<String?> description = const Value.absent(),
                Value<String?> traction = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
              }) => VehiclesCompanion.insert(
                id: id,
                name: name,
                model: model,
                licensePlate: licensePlate,
                defaultOdometer: defaultOdometer,
                year: year,
                description: description,
                traction: traction,
                isActive: isActive,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$VehiclesTable, Vehicle>(table),
                  $$VehiclesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({runsTableRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (runsTableRefs) db.runsTable],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (runsTableRefs)
                    await $_getPrefetchedData<Vehicle, $VehiclesTable, Run>(
                      currentTable: table,
                      referencedTable: $$VehiclesTableReferences
                          ._runsTableRefsTable(db),
                      managerFromTypedResult: (p0) => $$VehiclesTableReferences(
                        db,
                        table,
                        p0,
                      ).runsTableRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.vehicleId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$VehiclesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $VehiclesTable,
      Vehicle,
      $$VehiclesTableFilterComposer,
      $$VehiclesTableOrderingComposer,
      $$VehiclesTableAnnotationComposer,
      $$VehiclesTableCreateCompanionBuilder,
      $$VehiclesTableUpdateCompanionBuilder,
      (Vehicle, $$VehiclesTableReferences),
      Vehicle,
      PrefetchHooks Function({bool runsTableRefs})
    >;
typedef $$RunsTableTableCreateCompanionBuilder =
    RunsTableCompanion Function({
      Value<int> id,
      Value<DateTime> recordedAt,
      Value<double> odometer,
      Value<bool> isSynced,
      Value<String?> title,
      Value<double> distanceKm,
      Value<int?> vehicleId,
      Value<String?> notes,
      Value<DateTime?> syncedAt,
      Value<DateTime?> endedAt,
      Value<int> durationSeconds,
      Value<String?> configurationJson,
      Value<String?> deviceManufacturer,
      Value<String?> deviceModel,
      Value<int?> initialBatteryPercent,
      Value<double?> initialBatteryTemperatureC,
      Value<int> accelerometerSampleCount,
      Value<int> gpsPointCount,
      Value<int> mediaCount,
    });
typedef $$RunsTableTableUpdateCompanionBuilder =
    RunsTableCompanion Function({
      Value<int> id,
      Value<DateTime> recordedAt,
      Value<double> odometer,
      Value<bool> isSynced,
      Value<String?> title,
      Value<double> distanceKm,
      Value<int?> vehicleId,
      Value<String?> notes,
      Value<DateTime?> syncedAt,
      Value<DateTime?> endedAt,
      Value<int> durationSeconds,
      Value<String?> configurationJson,
      Value<String?> deviceManufacturer,
      Value<String?> deviceModel,
      Value<int?> initialBatteryPercent,
      Value<double?> initialBatteryTemperatureC,
      Value<int> accelerometerSampleCount,
      Value<int> gpsPointCount,
      Value<int> mediaCount,
    });

final class $$RunsTableTableReferences
    extends BaseReferences<_$AppDatabase, $RunsTableTable, Run> {
  $$RunsTableTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $VehiclesTable _vehicleIdTable(_$AppDatabase db) =>
      db.vehicles.createAlias('runs_table__vehicle_id__vehicles__id');

  $$VehiclesTableProcessedTableManager? get vehicleId {
    final $_column = $_itemColumn<int>('vehicle_id');
    if ($_column == null) return null;
    final manager = $$VehiclesTableTableManager(
      $_db,
      $_db.vehicles,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_vehicleIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$SensorReadingsTableTable, List<SensorReading>>
  _sensorReadingsTableRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.sensorReadingsTable,
        aliasName: 'runs_table__id__sensor_readings_table__run_id',
      );

  $$SensorReadingsTableTableProcessedTableManager get sensorReadingsTableRefs {
    final manager = $$SensorReadingsTableTableTableManager(
      $_db,
      $_db.sensorReadingsTable,
    ).filter((f) => f.runId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _sensorReadingsTableRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$GpsPointsTableTable, List<GpsPoint>>
  _gpsPointsTableRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.gpsPointsTable,
    aliasName: 'runs_table__id__gps_points_table__run_id',
  );

  $$GpsPointsTableTableProcessedTableManager get gpsPointsTableRefs {
    final manager = $$GpsPointsTableTableTableManager(
      $_db,
      $_db.gpsPointsTable,
    ).filter((f) => f.runId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_gpsPointsTableRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$MediaRecordsTableTable, List<MediaRecord>>
  _mediaRecordsTableRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.mediaRecordsTable,
        aliasName: 'runs_table__id__media_records_table__run_id',
      );

  $$MediaRecordsTableTableProcessedTableManager get mediaRecordsTableRefs {
    final manager = $$MediaRecordsTableTableTableManager(
      $_db,
      $_db.mediaRecordsTable,
    ).filter((f) => f.runId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _mediaRecordsTableRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$RunsTableTableFilterComposer
    extends Composer<_$AppDatabase, $RunsTableTable> {
  $$RunsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get recordedAt => $composableBuilder(
    column: $table.recordedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get odometer => $composableBuilder(
    column: $table.odometer,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get distanceKm => $composableBuilder(
    column: $table.distanceKm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get configurationJson => $composableBuilder(
    column: $table.configurationJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceManufacturer => $composableBuilder(
    column: $table.deviceManufacturer,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceModel => $composableBuilder(
    column: $table.deviceModel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get initialBatteryPercent => $composableBuilder(
    column: $table.initialBatteryPercent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get initialBatteryTemperatureC => $composableBuilder(
    column: $table.initialBatteryTemperatureC,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get accelerometerSampleCount => $composableBuilder(
    column: $table.accelerometerSampleCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get gpsPointCount => $composableBuilder(
    column: $table.gpsPointCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get mediaCount => $composableBuilder(
    column: $table.mediaCount,
    builder: (column) => ColumnFilters(column),
  );

  $$VehiclesTableFilterComposer get vehicleId {
    final $$VehiclesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.vehicleId,
      referencedTable: $db.vehicles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VehiclesTableFilterComposer(
            $db: $db,
            $table: $db.vehicles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> sensorReadingsTableRefs(
    Expression<bool> Function($$SensorReadingsTableTableFilterComposer f) f,
  ) {
    final $$SensorReadingsTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.sensorReadingsTable,
      getReferencedColumn: (t) => t.runId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SensorReadingsTableTableFilterComposer(
            $db: $db,
            $table: $db.sensorReadingsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> gpsPointsTableRefs(
    Expression<bool> Function($$GpsPointsTableTableFilterComposer f) f,
  ) {
    final $$GpsPointsTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.gpsPointsTable,
      getReferencedColumn: (t) => t.runId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GpsPointsTableTableFilterComposer(
            $db: $db,
            $table: $db.gpsPointsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> mediaRecordsTableRefs(
    Expression<bool> Function($$MediaRecordsTableTableFilterComposer f) f,
  ) {
    final $$MediaRecordsTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.mediaRecordsTable,
      getReferencedColumn: (t) => t.runId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MediaRecordsTableTableFilterComposer(
            $db: $db,
            $table: $db.mediaRecordsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$RunsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $RunsTableTable> {
  $$RunsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get recordedAt => $composableBuilder(
    column: $table.recordedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get odometer => $composableBuilder(
    column: $table.odometer,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get distanceKm => $composableBuilder(
    column: $table.distanceKm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get configurationJson => $composableBuilder(
    column: $table.configurationJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceManufacturer => $composableBuilder(
    column: $table.deviceManufacturer,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceModel => $composableBuilder(
    column: $table.deviceModel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get initialBatteryPercent => $composableBuilder(
    column: $table.initialBatteryPercent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get initialBatteryTemperatureC => $composableBuilder(
    column: $table.initialBatteryTemperatureC,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get accelerometerSampleCount => $composableBuilder(
    column: $table.accelerometerSampleCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get gpsPointCount => $composableBuilder(
    column: $table.gpsPointCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get mediaCount => $composableBuilder(
    column: $table.mediaCount,
    builder: (column) => ColumnOrderings(column),
  );

  $$VehiclesTableOrderingComposer get vehicleId {
    final $$VehiclesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.vehicleId,
      referencedTable: $db.vehicles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VehiclesTableOrderingComposer(
            $db: $db,
            $table: $db.vehicles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RunsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $RunsTableTable> {
  $$RunsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get recordedAt => $composableBuilder(
    column: $table.recordedAt,
    builder: (column) => column,
  );

  GeneratedColumn<double> get odometer =>
      $composableBuilder(column: $table.odometer, builder: (column) => column);

  GeneratedColumn<bool> get isSynced =>
      $composableBuilder(column: $table.isSynced, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<double> get distanceKm => $composableBuilder(
    column: $table.distanceKm,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get syncedAt =>
      $composableBuilder(column: $table.syncedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get endedAt =>
      $composableBuilder(column: $table.endedAt, builder: (column) => column);

  GeneratedColumn<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<String> get configurationJson => $composableBuilder(
    column: $table.configurationJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get deviceManufacturer => $composableBuilder(
    column: $table.deviceManufacturer,
    builder: (column) => column,
  );

  GeneratedColumn<String> get deviceModel => $composableBuilder(
    column: $table.deviceModel,
    builder: (column) => column,
  );

  GeneratedColumn<int> get initialBatteryPercent => $composableBuilder(
    column: $table.initialBatteryPercent,
    builder: (column) => column,
  );

  GeneratedColumn<double> get initialBatteryTemperatureC => $composableBuilder(
    column: $table.initialBatteryTemperatureC,
    builder: (column) => column,
  );

  GeneratedColumn<int> get accelerometerSampleCount => $composableBuilder(
    column: $table.accelerometerSampleCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get gpsPointCount => $composableBuilder(
    column: $table.gpsPointCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get mediaCount => $composableBuilder(
    column: $table.mediaCount,
    builder: (column) => column,
  );

  $$VehiclesTableAnnotationComposer get vehicleId {
    final $$VehiclesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.vehicleId,
      referencedTable: $db.vehicles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VehiclesTableAnnotationComposer(
            $db: $db,
            $table: $db.vehicles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> sensorReadingsTableRefs<T extends Object>(
    Expression<T> Function($$SensorReadingsTableTableAnnotationComposer a) f,
  ) {
    final $$SensorReadingsTableTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.sensorReadingsTable,
          getReferencedColumn: (t) => t.runId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$SensorReadingsTableTableAnnotationComposer(
                $db: $db,
                $table: $db.sensorReadingsTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> gpsPointsTableRefs<T extends Object>(
    Expression<T> Function($$GpsPointsTableTableAnnotationComposer a) f,
  ) {
    final $$GpsPointsTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.gpsPointsTable,
      getReferencedColumn: (t) => t.runId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GpsPointsTableTableAnnotationComposer(
            $db: $db,
            $table: $db.gpsPointsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> mediaRecordsTableRefs<T extends Object>(
    Expression<T> Function($$MediaRecordsTableTableAnnotationComposer a) f,
  ) {
    final $$MediaRecordsTableTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.mediaRecordsTable,
          getReferencedColumn: (t) => t.runId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$MediaRecordsTableTableAnnotationComposer(
                $db: $db,
                $table: $db.mediaRecordsTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$RunsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RunsTableTable,
          Run,
          $$RunsTableTableFilterComposer,
          $$RunsTableTableOrderingComposer,
          $$RunsTableTableAnnotationComposer,
          $$RunsTableTableCreateCompanionBuilder,
          $$RunsTableTableUpdateCompanionBuilder,
          (Run, $$RunsTableTableReferences),
          Run,
          PrefetchHooks Function({
            bool vehicleId,
            bool sensorReadingsTableRefs,
            bool gpsPointsTableRefs,
            bool mediaRecordsTableRefs,
          })
        > {
  $$RunsTableTableTableManager(_$AppDatabase db, $RunsTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RunsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RunsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RunsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> recordedAt = const Value.absent(),
                Value<double> odometer = const Value.absent(),
                Value<bool> isSynced = const Value.absent(),
                Value<String?> title = const Value.absent(),
                Value<double> distanceKm = const Value.absent(),
                Value<int?> vehicleId = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime?> syncedAt = const Value.absent(),
                Value<DateTime?> endedAt = const Value.absent(),
                Value<int> durationSeconds = const Value.absent(),
                Value<String?> configurationJson = const Value.absent(),
                Value<String?> deviceManufacturer = const Value.absent(),
                Value<String?> deviceModel = const Value.absent(),
                Value<int?> initialBatteryPercent = const Value.absent(),
                Value<double?> initialBatteryTemperatureC =
                    const Value.absent(),
                Value<int> accelerometerSampleCount = const Value.absent(),
                Value<int> gpsPointCount = const Value.absent(),
                Value<int> mediaCount = const Value.absent(),
              }) => RunsTableCompanion(
                id: id,
                recordedAt: recordedAt,
                odometer: odometer,
                isSynced: isSynced,
                title: title,
                distanceKm: distanceKm,
                vehicleId: vehicleId,
                notes: notes,
                syncedAt: syncedAt,
                endedAt: endedAt,
                durationSeconds: durationSeconds,
                configurationJson: configurationJson,
                deviceManufacturer: deviceManufacturer,
                deviceModel: deviceModel,
                initialBatteryPercent: initialBatteryPercent,
                initialBatteryTemperatureC: initialBatteryTemperatureC,
                accelerometerSampleCount: accelerometerSampleCount,
                gpsPointCount: gpsPointCount,
                mediaCount: mediaCount,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> recordedAt = const Value.absent(),
                Value<double> odometer = const Value.absent(),
                Value<bool> isSynced = const Value.absent(),
                Value<String?> title = const Value.absent(),
                Value<double> distanceKm = const Value.absent(),
                Value<int?> vehicleId = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime?> syncedAt = const Value.absent(),
                Value<DateTime?> endedAt = const Value.absent(),
                Value<int> durationSeconds = const Value.absent(),
                Value<String?> configurationJson = const Value.absent(),
                Value<String?> deviceManufacturer = const Value.absent(),
                Value<String?> deviceModel = const Value.absent(),
                Value<int?> initialBatteryPercent = const Value.absent(),
                Value<double?> initialBatteryTemperatureC =
                    const Value.absent(),
                Value<int> accelerometerSampleCount = const Value.absent(),
                Value<int> gpsPointCount = const Value.absent(),
                Value<int> mediaCount = const Value.absent(),
              }) => RunsTableCompanion.insert(
                id: id,
                recordedAt: recordedAt,
                odometer: odometer,
                isSynced: isSynced,
                title: title,
                distanceKm: distanceKm,
                vehicleId: vehicleId,
                notes: notes,
                syncedAt: syncedAt,
                endedAt: endedAt,
                durationSeconds: durationSeconds,
                configurationJson: configurationJson,
                deviceManufacturer: deviceManufacturer,
                deviceModel: deviceModel,
                initialBatteryPercent: initialBatteryPercent,
                initialBatteryTemperatureC: initialBatteryTemperatureC,
                accelerometerSampleCount: accelerometerSampleCount,
                gpsPointCount: gpsPointCount,
                mediaCount: mediaCount,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$RunsTableTable, Run>(table),
                  $$RunsTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                vehicleId = false,
                sensorReadingsTableRefs = false,
                gpsPointsTableRefs = false,
                mediaRecordsTableRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (sensorReadingsTableRefs) db.sensorReadingsTable,
                    if (gpsPointsTableRefs) db.gpsPointsTable,
                    if (mediaRecordsTableRefs) db.mediaRecordsTable,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (vehicleId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.vehicleId,
                                    referencedTable: $$RunsTableTableReferences
                                        ._vehicleIdTable(db),
                                    referencedColumn: $$RunsTableTableReferences
                                        ._vehicleIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (sensorReadingsTableRefs)
                        await $_getPrefetchedData<
                          Run,
                          $RunsTableTable,
                          SensorReading
                        >(
                          currentTable: table,
                          referencedTable: $$RunsTableTableReferences
                              ._sensorReadingsTableRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$RunsTableTableReferences(
                                db,
                                table,
                                p0,
                              ).sensorReadingsTableRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.runId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (gpsPointsTableRefs)
                        await $_getPrefetchedData<
                          Run,
                          $RunsTableTable,
                          GpsPoint
                        >(
                          currentTable: table,
                          referencedTable: $$RunsTableTableReferences
                              ._gpsPointsTableRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$RunsTableTableReferences(
                                db,
                                table,
                                p0,
                              ).gpsPointsTableRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.runId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (mediaRecordsTableRefs)
                        await $_getPrefetchedData<
                          Run,
                          $RunsTableTable,
                          MediaRecord
                        >(
                          currentTable: table,
                          referencedTable: $$RunsTableTableReferences
                              ._mediaRecordsTableRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$RunsTableTableReferences(
                                db,
                                table,
                                p0,
                              ).mediaRecordsTableRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.runId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$RunsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RunsTableTable,
      Run,
      $$RunsTableTableFilterComposer,
      $$RunsTableTableOrderingComposer,
      $$RunsTableTableAnnotationComposer,
      $$RunsTableTableCreateCompanionBuilder,
      $$RunsTableTableUpdateCompanionBuilder,
      (Run, $$RunsTableTableReferences),
      Run,
      PrefetchHooks Function({
        bool vehicleId,
        bool sensorReadingsTableRefs,
        bool gpsPointsTableRefs,
        bool mediaRecordsTableRefs,
      })
    >;
typedef $$SensorReadingsTableTableCreateCompanionBuilder =
    SensorReadingsTableCompanion Function({
      Value<int> id,
      required int runId,
      required DateTime recordedAt,
      required double accelerometerX,
      required double accelerometerY,
      required double accelerometerZ,
      Value<double?> gyroscopeX,
      Value<double?> gyroscopeY,
      Value<double?> gyroscopeZ,
    });
typedef $$SensorReadingsTableTableUpdateCompanionBuilder =
    SensorReadingsTableCompanion Function({
      Value<int> id,
      Value<int> runId,
      Value<DateTime> recordedAt,
      Value<double> accelerometerX,
      Value<double> accelerometerY,
      Value<double> accelerometerZ,
      Value<double?> gyroscopeX,
      Value<double?> gyroscopeY,
      Value<double?> gyroscopeZ,
    });

final class $$SensorReadingsTableTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $SensorReadingsTableTable,
          SensorReading
        > {
  $$SensorReadingsTableTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $RunsTableTable _runIdTable(_$AppDatabase db) =>
      db.runsTable.createAlias('sensor_readings_table__run_id__runs_table__id');

  $$RunsTableTableProcessedTableManager get runId {
    final $_column = $_itemColumn<int>('run_id')!;

    final manager = $$RunsTableTableTableManager(
      $_db,
      $_db.runsTable,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_runIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$SensorReadingsTableTableFilterComposer
    extends Composer<_$AppDatabase, $SensorReadingsTableTable> {
  $$SensorReadingsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get recordedAt => $composableBuilder(
    column: $table.recordedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get accelerometerX => $composableBuilder(
    column: $table.accelerometerX,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get accelerometerY => $composableBuilder(
    column: $table.accelerometerY,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get accelerometerZ => $composableBuilder(
    column: $table.accelerometerZ,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get gyroscopeX => $composableBuilder(
    column: $table.gyroscopeX,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get gyroscopeY => $composableBuilder(
    column: $table.gyroscopeY,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get gyroscopeZ => $composableBuilder(
    column: $table.gyroscopeZ,
    builder: (column) => ColumnFilters(column),
  );

  $$RunsTableTableFilterComposer get runId {
    final $$RunsTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.runId,
      referencedTable: $db.runsTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RunsTableTableFilterComposer(
            $db: $db,
            $table: $db.runsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SensorReadingsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $SensorReadingsTableTable> {
  $$SensorReadingsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get recordedAt => $composableBuilder(
    column: $table.recordedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get accelerometerX => $composableBuilder(
    column: $table.accelerometerX,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get accelerometerY => $composableBuilder(
    column: $table.accelerometerY,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get accelerometerZ => $composableBuilder(
    column: $table.accelerometerZ,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get gyroscopeX => $composableBuilder(
    column: $table.gyroscopeX,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get gyroscopeY => $composableBuilder(
    column: $table.gyroscopeY,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get gyroscopeZ => $composableBuilder(
    column: $table.gyroscopeZ,
    builder: (column) => ColumnOrderings(column),
  );

  $$RunsTableTableOrderingComposer get runId {
    final $$RunsTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.runId,
      referencedTable: $db.runsTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RunsTableTableOrderingComposer(
            $db: $db,
            $table: $db.runsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SensorReadingsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $SensorReadingsTableTable> {
  $$SensorReadingsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get recordedAt => $composableBuilder(
    column: $table.recordedAt,
    builder: (column) => column,
  );

  GeneratedColumn<double> get accelerometerX => $composableBuilder(
    column: $table.accelerometerX,
    builder: (column) => column,
  );

  GeneratedColumn<double> get accelerometerY => $composableBuilder(
    column: $table.accelerometerY,
    builder: (column) => column,
  );

  GeneratedColumn<double> get accelerometerZ => $composableBuilder(
    column: $table.accelerometerZ,
    builder: (column) => column,
  );

  GeneratedColumn<double> get gyroscopeX => $composableBuilder(
    column: $table.gyroscopeX,
    builder: (column) => column,
  );

  GeneratedColumn<double> get gyroscopeY => $composableBuilder(
    column: $table.gyroscopeY,
    builder: (column) => column,
  );

  GeneratedColumn<double> get gyroscopeZ => $composableBuilder(
    column: $table.gyroscopeZ,
    builder: (column) => column,
  );

  $$RunsTableTableAnnotationComposer get runId {
    final $$RunsTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.runId,
      referencedTable: $db.runsTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RunsTableTableAnnotationComposer(
            $db: $db,
            $table: $db.runsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SensorReadingsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SensorReadingsTableTable,
          SensorReading,
          $$SensorReadingsTableTableFilterComposer,
          $$SensorReadingsTableTableOrderingComposer,
          $$SensorReadingsTableTableAnnotationComposer,
          $$SensorReadingsTableTableCreateCompanionBuilder,
          $$SensorReadingsTableTableUpdateCompanionBuilder,
          (SensorReading, $$SensorReadingsTableTableReferences),
          SensorReading,
          PrefetchHooks Function({bool runId})
        > {
  $$SensorReadingsTableTableTableManager(
    _$AppDatabase db,
    $SensorReadingsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SensorReadingsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SensorReadingsTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$SensorReadingsTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> runId = const Value.absent(),
                Value<DateTime> recordedAt = const Value.absent(),
                Value<double> accelerometerX = const Value.absent(),
                Value<double> accelerometerY = const Value.absent(),
                Value<double> accelerometerZ = const Value.absent(),
                Value<double?> gyroscopeX = const Value.absent(),
                Value<double?> gyroscopeY = const Value.absent(),
                Value<double?> gyroscopeZ = const Value.absent(),
              }) => SensorReadingsTableCompanion(
                id: id,
                runId: runId,
                recordedAt: recordedAt,
                accelerometerX: accelerometerX,
                accelerometerY: accelerometerY,
                accelerometerZ: accelerometerZ,
                gyroscopeX: gyroscopeX,
                gyroscopeY: gyroscopeY,
                gyroscopeZ: gyroscopeZ,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int runId,
                required DateTime recordedAt,
                required double accelerometerX,
                required double accelerometerY,
                required double accelerometerZ,
                Value<double?> gyroscopeX = const Value.absent(),
                Value<double?> gyroscopeY = const Value.absent(),
                Value<double?> gyroscopeZ = const Value.absent(),
              }) => SensorReadingsTableCompanion.insert(
                id: id,
                runId: runId,
                recordedAt: recordedAt,
                accelerometerX: accelerometerX,
                accelerometerY: accelerometerY,
                accelerometerZ: accelerometerZ,
                gyroscopeX: gyroscopeX,
                gyroscopeY: gyroscopeY,
                gyroscopeZ: gyroscopeZ,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SensorReadingsTableTable, SensorReading>(table),
                  $$SensorReadingsTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({runId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (runId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.runId,
                                referencedTable:
                                    $$SensorReadingsTableTableReferences
                                        ._runIdTable(db),
                                referencedColumn:
                                    $$SensorReadingsTableTableReferences
                                        ._runIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$SensorReadingsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SensorReadingsTableTable,
      SensorReading,
      $$SensorReadingsTableTableFilterComposer,
      $$SensorReadingsTableTableOrderingComposer,
      $$SensorReadingsTableTableAnnotationComposer,
      $$SensorReadingsTableTableCreateCompanionBuilder,
      $$SensorReadingsTableTableUpdateCompanionBuilder,
      (SensorReading, $$SensorReadingsTableTableReferences),
      SensorReading,
      PrefetchHooks Function({bool runId})
    >;
typedef $$GpsPointsTableTableCreateCompanionBuilder =
    GpsPointsTableCompanion Function({
      Value<int> id,
      required int runId,
      required DateTime recordedAt,
      required double latitude,
      required double longitude,
      Value<double?> altitudeMeters,
      Value<double?> speedMetersPerSecond,
      Value<double?> headingDegrees,
      Value<double?> accuracyMeters,
    });
typedef $$GpsPointsTableTableUpdateCompanionBuilder =
    GpsPointsTableCompanion Function({
      Value<int> id,
      Value<int> runId,
      Value<DateTime> recordedAt,
      Value<double> latitude,
      Value<double> longitude,
      Value<double?> altitudeMeters,
      Value<double?> speedMetersPerSecond,
      Value<double?> headingDegrees,
      Value<double?> accuracyMeters,
    });

final class $$GpsPointsTableTableReferences
    extends BaseReferences<_$AppDatabase, $GpsPointsTableTable, GpsPoint> {
  $$GpsPointsTableTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $RunsTableTable _runIdTable(_$AppDatabase db) =>
      db.runsTable.createAlias('gps_points_table__run_id__runs_table__id');

  $$RunsTableTableProcessedTableManager get runId {
    final $_column = $_itemColumn<int>('run_id')!;

    final manager = $$RunsTableTableTableManager(
      $_db,
      $_db.runsTable,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_runIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$GpsPointsTableTableFilterComposer
    extends Composer<_$AppDatabase, $GpsPointsTableTable> {
  $$GpsPointsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get recordedAt => $composableBuilder(
    column: $table.recordedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get altitudeMeters => $composableBuilder(
    column: $table.altitudeMeters,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get speedMetersPerSecond => $composableBuilder(
    column: $table.speedMetersPerSecond,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get headingDegrees => $composableBuilder(
    column: $table.headingDegrees,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get accuracyMeters => $composableBuilder(
    column: $table.accuracyMeters,
    builder: (column) => ColumnFilters(column),
  );

  $$RunsTableTableFilterComposer get runId {
    final $$RunsTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.runId,
      referencedTable: $db.runsTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RunsTableTableFilterComposer(
            $db: $db,
            $table: $db.runsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$GpsPointsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $GpsPointsTableTable> {
  $$GpsPointsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get recordedAt => $composableBuilder(
    column: $table.recordedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get altitudeMeters => $composableBuilder(
    column: $table.altitudeMeters,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get speedMetersPerSecond => $composableBuilder(
    column: $table.speedMetersPerSecond,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get headingDegrees => $composableBuilder(
    column: $table.headingDegrees,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get accuracyMeters => $composableBuilder(
    column: $table.accuracyMeters,
    builder: (column) => ColumnOrderings(column),
  );

  $$RunsTableTableOrderingComposer get runId {
    final $$RunsTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.runId,
      referencedTable: $db.runsTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RunsTableTableOrderingComposer(
            $db: $db,
            $table: $db.runsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$GpsPointsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $GpsPointsTableTable> {
  $$GpsPointsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get recordedAt => $composableBuilder(
    column: $table.recordedAt,
    builder: (column) => column,
  );

  GeneratedColumn<double> get latitude =>
      $composableBuilder(column: $table.latitude, builder: (column) => column);

  GeneratedColumn<double> get longitude =>
      $composableBuilder(column: $table.longitude, builder: (column) => column);

  GeneratedColumn<double> get altitudeMeters => $composableBuilder(
    column: $table.altitudeMeters,
    builder: (column) => column,
  );

  GeneratedColumn<double> get speedMetersPerSecond => $composableBuilder(
    column: $table.speedMetersPerSecond,
    builder: (column) => column,
  );

  GeneratedColumn<double> get headingDegrees => $composableBuilder(
    column: $table.headingDegrees,
    builder: (column) => column,
  );

  GeneratedColumn<double> get accuracyMeters => $composableBuilder(
    column: $table.accuracyMeters,
    builder: (column) => column,
  );

  $$RunsTableTableAnnotationComposer get runId {
    final $$RunsTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.runId,
      referencedTable: $db.runsTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RunsTableTableAnnotationComposer(
            $db: $db,
            $table: $db.runsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$GpsPointsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $GpsPointsTableTable,
          GpsPoint,
          $$GpsPointsTableTableFilterComposer,
          $$GpsPointsTableTableOrderingComposer,
          $$GpsPointsTableTableAnnotationComposer,
          $$GpsPointsTableTableCreateCompanionBuilder,
          $$GpsPointsTableTableUpdateCompanionBuilder,
          (GpsPoint, $$GpsPointsTableTableReferences),
          GpsPoint,
          PrefetchHooks Function({bool runId})
        > {
  $$GpsPointsTableTableTableManager(
    _$AppDatabase db,
    $GpsPointsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GpsPointsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GpsPointsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GpsPointsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> runId = const Value.absent(),
                Value<DateTime> recordedAt = const Value.absent(),
                Value<double> latitude = const Value.absent(),
                Value<double> longitude = const Value.absent(),
                Value<double?> altitudeMeters = const Value.absent(),
                Value<double?> speedMetersPerSecond = const Value.absent(),
                Value<double?> headingDegrees = const Value.absent(),
                Value<double?> accuracyMeters = const Value.absent(),
              }) => GpsPointsTableCompanion(
                id: id,
                runId: runId,
                recordedAt: recordedAt,
                latitude: latitude,
                longitude: longitude,
                altitudeMeters: altitudeMeters,
                speedMetersPerSecond: speedMetersPerSecond,
                headingDegrees: headingDegrees,
                accuracyMeters: accuracyMeters,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int runId,
                required DateTime recordedAt,
                required double latitude,
                required double longitude,
                Value<double?> altitudeMeters = const Value.absent(),
                Value<double?> speedMetersPerSecond = const Value.absent(),
                Value<double?> headingDegrees = const Value.absent(),
                Value<double?> accuracyMeters = const Value.absent(),
              }) => GpsPointsTableCompanion.insert(
                id: id,
                runId: runId,
                recordedAt: recordedAt,
                latitude: latitude,
                longitude: longitude,
                altitudeMeters: altitudeMeters,
                speedMetersPerSecond: speedMetersPerSecond,
                headingDegrees: headingDegrees,
                accuracyMeters: accuracyMeters,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$GpsPointsTableTable, GpsPoint>(table),
                  $$GpsPointsTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({runId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (runId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.runId,
                                referencedTable: $$GpsPointsTableTableReferences
                                    ._runIdTable(db),
                                referencedColumn:
                                    $$GpsPointsTableTableReferences
                                        ._runIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$GpsPointsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $GpsPointsTableTable,
      GpsPoint,
      $$GpsPointsTableTableFilterComposer,
      $$GpsPointsTableTableOrderingComposer,
      $$GpsPointsTableTableAnnotationComposer,
      $$GpsPointsTableTableCreateCompanionBuilder,
      $$GpsPointsTableTableUpdateCompanionBuilder,
      (GpsPoint, $$GpsPointsTableTableReferences),
      GpsPoint,
      PrefetchHooks Function({bool runId})
    >;
typedef $$MediaRecordsTableTableCreateCompanionBuilder =
    MediaRecordsTableCompanion Function({
      Value<int> id,
      required int runId,
      required String mediaType,
      required String filePath,
      required DateTime recordedAt,
      Value<double?> latitude,
      Value<double?> longitude,
    });
typedef $$MediaRecordsTableTableUpdateCompanionBuilder =
    MediaRecordsTableCompanion Function({
      Value<int> id,
      Value<int> runId,
      Value<String> mediaType,
      Value<String> filePath,
      Value<DateTime> recordedAt,
      Value<double?> latitude,
      Value<double?> longitude,
    });

final class $$MediaRecordsTableTableReferences
    extends
        BaseReferences<_$AppDatabase, $MediaRecordsTableTable, MediaRecord> {
  $$MediaRecordsTableTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $RunsTableTable _runIdTable(_$AppDatabase db) =>
      db.runsTable.createAlias('media_records_table__run_id__runs_table__id');

  $$RunsTableTableProcessedTableManager get runId {
    final $_column = $_itemColumn<int>('run_id')!;

    final manager = $$RunsTableTableTableManager(
      $_db,
      $_db.runsTable,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_runIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$MediaRecordsTableTableFilterComposer
    extends Composer<_$AppDatabase, $MediaRecordsTableTable> {
  $$MediaRecordsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mediaType => $composableBuilder(
    column: $table.mediaType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get filePath => $composableBuilder(
    column: $table.filePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get recordedAt => $composableBuilder(
    column: $table.recordedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnFilters(column),
  );

  $$RunsTableTableFilterComposer get runId {
    final $$RunsTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.runId,
      referencedTable: $db.runsTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RunsTableTableFilterComposer(
            $db: $db,
            $table: $db.runsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MediaRecordsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $MediaRecordsTableTable> {
  $$MediaRecordsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mediaType => $composableBuilder(
    column: $table.mediaType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get filePath => $composableBuilder(
    column: $table.filePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get recordedAt => $composableBuilder(
    column: $table.recordedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnOrderings(column),
  );

  $$RunsTableTableOrderingComposer get runId {
    final $$RunsTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.runId,
      referencedTable: $db.runsTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RunsTableTableOrderingComposer(
            $db: $db,
            $table: $db.runsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MediaRecordsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $MediaRecordsTableTable> {
  $$MediaRecordsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get mediaType =>
      $composableBuilder(column: $table.mediaType, builder: (column) => column);

  GeneratedColumn<String> get filePath =>
      $composableBuilder(column: $table.filePath, builder: (column) => column);

  GeneratedColumn<DateTime> get recordedAt => $composableBuilder(
    column: $table.recordedAt,
    builder: (column) => column,
  );

  GeneratedColumn<double> get latitude =>
      $composableBuilder(column: $table.latitude, builder: (column) => column);

  GeneratedColumn<double> get longitude =>
      $composableBuilder(column: $table.longitude, builder: (column) => column);

  $$RunsTableTableAnnotationComposer get runId {
    final $$RunsTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.runId,
      referencedTable: $db.runsTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RunsTableTableAnnotationComposer(
            $db: $db,
            $table: $db.runsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MediaRecordsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MediaRecordsTableTable,
          MediaRecord,
          $$MediaRecordsTableTableFilterComposer,
          $$MediaRecordsTableTableOrderingComposer,
          $$MediaRecordsTableTableAnnotationComposer,
          $$MediaRecordsTableTableCreateCompanionBuilder,
          $$MediaRecordsTableTableUpdateCompanionBuilder,
          (MediaRecord, $$MediaRecordsTableTableReferences),
          MediaRecord,
          PrefetchHooks Function({bool runId})
        > {
  $$MediaRecordsTableTableTableManager(
    _$AppDatabase db,
    $MediaRecordsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MediaRecordsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MediaRecordsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MediaRecordsTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> runId = const Value.absent(),
                Value<String> mediaType = const Value.absent(),
                Value<String> filePath = const Value.absent(),
                Value<DateTime> recordedAt = const Value.absent(),
                Value<double?> latitude = const Value.absent(),
                Value<double?> longitude = const Value.absent(),
              }) => MediaRecordsTableCompanion(
                id: id,
                runId: runId,
                mediaType: mediaType,
                filePath: filePath,
                recordedAt: recordedAt,
                latitude: latitude,
                longitude: longitude,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int runId,
                required String mediaType,
                required String filePath,
                required DateTime recordedAt,
                Value<double?> latitude = const Value.absent(),
                Value<double?> longitude = const Value.absent(),
              }) => MediaRecordsTableCompanion.insert(
                id: id,
                runId: runId,
                mediaType: mediaType,
                filePath: filePath,
                recordedAt: recordedAt,
                latitude: latitude,
                longitude: longitude,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$MediaRecordsTableTable, MediaRecord>(table),
                  $$MediaRecordsTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({runId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (runId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.runId,
                                referencedTable:
                                    $$MediaRecordsTableTableReferences
                                        ._runIdTable(db),
                                referencedColumn:
                                    $$MediaRecordsTableTableReferences
                                        ._runIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$MediaRecordsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MediaRecordsTableTable,
      MediaRecord,
      $$MediaRecordsTableTableFilterComposer,
      $$MediaRecordsTableTableOrderingComposer,
      $$MediaRecordsTableTableAnnotationComposer,
      $$MediaRecordsTableTableCreateCompanionBuilder,
      $$MediaRecordsTableTableUpdateCompanionBuilder,
      (MediaRecord, $$MediaRecordsTableTableReferences),
      MediaRecord,
      PrefetchHooks Function({bool runId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$VehiclesTableTableManager get vehicles =>
      $$VehiclesTableTableManager(_db, _db.vehicles);
  $$RunsTableTableTableManager get runsTable =>
      $$RunsTableTableTableManager(_db, _db.runsTable);
  $$SensorReadingsTableTableTableManager get sensorReadingsTable =>
      $$SensorReadingsTableTableTableManager(_db, _db.sensorReadingsTable);
  $$GpsPointsTableTableTableManager get gpsPointsTable =>
      $$GpsPointsTableTableTableManager(_db, _db.gpsPointsTable);
  $$MediaRecordsTableTableTableManager get mediaRecordsTable =>
      $$MediaRecordsTableTableTableManager(_db, _db.mediaRecordsTable);
}
