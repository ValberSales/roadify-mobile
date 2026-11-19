import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:roadify_app/core/widgets/app_loading_indicator.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:roadify_app/core/theme/app_theme.dart';
import 'package:roadify_app/features/sensores/models/circular_buffer.dart';
import 'package:roadify_app/features/sensores/models/nivel_bolha_state.dart';
import 'package:roadify_app/features/sensores/presentation/sensores_screen.dart';
import 'package:roadify_app/features/sensores/services/sensor_orientation_service.dart';
import 'package:roadify_app/features/sensores/viewmodel/nivel_bolha_viewmodel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('CircularBuffer Tests (Sprint 4)', () {
    test('Mantém rigorosamente o limite de 50 amostras em FIFO sem engasgos', () {
      final buffer = CircularBuffer<int>(50);
      expect(buffer.isEmpty, isTrue);
      expect(buffer.capacity, equals(50));

      for (var i = 1; i <= 60; i++) {
        buffer.add(i);
      }

      expect(buffer.length, equals(50));
      expect(buffer.isFull, isTrue);
      expect(buffer.first, equals(11)); // Primeiros 10 foram descartados
      expect(buffer.last, equals(60));  // Último elemento é o mais recente
      expect(buffer[0], equals(11));
      expect(buffer[49], equals(60));
    });

    test('toList gera lista cronológica correta', () {
      final buffer = CircularBuffer<int>(3);
      buffer.addAll([1, 2, 3]);
      buffer.add(4); // Sobrescreve o 1

      expect(buffer.toList(), equals([2, 3, 4]));
    });
  });

  group('NivelBolhaViewModel & NivelBolhaState Tests (Sprint 4)', () {
    late NivelBolhaViewModel viewModel;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      viewModel = NivelBolhaViewModel(autoStart: false);
    });

    tearDown(() {
      viewModel.dispose();
    });

    test('Buffer circular inicial possui janela de 1 minuto (600 amostras a 10 Hz)', () {
      expect(viewModel.signalBuffer.length, equals(600));
      expect(viewModel.signalHistory.length, equals(600));
      expect(NivelBolhaViewModel.maxHistoryPoints, equals(600));
      expect(
        NivelBolhaViewModel.chartWindowDuration,
        equals(const Duration(seconds: 60)),
      );
    });

    test('Estado inicial padrão', () {
      expect(viewModel.state.selectedMode, BubbleDisplayMode.auto);
      expect(viewModel.state.isCalibrated, false);
      expect(viewModel.state.calibOffsetX, 0.0);
      expect(viewModel.state.calibOffsetY, 0.0);
    });

    test('Alternância manual de modos de exibição', () {
      viewModel.setMode(BubbleDisplayMode.circular2D);
      expect(viewModel.state.selectedMode, BubbleDisplayMode.circular2D);
      expect(viewModel.state.activeMode, BubbleDisplayMode.circular2D);

      viewModel.setMode(BubbleDisplayMode.tubularT);
      expect(viewModel.state.selectedMode, BubbleDisplayMode.tubularT);
      expect(viewModel.state.activeMode, BubbleDisplayMode.tubularT);
    });

    test(
      'Modo Auto resolve para Circular 2D quando deitado e Tubular T quando em pé',
      () {
        viewModel.setMode(BubbleDisplayMode.auto);

        // Postura deitada (Z próximo de 9.81 m/s²)
        viewModel.updateFromSensors(accelX: 0.0, accelY: 0.0, accelZ: 9.81);
        expect(
          viewModel.state.detectedOrientation,
          DeviceOrientationMode.horizontal,
        );
        expect(viewModel.state.activeMode, BubbleDisplayMode.circular2D);

        // Postura vertical (em suporte veicular, Z próximo de zero)
        viewModel.updateFromSensors(accelX: 0.0, accelY: 9.81, accelZ: 0.5);
        expect(
          viewModel.state.detectedOrientation,
          DeviceOrientationMode.vertical,
        );
        expect(viewModel.state.activeMode, BubbleDisplayMode.tubularT);
      },
    );

    test('Calibração de Tara (Zerar Nível) e Persistência (SP2-06)', () async {
      viewModel.setAngles(2.4, -1.8);
      expect(viewModel.state.calibratedAngleX, 2.4);
      expect(viewModel.state.calibratedAngleY, -1.8);
      expect(viewModel.state.isCalibrated, false);
      expect(viewModel.state.isLevel, false);

      viewModel.calibrate();
      expect(viewModel.state.isCalibrated, true);
      expect(viewModel.state.calibOffsetX, 2.4);
      expect(viewModel.state.calibOffsetY, -1.8);
      expect(viewModel.state.calibratedAngleX, 0.0);
      expect(viewModel.state.calibratedAngleY, 0.0);
      expect(viewModel.state.isLevel, true);

      await viewModel.persistCalibration();

      final restoredVm = NivelBolhaViewModel(autoStart: false);
      addTearDown(restoredVm.dispose);
      await restoredVm.loadPersistedCalibration();
      expect(restoredVm.state.isCalibrated, isTrue);
      expect(restoredVm.state.calibOffsetX, equals(2.4));
      expect(restoredVm.state.calibOffsetY, equals(-1.8));

      viewModel.resetCalibration();
      expect(viewModel.state.isCalibrated, false);
      expect(viewModel.state.calibOffsetX, 0.0);
      expect(viewModel.state.calibOffsetY, 0.0);
      expect(viewModel.state.calibratedAngleX, 2.4);
      expect(viewModel.state.calibratedAngleY, -1.8);
    });

    test('Critério de tolerância de nivelamento (<= 0.5 graus)', () {
      viewModel.setAngles(0.3, 0.2);
      expect(viewModel.state.isLevelX, true);
      expect(viewModel.state.isLevelY, true);
      expect(viewModel.state.isLevel, true);

      viewModel.setAngles(0.8, 0.1);
      expect(viewModel.state.isLevelX, false);
      expect(viewModel.state.isLevel, false);
    });

    test('Atualização inercial de Acelerômetro e Giroscópio (Sprint 4)', () {
      viewModel.updateFromSensors(
        accelX: 1.2,
        accelY: -0.5,
        accelZ: 9.75,
        gyroX: 0.15,
        gyroY: -0.22,
        gyroZ: 0.05,
      );

      expect(viewModel.state.accelX, equals(1.2));
      expect(viewModel.state.accelY, equals(-0.5));
      expect(viewModel.state.accelZ, equals(9.75));
      expect(viewModel.state.gyroX, equals(0.15));
      expect(viewModel.state.gyroY, equals(-0.22));
      expect(viewModel.state.gyroZ, equals(0.05));

      final last = viewModel.signalHistory.last;
      expect(last.accelX, equals(1.2));
      expect(last.gyroX, equals(0.15));
      expect(last.gyroY, equals(-0.22));
      expect(last.gyroZ, equals(0.05));
    });
  });

  group('SensorOrientationService Tests', () {
    testWidgets('exibe loading enquanto carrega calibração dos sensores', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({});
      final preferences = await SharedPreferences.getInstance();
      final calibration = Completer<SharedPreferences>();
      final vm = NivelBolhaViewModel(
        autoStart: false,
        preferencesProvider: () => calibration.future,
      );
      addTearDown(vm.dispose);

      await tester.pumpWidget(MaterialApp(home: SensoresScreen(viewModel: vm)));

      expect(find.byType(AppLoadingIndicator), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      calibration.complete(preferences);
      await tester.pumpAndSettle();

      expect(find.byType(AppLoadingIndicator), findsNothing);
      expect(find.byType(TabBarView), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
    });

    test('coalesces high-rate updates sent to the sensor screen', () async {
      final sensorEvents = StreamController<AccelerometerEvent>.broadcast(
        sync: true,
      );
      final service = SensorOrientationService(
        customAccelerometerStream: sensorEvents.stream,
      );
      final vm = NivelBolhaViewModel(orientationService: service);
      var notifications = 0;
      vm.addListener(() => notifications++);

      for (var index = 0; index < 20; index++) {
        sensorEvents.add(
          AccelerometerEvent(index.toDouble(), 0, 9.81, DateTime.now()),
        );
      }

      expect(notifications, 0);
      await Future<void>.delayed(const Duration(milliseconds: 120));
      expect(notifications, 1);

      vm.dispose();
      await sensorEvents.close();
    });

    test(
      'Processamento de leitura com filtro passa-baixa e conversão trigonométrica',
      () async {
        final mockController = StreamController<AccelerometerEvent>();
        final service = SensorOrientationService(
          alpha: 0.2,
          customAccelerometerStream: mockController.stream,
        );
        expect(service.alpha, 0.2);

        service.startListening(allowMockFallback: false);

        mockController.add(AccelerometerEvent(0.5, 0.2, 9.81, DateTime.now()));

        final reading = await service.orientationStream.first;
        expect(reading.accelZ, closeTo(9.81, 0.1));
        expect(reading.roll, isA<double>());
        expect(reading.pitch, isA<double>());
        expect(reading.isFromHardware, true);

        service.dispose();
        await mockController.close();
      },
    );

    testWidgets(
      'SensoresScreen exibe osciloscópios a 60 FPS na aba Sinais ao Vivo (Sprint 4)',
      (tester) async {
        final vm = NivelBolhaViewModel(autoStart: false);
        addTearDown(vm.dispose);

        await tester.pumpWidget(
          MaterialApp(home: SensoresScreen(viewModel: vm)),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text('Sinais ao Vivo'));
        await tester.pumpAndSettle();

        // Verifica os cards de osciloscópio do Acelerômetro e Giroscópio
        expect(
          find.byKey(const ValueKey('live-chart-accelerometer')),
          findsOneWidget,
        );
        expect(
          find.byKey(const ValueKey('live-chart-gyroscope')),
          findsOneWidget,
        );
        expect(
          find.byKey(const ValueKey('live-chart-inclination')),
          findsOneWidget,
        );
        expect(
          find.byKey(const ValueKey('live-card-gps')),
          findsOneWidget,
        );

        // Injeta dados e verifica propagação imediata no buffer
        vm.updateFromSensors(
          accelX: 1.5,
          accelY: -0.8,
          accelZ: 9.65,
          gyroX: 0.33,
          gyroY: -0.15,
          gyroZ: 0.08,
        );
        await tester.pump();

        expect(vm.signalHistory.last.accelX, equals(1.5));
        expect(vm.signalHistory.last.accelY, equals(-0.8));
        expect(vm.signalHistory.last.gyroX, equals(0.33));
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'SensoresScreen: aba Sinais ao Vivo não sofre RenderFlex overflow em tela estreita (320px)',
      (tester) async {
        tester.view.physicalSize = const Size(320 * 2.0, 800 * 2.0);
        tester.view.devicePixelRatio = 2.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        final vm = NivelBolhaViewModel(autoStart: false);
        addTearDown(vm.dispose);

        await tester.pumpWidget(
          MaterialApp(home: SensoresScreen(viewModel: vm)),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text('Sinais ao Vivo'));
        await tester.pumpAndSettle();

        expect(find.text('Janela: 1 min (60s)'), findsAtLeastNWidgets(1));
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox());
      },
    );

    testWidgets('SensoresScreen usa cores compatíveis com o tema escuro', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({});
      final vm = NivelBolhaViewModel(autoStart: false);
      addTearDown(vm.dispose);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: ThemeMode.dark,
          home: SensoresScreen(viewModel: vm),
        ),
      );
      await tester.pumpAndSettle();

      final modeLabel = tester.widget<Text>(
        find.textContaining('Visualização:'),
      );
      expect(
        Theme.of(
          tester.element(find.text('Sensores & Nivelamento')),
        ).brightness,
        Brightness.dark,
      );
      expect(modeLabel.style?.color, AppTheme.dark.colorScheme.primary);
      await tester.pumpWidget(const SizedBox());
    });
  });
}
