import 'dart:async';
import 'dart:math' as math;
import 'package:sensors_plus/sensors_plus.dart';

/// Modelo de dados emitido pelo serviço de orientação.
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

  /// Indica se a leitura provém do hardware físico real do dispositivo.
  final bool isFromHardware;

  const OrientationReading({
    required this.roll,
    required this.pitch,
    required this.accelX,
    required this.accelY,
    required this.accelZ,
    this.isFromHardware = false,
  });
}

/// Serviço de aquisição inercial e cálculo de orientação (Feature Sensores).
///
/// Responsável por:
/// 1. Escutar os sensores de aceleração do hardware via [sensors_plus].
/// 2. Aplicar Filtro Passa-Baixa (Low-Pass Filter) para suavizar trepidações mecânicas.
/// 3. Calcular Roll e Pitch com fórmulas trigonométricas de precisão (`atan2`).
/// 4. Manter fallback e gerador de dados mockados para testes em emuladores e desktop.
class SensorOrientationService {
  /// Fator de atenuação do filtro passa-baixa (0.0 = congelado, 1.0 = sem filtro).
  /// O valor 0.15 amortece perfeitamente ruídos de alta frequência do motor veicular.
  final double alpha;

  /// Stream opcional de eventos de acelerômetro para injeção de dependência e testes.
  final Stream<AccelerometerEvent>? customAccelerometerStream;

  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
  final StreamController<OrientationReading> _controller =
      StreamController<OrientationReading>.broadcast();

  Timer? _mockTimer;
  double _mockTick = 0.0;

  // Estados anteriores do filtro passa-baixa
  double _filteredX = 0.0;
  double _filteredY = 0.0;
  double _filteredZ = 9.81;

  SensorOrientationService({
    this.alpha = 0.15,
    this.customAccelerometerStream,
  });

  /// Stream unificado de leituras inerciais filtradas.
  Stream<OrientationReading> get orientationStream => _controller.stream;

  /// Inicia a escuta dos sensores de hardware com fallback para dados simulados.
  void startListening({bool allowMockFallback = true}) {
    stopListening();

    // Se o fallback estiver ativo, inicia a simulação imediatamente
    if (allowMockFallback) {
      _startMockSimulation();
    }

    try {
      final Stream<AccelerometerEvent> rawStream = customAccelerometerStream ??
          accelerometerEventStream(samplingPeriod: SensorInterval.uiInterval);

      _accelerometerSubscription = rawStream.listen(
        (AccelerometerEvent event) {
          // Quando eventos reais do hardware chegam, cancela a simulação mockada
          _cancelMockTimer();

          // Aplicação do Filtro Passa-Baixa:
          // filtered = alpha * new + (1 - alpha) * previous
          _filteredX = (alpha * event.x) + ((1.0 - alpha) * _filteredX);
          _filteredY = (alpha * event.y) + ((1.0 - alpha) * _filteredY);
          _filteredZ = (alpha * event.z) + ((1.0 - alpha) * _filteredZ);

          final reading = _calculateAngles(
            _filteredX,
            _filteredY,
            _filteredZ,
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
  }

  /// Inicia a simulação harmônica mockada (para emuladores e ambiente de desenvolvimento).
  void _startMockSimulation() {
    _cancelMockTimer();

    // Emite imediatamente o primeiro frame
    final initialReading = _calculateAngles(
      _filteredX,
      _filteredY,
      _filteredZ,
      isFromHardware: false,
    );
    if (!_controller.isClosed) {
      _controller.add(initialReading);
    }

    _mockTimer = Timer.periodic(const Duration(milliseconds: 50), (_) {
      _mockTick += 0.05;

      // Gera pequenas variações senoidais harmônicas
      final mockX = math.sin(_mockTick * 0.8) * 1.6 + math.cos(_mockTick * 1.9) * 0.3;
      final mockY = math.cos(_mockTick * 0.7) * 1.3 + math.sin(_mockTick * 1.5) * 0.3;
      const mockZ = 9.81;

      // Passa também pelo filtro para garantir suavidade matemática
      _filteredX = (alpha * mockX) + ((1.0 - alpha) * _filteredX);
      _filteredY = (alpha * mockY) + ((1.0 - alpha) * _filteredY);
      _filteredZ = (alpha * mockZ) + ((1.0 - alpha) * _filteredZ);

      final reading = _calculateAngles(
        _filteredX,
        _filteredY,
        _filteredZ,
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
    required bool isFromHardware,
  }) {
    // Equações trigonométricas padronizadas de atitude e navegação inercial:
    // Roll: rotação em torno do eixo X (inclinação lateral)
    final rollRad = math.atan2(ax, math.sqrt(ay * ay + az * az));
    // Pitch: rotação em torno do eixo Y (inclinação longitudinal)
    final pitchRad = math.atan2(ay, math.sqrt(ax * ax + az * az));

    final rollDeg = rollRad * (180.0 / math.pi);
    final pitchDeg = pitchRad * (180.0 / math.pi);

    return OrientationReading(
      roll: double.parse(rollDeg.toStringAsFixed(2)),
      pitch: double.parse(pitchDeg.toStringAsFixed(2)),
      accelX: ax,
      accelY: ay,
      accelZ: az,
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
    _accelerometerSubscription = null;
    _cancelMockTimer();
  }

  /// Descarta o serviço completamente.
  void dispose() {
    stopListening();
    _controller.close();
  }
}
