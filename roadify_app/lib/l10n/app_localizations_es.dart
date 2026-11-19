// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Roadify';

  @override
  String get settingsTitle => 'Configuración';

  @override
  String get appearanceAndThemeTitle => 'Apariencia y Tema';

  @override
  String get appearanceDescription =>
      'Seleccione el modo de visualización preferido. El Modo Claro es el más recomendado para visibilidad en parabrisas.';

  @override
  String get themeLight => 'Claro';

  @override
  String get themeDark => 'Oscuro';

  @override
  String get themeSystem => 'Sistema';

  @override
  String get vehicleDefaultsTitle => 'Valores del Vehículo';

  @override
  String get defaultVehicleLabel => 'Vehículo Predeterminado';

  @override
  String get manageVehiclesTitle => 'Gestión de Vehículos';

  @override
  String get accelerometerRateLabel => 'Frecuencia del Acelerómetro';

  @override
  String get systemLanguageLabel => 'Idioma del Sistema';
  @override
  String get recordingsTitle => 'Grabaciones';

  @override
  String text(String key) => const <String, String>{
      'appTitle': 'Roadify',
      'settingsTitle': 'Configuración',
      'appearanceAndThemeTitle': 'Apariencia y Tema',
      'appearanceDescription': 'Seleccione el modo de visualización preferido. El Modo Claro es el más recomendado para visibilidad en parabrisas.',
      'themeLight': 'Claro',
      'themeDark': 'Oscuro',
      'themeSystem': 'Sistema',
      'vehicleDefaultsTitle': 'Valores del Vehículo',
      'defaultVehicleLabel': 'Vehículo Predeterminado',
      'manageVehiclesTitle': 'Gestión de Vehículos',
      'accelerometerRateLabel': 'Frecuencia del Acelerómetro',
      'systemLanguageLabel': 'Idioma del Sistema',
      'recordingsTitle': 'Grabaciones',
      'navHome': 'Inicio',
      'navCollection': 'Recopilación',
      'navSensors': 'Sensores',
      'navData': 'Datos',
      'navSettings': 'Configuración',
      'selectLanguage': 'Seleccionar idioma',
      'defaultAccelRate': 'Frecuencia predeterminada del acelerómetro',
      'recommended': 'Recomendado',
      'collectionOrientation': 'Orientación y nivelación',
      'backToSettings': 'Volver a la configuración',
      'startCollection': 'Iniciar recopilación',
      'removeCalibration': 'Quitar calibración',
      'recalibrateLevel': 'Recalibrar nivel',
      'calibrateLevel': 'Calibrar nivel',
      'newItem': 'Nuevo',
      'cancel': 'Cancelar',
      'delete': 'Eliminar',
      'close': 'Cerrar',
      'retry': 'Reintentar',
      'sort': 'Ordenar',
      'exportZip': 'Exportar ZIP',
      'deleteVehicle': 'Eliminar vehículo',
      'removeVehicleConfirm': '¿Desea eliminar "{name}" de la lista de vehículos?',
      'vehicleRemoved': 'Vehículo "{name}" eliminado.',
      'defaultVehicleSet': 'Vehículo predeterminado: {name} ({plate})',
      'editVehicle': 'Editar vehículo',
      'registerVehicle': 'Registrar vehículo',
      'vehicleIdentity': 'Identificación (p. ej., Pickup 01)',
      'makeModel': 'Marca / modelo (p. ej., Toyota Hilux)',
      'year': 'Año',
      'plate': 'Matrícula',
      'tractionOptional': 'Tracción (opcional)',
      'standardMileage': 'Kilometraje predeterminado (km)',
      'notesOptional': 'Notas / descripción (opcional)',
      'loadingRecordings': 'No se pudieron cargar las grabaciones.',
      'searchRuns': 'Buscar por nombre, fecha o carretera',
      'savedRunsDescription': 'Recopilaciones guardadas localmente y listas para exportar en ZIP.',
      'odometerStart': 'Odómetro inicial',
      'odometerEnd': 'Odómetro final',
      'distance': 'Distancia',
      'initialPoint': 'Punto inicial (Lat, Lng):',
      'finalPoint': 'Punto final (Lat, Lng):',
      'inertialSamples': 'Muestras inerciales',
      'gpsPoints': 'Puntos GPS',
      'mediaVolume': 'Medios / volumen',
      'permissionRequired': 'Permisos necesarios',
      'openSettings': 'Abrir configuración',
      'back': 'Volver',
      'preparingRecording': 'Preparando la grabación...',
      'continueRecording': 'Continuar a la grabación',
      'finishCollectionQuestion': '¿Finalizar recopilación?',
      'continueCollecting': 'Continuar recopilando',
      'finishAndSave': 'Finalizar y guardar',
      'collectionInProgress': 'Recopilación en curso',
      'sensorScreenTitle': 'Sensores y nivelación',
      'bubbleLevel': 'Nivel de burbuja',
      'requiredSensors': 'Sensores obligatorios',
      'optionalSensors': 'Sensores adicionales',
      'accelerometer': 'Acelerómetro',
      'gyroscope': 'Giroscopio',
      'camera': 'Cámara',
      'audio': 'Audio',
      'gps': 'GPS',
      'noVehicles': 'No hay vehículos registrados.',
      'saveVehicleSuccess': '¡Vehículo guardado correctamente!',
      'saveVehicleError': 'No se pudo guardar el vehículo. Inténtelo de nuevo.',
      'themeToggle': "Alternar tema claro / oscuro",
      'dataCollector': "Colector de datos de pavimento",
      'vehicleExample': "VEHÍCULO: TOYOTA HILUX (ABC-1234)",
      'vehiclePrefix': 'VEHÍCULO',
      'vehicleNoneRegistered': 'VEHÍCULO: NINGUNO REGISTRADO',
      'vehicleLoading': 'VEHÍCULO: CARGANDO...',
      'vehicleUnavailable': 'VEHÍCULO: NO DISPONIBLE',
      'calibrateBeforeDriving': "Calibre los sensores con el nivel de burbuja antes de conducir.",
      'startTrackCollection': "Iniciar recopilación en pista",
      'deviceStorage': "Almacenamiento del dispositivo",
      'availableStorage': "42 GB disponibles",
      'latestCollections': "Últimas recopilaciones",
      'lowBattery': 'Batería por debajo del límite seguro ({batteryLevel}%)',
      'batteryRecommendation': 'Nivel mínimo recomendado: {threshold}%. Conecte el cargador del vehículo antes de iniciar el ensayo.',
      'loadSettingsError': 'No se pudieron cargar los últimos ajustes: {error}',
      'savePreferencesError': 'No se pudieron guardar las preferencias: {error}',
      'requiredSensorsStart': "El acelerómetro y el GPS son obligatorios para iniciar la recopilación.",
      'reviewFrequencies': "Revise las frecuencias y la distancia indicadas.",
      'validStartingMileage': "Introduzca un kilometraje inicial válido.",
      'validAccelerometerFrequency': "Introduzca una frecuencia válida para el acelerómetro.",
      'sensorsPrepared': 'Recopilación preparada con {count} sensores.',
      'recordingStartError': 'No se pudo iniciar la grabación: {error}',
      'parameters': "Parámetros",
      'gpsDistanceDescription': "Defina la distancia mínima entre los puntos GPS almacenados. ",
      'otherSensorsDescription': "Las frecuencias de los otros sensores se configuran arriba.",
      'minGpsDistance': "Distancia mínima entre puntos GPS",
      'gpsDistanceHelp': "El GPS sigue leyendo a la frecuencia elegida; un punto solo se guarda después de recorrer al menos esta distancia.",
      'selectVehicle': "Seleccione el vehículo",
      'loadVehiclesError': "No se pudieron cargar los vehículos: ",
      'identity': "Identificación",
      'enterCollectionSegment': "Introduzca el tramo de la recopilación.",
      'testIdentifier': "Identificador del ensayo *",
      'enterTestIdentifier': "Introduzca el identificador del ensayo.",
      'selectVehicleForCollection': "Seleccione un vehículo para la recopilación.",
      'selectVehicleRequired': "Seleccionar vehículo *",
      'validMileageRange': "Introduzca un kilometraje entre 0 y 2.000.000 km.",
      'customFrequencyError': "Introduzca una frecuencia entera.",
      'frequencyRange': "Use un valor entre 50 y 500 Hz.",
      'durationIntegerError': "Introduzca una duración entera.",
      'videoDurationRange': "Entre 1 y 120 segundos (2 minutos) para limitar el almacenamiento.",
      'audioDurationRange': "Entre 1 y 300 segundos para limitar el almacenamiento.",
      'content': "Contenido",
      'videos': "Vídeos",
      'photosAndVideos': "Fotos y vídeos",
      'cameraUsed': "Cámara utilizada",
      'front': "Frontal",
      'rear': "Trasera",
      'videoMaxDuration': "Duración máxima del vídeo",
      'automaticCapture': "Captura automática",
      'optionalByTimeDistance': "Opcional • por tiempo o distancia recorrida",
      'automaticRecording': "Grabación automática",
      'recordingDuration': "Duración de cada grabación",
      'minutes': "Minutos",
      'hours': "Horas",
      'meters': "Metros",
      'kilometers': "Kilómetros",
      'requiredSensorsSubtitle': "Necesarios para registrar movimiento y ubicación.",
      'roadIrregularity': "Irregularidad y vibración de la vía",
      'sensorSafetyLimit': "Límite de seguridad del sensor",
      'gpsRoads': "Geolocalización y rutas de la pista",
      'gnssRange': "GNSS: de 1 Hz a 10 Hz.",
      'customFrequency': "Introducir frecuencia personalizada",
      'change': "Cambiar",
      'traction': "Tracción",
      'description': "Descripción",
      'liveSignals': "Señales en vivo",
      'levelingInstruction': "Coloque el smartphone en el soporte del vehículo o en la bancada y calibre la referencia.",
      'view': 'Visualización: {mode}',
      'sideTilt': "Inclinación lateral",
      'frontTilt': "Inclinación frontal",
      'misaligned': "Desalineado de la referencia",
      'live': "EN VIVO",
      'finishCollection': "¿Finalizar recopilación?",
      'continueCollecting2': "Continuar recopilando",
      'finishSave2': "Finalizar y guardar",
      'collectionProgress': "Recopilación en curso",
      'quickRoadPhoto': "Foto rápida de la vía",
      'distanceUpper': "DISTANCIA",
      'sensorParams': "Sensores y parámetros",
      'deviceMonitoring': "Monitorización del dispositivo",
      'appRam': "RAM DE LA APP",
      'audioStop': "Detener audio",
      'audioStart': "Iniciar grabación de audio",
      'cameraPreparing': "Preparando cámara...",
      'takeRoadPhoto': "TOMAR FOTO DE LA VÍA",
      'incidentImage': "Registrar imagen del incidente",
      'finishVideo': "FINALIZAR VÍDEO",
      'recordVideo': "GRABAR VÍDEO",
      'stopVideo': "DETENER VÍDEO",
      'video': "VÍDEO",
      'tapToSave': "Toque para guardar",
      'audioRecording': "AUDIO GRABANDO",
      'audioReady': "Audio listo",
      'closeFile': "No se pudo abrir el archivo: ",
      'time': "Hora: ",
      'gpsUnavailable': "GPS: no disponible",
    }[key] ?? key;
}
