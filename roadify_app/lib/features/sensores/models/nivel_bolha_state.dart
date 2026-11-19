import 'dart:math' as math;
import 'package:flutter/widgets.dart';
import 'package:roadify_app/l10n/app_localizations_catalog.dart';

/// Amostra instantânea de telemetria para os gráficos em tempo real ("Sinais ao Vivo").
class SensorSignalSample {
  final double accelX;
  final double accelY;
  final double accelZ;
  final double gyroX;
  final double gyroY;
  final double gyroZ;
  final double roll;
  final double pitch;

  const SensorSignalSample({
    required this.accelX,
    required this.accelY,
    required this.accelZ,
    this.gyroX = 0.0,
    this.gyroY = 0.0,
    this.gyroZ = 0.0,
    required this.roll,
    required this.pitch,
  });
}

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

  String localizedLabel(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return switch (this) {
      BubbleDisplayMode.auto => l10n.text('modeAuto'),
      BubbleDisplayMode.circular2D => l10n.text('modeCircular2D'),
      BubbleDisplayMode.tubularT => l10n.text('modeTubularT'),
    };
  }
}

/// Orientação física estimada ou detectada do smartphone.
enum DeviceOrientationMode {
  /// Smartphone repousado na horizontal (mesa/bancada, tela para cima).
  horizontal('Deitado (Mesa)'),

  /// Smartphone na vertical ou inclinado em suporte veicular de para-brisa/painel.
  vertical('Vertical (Suporte)');

  final String label;
  const DeviceOrientationMode(this.label);

  String localizedLabel(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return switch (this) {
      DeviceOrientationMode.horizontal => l10n.text('postureHorizontalTable'),
      DeviceOrientationMode.vertical => l10n.text('postureVerticalMount'),
    };
  }
}

/// Estado imutável dos dados do Nível Bolha e Sensores em Tempo Real.
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

  /// Valor da aceleração do eixo X (em m/s²).
  final double accelX;

  /// Valor da aceleração do eixo Y (em m/s²).
  final double accelY;

  /// Valor da aceleração do eixo Z (em m/s²), usado para detecção de postura.
  final double accelZ;

  /// Leitura do giroscópio no eixo X (rad/s ou deg/s).
  final double gyroX;

  /// Leitura do giroscópio no eixo Y (rad/s ou deg/s).
  final double gyroY;

  /// Leitura do giroscópio no eixo Z (rad/s ou deg/s).
  final double gyroZ;

  /// Velocidade instantânea do GPS (em km/h).
  final double gpsSpeed;

  /// Precisão estimada do sinal GPS (em metros).
  final double gpsAccuracy;

  /// Altitude do GPS (em metros).
  final double gpsAltitude;

  /// Latitude geográfica atual do GPS.
  final double gpsLatitude;

  /// Longitude geográfica atual do GPS.
  final double gpsLongitude;

  /// Indica se o sinal do GPS está ativo e recebendo dados válidos.
  final bool hasGpsSignal;

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
    this.accelX = 0.0,
    this.accelY = 0.0,
    this.accelZ = 9.81,
    this.gyroX = 0.0,
    this.gyroY = 0.0,
    this.gyroZ = 0.0,
    this.gpsSpeed = 0.0,
    this.gpsAccuracy = 0.0,
    this.gpsAltitude = 0.0,
    this.gpsLatitude = 0.0,
    this.gpsLongitude = 0.0,
    this.hasGpsSignal = false,
    this.isReadingFromHardware = false,
  });

  /// Ângulo do eixo X com tara compensada.
  double get calibratedAngleX => angleX - calibOffsetX;

  /// Ângulo do eixo Y com tara compensada.
  double get calibratedAngleY => angleY - calibOffsetY;

  /// Magnitude angular total combinada (em graus).
  double get totalInclination => math.sqrt(
    (calibratedAngleX * calibratedAngleX) +
        (calibratedAngleY * calibratedAngleY),
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
    double? accelX,
    double? accelY,
    double? accelZ,
    double? gyroX,
    double? gyroY,
    double? gyroZ,
    double? gpsSpeed,
    double? gpsAccuracy,
    double? gpsAltitude,
    double? gpsLatitude,
    double? gpsLongitude,
    bool? hasGpsSignal,
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
      accelX: accelX ?? this.accelX,
      accelY: accelY ?? this.accelY,
      accelZ: accelZ ?? this.accelZ,
      gyroX: gyroX ?? this.gyroX,
      gyroY: gyroY ?? this.gyroY,
      gyroZ: gyroZ ?? this.gyroZ,
      gpsSpeed: gpsSpeed ?? this.gpsSpeed,
      gpsAccuracy: gpsAccuracy ?? this.gpsAccuracy,
      gpsAltitude: gpsAltitude ?? this.gpsAltitude,
      gpsLatitude: gpsLatitude ?? this.gpsLatitude,
      gpsLongitude: gpsLongitude ?? this.gpsLongitude,
      hasGpsSignal: hasGpsSignal ?? this.hasGpsSignal,
      isReadingFromHardware:
          isReadingFromHardware ?? this.isReadingFromHardware,
    );
  }
}
