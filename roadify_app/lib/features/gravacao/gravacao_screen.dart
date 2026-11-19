import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:battery_plus/battery_plus.dart';
import 'package:camera/camera.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:roadify_app/l10n/app_localizations_catalog.dart';
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
import 'services/sensor_sampling_isolate.dart';
import 'services/sensor_trace_buffer.dart';
import 'widgets/audio_recording_indicator.dart';
import 'widgets/recorded_media_preview.dart';
import 'widgets/recording_telemetry_widgets.dart';

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
  final Battery _battery = Battery();
  final ValueNotifier<int> _telemetryRevision = ValueNotifier(0);
  final ValueNotifier<int> _mediaRevision = ValueNotifier(0);
  RecordingRepository get _repository =>
      widget.repository ?? RecordingRepository(getIt<AppDatabase>());
  int? _runId;
  Timer? _tickerTimer;
  Timer? _mediaTickerTimer;
  Timer? _batchTimer;
  Timer? _memoryMonitorTimer;
  Timer? _batteryMonitorTimer;
  Timer? _sensorWatchdogTimer;
  Duration _elapsed = Duration.zero;
  Duration _audioElapsed = Duration.zero;
  Duration _videoElapsed = Duration.zero;

  StreamSubscription<AccelerometerEvent>? _sensorSubscription;
  StreamSubscription<GyroscopeEvent>? _gyroscopeSubscription;
  StreamSubscription<Position>? _gpsSubscription;
  StreamSubscription<Amplitude>? _audioAmplitudeSubscription;
  final Stopwatch _sensorClock = Stopwatch();
  SensorSamplingIsolate? _sensorSampler;
  final SensorTraceBuffer _sensorTrace = SensorTraceBuffer();
  int? _lastTraceSampleElapsedMicros;
  final List<RecordedSensorSample> _pendingSensorSamples = [];
  final List<RecordedGpsPoint> _pendingGpsPoints = [];
  double _currentX = 0.0;
  double _currentY = 0.0;
  double _currentZ = 9.81;
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
  String? _memoryMonitorError;
  String? _batteryMonitorError;
  int? _memoryUsageBytes;
  int? _batteryPercent;
  int? _initialBatteryPercent;
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
  final List<RecordedMediaItem> _capturedMedia = [];
  bool _isFinalizing = false;
  bool _isFinalized = false;

  @override
  void initState() {
    super.initState();
    _stopwatch = Stopwatch();
    unawaited(_startRecording());
  }

  void _validateCaptureConfiguration() {
    widget.configuracao.validarParaGravacao();
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
          batteryPercent = await _battery.batteryLevel;
        } catch (error) {
          _batteryMonitorError = error.toString();
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
        _batteryPercent = batteryPercent;
        _initialBatteryPercent = batteryPercent;
        await WakelockPlus.enable();
        await _startSensorStreams();
        _startGpsStream();
        _startDeviceResourceMonitoring();
        unawaited(_initializeOptionalMedia());
      }

      _stopwatch.start();
      _batchTimer = Timer.periodic(
        const Duration(seconds: 1),
        (_) => unawaited(_flushPendingSamples()),
      );
      _tickerTimer = Timer.periodic(const Duration(milliseconds: 200), (_) {
        if (!mounted) return;
        _elapsed = _stopwatch.elapsed;
        _telemetryRevision.value++;
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

  void _startDeviceResourceMonitoring() {
    _sampleMemoryUsage();
    if (_batteryPercent == null) unawaited(_refreshBatteryLevel());
    _memoryMonitorTimer = Timer.periodic(
      const Duration(seconds: 2),
      (_) => _sampleMemoryUsage(),
    );
    _batteryMonitorTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => unawaited(_refreshBatteryLevel()),
    );
  }

  void _sampleMemoryUsage() {
    try {
      final memoryUsageBytes = ProcessInfo.currentRss;
      if (!mounted) return;
      setState(() {
        _memoryUsageBytes = memoryUsageBytes;
        _memoryMonitorError = null;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _memoryMonitorError = error.toString());
    }
  }

  Future<void> _refreshBatteryLevel() async {
    try {
      final batteryPercent = await _battery.batteryLevel;
      if (batteryPercent < 0 || batteryPercent > 100) {
        throw StateError('Nível de bateria fora do intervalo esperado.');
      }
      if (!mounted) return;
      setState(() {
        _batteryPercent = batteryPercent;
        _initialBatteryPercent ??= batteryPercent;
        _batteryMonitorError = null;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _batteryMonitorError = error.toString());
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

  Future<void> _startSensorStreams() async {
    _sensorWatchdogTimer = Timer(const Duration(seconds: 5), () {
      if (_sensorSampleCount == 0) {
        _handleStreamFailure(
          'O acelerômetro não forneceu leituras. Verifique a disponibilidade do sensor.',
        );
      }
    });
    final startedAtUtc = DateTime.now().toUtc();
    _sensorClock
      ..reset()
      ..start();
    final sampler = SensorSamplingIsolate();
    _sensorSampler = sampler;
    await sampler.start(
      startedAtUtc: startedAtUtc,
      onBatch: _onSensorBatch,
      onError: (error, _) {
        _handleStreamFailure('Falha no buffer de amostras inerciais: $error');
      },
    );

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
              try {
                sampler.addGyroscope(x: event.x, y: event.y, z: event.z);
              } catch (error) {
                _handleStreamFailure(
                  'Falha ao encaminhar leitura do giroscópio: $error',
                );
              }
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
    final sampler = _sensorSampler;
    if (sampler == null) {
      _handleStreamFailure('O buffer de amostras inerciais não foi iniciado.');
      return;
    }
    _currentX = event.x;
    _currentY = event.y;
    _currentZ = event.z;
    final elapsedMicros = _sensorClock.elapsedMicroseconds;
    const traceIntervalMicros = SensorTraceBuffer.sampleIntervalMs * 1000;
    if (_lastTraceSampleElapsedMicros == null ||
        elapsedMicros - _lastTraceSampleElapsedMicros! >= traceIntervalMicros) {
      _lastTraceSampleElapsedMicros = elapsedMicros;
      _sensorTrace.add(event.x, event.y, event.z);
    }

    try {
      sampler.addAccelerometer(
        elapsedMicroseconds: elapsedMicros,
        x: event.x,
        y: event.y,
        z: event.z,
      );
    } catch (error) {
      _handleStreamFailure(
        'Falha ao encaminhar leitura do acelerômetro: $error',
      );
    }
  }

  void _onSensorBatch(List<RecordedSensorSample> samples) {
    if (samples.isEmpty) return;
    _pendingSensorSamples.addAll(samples);
    _sensorSampleCount += samples.length;
    if (_pendingSensorSamples.length + _pendingGpsPoints.length >= 1000) {
      _handleStreamFailure(
        'O banco local não está acompanhando a aquisição. A captura foi pausada para preservar as amostras pendentes.',
      );
      return;
    }
    unawaited(_flushPendingSamples());
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
      _scheduleAutomaticCameraCapture();
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

  Future<CameraController> _ensureCameraInitialized() async {
    final activeController = _cameraController;
    if (activeController?.value.isInitialized == true) {
      return activeController!;
    }

    final cameras = await availableCameras();
    final requestedDirection =
        widget.configuracao.sensoresOpcionais.camera.facing ==
            CameraFacing.front
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
      enableAudio: widget.configuracao.sensoresSelecionados.contains(
        SensorColeta.audio,
      ),
    );
    try {
      await controller.initialize();
      if (!mounted) {
        throw StateError(
          'A tela foi encerrada durante a inicialização da câmera.',
        );
      }
      _cameraController = controller;
      return controller;
    } catch (error) {
      try {
        await controller.dispose();
      } catch (disposeError) {
        throw StateError(
          'Falha ao inicializar a câmera: $error. '
          'Falha ao liberar os recursos da câmera: $disposeError',
        );
      }
      rethrow;
    }
  }

  Future<void> _releaseCameraController() async {
    final controller = _cameraController;
    _cameraController = null;
    if (controller == null) return;

    try {
      await controller.dispose();
    } catch (error) {
      _showMediaError('Falha ao desligar a câmera: $error');
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
    bool photo = false,
  }) async {
    if (automatic && _isRecordingVideo) return;
    if (_isRecordingVideo && !video) return;
    if (_isCapturingMedia || _runId == null) return;
    _isCapturingMedia = true;
    if (mounted) setState(() {});
    try {
      final controller = await _ensureCameraInitialized();
      final mediaType = widget.configuracao.sensoresOpcionais.camera.mediaType;
      final takeVideo =
          !photo &&
          (_isRecordingVideo || video || mediaType == CameraMediaType.videos);
      if (takeVideo) {
        if (_isRecordingVideo) {
          await _stopVideoRecording(propagate: true);
        } else {
          await controller.startVideoRecording();
          _isRecordingVideo = true;
          _videoElapsed = Duration.zero;
          _videoStopwatch
            ..reset()
            ..start();
          _startMediaTicker();
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
      if (!_isRecordingVideo) await _releaseCameraController();
      _isCapturingMedia = false;
      if (mounted) setState(() {});
    }
  }

  void _alternarVideo() => unawaited(_captureCameraMedia(video: true));

  void _startMediaTicker() {
    _mediaTickerTimer ??= Timer.periodic(const Duration(milliseconds: 250), (
      _,
    ) {
      if (!mounted || (!_isRecordingAudio && !_isRecordingVideo)) return;
      if (_isRecordingAudio) _audioElapsed = _audioStopwatch.elapsed;
      if (_isRecordingVideo) _videoElapsed = _videoStopwatch.elapsed;
      _mediaRevision.value++;
    });
  }

  void _stopMediaTickerIfIdle() {
    if (_isRecordingAudio || _isRecordingVideo) return;
    _mediaTickerTimer?.cancel();
    _mediaTickerTimer = null;
  }

  Future<void> _stopVideoRecording({bool propagate = false}) async {
    final controller = _cameraController;
    if (controller == null || !_isRecordingVideo) return;
    try {
      _cameraDurationTimer?.cancel();
      _videoStopwatch.stop();
      final file = await controller.stopVideoRecording();
      _isRecordingVideo = false;
      _videoElapsed = _videoStopwatch.elapsed;
      _stopMediaTickerIfIdle();
      await _saveMediaFile(file, 'video');
    } catch (error) {
      _showMediaError('Falha ao finalizar o vídeo: $error');
      if (propagate) rethrow;
    } finally {
      if (!_isRecordingVideo) await _releaseCameraController();
      if (mounted) setState(() {});
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
      _startMediaTicker();
      _audioAmplitudeSubscription = _audioRecorder!
          .onAmplitudeChanged(const Duration(milliseconds: 200))
          .listen(
            (amplitude) {
              if (!mounted || !_isRecordingAudio) return;
              _audioAmplitudeDb = amplitude.current;
              _mediaRevision.value++;
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
      _audioElapsed = _audioStopwatch.elapsed;
      await _audioAmplitudeSubscription?.cancel();
      _audioAmplitudeSubscription = null;
      final filePath = await _audioRecorder!.stop();
      _isRecordingAudio = false;
      _stopMediaTickerIfIdle();
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
    if (mounted) {
      setState(() {
        _capturedMedia.add(
          RecordedMediaItem(
            id: mediaId,
            type: type,
            timestamp: timestamp,
            latitude: position?.latitude,
            longitude: position?.longitude,
            odometerKm:
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
    _memoryMonitorTimer?.cancel();
    _batteryMonitorTimer?.cancel();
    setState(() {
      _recordingError = message;
      _isRecording = false;
    });
    _stopwatch.stop();
    _tickerTimer?.cancel();
    _mediaTickerTimer?.cancel();
    _batchTimer?.cancel();
    unawaited(
      _cancelSensorStreams(propagateSamplerFailure: false).catchError((error) {
        if (mounted) {
          setState(() {
            _recordingError ??= 'Falha ao encerrar o buffer inercial: $error';
          });
        }
      }),
    );
  }

  void _handleOptionalSensorFailure(String message) {
    if (!mounted || !_isRecording && !_isStarting) return;
    setState(() => _optionalSensorWarning = message);
    unawaited(_gyroscopeSubscription?.cancel());
    _gyroscopeSubscription = null;
  }

  Future<void> _cancelSensorStreams({
    bool propagateSamplerFailure = true,
  }) async {
    await _sensorSubscription?.cancel();
    await _gyroscopeSubscription?.cancel();
    await _gpsSubscription?.cancel();
    _sensorSubscription = null;
    _gyroscopeSubscription = null;
    _gpsSubscription = null;
    final sampler = _sensorSampler;
    _sensorSampler = null;
    _sensorClock.stop();
    try {
      await sampler?.stopAndFlush();
    } catch (error) {
      if (propagateSamplerFailure) rethrow;
      if (mounted) {
        setState(() {
          _recordingError ??= 'Falha ao encerrar o buffer inercial: $error';
        });
      }
    }
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
    _memoryMonitorTimer?.cancel();
    _batteryMonitorTimer?.cancel();
    _sensorWatchdogTimer?.cancel();
    _cameraDurationTimer?.cancel();
    _audioDurationTimer?.cancel();
    _automaticCameraTimer?.cancel();
    _automaticAudioTimer?.cancel();
    unawaited(_audioAmplitudeSubscription?.cancel());
    unawaited(_cancelSensorStreams(propagateSamplerFailure: false));
    unawaited(_releaseCameraController());
    unawaited(_audioRecorder?.dispose());
    if (widget.captureDeviceSensors) unawaited(WakelockPlus.disable());
    _stopwatch.stop();
    _telemetryRevision.dispose();
    _mediaRevision.dispose();
    super.dispose();
  }

  String _formatDuration(Duration d) {
    final hours = d.inHours.toString().padLeft(2, '0');
    final minutes = (d.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (d.inSeconds % 60).toString().padLeft(2, '0');
    final tenths = (d.inMilliseconds % 1000) ~/ 100;
    return '$hours:$minutes:$seconds.$tenths';
  }

  String _batteryChangeDescription(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final initialBatteryPercent = _initialBatteryPercent;
    final batteryPercent = _batteryPercent;
    if (initialBatteryPercent == null || batteryPercent == null) {
      return l10n.text('batteryChangeUnavailable');
    }

    final change = batteryPercent - initialBatteryPercent;
    if (change == 0) return l10n.text('batteryNoChange');
    final sign = change < 0 ? '−' : '+';
    return l10n
        .text('batteryChangeFromStart')
        .replaceAll('{sign}', sign)
        .replaceAll('{change}', '${change.abs()}');
  }

  String _intervalLabel(CaptureIntervalUnit unit) => switch (unit) {
    CaptureIntervalUnit.minutes => 'min',
    CaptureIntervalUnit.hours => 'h',
    CaptureIntervalUnit.meters => 'm',
    CaptureIntervalUnit.kilometers => 'km',
  };

  String _sensorConfigurationDescription(SensorColeta sensor) {
    final config = widget.configuracao;
    final optional = config.sensoresOpcionais;

    return switch (sensor) {
      SensorColeta.acelerometro => '${config.taxaAcelerometroHz} Hz',
      SensorColeta.giroscopio => '${optional.gyroscopeFrequencyHz} Hz',
      SensorColeta.gps =>
        '${config.taxaGpsHz} Hz • intervalo mínimo de gravação '
            '${config.intervaloMetros.toStringAsFixed(0)} m',
      SensorColeta.camera => _cameraConfigurationDescription(optional.camera),
      SensorColeta.audio => _audioConfigurationDescription(optional.audio),
    };
  }

  String _cameraConfigurationDescription(CameraCaptureSettings camera) {
    final media = switch (camera.mediaType) {
      CameraMediaType.photos => 'fotos',
      CameraMediaType.videos => 'vídeos',
      CameraMediaType.photosAndVideos => 'fotos e vídeos',
    };
    final facing = switch (camera.facing) {
      CameraFacing.front => 'frontal',
      CameraFacing.rear => 'traseira',
    };
    final schedule = camera.automatic
        ? 'automática a cada ${camera.interval} '
              '${_intervalLabel(camera.intervalUnit)}'
        : 'acionamento manual';
    final videoDuration = camera.mediaType == CameraMediaType.photos
        ? null
        : 'vídeo até ${camera.videoDurationSeconds}s';
    return ['$media • câmera $facing • $schedule', ?videoDuration].join(' • ');
  }

  String _audioConfigurationDescription(AudioCaptureSettings audio) =>
      audio.automatic
      ? 'Automático a cada ${audio.interval} '
            '${_intervalLabel(audio.intervalUnit)} • até ${audio.durationSeconds}s'
      : 'Acionamento manual • até ${audio.durationSeconds}s por gravação';

  Widget _buildInformationSection(
    BuildContext context, {
    required String title,
    required List<Widget> children,
  }) {
    final colors = Theme.of(context).colorScheme;
    return Card(
      color: colors.surfaceContainerLow,
      margin: const EdgeInsets.only(bottom: AppDimensions.space12),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.space12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: AppDimensions.space8),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInformationRow(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
  }) {
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      minLeadingWidth: 24,
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(title),
      subtitle: Text(value),
    );
  }

  List<Widget> _buildSensorInformationRows(BuildContext context) {
    return widget.configuracao.sensoresSelecionados
        .map((sensor) {
          return _buildInformationRow(
            context,
            icon: _iconForSensor(sensor),
            title: _nameForSensor(context, sensor),
            value: _sensorConfigurationDescription(sensor),
          );
        })
        .toList(growable: false);
  }

  Future<void> _showRecordingInfo() {
    final config = widget.configuracao;
    final modalHeight = MediaQuery.sizeOf(context).height * 0.62;
    final collectionName = config.nomeColeta?.trim().isNotEmpty == true
        ? config.nomeColeta!.trim()
        : config.identificador;
    final l10n = AppLocalizations.of(context);

    return showDialog<void>(
      context: context,
      builder: (modalContext) => AlertDialog(
        titlePadding: const EdgeInsets.fromLTRB(24, 16, 16, 0),
        title: Row(
          children: [
            Expanded(child: Text(l10n.text('collectionInfoDialogTitle'))),
            IconButton(
              key: const ValueKey('close-recording-info'),
              tooltip: l10n.text('closeInfoTooltip'),
              onPressed: () => Navigator.of(modalContext).pop(),
              icon: const Icon(Icons.close_rounded),
            ),
          ],
        ),
        contentPadding: EdgeInsets.zero,
        content: SizedBox(
          width: double.maxFinite,
          height: modalHeight,
          child: ListView(
            key: const ValueKey('recording-info-list'),
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              _buildInformationSection(
                modalContext,
                title: l10n.text('sensorsAndSettingsTitle'),
                children: _buildSensorInformationRows(modalContext),
              ),
              _buildInformationSection(
                modalContext,
                title: l10n.text('identificationAndVehicleTitle'),
                children: [
                  _buildInformationRow(
                    modalContext,
                    icon: Icons.badge_outlined,
                    title: l10n.text('collectionLabel'),
                    value: collectionName,
                  ),
                  _buildInformationRow(
                    modalContext,
                    icon: Icons.route_outlined,
                    title: l10n.text('segmentLabel'),
                    value: config.trecho,
                  ),
                  _buildInformationRow(
                    modalContext,
                    icon: Icons.tag_rounded,
                    title: l10n.text('identifierLabel'),
                    value: config.identificador,
                  ),
                  _buildInformationRow(
                    modalContext,
                    icon: Icons.directions_car_outlined,
                    title: l10n.text('vehicleSimpleLabel'),
                    value: config.vehicleId == null
                        ? l10n.text('notLinked')
                        : 'ID ${config.vehicleId}',
                  ),
                  _buildInformationRow(
                    modalContext,
                    icon: Icons.speed_rounded,
                    title: l10n.text('initialOdometerSimple'),
                    value: '${config.odometroInicial.toStringAsFixed(1)} km',
                  ),
                  _buildInformationRow(
                    modalContext,
                    icon: Icons.screen_rotation_rounded,
                    title: l10n.text('orientationAndPostureLabel'),
                    value:
                        '${config.orientation == CollectionOrientation.vertical ? l10n.text('verticalOrientation') : l10n.text('horizontalOrientation')} • '
                        '${config.posture == CollectionPosture.standing ? l10n.text('standingPosture') : l10n.text('lyingDownPosture')}',
                  ),
                ],
              ),
              _buildInformationSection(
                modalContext,
                title: l10n.text('levelingTitle'),
                children: [
                  _buildInformationRow(
                    modalContext,
                    icon: Icons.screen_rotation_alt_rounded,
                    title: l10n.text('modeLabel'),
                    value: config.levelingMode.label,
                  ),
                  _buildInformationRow(
                    modalContext,
                    icon: Icons.tune_rounded,
                    title: l10n.text('calibrationLabel'),
                    value: config.isCalibrated
                        ? l10n
                              .text('calibratedWithOffsets')
                              .replaceAll(
                                '{x}',
                                config.calibrationOffsetX.toStringAsFixed(2),
                              )
                              .replaceAll(
                                '{y}',
                                config.calibrationOffsetY.toStringAsFixed(2),
                              )
                        : l10n.text('noCustomCalibration'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _capturarFoto() => unawaited(_captureCameraMedia(photo: true));

  void _exibirDetalhesFoto(RecordedMediaItem media) {
    showDialog(
      context: context,
      builder: (ctx) => RecordedMediaPreviewDialog(media: media),
    );
  }

  Widget _capturedMediaGallery(ColorScheme colors) {
    final l10n = AppLocalizations.of(context);
    return Container(
      key: const ValueKey('captured-media-gallery'),
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.space12),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: AppDimensions.borderRadiusCard,
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n
                .text('capturedFilesCount')
                .replaceAll('{count}', '${_capturedMedia.length}'),
            style: context.typography.titleSmall,
          ),
          const SizedBox(height: AppDimensions.space8),
          SizedBox(
            height: 58,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _capturedMedia.length,
              separatorBuilder: (_, _) =>
                  const SizedBox(width: AppDimensions.space8),
              itemBuilder: (context, index) {
                final media = _capturedMedia[index];
                final hour =
                    '${media.timestamp.hour.toString().padLeft(2, '0')}:'
                    '${media.timestamp.minute.toString().padLeft(2, '0')}:'
                    '${media.timestamp.second.toString().padLeft(2, '0')}';
                return InkWell(
                  key: ValueKey('captured-media-${media.id}'),
                  onTap: () => _exibirDetalhesFoto(media),
                  borderRadius: AppDimensions.borderRadiusSmall,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.space12,
                      vertical: AppDimensions.space8,
                    ),
                    decoration: BoxDecoration(
                      color: colors.primary.withValues(alpha: 0.08),
                      borderRadius: AppDimensions.borderRadiusSmall,
                      border: Border.all(
                        color: colors.primary.withValues(alpha: 0.25),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(media.icon, color: colors.primary),
                        const SizedBox(width: AppDimensions.space8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '${media.label} #${media.id}',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              '$hour • ${path.basename(media.filePath)}',
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
      ),
    );
  }

  Future<void> _confirmarFinalizacao() async {
    unawaited(HapticFeedback.mediumImpact());
    final l10n = AppLocalizations.of(context);
    final config = widget.configuracao;
    final collectionName = config.nomeColeta?.trim().isNotEmpty == true
        ? config.nomeColeta!.trim()
        : config.identificador;
    final activeMediaCount =
        (_isRecordingVideo ? 1 : 0) + (_isRecordingAudio ? 1 : 0);
    final mediaToSave = _mediaCount + activeMediaCount;
    final mediaDetails = activeMediaCount == 0
        ? l10n.text('alreadyCapturedCount').replaceAll('{count}', '$_mediaCount')
        : l10n
              .text('alreadyCapturedPlusActive')
              .replaceAll('{count}', '$_mediaCount')
              .replaceAll('{active}', '$activeMediaCount');
    final finalOdometer = config.odometroInicial + _distanceMeters / 1000;

    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.text('collectionSummaryTitle')),
        content: SizedBox(
          width: double.maxFinite,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.sizeOf(ctx).height * 0.58,
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.text('collectionSummaryDescription')),
                  const SizedBox(height: AppDimensions.space12),
                  _buildInformationSection(
                    ctx,
                    title: l10n.text('summaryWhatWillBeSaved'),
                    children: [
                      _buildInformationRow(
                        ctx,
                        icon: Icons.timer_outlined,
                        title: l10n.text('durationLabel'),
                        value: _formatDuration(_elapsed),
                      ),
                      _buildInformationRow(
                        ctx,
                        icon: Icons.show_chart_rounded,
                        title: l10n.text('inertialSamplesLower'),
                        value:
                            '$_sensorSampleCount • ${l10n.text('accelerometerLower')}'
                            '${config.sensoresSelecionados.contains(SensorColeta.giroscopio) ? l10n.text('andGyroscopeLower') : ''}',
                      ),
                      _buildInformationRow(
                        ctx,
                        icon: Icons.gps_fixed_rounded,
                        title: l10n.text('gpsPoints'),
                        value:
                            '$_gpsPointCount • ${(_distanceMeters / 1000).toStringAsFixed(2)} km',
                      ),
                      _buildInformationRow(
                        ctx,
                        icon: Icons.perm_media_outlined,
                        title: l10n.text('mediaFilesLabel'),
                        value: '$mediaToSave • $mediaDetails',
                      ),
                      _buildInformationRow(
                        ctx,
                        icon: Icons.storage_rounded,
                        title: l10n.text('destinationLabel'),
                        value: l10n.text('destinationValue'),
                      ),
                    ],
                  ),
                  _buildInformationSection(
                    ctx,
                    title: l10n.text('identificationAndVehicleTitle'),
                    children: [
                      _buildInformationRow(
                        ctx,
                        icon: Icons.badge_outlined,
                        title: l10n.text('collectionLabel'),
                        value: collectionName,
                      ),
                      _buildInformationRow(
                        ctx,
                        icon: Icons.route_outlined,
                        title: l10n.text('segmentLabel'),
                        value: config.trecho,
                      ),
                      _buildInformationRow(
                        ctx,
                        icon: Icons.directions_car_outlined,
                        title: l10n.text('vehicleSimpleLabel'),
                        value: config.vehicleId == null
                            ? l10n.text('notLinked')
                            : 'ID ${config.vehicleId}',
                      ),
                      _buildInformationRow(
                        ctx,
                        icon: Icons.tag_rounded,
                        title: l10n.text('identifierLabel'),
                        value: config.identificador,
                      ),
                      _buildInformationRow(
                        ctx,
                        icon: Icons.speed_rounded,
                        title: l10n.text('initialOdometerSimple'),
                        value:
                            '${config.odometroInicial.toStringAsFixed(1)} km',
                      ),
                      _buildInformationRow(
                        ctx,
                        icon: Icons.directions_car_outlined,
                        title: l10n.text('estimatedFinalOdometer'),
                        value: '${finalOdometer.toStringAsFixed(1)} km',
                      ),
                    ],
                  ),
                  _buildInformationSection(
                    ctx,
                    title: l10n.text('configuredSensorsTitle'),
                    children: _buildSensorInformationRows(ctx),
                  ),
                  if (activeMediaCount > 0)
                    Padding(
                      padding: const EdgeInsets.only(
                        bottom: AppDimensions.space8,
                      ),
                      child: Text(
                        l10n.text('activeMediaWillBeStoppedMsg'),
                        style: Theme.of(ctx).textTheme.bodySmall,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.text('continueCollecting2')),
          ),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
              foregroundColor: Theme.of(ctx).colorScheme.onError,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            icon: const Icon(Icons.check_rounded, size: 18),
            label: Text(l10n.text('finishSave2')),
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
    _elapsed = _stopwatch.elapsed;
    _telemetryRevision.value++;
    _isRecording = false;
    setState(() => _isFinalizing = true);
    _tickerTimer?.cancel();
    _batchTimer?.cancel();
    _memoryMonitorTimer?.cancel();
    _batteryMonitorTimer?.cancel();
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
        vehicleId: widget.configuracao.vehicleId,
        finalOdometer:
            widget.configuracao.odometroInicial + _distanceMeters / 1000,
      );
      _isFinalized = true;
      if (widget.captureDeviceSensors) await WakelockPlus.disable();
      await _releaseCameraController();
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

  Widget _buildPillDockActionItem({
    required BuildContext context,
    required ColorScheme colors,
    required String keyName,
    required String label,
    required String tooltip,
    required IconData icon,
    required String? detail,
    required VoidCallback? onPressed,
    required bool isActive,
    bool isDanger = false,
  }) {
    final dockTheme = context.pillDockTheme;
    final enabled = onPressed != null;
    final activeBg = (isActive || isDanger) ? colors.error : colors.primary;
    final activeFg = (isActive || isDanger) ? colors.onError : colors.onPrimary;
    final iconColor = !enabled
        ? dockTheme.unselectedItemColor.withValues(alpha: 0.4)
        : (isActive || isDanger)
        ? activeFg
        : colors.primary;

    return Expanded(
      child: Tooltip(
        message: tooltip,
        child: Material(
          key: ValueKey(keyName),
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed == null
                ? null
                : () {
                    unawaited(HapticFeedback.lightImpact());
                    onPressed();
                  },
            borderRadius: BorderRadius.circular(24),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOutCubic,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: !enabled
                          ? colors.surfaceContainerHighest.withValues(alpha: 0.4)
                          : (isActive || isDanger)
                          ? activeBg
                          : colors.primary.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(icon, size: 20, color: iconColor),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      color: !enabled
                          ? dockTheme.unselectedItemColor.withValues(alpha: 0.5)
                          : (isActive || isDanger)
                          ? colors.error
                          : colors.onSurface,
                      letterSpacing: -0.1,
                    ),
                  ),
                  if (detail != null)
                    Text(
                      detail,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 9,
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Dock flutuante inferior (estilo PillDockScaffold) contendo os botões de
  /// Câmera (Foto), Vídeo, Áudio e Encerrar/Finalizar Coleta.
  Widget _buildRecordingActionDock(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final dockTheme = context.pillDockTheme;
    final l10n = AppLocalizations.of(context);
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final selectedSensors = widget.configuracao.sensoresSelecionados;
    final cameraSettings = widget.configuracao.sensoresOpcionais.camera;
    final cameraSelected = selectedSensors.contains(SensorColeta.camera);
    final audioSelected = selectedSensors.contains(SensorColeta.audio);

    return SafeArea(
      top: false,
      left: false,
      right: false,
      bottom: false,
      child: Padding(
        padding: EdgeInsets.only(
          left: AppDimensions.pillDockMarginHorizontal,
          right: AppDimensions.pillDockMarginHorizontal,
          bottom: bottomPadding > 0
              ? bottomPadding + 8
              : AppDimensions.pillDockMarginBottom,
        ),
        child: ValueListenableBuilder<int>(
          valueListenable: _mediaRevision,
          builder: (context, _, _) {
            final actions = <Widget>[];
            final cameraBusy =
                _isCapturingMedia || _runId == null || _isStarting;

            if (cameraSelected &&
                cameraSettings.mediaType != CameraMediaType.videos) {
              actions.add(
                _buildPillDockActionItem(
                  context: context,
                  colors: colors,
                  keyName: 'floating-photo-action',
                  label: l10n.text('photoAction'),
                  tooltip: l10n.text('takePhotoTooltip'),
                  icon: Icons.camera_alt_rounded,
                  detail: null,
                  onPressed: cameraBusy || _isRecordingVideo
                      ? null
                      : _capturarFoto,
                  isActive: false,
                ),
              );
            }

            if (cameraSelected &&
                cameraSettings.mediaType != CameraMediaType.photos) {
              actions.add(
                _buildPillDockActionItem(
                  context: context,
                  colors: colors,
                  keyName: 'floating-video-action',
                  label: _isRecordingVideo
                      ? l10n.text('stopVideoShort')
                      : l10n.text('videoShort'),
                  tooltip: _isRecordingVideo
                      ? l10n.text('stopVideoTooltip')
                      : l10n.text('recordVideoTooltip'),
                  icon: _isRecordingVideo
                      ? Icons.stop_rounded
                      : Icons.videocam_rounded,
                  detail: _isRecordingVideo
                      ? '${_videoElapsed.inSeconds}s / '
                            '${cameraSettings.videoDurationSeconds}s'
                      : l10n
                            .text('upToSeconds')
                            .replaceAll(
                              '{seconds}',
                              '${cameraSettings.videoDurationSeconds}',
                            ),
                  onPressed: cameraBusy ? null : _alternarVideo,
                  isActive: _isRecordingVideo,
                ),
              );
            }

            if (audioSelected) {
              final audioSettings =
                  widget.configuracao.sensoresOpcionais.audio;
              actions.add(
                _buildPillDockActionItem(
                  context: context,
                  colors: colors,
                  keyName: 'floating-audio-action',
                  label: _isRecordingAudio
                      ? l10n.text('audioStop')
                      : l10n.text('audio'),
                  tooltip: _isRecordingAudio
                      ? l10n.text('stopAudioTooltip')
                      : l10n.text('recordAudioTooltip'),
                  icon: _isRecordingAudio
                      ? Icons.stop_rounded
                      : Icons.mic_rounded,
                  detail: _isRecordingAudio
                      ? '${_audioElapsed.inSeconds}s / '
                            '${audioSettings.durationSeconds}s'
                      : l10n
                            .text('upToSeconds')
                            .replaceAll(
                              '{seconds}',
                              '${audioSettings.durationSeconds}',
                            ),
                  onPressed:
                      _runId == null ||
                          _isStarting ||
                          (!_isRecordingAudio && _audioRecorder == null)
                      ? null
                      : _isRecordingAudio
                      ? () => unawaited(_stopAudioRecording())
                      : () => unawaited(_captureAudio()),
                  isActive: _isRecordingAudio,
                ),
              );
            }

            final finishLabel = _runId == null
                ? l10n.text('retryStartCollection')
                : _recordingError == null
                ? l10n.text('finishCollectionBtn')
                : l10n.text('savePartialData');

            actions.add(
              _buildPillDockActionItem(
                context: context,
                colors: colors,
                keyName: 'floating-finish-action',
                label: finishLabel,
                tooltip: finishLabel,
                icon: _runId == null
                    ? Icons.refresh_rounded
                    : Icons.stop_circle_rounded,
                detail: null,
                onPressed: _isFinalizing || _isStarting
                    ? null
                    : _runId == null
                    ? _startRecording
                    : _confirmarFinalizacao,
                isActive: true,
                isDanger: true,
              ),
            );

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_mediaError != null) ...[
                  Container(
                    margin: const EdgeInsets.only(bottom: 6),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: colors.errorContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _mediaError!,
                      key: const ValueKey('recording-media-error'),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: colors.onErrorContainer,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
                ClipRRect(
                  borderRadius: AppDimensions.borderRadiusPill,
                  child: BackdropFilter(
                    filter: ImageFilter.blur(
                      sigmaX: dockTheme.blurAmount,
                      sigmaY: dockTheme.blurAmount,
                    ),
                    child: Container(
                      key: const ValueKey('recording-action-dock'),
                      height: AppDimensions.pillDockHeight + 8,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        color: dockTheme.backgroundColor,
                        borderRadius: AppDimensions.borderRadiusPill,
                        border: Border.all(
                          color: dockTheme.borderColor,
                          width: 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(
                              alpha: context.isDarkMode ? 0.3 : 0.08,
                            ),
                            blurRadius: AppDimensions.pillDockElevation * 2,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: actions,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildRecordingMetrics(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final typography = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);

    Widget metric({
      required String label,
      required IconData icon,
      required String Function() value,
      required String Function() detail,
    }) {
      return Expanded(
        child: Container(
          padding: const EdgeInsets.all(12),
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
                  Icon(icon, size: 16, color: colors.primary),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      label,
                      style: typography.labelSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ValueListenableBuilder<int>(
                valueListenable: _telemetryRevision,
                builder: (context, _, _) => Text(
                  value(),
                  style: typography.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(height: 2),
              ValueListenableBuilder<int>(
                valueListenable: _telemetryRevision,
                builder: (context, _, _) => Text(
                  detail(),
                  style: typography.bodySmall?.copyWith(
                    fontSize: 11,
                    color: colors.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Row(
      key: const ValueKey('recording-sample-metrics'),
      children: [
        metric(
          label: l10n.text('samplesLabel'),
          icon: Icons.show_chart_rounded,
          value: () => '$_sensorSampleCount',
          detail: () =>
              '${l10n.text('accelerometerLower')}${widget.configuracao.sensoresSelecionados.contains(SensorColeta.giroscopio) ? l10n.text('plusGyroscopeLower') : ''}',
        ),
        const SizedBox(width: 12),
        metric(
          label: l10n.text('gpsPoints'),
          icon: Icons.gps_fixed_rounded,
          value: () => '$_gpsPointCount',
          detail: () => '${(_distanceMeters / 1000).toStringAsFixed(2)} km',
        ),
      ],
    );
  }

  Widget _buildAccelerometerChart(BuildContext context) {
    return RecordingAccelerometerChart(
      telemetryRevision: _telemetryRevision,
      sensorTrace: _sensorTrace,
      currentX: () => _currentX,
      currentY: () => _currentY,
      currentZ: () => _currentZ,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final l10n = AppLocalizations.of(context);

    return PopScope<Object?>(
      canPop: (_runId == null && !_startInProgress) || _isFinalized,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.text('finishBeforeLeaving'))),
          );
        }
      },
      child: Scaffold(
        extendBody: true,
        appBar: AppBar(
          title: Text(l10n.text('collectionProgress')),
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              key: const ValueKey('recording-info-button'),
              tooltip: l10n.text('collectionInfoDialogTitle'),
              onPressed: _showRecordingInfo,
              icon: const Icon(Icons.info_outline_rounded),
            ),
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
                        ? l10n.text('recordingStatusActive')
                        : _isStarting
                        ? l10n.text('recordingStatusPreparing')
                        : l10n.text('recordingStatusPaused'),
                    style: typography.labelMedium?.copyWith(
                      color: _isRecording
                          ? Colors.red
                          : _recordingError != null
                          ? colors.error
                          : Colors.amber,
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
              child: ValueListenableBuilder<int>(
                valueListenable: _telemetryRevision,
                builder: (context, _, _) => Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            l10n.text('elapsedTimeUpper'),
                            style: typography.labelSmall?.copyWith(
                              color: colors.onSurfaceVariant,
                              letterSpacing: 0.8,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          ValueListenableBuilder<int>(
                            valueListenable: _telemetryRevision,
                            builder: (context, _, _) => Text(
                              _formatDuration(_elapsed),
                              key: const ValueKey('elapsed-time-sticky'),
                              style: typography.headlineMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                                fontFeatures: const [
                                  FontFeature.tabularFigures(),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    ValueListenableBuilder<int>(
                      valueListenable: _telemetryRevision,
                      builder: (context, _, _) => StickyMetric(
                        label: l10n.text('gpsSpeedUpper'),
                        value:
                            _lastPosition?.speed.isFinite == true &&
                                _lastPosition!.speed >= 0
                            ? '${((_lastPosition!.speed * 3.6).round())} km/h'
                            : '-- km/h',
                        icon: Icons.speed_rounded,
                        prominent: true,
                      ),
                    ),
                    const SizedBox(width: 14),
                    ValueListenableBuilder<int>(
                      valueListenable: _telemetryRevision,
                      builder: (context, _, _) => StickyMetric(
                        label: l10n.text('distanceUpper'),
                        value:
                            '${(_distanceMeters / 1000).toStringAsFixed(2)} km',
                        icon: Icons.route_rounded,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        bottomNavigationBar: _buildRecordingActionDock(context),
        body: SafeArea(
          bottom: false,
          child: SingleChildScrollView(
            key: const ValueKey('recording-content-scroll'),
            padding: const EdgeInsets.fromLTRB(
              AppDimensions.space20,
              AppDimensions.space12,
              AppDimensions.space20,
              AppDimensions.pillDockHeight +
                  AppDimensions.pillDockMarginBottom +
                  48,
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
                _buildRecordingMetrics(context),
                const SizedBox(height: AppDimensions.space12),
                _buildAccelerometerChart(context),
                const SizedBox(height: AppDimensions.space16),
                Container(
                  key: const ValueKey('device-resource-monitor'),
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
                            Icons.monitor_heart_rounded,
                            size: 16,
                            color: colors.primary,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              l10n.text('deviceMonitoring'),
                              style: typography.labelMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppDimensions.space12),
                      Row(
                        children: [
                          Expanded(
                            child: DeviceResourceMetric(
                              key: const ValueKey('app-memory-usage'),
                              label: l10n.text('appRam'),
                              value: _memoryUsageBytes == null
                                  ? '-- MB'
                                  : '${(_memoryUsageBytes! / (1024 * 1024)).toStringAsFixed(1)} MB',
                              detail: _memoryMonitorError == null
                                  ? l10n.text('processRamUsageDetail')
                                  : l10n
                                        .text('memoryReadError')
                                        .replaceAll(
                                          '{error}',
                                          '$_memoryMonitorError',
                                        ),
                              icon: Icons.memory_rounded,
                            ),
                          ),
                          const SizedBox(width: AppDimensions.space12),
                          Expanded(
                            child: DeviceResourceMetric(
                              key: const ValueKey('battery-usage'),
                              label: l10n.text('batteryUpper'),
                              value: _batteryPercent == null
                                  ? '--%'
                                  : '$_batteryPercent%',
                              detail: _batteryMonitorError != null
                                  ? l10n
                                        .text('batteryReadError')
                                        .replaceAll(
                                          '{error}',
                                          '$_batteryMonitorError',
                                        )
                                  : _batteryChangeDescription(context),
                              icon:
                                  _batteryPercent != null &&
                                      _batteryPercent! <= 20
                                  ? Icons.battery_alert_rounded
                                  : Icons.battery_full_rounded,
                              valueColor:
                                  _batteryPercent != null &&
                                      _batteryPercent! <= 20
                                  ? colors.error
                                  : null,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (widget.configuracao.sensoresSelecionados.contains(
                  SensorColeta.audio,
                )) ...[
                  const SizedBox(height: AppDimensions.space16),
                  ValueListenableBuilder<int>(
                    valueListenable: _mediaRevision,
                    builder: (context, _, _) => AudioRecordingIndicator(
                      isRecording: _isRecordingAudio,
                      elapsed: _audioElapsed,
                      maxDurationSeconds: widget
                          .configuracao
                          .sensoresOpcionais
                          .audio
                          .durationSeconds,
                      amplitudeDb: _audioAmplitudeDb,
                    ),
                  ),
                ],
                if (_capturedMedia.isNotEmpty) ...[
                  const SizedBox(height: AppDimensions.space16),
                  _capturedMediaGallery(colors),
                ],
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

  String _nameForSensor(BuildContext context, SensorColeta s) {
    final l10n = AppLocalizations.of(context);
    switch (s) {
      case SensorColeta.acelerometro:
        return l10n.text('accelerometer');
      case SensorColeta.giroscopio:
        return l10n.text('gyroscope');
      case SensorColeta.gps:
        return l10n.text('gps');
      case SensorColeta.camera:
        return l10n.text('camera');
      case SensorColeta.audio:
        return l10n.text('audio');
    }
  }
}
