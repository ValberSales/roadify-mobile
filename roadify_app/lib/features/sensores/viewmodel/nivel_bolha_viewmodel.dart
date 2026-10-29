import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/nivel_bolha_state.dart';
import '../services/sensor_orientation_service.dart';

/// ViewModel desacoplada para gerenciamento do Nível Bolha (Feature Sensores — SP2-05 e SP2-06).
///
/// Implementa:
/// 1. Conexão ao [SensorOrientationService] (leitura inercial real via sensors_plus com filtro passa-baixa).
/// 2. Lógica de calibração de tara angular (compensação da montagem no para-brisa) com persistência em SharedPreferences.
/// 3. Alternância entre modos (Circular 2D e Tubular em T).
/// 4. Fallback automático com dados simulados/mockados caso o hardware inercial não esteja presente.
class NivelBolhaViewModel extends ChangeNotifier {
  static const String _keyOffsetX = 'roadify_tare_offset_x';
  static const String _keyOffsetY = 'roadify_tare_offset_y';
  static const String _keyIsCalibrated = 'roadify_tare_is_calibrated';
  static const String _keySelectedMode = 'roadify_tare_selected_mode';
  static const String _collectionConfigKey = 'last_collection_configuration';
  static const int maxHistoryPoints = 60;

  final SensorOrientationService _orientationService;
  final Future<SharedPreferences> Function() _preferencesProvider;
  StreamSubscription<OrientationReading>? _orientationSubscription;
  Timer? _telemetryHeartbeatTimer;
  DateTime _lastHardwareSampleAt = DateTime.fromMillisecondsSinceEpoch(0);
  bool _disposed = false;

  final List<SensorSignalSample> _signalHistory = List<SensorSignalSample>.generate(
    24,
    (_) => const SensorSignalSample(
      accelX: 0.0,
      accelY: 0.0,
      accelZ: 9.81,
      roll: 0.0,
      pitch: 0.0,
    ),
    growable: true,
  );
  int _sampleTick = 0;

  NivelBolhaState _state = const NivelBolhaState(
    angleX: 0.0,
    angleY: 0.0,
    detectedOrientation: DeviceOrientationMode.horizontal,
    selectedMode: BubbleDisplayMode.auto,
  );

  /// Estado imutável atual exposto para as views.
  NivelBolhaState get state => _state;

  /// Histórico recente de amostras para os gráficos em tempo real ("Sinais ao Vivo").
  List<SensorSignalSample> get signalHistory =>
      List<SensorSignalSample>.unmodifiable(_signalHistory);

  /// Contador incremental de amostras para deslocamento temporal contínuo do gráfico.
  int get sampleTick => _sampleTick;

  NivelBolhaViewModel({
    SensorOrientationService? orientationService,
    Future<SharedPreferences> Function()? preferencesProvider,
    bool autoStart = true,
  }) : _orientationService = orientationService ?? SensorOrientationService(),
       _preferencesProvider =
           preferencesProvider ?? SharedPreferences.getInstance {
    if (autoStart) {
      _initService();
    }
  }

  void _initService() {
    _orientationSubscription = _orientationService.orientationStream.listen((
      OrientationReading reading,
    ) {
      // Se a aceleração no eixo Z for alta (> 6.5 m/s²), o aparelho está deitado na mesa
      // Se for menor, está inclinado ou em pé no suporte veicular
      final autoDetected = reading.accelZ.abs() > 6.5
          ? DeviceOrientationMode.horizontal
          : DeviceOrientationMode.vertical;

      // Se o modo selecionado for manual, a postura reflete o instrumento escolhido;
      // se for automático, reflete a leitura inercial do sensor
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
        detectedOrientation: resolvedOrientation,
        isReadingFromHardware: reading.isFromHardware,
      );
      _lastHardwareSampleAt = DateTime.now();
      _pushSignalSample();
      _notify();
    });

    _orientationService.startListening(allowMockFallback: true);

    // Mantém a janela temporal do osciloscópio avançando continuamente mesmo quando o emulador está parado
    _telemetryHeartbeatTimer = Timer.periodic(
      const Duration(milliseconds: 100),
      (_) {
        if (_disposed) return;
        final elapsedMs = DateTime.now()
            .difference(_lastHardwareSampleAt)
            .inMilliseconds;
        if (elapsedMs >= 90) {
          _pushSignalSample();
          _notify();
        }
      },
    );
  }

  void _pushSignalSample() {
    _sampleTick++;
    _signalHistory.add(
      SensorSignalSample(
        accelX: _state.accelX,
        accelY: _state.accelY,
        accelZ: _state.accelZ,
        roll: _state.calibratedAngleX,
        pitch: _state.calibratedAngleY,
      ),
    );
    if (_signalHistory.length > maxHistoryPoints) {
      _signalHistory.removeAt(0);
    }
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

      // Sincroniza também com last_collection_configuration caso já exista
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
  ///
  /// O alinhamento atual se torna a nova referência 0,0° para toda a sessão.
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

  /// Atualização direta a partir de valores de aceleração (útil para injeção manual ou testes).
  void updateFromSensors({
    required double accelX,
    required double accelY,
    required double accelZ,
  }) {
    // Cálculo do Roll (inclinação lateral no eixo X)
    final rollRad = (accelX != 0 || accelY != 0 || accelZ != 0)
        ? (accelX /
              (accelY * accelY + accelZ * accelZ > 0
                  ? (accelY * accelY + accelZ * accelZ)
                  : 1))
        : 0.0;
    // Cálculo trigonométrico
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
    _orientationSubscription?.cancel();
    _orientationService.dispose();
    super.dispose();
  }
}
