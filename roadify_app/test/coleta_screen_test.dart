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

  testWidgets('exibe presets de frequência para acelerômetro e GPS, permitindo valores customizados', (
    tester,
  ) async {
    final viewModel = _RecordingColetaViewModel();

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: ColetaScreen(viewModel: viewModel),
      ),
    );

    // 1. Verifica presença dos botões pre-configurados do acelerômetro: 100, 200, 300, 400, 500 Hz e Outro
    expect(find.byKey(const ValueKey('chip-acc-100')), findsOneWidget);
    expect(find.byKey(const ValueKey('chip-acc-200')), findsOneWidget);
    expect(find.byKey(const ValueKey('chip-acc-300')), findsOneWidget);
    expect(find.byKey(const ValueKey('chip-acc-400')), findsOneWidget);
    expect(find.byKey(const ValueKey('chip-acc-500')), findsOneWidget);
    expect(find.byKey(const ValueKey('chip-acc-outro')), findsOneWidget);

    // 2. Verifica presença dos botões pre-configurados do GPS: 1, 2, 5, 10 Hz e Outro
    expect(find.byKey(const ValueKey('chip-gps-1')), findsOneWidget);
    expect(find.byKey(const ValueKey('chip-gps-2')), findsOneWidget);
    expect(find.byKey(const ValueKey('chip-gps-5')), findsOneWidget);
    expect(find.byKey(const ValueKey('chip-gps-10')), findsOneWidget);
    expect(find.byKey(const ValueKey('chip-gps-outro')), findsOneWidget);

    // 3. Testa seleção de preset de acelerômetro 400 Hz e GPS 5 Hz
    final chipAcc400 = find.byKey(const ValueKey('chip-acc-400'));
    await tester.ensureVisible(chipAcc400);
    await tester.tap(chipAcc400);

    final chipGps5 = find.byKey(const ValueKey('chip-gps-5'));
    await tester.ensureVisible(chipGps5);
    await tester.tap(chipGps5);
    await tester.pump();

    // 4. Testa botão "Outro..." do acelerômetro e digitação de frequência personalizada (ex: 250 Hz)
    final chipAccOutro = find.byKey(const ValueKey('chip-acc-outro'));
    await tester.ensureVisible(chipAccOutro);
    await tester.tap(chipAccOutro);
    await tester.pump();

    final inputAccCustom = find.byKey(const ValueKey('input-acc-custom'));
    await tester.ensureVisible(inputAccCustom);
    await tester.enterText(inputAccCustom, '250');
    await tester.pump();

    // 5. Inicia coleta e valida configuração enviada
    await tester.ensureVisible(find.text('Prosseguir para gravação'));
    await tester.tap(find.text('Prosseguir para gravação'));
    await tester.pumpAndSettle();

    expect(viewModel.requestedConfiguration?.taxaInercialHz, 250);
    expect(viewModel.requestedConfiguration?.taxaAcelerometroHz, 250);
    expect(viewModel.requestedConfiguration?.taxaGpsHz, 5);
  });
}
