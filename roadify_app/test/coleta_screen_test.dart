import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:roadify_app/core/theme/app_theme.dart';
import 'package:roadify_app/features/coleta/presentation/coleta_screen.dart';
import 'package:roadify_app/features/coleta/viewmodels/coleta_viewmodel.dart';

class _RecordingColetaViewModel implements ColetaViewModel {
  ConfiguracaoColeta? requestedConfiguration;

  @override
  Future<void> prosseguirParaGravacao({
    required ConfiguracaoColeta configuracao,
  }) async {
    requestedConfiguration = configuracao;
  }
}

void main() {
  testWidgets('sends selected sensors and rates to the ViewModel', (
    tester,
  ) async {
    final viewModel = _RecordingColetaViewModel();

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: ColetaScreen(viewModel: viewModel),
      ),
    );

    await tester.tap(find.text('200 Hz'));
    await tester.tap(find.byKey(const ValueKey('sensor-giroscopio-checkbox')));
    final cameraCheckbox = find.byKey(const ValueKey('sensor-camera-checkbox'));
    await tester.ensureVisible(cameraCheckbox);
    await tester.tap(cameraCheckbox);
    await tester.pump();
    await tester.ensureVisible(find.text('Prosseguir para gravação'));
    await tester.tap(find.text('Prosseguir para gravação'));
    await tester.pumpAndSettle();

    expect(
      viewModel.requestedConfiguration?.sensoresSelecionados,
      containsAll([
        SensorColeta.acelerometro,
        SensorColeta.giroscopio,
        SensorColeta.gps,
        SensorColeta.camera,
      ]),
    );
    expect(viewModel.requestedConfiguration?.taxaInercialHz, 200);
    expect(viewModel.requestedConfiguration?.taxaGpsHz, 10);
    expect(viewModel.requestedConfiguration?.intervaloMetros, 20);
    expect(
      find.text('Coleta simulada preparada com 4 sensores.'),
      findsOneWidget,
    );
  });

  testWidgets('requires accelerometer and GPS before proceeding', (
    tester,
  ) async {
    final viewModel = _RecordingColetaViewModel();

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: ColetaScreen(viewModel: viewModel),
      ),
    );

    await tester.tap(find.byKey(const ValueKey('sensor-gps-checkbox')));
    await tester.pump();
    await tester.ensureVisible(find.text('Prosseguir para gravação'));
    await tester.tap(find.text('Prosseguir para gravação'));
    await tester.pump();

    expect(viewModel.requestedConfiguration, isNull);
    expect(
      find.text('Acelerômetro e GPS são obrigatórios para iniciar a coleta.'),
      findsOneWidget,
    );
  });
}
