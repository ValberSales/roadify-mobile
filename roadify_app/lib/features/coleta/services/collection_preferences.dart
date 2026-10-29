import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../sensores/models/nivel_bolha_state.dart';
import '../viewmodels/coleta_viewmodel.dart';

class CollectionPreferences {
  static const _configurationKey = 'last_collection_configuration';

  final Future<SharedPreferences> Function() _preferencesProvider;
  Future<void> _writeQueue = Future<void>.value();

  CollectionPreferences({
    Future<SharedPreferences> Function()? preferencesProvider,
  }) : _preferencesProvider =
           preferencesProvider ?? SharedPreferences.getInstance;

  Future<ConfiguracaoColeta?> load() async {
    final preferences = await _preferencesProvider();
    final json = preferences.getString(_configurationKey);
    if (json == null) return null;

    final decoded = jsonDecode(json);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Configuração de coleta inválida.');
    }

    final optional = decoded['optionalSensors'];
    if (optional is! Map<String, dynamic>) {
      throw const FormatException('Sensores opcionais inválidos.');
    }
    final camera = optional['camera'];
    final audio = optional['audio'];
    if (camera is! Map<String, dynamic> || audio is! Map<String, dynamic>) {
      throw const FormatException('Configuração de mídia inválida.');
    }

    final sensorsValue = decoded['sensors'];
    if (sensorsValue is! List<dynamic>) {
      throw const FormatException('Sensores selecionados inválidos.');
    }
    final sensors = sensorsValue
        .map((value) => SensorColeta.values.byName(value as String))
        .toSet();

    return ConfiguracaoColeta(
      sensoresSelecionados: sensors,
      taxaInercialHz: _readInt(decoded, 'accelerometerFrequencyHz'),
      taxaGpsHz: _readInt(decoded, 'gpsFrequencyHz'),
      intervaloMetros: _readDouble(decoded, 'distanceIntervalMeters'),
      trecho: _readString(decoded, 'route'),
      identificador: _readString(decoded, 'identifier'),
      vehicleId: _readNullableInt(decoded, 'vehicleId'),
      odometroInicial: _readDouble(decoded, 'initialOdometer'),
      nomeColeta: _readString(decoded, 'collectionName'),
      orientation: CollectionOrientation.values.byName(
        _readStringOrDefault(decoded, 'orientation', 'vertical'),
      ),
      posture: CollectionPosture.values.byName(
        _readStringOrDefault(decoded, 'posture', 'standing'),
      ),
      calibrationOffsetX: _readDoubleOrDefault(
        decoded,
        'calibrationOffsetX',
        0,
      ),
      calibrationOffsetY: _readDoubleOrDefault(
        decoded,
        'calibrationOffsetY',
        0,
      ),
      levelingMode: BubbleDisplayMode.values.byName(
        _readStringOrDefault(decoded, 'levelingMode', 'auto'),
      ),
      isCalibrated: _readBoolOrDefault(decoded, 'isCalibrated', false),
      sensoresOpcionais: OptionalSensorSettings(
        gyroscopeFrequencyHz: _readInt(optional, 'gyroscopeFrequencyHz'),
        camera: CameraCaptureSettings(
          mediaType: CameraMediaType.values.byName(
            _readString(camera, 'mediaType'),
          ),
          facing: CameraFacing.values.byName(_readString(camera, 'facing')),
          automatic: _readBool(camera, 'automatic'),
          interval: _readInt(camera, 'interval'),
          intervalUnit: CaptureIntervalUnit.values.byName(
            _readString(camera, 'intervalUnit'),
          ),
          videoDurationSeconds: _readInt(camera, 'videoDurationSeconds'),
        ),
        audio: AudioCaptureSettings(
          automatic: _readBool(audio, 'automatic'),
          interval: _readInt(audio, 'interval'),
          intervalUnit: CaptureIntervalUnit.values.byName(
            _readString(audio, 'intervalUnit'),
          ),
          durationSeconds: _readInt(audio, 'durationSeconds'),
        ),
      ),
    );
  }

  Future<void> save(ConfiguracaoColeta configuration) async {
    final serialized = jsonEncode({
      'route': configuration.trecho,
      'identifier': configuration.identificador,
      'collectionName': configuration.nomeColeta ?? '',
      'vehicleId': configuration.vehicleId,
      'initialOdometer': configuration.odometroInicial,
      'orientation': configuration.orientation.name,
      'posture': configuration.posture.name,
      'calibrationOffsetX': configuration.calibrationOffsetX,
      'calibrationOffsetY': configuration.calibrationOffsetY,
      'levelingMode': configuration.levelingMode.name,
      'isCalibrated': configuration.isCalibrated,
      'sensors': configuration.sensoresSelecionados
          .map((sensor) => sensor.name)
          .toList(),
      'accelerometerFrequencyHz': configuration.taxaInercialHz,
      'gpsFrequencyHz': configuration.taxaGpsHz,
      'distanceIntervalMeters': configuration.intervaloMetros,
      'optionalSensors': {
        'gyroscopeFrequencyHz':
            configuration.sensoresOpcionais.gyroscopeFrequencyHz,
        'camera': {
          'mediaType': configuration.sensoresOpcionais.camera.mediaType.name,
          'facing': configuration.sensoresOpcionais.camera.facing.name,
          'automatic': configuration.sensoresOpcionais.camera.automatic,
          'interval': configuration.sensoresOpcionais.camera.interval,
          'intervalUnit':
              configuration.sensoresOpcionais.camera.intervalUnit.name,
          'videoDurationSeconds':
              configuration.sensoresOpcionais.camera.videoDurationSeconds,
        },
        'audio': {
          'automatic': configuration.sensoresOpcionais.audio.automatic,
          'interval': configuration.sensoresOpcionais.audio.interval,
          'intervalUnit':
              configuration.sensoresOpcionais.audio.intervalUnit.name,
          'durationSeconds':
              configuration.sensoresOpcionais.audio.durationSeconds,
        },
      },
    });
    final write = _writeQueue.then((_) async {
      final preferences = await _preferencesProvider();
      await preferences.setString(_configurationKey, serialized);
    });
    _writeQueue = write.catchError((Object _) {});
    await write;
  }

  static int _readInt(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is! int) throw FormatException('Valor inteiro inválido: $key.');
    return value;
  }

  static int? _readNullableInt(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value == null) return null;
    if (value is! int) throw FormatException('Valor inteiro inválido: $key.');
    return value;
  }

  static double _readDouble(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is! num) throw FormatException('Valor numérico inválido: $key.');
    return value.toDouble();
  }

  static String _readString(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is! String) throw FormatException('Texto inválido: $key.');
    return value;
  }

  static bool _readBool(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is! bool) throw FormatException('Valor lógico inválido: $key.');
    return value;
  }

  static String _readStringOrDefault(
    Map<String, dynamic> json,
    String key,
    String defaultValue,
  ) {
    final value = json[key];
    if (value == null) return defaultValue;
    if (value is! String) throw FormatException('Texto inválido: $key.');
    return value;
  }

  static double _readDoubleOrDefault(
    Map<String, dynamic> json,
    String key,
    double defaultValue,
  ) {
    final value = json[key];
    if (value == null) return defaultValue;
    if (value is! num) throw FormatException('Número inválido: $key.');
    return value.toDouble();
  }

  static bool _readBoolOrDefault(
    Map<String, dynamic> json,
    String key,
    bool defaultValue,
  ) {
    final value = json[key];
    if (value == null) return defaultValue;
    if (value is! bool) throw FormatException('Valor lógico inválido: $key.');
    return value;
  }
}
