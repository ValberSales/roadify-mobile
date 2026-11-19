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
  String get navHome => 'Inicio';

  @override
  String get navCollection => 'Recopilación';

  @override
  String get navSensors => 'Sensores';

  @override
  String get navData => 'Datos';

  @override
  String get navSettings => 'Configuración';

  @override
  String get selectLanguage => 'Seleccionar idioma';

  @override
  String get defaultAccelRate => 'Frecuencia predeterminada del acelerómetro';

  @override
  String get recommended => 'Recomendado';

  @override
  String get collectionOrientation => 'Orientación y nivelación';

  @override
  String get backToSettings => 'Volver a la configuración';

  @override
  String get startCollection => 'Iniciar recopilación';

  @override
  String get removeCalibration => 'Quitar calibración';

  @override
  String get recalibrateLevel => 'Recalibrar nivel';

  @override
  String get calibrateLevel => 'Calibrar nivel';

  @override
  String get newItem => 'Nuevo';

  @override
  String get cancel => 'Cancelar';

  @override
  String get delete => 'Eliminar';

  @override
  String get close => 'Cerrar';

  @override
  String get retry => 'Reintentar';

  @override
  String get sort => 'Ordenar';

  @override
  String get exportZip => 'Exportar ZIP';

  @override
  String get deleteVehicle => 'Eliminar vehículo';

  @override
  String removeVehicleConfirm(Object name) {
    return '¿Desea eliminar \"$name\" de la lista de vehículos?';
  }

  @override
  String vehicleRemoved(Object name) {
    return 'Vehículo \"$name\" eliminado.';
  }

  @override
  String defaultVehicleSet(Object name, Object plate) {
    return 'Vehículo predeterminado: $name ($plate)';
  }

  @override
  String get editVehicle => 'Editar vehículo';

  @override
  String get registerVehicle => 'Registrar vehículo';

  @override
  String get vehicleIdentity => 'Identificación (p. ej., Pickup 01)';

  @override
  String get makeModel => 'Marca / modelo (p. ej., Toyota Hilux)';

  @override
  String get year => 'Año';

  @override
  String get plate => 'Matrícula';

  @override
  String get tractionOptional => 'Tracción (opcional)';

  @override
  String get standardMileage => 'Kilometraje predeterminado (km)';

  @override
  String get notesOptional => 'Notas / descripción (opcional)';

  @override
  String get loadingRecordings => 'No se pudieron cargar las grabaciones.';

  @override
  String get searchRuns => 'Buscar por nombre, fecha o carretera';

  @override
  String get savedRunsDescription =>
      'Recopilaciones guardadas localmente y listas para exportar en ZIP.';

  @override
  String get odometerStart => 'Odómetro inicial';

  @override
  String get odometerEnd => 'Odómetro final';

  @override
  String get distance => 'Distancia';

  @override
  String get initialPoint => 'Punto inicial (Lat, Lng):';

  @override
  String get finalPoint => 'Punto final (Lat, Lng):';

  @override
  String get inertialSamples => 'Muestras inerciales';

  @override
  String get gpsPoints => 'Puntos GPS';

  @override
  String get mediaVolume => 'Medios / volumen';

  @override
  String get permissionRequired => 'Permisos necesarios';

  @override
  String get openSettings => 'Abrir configuración';

  @override
  String get back => 'Volver';

  @override
  String get preparingRecording => 'Preparando la grabación...';

  @override
  String get continueRecording => 'Continuar a la grabación';

  @override
  String get finishCollectionQuestion => '¿Finalizar recopilación?';

  @override
  String get continueCollecting => 'Continuar recopilando';

  @override
  String get finishAndSave => 'Finalizar y guardar';

  @override
  String get collectionInProgress => 'Recopilación en curso';

  @override
  String get sensorScreenTitle => 'Sensores y nivelación';

  @override
  String get bubbleLevel => 'Nivel de burbuja';

  @override
  String get requiredSensors => 'Sensores obligatorios';

  @override
  String get optionalSensors => 'Sensores adicionales';

  @override
  String get accelerometer => 'Acelerómetro';

  @override
  String get gyroscope => 'Giroscopio';

  @override
  String get camera => 'Cámara';

  @override
  String get audio => 'Audio';

  @override
  String get gps => 'GPS';

  @override
  String get noVehicles => 'No hay vehículos registrados.';

  @override
  String get saveVehicleSuccess => '¡Vehículo guardado correctamente!';

  @override
  String get saveVehicleError =>
      'No se pudo guardar el vehículo. Inténtelo de nuevo.';

  @override
  String get recordingsTitle => 'Grabaciones';

  @override
  String get themeToggle => 'Alternar tema claro / oscuro';

  @override
  String get dataCollector => 'Colector de datos de pavimento';

  @override
  String get vehicleExample => 'VEHÍCULO: TOYOTA HILUX (ABC-1234)';

  @override
  String get calibrateBeforeDriving =>
      'Calibre los sensores con el nivel de burbuja antes de conducir.';

  @override
  String get startTrackCollection => 'Iniciar recopilación en pista';

  @override
  String get deviceStorage => 'Almacenamiento del dispositivo';

  @override
  String get availableStorage => '42 GB disponibles';

  @override
  String get latestCollections => 'Últimas recopilaciones';

  @override
  String lowBattery(Object batteryLevel) {
    return 'Batería por debajo del límite seguro ($batteryLevel%)';
  }

  @override
  String batteryRecommendation(Object threshold) {
    return 'Nivel mínimo recomendado: $threshold%. Conecte el cargador del vehículo antes de iniciar el ensayo.';
  }

  @override
  String loadSettingsError(Object error) {
    return 'No se pudieron cargar los últimos ajustes: $error';
  }

  @override
  String savePreferencesError(Object error) {
    return 'No se pudieron guardar las preferencias: $error';
  }

  @override
  String get requiredSensorsStart =>
      'El acelerómetro y el GPS son obligatorios para iniciar la recopilación.';

  @override
  String get reviewFrequencies =>
      'Revise las frecuencias y la distancia indicadas.';

  @override
  String get validStartingMileage =>
      'Introduzca un kilometraje inicial válido.';

  @override
  String get validAccelerometerFrequency =>
      'Introduzca una frecuencia válida para el acelerómetro.';

  @override
  String sensorsPrepared(Object count) {
    return 'Recopilación preparada con $count sensores.';
  }

  @override
  String recordingStartError(Object error) {
    return 'No se pudo iniciar la grabación: $error';
  }

  @override
  String get parameters => 'Parámetros';

  @override
  String get gpsDistanceDescription =>
      'Defina la distancia mínima entre los puntos GPS almacenados. ';

  @override
  String get otherSensorsDescription =>
      'Las frecuencias de los otros sensores se configuran arriba.';

  @override
  String get minGpsDistance => 'Distancia mínima entre puntos GPS';

  @override
  String get gpsDistanceHelp =>
      'El GPS sigue leyendo a la frecuencia elegida; un punto solo se guarda después de recorrer al menos esta distancia.';

  @override
  String get selectVehicle => 'Seleccione el vehículo';

  @override
  String get loadVehiclesError => 'No se pudieron cargar los vehículos: ';

  @override
  String get identity => 'Identificación';

  @override
  String get enterCollectionSegment =>
      'Introduzca el tramo de la recopilación.';

  @override
  String get testIdentifier => 'Identificador del ensayo *';

  @override
  String get enterTestIdentifier => 'Introduzca el identificador del ensayo.';

  @override
  String get selectVehicleForCollection =>
      'Seleccione un vehículo para la recopilación.';

  @override
  String get selectVehicleRequired => 'Seleccionar vehículo *';

  @override
  String get validMileageRange =>
      'Introduzca un kilometraje entre 0 y 2.000.000 km.';

  @override
  String get customFrequencyError => 'Introduzca una frecuencia entera.';

  @override
  String get frequencyRange => 'Use un valor entre 50 y 500 Hz.';

  @override
  String get durationIntegerError => 'Introduzca una duración entera.';

  @override
  String get videoDurationRange =>
      'Entre 1 y 120 segundos (2 minutos) para limitar el almacenamiento.';

  @override
  String get audioDurationRange =>
      'Entre 1 y 300 segundos para limitar el almacenamiento.';

  @override
  String get content => 'Contenido';

  @override
  String get videos => 'Vídeos';

  @override
  String get photosAndVideos => 'Fotos y vídeos';

  @override
  String get cameraUsed => 'Cámara utilizada';

  @override
  String get front => 'Frontal';

  @override
  String get rear => 'Trasera';

  @override
  String get videoMaxDuration => 'Duración máxima del vídeo';

  @override
  String get automaticCapture => 'Captura automática';

  @override
  String get optionalByTimeDistance =>
      'Opcional • por tiempo o distancia recorrida';

  @override
  String get automaticRecording => 'Grabación automática';

  @override
  String get recordingDuration => 'Duración de cada grabación';

  @override
  String get minutes => 'Minutos';

  @override
  String get hours => 'Horas';

  @override
  String get meters => 'Metros';

  @override
  String get kilometers => 'Kilómetros';

  @override
  String get requiredSensorsSubtitle =>
      'Necesarios para registrar movimiento y ubicación.';

  @override
  String get roadIrregularity => 'Irregularidad y vibración de la vía';

  @override
  String get sensorSafetyLimit => 'Límite de seguridad del sensor';

  @override
  String get gpsRoads => 'Geolocalización y rutas de la pista';

  @override
  String get gnssRange => 'GNSS: de 1 Hz a 10 Hz.';

  @override
  String get customFrequency => 'Introducir frecuencia personalizada';

  @override
  String get change => 'Cambiar';

  @override
  String get traction => 'Tracción';

  @override
  String get description => 'Descripción';

  @override
  String get liveSignals => 'Señales en vivo';

  @override
  String get levelingInstruction =>
      'Coloque el smartphone en el soporte del vehículo o en la bancada y calibre la referencia.';

  @override
  String view(Object mode) {
    return 'Visualización: $mode';
  }

  @override
  String get sideTilt => 'Inclinación lateral';

  @override
  String get frontTilt => 'Inclinación frontal';

  @override
  String get misaligned => 'Desalineado de la referencia';

  @override
  String get live => 'EN VIVO';

  @override
  String get finishCollection => '¿Finalizar recopilación?';

  @override
  String get continueCollecting2 => 'Continuar recopilando';

  @override
  String get finishSave2 => 'Finalizar y guardar';

  @override
  String get collectionProgress => 'Recopilación en curso';

  @override
  String get quickRoadPhoto => 'Foto rápida de la vía';

  @override
  String get distanceUpper => 'DISTANCIA';

  @override
  String get sensorParams => 'Sensores y parámetros';

  @override
  String get deviceMonitoring => 'Monitorización del dispositivo';

  @override
  String get appRam => 'RAM DE LA APP';

  @override
  String get audioStop => 'Detener audio';

  @override
  String get audioStart => 'Iniciar grabación de audio';

  @override
  String get cameraPreparing => 'Preparando cámara...';

  @override
  String get takeRoadPhoto => 'TOMAR FOTO DE LA VÍA';

  @override
  String get incidentImage => 'Registrar imagen del incidente';

  @override
  String get finishVideo => 'FINALIZAR VÍDEO';

  @override
  String get recordVideo => 'GRABAR VÍDEO';

  @override
  String get stopVideo => 'DETENER VÍDEO';

  @override
  String get video => 'VÍDEO';

  @override
  String get tapToSave => 'Toque para guardar';

  @override
  String get audioRecording => 'AUDIO GRABANDO';

  @override
  String get audioReady => 'Audio listo';

  @override
  String get closeFile => 'No se pudo abrir el archivo: ';

  @override
  String get time => 'Hora: ';

  @override
  String get gpsUnavailable => 'GPS: no disponible';
}
