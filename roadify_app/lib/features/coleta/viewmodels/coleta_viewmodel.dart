enum SensorColeta { acelerometro, giroscopio, gps, camera, audio }

enum CaptureIntervalUnit { minutes, hours, meters, kilometers }

enum CameraMediaType { photos, videos, photosAndVideos }

enum CameraFacing { front, rear }

class CameraCaptureSettings {
  final CameraMediaType mediaType;
  final CameraFacing facing;
  final bool automatic;
  final int interval;
  final CaptureIntervalUnit intervalUnit;
  final int videoDurationSeconds;

  const CameraCaptureSettings({
    this.mediaType = CameraMediaType.photos,
    this.facing = CameraFacing.rear,
    this.automatic = false,
    this.interval = 1,
    this.intervalUnit = CaptureIntervalUnit.minutes,
    this.videoDurationSeconds = 60,
  });
}

class AudioCaptureSettings {
  final bool automatic;
  final int interval;
  final CaptureIntervalUnit intervalUnit;
  final int durationSeconds;

  const AudioCaptureSettings({
    this.automatic = false,
    this.interval = 1,
    this.intervalUnit = CaptureIntervalUnit.minutes,
    this.durationSeconds = 30,
  });
}

class OptionalSensorSettings {
  final int gyroscopeFrequencyHz;
  final CameraCaptureSettings camera;
  final AudioCaptureSettings audio;

  const OptionalSensorSettings({
    this.gyroscopeFrequencyHz = 100,
    this.camera = const CameraCaptureSettings(),
    this.audio = const AudioCaptureSettings(),
  });
}

class ConfiguracaoColeta {
  final Set<SensorColeta> sensoresSelecionados;
  final int taxaInercialHz;
  final int taxaGpsHz;
  final double intervaloMetros;
  final OptionalSensorSettings sensoresOpcionais;
  final String? nomeColeta;
  final int? vehicleId;
  final double odometroInicial;

  ConfiguracaoColeta({
    required Set<SensorColeta> sensoresSelecionados,
    required this.taxaInercialHz,
    required this.taxaGpsHz,
    required this.intervaloMetros,
    this.sensoresOpcionais = const OptionalSensorSettings(),
    this.nomeColeta,
    this.vehicleId,
    this.odometroInicial = 0,
  }) : sensoresSelecionados = Set.unmodifiable(sensoresSelecionados);

  /// Frequência de amostragem do sensor acelerômetro em Hz.
  int get taxaAcelerometroHz => taxaInercialHz;
}

abstract interface class ColetaViewModel {
  Future<void> prosseguirParaGravacao({
    required ConfiguracaoColeta configuracao,
  });
}

class MockColetaViewModel implements ColetaViewModel {
  ConfiguracaoColeta? ultimaConfiguracao;

  @override
  Future<void> prosseguirParaGravacao({
    required ConfiguracaoColeta configuracao,
  }) async {
    ultimaConfiguracao = configuracao;
  }
}
