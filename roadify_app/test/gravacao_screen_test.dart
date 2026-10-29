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
            controller: null,
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
      isNull,
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
    expect(find.text('200 Hz'), findsOneWidget);
    expect(find.textContaining('10 Hz • mínimo'), findsOneWidget);
    expect(find.textContaining('25 m entre pontos'), findsOneWidget);
    expect(find.textContaining('25 m'), findsOneWidget);
    expect(find.text('Amostras'), findsOneWidget);
    expect(find.text('Pontos GPS'), findsOneWidget);
    expect(find.text('Acelerômetro ao Vivo'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('sticky-recording-telemetry')),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('elapsed-time-sticky')), findsOneWidget);
    expect(tester.takeException(), isNull);

    final finalizar = find.text('Finalizar Coleta');
    await tester.ensureVisible(finalizar);
    await tester.tap(finalizar);
    await tester.pump();

    expect(find.text('Finalizar Coleta?'), findsOneWidget);
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

    expect(
      find.text(
        'Giroscópio 250 Hz • Câmera frontal: vídeos • vídeo até 120s • '
        'automático a cada 5 km • Áudio: a cada 2 h, 45s',
      ),
      findsOneWidget,
    );
    expect(find.textContaining('Áudio: a cada 2 h, 45s'), findsOneWidget);
    expect(find.byKey(const ValueKey('botao-gravar-video')), findsOneWidget);
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

    expect(find.byKey(const ValueKey('botao-capturar-foto')), findsOneWidget);
    expect(find.byKey(const ValueKey('botao-gravar-video')), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('mantém o HUD escuro e mostra cronômetro e captura rápida', (
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
    expect(Theme.of(elapsedContext).brightness, Brightness.dark);
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
    expect(find.byKey(const ValueKey('quick-capture-photo')), findsOneWidget);
    expect(
      tester
          .widget<IconButton>(find.byKey(const ValueKey('quick-capture-photo')))
          .tooltip,
      'Foto rápida da via',
    );
    expect(tester.takeException(), isNull);
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
