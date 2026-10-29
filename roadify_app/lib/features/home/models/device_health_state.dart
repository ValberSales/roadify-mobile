import 'package:battery_plus/battery_plus.dart';
import 'package:flutter/foundation.dart';

/// Classificação da qualidade de recepção e precisão do sinal de GPS (SP2-02).
enum GpsSignalQuality {
  forte('Forte'),
  medio('Médio'),
  fraco('Fraco');

  final String label;
  const GpsSignalQuality(this.label);

  /// Classifica o sinal com base no raio de incerteza horizontal em metros:
  /// - Forte: <= 10,0 m
  /// - Médio: > 10,0 m e <= 25,0 m
  /// - Fraco: > 25,0 m ou serviço indisponível
  static GpsSignalQuality fromAccuracy(
    double? accuracyMeters, {
    bool isServiceEnabled = true,
  }) {
    if (!isServiceEnabled || accuracyMeters == null || accuracyMeters.isNaN) {
      return GpsSignalQuality.fraco;
    }
    if (accuracyMeters <= 10.0) {
      return GpsSignalQuality.forte;
    }
    if (accuracyMeters <= 25.0) {
      return GpsSignalQuality.medio;
    }
    return GpsSignalQuality.fraco;
  }
}

/// Estado imutável de diagnóstico de Bateria e Sinal GPS para a HomeScreen (SP2-02).
@immutable
class DeviceHealthState {
  /// Limite percentual mínimo seguro de bateria para iniciar um ensaio em pista.
  static const int safeBatteryThreshold = 20;

  /// Percentual atual da bateria (0 a 100%).
  final int batteryLevel;

  /// Estado atual de carregamento da bateria (`battery_plus`).
  final BatteryState batteryState;

  /// Raio de incerteza do sinal GPS em metros (`geolocator`).
  final double? gpsAccuracyMeters;

  /// Indica se o serviço de localização e permissões de GPS estão ativos.
  final bool isGpsServiceEnabled;

  /// Indica se os dados vieram de leitura real de hardware.
  final bool isFromHardware;

  const DeviceHealthState({
    this.batteryLevel = 85,
    this.batteryState = BatteryState.discharging,
    this.gpsAccuracyMeters = 4.5,
    this.isGpsServiceEnabled = true,
    this.isFromHardware = false,
  });

  /// Indica se o dispositivo está conectado ao carregador ou com carga completa.
  bool get isCharging =>
      batteryState == BatteryState.charging ||
      batteryState == BatteryState.full ||
      batteryState == BatteryState.connectedNotCharging;

  /// Rótulo legível do status de carregamento da bateria.
  String get chargingStatusLabel => switch (batteryState) {
    BatteryState.charging => 'Carregando',
    BatteryState.full => 'Carregada',
    BatteryState.connectedNotCharging => 'Conectada',
    BatteryState.discharging => 'Descarregando',
    BatteryState.unknown => 'Em uso',
  };

  /// Indica se o nível de bateria está abaixo do limite seguro (< 20%) para ensaio.
  bool get isBatteryBelowSafeLimit => batteryLevel < safeBatteryThreshold;

  /// Qualidade calculada do sinal de GPS (Forte / Médio / Fraco).
  GpsSignalQuality get gpsSignalQuality => GpsSignalQuality.fromAccuracy(
    gpsAccuracyMeters,
    isServiceEnabled: isGpsServiceEnabled,
  );

  /// Raio de incerteza formatado em metros (ex: `± 4,5 m`).
  String get gpsUncertaintyLabel {
    if (!isGpsServiceEnabled || gpsAccuracyMeters == null) {
      return 'Sem sinal (± -- m)';
    }
    final formatted = gpsAccuracyMeters!
        .toStringAsFixed(1)
        .replaceAll('.', ',');
    return '± $formatted m';
  }

  DeviceHealthState copyWith({
    int? batteryLevel,
    BatteryState? batteryState,
    Object? gpsAccuracyMeters = _sentinel,
    bool? isGpsServiceEnabled,
    bool? isFromHardware,
  }) {
    return DeviceHealthState(
      batteryLevel: batteryLevel ?? this.batteryLevel,
      batteryState: batteryState ?? this.batteryState,
      gpsAccuracyMeters: identical(gpsAccuracyMeters, _sentinel)
          ? this.gpsAccuracyMeters
          : gpsAccuracyMeters as double?,
      isGpsServiceEnabled: isGpsServiceEnabled ?? this.isGpsServiceEnabled,
      isFromHardware: isFromHardware ?? this.isFromHardware,
    );
  }

  static const Object _sentinel = Object();
}
