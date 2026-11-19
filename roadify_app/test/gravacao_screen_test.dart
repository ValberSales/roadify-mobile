import 'package:camera/camera.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:roadify_app/core/database/app_database.dart';
import 'package:roadify_app/core/theme/app_theme.dart';
import 'package:roadify_app/features/coleta/viewmodels/coleta_viewmodel.dart';
import 'package:roadify_app/features/gravacao/gravacao_screen.dart';
import 'package:roadify_app/features/gravacao/services/recording_repository.dart';
import 'package:roadify_app/features/gravacao/widgets/camera_capture_controls.dart';

void main() {
  late AppDatabase database;
  late RecordingRepository repository;
  late int vehicleId;

  setUp(() async {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    vehicleId = await database
        .into(database.vehicles)
        .insert(
          VehiclesCompanion.insert(
            name: 'Veículo de teste',
            model: 'Modelo',
            licensePlate: 'ABC1234',
            defaultOdometer: 1000,
            year: 2020,
          ),
        );
    repository = RecordingRepository(database);
  });

  tearDown(() async {
    await database.close();
  });

  testWidgets('blocks photo capture while video is recording', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CameraCaptureControls(
            mediaType: CameraMediaType.photosAndVideos,
            isVideoRecording: true,
            isBusy: false,
            videoElapsed: Duration.zero,
            videoDurationSeconds: 60,
            errorMessage: null,
            onTakePhoto: () {},
            onToggleVideo: () {},
          ),
        ),
      ),
    );

    expect(
      tester
          .widget<FilledButton>(
            find.descendant(
              of: find.byKey(const ValueKey('botao-capturar-foto')),
              matching: find.byType(FilledButton),
            ),
          )
          .onPressed,
      isNull,
    );
    expect(
      tester
          .widget<FilledButton>(
            find.descendant(
              of: find.byKey(const ValueKey('botao-gravar-video')),
              matching: find.byType(FilledButton),
            ),
          )
          .onPressed,
      isNotNull,
    );
  });

  testWidgets('exibe apenas controles sem preview ativo da câmera', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: CameraCaptureControls(
            mediaType: CameraMediaType.photosAndVideos,
            isVideoRecording: false,
            isBusy: false,
            videoElapsed: Duration.zero,
            videoDurationSeconds: 30,
            errorMessage: null,
            onTakePhoto: () {},
            onToggleVideo: () {},
          ),
        ),
      ),
    );

    expect(find.byType(CameraPreview), findsNothing);
    expect(find.byKey(const ValueKey('botao-capturar-foto')), findsOneWidget);
    expect(find.byKey(const ValueKey('botao-gravar-video')), findsOneWidget);
    expect(
      tester
          .widget<FilledButton>(
            find.descendant(
              of: find.byKey(const ValueKey('botao-capturar-foto')),
              matching: find.byType(FilledButton),
            ),
          )
          .onPressed,
      isNotNull,
    );
  });

  Future<void> waitForRecording(WidgetTester tester) async {
    for (
      var attempt = 0;
      attempt < 20 && find.text('GRAVANDO').evaluate().isEmpty;
      attempt++
    ) {
      await tester.pump(const Duration(milliseconds: 25));
    }
  }

  testWidgets('exibe telemetria real, parâmetros e finalização da coleta', (
    tester,
  ) async {
    final configuracao = ConfiguracaoColeta(
      sensoresSelecionados: {
        SensorColeta.acelerometro,
        SensorColeta.gps,
        SensorColeta.giroscopio,
      },
      taxaInercialHz: 200,
      taxaGpsHz: 10,
      intervaloMetros: 25,
      trecho: 'Trecho de teste',
      identificador: 'ensaio-001',
      vehicleId: vehicleId,
      odometroInicial: 1000,
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: GravacaoScreen(
          configuracao: configuracao,
          repository: repository,
          captureDeviceSensors: false,
        ),
      ),
    );
    await waitForRecording(tester);

    expect(find.text('Coleta em Andamento'), findsOneWidget);
    expect(find.text('GRAVANDO'), findsOneWidget);
    expect(find.text('TEMPO DECORRIDO'), findsOneWidget);
    expect(find.byKey(const ValueKey('recording-info-button')), findsOneWidget);
    expect(
      find.byKey(const ValueKey('recording-parameters-card')),
      findsNothing,
    );
    expect(find.text('Amostras'), findsOneWidget);
    expect(find.text('Pontos GPS'), findsOneWidget);
    expect(find.text('Acelerômetro ao Vivo'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('recording-sample-metrics')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('live-chart-accelerometer')),
      findsOneWidget,
    );
    final monitorChart = tester.getRect(
      find.byKey(const ValueKey('live-chart-accelerometer')),
    );
    final monitorViewport = tester.getRect(
      find.byKey(const ValueKey('recording-content-scroll')),
    );
    expect(monitorChart.bottom, lessThanOrEqualTo(monitorViewport.bottom));
    expect(
      find.byKey(const ValueKey('sticky-recording-telemetry')),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('elapsed-time-sticky')), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.byKey(const ValueKey('recording-info-button')));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Informações da coleta'), findsOneWidget);
    expect(find.text('Acelerômetro'), findsOneWidget);
    expect(find.text('200 Hz'), findsOneWidget);
    expect(
      find.text('10 Hz • intervalo mínimo de gravação 25 m'),
      findsOneWidget,
    );
    await tester.tap(find.byKey(const ValueKey('close-recording-info')));
    await tester.pump(const Duration(milliseconds: 300));

    final finalizar = find.text('Finalizar Coleta');
    await tester.ensureVisible(finalizar);
    await tester.tap(finalizar);
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Resumo da coleta'), findsOneWidget);
    expect(find.text('Resumo do que será salvo'), findsOneWidget);
    expect(find.text('Amostras inerciais'), findsOneWidget);
    expect(find.text('Pontos GPS'), findsNWidgets(2));
    expect(find.text('Sensores configurados'), findsOneWidget);
    expect(find.text('Finalizar e Salvar'), findsOneWidget);
    await tester.tap(find.text('Finalizar e Salvar'));
    await tester.pumpAndSettle();

    final savedRun = (await database.select(database.runsTable).get()).single;
    expect(savedRun.endedAt, isNotNull);
    expect(
      savedRun.configurationJson,
      contains('"accelerometerFrequencyHz":200'),
    );
    expect(savedRun.configurationJson, contains('"identifier":"ensaio-001"'));
    expect(
      (await database.vehicleDao.getVehicleById(vehicleId)).defaultOdometer,
      1000,
    );
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('mostra as configurações de sensores complementares', (
    tester,
  ) async {
    final configuracao = ConfiguracaoColeta(
      sensoresSelecionados: {
        SensorColeta.acelerometro,
        SensorColeta.gps,
        SensorColeta.giroscopio,
        SensorColeta.camera,
        SensorColeta.audio,
      },
      taxaInercialHz: 200,
      taxaGpsHz: 10,
      intervaloMetros: 25,
      trecho: 'Trecho de teste',
      identificador: 'ensaio-002',
      vehicleId: vehicleId,
      odometroInicial: 1000,
      sensoresOpcionais: const OptionalSensorSettings(
        gyroscopeFrequencyHz: 250,
        camera: CameraCaptureSettings(
          mediaType: CameraMediaType.videos,
          facing: CameraFacing.front,
          automatic: true,
          interval: 5,
          intervalUnit: CaptureIntervalUnit.kilometers,
          videoDurationSeconds: 120,
        ),
        audio: AudioCaptureSettings(
          automatic: true,
          interval: 2,
          intervalUnit: CaptureIntervalUnit.hours,
          durationSeconds: 45,
        ),
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: GravacaoScreen(
          configuracao: configuracao,
          repository: repository,
          captureDeviceSensors: false,
        ),
      ),
    );
    await waitForRecording(tester);

    await tester.tap(find.byKey(const ValueKey('recording-info-button')));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('250 Hz'), findsOneWidget);
    await tester.drag(
      find.byKey(const ValueKey('recording-info-list')),
      const Offset(0, -300),
    );
    await tester.pump();
    expect(
      find.text(
        'vídeos • câmera frontal • automática a cada 5 km • vídeo até 120s',
      ),
      findsOneWidget,
    );
    expect(find.text('Automático a cada 2 h • até 45s'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('close-recording-info')));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byKey(const ValueKey('floating-video-action')), findsOneWidget);
    expect(find.byKey(const ValueKey('floating-audio-action')), findsOneWidget);
    expect(
      find.byKey(const ValueKey('audio-recording-indicator')),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('exibe controles separados para foto e vídeo no modo combinado', (
    tester,
  ) async {
    final configuration = ConfiguracaoColeta(
      sensoresSelecionados: {
        SensorColeta.acelerometro,
        SensorColeta.gps,
        SensorColeta.camera,
      },
      taxaInercialHz: 100,
      taxaGpsHz: 5,
      intervaloMetros: 20,
      trecho: 'Trecho de teste',
      identificador: 'ensaio-003',
      vehicleId: vehicleId,
      odometroInicial: 1000,
      sensoresOpcionais: const OptionalSensorSettings(
        camera: CameraCaptureSettings(
          mediaType: CameraMediaType.photosAndVideos,
          videoDurationSeconds: 30,
        ),
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: GravacaoScreen(
          configuracao: configuration,
          repository: repository,
          captureDeviceSensors: false,
        ),
      ),
    );
    await waitForRecording(tester);
    expect(find.byKey(const ValueKey('floating-photo-action')), findsOneWidget);
    expect(find.byKey(const ValueKey('floating-video-action')), findsOneWidget);
    expect(
      find.byKey(const ValueKey('floating-finish-action')),
      findsOneWidget,
    );
    final chartBottom = tester
        .getRect(find.byKey(const ValueKey('live-chart-accelerometer')))
        .bottom;
    final contentBottom = tester
        .getRect(find.byKey(const ValueKey('recording-content-scroll')))
        .bottom;
    expect(chartBottom, lessThanOrEqualTo(contentBottom));
    final actionDockTop = tester
        .getRect(find.byKey(const ValueKey('recording-action-dock')))
        .top;
    await tester.drag(
      find.byKey(const ValueKey('recording-content-scroll')),
      const Offset(0, -300),
    );
    await tester.pumpAndSettle();
    expect(
      tester.getRect(find.byKey(const ValueKey('recording-action-dock'))).top,
      actionDockTop,
    );
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('respeita o tema escolhido e exibe o cronômetro', (tester) async {
    final configuration = ConfiguracaoColeta(
      sensoresSelecionados: {
        SensorColeta.acelerometro,
        SensorColeta.gps,
        SensorColeta.camera,
      },
      taxaInercialHz: 100,
      taxaGpsHz: 5,
      intervaloMetros: 20,
      trecho: 'Trecho de teste',
      identificador: 'ensaio-hud',
      vehicleId: vehicleId,
      odometroInicial: 1000,
      sensoresOpcionais: const OptionalSensorSettings(
        camera: CameraCaptureSettings(
          mediaType: CameraMediaType.photosAndVideos,
        ),
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: GravacaoScreen(
          configuracao: configuration,
          repository: repository,
          captureDeviceSensors: false,
        ),
      ),
    );
    await waitForRecording(tester);
    await tester.pump(const Duration(milliseconds: 250));

    final elapsedContext = tester.element(
      find.byKey(const ValueKey('elapsed-time-sticky')),
    );
    expect(Theme.of(elapsedContext).brightness, Brightness.light);
    expect(
      find.byKey(const ValueKey('recording-parameters-card')),
      findsNothing,
    );
    await tester.tap(find.byKey(const ValueKey('recording-info-button')));
    await tester.pump(const Duration(milliseconds: 300));
    expect(
      Theme.of(tester.element(find.text('Informações da coleta'))).brightness,
      Brightness.light,
    );
    await tester.tap(find.byKey(const ValueKey('close-recording-info')));
    await tester.pump(const Duration(milliseconds: 300));
    expect(
      tester
          .widget<Text>(find.byKey(const ValueKey('elapsed-time-sticky')))
          .data,
      matches(RegExp(r'^\d{2}:\d{2}:\d{2}\.\d$')),
    );
    expect(
      tester.widget<Text>(find.byKey(const ValueKey('speedometer-value'))).data,
      '-- km/h',
    );
    expect(find.byKey(const ValueKey('quick-capture-photo')), findsNothing);
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: ThemeMode.dark,
        home: GravacaoScreen(
          key: const ValueKey('dark-theme-recording'),
          configuracao: configuration,
          repository: repository,
          captureDeviceSensors: false,
        ),
      ),
    );
    await waitForRecording(tester);
    await tester.pump(const Duration(milliseconds: 300));

    final darkElapsedContext = tester.element(
      find.byKey(const ValueKey('elapsed-time-sticky')),
    );
    expect(Theme.of(darkElapsedContext).brightness, Brightness.dark);
    await tester.tap(find.byKey(const ValueKey('recording-info-button')));
    await tester.pump(const Duration(milliseconds: 300));
    expect(
      Theme.of(tester.element(find.text('Informações da coleta'))).brightness,
      Brightness.dark,
    );
    await tester.tap(find.byKey(const ValueKey('close-recording-info')));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('impede iniciar com frequência inercial fora da faixa', (
    tester,
  ) async {
    final configuration = ConfiguracaoColeta(
      sensoresSelecionados: {SensorColeta.acelerometro, SensorColeta.gps},
      taxaInercialHz: 20,
      taxaGpsHz: 10,
      intervaloMetros: 25,
      trecho: 'Trecho de teste',
      identificador: 'ensaio-004',
      vehicleId: vehicleId,
      odometroInicial: 1000,
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: GravacaoScreen(
          configuracao: configuration,
          repository: repository,
          captureDeviceSensors: false,
        ),
      ),
    );
    await tester.pump();

    expect(
      find.textContaining(
        'frequência do acelerômetro deve estar entre 50 e 500 Hz',
      ),
      findsOneWidget,
    );
    expect(await database.select(database.runsTable).get(), isEmpty);
    await tester.pumpWidget(const SizedBox());
  });
}
