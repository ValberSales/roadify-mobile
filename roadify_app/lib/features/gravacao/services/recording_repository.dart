import 'dart:convert';

import 'package:drift/drift.dart';
import '../../../core/database/app_database.dart';
import '../../coleta/viewmodels/coleta_viewmodel.dart';

class RecordedSensorSample {
  final DateTime recordedAt;
  final double accelerometerX;
  final double accelerometerY;
  final double accelerometerZ;
  final double? gyroscopeX;
  final double? gyroscopeY;
  final double? gyroscopeZ;

  const RecordedSensorSample({
    required this.recordedAt,
    required this.accelerometerX,
    required this.accelerometerY,
    required this.accelerometerZ,
    this.gyroscopeX,
    this.gyroscopeY,
    this.gyroscopeZ,
  });
}

class RecordedGpsPoint {
  final DateTime recordedAt;
  final double latitude;
  final double longitude;
  final double? altitudeMeters;
  final double? speedMetersPerSecond;
  final double? headingDegrees;
  final double? accuracyMeters;

  const RecordedGpsPoint({
    required this.recordedAt,
    required this.latitude,
    required this.longitude,
    this.altitudeMeters,
    this.speedMetersPerSecond,
    this.headingDegrees,
    this.accuracyMeters,
  });
}

class RecordingRepository {
  final AppDatabase database;

  const RecordingRepository(this.database);

  Future<int> startRun({
    required ConfiguracaoColeta configuration,
    required DateTime startedAt,
    String? manufacturer,
    String? model,
    int? batteryPercent,
  }) {
    final options = configuration.sensoresOpcionais;
    return database
        .into(database.runsTable)
        .insert(
          RunsTableCompanion.insert(
            title: Value(
              configuration.nomeColeta?.trim().isNotEmpty == true
                  ? configuration.nomeColeta!.trim()
                  : 'Coleta ${startedAt.toLocal()}',
            ),
            recordedAt: Value(startedAt.toUtc()),
            odometer: Value(configuration.odometroInicial),
            vehicleId: Value(configuration.vehicleId),
            configurationJson: Value(
              jsonEncode({
                'sensors': configuration.sensoresSelecionados
                    .map((sensor) => sensor.name)
                    .toList(),
                'accelerometerFrequencyHz': configuration.taxaInercialHz,
                'gyroscopeFrequencyHz': options.gyroscopeFrequencyHz,
                'gpsFrequencyHz': configuration.taxaGpsHz,
                'gpsDistanceIntervalMeters': configuration.intervaloMetros,
                'route': configuration.trecho,
                'identifier': configuration.identificador,
                'orientation': configuration.orientation.name,
                'posture': configuration.posture.name,
                'levelingMode': configuration.levelingMode.name,
                'isCalibrated': configuration.isCalibrated,
                'calibrationOffsetX': configuration.calibrationOffsetX,
                'calibrationOffsetY': configuration.calibrationOffsetY,
                'camera': {
                  'mediaType': options.camera.mediaType.name,
                  'facing': options.camera.facing.name,
                  'automatic': options.camera.automatic,
                  'interval': options.camera.interval,
                  'intervalUnit': options.camera.intervalUnit.name,
                  'videoDurationSeconds': options.camera.videoDurationSeconds,
                },
                'audio': {
                  'automatic': options.audio.automatic,
                  'interval': options.audio.interval,
                  'intervalUnit': options.audio.intervalUnit.name,
                  'durationSeconds': options.audio.durationSeconds,
                },
              }),
            ),
            deviceManufacturer: Value(manufacturer),
            deviceModel: Value(model),
            initialBatteryPercent: Value(batteryPercent),
            notes: Value(
              'Frequências configuradas: acelerômetro ${configuration.taxaInercialHz} Hz; '
              'GPS ${configuration.taxaGpsHz} Hz.',
            ),
          ),
        );
  }

  Future<void> saveBatch({
    required int runId,
    required List<RecordedSensorSample> sensorSamples,
    required List<RecordedGpsPoint> gpsPoints,
    required int sensorSampleCount,
    required int gpsPointCount,
    required double distanceKm,
  }) async {
    if (sensorSamples.isEmpty && gpsPoints.isEmpty) return;

    await database.transaction(() async {
      if (sensorSamples.isNotEmpty) {
        await database.batch((batch) {
          batch.insertAll(
            database.sensorReadingsTable,
            sensorSamples.map(
              (sample) => SensorReadingsTableCompanion.insert(
                runId: runId,
                recordedAt: sample.recordedAt.toUtc(),
                accelerometerX: sample.accelerometerX,
                accelerometerY: sample.accelerometerY,
                accelerometerZ: sample.accelerometerZ,
                gyroscopeX: Value(sample.gyroscopeX),
                gyroscopeY: Value(sample.gyroscopeY),
                gyroscopeZ: Value(sample.gyroscopeZ),
              ),
            ),
          );
        });
      }
      if (gpsPoints.isNotEmpty) {
        await database.batch((batch) {
          batch.insertAll(
            database.gpsPointsTable,
            gpsPoints.map(
              (point) => GpsPointsTableCompanion.insert(
                runId: runId,
                recordedAt: point.recordedAt.toUtc(),
                latitude: point.latitude,
                longitude: point.longitude,
                altitudeMeters: Value(point.altitudeMeters),
                speedMetersPerSecond: Value(point.speedMetersPerSecond),
                headingDegrees: Value(point.headingDegrees),
                accuracyMeters: Value(point.accuracyMeters),
              ),
            ),
          );
        });
      }
      await (database.update(
        database.runsTable,
      )..where((run) => run.id.equals(runId))).write(
        RunsTableCompanion(
          accelerometerSampleCount: Value(sensorSampleCount),
          gpsPointCount: Value(gpsPointCount),
          distanceKm: Value(distanceKm),
        ),
      );
    });
  }

  Future<void> finishRun({
    required int runId,
    required DateTime endedAt,
    required Duration duration,
    required double distanceKm,
    required int sensorSampleCount,
    required int gpsPointCount,
    required int mediaCount,
    int? vehicleId,
    double? finalOdometer,
  }) async {
    if ((vehicleId == null) != (finalOdometer == null)) {
      throw ArgumentError(
        'Veículo e quilometragem final devem ser informados juntos.',
      );
    }

    await database.transaction(() async {
      final changed =
          await (database.update(
            database.runsTable,
          )..where((run) => run.id.equals(runId))).write(
            RunsTableCompanion(
              endedAt: Value(endedAt.toUtc()),
              durationSeconds: Value(duration.inSeconds),
              distanceKm: Value(distanceKm),
              accelerometerSampleCount: Value(sensorSampleCount),
              gpsPointCount: Value(gpsPointCount),
              mediaCount: Value(mediaCount),
            ),
          );
      if (changed != 1) {
        throw StateError('A coleta não foi encontrada para finalização.');
      }

      if (vehicleId != null) {
        final updated = await database.vehicleDao.updateOdometer(
          id: vehicleId,
          odometer: finalOdometer!,
        );
        if (updated != 1) {
          throw StateError(
            'O veículo selecionado não está mais disponível para atualizar a quilometragem.',
          );
        }
      }
    });
  }

  Future<int> saveMedia({
    required int runId,
    required String mediaType,
    required String filePath,
    required DateTime recordedAt,
    double? latitude,
    double? longitude,
  }) {
    return database
        .into(database.mediaRecordsTable)
        .insert(
          MediaRecordsTableCompanion.insert(
            runId: runId,
            mediaType: mediaType,
            filePath: filePath,
            recordedAt: recordedAt.toUtc(),
            latitude: Value(latitude),
            longitude: Value(longitude),
          ),
        );
  }
}
