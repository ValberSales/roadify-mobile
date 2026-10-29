import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:roadify_app/core/session/session_lifecycle_orchestrator.dart';
import 'package:roadify_app/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('SP2-01: SessionLifecycleOrchestrator', () {
    test(
      'solicita permissões transparentemente no primeiro uso e persiste flag',
      () async {
        final requested = <Permission>[];
        final orchestrator = SessionLifecycleOrchestrator(
          permissionRequester: (permission) async {
            requested.add(permission);
            return PermissionStatus.granted;
          },
          permissionChecker: (_) async => PermissionStatus.granted,
          enableWakelock: () async {},
          disableWakelock: () async {},
        );
        addTearDown(orchestrator.dispose);

        await orchestrator.initialize(requestPermissionsOnFirstUse: true);

        expect(
          requested,
          containsAll(<Permission>[
            Permission.locationWhenInUse,
            Permission.sensors,
            Permission.camera,
          ]),
        );
        expect(orchestrator.state.firstUsePermissionsRequested, isTrue);
        expect(orchestrator.state.allPermissionsGranted, isTrue);

        // Em uma segunda inicialização, não deve solicitar novamente os diálogos
        requested.clear();
        await orchestrator.initialize(requestPermissionsOnFirstUse: true);
        expect(requested, isEmpty);
      },
    );

    test(
      'mantém Wakelock ativo durante a sessão de ensaio e recupera após interrupção (chamada/minimização)',
      () async {
        var wakelockEnableCount = 0;
        var wakelockDisableCount = 0;
        var currentTime = DateTime(2026, 10, 29, 14, 0, 0);

        final orchestrator = SessionLifecycleOrchestrator(
          permissionRequester: (_) async => PermissionStatus.granted,
          permissionChecker: (_) async => PermissionStatus.granted,
          enableWakelock: () async {
            wakelockEnableCount++;
          },
          disableWakelock: () async {
            wakelockDisableCount++;
          },
          clock: () => currentTime,
        );
        addTearDown(orchestrator.dispose);

        await orchestrator.initialize(requestPermissionsOnFirstUse: false);

        // Inicia ensaio -> ativa Wakelock
        await orchestrator.startSession(runId: 42);
        expect(orchestrator.state.isSessionActive, isTrue);
        expect(orchestrator.state.activeRunId, equals(42));
        expect(orchestrator.state.isWakelockEnabled, isTrue);
        expect(wakelockEnableCount, equals(1));

        // Simula chamada telefônica / minimização do app (inactive -> paused)
        orchestrator.didChangeAppLifecycleState(AppLifecycleState.inactive);
        orchestrator.didChangeAppLifecycleState(AppLifecycleState.paused);
        expect(
          orchestrator.state.lifecycleState,
          equals(AppLifecycleState.paused),
        );

        // Avança 12 segundos e retorna ao app (resumed)
        currentTime = currentTime.add(const Duration(seconds: 12));
        orchestrator.didChangeAppLifecycleState(AppLifecycleState.resumed);
        await Future<void>.delayed(Duration.zero);

        // Deve ter reativado o Wakelock e registrado a recuperação da interrupção
        expect(wakelockEnableCount, equals(2));
        expect(orchestrator.state.isWakelockEnabled, isTrue);
        expect(orchestrator.state.interruptionCount, equals(1));
        expect(orchestrator.state.hasPendingInterruptionRecovery, isTrue);
        expect(
          orchestrator.state.lastInterruption?.duration,
          equals(const Duration(seconds: 12)),
        );
        expect(
          orchestrator.state.lastInterruption?.wasDuringActiveSession,
          isTrue,
        );

        // Confirma recuperação
        orchestrator.acknowledgeInterruptionRecovery();
        expect(orchestrator.state.hasPendingInterruptionRecovery, isFalse);

        // Finaliza ensaio -> desativa Wakelock
        await orchestrator.endSession();
        expect(orchestrator.state.isSessionActive, isFalse);
        expect(orchestrator.state.isWakelockEnabled, isFalse);
        expect(wakelockDisableCount, equals(1));
      },
    );

    testWidgets(
      'RoadifyApp exibe banner de recuperação quando sessão ativa sofre interrupção',
      (tester) async {
        var now = DateTime(2026, 10, 29, 14, 10, 0);
        final orchestrator = SessionLifecycleOrchestrator(
          permissionRequester: (_) async => PermissionStatus.granted,
          permissionChecker: (_) async => PermissionStatus.granted,
          enableWakelock: () async {},
          disableWakelock: () async {},
          clock: () => now,
        );
        addTearDown(orchestrator.dispose);

        await tester.pumpWidget(RoadifyApp(sessionOrchestrator: orchestrator));
        await tester.pumpAndSettle();

        await orchestrator.startSession(runId: 7);
        orchestrator.didChangeAppLifecycleState(AppLifecycleState.paused);
        now = now.add(const Duration(seconds: 5));
        orchestrator.didChangeAppLifecycleState(AppLifecycleState.resumed);
        await tester.pumpAndSettle();

        expect(
          find.textContaining('Sessão retomada após interrupção (5s)'),
          findsOneWidget,
        );

        await tester.tap(find.text('OK'));
        await tester.pumpAndSettle();

        expect(
          find.textContaining('Sessão retomada após interrupção'),
          findsNothing,
        );
      },
    );
  });
}
