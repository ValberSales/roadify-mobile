import 'dart:async';
import 'dart:isolate';

import 'recording_repository.dart';

typedef SensorSampleBatchCallback =
    void Function(List<RecordedSensorSample> samples);

typedef SensorSamplingErrorCallback =
    void Function(Object error, StackTrace stackTrace);

class SensorSamplingIsolate {
  static const Duration _startupTimeout = Duration(seconds: 5);
  static const Duration _shutdownTimeout = Duration(seconds: 5);

  final Duration batchInterval;
  final Completer<void> _ready = Completer<void>();
  final Completer<void> _stopped = Completer<void>();

  ReceivePort? _receivePort;
  ReceivePort? _errorPort;
  ReceivePort? _exitPort;
  Isolate? _isolate;
  SendPort? _commandPort;
  SensorSampleBatchCallback? _onBatch;
  SensorSamplingErrorCallback? _onError;
  bool _isStopping = false;
  bool _hasFailed = false;

  SensorSamplingIsolate({this.batchInterval = const Duration(seconds: 1)}) {
    if (batchInterval <= Duration.zero) {
      throw ArgumentError.value(
        batchInterval,
        'batchInterval',
        'Must be greater than zero.',
      );
    }
  }

  Future<void> start({
    required DateTime startedAtUtc,
    required SensorSampleBatchCallback onBatch,
    required SensorSamplingErrorCallback onError,
  }) async {
    if (_receivePort != null) {
      throw StateError('The sensor sampling isolate has already been started.');
    }

    _onBatch = onBatch;
    _onError = onError;
    final receivePort = ReceivePort();
    final errorPort = ReceivePort();
    final exitPort = ReceivePort();
    _receivePort = receivePort;
    _errorPort = errorPort;
    _exitPort = exitPort;
    receivePort.listen(_handleMessage);
    errorPort.listen(_handleIsolateError);
    exitPort.listen(_handleIsolateExit);

    try {
      _isolate = await Isolate.spawn<List<Object?>>(
        _sensorSamplingIsolateMain,
        <Object?>[
          receivePort.sendPort,
          startedAtUtc.toUtc().microsecondsSinceEpoch,
          batchInterval.inMicroseconds,
        ],
        onError: errorPort.sendPort,
        onExit: exitPort.sendPort,
        errorsAreFatal: true,
      );
      await _ready.future.timeout(_startupTimeout);
    } catch (_) {
      _isolate?.kill(priority: Isolate.immediate);
      _cleanup();
      rethrow;
    }
  }

  void addAccelerometer({
    required int elapsedMicroseconds,
    required double x,
    required double y,
    required double z,
  }) {
    _send(<Object?>['accelerometer', elapsedMicroseconds, x, y, z]);
  }

  void addGyroscope({required double x, required double y, required double z}) {
    _send(<Object?>['gyroscope', x, y, z]);
  }

  Future<void> stopAndFlush() async {
    if (_receivePort == null) return;
    if (_isStopping) {
      await _stopped.future.timeout(_shutdownTimeout);
      return;
    }
    _isStopping = true;
    if (_hasFailed || _commandPort == null) {
      _cleanup();
      throw StateError('The sensor sampling isolate failed before flushing.');
    }

    try {
      _commandPort!.send(<Object?>['stop']);
      await _stopped.future.timeout(_shutdownTimeout);
    } catch (error, stackTrace) {
      _fail(error, stackTrace);
      rethrow;
    } finally {
      _cleanup();
    }
  }

  void _send(List<Object?> command) {
    final commandPort = _commandPort;
    if (commandPort == null || _isStopping || _hasFailed) {
      throw StateError('The sensor sampling isolate is not accepting samples.');
    }
    commandPort.send(command);
  }

  void _handleIsolateError(Object? message) {
    if (message is List && message.isNotEmpty) {
      _fail(
        StateError('${message.first}'),
        StackTrace.fromString(message.length > 1 ? '${message[1]}' : ''),
      );
      return;
    }
    _fail(StateError('The sensor sampling isolate failed.'));
  }

  void _handleIsolateExit(Object? _) {
    if (!_isStopping && !_hasFailed) {
      _fail(StateError('The sensor sampling isolate exited unexpectedly.'));
    }
  }

  void _handleMessage(Object? message) {
    if (message is List && message.isNotEmpty && message.first == 'error') {
      final error = StateError(
        message.length > 1 ? '${message[1]}' : 'Unknown isolate error.',
      );
      final stack = StackTrace.fromString(
        message.length > 2 ? '${message[2]}' : '',
      );
      _fail(error, stack);
      return;
    }

    if (message is! List || message.isEmpty) return;
    switch (message.first) {
      case 'ready':
        if (message.length < 2 || message[1] is! SendPort) {
          _fail(StateError('Invalid startup response from sensor isolate.'));
          return;
        }
        _commandPort = message[1] as SendPort;
        if (!_ready.isCompleted) _ready.complete();
      case 'batch':
        if (message.length < 2 || message[1] is! List) {
          _fail(StateError('Invalid batch response from sensor isolate.'));
          return;
        }
        try {
          final samples = (message[1] as List)
              .map(_sampleFromMessage)
              .toList(growable: false);
          if (samples.isNotEmpty) _onBatch?.call(samples);
        } catch (error, stackTrace) {
          _fail(error, stackTrace);
        }
      case 'stopped':
        if (!_stopped.isCompleted) _stopped.complete();
      case 'error':
        final error = StateError(
          message.length > 1 ? '${message[1]}' : 'Unknown isolate error.',
        );
        final stack = StackTrace.fromString(
          message.length > 2 ? '${message[2]}' : '',
        );
        _fail(error, stack);
      default:
        _fail(StateError('Unknown message from sensor sampling isolate.'));
    }
  }

  RecordedSensorSample _sampleFromMessage(Object? message) {
    if (message is! List || message.length != 7) {
      throw const FormatException('Invalid sensor sample received.');
    }
    final timestampMicros = message[0];
    if (timestampMicros is! int) {
      throw const FormatException('Invalid timestamp in sensor sample.');
    }
    return RecordedSensorSample(
      recordedAt: DateTime.fromMicrosecondsSinceEpoch(
        timestampMicros,
        isUtc: true,
      ),
      accelerometerX: message[1] as double,
      accelerometerY: message[2] as double,
      accelerometerZ: message[3] as double,
      gyroscopeX: message[4] as double?,
      gyroscopeY: message[5] as double?,
      gyroscopeZ: message[6] as double?,
    );
  }

  void _fail(Object error, [StackTrace? stackTrace]) {
    if (_hasFailed) return;
    _hasFailed = true;
    _onError?.call(error, stackTrace ?? StackTrace.current);
    if (!_ready.isCompleted) _ready.completeError(error);
    if (!_stopped.isCompleted && _isStopping) _stopped.completeError(error);
  }

  void _cleanup() {
    _receivePort?.close();
    _errorPort?.close();
    _exitPort?.close();
    _receivePort = null;
    _errorPort = null;
    _exitPort = null;
    _isolate?.kill(priority: Isolate.immediate);
    _isolate = null;
    _commandPort = null;
  }
}

void _sensorSamplingIsolateMain(List<Object?> args) {
  final mainPort = args[0] as SendPort;
  final startedAtUtcMicros = args[1] as int;
  final batchIntervalMicros = args[2] as int;
  final commandPort = ReceivePort();
  final samples = <List<Object?>>[];
  double? gyroscopeX;
  double? gyroscopeY;
  double? gyroscopeZ;

  void flush() {
    if (samples.isEmpty) return;
    mainPort.send(<Object?>['batch', List<List<Object?>>.of(samples)]);
    samples.clear();
  }

  final timer = Timer.periodic(
    Duration(microseconds: batchIntervalMicros),
    (_) => flush(),
  );
  mainPort.send(<Object?>['ready', commandPort.sendPort]);

  commandPort.listen((Object? message) {
    try {
      if (message is! List || message.isEmpty) {
        throw const FormatException('Invalid sensor sampling command.');
      }
      switch (message.first) {
        case 'accelerometer':
          if (message.length != 5 || message[1] is! int) {
            throw const FormatException('Invalid accelerometer event.');
          }
          samples.add(<Object?>[
            startedAtUtcMicros + (message[1] as int),
            message[2] as double,
            message[3] as double,
            message[4] as double,
            gyroscopeX,
            gyroscopeY,
            gyroscopeZ,
          ]);
        case 'gyroscope':
          if (message.length != 4) {
            throw const FormatException('Invalid gyroscope event.');
          }
          gyroscopeX = message[1] as double;
          gyroscopeY = message[2] as double;
          gyroscopeZ = message[3] as double;
        case 'stop':
          timer.cancel();
          flush();
          mainPort.send(<Object?>['stopped']);
          commandPort.close();
        default:
          throw const FormatException('Unknown sensor sampling command.');
      }
    } catch (error, stackTrace) {
      mainPort.send(<Object?>[
        'error',
        error.toString(),
        stackTrace.toString(),
      ]);
    }
  });
}
