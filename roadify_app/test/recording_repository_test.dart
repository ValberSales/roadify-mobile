import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:roadify_app/core/database/app_database.dart';
import 'package:roadify_app/features/coleta/viewmodels/coleta_viewmodel.dart';
import 'package:roadify_app/features/gravacao/services/recording_repository.dart';

void main() {
  late AppDatabase database;
  late RecordingRepository repository;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    repository = RecordingRepository(database);
  });

  tearDown(() async {
    await database.close();
  });

  test(
    'persists run metadata and sensor/GPS batches transactionally',
    () async {
      final startedAt = DateTime.utc(2026, 10, 26, 23, 22);
      final configuration = ConfiguracaoColeta(
        sensoresSelecionados: {
          SensorColeta.acelerometro,
          SensorColeta.gps,
          SensorColeta.giroscopio,
        },
        taxaInercialHz: 200,
        taxaGpsHz: 10,
        intervaloMetros: 25,
        nomeColeta: 'BR-101 • Trecho Norte',
        odometroInicial: 15420.5,
      );

      final runId = await repository.startRun(
        configuration: configuration,
        startedAt: startedAt,
        manufacturer: 'Acme',
        model: 'Device X',
        batteryPercent: 87,
      );
      await repository.saveBatch(
        runId: runId,
        sensorSamples: [
          RecordedSensorSample(
            recordedAt: startedAt,
            accelerometerX: 1.1,
            accelerometerY: 2.2,
            accelerometerZ: 9.7,
            gyroscopeX: 0.1,
            gyroscopeY: 0.2,
            gyroscopeZ: 0.3,
          ),
          RecordedSensorSample(
            recordedAt: startedAt.add(const Duration(milliseconds: 5)),
            accelerometerX: 1.2,
            accelerometerY: 2.3,
            accelerometerZ: 9.6,
          ),
        ],
        gpsPoints: [
          RecordedGpsPoint(
            recordedAt: startedAt,
            latitude: -23.55,
            longitude: -46.63,
            altitudeMeters: 760,
            speedMetersPerSecond: 12.5,
            headingDegrees: 180,
            accuracyMeters: 3.2,
          ),
        ],
        sensorSampleCount: 2,
        gpsPointCount: 1,
        distanceKm: 0.1,
      );
      await repository.saveMedia(
        runId: runId,
        mediaType: 'photo',
        filePath: 'runs/$runId/photo_1.jpg',
        recordedAt: startedAt,
        latitude: -23.55,
        longitude: -46.63,
      );
      await repository.finishRun(
        runId: runId,
        endedAt: startedAt.add(const Duration(seconds: 8)),
        duration: const Duration(seconds: 8),
        distanceKm: 0.125,
        sensorSampleCount: 2,
        gpsPointCount: 1,
        mediaCount: 1,
      );

      final run = await (database.select(
        database.runsTable,
      )..where((table) => table.id.equals(runId))).getSingle();
      final samples = await (database.select(
        database.sensorReadingsTable,
      )..where((table) => table.runId.equals(runId))).get();
      final gpsPoints = await (database.select(
        database.gpsPointsTable,
      )..where((table) => table.runId.equals(runId))).get();
      final media = await (database.select(
        database.mediaRecordsTable,
      )..where((table) => table.runId.equals(runId))).getSingle();

      expect(run.title, 'BR-101 • Trecho Norte');
      expect(run.odometer, 15420.5);
      expect(run.deviceManufacturer, 'Acme');
      expect(run.initialBatteryPercent, 87);
      expect(run.configurationJson, contains('"gpsFrequencyHz":10'));
      expect(run.endedAt, isNotNull);
      expect(run.distanceKm, 0.125);
      expect(run.accelerometerSampleCount, 2);
      expect(run.gpsPointCount, 1);
      expect(run.mediaCount, 1);
      expect(samples, hasLength(2));
      expect(samples.first.gyroscopeY, 0.2);
      expect(gpsPoints.single.latitude, -23.55);
      expect(media.filePath, 'runs/$runId/photo_1.jpg');
    },
  );

  test('rolls back sensor and GPS inserts when a batch is invalid', () async {
    final timestamp = DateTime.utc(2026, 10, 26, 23, 22);

    await expectLater(
      repository.saveBatch(
        runId: 999,
        sensorSamples: [
          RecordedSensorSample(
            recordedAt: timestamp,
            accelerometerX: 1,
            accelerometerY: 2,
            accelerometerZ: 3,
          ),
        ],
        gpsPoints: [
          RecordedGpsPoint(
            recordedAt: timestamp,
            latitude: -23.55,
            longitude: -46.63,
          ),
        ],
        sensorSampleCount: 1,
        gpsPointCount: 1,
        distanceKm: 0.02,
      ),
      throwsA(anything),
    );

    expect(await database.select(database.sensorReadingsTable).get(), isEmpty);
    expect(await database.select(database.gpsPointsTable).get(), isEmpty);
  });
}
