import '../../sensores/models/nivel_bolha_state.dart';

enum SensorColeta { acelerometro, giroscopio, gps, camera, audio }

enum CollectionOrientation { vertical, horizontal }

enum CollectionPosture { standing, lyingDown }

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
  final String trecho;
  final String identificador;
  final int? vehicleId;
  final double odometroInicial;
  final CollectionOrientation orientation;
  final CollectionPosture posture;
  final double calibrationOffsetX;
  final double calibrationOffsetY;
  final BubbleDisplayMode levelingMode;
  final bool isCalibrated;

  ConfiguracaoColeta({
    required Set<SensorColeta> sensoresSelecionados,
    required this.taxaInercialHz,
    required this.taxaGpsHz,
    required this.intervaloMetros,
    this.sensoresOpcionais = const OptionalSensorSettings(),
    this.nomeColeta,
    this.trecho = '',
    this.identificador = '',
    this.vehicleId,
    this.odometroInicial = 0,
    this.orientation = CollectionOrientation.vertical,
    this.posture = CollectionPosture.standing,
    this.calibrationOffsetX = 0,
    this.calibrationOffsetY = 0,
    this.levelingMode = BubbleDisplayMode.auto,
    this.isCalibrated = false,
  }) : sensoresSelecionados = Set.unmodifiable(sensoresSelecionados);

  /// Frequência de amostragem do sensor acelerômetro em Hz.
  int get taxaAcelerometroHz => taxaInercialHz;

  ConfiguracaoColeta copyWith({
    Set<SensorColeta>? sensoresSelecionados,
    int? taxaInercialHz,
    int? taxaGpsHz,
    double? intervaloMetros,
    OptionalSensorSettings? sensoresOpcionais,
    String? nomeColeta,
    String? trecho,
    String? identificador,
    int? vehicleId,
    double? odometroInicial,
    CollectionOrientation? orientation,
    CollectionPosture? posture,
    double? calibrationOffsetX,
    double? calibrationOffsetY,
    BubbleDisplayMode? levelingMode,
    bool? isCalibrated,
  }) {
    return ConfiguracaoColeta(
      sensoresSelecionados: sensoresSelecionados ?? this.sensoresSelecionados,
      taxaInercialHz: taxaInercialHz ?? this.taxaInercialHz,
      taxaGpsHz: taxaGpsHz ?? this.taxaGpsHz,
      intervaloMetros: intervaloMetros ?? this.intervaloMetros,
      sensoresOpcionais: sensoresOpcionais ?? this.sensoresOpcionais,
      nomeColeta: nomeColeta ?? this.nomeColeta,
      trecho: trecho ?? this.trecho,
      identificador: identificador ?? this.identificador,
      vehicleId: vehicleId ?? this.vehicleId,
      odometroInicial: odometroInicial ?? this.odometroInicial,
      orientation: orientation ?? this.orientation,
      posture: posture ?? this.posture,
      calibrationOffsetX: calibrationOffsetX ?? this.calibrationOffsetX,
      calibrationOffsetY: calibrationOffsetY ?? this.calibrationOffsetY,
      levelingMode: levelingMode ?? this.levelingMode,
      isCalibrated: isCalibrated ?? this.isCalibrated,
    );
  }

  void validarParaGravacao() {
    if (!sensoresSelecionados.contains(SensorColeta.acelerometro) ||
        !sensoresSelecionados.contains(SensorColeta.gps)) {
      throw StateError('Acelerômetro e GPS são obrigatórios para iniciar.');
    }
    if (trecho.trim().isEmpty) {
      throw StateError('Informe o trecho da coleta.');
    }
    if (identificador.trim().isEmpty) {
      throw StateError('Informe o identificador do ensaio.');
    }
    if (vehicleId == null) {
      throw StateError('Selecione um veículo para a coleta.');
    }
    if (!odometroInicial.isFinite ||
        odometroInicial < 0 ||
        odometroInicial > 2000000) {
      throw StateError('Informe uma quilometragem válida.');
    }
    if (taxaInercialHz < 50 || taxaInercialHz > 500) {
      throw StateError(
        'A frequência do acelerômetro deve estar entre 50 e 500 Hz.',
      );
    }
    if (taxaGpsHz < 1 || taxaGpsHz > 10) {
      throw StateError('A frequência do GPS deve estar entre 1 e 10 Hz.');
    }
    if (!intervaloMetros.isFinite || intervaloMetros <= 0) {
      throw StateError('O intervalo de gravação deve ser positivo.');
    }

    final options = sensoresOpcionais;
    if (sensoresSelecionados.contains(SensorColeta.giroscopio) &&
        (options.gyroscopeFrequencyHz < 50 ||
            options.gyroscopeFrequencyHz > 500)) {
      throw StateError(
        'A frequência do giroscópio deve estar entre 50 e 500 Hz.',
      );
    }
    if (sensoresSelecionados.contains(SensorColeta.camera)) {
      final camera = options.camera;
      if (camera.mediaType != CameraMediaType.photos &&
          (camera.videoDurationSeconds < 1 ||
              camera.videoDurationSeconds > 120)) {
        throw StateError(
          'A duração máxima do vídeo deve ser de 1 a 120 segundos.',
        );
      }
      if (camera.automatic) {
        _validateInterval(camera.interval, camera.intervalUnit);
      }
    }
    if (sensoresSelecionados.contains(SensorColeta.audio)) {
      final audio = options.audio;
      if (audio.durationSeconds < 1 || audio.durationSeconds > 300) {
        throw StateError(
          'A duração máxima do áudio deve ser de 1 a 300 segundos.',
        );
      }
      if (audio.automatic) {
        _validateInterval(audio.interval, audio.intervalUnit);
      }
    }
  }

  void _validateInterval(int interval, CaptureIntervalUnit unit) {
    final (minimum, maximum) = switch (unit) {
      CaptureIntervalUnit.minutes => (1, 59),
      CaptureIntervalUnit.hours => (1, 24),
      CaptureIntervalUnit.meters => (1, 9999),
      CaptureIntervalUnit.kilometers => (1, 999),
    };
    if (interval < minimum || interval > maximum) {
      throw StateError(
        'O intervalo automático deve estar entre $minimum e $maximum.',
      );
    }
  }
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
