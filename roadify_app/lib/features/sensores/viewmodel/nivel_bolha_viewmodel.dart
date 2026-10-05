import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/nivel_bolha_state.dart';
import '../services/sensor_orientation_service.dart';

/// ViewModel desacoplada para gerenciamento do Nível Bolha (Feature Sensores).
///
/// Implementa:
/// 1. Conexão ao [SensorOrientationService] (leitura inercial real via sensors_plus com filtro passa-baixa).
/// 2. Lógica de calibração de tara angular (compensação da montagem no para-brisa).
/// 3. Alternância entre modos (Circular 2D e Tubular em T).
/// 4. Fallback automático com dados simulados/mockados caso o hardware inercial não esteja presente.
class NivelBolhaViewModel extends ChangeNotifier {
  final SensorOrientationService _orientationService;
  StreamSubscription<OrientationReading>? _orientationSubscription;

  NivelBolhaState _state = const NivelBolhaState(
    angleX: 0.0,
    angleY: 0.0,
    detectedOrientation: DeviceOrientationMode.horizontal,
    selectedMode: BubbleDisplayMode.auto,
  );

  /// Estado imutável atual exposto para as views.
  NivelBolhaState get state => _state;

  NivelBolhaViewModel({
    SensorOrientationService? orientationService,
    bool autoStart = true,
  }) : _orientationService = orientationService ?? SensorOrientationService() {
    if (autoStart) {
      _initService();
    }
  }

  void _initService() {
    _orientationSubscription = _orientationService.orientationStream.listen(
      (OrientationReading reading) {
        // Se a aceleração no eixo Z for alta (> 6.5 m/s²), o aparelho está deitado na mesa
        // Se for menor, está inclinado ou em pé no suporte veicular
        final autoDetected = reading.accelZ.abs() > 6.5
            ? DeviceOrientationMode.horizontal
            : DeviceOrientationMode.vertical;

        // Se o modo selecionado for manual, a postura reflete o instrumento escolhido;
        // se for automático, reflete a leitura inercial do sensor
        final resolvedOrientation = _state.selectedMode == BubbleDisplayMode.circular2D
            ? DeviceOrientationMode.horizontal
            : (_state.selectedMode == BubbleDisplayMode.tubularT
                ? DeviceOrientationMode.vertical
                : autoDetected);

        _state = _state.copyWith(
          angleX: reading.roll,
          angleY: reading.pitch,
          accelZ: reading.accelZ,
          detectedOrientation: resolvedOrientation,
          isReadingFromHardware: reading.isFromHardware,
        );
        notifyListeners();
      },
    );

    _orientationService.startListening(allowMockFallback: true);
  }

  /// Define explicitamente os ângulos (útil para testes unitários ou sliders manuais).
  void setAngles(double x, double y) {
    _state = _state.copyWith(
      angleX: double.parse(x.toStringAsFixed(2)),
      angleY: double.parse(y.toStringAsFixed(2)),
    );
    notifyListeners();
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
    notifyListeners();
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
    notifyListeners();
  }

  /// Restaura a calibração original de fábrica (remove a tara).
  void resetCalibration() {
    _state = _state.copyWith(
      calibOffsetX: 0.0,
      calibOffsetY: 0.0,
      isCalibrated: false,
    );
    notifyListeners();
  }

  /// Atualização direta a partir de valores de aceleração (útil para injeção manual ou testes).
  void updateFromSensors({
    required double accelX,
    required double accelY,
    required double accelZ,
  }) {
    // Cálculo do Roll (inclinação lateral no eixo X)
    final rollRad = (accelX != 0 || accelY != 0 || accelZ != 0)
        ? (accelX / (accelY * accelY + accelZ * accelZ > 0 ? (accelY * accelY + accelZ * accelZ) : 1))
        : 0.0;
    // Cálculo trigonométrico
    final degX = double.parse((rollRad * 180.0 / 3.1415926535).toStringAsFixed(2));
    final degY = double.parse(((accelY) * 180.0 / (3.1415926535 * 9.81)).toStringAsFixed(2));

    final detected = accelZ.abs() > 6.5
        ? DeviceOrientationMode.horizontal
        : DeviceOrientationMode.vertical;

    _state = _state.copyWith(
      angleX: degX,
      angleY: degY,
      accelZ: accelZ,
      detectedOrientation: detected,
    );
    notifyListeners();
  }

  @override
  void dispose() {
    _orientationSubscription?.cancel();
    _orientationService.dispose();
    super.dispose();
  }
}
