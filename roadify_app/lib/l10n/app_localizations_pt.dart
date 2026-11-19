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
  String get navHome => 'Início';

  @override
  String get navCollection => 'Coleta';

  @override
  String get navSensors => 'Sensores';

  @override
  String get navData => 'Dados';

  @override
  String get navSettings => 'Config';

  @override
  String get selectLanguage => 'Selecionar Idioma';

  @override
  String get defaultAccelRate => 'Taxa Padrão do Acelerômetro';

  @override
  String get recommended => 'Recomendado';

  @override
  String get collectionOrientation => 'Orientação e nivelamento';

  @override
  String get backToSettings => 'Voltar à configuração';

  @override
  String get startCollection => 'Iniciar coleta';

  @override
  String get removeCalibration => 'Remover calibração';

  @override
  String get recalibrateLevel => 'Recalibrar nível';

  @override
  String get calibrateLevel => 'Calibrar nível';

  @override
  String get newItem => 'Novo';

  @override
  String get cancel => 'Cancelar';

  @override
  String get delete => 'Excluir';

  @override
  String get close => 'Fechar';

  @override
  String get retry => 'Tentar novamente';

  @override
  String get sort => 'Ordenar';

  @override
  String get exportZip => 'Exportar ZIP';

  @override
  String get deleteVehicle => 'Excluir veículo';

  @override
  String removeVehicleConfirm(Object name) {
    return 'Deseja remover \"$name\" da lista de veículos?';
  }

  @override
  String vehicleRemoved(Object name) {
    return 'Veículo \"$name\" removido.';
  }

  @override
  String defaultVehicleSet(Object name, Object plate) {
    return 'Veículo padrão definido: $name ($plate)';
  }

  @override
  String get editVehicle => 'Editar Veículo';

  @override
  String get registerVehicle => 'Cadastrar Veículo';

  @override
  String get vehicleIdentity => 'Identificação (Ex: Caminhonete 01)';

  @override
  String get makeModel => 'Marca / Modelo (Ex: Toyota Hilux)';

  @override
  String get year => 'Ano';

  @override
  String get plate => 'Placa';

  @override
  String get tractionOptional => 'Tração (Opcional)';

  @override
  String get standardMileage => 'Kilometragem Padrão (km)';

  @override
  String get notesOptional => 'Observações / Descrição (Opcional)';

  @override
  String get loadingRecordings => 'Não foi possível carregar as gravações.';

  @override
  String get searchRuns => 'Buscar por nome, data ou rodovia';

  @override
  String get savedRunsDescription =>
      'Coletas salvas localmente no dispositivo e prontas para exportação em ZIP.';

  @override
  String get odometerStart => 'Odômetro Inicial';

  @override
  String get odometerEnd => 'Odômetro Final';

  @override
  String get distance => 'Distância';

  @override
  String get initialPoint => 'Ponto Inicial (Lat, Lng):';

  @override
  String get finalPoint => 'Ponto Final (Lat, Lng):';

  @override
  String get inertialSamples => 'Amostras Inerciais';

  @override
  String get gpsPoints => 'Pontos GPS';

  @override
  String get mediaVolume => 'Mídias / Volume';

  @override
  String get permissionRequired => 'Permissões necessárias';

  @override
  String get openSettings => 'Abrir configurações';

  @override
  String get back => 'Voltar';

  @override
  String get preparingRecording => 'Preparando gravação...';

  @override
  String get continueRecording => 'Prosseguir para gravação';

  @override
  String get finishCollectionQuestion => 'Finalizar Coleta?';

  @override
  String get continueCollecting => 'Continuar Coletando';

  @override
  String get finishAndSave => 'Finalizar e Salvar';

  @override
  String get collectionInProgress => 'Coleta em Andamento';

  @override
  String get sensorScreenTitle => 'Sensores & Nivelamento';

  @override
  String get bubbleLevel => 'Nível Bolha';

  @override
  String get requiredSensors => 'Sensores Obrigatórios';

  @override
  String get optionalSensors => 'Sensores complementares';

  @override
  String get accelerometer => 'Acelerômetro';

  @override
  String get gyroscope => 'Giroscópio';

  @override
  String get camera => 'Câmera';

  @override
  String get audio => 'Áudio';

  @override
  String get gps => 'GPS';

  @override
  String get noVehicles => 'Nenhum veículo cadastrado.';

  @override
  String get saveVehicleSuccess => 'Veículo salvo com sucesso!';

  @override
  String get saveVehicleError =>
      'Não foi possível salvar o veículo. Tente novamente.';

  @override
  String get recordingsTitle => 'Gravações';

  @override
  String get themeToggle => 'Alternar Tema Claro / Escuro';

  @override
  String get dataCollector => 'Coletor de Dados de Pavimento';

  @override
  String get vehicleExample => 'VEÍCULO: TOYOTA HILUX (ABC-1234)';

  @override
  String get calibrateBeforeDriving =>
      'Calibre os sensores com o nível bolha antes de rodar.';

  @override
  String get startTrackCollection => 'Iniciar Coleta em Pista';

  @override
  String get deviceStorage => 'Armazenamento do Aparelho';

  @override
  String get availableStorage => '42 GB disponíveis';

  @override
  String get latestCollections => 'Últimas Coletas';

  @override
  String lowBattery(Object batteryLevel) {
    return 'Bateria abaixo do limite seguro ($batteryLevel%)';
  }

  @override
  String batteryRecommendation(Object threshold) {
    return 'Nível mínimo recomendado: $threshold%. Conecte o carregador veicular antes de iniciar o ensaio.';
  }

  @override
  String loadSettingsError(Object error) {
    return 'Não foi possível carregar as últimas configurações: $error';
  }

  @override
  String savePreferencesError(Object error) {
    return 'Não foi possível salvar as preferências: $error';
  }

  @override
  String get requiredSensorsStart =>
      'Acelerômetro e GPS são obrigatórios para iniciar a coleta.';

  @override
  String get reviewFrequencies =>
      'Revise as frequências e a distância informadas.';

  @override
  String get validStartingMileage =>
      'Informe uma quilometragem inicial válida.';

  @override
  String get validAccelerometerFrequency =>
      'Informe uma frequência válida para o acelerômetro.';

  @override
  String sensorsPrepared(Object count) {
    return 'Coleta preparada com $count sensores.';
  }

  @override
  String recordingStartError(Object error) {
    return 'Não foi possível iniciar a gravação: $error';
  }

  @override
  String get parameters => 'Parâmetros';

  @override
  String get gpsDistanceDescription =>
      'Defina a distância mínima entre os pontos GPS armazenados. ';

  @override
  String get otherSensorsDescription =>
      'As taxas dos outros sensores são configuradas acima.';

  @override
  String get minGpsDistance => 'Distância mínima entre pontos GPS';

  @override
  String get gpsDistanceHelp =>
      'O GPS continua lendo na frequência escolhida; um ponto só é salvo após deslocar pelo menos esta distância.';

  @override
  String get selectVehicle => 'Selecione o veículo';

  @override
  String get loadVehiclesError => 'Não foi possível carregar os veículos: ';

  @override
  String get identity => 'Identificação';

  @override
  String get enterCollectionSegment => 'Informe o trecho da coleta.';

  @override
  String get testIdentifier => 'Identificador do ensaio *';

  @override
  String get enterTestIdentifier => 'Informe o identificador do ensaio.';

  @override
  String get selectVehicleForCollection =>
      'Selecione um veículo para a coleta.';

  @override
  String get selectVehicleRequired => 'Selecionar veículo *';

  @override
  String get validMileageRange =>
      'Informe uma quilometragem entre 0 e 2.000.000 km.';

  @override
  String get customFrequencyError => 'Informe uma frequência inteira.';

  @override
  String get frequencyRange => 'Use um valor entre 50 e 500 Hz.';

  @override
  String get durationIntegerError => 'Informe uma duração inteira.';

  @override
  String get videoDurationRange =>
      'Entre 1 e 120 segundos (2 minutos) para limitar o armazenamento.';

  @override
  String get audioDurationRange =>
      'Entre 1 e 300 segundos para limitar o armazenamento.';

  @override
  String get content => 'Conteúdo';

  @override
  String get videos => 'Vídeos';

  @override
  String get photosAndVideos => 'Fotos e vídeos';

  @override
  String get cameraUsed => 'Câmera utilizada';

  @override
  String get front => 'Frontal';

  @override
  String get rear => 'Traseira';

  @override
  String get videoMaxDuration => 'Duração máxima do vídeo';

  @override
  String get automaticCapture => 'Captura automática';

  @override
  String get optionalByTimeDistance =>
      'Opcional • por tempo ou distância percorrida';

  @override
  String get automaticRecording => 'Gravação automática';

  @override
  String get recordingDuration => 'Duração de cada gravação';

  @override
  String get minutes => 'Minutos';

  @override
  String get hours => 'Horas';

  @override
  String get meters => 'Metros';

  @override
  String get kilometers => 'Quilômetros';

  @override
  String get requiredSensorsSubtitle =>
      'Necessários para registrar movimento e localização.';

  @override
  String get roadIrregularity => 'Irregularidade e vibração da via';

  @override
  String get sensorSafetyLimit => 'Limite de segurança do sensor';

  @override
  String get gpsRoads => 'Geolocalização e rotas da pista';

  @override
  String get gnssRange => 'GNSS: 1 Hz até 10 Hz.';

  @override
  String get customFrequency => 'Digitar frequência customizada';

  @override
  String get change => 'Alterar';

  @override
  String get traction => 'Tração';

  @override
  String get description => 'Descrição';

  @override
  String get liveSignals => 'Sinais ao Vivo';

  @override
  String get levelingInstruction =>
      'Posicione o smartphone no suporte veicular ou na bancada e calibre a referência.';

  @override
  String view(Object mode) {
    return 'Visualização: $mode';
  }

  @override
  String get sideTilt => 'Inclinação Lateral';

  @override
  String get frontTilt => 'Inclinação Frontal';

  @override
  String get misaligned => 'Desalinhado da Referência';

  @override
  String get live => 'AO VIVO';

  @override
  String get finishCollection => 'Finalizar Coleta?';

  @override
  String get continueCollecting2 => 'Continuar Coletando';

  @override
  String get finishSave2 => 'Finalizar e Salvar';

  @override
  String get collectionProgress => 'Coleta em Andamento';

  @override
  String get quickRoadPhoto => 'Foto rápida da via';

  @override
  String get distanceUpper => 'DISTÂNCIA';

  @override
  String get sensorParams => 'Sensores e parâmetros';

  @override
  String get deviceMonitoring => 'Monitoramento do dispositivo';

  @override
  String get appRam => 'RAM DO APP';

  @override
  String get audioStop => 'Parar áudio';

  @override
  String get audioStart => 'Iniciar gravação de áudio';

  @override
  String get cameraPreparing => 'Preparando câmera...';

  @override
  String get takeRoadPhoto => 'TIRAR FOTO DA VIA';

  @override
  String get incidentImage => 'Registrar imagem da ocorrência';

  @override
  String get finishVideo => 'FINALIZAR VÍDEO';

  @override
  String get recordVideo => 'GRAVAR VÍDEO';

  @override
  String get stopVideo => 'PARAR VÍDEO';

  @override
  String get video => 'VÍDEO';

  @override
  String get tapToSave => 'Toque para salvar';

  @override
  String get audioRecording => 'ÁUDIO GRAVANDO';

  @override
  String get audioReady => 'Áudio pronto';

  @override
  String get closeFile => 'Não foi possível abrir o arquivo: ';

  @override
  String get time => 'Horário: ';

  @override
  String get gpsUnavailable => 'GPS: indisponível';
}
