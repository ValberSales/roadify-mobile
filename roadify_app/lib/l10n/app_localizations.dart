import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
    Locale('pt'),
  ];

  /// Título principal do aplicativo Roadify
  ///
  /// In pt, this message translates to:
  /// **'Roadify'**
  String get appTitle;

  /// Título da tela de configurações
  ///
  /// In pt, this message translates to:
  /// **'Configurações'**
  String get settingsTitle;

  /// Título da seção de aparência e tema
  ///
  /// In pt, this message translates to:
  /// **'Aparência e Tema'**
  String get appearanceAndThemeTitle;

  /// Descrição do modo de aparência
  ///
  /// In pt, this message translates to:
  /// **'Selecione o modo de exibição preferido. O Modo Claro é o mais recomendado para visibilidade em para-brisas.'**
  String get appearanceDescription;

  /// Opção de tema claro
  ///
  /// In pt, this message translates to:
  /// **'Claro'**
  String get themeLight;

  /// Opção de tema escuro
  ///
  /// In pt, this message translates to:
  /// **'Escuro'**
  String get themeDark;

  /// Opção de tema do sistema
  ///
  /// In pt, this message translates to:
  /// **'Sistema'**
  String get themeSystem;

  /// Título da seção de padrões do veículo
  ///
  /// In pt, this message translates to:
  /// **'Padrões do Veículo'**
  String get vehicleDefaultsTitle;

  /// Rótulo do item de veículo padrão e gestão de veículos
  ///
  /// In pt, this message translates to:
  /// **'Veículo Padrão'**
  String get defaultVehicleLabel;

  /// Título da tela de gestão de veículos
  ///
  /// In pt, this message translates to:
  /// **'Gestão de Veículos'**
  String get manageVehiclesTitle;

  /// Rótulo da taxa padrão do acelerômetro
  ///
  /// In pt, this message translates to:
  /// **'Taxa do Acelerômetro'**
  String get accelerometerRateLabel;

  /// Rótulo do seletor de idioma do sistema
  ///
  /// In pt, this message translates to:
  /// **'Idioma do Sistema'**
  String get systemLanguageLabel;

  /// Visible UI text: navHome
  ///
  /// In pt, this message translates to:
  /// **'Início'**
  String get navHome;

  /// Visible UI text: navCollection
  ///
  /// In pt, this message translates to:
  /// **'Coleta'**
  String get navCollection;

  /// Visible UI text: navSensors
  ///
  /// In pt, this message translates to:
  /// **'Sensores'**
  String get navSensors;

  /// Visible UI text: navData
  ///
  /// In pt, this message translates to:
  /// **'Dados'**
  String get navData;

  /// Visible UI text: navSettings
  ///
  /// In pt, this message translates to:
  /// **'Config'**
  String get navSettings;

  /// Visible UI text: selectLanguage
  ///
  /// In pt, this message translates to:
  /// **'Selecionar Idioma'**
  String get selectLanguage;

  /// Visible UI text: defaultAccelRate
  ///
  /// In pt, this message translates to:
  /// **'Taxa Padrão do Acelerômetro'**
  String get defaultAccelRate;

  /// Visible UI text: recommended
  ///
  /// In pt, this message translates to:
  /// **'Recomendado'**
  String get recommended;

  /// Visible UI text: collectionOrientation
  ///
  /// In pt, this message translates to:
  /// **'Orientação e nivelamento'**
  String get collectionOrientation;

  /// Visible UI text: backToSettings
  ///
  /// In pt, this message translates to:
  /// **'Voltar à configuração'**
  String get backToSettings;

  /// Visible UI text: startCollection
  ///
  /// In pt, this message translates to:
  /// **'Iniciar coleta'**
  String get startCollection;

  /// Visible UI text: removeCalibration
  ///
  /// In pt, this message translates to:
  /// **'Remover calibração'**
  String get removeCalibration;

  /// Visible UI text: recalibrateLevel
  ///
  /// In pt, this message translates to:
  /// **'Recalibrar nível'**
  String get recalibrateLevel;

  /// Visible UI text: calibrateLevel
  ///
  /// In pt, this message translates to:
  /// **'Calibrar nível'**
  String get calibrateLevel;

  /// Visible UI text: newItem
  ///
  /// In pt, this message translates to:
  /// **'Novo'**
  String get newItem;

  /// Visible UI text: cancel
  ///
  /// In pt, this message translates to:
  /// **'Cancelar'**
  String get cancel;

  /// Visible UI text: delete
  ///
  /// In pt, this message translates to:
  /// **'Excluir'**
  String get delete;

  /// Visible UI text: close
  ///
  /// In pt, this message translates to:
  /// **'Fechar'**
  String get close;

  /// Visible UI text: retry
  ///
  /// In pt, this message translates to:
  /// **'Tentar novamente'**
  String get retry;

  /// Visible UI text: sort
  ///
  /// In pt, this message translates to:
  /// **'Ordenar'**
  String get sort;

  /// Visible UI text: exportZip
  ///
  /// In pt, this message translates to:
  /// **'Exportar ZIP'**
  String get exportZip;

  /// Visible UI text: deleteVehicle
  ///
  /// In pt, this message translates to:
  /// **'Excluir veículo'**
  String get deleteVehicle;

  /// Visible UI text: removeVehicleConfirm
  ///
  /// In pt, this message translates to:
  /// **'Deseja remover \"{name}\" da lista de veículos?'**
  String removeVehicleConfirm(Object name);

  /// Visible UI text: vehicleRemoved
  ///
  /// In pt, this message translates to:
  /// **'Veículo \"{name}\" removido.'**
  String vehicleRemoved(Object name);

  /// Visible UI text: defaultVehicleSet
  ///
  /// In pt, this message translates to:
  /// **'Veículo padrão definido: {name} ({plate})'**
  String defaultVehicleSet(Object name, Object plate);

  /// Visible UI text: editVehicle
  ///
  /// In pt, this message translates to:
  /// **'Editar Veículo'**
  String get editVehicle;

  /// Visible UI text: registerVehicle
  ///
  /// In pt, this message translates to:
  /// **'Cadastrar Veículo'**
  String get registerVehicle;

  /// Visible UI text: vehicleIdentity
  ///
  /// In pt, this message translates to:
  /// **'Identificação (Ex: Caminhonete 01)'**
  String get vehicleIdentity;

  /// Visible UI text: makeModel
  ///
  /// In pt, this message translates to:
  /// **'Marca / Modelo (Ex: Toyota Hilux)'**
  String get makeModel;

  /// Visible UI text: year
  ///
  /// In pt, this message translates to:
  /// **'Ano'**
  String get year;

  /// Visible UI text: plate
  ///
  /// In pt, this message translates to:
  /// **'Placa'**
  String get plate;

  /// Visible UI text: tractionOptional
  ///
  /// In pt, this message translates to:
  /// **'Tração (Opcional)'**
  String get tractionOptional;

  /// Visible UI text: standardMileage
  ///
  /// In pt, this message translates to:
  /// **'Kilometragem Padrão (km)'**
  String get standardMileage;

  /// Visible UI text: notesOptional
  ///
  /// In pt, this message translates to:
  /// **'Observações / Descrição (Opcional)'**
  String get notesOptional;

  /// Visible UI text: loadingRecordings
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível carregar as gravações.'**
  String get loadingRecordings;

  /// Visible UI text: searchRuns
  ///
  /// In pt, this message translates to:
  /// **'Buscar por nome, data ou rodovia'**
  String get searchRuns;

  /// Visible UI text: savedRunsDescription
  ///
  /// In pt, this message translates to:
  /// **'Coletas salvas localmente no dispositivo e prontas para exportação em ZIP.'**
  String get savedRunsDescription;

  /// Visible UI text: odometerStart
  ///
  /// In pt, this message translates to:
  /// **'Odômetro Inicial'**
  String get odometerStart;

  /// Visible UI text: odometerEnd
  ///
  /// In pt, this message translates to:
  /// **'Odômetro Final'**
  String get odometerEnd;

  /// Visible UI text: distance
  ///
  /// In pt, this message translates to:
  /// **'Distância'**
  String get distance;

  /// Visible UI text: initialPoint
  ///
  /// In pt, this message translates to:
  /// **'Ponto Inicial (Lat, Lng):'**
  String get initialPoint;

  /// Visible UI text: finalPoint
  ///
  /// In pt, this message translates to:
  /// **'Ponto Final (Lat, Lng):'**
  String get finalPoint;

  /// Visible UI text: inertialSamples
  ///
  /// In pt, this message translates to:
  /// **'Amostras Inerciais'**
  String get inertialSamples;

  /// Visible UI text: gpsPoints
  ///
  /// In pt, this message translates to:
  /// **'Pontos GPS'**
  String get gpsPoints;

  /// Visible UI text: mediaVolume
  ///
  /// In pt, this message translates to:
  /// **'Mídias / Volume'**
  String get mediaVolume;

  /// Visible UI text: permissionRequired
  ///
  /// In pt, this message translates to:
  /// **'Permissões necessárias'**
  String get permissionRequired;

  /// Visible UI text: openSettings
  ///
  /// In pt, this message translates to:
  /// **'Abrir configurações'**
  String get openSettings;

  /// Visible UI text: back
  ///
  /// In pt, this message translates to:
  /// **'Voltar'**
  String get back;

  /// Visible UI text: preparingRecording
  ///
  /// In pt, this message translates to:
  /// **'Preparando gravação...'**
  String get preparingRecording;

  /// Visible UI text: continueRecording
  ///
  /// In pt, this message translates to:
  /// **'Prosseguir para gravação'**
  String get continueRecording;

  /// Visible UI text: finishCollectionQuestion
  ///
  /// In pt, this message translates to:
  /// **'Finalizar Coleta?'**
  String get finishCollectionQuestion;

  /// Visible UI text: continueCollecting
  ///
  /// In pt, this message translates to:
  /// **'Continuar Coletando'**
  String get continueCollecting;

  /// Visible UI text: finishAndSave
  ///
  /// In pt, this message translates to:
  /// **'Finalizar e Salvar'**
  String get finishAndSave;

  /// Visible UI text: collectionInProgress
  ///
  /// In pt, this message translates to:
  /// **'Coleta em Andamento'**
  String get collectionInProgress;

  /// Visible UI text: sensorScreenTitle
  ///
  /// In pt, this message translates to:
  /// **'Sensores & Nivelamento'**
  String get sensorScreenTitle;

  /// Visible UI text: bubbleLevel
  ///
  /// In pt, this message translates to:
  /// **'Nível Bolha'**
  String get bubbleLevel;

  /// Visible UI text: requiredSensors
  ///
  /// In pt, this message translates to:
  /// **'Sensores Obrigatórios'**
  String get requiredSensors;

  /// Visible UI text: optionalSensors
  ///
  /// In pt, this message translates to:
  /// **'Sensores complementares'**
  String get optionalSensors;

  /// Visible UI text: accelerometer
  ///
  /// In pt, this message translates to:
  /// **'Acelerômetro'**
  String get accelerometer;

  /// Visible UI text: gyroscope
  ///
  /// In pt, this message translates to:
  /// **'Giroscópio'**
  String get gyroscope;

  /// Visible UI text: camera
  ///
  /// In pt, this message translates to:
  /// **'Câmera'**
  String get camera;

  /// Visible UI text: audio
  ///
  /// In pt, this message translates to:
  /// **'Áudio'**
  String get audio;

  /// Visible UI text: gps
  ///
  /// In pt, this message translates to:
  /// **'GPS'**
  String get gps;

  /// Visible UI text: noVehicles
  ///
  /// In pt, this message translates to:
  /// **'Nenhum veículo cadastrado.'**
  String get noVehicles;

  /// Visible UI text: saveVehicleSuccess
  ///
  /// In pt, this message translates to:
  /// **'Veículo salvo com sucesso!'**
  String get saveVehicleSuccess;

  /// Visible UI text: saveVehicleError
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível salvar o veículo. Tente novamente.'**
  String get saveVehicleError;

  /// Visible UI text: recordings title
  ///
  /// In pt, this message translates to:
  /// **'Gravações'**
  String get recordingsTitle;

  /// Visible UI text: themeToggle
  ///
  /// In pt, this message translates to:
  /// **'Alternar Tema Claro / Escuro'**
  String get themeToggle;

  /// Visible UI text: dataCollector
  ///
  /// In pt, this message translates to:
  /// **'Coletor de Dados de Pavimento'**
  String get dataCollector;

  /// Visible UI text: vehicleExample
  ///
  /// In pt, this message translates to:
  /// **'VEÍCULO: TOYOTA HILUX (ABC-1234)'**
  String get vehicleExample;

  /// Visible UI text: calibrateBeforeDriving
  ///
  /// In pt, this message translates to:
  /// **'Calibre os sensores com o nível bolha antes de rodar.'**
  String get calibrateBeforeDriving;

  /// Visible UI text: startTrackCollection
  ///
  /// In pt, this message translates to:
  /// **'Iniciar Coleta em Pista'**
  String get startTrackCollection;

  /// Visible UI text: deviceStorage
  ///
  /// In pt, this message translates to:
  /// **'Armazenamento do Aparelho'**
  String get deviceStorage;

  /// Visible UI text: availableStorage
  ///
  /// In pt, this message translates to:
  /// **'42 GB disponíveis'**
  String get availableStorage;

  /// Visible UI text: latestCollections
  ///
  /// In pt, this message translates to:
  /// **'Últimas Coletas'**
  String get latestCollections;

  /// Visible UI text: lowBattery
  ///
  /// In pt, this message translates to:
  /// **'Bateria abaixo do limite seguro ({batteryLevel}%)'**
  String lowBattery(Object batteryLevel);

  /// Visible UI text: batteryRecommendation
  ///
  /// In pt, this message translates to:
  /// **'Nível mínimo recomendado: {threshold}%. Conecte o carregador veicular antes de iniciar o ensaio.'**
  String batteryRecommendation(Object threshold);

  /// Visible UI text: loadSettingsError
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível carregar as últimas configurações: {error}'**
  String loadSettingsError(Object error);

  /// Visible UI text: savePreferencesError
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível salvar as preferências: {error}'**
  String savePreferencesError(Object error);

  /// Visible UI text: requiredSensorsStart
  ///
  /// In pt, this message translates to:
  /// **'Acelerômetro e GPS são obrigatórios para iniciar a coleta.'**
  String get requiredSensorsStart;

  /// Visible UI text: reviewFrequencies
  ///
  /// In pt, this message translates to:
  /// **'Revise as frequências e a distância informadas.'**
  String get reviewFrequencies;

  /// Visible UI text: validStartingMileage
  ///
  /// In pt, this message translates to:
  /// **'Informe uma quilometragem inicial válida.'**
  String get validStartingMileage;

  /// Visible UI text: validAccelerometerFrequency
  ///
  /// In pt, this message translates to:
  /// **'Informe uma frequência válida para o acelerômetro.'**
  String get validAccelerometerFrequency;

  /// Visible UI text: sensorsPrepared
  ///
  /// In pt, this message translates to:
  /// **'Coleta preparada com {count} sensores.'**
  String sensorsPrepared(Object count);

  /// Visible UI text: recordingStartError
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível iniciar a gravação: {error}'**
  String recordingStartError(Object error);

  /// Visible UI text: parameters
  ///
  /// In pt, this message translates to:
  /// **'Parâmetros'**
  String get parameters;

  /// Visible UI text: gpsDistanceDescription
  ///
  /// In pt, this message translates to:
  /// **'Defina a distância mínima entre os pontos GPS armazenados. '**
  String get gpsDistanceDescription;

  /// Visible UI text: otherSensorsDescription
  ///
  /// In pt, this message translates to:
  /// **'As taxas dos outros sensores são configuradas acima.'**
  String get otherSensorsDescription;

  /// Visible UI text: minGpsDistance
  ///
  /// In pt, this message translates to:
  /// **'Distância mínima entre pontos GPS'**
  String get minGpsDistance;

  /// Visible UI text: gpsDistanceHelp
  ///
  /// In pt, this message translates to:
  /// **'O GPS continua lendo na frequência escolhida; um ponto só é salvo após deslocar pelo menos esta distância.'**
  String get gpsDistanceHelp;

  /// Visible UI text: selectVehicle
  ///
  /// In pt, this message translates to:
  /// **'Selecione o veículo'**
  String get selectVehicle;

  /// Visible UI text: loadVehiclesError
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível carregar os veículos: '**
  String get loadVehiclesError;

  /// Visible UI text: identity
  ///
  /// In pt, this message translates to:
  /// **'Identificação'**
  String get identity;

  /// Visible UI text: enterCollectionSegment
  ///
  /// In pt, this message translates to:
  /// **'Informe o trecho da coleta.'**
  String get enterCollectionSegment;

  /// Visible UI text: testIdentifier
  ///
  /// In pt, this message translates to:
  /// **'Identificador do ensaio *'**
  String get testIdentifier;

  /// Visible UI text: enterTestIdentifier
  ///
  /// In pt, this message translates to:
  /// **'Informe o identificador do ensaio.'**
  String get enterTestIdentifier;

  /// Visible UI text: selectVehicleForCollection
  ///
  /// In pt, this message translates to:
  /// **'Selecione um veículo para a coleta.'**
  String get selectVehicleForCollection;

  /// Visible UI text: selectVehicleRequired
  ///
  /// In pt, this message translates to:
  /// **'Selecionar veículo *'**
  String get selectVehicleRequired;

  /// Visible UI text: validMileageRange
  ///
  /// In pt, this message translates to:
  /// **'Informe uma quilometragem entre 0 e 2.000.000 km.'**
  String get validMileageRange;

  /// Visible UI text: customFrequencyError
  ///
  /// In pt, this message translates to:
  /// **'Informe uma frequência inteira.'**
  String get customFrequencyError;

  /// Visible UI text: frequencyRange
  ///
  /// In pt, this message translates to:
  /// **'Use um valor entre 50 e 500 Hz.'**
  String get frequencyRange;

  /// Visible UI text: durationIntegerError
  ///
  /// In pt, this message translates to:
  /// **'Informe uma duração inteira.'**
  String get durationIntegerError;

  /// Visible UI text: videoDurationRange
  ///
  /// In pt, this message translates to:
  /// **'Entre 1 e 120 segundos (2 minutos) para limitar o armazenamento.'**
  String get videoDurationRange;

  /// Visible UI text: audioDurationRange
  ///
  /// In pt, this message translates to:
  /// **'Entre 1 e 300 segundos para limitar o armazenamento.'**
  String get audioDurationRange;

  /// Visible UI text: content
  ///
  /// In pt, this message translates to:
  /// **'Conteúdo'**
  String get content;

  /// Visible UI text: videos
  ///
  /// In pt, this message translates to:
  /// **'Vídeos'**
  String get videos;

  /// Visible UI text: photosAndVideos
  ///
  /// In pt, this message translates to:
  /// **'Fotos e vídeos'**
  String get photosAndVideos;

  /// Visible UI text: cameraUsed
  ///
  /// In pt, this message translates to:
  /// **'Câmera utilizada'**
  String get cameraUsed;

  /// Visible UI text: front
  ///
  /// In pt, this message translates to:
  /// **'Frontal'**
  String get front;

  /// Visible UI text: rear
  ///
  /// In pt, this message translates to:
  /// **'Traseira'**
  String get rear;

  /// Visible UI text: videoMaxDuration
  ///
  /// In pt, this message translates to:
  /// **'Duração máxima do vídeo'**
  String get videoMaxDuration;

  /// Visible UI text: automaticCapture
  ///
  /// In pt, this message translates to:
  /// **'Captura automática'**
  String get automaticCapture;

  /// Visible UI text: optionalByTimeDistance
  ///
  /// In pt, this message translates to:
  /// **'Opcional • por tempo ou distância percorrida'**
  String get optionalByTimeDistance;

  /// Visible UI text: automaticRecording
  ///
  /// In pt, this message translates to:
  /// **'Gravação automática'**
  String get automaticRecording;

  /// Visible UI text: recordingDuration
  ///
  /// In pt, this message translates to:
  /// **'Duração de cada gravação'**
  String get recordingDuration;

  /// Visible UI text: minutes
  ///
  /// In pt, this message translates to:
  /// **'Minutos'**
  String get minutes;

  /// Visible UI text: hours
  ///
  /// In pt, this message translates to:
  /// **'Horas'**
  String get hours;

  /// Visible UI text: meters
  ///
  /// In pt, this message translates to:
  /// **'Metros'**
  String get meters;

  /// Visible UI text: kilometers
  ///
  /// In pt, this message translates to:
  /// **'Quilômetros'**
  String get kilometers;

  /// Visible UI text: requiredSensorsSubtitle
  ///
  /// In pt, this message translates to:
  /// **'Necessários para registrar movimento e localização.'**
  String get requiredSensorsSubtitle;

  /// Visible UI text: roadIrregularity
  ///
  /// In pt, this message translates to:
  /// **'Irregularidade e vibração da via'**
  String get roadIrregularity;

  /// Visible UI text: sensorSafetyLimit
  ///
  /// In pt, this message translates to:
  /// **'Limite de segurança do sensor'**
  String get sensorSafetyLimit;

  /// Visible UI text: gpsRoads
  ///
  /// In pt, this message translates to:
  /// **'Geolocalização e rotas da pista'**
  String get gpsRoads;

  /// Visible UI text: gnssRange
  ///
  /// In pt, this message translates to:
  /// **'GNSS: 1 Hz até 10 Hz.'**
  String get gnssRange;

  /// Visible UI text: customFrequency
  ///
  /// In pt, this message translates to:
  /// **'Digitar frequência customizada'**
  String get customFrequency;

  /// Visible UI text: change
  ///
  /// In pt, this message translates to:
  /// **'Alterar'**
  String get change;

  /// Visible UI text: traction
  ///
  /// In pt, this message translates to:
  /// **'Tração'**
  String get traction;

  /// Visible UI text: description
  ///
  /// In pt, this message translates to:
  /// **'Descrição'**
  String get description;

  /// Visible UI text: liveSignals
  ///
  /// In pt, this message translates to:
  /// **'Sinais ao Vivo'**
  String get liveSignals;

  /// Visible UI text: levelingInstruction
  ///
  /// In pt, this message translates to:
  /// **'Posicione o smartphone no suporte veicular ou na bancada e calibre a referência.'**
  String get levelingInstruction;

  /// Visible UI text: view
  ///
  /// In pt, this message translates to:
  /// **'Visualização: {mode}'**
  String view(Object mode);

  /// Visible UI text: sideTilt
  ///
  /// In pt, this message translates to:
  /// **'Inclinação Lateral'**
  String get sideTilt;

  /// Visible UI text: frontTilt
  ///
  /// In pt, this message translates to:
  /// **'Inclinação Frontal'**
  String get frontTilt;

  /// Visible UI text: misaligned
  ///
  /// In pt, this message translates to:
  /// **'Desalinhado da Referência'**
  String get misaligned;

  /// Visible UI text: live
  ///
  /// In pt, this message translates to:
  /// **'AO VIVO'**
  String get live;

  /// Visible UI text: finishCollection
  ///
  /// In pt, this message translates to:
  /// **'Finalizar Coleta?'**
  String get finishCollection;

  /// Visible UI text: continueCollecting2
  ///
  /// In pt, this message translates to:
  /// **'Continuar Coletando'**
  String get continueCollecting2;

  /// Visible UI text: finishSave2
  ///
  /// In pt, this message translates to:
  /// **'Finalizar e Salvar'**
  String get finishSave2;

  /// Visible UI text: collectionProgress
  ///
  /// In pt, this message translates to:
  /// **'Coleta em Andamento'**
  String get collectionProgress;

  /// Visible UI text: quickRoadPhoto
  ///
  /// In pt, this message translates to:
  /// **'Foto rápida da via'**
  String get quickRoadPhoto;

  /// Visible UI text: distanceUpper
  ///
  /// In pt, this message translates to:
  /// **'DISTÂNCIA'**
  String get distanceUpper;

  /// Visible UI text: sensorParams
  ///
  /// In pt, this message translates to:
  /// **'Sensores e parâmetros'**
  String get sensorParams;

  /// Visible UI text: deviceMonitoring
  ///
  /// In pt, this message translates to:
  /// **'Monitoramento do dispositivo'**
  String get deviceMonitoring;

  /// Visible UI text: appRam
  ///
  /// In pt, this message translates to:
  /// **'RAM DO APP'**
  String get appRam;

  /// Visible UI text: audioStop
  ///
  /// In pt, this message translates to:
  /// **'Parar áudio'**
  String get audioStop;

  /// Visible UI text: audioStart
  ///
  /// In pt, this message translates to:
  /// **'Iniciar gravação de áudio'**
  String get audioStart;

  /// Visible UI text: cameraPreparing
  ///
  /// In pt, this message translates to:
  /// **'Preparando câmera...'**
  String get cameraPreparing;

  /// Visible UI text: takeRoadPhoto
  ///
  /// In pt, this message translates to:
  /// **'TIRAR FOTO DA VIA'**
  String get takeRoadPhoto;

  /// Visible UI text: incidentImage
  ///
  /// In pt, this message translates to:
  /// **'Registrar imagem da ocorrência'**
  String get incidentImage;

  /// Visible UI text: finishVideo
  ///
  /// In pt, this message translates to:
  /// **'FINALIZAR VÍDEO'**
  String get finishVideo;

  /// Visible UI text: recordVideo
  ///
  /// In pt, this message translates to:
  /// **'GRAVAR VÍDEO'**
  String get recordVideo;

  /// Visible UI text: stopVideo
  ///
  /// In pt, this message translates to:
  /// **'PARAR VÍDEO'**
  String get stopVideo;

  /// Visible UI text: video
  ///
  /// In pt, this message translates to:
  /// **'VÍDEO'**
  String get video;

  /// Visible UI text: tapToSave
  ///
  /// In pt, this message translates to:
  /// **'Toque para salvar'**
  String get tapToSave;

  /// Visible UI text: audioRecording
  ///
  /// In pt, this message translates to:
  /// **'ÁUDIO GRAVANDO'**
  String get audioRecording;

  /// Visible UI text: audioReady
  ///
  /// In pt, this message translates to:
  /// **'Áudio pronto'**
  String get audioReady;

  /// Visible UI text: closeFile
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível abrir o arquivo: '**
  String get closeFile;

  /// Visible UI text: time
  ///
  /// In pt, this message translates to:
  /// **'Horário: '**
  String get time;

  /// Visible UI text: gpsUnavailable
  ///
  /// In pt, this message translates to:
  /// **'GPS: indisponível'**
  String get gpsUnavailable;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
