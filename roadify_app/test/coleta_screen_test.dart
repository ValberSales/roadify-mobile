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
  testWidgets('requires vehicle selection before starting collection', (
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
    final gyroscopeCheckbox = find.byKey(
      const ValueKey('sensor-giroscopio-checkbox'),
    );
    await tester.ensureVisible(gyroscopeCheckbox);
    await tester.tap(gyroscopeCheckbox);
    final cameraCheckbox = find.byKey(const ValueKey('sensor-camera-checkbox'));
    await tester.ensureVisible(cameraCheckbox);
    await tester.tap(cameraCheckbox);
    await tester.pump();
    await tester.ensureVisible(find.text('Prosseguir para gravação'));
    await tester.tap(find.text('Prosseguir para gravação'));
    await tester.pumpAndSettle();

    expect(viewModel.requestedConfiguration, isNull);
    expect(find.text('Selecione um veículo para a coleta.'), findsOneWidget);
  });

  testWidgets('keeps required sensors selected without checkboxes', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: ColetaScreen(viewModel: _RecordingColetaViewModel()),
      ),
    );

    expect(
      find.byKey(const ValueKey('sensor-acelerometro-checkbox')),
      findsNothing,
    );
    expect(find.byKey(const ValueKey('sensor-gps-checkbox')), findsNothing);
    expect(find.text('Obrigatório'), findsNWidgets(2));
    expect(find.byKey(const ValueKey('chip-acc-100')), findsOneWidget);
    expect(find.byKey(const ValueKey('chip-gps-10')), findsOneWidget);
  });

  testWidgets('prefills the collection name and validates required fields', (
    tester,
  ) async {
    final viewModel = _RecordingColetaViewModel();

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: ColetaScreen(viewModel: viewModel),
      ),
    );

    final collectionNameField = tester.widget<TextFormField>(
      find.byKey(const ValueKey('collection-name-field')),
    );
    expect(
      collectionNameField.controller!.text,
      matches(RegExp(r'^\d{2}/\d{2}/\d{4} - \d{2}:\d{2}$')),
    );

    await tester.enterText(
      find.byKey(const ValueKey('collection-name-field')),
      '   ',
    );
    await tester.pump();
    expect(find.text('Informe o nome da coleta.'), findsOneWidget);
    await tester.ensureVisible(find.text('Prosseguir para gravação'));
    await tester.tap(find.text('Prosseguir para gravação'));
    await tester.pump();

    expect(find.text('Informe o nome da coleta.'), findsOneWidget);
    expect(find.text('Selecione um veículo para a coleta.'), findsOneWidget);
    expect(viewModel.requestedConfiguration, isNull);
  });

  testWidgets(
    'exibe presets de frequência para acelerômetro e GPS, permitindo valores customizados',
    (tester) async {
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

      // 5. Valida os valores escolhidos; é necessário selecionar um veículo
      // antes de iniciar uma coleta.
      final customFrequencyField = tester.widget<TextFormField>(inputAccCustom);
      expect(customFrequencyField.controller!.text, '250');
      expect(tester.widget<ChoiceChip>(chipGps5).selected, isTrue);

      await tester.ensureVisible(find.text('Prosseguir para gravação'));
      await tester.tap(find.text('Prosseguir para gravação'));
      await tester.pump();

      expect(viewModel.requestedConfiguration, isNull);
      expect(find.text('Selecione um veículo para a coleta.'), findsOneWidget);
    },
  );

  testWidgets(
    'validates required sensor frequencies against supported ranges',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: ColetaScreen(viewModel: _RecordingColetaViewModel()),
        ),
      );

      final accOther = find.byKey(const ValueKey('chip-acc-outro'));
      await tester.ensureVisible(accOther);
      await tester.tap(accOther);
      await tester.pump();
      final accInput = find.byKey(const ValueKey('input-acc-custom'));
      await tester.ensureVisible(accInput);
      await tester.enterText(accInput, '49');
      await tester.pump();
      expect(find.text('Use um valor entre 50 e 500 Hz.'), findsOneWidget);

      final gpsOther = find.byKey(const ValueKey('chip-gps-outro'));
      await tester.ensureVisible(gpsOther);
      await tester.tap(gpsOther);
      await tester.pump();
      final gpsInput = find.byKey(const ValueKey('input-gps-custom'));
      await tester.ensureVisible(gpsInput);
      await tester.enterText(gpsInput, '11');
      await tester.pump();
      expect(find.text('Use um valor entre 1 e 10 Hz.'), findsOneWidget);

      await tester.ensureVisible(find.text('Prosseguir para gravação'));
      await tester.tap(find.text('Prosseguir para gravação'));
      await tester.pump();

      expect(find.text('Use um valor entre 50 e 500 Hz.'), findsOneWidget);
      expect(find.text('Use um valor entre 1 e 10 Hz.'), findsOneWidget);
    },
  );

  testWidgets('shows optional sensor configuration only when enabled', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: ColetaScreen(viewModel: _RecordingColetaViewModel()),
      ),
    );

    expect(find.byKey(const ValueKey('input-gyro-custom')), findsNothing);
    expect(find.byKey(const ValueKey('camera-auto-capture')), findsNothing);
    expect(find.byKey(const ValueKey('audio-auto-capture')), findsNothing);

    final gyroCheckbox = find.byKey(
      const ValueKey('sensor-giroscopio-checkbox'),
    );
    await tester.ensureVisible(gyroCheckbox);
    await tester.tap(gyroCheckbox);
    await tester.pump();
    expect(find.byKey(const ValueKey('chip-gyro-100')), findsOneWidget);

    final cameraCheckbox = find.byKey(const ValueKey('sensor-camera-checkbox'));
    await tester.ensureVisible(cameraCheckbox);
    await tester.tap(cameraCheckbox);
    await tester.pump();
    expect(find.byKey(const ValueKey('camera-media-photos')), findsOneWidget);
    expect(find.byKey(const ValueKey('camera-media-videos')), findsOneWidget);
    expect(find.byKey(const ValueKey('camera-facing-front')), findsOneWidget);
    expect(find.byKey(const ValueKey('camera-facing-rear')), findsOneWidget);
    expect(find.byKey(const ValueKey('video-duration-seconds')), findsNothing);

    final videosOption = find.byKey(const ValueKey('camera-media-videos'));
    await tester.ensureVisible(videosOption);
    await tester.tap(videosOption);
    await tester.pump();
    expect(
      find.byKey(const ValueKey('video-duration-seconds')),
      findsOneWidget,
    );

    final cameraAutoSwitch = find.byKey(const ValueKey('camera-auto-capture'));
    await tester.ensureVisible(cameraAutoSwitch);
    await tester.tap(cameraAutoSwitch);
    await tester.pump();
    expect(
      find.byKey(const ValueKey('camera-capture-interval-value')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('camera-capture-interval-unit')),
      findsOneWidget,
    );

    final audioCheckbox = find.byKey(const ValueKey('sensor-audio-checkbox'));
    await tester.ensureVisible(audioCheckbox);
    await tester.tap(audioCheckbox);
    await tester.pump();
    final audioAutoSwitch = find.byKey(const ValueKey('audio-auto-capture'));
    await tester.ensureVisible(audioAutoSwitch);
    await tester.tap(audioAutoSwitch);
    await tester.pump();
    expect(
      find.byKey(const ValueKey('audio-capture-interval-value')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('audio-capture-duration')),
      findsOneWidget,
    );
  });

  testWidgets('validates automatic capture intervals and audio duration', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: ColetaScreen(viewModel: _RecordingColetaViewModel()),
      ),
    );

    final cameraCheckbox = find.byKey(const ValueKey('sensor-camera-checkbox'));
    await tester.ensureVisible(cameraCheckbox);
    await tester.tap(cameraCheckbox);
    await tester.pump();
    final cameraAutoSwitch = find.byKey(const ValueKey('camera-auto-capture'));
    await tester.ensureVisible(cameraAutoSwitch);
    await tester.tap(cameraAutoSwitch);
    await tester.pump();
    final cameraInterval = find.byKey(
      const ValueKey('camera-capture-interval-value'),
    );
    await tester.ensureVisible(cameraInterval);
    await tester.enterText(cameraInterval, '0');

    final audioCheckbox = find.byKey(const ValueKey('sensor-audio-checkbox'));
    await tester.ensureVisible(audioCheckbox);
    await tester.tap(audioCheckbox);
    await tester.pump();
    final audioAutoSwitch = find.byKey(const ValueKey('audio-auto-capture'));
    await tester.ensureVisible(audioAutoSwitch);
    await tester.tap(audioAutoSwitch);
    await tester.pump();
    final audioDuration = find.byKey(const ValueKey('audio-capture-duration'));
    await tester.ensureVisible(audioDuration);
    await tester.enterText(audioDuration, '301');

    await tester.ensureVisible(find.text('Prosseguir para gravação'));
    await tester.tap(find.text('Prosseguir para gravação'));
    await tester.pump();

    expect(find.text('Use um valor entre 1 e 59.'), findsOneWidget);
    expect(
      find.text('Use uma duração entre 1 e 300 segundos.'),
      findsOneWidget,
    );
  });

  testWidgets('rejects video duration above the safe two-minute limit', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: ColetaScreen(viewModel: _RecordingColetaViewModel()),
      ),
    );

    final cameraCheckbox = find.byKey(const ValueKey('sensor-camera-checkbox'));
    await tester.ensureVisible(cameraCheckbox);
    await tester.tap(cameraCheckbox);
    await tester.pump();

    final videosOption = find.byKey(const ValueKey('camera-media-videos'));
    await tester.ensureVisible(videosOption);
    await tester.tap(videosOption);
    await tester.pump();

    final durationField = find.byKey(const ValueKey('video-duration-seconds'));
    await tester.ensureVisible(durationField);
    await tester.enterText(durationField, '121');
    await tester.pump();

    expect(
      find.text('Máximo seguro: 120 segundos (2 minutos).'),
      findsOneWidget,
    );
    expect(find.text('Formato do Arquivo'), findsNothing);
  });
}
