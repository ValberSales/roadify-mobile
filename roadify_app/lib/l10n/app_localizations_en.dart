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
  String get navHome => 'Home';

  @override
  String get navCollection => 'Collection';

  @override
  String get navSensors => 'Sensors';

  @override
  String get navData => 'Data';

  @override
  String get navSettings => 'Settings';

  @override
  String get selectLanguage => 'Select Language';

  @override
  String get defaultAccelRate => 'Default Accelerometer Rate';

  @override
  String get recommended => 'Recommended';

  @override
  String get collectionOrientation => 'Orientation and leveling';

  @override
  String get backToSettings => 'Back to settings';

  @override
  String get startCollection => 'Start collection';

  @override
  String get removeCalibration => 'Remove calibration';

  @override
  String get recalibrateLevel => 'Recalibrate level';

  @override
  String get calibrateLevel => 'Calibrate level';

  @override
  String get newItem => 'New';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get close => 'Close';

  @override
  String get retry => 'Try again';

  @override
  String get sort => 'Sort';

  @override
  String get exportZip => 'Export ZIP';

  @override
  String get deleteVehicle => 'Delete vehicle';

  @override
  String removeVehicleConfirm(Object name) {
    return 'Remove \"$name\" from the vehicle list?';
  }

  @override
  String vehicleRemoved(Object name) {
    return 'Vehicle \"$name\" removed.';
  }

  @override
  String defaultVehicleSet(Object name, Object plate) {
    return 'Default vehicle set: $name ($plate)';
  }

  @override
  String get editVehicle => 'Edit Vehicle';

  @override
  String get registerVehicle => 'Register Vehicle';

  @override
  String get vehicleIdentity => 'Identification (e.g. Pickup 01)';

  @override
  String get makeModel => 'Make / Model (e.g. Toyota Hilux)';

  @override
  String get year => 'Year';

  @override
  String get plate => 'License plate';

  @override
  String get tractionOptional => 'Drivetrain (Optional)';

  @override
  String get standardMileage => 'Default Mileage (km)';

  @override
  String get notesOptional => 'Notes / Description (Optional)';

  @override
  String get loadingRecordings => 'Could not load recordings.';

  @override
  String get searchRuns => 'Search by name, date or road';

  @override
  String get savedRunsDescription =>
      'Collections saved locally on the device and ready for ZIP export.';

  @override
  String get odometerStart => 'Starting Odometer';

  @override
  String get odometerEnd => 'Ending Odometer';

  @override
  String get distance => 'Distance';

  @override
  String get initialPoint => 'Starting Point (Lat, Lng):';

  @override
  String get finalPoint => 'Ending Point (Lat, Lng):';

  @override
  String get inertialSamples => 'Inertial Samples';

  @override
  String get gpsPoints => 'GPS Points';

  @override
  String get mediaVolume => 'Media / Volume';

  @override
  String get permissionRequired => 'Permissions required';

  @override
  String get openSettings => 'Open settings';

  @override
  String get back => 'Back';

  @override
  String get preparingRecording => 'Preparing recording...';

  @override
  String get continueRecording => 'Continue to recording';

  @override
  String get finishCollectionQuestion => 'Finish collection?';

  @override
  String get continueCollecting => 'Continue collecting';

  @override
  String get finishAndSave => 'Finish and save';

  @override
  String get collectionInProgress => 'Collection in progress';

  @override
  String get sensorScreenTitle => 'Sensors & Leveling';

  @override
  String get bubbleLevel => 'Bubble Level';

  @override
  String get requiredSensors => 'Required Sensors';

  @override
  String get optionalSensors => 'Additional sensors';

  @override
  String get accelerometer => 'Accelerometer';

  @override
  String get gyroscope => 'Gyroscope';

  @override
  String get camera => 'Camera';

  @override
  String get audio => 'Audio';

  @override
  String get gps => 'GPS';

  @override
  String get noVehicles => 'No vehicles registered.';

  @override
  String get saveVehicleSuccess => 'Vehicle saved successfully!';

  @override
  String get saveVehicleError => 'Could not save the vehicle. Try again.';

  @override
  String get recordingsTitle => 'Recordings';

  @override
  String get themeToggle => 'Toggle Light / Dark Theme';

  @override
  String get dataCollector => 'Pavement Data Collector';

  @override
  String get vehicleExample => 'VEHICLE: TOYOTA HILUX (ABC-1234)';

  @override
  String get calibrateBeforeDriving =>
      'Calibrate the sensors with the bubble level before driving.';

  @override
  String get startTrackCollection => 'Start Track Collection';

  @override
  String get deviceStorage => 'Device Storage';

  @override
  String get availableStorage => '42 GB available';

  @override
  String get latestCollections => 'Latest Collections';

  @override
  String lowBattery(Object batteryLevel) {
    return 'Battery below the safe limit ($batteryLevel%)';
  }

  @override
  String batteryRecommendation(Object threshold) {
    return 'Recommended minimum level: $threshold%. Connect the vehicle charger before starting the test.';
  }

  @override
  String loadSettingsError(Object error) {
    return 'Could not load the latest settings: $error';
  }

  @override
  String savePreferencesError(Object error) {
    return 'Could not save preferences: $error';
  }

  @override
  String get requiredSensorsStart =>
      'Accelerometer and GPS are required to start collection.';

  @override
  String get reviewFrequencies =>
      'Review the entered frequencies and distance.';

  @override
  String get validStartingMileage => 'Enter a valid starting mileage.';

  @override
  String get validAccelerometerFrequency =>
      'Enter a valid accelerometer frequency.';

  @override
  String sensorsPrepared(Object count) {
    return 'Collection prepared with $count sensors.';
  }

  @override
  String recordingStartError(Object error) {
    return 'Could not start recording: $error';
  }

  @override
  String get parameters => 'Parameters';

  @override
  String get gpsDistanceDescription =>
      'Set the minimum distance between stored GPS points. ';

  @override
  String get otherSensorsDescription =>
      'Other sensor rates are configured above.';

  @override
  String get minGpsDistance => 'Minimum distance between GPS points';

  @override
  String get gpsDistanceHelp =>
      'GPS continues reading at the selected rate; a point is saved only after moving at least this distance.';

  @override
  String get selectVehicle => 'Select the vehicle';

  @override
  String get loadVehiclesError => 'Could not load vehicles: ';

  @override
  String get identity => 'Identification';

  @override
  String get enterCollectionSegment => 'Enter the collection segment.';

  @override
  String get testIdentifier => 'Test identifier *';

  @override
  String get enterTestIdentifier => 'Enter the test identifier.';

  @override
  String get selectVehicleForCollection => 'Select a vehicle for collection.';

  @override
  String get selectVehicleRequired => 'Select vehicle *';

  @override
  String get validMileageRange => 'Enter mileage between 0 and 2,000,000 km.';

  @override
  String get customFrequencyError => 'Enter a whole-number frequency.';

  @override
  String get frequencyRange => 'Use a value between 50 and 500 Hz.';

  @override
  String get durationIntegerError => 'Enter a whole-number duration.';

  @override
  String get videoDurationRange =>
      'Between 1 and 120 seconds (2 minutes) to limit storage.';

  @override
  String get audioDurationRange =>
      'Between 1 and 300 seconds to limit storage.';

  @override
  String get content => 'Content';

  @override
  String get videos => 'Videos';

  @override
  String get photosAndVideos => 'Photos and videos';

  @override
  String get cameraUsed => 'Camera used';

  @override
  String get front => 'Front';

  @override
  String get rear => 'Rear';

  @override
  String get videoMaxDuration => 'Maximum video duration';

  @override
  String get automaticCapture => 'Automatic capture';

  @override
  String get optionalByTimeDistance =>
      'Optional • by time or distance traveled';

  @override
  String get automaticRecording => 'Automatic recording';

  @override
  String get recordingDuration => 'Duration of each recording';

  @override
  String get minutes => 'Minutes';

  @override
  String get hours => 'Hours';

  @override
  String get meters => 'Meters';

  @override
  String get kilometers => 'Kilometers';

  @override
  String get requiredSensorsSubtitle =>
      'Required to record movement and location.';

  @override
  String get roadIrregularity => 'Road irregularity and vibration';

  @override
  String get sensorSafetyLimit => 'Sensor safety limit';

  @override
  String get gpsRoads => 'Geolocation and track routes';

  @override
  String get gnssRange => 'GNSS: 1 Hz to 10 Hz.';

  @override
  String get customFrequency => 'Enter custom frequency';

  @override
  String get change => 'Change';

  @override
  String get traction => 'Drivetrain';

  @override
  String get description => 'Description';

  @override
  String get liveSignals => 'Live Signals';

  @override
  String get levelingInstruction =>
      'Place the smartphone on the vehicle mount or bench and calibrate the reference.';

  @override
  String view(Object mode) {
    return 'View: $mode';
  }

  @override
  String get sideTilt => 'Side Tilt';

  @override
  String get frontTilt => 'Front Tilt';

  @override
  String get misaligned => 'Misaligned with Reference';

  @override
  String get live => 'LIVE';

  @override
  String get finishCollection => 'Finish Collection?';

  @override
  String get continueCollecting2 => 'Continue Collecting';

  @override
  String get finishSave2 => 'Finish and Save';

  @override
  String get collectionProgress => 'Collection in Progress';

  @override
  String get quickRoadPhoto => 'Quick road photo';

  @override
  String get distanceUpper => 'DISTANCE';

  @override
  String get sensorParams => 'Sensors and parameters';

  @override
  String get deviceMonitoring => 'Device monitoring';

  @override
  String get appRam => 'APP RAM';

  @override
  String get audioStop => 'Stop audio';

  @override
  String get audioStart => 'Start audio recording';

  @override
  String get cameraPreparing => 'Preparing camera...';

  @override
  String get takeRoadPhoto => 'TAKE ROAD PHOTO';

  @override
  String get incidentImage => 'Record incident image';

  @override
  String get finishVideo => 'FINISH VIDEO';

  @override
  String get recordVideo => 'RECORD VIDEO';

  @override
  String get stopVideo => 'STOP VIDEO';

  @override
  String get video => 'VIDEO';

  @override
  String get tapToSave => 'Tap to save';

  @override
  String get audioRecording => 'AUDIO RECORDING';

  @override
  String get audioReady => 'Audio ready';

  @override
  String get closeFile => 'Could not open file: ';

  @override
  String get time => 'Time: ';

  @override
  String get gpsUnavailable => 'GPS: unavailable';
}
