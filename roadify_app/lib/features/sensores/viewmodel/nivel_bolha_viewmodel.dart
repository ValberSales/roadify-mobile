import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/circular_buffer.dart';
import '../models/nivel_bolha_state.dart';
import '../services/sensor_orientation_service.dart';

/// ViewModel desacoplada para gerenciamento do Nível Bolha e Sinais em Tempo Real (Sprint 4).
///
/// Implementa:
/// 1. Conexão ao [SensorOrientationService] (leitura inercial real via sensors_plus com filtro passa-baixa).
/// 2. Buffer circular de exatamente 50 amostras dos eixos X, Y e Z a 60 FPS sem engasgos ou retenção excessiva.
/// 3. Telemetria do Giroscópio (velocidade angular X, Y, Z) e GPS em tempo real (velocidade, precisão, altitude).
/// 4. Lógica de calibração de tara angular com persistência em SharedPreferences.
/// 5. Alternância entre modos (Circular 2D e Tubular em T).
class NivelBolhaViewModel extends ChangeNotifier {
  static const String _keyOffsetX = 'roadify_tare_offset_x';
  static const String _keyOffsetY = 'roadify_tare_offset_y';
  static const String _keyIsCalibrated = 'roadify_tare_is_calibrated';
  static const String _keySelectedMode = 'roadify_tare_selected_mode';
  static const String _collectionConfigKey = 'last_collection_configuration';

  /// Capacidade rigorosa do buffer circular (50 amostras conforme critério de aceite da Sprint 4).
  static const int maxHistoryPoints = 50;

  final SensorOrientationService _orientationService;
  final Future<SharedPreferences> Function() _preferencesProvider;
  StreamSubscription<OrientationReading>? _orientationSubscription;
  StreamSubscription<Position>? _gpsSubscription;
  Timer? _telemetryHeartbeatTimer;
  Timer? _sensorUiNotificationTimer;
  DateTime _lastHardwareSampleAt = DateTime.fromMillisecondsSinceEpoch(0);
  bool _disposed = false;

  /// Buffer circular de capacidade 50 amostras (O(1) sem realocação dinâmica de memória).
  final CircularBuffer<SensorSignalSample> _circularBuffer =
      CircularBuffer<SensorSignalSample>(maxHistoryPoints);

  int _sampleTick = 0;

  NivelBolhaState _state = const NivelBolhaState(
    angleX: 0.0,
    angleY: 0.0,
    detectedOrientation: DeviceOrientationMode.horizontal,
    selectedMode: BubbleDisplayMode.auto,
  );

  /// Estado imutável atual exposto para as views.
  NivelBolhaState get state => _state;

  /// Buffer circular com as últimas 50 amostras recentes de aceleração e telemetria.
  CircularBuffer<SensorSignalSample> get signalBuffer => _circularBuffer;

  /// Histórico recente como lista imutável para compatibilidade com widgets e testes.
  List<SensorSignalSample> get signalHistory =>
      List<SensorSignalSample>.unmodifiable(_circularBuffer.toList());

  /// Contador incremental de amostras para avanço temporal suave do osciloscópio.
  int get sampleTick => _sampleTick;

  NivelBolhaViewModel({
    SensorOrientationService? orientationService,
    Future<SharedPreferences> Function()? preferencesProvider,
    bool autoStart = true,
  }) : _orientationService = orientationService ?? SensorOrientationService(),
       _preferencesProvider =
           preferencesProvider ?? SharedPreferences.getInstance {
    // Inicializa o buffer com 50 amostras neutras iniciais
    for (var i = 0; i < maxHistoryPoints; i++) {
      _circularBuffer.add(
        const SensorSignalSample(
          accelX: 0.0,
          accelY: 0.0,
          accelZ: 9.81,
          gyroX: 0.0,
          gyroY: 0.0,
          gyroZ: 0.0,
          roll: 0.0,
          pitch: 0.0,
        ),
      );
    }

    if (autoStart) {
      _initService();
      _initGpsStream();
    }
  }

  void _initService() {
    _orientationSubscription = _orientationService.orientationStream.listen((
      OrientationReading reading,
    ) {
      final autoDetected = reading.accelZ.abs() > 6.5
          ? DeviceOrientationMode.horizontal
          : DeviceOrientationMode.vertical;

      final resolvedOrientation =
          _state.selectedMode == BubbleDisplayMode.circular2D
          ? DeviceOrientationMode.horizontal
          : (_state.selectedMode == BubbleDisplayMode.tubularT
                ? DeviceOrientationMode.vertical
                : autoDetected);

      _state = _state.copyWith(
        angleX: reading.roll,
        angleY: reading.pitch,
        accelX: reading.accelX,
        accelY: reading.accelY,
        accelZ: reading.accelZ,
        gyroX: reading.gyroX,
        gyroY: reading.gyroY,
        gyroZ: reading.gyroZ,
        detectedOrientation: resolvedOrientation,
        isReadingFromHardware: reading.isFromHardware,
      );
      _lastHardwareSampleAt = DateTime.now();
      _pushSignalSample();
      _scheduleSensorUiNotification();
    });

    _orientationService.startListening(allowMockFallback: true);

    // Heartbeat de alta taxa (~60 FPS) para manter o osciloscópio fluido e vivo
    _telemetryHeartbeatTimer = Timer.periodic(
      const Duration(milliseconds: 16),
      (_) {
        if (_disposed) return;
        final elapsedMs = DateTime.now()
            .difference(_lastHardwareSampleAt)
            .inMilliseconds;
        if (elapsedMs >= 30) {
          _pushSignalSample();
          _scheduleSensorUiNotification();
        }
      },
    );
  }

  /// Inicializa a escuta em tempo real da posição e velocidade do GPS.
  Future<void> _initGpsStream() async {
    try {
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse) {
        const locationSettings = LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 1,
        );

        _gpsSubscription = Geolocator.getPositionStream(
          locationSettings: locationSettings,
        ).listen(
          (Position position) {
            if (_disposed) return;
            final speedKmh = position.speed > 0 ? (position.speed * 3.6) : 0.0;
            _state = _state.copyWith(
              gpsSpeed: speedKmh,
              gpsAccuracy: position.accuracy,
              gpsAltitude: position.altitude,
              gpsLatitude: position.latitude,
              gpsLongitude: position.longitude,
              hasGpsSignal: true,
            );
            _notify();
          },
          onError: (_) {
            _fallbackGps();
          },
        );
      } else {
        _fallbackGps();
      }
    } catch (_) {
      _fallbackGps();
    }
  }

  void _fallbackGps() {
    if (_disposed) return;
    // Valores de telemetria simulados seguros para desktop / emulador
    _state = _state.copyWith(
      gpsSpeed: 0.0,
      gpsAccuracy: 3.5,
      gpsAltitude: 785.0,
      gpsLatitude: -25.4284,
      gpsLongitude: -49.2733,
      hasGpsSignal: false,
    );
  }

  void _scheduleSensorUiNotification() {
    if (_sensorUiNotificationTimer?.isActive == true) return;
    _sensorUiNotificationTimer = Timer(const Duration(milliseconds: 100), () {
      _sensorUiNotificationTimer = null;
      _notify();
    });
  }

  void _pushSignalSample() {
    _sampleTick++;
    _circularBuffer.add(
      SensorSignalSample(
        accelX: _state.accelX,
        accelY: _state.accelY,
        accelZ: _state.accelZ,
        gyroX: _state.gyroX,
        gyroY: _state.gyroY,
        gyroZ: _state.gyroZ,
        roll: _state.calibratedAngleX,
        pitch: _state.calibratedAngleY,
      ),
    );
  }

  /// Carrega os offsets de calibração (tara) persistidos da sessão.
  Future<void> loadPersistedCalibration() async {
    try {
      final prefs = await _preferencesProvider();
      final isCalibrated = prefs.getBool(_keyIsCalibrated);
      final offsetX = prefs.getDouble(_keyOffsetX);
      final offsetY = prefs.getDouble(_keyOffsetY);
      final modeName = prefs.getString(_keySelectedMode);

      BubbleDisplayMode? mode;
      if (modeName != null) {
        for (final candidate in BubbleDisplayMode.values) {
          if (candidate.name == modeName) {
            mode = candidate;
            break;
          }
        }
      }

      if (isCalibrated != null || mode != null) {
        _state = _state.copyWith(
          calibOffsetX: offsetX ?? _state.calibOffsetX,
          calibOffsetY: offsetY ?? _state.calibOffsetY,
          isCalibrated: isCalibrated ?? _state.isCalibrated,
          selectedMode: mode ?? _state.selectedMode,
        );
        _notify();
      }
    } catch (_) {}
  }

  /// Persiste a tara angular e modo de nivelamento para uso durante toda a sessão de ensaio.
  Future<void> persistCalibration() async {
    try {
      final prefs = await _preferencesProvider();
      await prefs.setDouble(_keyOffsetX, _state.calibOffsetX);
      await prefs.setDouble(_keyOffsetY, _state.calibOffsetY);
      await prefs.setBool(_keyIsCalibrated, _state.isCalibrated);
      await prefs.setString(_keySelectedMode, _state.selectedMode.name);

      final rawConfig = prefs.getString(_collectionConfigKey);
      if (rawConfig != null) {
        final decoded = jsonDecode(rawConfig);
        if (decoded is Map<String, dynamic>) {
          decoded['calibrationOffsetX'] = _state.calibOffsetX;
          decoded['calibrationOffsetY'] = _state.calibOffsetY;
          decoded['isCalibrated'] = _state.isCalibrated;
          decoded['levelingMode'] = _state.selectedMode.name;
          await prefs.setString(_collectionConfigKey, jsonEncode(decoded));
        }
      }
    } catch (_) {}
  }

  /// Define explicitamente os ângulos (útil para testes unitários ou sliders manuais).
  void setAngles(double x, double y) {
    _state = _state.copyWith(
      angleX: double.parse(x.toStringAsFixed(2)),
      angleY: double.parse(y.toStringAsFixed(2)),
    );
    _pushSignalSample();
    _notify();
  }

  /// Altera o modo de visualização escolhido pelo usuário e sincroniza a postura.
  void setMode(BubbleDisplayMode mode) {
    if (_state.selectedMode == mode) return;

    final updatedOrientation = mode == BubbleDisplayMode.circular2D
        ? DeviceOrientationMode.horizontal
        : (mode == BubbleDisplayMode.tubularT
              ? DeviceOrientationMode.vertical
              : (_state.accelZ.abs() > 6.5
                    ? DeviceOrientationMode.horizontal
                    : DeviceOrientationMode.vertical));

    _state = _state.copyWith(
      selectedMode: mode,
      detectedOrientation: updatedOrientation,
    );
    _notify();
    unawaited(persistCalibration());
  }

  /// Calibra o nível na posição atual (grava tara angular da montagem).
  void calibrate() {
    _state = _state.copyWith(
      calibOffsetX: _state.angleX,
      calibOffsetY: _state.angleY,
      isCalibrated: true,
    );
    _notify();
    unawaited(persistCalibration());
  }

  /// Restaura a calibração original de fábrica (remove a tara).
  void resetCalibration() {
    _state = _state.copyWith(
      calibOffsetX: 0.0,
      calibOffsetY: 0.0,
      isCalibrated: false,
    );
    _notify();
    unawaited(persistCalibration());
  }

  void restoreCalibration({
    required double offsetX,
    required double offsetY,
    required bool isCalibrated,
  }) {
    _state = _state.copyWith(
      calibOffsetX: offsetX,
      calibOffsetY: offsetY,
      isCalibrated: isCalibrated,
    );
    _notify();
    unawaited(persistCalibration());
  }

  /// Atualização direta a partir de valores de aceleração e giroscópio (para testes e injeção).
  void updateFromSensors({
    required double accelX,
    required double accelY,
    required double accelZ,
    double gyroX = 0.0,
    double gyroY = 0.0,
    double gyroZ = 0.0,
  }) {
    final rollRad = (accelX != 0 || accelY != 0 || accelZ != 0)
        ? (accelX /
              (accelY * accelY + accelZ * accelZ > 0
                  ? (accelY * accelY + accelZ * accelZ)
                  : 1))
        : 0.0;
    final degX = double.parse(
      (rollRad * 180.0 / 3.1415926535).toStringAsFixed(2),
    );
    final degY = double.parse(
      ((accelY) * 180.0 / (3.1415926535 * 9.81)).toStringAsFixed(2),
    );

    final detected = accelZ.abs() > 6.5
        ? DeviceOrientationMode.horizontal
        : DeviceOrientationMode.vertical;

    _state = _state.copyWith(
      angleX: degX,
      angleY: degY,
      accelX: accelX,
      accelY: accelY,
      accelZ: accelZ,
      gyroX: gyroX,
      gyroY: gyroY,
      gyroZ: gyroZ,
      detectedOrientation: detected,
    );
    _pushSignalSample();
    _notify();
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _telemetryHeartbeatTimer?.cancel();
    _sensorUiNotificationTimer?.cancel();
    _orientationSubscription?.cancel();
    _gpsSubscription?.cancel();
    _orientationService.dispose();
    super.dispose();
  }
}
