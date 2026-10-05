import 'dart:math' as math;

/// Modos de exibição do nível bolha.
enum BubbleDisplayMode {
  /// Alterna automaticamente entre Circular (horizontal) e Tubular T (vertical).
  auto('Automático'),

  /// Bolha circular concêntrica 2D (ideal para smartphone deitado na mesa).
  circular2D('Circular 2D'),

  /// Nível tubular em formato T com eixos horizontal e vertical (smartphone no suporte do carro).
  tubularT('Tubular em T');

  final String label;
  const BubbleDisplayMode(this.label);
}

/// Orientação física estimada ou detectada do smartphone.
enum DeviceOrientationMode {
  /// Smartphone repousado na horizontal (mesa/bancada, tela para cima).
  horizontal('Deitado (Mesa)'),

  /// Smartphone na vertical ou inclinado em suporte veicular de para-brisa/painel.
  vertical('Vertical (Suporte)');

  final String label;
  const DeviceOrientationMode(this.label);
}

/// Estado imutável dos dados do Nível Bolha.
class NivelBolhaState {
  /// Inclinação no eixo X (Roll / lateral) em graus (-90° a +90°).
  final double angleX;

  /// Inclinação no eixo Y (Pitch / longitudinal) em graus (-90° a +90°).
  final double angleY;

  /// Offset de calibração (tara) gravado para o eixo X.
  final double calibOffsetX;

  /// Offset de calibração (tara) gravado para o eixo Y.
  final double calibOffsetY;

  /// Modo selecionado pelo usuário (Auto, Circular 2D ou Tubular T).
  final BubbleDisplayMode selectedMode;

  /// Orientação detectada com base no sensor gravitacional simulado/real.
  final DeviceOrientationMode detectedOrientation;

  /// Indica se a referência de zero já foi calibrada pelo usuário.
  final bool isCalibrated;

  /// Valor da aceleração do eixo Z (em m/s²), usado para detecção de postura.
  final double accelZ;

  /// Indica se os dados estão vindo do hardware real (sensors_plus) ou simulação mockada.
  final bool isReadingFromHardware;

  const NivelBolhaState({
    this.angleX = 0.0,
    this.angleY = 0.0,
    this.calibOffsetX = 0.0,
    this.calibOffsetY = 0.0,
    this.selectedMode = BubbleDisplayMode.auto,
    this.detectedOrientation = DeviceOrientationMode.horizontal,
    this.isCalibrated = false,
    this.accelZ = 9.81,
    this.isReadingFromHardware = false,
  });

  /// Ângulo do eixo X com tara compensada.
  double get calibratedAngleX => angleX - calibOffsetX;

  /// Ângulo do eixo Y com tara compensada.
  double get calibratedAngleY => angleY - calibOffsetY;

  /// Magnitude angular total combinada (em graus).
  double get totalInclination => math.sqrt(
        (calibratedAngleX * calibratedAngleX) + (calibratedAngleY * calibratedAngleY),
      );

  /// Tolerância limite de alinhamento perfeito (0.5 graus).
  static const double tolerance = 0.5;

  /// Indica se o dispositivo está perfeitamente nivelado em ambos os eixos.
  bool get isLevel => totalInclination <= tolerance;

  /// Nivelamento específico do eixo X.
  bool get isLevelX => calibratedAngleX.abs() <= tolerance;

  /// Nivelamento específico do eixo Y.
  bool get isLevelY => calibratedAngleY.abs() <= tolerance;

  /// Retorna o modo ativo de exibição (resolvendo 'auto' para o modo físico correspondente).
  BubbleDisplayMode get activeMode {
    if (selectedMode == BubbleDisplayMode.auto) {
      return detectedOrientation == DeviceOrientationMode.horizontal
          ? BubbleDisplayMode.circular2D
          : BubbleDisplayMode.tubularT;
    }
    return selectedMode;
  }

  /// Cria uma cópia com campos modificados.
  NivelBolhaState copyWith({
    double? angleX,
    double? angleY,
    double? calibOffsetX,
    double? calibOffsetY,
    BubbleDisplayMode? selectedMode,
    DeviceOrientationMode? detectedOrientation,
    bool? isCalibrated,
    double? accelZ,
    bool? isReadingFromHardware,
  }) {
    return NivelBolhaState(
      angleX: angleX ?? this.angleX,
      angleY: angleY ?? this.angleY,
      calibOffsetX: calibOffsetX ?? this.calibOffsetX,
      calibOffsetY: calibOffsetY ?? this.calibOffsetY,
      selectedMode: selectedMode ?? this.selectedMode,
      detectedOrientation: detectedOrientation ?? this.detectedOrientation,
      isCalibrated: isCalibrated ?? this.isCalibrated,
      accelZ: accelZ ?? this.accelZ,
      isReadingFromHardware: isReadingFromHardware ?? this.isReadingFromHardware,
    );
  }
}
