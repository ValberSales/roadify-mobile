import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:archive/archive_io.dart';
import 'package:drift/drift.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:roadify_app/core/database/app_database.dart';

class RunExportService {
  static const _pageSize = 5000;

  final AppDatabase _db;
  final Future<Directory> Function() _temporaryDirectory;
  final Future<String?> Function(String sourcePath, String fileName) _saveToDevice;

  RunExportService(
      this._db, {
        Future<Directory> Function()? temporaryDirectory,
        Future<String?> Function(String sourcePath, String fileName)? saveToDevice,
      })  : _temporaryDirectory = temporaryDirectory ?? getTemporaryDirectory,
        _saveToDevice = saveToDevice ?? _defaultSaveToDevice;

  /// Abre o seletor de local do sistema (Android/iOS) e copia o arquivo para lá.
  /// Retorna o caminho salvo, ou `null` se o usuário cancelou.
  static Future<String?> _defaultSaveToDevice(String sourcePath, String fileName) {
    return FlutterFileDialog.saveFile(
      params: SaveFileDialogParams(
        sourceFilePath: sourcePath,
        fileName: fileName,
      ),
    );
  }


  Future<String?> exportRun(
      int runId, {
        void Function(double progress)? onProgress,
      }) async {
    final run = await _db.runDao.getRunById(runId);
    if (run == null) {
      throw StateError('A coleta #$runId não foi encontrada.');
    }

    final rootName = 'coleta_${run.id}_${_stamp(run.recordedAt)}';
    final tempRoot = p.join((await _temporaryDirectory()).path, 'roadify_export');
    final workDir = Directory(p.join(tempRoot, rootName));
    final zipFile = File(p.join(tempRoot, '$rootName.zip'));

    try {
      if (await workDir.exists()) await workDir.delete(recursive: true);
      if (await zipFile.exists()) await zipFile.delete();
      await workDir.create(recursive: true);

      // Linhas de CSV são a maior parte do trabalho; reserva 0–90% para elas.
      final expectedRows =
      (run.accelerometerSampleCount + run.gpsPointCount).clamp(1, 1 << 62);
      var writtenRows = 0;
      void rowsWritten(int n) {
        writtenRows += n;
        onProgress?.call((writtenRows / expectedRows * 0.9).clamp(0.0, 0.9));
      }

      final entries = <_ZipEntry>[];

      final sensorCsv = File(p.join(workDir.path, 'sensor_readings.csv'));
      await _writeSensorCsv(sensorCsv, runId, rowsWritten);
      entries.add(_ZipEntry(sensorCsv.path, '$rootName/sensor_readings.csv'));

      final gpsCsv = File(p.join(workDir.path, 'gps_points.csv'));
      await _writeGpsCsv(gpsCsv, runId, rowsWritten);
      entries.add(_ZipEntry(gpsCsv.path, '$rootName/gps_points.csv'));

      final mediaCsv = File(p.join(workDir.path, 'media.csv'));
      entries.addAll(await _writeMedia(mediaCsv, runId, rootName));
      entries.add(_ZipEntry(mediaCsv.path, '$rootName/media.csv'));

      final jsonFile = File(p.join(workDir.path, 'run.json'));
      await jsonFile.writeAsString(await _buildRunJson(run));
      entries.add(_ZipEntry(jsonFile.path, '$rootName/run.json'));

      onProgress?.call(0.92);
      await _zip(zipFile.path, entries);

      onProgress?.call(0.97);
      final saved = await _saveToDevice(zipFile.path, '$rootName.zip');
      onProgress?.call(1.0);
      return saved;
    } finally {
      // Remove arquivos temporários mesmo em caso de erro/cancelamento.
      try {
        if (await workDir.exists()) await workDir.delete(recursive: true);
        if (await zipFile.exists()) await zipFile.delete();
      } catch (_) {}
    }
  }

  // --- CSVs (paginados por id para não carregar milhões de linhas na memória) ---

  Future<void> _writeSensorCsv(
      File file,
      int runId,
      void Function(int) onRows,
      ) async {
    final sink = file.openWrite();
    try {
      sink.writeln(
        'timestamp_utc,accel_x,accel_y,accel_z,gyro_x,gyro_y,gyro_z',
      );
      var lastId = 0;
      while (true) {
        final rows = await (_db.select(_db.sensorReadingsTable)
          ..where((t) => t.runId.equals(runId) & t.id.isBiggerThanValue(lastId))
          ..orderBy([(t) => OrderingTerm.asc(t.id)])
          ..limit(_pageSize))
            .get();
        if (rows.isEmpty) break;
        final buffer = StringBuffer();
        for (final r in rows) {
          buffer
            ..write(r.recordedAt.toUtc().toIso8601String())
            ..write(',')
            ..write(r.accelerometerX)
            ..write(',')
            ..write(r.accelerometerY)
            ..write(',')
            ..write(r.accelerometerZ)
            ..write(',')
            ..write(r.gyroscopeX ?? '')
            ..write(',')
            ..write(r.gyroscopeY ?? '')
            ..write(',')
            ..write(r.gyroscopeZ ?? '')
            ..write('\n');
        }
        sink.write(buffer);
        lastId = rows.last.id;
        onRows(rows.length);
        if (rows.length < _pageSize) break;
      }
    } finally {
      await sink.close();
    }
  }

  Future<void> _writeGpsCsv(
      File file,
      int runId,
      void Function(int) onRows,
      ) async {
    final sink = file.openWrite();
    try {
      sink.writeln(
        'timestamp_utc,latitude,longitude,altitude_m,speed_mps,heading_deg,accuracy_m',
      );
      var lastId = 0;
      while (true) {
        final rows = await (_db.select(_db.gpsPointsTable)
          ..where((t) => t.runId.equals(runId) & t.id.isBiggerThanValue(lastId))
          ..orderBy([(t) => OrderingTerm.asc(t.id)])
          ..limit(_pageSize))
            .get();
        if (rows.isEmpty) break;
        final buffer = StringBuffer();
        for (final r in rows) {
          buffer
            ..write(r.recordedAt.toUtc().toIso8601String())
            ..write(',')
            ..write(r.latitude)
            ..write(',')
            ..write(r.longitude)
            ..write(',')
            ..write(r.altitudeMeters ?? '')
            ..write(',')
            ..write(r.speedMetersPerSecond ?? '')
            ..write(',')
            ..write(r.headingDegrees ?? '')
            ..write(',')
            ..write(r.accuracyMeters ?? '')
            ..write('\n');
        }
        sink.write(buffer);
        lastId = rows.last.id;
        onRows(rows.length);
        if (rows.length < _pageSize) break;
      }
    } finally {
      await sink.close();
    }
  }

  /// Escreve `media.csv` e devolve os arquivos de mídia existentes para entrar no ZIP.
  Future<List<_ZipEntry>> _writeMedia(File csv, int runId, String rootName) async {
    final records = await (_db.select(_db.mediaRecordsTable)
      ..where((t) => t.runId.equals(runId))
      ..orderBy([(t) => OrderingTerm.asc(t.recordedAt)]))
        .get();

    final entries = <_ZipEntry>[];
    final usedNames = <String>{};
    final sink = csv.openWrite();
    try {
      sink.writeln('timestamp_utc,type,file_in_zip,latitude,longitude');
      for (final m in records) {
        var fileInZip = '';
        final source = File(m.filePath);
        if (await source.exists()) {
          var name = p.basename(m.filePath);
          if (!usedNames.add(name)) {
            name = '${m.id}_$name';
            usedNames.add(name);
          }
          fileInZip = 'media/$name';
          entries.add(_ZipEntry(source.path, '$rootName/$fileInZip'));
        }
        sink.writeln([
          m.recordedAt.toUtc().toIso8601String(),
          _csvEscape(m.mediaType),
          _csvEscape(fileInZip),
          m.latitude ?? '',
          m.longitude ?? '',
        ].join(','));
      }
    } finally {
      await sink.close();
    }
    return entries;
  }

  Future<String> _buildRunJson(Run run) async {
    Object? configuration;
    if (run.configurationJson != null) {
      try {
        configuration = jsonDecode(run.configurationJson!);
      } catch (_) {
        configuration = run.configurationJson;
      }
    }

    Map<String, Object?>? vehicle;
    final vehicleId = run.vehicleId;
    if (vehicleId != null) {
      try {
        final v = await _db.vehicleDao.getVehicleById(vehicleId);
        vehicle = {
          'id': v.id,
          'name': v.name,
          'model': v.model,
          'licensePlate': v.licensePlate,
          'year': v.year,
          'traction': v.traction,
          'description': v.description,
        };
      } catch (_) {
        // Veículo removido do banco: exporta sem os dados dele.
      }
    }

    return const JsonEncoder.withIndent('  ').convert({
      'id': run.id,
      'title': run.title,
      'startedAtUtc': run.recordedAt.toUtc().toIso8601String(),
      'endedAtUtc': run.endedAt?.toUtc().toIso8601String(),
      'durationSeconds': run.durationSeconds,
      'initialOdometerKm': run.odometer,
      'distanceKm': run.distanceKm,
      'notes': run.notes,
      'synced': run.isSynced,
      'device': {
        'manufacturer': run.deviceManufacturer,
        'model': run.deviceModel,
        'initialBatteryPercent': run.initialBatteryPercent,
        'initialBatteryTemperatureC': run.initialBatteryTemperatureC,
      },
      'counts': {
        'accelerometerSamples': run.accelerometerSampleCount,
        'gpsPoints': run.gpsPointCount,
        'media': run.mediaCount,
      },
      'configuration': configuration,
      'vehicle': vehicle,
    });
  }

  /// Compacta em um isolate separado para não travar a interface.
  static Future<void> _zip(String zipPath, List<_ZipEntry> entries) {
    return Isolate.run(() async {
      final encoder = ZipFileEncoder();
      encoder.create(zipPath);
      try {
        for (final e in entries) {
          await encoder.addFile(File(e.sourcePath), e.pathInZip);
        }
      } finally {
        await encoder.close();
      }
    });
  }

  static String _stamp(DateTime date) {
    final d = date.toLocal();
    String two(int v) => v.toString().padLeft(2, '0');
    return '${d.year}${two(d.month)}${two(d.day)}_${two(d.hour)}${two(d.minute)}${two(d.second)}';
  }

  static String _csvEscape(String value) {
    if (value.contains(RegExp(r'[",\n\r]'))) {
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
  }
}

class _ZipEntry {
  final String sourcePath;
  final String pathInZip;
  const _ZipEntry(this.sourcePath, this.pathInZip);
}