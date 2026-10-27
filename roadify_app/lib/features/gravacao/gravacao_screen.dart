import 'dart:async';
import 'dart:io';
import 'package:battery_plus/battery_plus.dart';
import 'package:camera/camera.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:sensors_plus/sensors_plus.dart';
import '../../core/database/app_database.dart';
import '../../core/di/setup_locator.dart';
import '../../core/theme/app_dimensions.dart';
import '../../core/theme/theme_extensions.dart';
import '../coleta/viewmodels/coleta_viewmodel.dart';
import 'services/recording_repository.dart';
import 'widgets/audio_recording_indicator.dart';
import 'widgets/camera_capture_controls.dart';

/// Tela de Gravação e Telemetria em Pista (Cockpit HUD — RF04).
///
/// Captures configured device streams, batches readings into Drift, and keeps
/// the acquisition state and available media visible to the operator.
class GravacaoScreen extends StatefulWidget {
  final ConfiguracaoColeta configuracao;
  final RecordingRepository? repository;
  final bool captureDeviceSensors;

  const GravacaoScreen({
    super.key,
    required this.configuracao,
    this.repository,
    this.captureDeviceSensors = true,
  });

  @override
  State<GravacaoScreen> createState() => _GravacaoScreenState();
}

class _GravacaoScreenState extends State<GravacaoScreen> {
  late final Stopwatch _stopwatch;
  final Stopwatch _audioStopwatch = Stopwatch();
  final Stopwatch _videoStopwatch = Stopwatch();
  RecordingRepository get _repository =>
      widget.repository ?? RecordingRepository(getIt<AppDatabase>());
  int? _runId;
  Timer? _tickerTimer;
  Timer? _batchTimer;
  Timer? _sensorWatchdogTimer;
  Duration _elapsed = Duration.zero;
  Duration _audioElapsed = Duration.zero;
  Duration _videoElapsed = Duration.zero;

  StreamSubscription<AccelerometerEvent>? _sensorSubscription;
  StreamSubscription<GyroscopeEvent>? _gyroscopeSubscription;
  StreamSubscription<Position>? _gpsSubscription;
  StreamSubscription<Amplitude>? _audioAmplitudeSubscription;
  final int _maxBufferSize = 60;
  final List<double> _bufferX = [];
  final List<double> _bufferY = [];
  final List<double> _bufferZ = [];
  final List<RecordedSensorSample> _pendingSensorSamples = [];
  final List<RecordedGpsPoint> _pendingGpsPoints = [];
  double _currentX = 0.0;
  double _currentY = 0.0;
  double _currentZ = 9.81;
  double? _gyroscopeX;
  double? _gyroscopeY;
  double? _gyroscopeZ;
  Position? _lastPosition;
  DateTime? _lastGpsSampleAt;
  double _lastGpsStoredAtDistanceMeters = 0;
  double _distanceMeters = 0;
  int _sensorSampleCount = 0;
  int _gpsPointCount = 0;
  int _mediaCount = 0;
  bool _isStarting = true;
  bool _startInProgress = false;
  bool _isRecording = false;
  bool _isFlushing = false;
  String? _recordingError;
  String? _metadataWarning;
  String? _optionalSensorWarning;
  String? _mediaError;
  CameraController? _cameraController;
  AudioRecorder? _audioRecorder;
  bool _isRecordingVideo = false;
  bool _isRecordingAudio = false;
  bool _isCapturingMedia = false;
  Timer? _cameraDurationTimer;
  Timer? _audioDurationTimer;
  Timer? _automaticCameraTimer;
  Timer? _automaticAudioTimer;
  double? _nextCameraDistanceMeters;
  double? _nextAudioDistanceMeters;
  double _audioAmplitudeDb = -60;

  // Media capture is tracked independently from sensor samples.
  final List<_RegistroFoto> _fotosCapturadas = [];
  bool _isFinalizing = false;
  bool _isFinalized = false;

  @override
  void initState() {
    super.initState();
    _stopwatch = Stopwatch();

    // Inicializa buffers circulares com zeros
    for (var i = 0; i < _maxBufferSize; i++) {
      _bufferX.add(0.0);
      _bufferY.add(0.0);
      _bufferZ.add(9.81);
    }

    unawaited(_startRecording());
  }

  void _validateCaptureConfiguration() {
    final config = widget.configuracao;
    if (!config.sensoresSelecionados.contains(SensorColeta.acelerometro) ||
        !config.sensoresSelecionados.contains(SensorColeta.gps)) {
      throw StateError('Acelerômetro e GPS são obrigatórios para gravar.');
    }
    if (config.taxaInercialHz < 50 || config.taxaInercialHz > 500) {
      throw StateError(
        'A frequência do acelerômetro deve estar entre 50 e 500 Hz.',
      );
    }
    if (config.taxaGpsHz < 1 || config.taxaGpsHz > 10) {
      throw StateError('A frequência do GPS deve estar entre 1 e 10 Hz.');
    }
    if (!config.intervaloMetros.isFinite || config.intervaloMetros <= 0) {
      throw StateError(
        'O intervalo de gravação deve ser uma distância positiva.',
      );
    }
    if (config.sensoresSelecionados.contains(SensorColeta.giroscopio) &&
        (config.sensoresOpcionais.gyroscopeFrequencyHz < 50 ||
            config.sensoresOpcionais.gyroscopeFrequencyHz > 500)) {
      throw StateError(
        'A frequência do giroscópio deve estar entre 50 e 500 Hz.',
      );
    }
    if (config.sensoresSelecionados.contains(SensorColeta.camera)) {
      final camera = config.sensoresOpcionais.camera;
      if (camera.mediaType != CameraMediaType.photos &&
          (camera.videoDurationSeconds < 1 ||
              camera.videoDurationSeconds > 120)) {
        throw StateError(
          'A duração máxima do vídeo deve ser de 1 a 120 segundos.',
        );
      }
      if (camera.automatic) {
        _validateAutomaticInterval(camera.interval, camera.intervalUnit);
      }
    }
    if (config.sensoresSelecionados.contains(SensorColeta.audio)) {
      final audio = config.sensoresOpcionais.audio;
      if (audio.durationSeconds < 1 || audio.durationSeconds > 300) {
        throw StateError(
          'A duração máxima do áudio deve ser de 1 a 300 segundos.',
        );
      }
      if (audio.automatic) {
        _validateAutomaticInterval(audio.interval, audio.intervalUnit);
      }
    }
  }

  void _validateAutomaticInterval(int interval, CaptureIntervalUnit unit) {
    final (minimum, maximum) = switch (unit) {
      CaptureIntervalUnit.minutes => (1, 59),
      CaptureIntervalUnit.hours => (1, 24),
      CaptureIntervalUnit.meters => (1, 9999),
      CaptureIntervalUnit.kilometers => (1, 999),
    };
    if (interval < minimum || interval > maximum) {
      throw StateError(
        'O intervalo automático deve estar entre $minimum e $maximum ${_intervalLabel(unit)}.',
      );
    }
  }

  Future<void> _startRecording() async {
    if (_startInProgress || _runId != null) return;
    _startInProgress = true;
    if (mounted) {
      setState(() {
        _isStarting = true;
        _recordingError = null;
        _metadataWarning = null;
        _optionalSensorWarning = null;
      });
    }
    try {
      _validateCaptureConfiguration();
      String? manufacturer;
      String? model;
      int? batteryPercent;
      if (widget.captureDeviceSensors) {
        await _ensureLocationPermission();
        try {
          final device = await DeviceInfoPlugin().deviceInfo;
          manufacturer = Platform.isIOS
              ? 'Apple'
              : device.data['manufacturer']?.toString();
          model = device.data['model']?.toString();
        } catch (error) {
          _metadataWarning =
              'Fabricante/modelo do aparelho indisponíveis: $error';
        }
        try {
          batteryPercent = await Battery().batteryLevel;
        } catch (error) {
          _metadataWarning = [
            if (_metadataWarning != null) _metadataWarning,
            'Nível de bateria indisponível: $error',
          ].join(' ');
        }
      }

      final startedAt = DateTime.now();
      _runId = await _repository.startRun(
        configuration: widget.configuracao,
        startedAt: startedAt,
        manufacturer: manufacturer,
        model: model,
        batteryPercent: batteryPercent,
      );

      if (widget.captureDeviceSensors) {
        await WakelockPlus.enable();
        _startSensorStreams();
        _startGpsStream();
        unawaited(_initializeOptionalMedia());
      }

      _stopwatch.start();
      _batchTimer = Timer.periodic(
        const Duration(seconds: 1),
        (_) => unawaited(_flushPendingSamples()),
      );
      _tickerTimer = Timer.periodic(const Duration(milliseconds: 100), (_) {
        if (!mounted) return;
        setState(() {
          _elapsed = _stopwatch.elapsed;
          if (_isRecordingAudio) _audioElapsed = _audioStopwatch.elapsed;
          if (_isRecordingVideo) _videoElapsed = _videoStopwatch.elapsed;
        });
      });
      _startInProgress = false;
      if (mounted) {
        setState(() {
          _isStarting = false;
          _isRecording = true;
        });
      }
    } catch (error) {
      _startInProgress = false;
      if (!mounted) return;
      setState(() {
        _isStarting = false;
        _recordingError = 'Não foi possível iniciar a coleta: $error';
      });
    }
  }

  Future<void> _ensureLocationPermission() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw StateError('Ative o serviço de localização para iniciar a coleta.');
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied) {
      throw StateError('A permissão de localização foi negada.');
    }
    if (permission == LocationPermission.deniedForever) {
      throw StateError(
        'A permissão de localização está bloqueada. Habilite-a nas configurações do dispositivo.',
      );
    }
  }

  void _startSensorStreams() {
    _sensorWatchdogTimer = Timer(const Duration(seconds: 5), () {
      if (_sensorSampleCount == 0) {
        _handleStreamFailure(
          'O acelerômetro não forneceu leituras. Verifique a disponibilidade do sensor.',
        );
      }
    });
    final accelPeriod = Duration(
      microseconds: (1000000 / widget.configuracao.taxaInercialHz).round(),
    );
    _sensorSubscription = accelerometerEventStream(samplingPeriod: accelPeriod)
        .listen(
          _onAccelerometer,
          onError: (Object error) =>
              _handleStreamFailure('Falha ao ler o acelerômetro: $error'),
          onDone: () => _handleStreamFailure(
            'O fluxo do acelerômetro foi encerrado inesperadamente.',
          ),
          cancelOnError: true,
        );

    if (widget.configuracao.sensoresSelecionados.contains(
      SensorColeta.giroscopio,
    )) {
      final gyroPeriod = Duration(
        microseconds:
            (1000000 /
                    widget.configuracao.sensoresOpcionais.gyroscopeFrequencyHz)
                .round(),
      );
      _gyroscopeSubscription = gyroscopeEventStream(samplingPeriod: gyroPeriod)
          .listen(
            (event) {
              _gyroscopeX = event.x;
              _gyroscopeY = event.y;
              _gyroscopeZ = event.z;
            },
            onError: (Object error) => _handleOptionalSensorFailure(
              'Giroscópio indisponível; a coleta inercial continua: $error',
            ),
            onDone: () => _handleOptionalSensorFailure(
              'O fluxo do giroscópio foi encerrado; a coleta inercial continua.',
            ),
            cancelOnError: true,
          );
    }
  }

  void _onAccelerometer(AccelerometerEvent event) {
    if (!mounted || !_isRecording && !_isStarting) return;
    _sensorWatchdogTimer?.cancel();
    final now = DateTime.now().toUtc();
    _currentX = event.x;
    _currentY = event.y;
    _currentZ = event.z;
    _bufferX.add(event.x);
    _bufferY.add(event.y);
    _bufferZ.add(event.z);
    if (_bufferX.length > _maxBufferSize) {
      _bufferX.removeAt(0);
      _bufferY.removeAt(0);
      _bufferZ.removeAt(0);
    }

    _pendingSensorSamples.add(
      RecordedSensorSample(
        recordedAt: now,
        accelerometerX: event.x,
        accelerometerY: event.y,
        accelerometerZ: event.z,
        gyroscopeX: _gyroscopeX,
        gyroscopeY: _gyroscopeY,
        gyroscopeZ: _gyroscopeZ,
      ),
    );
    _sensorSampleCount++;
    if (_pendingSensorSamples.length + _pendingGpsPoints.length >= 1000) {
      _handleStreamFailure(
        'O banco local não está acompanhando a aquisição. A captura foi pausada para preservar as amostras pendentes.',
      );
    }
  }

  void _startGpsStream() {
    final accuracy = LocationAccuracy.best;
    final interval = Duration(
      microseconds: (1000000 / widget.configuracao.taxaGpsHz).round(),
    );
    final LocationSettings locationSettings;
    if (Platform.isAndroid) {
      locationSettings = AndroidSettings(
        accuracy: accuracy,
        distanceFilter: 0,
        intervalDuration: interval,
      );
    } else if (Platform.isIOS) {
      locationSettings = AppleSettings(
        accuracy: accuracy,
        distanceFilter: 0,
        activityType: ActivityType.automotiveNavigation,
        pauseLocationUpdatesAutomatically: false,
        allowBackgroundLocationUpdates: false,
      );
    } else {
      locationSettings = LocationSettings(
        accuracy: accuracy,
        distanceFilter: 0,
      );
    }
    _gpsSubscription =
        Geolocator.getPositionStream(locationSettings: locationSettings).listen(
          _onPosition,
          onError: (Object error) =>
              _handleStreamFailure('Falha ao receber dados do GPS: $error'),
          onDone: () => _handleStreamFailure(
            'O fluxo do GPS foi encerrado inesperadamente.',
          ),
          cancelOnError: true,
        );
  }

  void _onPosition(Position position) {
    if (!mounted || !_isRecording && !_isStarting) return;
    final now = DateTime.now().toUtc();
    final minInterval = Duration(
      microseconds: (1000000 / widget.configuracao.taxaGpsHz).round(),
    );
    if (_lastGpsSampleAt != null &&
        now.difference(_lastGpsSampleAt!) < minInterval) {
      return;
    }

    final previous = _lastPosition;
    if (previous != null) {
      final segmentMeters = Geolocator.distanceBetween(
        previous.latitude,
        previous.longitude,
        position.latitude,
        position.longitude,
      );
      if (segmentMeters.isFinite && segmentMeters > 0 && segmentMeters < 200) {
        _distanceMeters += segmentMeters;
      }
    }
    _lastPosition = position;
    _lastGpsSampleAt = now;
    final minimumDistanceMeters = widget.configuracao.intervaloMetros;
    if (_gpsPointCount == 0 ||
        _distanceMeters - _lastGpsStoredAtDistanceMeters >=
            minimumDistanceMeters) {
      _pendingGpsPoints.add(
        RecordedGpsPoint(
          recordedAt: now,
          latitude: position.latitude,
          longitude: position.longitude,
          altitudeMeters: position.altitude,
          speedMetersPerSecond: position.speed,
          headingDegrees: position.heading,
          accuracyMeters: position.accuracy,
        ),
      );
      _gpsPointCount++;
      _lastGpsStoredAtDistanceMeters = _distanceMeters;
    }

    final cameraDistance = _nextCameraDistanceMeters;
    if (cameraDistance != null && _distanceMeters >= cameraDistance) {
      _nextCameraDistanceMeters =
          cameraDistance +
          _distanceIntervalMeters(
            widget.configuracao.sensoresOpcionais.camera.interval,
            widget.configuracao.sensoresOpcionais.camera.intervalUnit,
          );
      unawaited(_captureCameraMedia(automatic: true));
    }
    final audioDistance = _nextAudioDistanceMeters;
    if (audioDistance != null && _distanceMeters >= audioDistance) {
      _nextAudioDistanceMeters =
          audioDistance +
          _distanceIntervalMeters(
            widget.configuracao.sensoresOpcionais.audio.interval,
            widget.configuracao.sensoresOpcionais.audio.intervalUnit,
          );
      unawaited(_captureAudio());
    }
  }

  Future<void> _initializeOptionalMedia() async {
    final config = widget.configuracao;
    if (config.sensoresSelecionados.contains(SensorColeta.camera)) {
      try {
        final cameras = await availableCameras();
        final requestedDirection =
            config.sensoresOpcionais.camera.facing == CameraFacing.front
            ? CameraLensDirection.front
            : CameraLensDirection.back;
        final matchingCameras = cameras.where(
          (item) => item.lensDirection == requestedDirection,
        );
        if (matchingCameras.isEmpty) {
          throw StateError('A câmera selecionada não está disponível.');
        }
        final controller = CameraController(
          matchingCameras.first,
          ResolutionPreset.medium,
          enableAudio: config.sensoresSelecionados.contains(SensorColeta.audio),
        );
        await controller.initialize();
        if (!mounted) {
          await controller.dispose();
          return;
        }
        setState(() {
          _cameraController = controller;
          _mediaError = null;
        });
        _scheduleAutomaticCameraCapture();
      } catch (error) {
        if (mounted) {
          setState(() => _mediaError = 'Câmera indisponível: $error');
        }
      }
    }

    if (config.sensoresSelecionados.contains(SensorColeta.audio)) {
      try {
        _audioRecorder = AudioRecorder();
        _scheduleAutomaticAudioCapture();
      } catch (error) {
        if (mounted) {
          setState(() => _mediaError = 'Áudio indisponível: $error');
        }
      }
    }
  }

  void _scheduleAutomaticCameraCapture() {
    final settings = widget.configuracao.sensoresOpcionais.camera;
    if (!settings.automatic) return;
    if (settings.intervalUnit == CaptureIntervalUnit.meters ||
        settings.intervalUnit == CaptureIntervalUnit.kilometers) {
      _nextCameraDistanceMeters = _distanceIntervalMeters(
        settings.interval,
        settings.intervalUnit,
      );
      return;
    }
    _automaticCameraTimer = Timer.periodic(
      _timeInterval(settings.interval, settings.intervalUnit),
      (_) => unawaited(_captureCameraMedia(automatic: true)),
    );
  }

  void _scheduleAutomaticAudioCapture() {
    final settings = widget.configuracao.sensoresOpcionais.audio;
    if (!settings.automatic) return;
    if (settings.intervalUnit == CaptureIntervalUnit.meters ||
        settings.intervalUnit == CaptureIntervalUnit.kilometers) {
      _nextAudioDistanceMeters = _distanceIntervalMeters(
        settings.interval,
        settings.intervalUnit,
      );
      return;
    }
    _automaticAudioTimer = Timer.periodic(
      _timeInterval(settings.interval, settings.intervalUnit),
      (_) => unawaited(_captureAudio()),
    );
  }

  Duration _timeInterval(int amount, CaptureIntervalUnit unit) =>
      switch (unit) {
        CaptureIntervalUnit.minutes => Duration(minutes: amount),
        CaptureIntervalUnit.hours => Duration(hours: amount),
        CaptureIntervalUnit.meters ||
        CaptureIntervalUnit.kilometers => Duration.zero,
      };

  double _distanceIntervalMeters(int amount, CaptureIntervalUnit unit) =>
      unit == CaptureIntervalUnit.kilometers
      ? amount * 1000
      : amount.toDouble();

  Future<void> _captureCameraMedia({
    bool automatic = false,
    bool video = false,
  }) async {
    if (automatic && _isRecordingVideo) return;
    if (_isCapturingMedia || _runId == null) return;
    final controller = _cameraController;
    if (controller == null || !controller.value.isInitialized) {
      _showMediaError(_mediaError ?? 'A câmera ainda não está pronta.');
      return;
    }

    _isCapturingMedia = true;
    try {
      final mediaType = widget.configuracao.sensoresOpcionais.camera.mediaType;
      final takeVideo =
          _isRecordingVideo ||
          video ||
          mediaType == CameraMediaType.videos ||
          (automatic && mediaType == CameraMediaType.videos);
      if (takeVideo) {
        if (_isRecordingVideo) {
          _cameraDurationTimer?.cancel();
          _videoStopwatch.stop();
          final file = await controller.stopVideoRecording();
          _isRecordingVideo = false;
          await _saveMediaFile(file, 'video');
        } else {
          await controller.startVideoRecording();
          _isRecordingVideo = true;
          _videoElapsed = Duration.zero;
          _videoStopwatch
            ..reset()
            ..start();
          _cameraDurationTimer = Timer(
            Duration(
              seconds: widget
                  .configuracao
                  .sensoresOpcionais
                  .camera
                  .videoDurationSeconds,
            ),
            () => unawaited(_stopVideoRecording()),
          );
        }
      } else {
        final file = await controller.takePicture();
        await _saveMediaFile(file, 'photo');
      }
      if (mounted) setState(() {});
    } catch (error) {
      _showMediaError('Falha ao capturar mídia: $error');
    } finally {
      _isCapturingMedia = false;
    }
  }

  void _alternarVideo() => unawaited(_captureCameraMedia(video: true));

  Future<void> _stopVideoRecording({bool propagate = false}) async {
    final controller = _cameraController;
    if (controller == null || !_isRecordingVideo) return;
    try {
      _cameraDurationTimer?.cancel();
      _videoStopwatch.stop();
      final file = await controller.stopVideoRecording();
      _isRecordingVideo = false;
      await _saveMediaFile(file, 'video');
      if (mounted) setState(() => _videoElapsed = _videoStopwatch.elapsed);
    } catch (error) {
      _showMediaError('Falha ao finalizar o vídeo: $error');
      if (propagate) rethrow;
    }
  }

  Future<void> _captureAudio() async {
    if (_isRecordingAudio || _runId == null || _audioRecorder == null) return;
    try {
      if (!await _audioRecorder!.hasPermission()) {
        throw StateError('Permissão do microfone não concedida.');
      }
      final directory = await _mediaDirectory();
      final audioPath = path.join(
        directory.path,
        'audio_${DateTime.now().toUtc().millisecondsSinceEpoch}.m4a',
      );
      await _audioRecorder!.start(
        const RecordConfig(encoder: AudioEncoder.aacLc),
        path: audioPath,
      );
      _isRecordingAudio = true;
      _audioElapsed = Duration.zero;
      _audioAmplitudeDb = -60;
      _audioStopwatch
        ..reset()
        ..start();
      _audioAmplitudeSubscription = _audioRecorder!
          .onAmplitudeChanged(const Duration(milliseconds: 200))
          .listen(
            (amplitude) {
              if (!mounted || !_isRecordingAudio) return;
              setState(() => _audioAmplitudeDb = amplitude.current);
            },
            onError: (Object error) =>
                _showMediaError('Falha ao medir o nível de áudio: $error'),
          );
      _audioDurationTimer?.cancel();
      _audioDurationTimer = Timer(
        Duration(
          seconds: widget.configuracao.sensoresOpcionais.audio.durationSeconds,
        ),
        () => unawaited(_stopAudioRecording()),
      );
      if (mounted) setState(() {});
    } catch (error) {
      _showMediaError('Falha ao iniciar a gravação de áudio: $error');
    }
  }

  Future<void> _stopAudioRecording({bool propagate = false}) async {
    if (!_isRecordingAudio || _audioRecorder == null) return;
    try {
      _audioDurationTimer?.cancel();
      _audioStopwatch.stop();
      await _audioAmplitudeSubscription?.cancel();
      _audioAmplitudeSubscription = null;
      final filePath = await _audioRecorder!.stop();
      _isRecordingAudio = false;
      if (filePath != null) {
        await _saveMediaFile(XFile(filePath), 'audio');
      }
      if (mounted) setState(() {});
    } catch (error) {
      _showMediaError('Falha ao finalizar o áudio: $error');
      if (propagate) rethrow;
    }
  }

  Future<void> _saveMediaFile(XFile file, String type) async {
    final directory = await _mediaDirectory();
    final timestamp = DateTime.now().toUtc();
    final extension = path.extension(file.path);
    final savedFile = await File(file.path).copy(
      path.join(
        directory.path,
        '${type}_${timestamp.millisecondsSinceEpoch}$extension',
      ),
    );
    final position = _lastPosition;
    final mediaId = await _repository.saveMedia(
      runId: _runId!,
      mediaType: type,
      filePath: savedFile.path,
      recordedAt: timestamp,
      latitude: position?.latitude,
      longitude: position?.longitude,
    );
    if (path.normalize(file.path) != path.normalize(savedFile.path)) {
      await File(file.path).delete();
    }
    _mediaCount++;
    if (type == 'photo' && mounted) {
      setState(() {
        _fotosCapturadas.add(
          _RegistroFoto(
            id: mediaId,
            timestamp: timestamp,
            latitude: position?.latitude,
            longitude: position?.longitude,
            odometroKm:
                widget.configuracao.odometroInicial + _distanceMeters / 1000,
            filePath: savedFile.path,
          ),
        );
      });
    }
  }

  Future<Directory> _mediaDirectory() async {
    final documents = await getApplicationDocumentsDirectory();
    final directory = Directory(
      path.join(documents.path, 'roadify', 'runs', _runId.toString()),
    );
    await directory.create(recursive: true);
    return directory;
  }

  void _showMediaError(String message) {
    if (!mounted) return;
    setState(() => _mediaError = message);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _handleStreamFailure(String message) {
    if (!mounted) return;
    _sensorWatchdogTimer?.cancel();
    setState(() {
      _recordingError = message;
      _isRecording = false;
    });
    _stopwatch.stop();
    _tickerTimer?.cancel();
    _batchTimer?.cancel();
    unawaited(_cancelSensorStreams());
  }

  void _handleOptionalSensorFailure(String message) {
    if (!mounted || !_isRecording && !_isStarting) return;
    setState(() => _optionalSensorWarning = message);
    unawaited(_gyroscopeSubscription?.cancel());
    _gyroscopeSubscription = null;
  }

  Future<void> _cancelSensorStreams() async {
    await _sensorSubscription?.cancel();
    await _gyroscopeSubscription?.cancel();
    await _gpsSubscription?.cancel();
    _sensorSubscription = null;
    _gyroscopeSubscription = null;
    _gpsSubscription = null;
  }

  Future<void> _flushPendingSamples({bool propagate = false}) async {
    if (_isFlushing || _runId == null) return;
    if (_pendingSensorSamples.isEmpty && _pendingGpsPoints.isEmpty) return;
    _isFlushing = true;
    final samples = List<RecordedSensorSample>.of(_pendingSensorSamples);
    final points = List<RecordedGpsPoint>.of(_pendingGpsPoints);
    _pendingSensorSamples.clear();
    _pendingGpsPoints.clear();
    try {
      await _repository.saveBatch(
        runId: _runId!,
        sensorSamples: samples,
        gpsPoints: points,
        sensorSampleCount: _sensorSampleCount,
        gpsPointCount: _gpsPointCount,
        distanceKm: _distanceMeters / 1000,
      );
    } catch (error) {
      _pendingSensorSamples.insertAll(0, samples);
      _pendingGpsPoints.insertAll(0, points);
      _handleStreamFailure('Falha ao salvar um lote local: $error');
      if (propagate) rethrow;
    } finally {
      _isFlushing = false;
    }
  }

  @override
  void dispose() {
    _tickerTimer?.cancel();
    _batchTimer?.cancel();
    _sensorWatchdogTimer?.cancel();
    _cameraDurationTimer?.cancel();
    _audioDurationTimer?.cancel();
    _automaticCameraTimer?.cancel();
    _automaticAudioTimer?.cancel();
    unawaited(_audioAmplitudeSubscription?.cancel());
    unawaited(_cancelSensorStreams());
    unawaited(_cameraController?.dispose());
    unawaited(_audioRecorder?.dispose());
    if (widget.captureDeviceSensors) unawaited(WakelockPlus.disable());
    _stopwatch.stop();
    super.dispose();
  }

  String _formatDuration(Duration d) {
    final hours = d.inHours.toString().padLeft(2, '0');
    final minutes = (d.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }

  String _intervalLabel(CaptureIntervalUnit unit) => switch (unit) {
    CaptureIntervalUnit.minutes => 'min',
    CaptureIntervalUnit.hours => 'h',
    CaptureIntervalUnit.meters => 'm',
    CaptureIntervalUnit.kilometers => 'km',
  };

  String _collectionSettingsSummary() {
    final config = widget.configuracao;
    final optional = config.sensoresOpcionais;
    final details = <String>[];

    if (config.sensoresSelecionados.contains(SensorColeta.giroscopio)) {
      details.add('Giroscópio ${optional.gyroscopeFrequencyHz} Hz');
    }
    if (config.sensoresSelecionados.contains(SensorColeta.camera)) {
      final media = switch (optional.camera.mediaType) {
        CameraMediaType.photos => 'fotos',
        CameraMediaType.videos => 'vídeos',
        CameraMediaType.photosAndVideos => 'fotos e vídeos',
      };
      final facing = switch (optional.camera.facing) {
        CameraFacing.front => 'frontal',
        CameraFacing.rear => 'traseira',
      };
      final schedule = optional.camera.automatic
          ? ' • automático a cada ${optional.camera.interval}'
                ' ${_intervalLabel(optional.camera.intervalUnit)}'
          : '';
      final videoDuration = optional.camera.mediaType == CameraMediaType.photos
          ? ''
          : ' • vídeo até ${optional.camera.videoDurationSeconds}s';
      details.add('Câmera $facing: $media$videoDuration$schedule');
    }
    if (config.sensoresSelecionados.contains(SensorColeta.audio)) {
      details.add(
        optional.audio.automatic
            ? 'Áudio: a cada ${optional.audio.interval}'
                  ' ${_intervalLabel(optional.audio.intervalUnit)}, '
                  '${optional.audio.durationSeconds}s'
            : 'Áudio: acionamento manual',
      );
    }

    return details.join(' • ');
  }

  void _capturarFoto() => unawaited(_captureCameraMedia());

  void _exibirDetalhesFoto(_RegistroFoto foto) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.place_rounded, color: Colors.teal),
            const SizedBox(width: 8),
            Text('Foto #${foto.id} (Geotag)'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 120,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.black12,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade400),
              ),
              child: Image.file(
                File(foto.filePath),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const Center(
                  child: Icon(Icons.broken_image_outlined, size: 36),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              foto.latitude == null
                  ? 'Latitude: sem posição GPS disponível'
                  : 'Latitude: ${foto.latitude!.toStringAsFixed(6)}',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            Text(
              foto.longitude == null
                  ? 'Longitude: sem posição GPS disponível'
                  : 'Longitude: ${foto.longitude!.toStringAsFixed(6)}',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            Text(
              'Kilometragem estimada: ${foto.odometroKm.toStringAsFixed(2)} km',
            ),
            Text(
              'Horário: ${foto.timestamp.hour.toString().padLeft(2, '0')}:${foto.timestamp.minute.toString().padLeft(2, '0')}:${foto.timestamp.second.toString().padLeft(2, '0')}',
            ),
            const SizedBox(height: 8),
            Text(
              'Arquivo: ${path.basename(foto.filePath)}',
              style: TextStyle(
                fontSize: 11,
                fontStyle: FontStyle.italic,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmarFinalizacao() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Finalizar Coleta?'),
        content: Text(
          'Deseja encerrar este ensaio? Serão salvos $_sensorSampleCount amostras inerciais, '
          '$_gpsPointCount pontos GPS e $_mediaCount arquivos de mídia no armazenamento local.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Continuar Coletando'),
          ),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
              foregroundColor: Theme.of(ctx).colorScheme.onError,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            icon: const Icon(Icons.check_rounded, size: 18),
            label: const Text('Finalizar e Salvar'),
          ),
        ],
      ),
    );

    if (confirmar == true && mounted) {
      await _salvarEFechar();
    }
  }

  Future<void> _salvarEFechar() async {
    if (_isStarting || _runId == null) return;
    _stopwatch.stop();
    _isRecording = false;
    setState(() => _isFinalizing = true);
    _tickerTimer?.cancel();
    _batchTimer?.cancel();
    _automaticCameraTimer?.cancel();
    _automaticAudioTimer?.cancel();

    try {
      await _cancelSensorStreams();
      if (_isRecordingVideo) await _stopVideoRecording(propagate: true);
      if (_isRecordingAudio) await _stopAudioRecording(propagate: true);
      while (_isFlushing) {
        await Future<void>.delayed(const Duration(milliseconds: 10));
      }
      await _flushPendingSamples(propagate: true);
      await _repository.finishRun(
        runId: _runId!,
        endedAt: DateTime.now(),
        duration: _elapsed,
        distanceKm: _distanceMeters / 1000,
        sensorSampleCount: _sensorSampleCount,
        gpsPointCount: _gpsPointCount,
        mediaCount: _mediaCount,
      );
      _isFinalized = true;
      if (widget.captureDeviceSensors) await WakelockPlus.disable();
      await _cameraController?.dispose();
      await _audioRecorder?.dispose();
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isFinalizing = false;
        _recordingError = 'Não foi possível salvar a coleta: $error';
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_recordingError!)));
      return;
    }

    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;

    return PopScope<Object?>(
      canPop: (_runId == null && !_startInProgress) || _isFinalized,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Finalize ou salve a coleta antes de sair.'),
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Coleta em Andamento'),
          automaticallyImplyLeading: false,
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: _isRecording
                          ? Colors.red
                          : _recordingError != null
                          ? colors.error
                          : Colors.amber,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _isRecording
                        ? 'GRAVANDO'
                        : _isStarting
                        ? 'PREPARANDO'
                        : 'PAUSADA',
                    style: typography.labelMedium?.copyWith(
                      color: _isRecording
                          ? Colors.red
                          : _recordingError != null
                          ? colors.error
                          : Colors.amber.shade900,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(76),
            child: Container(
              key: const ValueKey('sticky-recording-telemetry'),
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'TEMPO DECORRIDO',
                        style: typography.labelSmall?.copyWith(
                          color: colors.onSurfaceVariant,
                          letterSpacing: 0.8,
                        ),
                      ),
                      Text(
                        _formatDuration(_elapsed),
                        key: const ValueKey('elapsed-time-sticky'),
                        style: typography.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  _StickyMetric(
                    label: 'VELOCIDADE',
                    value: _lastPosition?.speed.isFinite == true
                        ? '${((_lastPosition!.speed * 3.6).round())} km/h'
                        : '-- km/h',
                    icon: Icons.speed_rounded,
                  ),
                  const SizedBox(width: 14),
                  _StickyMetric(
                    label: 'DISTÂNCIA',
                    value: '${(_distanceMeters / 1000).toStringAsFixed(2)} km',
                    icon: Icons.route_rounded,
                  ),
                ],
              ),
            ),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              AppDimensions.space20,
              AppDimensions.space12,
              AppDimensions.space20,
              AppDimensions.space24,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_recordingError != null) ...[
                  Card(
                    color: colors.errorContainer,
                    child: Padding(
                      padding: const EdgeInsets.all(AppDimensions.space12),
                      child: Text(
                        _recordingError!,
                        style: TextStyle(color: colors.onErrorContainer),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppDimensions.space12),
                ],
                if (_metadataWarning != null) ...[
                  Card(
                    color: colors.tertiaryContainer,
                    child: Padding(
                      padding: const EdgeInsets.all(AppDimensions.space12),
                      child: Text(
                        _metadataWarning!,
                        style: TextStyle(color: colors.onTertiaryContainer),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppDimensions.space12),
                ],
                if (_optionalSensorWarning != null) ...[
                  Card(
                    color: colors.tertiaryContainer,
                    child: Padding(
                      padding: const EdgeInsets.all(AppDimensions.space12),
                      child: Text(
                        _optionalSensorWarning!,
                        style: TextStyle(color: colors.onTertiaryContainer),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppDimensions.space12),
                ],
                // --- CONFIGURAÇÃO POR SENSOR ---
                Container(
                  padding: const EdgeInsets.all(AppDimensions.space16),
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: AppDimensions.borderRadiusCard,
                    border: Border.all(color: colors.outlineVariant),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.tune_rounded,
                            size: 18,
                            color: colors.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Sensores e parâmetros',
                            style: typography.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: AppDimensions.space8,
                        runSpacing: AppDimensions.space8,
                        children: [
                          _ParamBadge(
                            label: 'Acelerômetro',
                            value: '${widget.configuracao.taxaInercialHz} Hz',
                            icon: Icons.speed_rounded,
                          ),
                          _ParamBadge(
                            label: 'GPS',
                            value:
                                '${widget.configuracao.taxaGpsHz} Hz • a cada '
                                '${widget.configuracao.intervaloMetros.toStringAsFixed(0)} m',
                            icon: Icons.gps_fixed_rounded,
                          ),
                          if (widget.configuracao.sensoresSelecionados.contains(
                            SensorColeta.giroscopio,
                          ))
                            _ParamBadge(
                              label: 'Giroscópio',
                              value:
                                  '${widget.configuracao.sensoresOpcionais.gyroscopeFrequencyHz} Hz',
                              icon: Icons.screen_rotation_rounded,
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: widget.configuracao.sensoresSelecionados.map((
                          s,
                        ) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: colors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _iconForSensor(s),
                                  size: 14,
                                  color: colors.primary,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  _nameForSensor(s),
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: colors.primary,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                      if (_collectionSettingsSummary().isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          _collectionSettingsSummary(),
                          key: const ValueKey('optional-capture-settings'),
                          style: typography.bodySmall?.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: AppDimensions.space16),

                // --- 3. STATUS REAL DA AQUISIÇÃO ---
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(AppDimensions.space16),
                        decoration: BoxDecoration(
                          color: colors.surface,
                          borderRadius: AppDimensions.borderRadiusCard,
                          border: Border.all(color: colors.outlineVariant),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.show_chart_rounded,
                                  size: 16,
                                  color: colors.primary,
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    'Amostras',
                                    style: typography.labelSmall?.copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '$_sensorSampleCount',
                              style: typography.titleMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'acelerômetro${widget.configuracao.sensoresSelecionados.contains(SensorColeta.giroscopio) ? ' + giroscópio' : ''}',
                              style: typography.bodySmall?.copyWith(
                                fontSize: 11,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(AppDimensions.space16),
                        decoration: BoxDecoration(
                          color: colors.surface,
                          borderRadius: AppDimensions.borderRadiusCard,
                          border: Border.all(color: colors.outlineVariant),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.gps_fixed_rounded,
                                  size: 16,
                                  color: colors.primary,
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    'Pontos GPS',
                                    style: typography.labelSmall?.copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '$_gpsPointCount',
                              style: typography.titleMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${(_distanceMeters / 1000).toStringAsFixed(2)} km',
                              style: typography.bodySmall?.copyWith(
                                fontSize: 11,
                                color: colors.onSurfaceVariant,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppDimensions.space16),

                // --- 4. GRÁFICO EM TEMPO REAL DO ACELERÔMETRO ---
                Container(
                  padding: const EdgeInsets.all(AppDimensions.space16),
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: AppDimensions.borderRadiusCard,
                    border: Border.all(color: colors.outlineVariant),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.show_chart_rounded,
                                size: 18,
                                color: colors.primary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Acelerômetro ao Vivo',
                                style: typography.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          // Valores numéricos instantâneos
                          Row(
                            children: [
                              _AxisValueBadge(
                                label: 'X',
                                value: _currentX,
                                color: const Color(0xFF10B981),
                              ),
                              const SizedBox(width: 6),
                              _AxisValueBadge(
                                label: 'Y',
                                value: _currentY,
                                color: const Color(0xFF06B6D4),
                              ),
                              const SizedBox(width: 6),
                              _AxisValueBadge(
                                label: 'Z',
                                value: _currentZ,
                                color: const Color(0xFFF59E0B),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 150,
                        width: double.infinity,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: CustomPaint(
                            painter: _OscilloscopePainter(
                              bufferX: _bufferX,
                              bufferY: _bufferY,
                              bufferZ: _bufferZ,
                              colorX: const Color(0xFF10B981),
                              colorY: const Color(0xFF06B6D4),
                              colorZ: const Color(0xFFF59E0B),
                              gridColor: colors.outlineVariant.withValues(
                                alpha: 0.5,
                              ),
                              backgroundColor: context.isDarkMode
                                  ? const Color(0xFF0D1F18)
                                  : const Color(0xFFF1F5F3),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppDimensions.space16),

                // --- 5. MÍDIA DA COLETA ---
                if (widget.configuracao.sensoresSelecionados.contains(
                  SensorColeta.camera,
                )) ...[
                  Container(
                    padding: const EdgeInsets.all(AppDimensions.space16),
                    decoration: BoxDecoration(
                      color: colors.surface,
                      borderRadius: AppDimensions.borderRadiusCard,
                      border: Border.all(
                        color: _fotosCapturadas.isNotEmpty
                            ? colors.primary.withValues(alpha: 0.5)
                            : colors.outlineVariant,
                        width: _fotosCapturadas.isNotEmpty ? 1.6 : 1.0,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.add_a_photo_rounded,
                                  size: 18,
                                  color: colors.primary,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Câmera • Foto e vídeo',
                                  style: typography.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: _fotosCapturadas.isEmpty
                                    ? colors.surfaceContainerHighest
                                    : colors.primary.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '$_mediaCount ${_mediaCount == 1 ? 'arquivo' : 'arquivos'}',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: _fotosCapturadas.isEmpty
                                      ? colors.onSurfaceVariant
                                      : colors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        CameraCaptureControls(
                          controller: _cameraController,
                          mediaType: widget
                              .configuracao
                              .sensoresOpcionais
                              .camera
                              .mediaType,
                          isVideoRecording: _isRecordingVideo,
                          isBusy: _isCapturingMedia,
                          videoElapsed: _videoElapsed,
                          videoDurationSeconds: widget
                              .configuracao
                              .sensoresOpcionais
                              .camera
                              .videoDurationSeconds,
                          errorMessage: _mediaError,
                          onTakePhoto: _capturarFoto,
                          onToggleVideo: _alternarVideo,
                        ),
                        if (_fotosCapturadas.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          SizedBox(
                            height: 48,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: _fotosCapturadas.length,
                              separatorBuilder: (_, _) =>
                                  const SizedBox(width: 8),
                              itemBuilder: (context, index) {
                                final foto = _fotosCapturadas[index];
                                final hora =
                                    '${foto.timestamp.hour.toString().padLeft(2, '0')}:${foto.timestamp.minute.toString().padLeft(2, '0')}:${foto.timestamp.second.toString().padLeft(2, '0')}';
                                return InkWell(
                                  onTap: () => _exibirDetalhesFoto(foto),
                                  borderRadius: BorderRadius.circular(8),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: colors.primary.withValues(
                                        alpha: 0.08,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: colors.primary.withValues(
                                          alpha: 0.25,
                                        ),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.photo_camera_rounded,
                                          size: 16,
                                          color: Colors.teal,
                                        ),
                                        const SizedBox(width: 6),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              'Foto #${foto.id} • $hora',
                                              style: const TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                            Text(
                                              foto.latitude == null ||
                                                      foto.longitude == null
                                                  ? 'GPS: indisponível'
                                                  : 'GPS: ${foto.latitude!.toStringAsFixed(4)}, ${foto.longitude!.toStringAsFixed(4)}',
                                              style: TextStyle(
                                                fontSize: 9,
                                                color: colors.onSurfaceVariant,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],

                if (widget.configuracao.sensoresSelecionados.contains(
                  SensorColeta.audio,
                )) ...[
                  const SizedBox(height: AppDimensions.space16),
                  Container(
                    padding: const EdgeInsets.all(AppDimensions.space16),
                    decoration: BoxDecoration(
                      color: colors.surface,
                      borderRadius: AppDimensions.borderRadiusCard,
                      border: Border.all(color: colors.outlineVariant),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        AudioRecordingIndicator(
                          isRecording: _isRecordingAudio,
                          elapsed: _audioElapsed,
                          maxDurationSeconds: widget
                              .configuracao
                              .sensoresOpcionais
                              .audio
                              .durationSeconds,
                          amplitudeDb: _audioAmplitudeDb,
                        ),
                        const SizedBox(height: 10),
                        FilledButton.icon(
                          key: const ValueKey('toggle-audio-recording'),
                          onPressed: _isRecordingAudio
                              ? () => unawaited(_stopAudioRecording())
                              : () => unawaited(_captureAudio()),
                          icon: Icon(
                            _isRecordingAudio ? Icons.stop_rounded : Icons.mic,
                          ),
                          label: Text(
                            _isRecordingAudio
                                ? 'Parar áudio'
                                : 'Iniciar gravação de áudio',
                          ),
                          style: FilledButton.styleFrom(
                            backgroundColor: _isRecordingAudio
                                ? colors.error
                                : colors.primary,
                          ),
                        ),
                        if (_mediaError != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            _mediaError!,
                            style: TextStyle(color: colors.error),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: AppDimensions.space24),

                // --- 6. BOTÃO PARA FINALIZAR COLETA ---
                SizedBox(
                  width: double.infinity,
                  height: AppDimensions.buttonHeight,
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: colors.error,
                      foregroundColor: colors.onError,
                      shape: RoundedRectangleBorder(
                        borderRadius: AppDimensions.borderRadiusMedium,
                      ),
                    ),
                    onPressed: _isFinalizing || _isStarting
                        ? null
                        : _runId == null
                        ? _startRecording
                        : _confirmarFinalizacao,
                    icon: Icon(
                      _runId == null
                          ? Icons.refresh_rounded
                          : Icons.stop_circle_rounded,
                      size: 22,
                    ),
                    label: Text(
                      _runId == null
                          ? 'Tentar iniciar novamente'
                          : _recordingError == null
                          ? 'Finalizar Coleta'
                          : 'Salvar dados parciais',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _iconForSensor(SensorColeta s) {
    switch (s) {
      case SensorColeta.acelerometro:
        return Icons.speed_rounded;
      case SensorColeta.giroscopio:
        return Icons.screen_rotation_rounded;
      case SensorColeta.gps:
        return Icons.gps_fixed_rounded;
      case SensorColeta.camera:
        return Icons.camera_alt_rounded;
      case SensorColeta.audio:
        return Icons.mic_rounded;
    }
  }

  String _nameForSensor(SensorColeta s) {
    switch (s) {
      case SensorColeta.acelerometro:
        return 'Acelerômetro';
      case SensorColeta.giroscopio:
        return 'Giroscópio';
      case SensorColeta.gps:
        return 'GPS';
      case SensorColeta.camera:
        return 'Câmera';
      case SensorColeta.audio:
        return 'Áudio';
    }
  }
}

class _ParamBadge extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _ParamBadge({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 168),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        decoration: BoxDecoration(
          color: colors.surfaceContainerHighest.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Icon(icon, size: 16, color: colors.primary),
            const SizedBox(height: 4),
            Text(
              value,
              style: typography.labelLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              label,
              style: typography.bodySmall?.copyWith(fontSize: 10),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _StickyMetric extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StickyMetric({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: colors.primary),
            const SizedBox(width: 4),
            Text(
              label,
              style: typography.labelSmall?.copyWith(
                fontSize: 9,
                color: colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
        Text(
          value,
          style: typography.titleSmall?.copyWith(fontWeight: FontWeight.w800),
        ),
      ],
    );
  }
}

class _AxisValueBadge extends StatelessWidget {
  final String label;
  final double value;
  final Color color;

  const _AxisValueBadge({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        '$label: ${value >= 0 ? '+' : ''}${value.toStringAsFixed(1)}',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

/// CustomPainter para desenhar as ondas do acelerômetro em tempo real
class _OscilloscopePainter extends CustomPainter {
  final List<double> bufferX;
  final List<double> bufferY;
  final List<double> bufferZ;
  final Color colorX;
  final Color colorY;
  final Color colorZ;
  final Color gridColor;
  final Color backgroundColor;

  _OscilloscopePainter({
    required this.bufferX,
    required this.bufferY,
    required this.bufferZ,
    required this.colorX,
    required this.colorY,
    required this.colorZ,
    required this.gridColor,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Fundo
    canvas.drawRect(Offset.zero & size, Paint()..color = backgroundColor);

    // Linha central de zero (referência)
    final centerY = size.height / 2;
    final gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 1.0;

    canvas.drawLine(Offset(0, centerY), Offset(size.width, centerY), gridPaint);
    canvas.drawLine(
      Offset(0, centerY - size.height * 0.35),
      Offset(size.width, centerY - size.height * 0.35),
      gridPaint,
    );
    canvas.drawLine(
      Offset(0, centerY + size.height * 0.35),
      Offset(size.width, centerY + size.height * 0.35),
      gridPaint,
    );

    if (bufferX.length < 2) return;

    // Escala: mapeia de -15 m/s² a +15 m/s² para a altura
    const range = 15.0;

    double mapY(double val) {
      final normalized = (val / range).clamp(-1.0, 1.0);
      return centerY - (normalized * (size.height * 0.45));
    }

    void drawTrace(List<double> buffer, Color color) {
      final paint = Paint()
        ..color = color
        ..strokeWidth = 1.8
        ..style = PaintingStyle.stroke
        ..strokeJoin = StrokeJoin.round;

      final path = Path();
      final stepX = size.width / (buffer.length - 1);

      for (var i = 0; i < buffer.length; i++) {
        final x = i * stepX;
        final y = mapY(buffer[i]);
        if (i == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }

      canvas.drawPath(path, paint);
    }

    drawTrace(bufferZ, colorZ);
    drawTrace(bufferY, colorY);
    drawTrace(bufferX, colorX);
  }

  @override
  bool shouldRepaint(covariant _OscilloscopePainter oldDelegate) => true;
}

/// Foto armazenada localmente junto aos metadados de captura.
class _RegistroFoto {
  final int id;
  final DateTime timestamp;
  final double? latitude;
  final double? longitude;
  final double odometroKm;
  final String filePath;

  const _RegistroFoto({
    required this.id,
    required this.timestamp,
    required this.latitude,
    required this.longitude,
    required this.odometroKm,
    required this.filePath,
  });
}
