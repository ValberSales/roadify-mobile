import 'dart:async';

import 'package:battery_plus/battery_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

import '../models/device_health_state.dart';

/// ViewModel responsável pela leitura de saúde de Bateria (`battery_plus`)
/// e precisão do Sinal GPS (`geolocator`) na Tela Inicial (SP2-02).
class HomeHealthViewModel extends ChangeNotifier {
  final Future<int> Function() _batteryLevelProvider;
  final Future<BatteryState> Function() _batteryStateProvider;
  final Stream<BatteryState> Function() _batteryStateStreamFactory;
  final Future<bool> Function() _locationServiceChecker;
  final Future<LocationPermission> Function() _locationPermissionChecker;
  final Future<Position?> Function() _lastKnownPositionProvider;
  final Stream<Position> Function() _positionStreamFactory;

  DeviceHealthState _state;
  StreamSubscription<BatteryState>? _batteryStateSubscription;
  StreamSubscription<Position>? _positionSubscription;
  Timer? _batteryPollTimer;
  bool _disposed = false;

  HomeHealthViewModel({
    DeviceHealthState? initialState,
    Battery? battery,
    Future<int> Function()? batteryLevelProvider,
    Future<BatteryState> Function()? batteryStateProvider,
    Stream<BatteryState> Function()? batteryStateStreamFactory,
    Future<bool> Function()? locationServiceChecker,
    Future<LocationPermission> Function()? locationPermissionChecker,
    Future<Position?> Function()? lastKnownPositionProvider,
    Stream<Position> Function()? positionStreamFactory,
    bool autoStart = true,
  }) : _state = initialState ?? const DeviceHealthState(),
       _batteryLevelProvider =
           batteryLevelProvider ?? (() => (battery ?? Battery()).batteryLevel),
       _batteryStateProvider =
           batteryStateProvider ?? (() => (battery ?? Battery()).batteryState),
       _batteryStateStreamFactory =
           batteryStateStreamFactory ??
           (() => (battery ?? Battery()).onBatteryStateChanged),
       _locationServiceChecker =
           locationServiceChecker ?? Geolocator.isLocationServiceEnabled,
       _locationPermissionChecker =
           locationPermissionChecker ?? Geolocator.checkPermission,
       _lastKnownPositionProvider =
           lastKnownPositionProvider ?? Geolocator.getLastKnownPosition,
       _positionStreamFactory =
           positionStreamFactory ??
           (() => Geolocator.getPositionStream(
             locationSettings: const LocationSettings(
               accuracy: LocationAccuracy.high,
               distanceFilter: 2,
             ),
           )) {
    if (autoStart) {
      unawaited(startMonitoring());
    }
  }

  DeviceHealthState get state => _state;

  /// Inicia o monitoramento reativo de bateria e precisão GPS do hardware.
  Future<void> startMonitoring({bool enablePeriodicBatteryPoll = true}) async {
    stopMonitoring();
    await refresh();

    try {
      _batteryStateSubscription = _batteryStateStreamFactory().listen((
        BatteryState newState,
      ) {
        _updateState(
          _state.copyWith(batteryState: newState, isFromHardware: true),
        );
        unawaited(_refreshBatteryLevel());
      }, onError: (_) {});
    } catch (_) {}

    if (enablePeriodicBatteryPoll) {
      _batteryPollTimer = Timer.periodic(
        const Duration(seconds: 30),
        (_) => unawaited(_refreshBatteryLevel()),
      );
    }

    await _startGpsStreamIfPermitted();
  }

  /// Atualiza pontualmente a leitura de bateria e GPS.
  Future<void> refresh() async {
    await _refreshBattery();
    await _refreshGpsSnapshot();
  }

  Future<void> _refreshBattery() async {
    await _refreshBatteryLevel();
    try {
      final batteryState = await _batteryStateProvider();
      _updateState(
        _state.copyWith(batteryState: batteryState, isFromHardware: true),
      );
    } catch (_) {}
  }

  Future<void> _refreshBatteryLevel() async {
    try {
      final level = await _batteryLevelProvider();
      final clamped = level.clamp(0, 100);
      _updateState(
        _state.copyWith(batteryLevel: clamped, isFromHardware: true),
      );
    } catch (_) {}
  }

  Future<void> _refreshGpsSnapshot() async {
    try {
      final serviceEnabled = await _locationServiceChecker();
      if (!serviceEnabled) {
        _updateState(
          _state.copyWith(gpsAccuracyMeters: null, isGpsServiceEnabled: false),
        );
        return;
      }

      final permission = await _locationPermissionChecker();
      final hasPermission =
          permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse;
      if (!hasPermission) {
        _updateState(
          _state.copyWith(gpsAccuracyMeters: null, isGpsServiceEnabled: false),
        );
        return;
      }

      final lastPosition = await _lastKnownPositionProvider();
      if (lastPosition != null) {
        _updateState(
          _state.copyWith(
            gpsAccuracyMeters: lastPosition.accuracy,
            isGpsServiceEnabled: true,
            isFromHardware: true,
          ),
        );
      } else {
        _updateState(_state.copyWith(isGpsServiceEnabled: true));
      }
    } catch (_) {}
  }

  Future<void> _startGpsStreamIfPermitted() async {
    try {
      final serviceEnabled = await _locationServiceChecker();
      if (!serviceEnabled) return;

      final permission = await _locationPermissionChecker();
      final hasPermission =
          permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse;
      if (!hasPermission) return;

      _positionSubscription = _positionStreamFactory().listen(
        (Position pos) {
          _updateState(
            _state.copyWith(
              gpsAccuracyMeters: pos.accuracy,
              isGpsServiceEnabled: true,
              isFromHardware: true,
            ),
          );
        },
        onError: (_) {
          _updateState(
            _state.copyWith(
              gpsAccuracyMeters: null,
              isGpsServiceEnabled: false,
            ),
          );
        },
      );
    } catch (_) {}
  }

  /// Atualiza manualmente os dados de bateria (útil para testes e simulação).
  void updateBattery({required int level, required BatteryState state}) {
    _updateState(
      _state.copyWith(
        batteryLevel: level.clamp(0, 100),
        batteryState: state,
        isFromHardware: true,
      ),
    );
  }

  /// Atualiza manualmente a precisão do GPS em metros (útil para testes e simulação).
  void updateGpsAccuracy(
    double? accuracyMeters, {
    bool isServiceEnabled = true,
  }) {
    _updateState(
      _state.copyWith(
        gpsAccuracyMeters: accuracyMeters,
        isGpsServiceEnabled: isServiceEnabled,
        isFromHardware: true,
      ),
    );
  }

  void _updateState(DeviceHealthState next) {
    if (_disposed) return;
    _state = next;
    notifyListeners();
  }

  void stopMonitoring() {
    _batteryPollTimer?.cancel();
    _batteryPollTimer = null;
    try {
      _batteryStateSubscription?.cancel().catchError((_) {});
    } catch (_) {}
    _batteryStateSubscription = null;
    try {
      _positionSubscription?.cancel().catchError((_) {});
    } catch (_) {}
    _positionSubscription = null;
  }

  @override
  void dispose() {
    _disposed = true;
    stopMonitoring();
    super.dispose();
  }
}
