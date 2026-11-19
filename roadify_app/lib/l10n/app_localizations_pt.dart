// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'Roadify';

  @override
  String get settingsTitle => 'Configurações';

  @override
  String get appearanceAndThemeTitle => 'Aparência e Tema';

  @override
  String get appearanceDescription =>
      'Selecione o modo de exibição preferido. O Modo Claro é o mais recomendado para visibilidade em para-brisas.';

  @override
  String get themeLight => 'Claro';

  @override
  String get themeDark => 'Escuro';

  @override
  String get themeSystem => 'Sistema';

  @override
  String get vehicleDefaultsTitle => 'Padrões do Veículo';

  @override
  String get defaultVehicleLabel => 'Veículo Padrão';

  @override
  String get manageVehiclesTitle => 'Gestão de Veículos';

  @override
  String get accelerometerRateLabel => 'Taxa do Acelerômetro';

  @override
  String get systemLanguageLabel => 'Idioma do Sistema';
  @override
  String get recordingsTitle => 'Gravações';

  @override
  String text(String key) => const <String, String>{
      'navHome': 'Início',
      'navCollection': 'Coleta',
      'navSensors': 'Sensores',
      'navData': 'Dados',
      'navSettings': 'Config',
      'selectLanguage': 'Selecionar Idioma',
      'defaultAccelRate': 'Taxa Padrão do Acelerômetro',
      'recommended': 'Recomendado',
      'collectionOrientation': 'Orientação e nivelamento',
      'backToSettings': 'Voltar à configuração',
      'startCollection': 'Iniciar coleta',
      'removeCalibration': 'Remover calibração',
      'recalibrateLevel': 'Recalibrar nível',
      'calibrateLevel': 'Calibrar nível',
      'newItem': 'Novo',
      'cancel': 'Cancelar',
      'delete': 'Excluir',
      'close': 'Fechar',
      'retry': 'Tentar novamente',
      'sort': 'Ordenar',
      'exportZip': 'Exportar ZIP',
      'deleteVehicle': 'Excluir veículo',
      'removeVehicleConfirm': 'Deseja remover "{name}" da lista de veículos?',
      'vehicleRemoved': 'Veículo "{name}" removido.',
      'defaultVehicleSet': 'Veículo padrão definido: {name} ({plate})',
      'editVehicle': 'Editar Veículo',
      'registerVehicle': 'Cadastrar Veículo',
      'vehicleIdentity': 'Identificação (Ex: Caminhonete 01)',
      'makeModel': 'Marca / Modelo (Ex: Toyota Hilux)',
      'year': 'Ano',
      'plate': 'Placa',
      'tractionOptional': 'Tração (Opcional)',
      'standardMileage': 'Kilometragem Padrão (km)',
      'notesOptional': 'Observações / Descrição (Opcional)',
      'loadingRecordings': 'Não foi possível carregar as gravações.',
      'searchRuns': 'Buscar por nome, data ou rodovia',
      'savedRunsDescription': 'Coletas salvas localmente no dispositivo e prontas para exportação em ZIP.',
      'odometerStart': 'Odômetro Inicial',
      'odometerEnd': 'Odômetro Final',
      'distance': 'Distância',
      'initialPoint': 'Ponto Inicial (Lat, Lng):',
      'finalPoint': 'Ponto Final (Lat, Lng):',
      'inertialSamples': 'Amostras Inerciais',
      'gpsPoints': 'Pontos GPS',
      'mediaVolume': 'Mídias / Volume',
      'permissionRequired': 'Permissões necessárias',
      'openSettings': 'Abrir configurações',
      'back': 'Voltar',
      'preparingRecording': 'Preparando gravação...',
      'continueRecording': 'Prosseguir para gravação',
      'finishCollectionQuestion': 'Finalizar Coleta?',
      'continueCollecting': 'Continuar Coletando',
      'finishAndSave': 'Finalizar e Salvar',
      'collectionInProgress': 'Coleta em Andamento',
      'sensorScreenTitle': 'Sensores & Nivelamento',
      'bubbleLevel': 'Nível Bolha',
      'requiredSensors': 'Sensores Obrigatórios',
      'optionalSensors': 'Sensores complementares',
      'accelerometer': 'Acelerômetro',
      'gyroscope': 'Giroscópio',
      'camera': 'Câmera',
      'audio': 'Áudio',
      'gps': 'GPS',
      'noVehicles': 'Nenhum veículo cadastrado.',
      'saveVehicleSuccess': 'Veículo salvo com sucesso!',
      'saveVehicleError': 'Não foi possível salvar o veículo. Tente novamente.',
      'themeToggle': "Alternar Tema Claro / Escuro",
      'dataCollector': "Coletor de Dados de Pavimento",
      'vehicleExample': "VEÍCULO: TOYOTA HILUX (ABC-1234)",
      'calibrateBeforeDriving': "Calibre os sensores com o nível bolha antes de rodar.",
      'startTrackCollection': "Iniciar Coleta em Pista",
      'deviceStorage': "Armazenamento do Aparelho",
      'availableStorage': "42 GB disponíveis",
      'latestCollections': "Últimas Coletas",
      'lowBattery': 'Bateria abaixo do limite seguro ({batteryLevel}%)',
      'batteryRecommendation': 'Nível mínimo recomendado: {threshold}%. Conecte o carregador veicular antes de iniciar o ensaio.',
      'loadSettingsError': 'Não foi possível carregar as últimas configurações: {error}',
      'savePreferencesError': 'Não foi possível salvar as preferências: {error}',
      'requiredSensorsStart': "Acelerômetro e GPS são obrigatórios para iniciar a coleta.",
      'reviewFrequencies': "Revise as frequências e a distância informadas.",
      'validStartingMileage': "Informe uma quilometragem inicial válida.",
      'validAccelerometerFrequency': "Informe uma frequência válida para o acelerômetro.",
      'sensorsPrepared': 'Coleta preparada com {count} sensores.',
      'recordingStartError': 'Não foi possível iniciar a gravação: {error}',
      'parameters': "Parâmetros",
      'gpsDistanceDescription': "Defina a distância mínima entre os pontos GPS armazenados. ",
      'otherSensorsDescription': "As taxas dos outros sensores são configuradas acima.",
      'minGpsDistance': "Distância mínima entre pontos GPS",
      'gpsDistanceHelp': "O GPS continua lendo na frequência escolhida; um ponto só é salvo após deslocar pelo menos esta distância.",
      'selectVehicle': "Selecione o veículo",
      'loadVehiclesError': "Não foi possível carregar os veículos: ",
      'identity': "Identificação",
      'enterCollectionSegment': "Informe o trecho da coleta.",
      'testIdentifier': "Identificador do ensaio *",
      'enterTestIdentifier': "Informe o identificador do ensaio.",
      'selectVehicleForCollection': "Selecione um veículo para a coleta.",
      'selectVehicleRequired': "Selecionar veículo *",
      'validMileageRange': "Informe uma quilometragem entre 0 e 2.000.000 km.",
      'customFrequencyError': "Informe uma frequência inteira.",
      'frequencyRange': "Use um valor entre 50 e 500 Hz.",
      'durationIntegerError': "Informe uma duração inteira.",
      'videoDurationRange': "Entre 1 e 120 segundos (2 minutos) para limitar o armazenamento.",
      'audioDurationRange': "Entre 1 e 300 segundos para limitar o armazenamento.",
      'content': "Conteúdo",
      'videos': "Vídeos",
      'photosAndVideos': "Fotos e vídeos",
      'cameraUsed': "Câmera utilizada",
      'front': "Frontal",
      'rear': "Traseira",
      'videoMaxDuration': "Duração máxima do vídeo",
      'automaticCapture': "Captura automática",
      'optionalByTimeDistance': "Opcional • por tempo ou distância percorrida",
      'automaticRecording': "Gravação automática",
      'recordingDuration': "Duração de cada gravação",
      'minutes': "Minutos",
      'hours': "Horas",
      'meters': "Metros",
      'kilometers': "Quilômetros",
      'requiredSensorsSubtitle': "Necessários para registrar movimento e localização.",
      'roadIrregularity': "Irregularidade e vibração da via",
      'sensorSafetyLimit': "Limite de segurança do sensor",
      'gpsRoads': "Geolocalização e rotas da pista",
      'gnssRange': "GNSS: 1 Hz até 10 Hz.",
      'customFrequency': "Digitar frequência customizada",
      'change': "Alterar",
      'traction': "Tração",
      'description': "Descrição",
      'liveSignals': "Sinais ao Vivo",
      'levelingInstruction': "Posicione o smartphone no suporte veicular ou na bancada e calibre a referência.",
      'view': 'Visualização: {mode}',
      'sideTilt': "Inclinação Lateral",
      'frontTilt': "Inclinação Frontal",
      'misaligned': "Desalinhado da Referência",
      'live': "AO VIVO",
      'finishCollection': "Finalizar Coleta?",
      'continueCollecting2': "Continuar Coletando",
      'finishSave2': "Finalizar e Salvar",
      'collectionProgress': "Coleta em Andamento",
      'quickRoadPhoto': "Foto rápida da via",
      'distanceUpper': "DISTÂNCIA",
      'sensorParams': "Sensores e parâmetros",
      'deviceMonitoring': "Monitoramento do dispositivo",
      'appRam': "RAM DO APP",
      'audioStop': "Parar áudio",
      'audioStart': "Iniciar gravação de áudio",
      'cameraPreparing': "Preparando câmera...",
      'takeRoadPhoto': "TIRAR FOTO DA VIA",
      'incidentImage': "Registrar imagem da ocorrência",
      'finishVideo': "FINALIZAR VÍDEO",
      'recordVideo': "GRAVAR VÍDEO",
      'stopVideo': "PARAR VÍDEO",
      'video': "VÍDEO",
      'tapToSave': "Toque para salvar",
      'audioRecording': "ÁUDIO GRAVANDO",
      'audioReady': "Áudio pronto",
      'closeFile': "Não foi possível abrir o arquivo: ",
      'time': "Horário: ",
      'gpsUnavailable': "GPS: indisponível",
    }[key] ?? key;
}
