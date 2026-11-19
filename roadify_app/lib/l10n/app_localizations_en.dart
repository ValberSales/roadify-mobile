// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Roadify';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get appearanceAndThemeTitle => 'Appearance & Theme';

  @override
  String get appearanceDescription =>
      'Select your preferred display mode. Light Mode is recommended for windshield visibility.';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get themeSystem => 'System';

  @override
  String get vehicleDefaultsTitle => 'Vehicle Defaults';

  @override
  String get defaultVehicleLabel => 'Default Vehicle';

  @override
  String get manageVehiclesTitle => 'Vehicle Management';

  @override
  String get accelerometerRateLabel => 'Accelerometer Rate';

  @override
  String get systemLanguageLabel => 'System Language';
  @override
  String get recordingsTitle => 'Recordings';

  @override
  String text(String key) => const <String, String>{
      'appTitle': 'Roadify',
      'settingsTitle': 'Settings',
      'appearanceAndThemeTitle': 'Appearance & Theme',
      'appearanceDescription': 'Select your preferred display mode. Light Mode is recommended for windshield visibility.',
      'themeLight': 'Light',
      'themeDark': 'Dark',
      'themeSystem': 'System',
      'vehicleDefaultsTitle': 'Vehicle Defaults',
      'defaultVehicleLabel': 'Default Vehicle',
      'manageVehiclesTitle': 'Vehicle Management',
      'accelerometerRateLabel': 'Accelerometer Rate',
      'systemLanguageLabel': 'System Language',
      'recordingsTitle': 'Recordings',
      'navHome': 'Home',
      'navCollection': 'Collection',
      'navSensors': 'Sensors',
      'navData': 'Data',
      'navSettings': 'Settings',
      'selectLanguage': 'Select Language',
      'defaultAccelRate': 'Default Accelerometer Rate',
      'recommended': 'Recommended',
      'collectionOrientation': 'Orientation and leveling',
      'backToSettings': 'Back to settings',
      'startCollection': 'Start collection',
      'removeCalibration': 'Remove calibration',
      'recalibrateLevel': 'Recalibrate level',
      'calibrateLevel': 'Calibrate level',
      'newItem': 'New',
      'cancel': 'Cancel',
      'delete': 'Delete',
      'close': 'Close',
      'retry': 'Try again',
      'sort': 'Sort',
      'exportZip': 'Export ZIP',
      'deleteVehicle': 'Delete vehicle',
      'removeVehicleConfirm': 'Remove "{name}" from the vehicle list?',
      'vehicleRemoved': 'Vehicle "{name}" removed.',
      'defaultVehicleSet': 'Default vehicle set: {name} ({plate})',
      'editVehicle': 'Edit Vehicle',
      'registerVehicle': 'Register Vehicle',
      'vehicleIdentity': 'Identification (e.g. Pickup 01)',
      'makeModel': 'Make / Model (e.g. Toyota Hilux)',
      'year': 'Year',
      'plate': 'License plate',
      'tractionOptional': 'Drivetrain (Optional)',
      'standardMileage': 'Default Mileage (km)',
      'notesOptional': 'Notes / Description (Optional)',
      'loadingRecordings': 'Could not load recordings.',
      'searchRuns': 'Search by name, date or road',
      'savedRunsDescription': 'Collections saved locally on the device and ready for ZIP export.',
      'odometerStart': 'Starting Odometer',
      'odometerEnd': 'Ending Odometer',
      'distance': 'Distance',
      'initialPoint': 'Starting Point (Lat, Lng):',
      'finalPoint': 'Ending Point (Lat, Lng):',
      'inertialSamples': 'Inertial Samples',
      'gpsPoints': 'GPS Points',
      'mediaVolume': 'Media / Volume',
      'permissionRequired': 'Permissions required',
      'openSettings': 'Open settings',
      'back': 'Back',
      'preparingRecording': 'Preparing recording...',
      'continueRecording': 'Continue to recording',
      'finishCollectionQuestion': 'Finish collection?',
      'continueCollecting': 'Continue collecting',
      'finishAndSave': 'Finish and save',
      'collectionInProgress': 'Collection in progress',
      'sensorScreenTitle': 'Sensors & Leveling',
      'bubbleLevel': 'Bubble Level',
      'requiredSensors': 'Required Sensors',
      'optionalSensors': 'Additional sensors',
      'accelerometer': 'Accelerometer',
      'gyroscope': 'Gyroscope',
      'camera': 'Camera',
      'audio': 'Audio',
      'gps': 'GPS',
      'noVehicles': 'No vehicles registered.',
      'saveVehicleSuccess': 'Vehicle saved successfully!',
      'saveVehicleError': 'Could not save the vehicle. Try again.',
      'themeToggle': "Toggle Light / Dark Theme",
      'dataCollector': "Pavement Data Collector",
      'vehicleExample': "VEHICLE: TOYOTA HILUX (ABC-1234)",
      'vehiclePrefix': 'VEHICLE',
      'vehicleNoneRegistered': 'VEHICLE: NONE REGISTERED',
      'vehicleLoading': 'VEHICLE: LOADING...',
      'vehicleUnavailable': 'VEHICLE: UNAVAILABLE',
      'calibrateBeforeDriving': "Calibrate the sensors with the bubble level before driving.",
      'startTrackCollection': "Start Track Collection",
      'deviceStorage': "Device Storage",
      'availableStorage': "42 GB available",
      'latestCollections': "Latest Collections",
      'lowBattery': 'Battery below the safe limit ({batteryLevel}%)',
      'batteryRecommendation': 'Recommended minimum level: {threshold}%. Connect the vehicle charger before starting the test.',
      'loadSettingsError': 'Could not load the latest settings: {error}',
      'savePreferencesError': 'Could not save preferences: {error}',
      'requiredSensorsStart': "Accelerometer and GPS are required to start collection.",
      'reviewFrequencies': "Review the entered frequencies and distance.",
      'validStartingMileage': "Enter a valid starting mileage.",
      'validAccelerometerFrequency': "Enter a valid accelerometer frequency.",
      'sensorsPrepared': 'Collection prepared with {count} sensors.',
      'recordingStartError': 'Could not start recording: {error}',
      'parameters': "Parameters",
      'gpsDistanceDescription': "Set the minimum distance between stored GPS points. ",
      'otherSensorsDescription': "Other sensor rates are configured above.",
      'minGpsDistance': "Minimum distance between GPS points",
      'gpsDistanceHelp': "GPS continues reading at the selected rate; a point is saved only after moving at least this distance.",
      'selectVehicle': "Select the vehicle",
      'loadVehiclesError': "Could not load vehicles: ",
      'identity': "Identification",
      'enterCollectionSegment': "Enter the collection segment.",
      'testIdentifier': "Test identifier *",
      'enterTestIdentifier': "Enter the test identifier.",
      'selectVehicleForCollection': "Select a vehicle for collection.",
      'selectVehicleRequired': "Select vehicle *",
      'validMileageRange': "Enter mileage between 0 and 2,000,000 km.",
      'customFrequencyError': "Enter a whole-number frequency.",
      'frequencyRange': "Use a value between 50 and 500 Hz.",
      'durationIntegerError': "Enter a whole-number duration.",
      'videoDurationRange': "Between 1 and 120 seconds (2 minutes) to limit storage.",
      'audioDurationRange': "Between 1 and 300 seconds to limit storage.",
      'content': "Content",
      'videos': "Videos",
      'photosAndVideos': "Photos and videos",
      'cameraUsed': "Camera used",
      'front': "Front",
      'rear': "Rear",
      'videoMaxDuration': "Maximum video duration",
      'automaticCapture': "Automatic capture",
      'optionalByTimeDistance': "Optional • by time or distance traveled",
      'automaticRecording': "Automatic recording",
      'recordingDuration': "Duration of each recording",
      'minutes': "Minutes",
      'hours': "Hours",
      'meters': "Meters",
      'kilometers': "Kilometers",
      'requiredSensorsSubtitle': "Required to record movement and location.",
      'roadIrregularity': "Road irregularity and vibration",
      'sensorSafetyLimit': "Sensor safety limit",
      'gpsRoads': "Geolocation and track routes",
      'gnssRange': "GNSS: 1 Hz to 10 Hz.",
      'customFrequency': "Enter custom frequency",
      'change': "Change",
      'traction': "Drivetrain",
      'description': "Description",
      'liveSignals': "Live Signals",
      'levelingInstruction': "Place the smartphone on the vehicle mount or bench and calibrate the reference.",
      'view': 'View: {mode}',
      'sideTilt': "Side Tilt",
      'frontTilt': "Front Tilt",
      'misaligned': "Misaligned with Reference",
      'live': "LIVE",
      'finishCollection': "Finish Collection?",
      'continueCollecting2': "Continue Collecting",
      'finishSave2': "Finish and Save",
      'collectionProgress': "Collection in Progress",
      'quickRoadPhoto': "Quick road photo",
      'distanceUpper': "DISTANCE",
      'sensorParams': "Sensors and parameters",
      'deviceMonitoring': "Device monitoring",
      'appRam': "APP RAM",
      'audioStop': "Stop audio",
      'audioStart': "Start audio recording",
      'cameraPreparing': "Preparing camera...",
      'takeRoadPhoto': "TAKE ROAD PHOTO",
      'incidentImage': "Record incident image",
      'finishVideo': "FINISH VIDEO",
      'recordVideo': "RECORD VIDEO",
      'stopVideo': "STOP VIDEO",
      'video': "VIDEO",
      'tapToSave': "Tap to save",
      'audioRecording': "AUDIO RECORDING",
      'audioReady': "Audio ready",
      'closeFile': "Could not open file: ",
      'time': "Time: ",
      'gpsUnavailable': "GPS: unavailable",
    }[key] ?? key;
}
