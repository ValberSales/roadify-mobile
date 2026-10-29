import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../database/app_database.dart';

/// Permissões em tempo de execução gerenciadas pelo orquestrador global (SP2-01).
enum AppRuntimePermission {
  location('Localização'),
  sensors('Sensores'),
  camera('Câmera');

  final String label;
  const AppRuntimePermission(this.label);

  Permission get platformPermission => switch (this) {
    AppRuntimePermission.location => Permission.locationWhenInUse,
    AppRuntimePermission.sensors => Permission.sensors,
    AppRuntimePermission.camera => Permission.camera,
  };
}

/// Estado simplificado de concessão de uma permissão de hardware.
enum PermissionGrantStatus {
  granted,
  denied,
  permanentlyDenied,
  unknown;

  bool get isGranted => this == PermissionGrantStatus.granted;
}

/// Registro de uma interrupção de ciclo de vida (chamada telefônica ou minimização).
@immutable
class SessionInterruptionRecord {
  final DateTime interruptedAt;
  final DateTime resumedAt;
  final Duration duration;
  final bool wasDuringActiveSession;
  final bool wakelockRestored;

  const SessionInterruptionRecord({
    required this.interruptedAt,
    required this.resumedAt,
    required this.duration,
    required this.wasDuringActiveSession,
    required this.wakelockRestored,
  });
}

/// Estado imutável do Orquestrador Global de Sessão, Permissões e Wakelock (SP2-01).
@immutable
class SessionLifecycleState {
  final bool isSessionActive;
  final int? activeRunId;
  final AppLifecycleState lifecycleState;
  final bool isWakelockEnabled;
  final bool firstUsePermissionsRequested;
  final Map<AppRuntimePermission, PermissionGrantStatus> permissions;
  final int interruptionCount;
  final SessionInterruptionRecord? lastInterruption;
  final bool hasPendingInterruptionRecovery;

  const SessionLifecycleState({
    this.isSessionActive = false,
    this.activeRunId,
    this.lifecycleState = AppLifecycleState.resumed,
    this.isWakelockEnabled = false,
    this.firstUsePermissionsRequested = false,
    this.permissions = const {
      AppRuntimePermission.location: PermissionGrantStatus.unknown,
      AppRuntimePermission.sensors: PermissionGrantStatus.unknown,
      AppRuntimePermission.camera: PermissionGrantStatus.unknown,
    },
    this.interruptionCount = 0,
    this.lastInterruption,
    this.hasPendingInterruptionRecovery = false,
  });

  bool get isLocationGranted =>
      permissions[AppRuntimePermission.location]?.isGranted ?? false;

  bool get isSensorsGranted =>
      permissions[AppRuntimePermission.sensors]?.isGranted ?? false;

  bool get isCameraGranted =>
      permissions[AppRuntimePermission.camera]?.isGranted ?? false;

  bool get allPermissionsGranted =>
      isLocationGranted && isSensorsGranted && isCameraGranted;

  SessionLifecycleState copyWith({
    bool? isSessionActive,
    Object? activeRunId = _sentinel,
    AppLifecycleState? lifecycleState,
    bool? isWakelockEnabled,
    bool? firstUsePermissionsRequested,
    Map<AppRuntimePermission, PermissionGrantStatus>? permissions,
    int? interruptionCount,
    Object? lastInterruption = _sentinel,
    bool? hasPendingInterruptionRecovery,
  }) {
    return SessionLifecycleState(
      isSessionActive: isSessionActive ?? this.isSessionActive,
      activeRunId: identical(activeRunId, _sentinel)
          ? this.activeRunId
          : activeRunId as int?,
      lifecycleState: lifecycleState ?? this.lifecycleState,
      isWakelockEnabled: isWakelockEnabled ?? this.isWakelockEnabled,
      firstUsePermissionsRequested:
          firstUsePermissionsRequested ?? this.firstUsePermissionsRequested,
      permissions: permissions ?? this.permissions,
      interruptionCount: interruptionCount ?? this.interruptionCount,
      lastInterruption: identical(lastInterruption, _sentinel)
          ? this.lastInterruption
          : lastInterruption as SessionInterruptionRecord?,
      hasPendingInterruptionRecovery:
          hasPendingInterruptionRecovery ?? this.hasPendingInterruptionRecovery,
    );
  }

  static const Object _sentinel = Object();
}

/// Orquestrador Global de Lifecycle, Permissões e Wakelock (SP2-01 — Épico Home & Core).
///
/// Responsabilidades:
/// 1. Solicitação transparente de permissões críticas (Location, Sensors, Camera) no primeiro uso.
/// 2. Manutenção ininterrupta da tela ativa durante ensaios via `wakelock_plus`.
/// 3. Monitoramento de `AppLifecycleState` e recuperação automática de interrupções
///    (chamadas recebidas, bloqueio temporário ou minimização do app).
class SessionLifecycleOrchestrator extends ChangeNotifier
    with WidgetsBindingObserver {
  static const String firstUsePreferencesKey =
      'roadify_first_use_permissions_requested';

  final Future<SharedPreferences> Function() _preferencesProvider;
  final Future<PermissionStatus> Function(Permission) _permissionRequester;
  final Future<PermissionStatus> Function(Permission) _permissionChecker;
  final Future<void> Function() _enableWakelock;
  final Future<void> Function() _disableWakelock;
  final DateTime Function() _clock;
  final Stream<List<Run>>? runsStream;

  SessionLifecycleState _state = const SessionLifecycleState();
  StreamSubscription<List<Run>>? _runsSubscription;
  DateTime? _interruptedAt;
  bool _wasActiveBeforeInterruption = false;
  bool _observerAttached = false;
  bool _disposed = false;

  SessionLifecycleOrchestrator({
    Future<SharedPreferences> Function()? preferencesProvider,
    Future<PermissionStatus> Function(Permission)? permissionRequester,
    Future<PermissionStatus> Function(Permission)? permissionChecker,
    Future<void> Function()? enableWakelock,
    Future<void> Function()? disableWakelock,
    DateTime Function()? clock,
    this.runsStream,
  }) : _preferencesProvider =
           preferencesProvider ?? SharedPreferences.getInstance,
       _permissionRequester =
           permissionRequester ?? ((permission) => permission.request()),
       _permissionChecker =
           permissionChecker ?? ((permission) => permission.status),
       _enableWakelock = enableWakelock ?? WakelockPlus.enable,
       _disableWakelock = disableWakelock ?? WakelockPlus.disable,
       _clock = clock ?? DateTime.now;

  SessionLifecycleState get state => _state;

  /// Inicializa o observador de ciclo de vida, monitora sessões de coleta e
  /// solicita permissões transparentemente no primeiro uso do aplicativo.
  Future<void> initialize({bool requestPermissionsOnFirstUse = true}) async {
    if (!_observerAttached) {
      WidgetsBinding.instance.addObserver(this);
      _observerAttached = true;
    }

    if (runsStream != null && _runsSubscription == null) {
      _runsSubscription = runsStream!.listen(_onRunsChanged, onError: (_) {});
    }

    try {
      final prefs = await _preferencesProvider();
      final alreadyRequested = prefs.getBool(firstUsePreferencesKey) ?? false;

      if (!alreadyRequested && requestPermissionsOnFirstUse) {
        await requestRuntimePermissions();
        await prefs.setBool(firstUsePreferencesKey, true);
        _updateState(_state.copyWith(firstUsePermissionsRequested: true));
      } else {
        _updateState(
          _state.copyWith(firstUsePermissionsRequested: alreadyRequested),
        );
        await refreshPermissions();
      }
    } catch (_) {
      // Caso ocorra falha de plataforma em ambiente de teste/emulador, mantém estado seguro.
    }
  }

  /// Solicita as permissões em tempo de execução (Location, Sensors, Camera).
  Future<Map<AppRuntimePermission, PermissionGrantStatus>>
  requestRuntimePermissions() async {
    final updated = Map<AppRuntimePermission, PermissionGrantStatus>.from(
      _state.permissions,
    );

    for (final permission in AppRuntimePermission.values) {
      try {
        final status = await _permissionRequester(
          permission.platformPermission,
        );
        updated[permission] = _mapStatus(status);
      } catch (_) {
        updated[permission] = PermissionGrantStatus.denied;
      }
    }

    _updateState(
      _state.copyWith(
        permissions: Map.unmodifiable(updated),
        firstUsePermissionsRequested: true,
      ),
    );
    return _state.permissions;
  }

  /// Atualiza o status atual das permissões sem abrir diálogos do sistema.
  Future<void> refreshPermissions() async {
    final updated = Map<AppRuntimePermission, PermissionGrantStatus>.from(
      _state.permissions,
    );

    for (final permission in AppRuntimePermission.values) {
      try {
        final status = await _permissionChecker(permission.platformPermission);
        updated[permission] = _mapStatus(status);
      } catch (_) {
        // Mantém estado anterior se o canal não estiver disponível
      }
    }

    _updateState(_state.copyWith(permissions: Map.unmodifiable(updated)));
  }

  /// Inicia uma sessão ativa de ensaio e garante o Wakelock ininterrupto.
  Future<void> startSession({int? runId}) async {
    var wakelockOk = false;
    try {
      await _enableWakelock();
      wakelockOk = true;
    } catch (_) {
      wakelockOk = false;
    }

    _updateState(
      _state.copyWith(
        isSessionActive: true,
        activeRunId: runId ?? _state.activeRunId,
        isWakelockEnabled: wakelockOk,
      ),
    );
  }

  /// Finaliza a sessão ativa de ensaio e libera o Wakelock da tela.
  Future<void> endSession() async {
    try {
      await _disableWakelock();
    } catch (_) {}

    _updateState(
      _state.copyWith(
        isSessionActive: false,
        activeRunId: null,
        isWakelockEnabled: false,
      ),
    );
  }

  /// Confirma o recebimento do alerta de recuperação após interrupção.
  void acknowledgeInterruptionRecovery() {
    if (!_state.hasPendingInterruptionRecovery) return;
    _updateState(_state.copyWith(hasPendingInterruptionRecovery: false));
  }

  void _onRunsChanged(List<Run> runs) {
    Run? activeRun;
    for (final run in runs) {
      if (run.endedAt == null) {
        activeRun = run;
        break;
      }
    }

    if (activeRun != null &&
        (!_state.isSessionActive || _state.activeRunId != activeRun.id)) {
      unawaited(startSession(runId: activeRun.id));
    } else if (activeRun == null && _state.isSessionActive) {
      unawaited(endSession());
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.hidden ||
        state == AppLifecycleState.paused) {
      _interruptedAt ??= _clock();
      _wasActiveBeforeInterruption =
          _wasActiveBeforeInterruption || _state.isSessionActive;
      _updateState(_state.copyWith(lifecycleState: state));
      return;
    }

    if (state == AppLifecycleState.resumed) {
      unawaited(_recoverFromInterruption());
      return;
    }

    _updateState(_state.copyWith(lifecycleState: state));
  }

  Future<void> _recoverFromInterruption() async {
    final resumedAt = _clock();
    final interruptedAt = _interruptedAt;
    final wasActive = _wasActiveBeforeInterruption || _state.isSessionActive;

    _interruptedAt = null;
    _wasActiveBeforeInterruption = false;

    var wakelockRestored = _state.isWakelockEnabled;
    if (wasActive) {
      try {
        await _enableWakelock();
        wakelockRestored = true;
      } catch (_) {
        wakelockRestored = false;
      }
    }

    SessionInterruptionRecord? record = _state.lastInterruption;
    var nextCount = _state.interruptionCount;
    var pendingRecovery = _state.hasPendingInterruptionRecovery;

    if (interruptedAt != null) {
      final duration = resumedAt.difference(interruptedAt);
      record = SessionInterruptionRecord(
        interruptedAt: interruptedAt,
        resumedAt: resumedAt,
        duration: duration.isNegative ? Duration.zero : duration,
        wasDuringActiveSession: wasActive,
        wakelockRestored: wakelockRestored,
      );
      nextCount += 1;
      if (wasActive) {
        pendingRecovery = true;
      }
    }

    _updateState(
      _state.copyWith(
        lifecycleState: AppLifecycleState.resumed,
        isWakelockEnabled: wasActive
            ? wakelockRestored
            : _state.isWakelockEnabled,
        interruptionCount: nextCount,
        lastInterruption: record,
        hasPendingInterruptionRecovery: pendingRecovery,
      ),
    );

    await refreshPermissions();
  }

  PermissionGrantStatus _mapStatus(PermissionStatus status) {
    if (status.isGranted || status.isLimited) {
      return PermissionGrantStatus.granted;
    }
    if (status.isPermanentlyDenied || status.isRestricted) {
      return PermissionGrantStatus.permanentlyDenied;
    }
    return PermissionGrantStatus.denied;
  }

  void _updateState(SessionLifecycleState newState) {
    if (_disposed) return;
    _state = newState;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    if (_observerAttached) {
      WidgetsBinding.instance.removeObserver(this);
      _observerAttached = false;
    }
    _runsSubscription?.cancel();
    super.dispose();
  }
}
