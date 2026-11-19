import 'dart:async';
import 'dart:math' as math;
import 'package:sensors_plus/sensors_plus.dart';

/// Modelo de dados emitido pelo serviço de orientação e telemetria inercial.
class OrientationReading {
  /// Ângulo de inclinação transversal (Roll) em graus (-90° a +90°).
  final double roll;

  /// Ângulo de inclinação longitudinal (Pitch) em graus (-90° a +90°).
  final double pitch;

  /// Aceleração filtrada no eixo X (m/s²).
  final double accelX;

  /// Aceleração filtrada no eixo Y (m/s²).
  final double accelY;

  /// Aceleração filtrada no eixo Z (m/s²).
  final double accelZ;

  /// Velocidade angular no eixo X (rad/s).
  final double gyroX;

  /// Velocidade angular no eixo Y (rad/s).
  final double gyroY;

  /// Velocidade angular no eixo Z (rad/s).
  final double gyroZ;

  /// Indica se a leitura provém do hardware físico real do dispositivo.
  final bool isFromHardware;

  const OrientationReading({
    required this.roll,
    required this.pitch,
    required this.accelX,
    required this.accelY,
    required this.accelZ,
    this.gyroX = 0.0,
    this.gyroY = 0.0,
    this.gyroZ = 0.0,
    this.isFromHardware = false,
  });
}

/// Serviço de aquisição inercial e cálculo de orientação (Feature Sensores — Sprint 4).
///
/// Responsável por:
/// 1. Escutar acelerômetro e giroscópio via [sensors_plus] em alta taxa (60 FPS / gameInterval).
/// 2. Aplicar Filtro Passa-Baixa (Low-Pass Filter) para suavizar trepidações mecânicas.
/// 3. Calcular Roll e Pitch com fórmulas trigonométricas de precisão (`atan2`).
/// 4. Manter fallback e gerador de dados mockados para testes em emuladores e desktop.
class SensorOrientationService {
  /// Fator de atenuação do filtro passa-baixa (0.0 = congelado, 1.0 = sem filtro).
  final double alpha;

  /// Stream opcional de eventos de acelerômetro para testes e injeção de dependência.
  final Stream<AccelerometerEvent>? customAccelerometerStream;

  /// Stream opcional de eventos de giroscópio para testes e injeção de dependência.
  final Stream<GyroscopeEvent>? customGyroscopeStream;

  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
  StreamSubscription<GyroscopeEvent>? _gyroscopeSubscription;
  final StreamController<OrientationReading> _controller =
      StreamController<OrientationReading>.broadcast();

  Timer? _mockTimer;
  double _mockTick = 0.0;

  // Estados anteriores do filtro passa-baixa (Acelerômetro)
  double _filteredX = 0.0;
  double _filteredY = 0.0;
  double _filteredZ = 9.81;

  // Estados atuais do Giroscópio
  double _currentGyroX = 0.0;
  double _currentGyroY = 0.0;
  double _currentGyroZ = 0.0;

  SensorOrientationService({
    this.alpha = 0.15,
    this.customAccelerometerStream,
    this.customGyroscopeStream,
  });

  /// Stream unificado de leituras inerciais filtradas.
  Stream<OrientationReading> get orientationStream => _controller.stream;

  /// Inicia a escuta dos sensores de hardware com fallback para dados simulados.
  void startListening({bool allowMockFallback = true}) {
    stopListening();

    if (allowMockFallback) {
      _startMockSimulation();
    }

    try {
      final Stream<AccelerometerEvent> rawStream = customAccelerometerStream ??
          accelerometerEventStream(samplingPeriod: SensorInterval.gameInterval);

      _accelerometerSubscription = rawStream.listen(
        (AccelerometerEvent event) {
          _cancelMockTimer();

          // Aplicação do Filtro Passa-Baixa:
          _filteredX = (alpha * event.x) + ((1.0 - alpha) * _filteredX);
          _filteredY = (alpha * event.y) + ((1.0 - alpha) * _filteredY);
          _filteredZ = (alpha * event.z) + ((1.0 - alpha) * _filteredZ);

          final reading = _calculateAngles(
            _filteredX,
            _filteredY,
            _filteredZ,
            gyroX: _currentGyroX,
            gyroY: _currentGyroY,
            gyroZ: _currentGyroZ,
            isFromHardware: true,
          );

          if (!_controller.isClosed) {
            _controller.add(reading);
          }
        },
        onError: (error) {
          if (allowMockFallback && _mockTimer == null) {
            _startMockSimulation();
          }
        },
        cancelOnError: false,
      );
    } catch (_) {
      if (allowMockFallback && _mockTimer == null) {
        _startMockSimulation();
      }
    }

    try {
      final Stream<GyroscopeEvent> rawGyroStream = customGyroscopeStream ??
          gyroscopeEventStream(samplingPeriod: SensorInterval.gameInterval);

      _gyroscopeSubscription = rawGyroStream.listen(
        (GyroscopeEvent event) {
          _currentGyroX = event.x;
          _currentGyroY = event.y;
          _currentGyroZ = event.z;
        },
        onError: (_) {},
        cancelOnError: false,
      );
    } catch (_) {}
  }

  /// Inicia a simulação harmônica mockada (para emuladores e ambiente de desenvolvimento).
  void _startMockSimulation() {
    _cancelMockTimer();

    final initialReading = _calculateAngles(
      _filteredX,
      _filteredY,
      _filteredZ,
      gyroX: 0.0,
      gyroY: 0.0,
      gyroZ: 0.0,
      isFromHardware: false,
    );
    if (!_controller.isClosed) {
      _controller.add(initialReading);
    }

    _mockTimer = Timer.periodic(const Duration(milliseconds: 33), (_) {
      _mockTick += 0.033;

      // Gera variações senoidais harmônicas suaves
      final mockX = math.sin(_mockTick * 0.8) * 1.6 + math.cos(_mockTick * 1.9) * 0.3;
      final mockY = math.cos(_mockTick * 0.7) * 1.3 + math.sin(_mockTick * 1.5) * 0.3;
      const mockZ = 9.81;

      // Giroscópio simulado (taxas de rotação em rad/s)
      final mockGyroX = math.cos(_mockTick * 1.2) * 0.45;
      final mockGyroY = math.sin(_mockTick * 1.0) * 0.35;
      final mockGyroZ = math.sin(_mockTick * 0.6) * 0.15;

      _filteredX = (alpha * mockX) + ((1.0 - alpha) * _filteredX);
      _filteredY = (alpha * mockY) + ((1.0 - alpha) * _filteredY);
      _filteredZ = (alpha * mockZ) + ((1.0 - alpha) * _filteredZ);

      final reading = _calculateAngles(
        _filteredX,
        _filteredY,
        _filteredZ,
        gyroX: mockGyroX,
        gyroY: mockGyroY,
        gyroZ: mockGyroZ,
        isFromHardware: false,
      );

      if (!_controller.isClosed) {
        _controller.add(reading);
      }
    });
  }

  /// Converte acelerações cartesianas (X, Y, Z) em ângulos de Roll e Pitch em graus.
  OrientationReading _calculateAngles(
    double ax,
    double ay,
    double az, {
    double gyroX = 0.0,
    double gyroY = 0.0,
    double gyroZ = 0.0,
    required bool isFromHardware,
  }) {
    final rollRad = math.atan2(ax, math.sqrt(ay * ay + az * az));
    final pitchRad = math.atan2(ay, math.sqrt(ax * ax + az * az));

    final rollDeg = rollRad * (180.0 / math.pi);
    final pitchDeg = pitchRad * (180.0 / math.pi);

    return OrientationReading(
      roll: double.parse(rollDeg.toStringAsFixed(2)),
      pitch: double.parse(pitchDeg.toStringAsFixed(2)),
      accelX: ax,
      accelY: ay,
      accelZ: az,
      gyroX: gyroX,
      gyroY: gyroY,
      gyroZ: gyroZ,
      isFromHardware: isFromHardware,
    );
  }

  void _cancelMockTimer() {
    _mockTimer?.cancel();
    _mockTimer = null;
  }

  /// Encerra as assinaturas e libera os recursos.
  void stopListening() {
    try {
      _accelerometerSubscription?.cancel().catchError((_) {});
    } catch (_) {}
    try {
      _gyroscopeSubscription?.cancel().catchError((_) {});
    } catch (_) {}
    _accelerometerSubscription = null;
    _gyroscopeSubscription = null;
    _cancelMockTimer();
  }

  /// Descarta o serviço completamente.
  void dispose() {
    stopListening();
    _controller.close();
  }
}
