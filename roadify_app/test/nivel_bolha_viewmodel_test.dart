import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:roadify_app/features/sensores/models/nivel_bolha_state.dart';
import 'package:roadify_app/features/sensores/services/sensor_orientation_service.dart';
import 'package:roadify_app/features/sensores/viewmodel/nivel_bolha_viewmodel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('NivelBolhaViewModel & NivelBolhaState Tests', () {
    late NivelBolhaViewModel viewModel;

    setUp(() {
      viewModel = NivelBolhaViewModel(autoStart: false);
    });

    tearDown(() {
      viewModel.dispose();
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

    test('Modo Auto resolve para Circular 2D quando deitado e Tubular T quando em pé', () {
      viewModel.setMode(BubbleDisplayMode.auto);

      // Postura deitada (Z próximo de 9.81 m/s²)
      viewModel.updateFromSensors(accelX: 0.0, accelY: 0.0, accelZ: 9.81);
      expect(viewModel.state.detectedOrientation, DeviceOrientationMode.horizontal);
      expect(viewModel.state.activeMode, BubbleDisplayMode.circular2D);

      // Postura vertical (em suporte veicular, Z próximo de zero)
      viewModel.updateFromSensors(accelX: 0.0, accelY: 9.81, accelZ: 0.5);
      expect(viewModel.state.detectedOrientation, DeviceOrientationMode.vertical);
      expect(viewModel.state.activeMode, BubbleDisplayMode.tubularT);
    });

    test('Calibração de Tara (Zerar Nível)', () {
      // Configura ângulos não zerados
      viewModel.setAngles(2.4, -1.8);
      expect(viewModel.state.calibratedAngleX, 2.4);
      expect(viewModel.state.calibratedAngleY, -1.8);
      expect(viewModel.state.isCalibrated, false);
      expect(viewModel.state.isLevel, false);

      // Realiza a calibração / tara
      viewModel.calibrate();
      expect(viewModel.state.isCalibrated, true);
      expect(viewModel.state.calibOffsetX, 2.4);
      expect(viewModel.state.calibOffsetY, -1.8);
      expect(viewModel.state.calibratedAngleX, 0.0);
      expect(viewModel.state.calibratedAngleY, 0.0);
      expect(viewModel.state.isLevel, true);

      // Ao resetar a calibração, volta aos ângulos brutos
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

    test('Simulação de dados de sensores brutos (acelerômetro X, Y, Z)', () {
      viewModel.updateFromSensors(accelX: 0.0, accelY: 9.81, accelZ: 0.0);
      expect(viewModel.state.detectedOrientation, DeviceOrientationMode.vertical);
      expect(viewModel.state.activeMode, BubbleDisplayMode.tubularT);

      viewModel.updateFromSensors(accelX: 0.0, accelY: 0.0, accelZ: 9.81);
      expect(viewModel.state.detectedOrientation, DeviceOrientationMode.horizontal);
      expect(viewModel.state.activeMode, BubbleDisplayMode.circular2D);
    });
  });

  group('SensorOrientationService Tests', () {
    test('Processamento de leitura com filtro passa-baixa e conversão trigonométrica', () async {
      final mockController = StreamController<AccelerometerEvent>();
      final service = SensorOrientationService(
        alpha: 0.2,
        customAccelerometerStream: mockController.stream,
      );
      expect(service.alpha, 0.2);

      service.startListening(allowMockFallback: false);

      // Injeta leitura de teste
      mockController.add(AccelerometerEvent(0.5, 0.2, 9.81, DateTime.now()));

      final reading = await service.orientationStream.first;
      expect(reading.accelZ, closeTo(9.81, 0.1));
      expect(reading.roll, isA<double>());
      expect(reading.pitch, isA<double>());
      expect(reading.isFromHardware, true);

      service.dispose();
      await mockController.close();
    });
  });
}
