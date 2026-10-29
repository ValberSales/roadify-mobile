import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:roadify_app/core/database/app_database.dart';
import 'package:roadify_app/core/theme/app_theme.dart';
import 'package:roadify_app/features/coleta/presentation/coleta_screen.dart';
import 'package:roadify_app/features/coleta/presentation/collection_orientation_setup_screen.dart';
import 'package:roadify_app/features/coleta/presentation/widgets/info_section_widget.dart';
import 'package:roadify_app/features/coleta/services/collection_preferences.dart';
import 'package:roadify_app/features/coleta/viewmodels/coleta_viewmodel.dart';
import 'package:roadify_app/features/coleta/viewmodels/persisted_coleta_viewmodel.dart';
import 'package:roadify_app/features/sensores/models/nivel_bolha_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('restores all collection values and sampling settings', () async {
    final preferences = CollectionPreferences();
    final configuration = ConfiguracaoColeta(
      sensoresSelecionados: {
        SensorColeta.acelerometro,
        SensorColeta.gps,
        SensorColeta.giroscopio,
        SensorColeta.camera,
        SensorColeta.audio,
      },
      taxaInercialHz: 250,
      taxaGpsHz: 6,
      intervaloMetros: 30.5,
      trecho: 'BR-101 km 10 ao 20',
      identificador: 'ensaio-2026-001',
      orientation: CollectionOrientation.horizontal,
      posture: CollectionPosture.lyingDown,
      calibrationOffsetX: 1.5,
      calibrationOffsetY: -2,
      levelingMode: BubbleDisplayMode.tubularT,
      isCalibrated: true,
      vehicleId: 7,
      odometroInicial: 15234.5,
      nomeColeta: 'BR-101 - ensaio-2026-001',
      sensoresOpcionais: const OptionalSensorSettings(
        gyroscopeFrequencyHz: 200,
        camera: CameraCaptureSettings(
          mediaType: CameraMediaType.photosAndVideos,
          facing: CameraFacing.front,
          automatic: true,
          interval: 3,
          intervalUnit: CaptureIntervalUnit.kilometers,
          videoDurationSeconds: 45,
        ),
        audio: AudioCaptureSettings(
          automatic: true,
          interval: 2,
          intervalUnit: CaptureIntervalUnit.hours,
          durationSeconds: 60,
        ),
      ),
    );

    await PersistedColetaViewModel(
      preferences,
    ).prosseguirParaGravacao(configuracao: configuration);
    final restored = await preferences.load();

    expect(restored, isNotNull);
    expect(restored!.trecho, configuration.trecho);
    expect(restored.identificador, configuration.identificador);
    expect(restored.vehicleId, configuration.vehicleId);
    expect(restored.odometroInicial, configuration.odometroInicial);
    expect(restored.taxaInercialHz, configuration.taxaInercialHz);
    expect(restored.taxaGpsHz, configuration.taxaGpsHz);
    expect(restored.intervaloMetros, configuration.intervaloMetros);
    expect(restored.sensoresSelecionados, configuration.sensoresSelecionados);
    expect(restored.sensoresOpcionais.gyroscopeFrequencyHz, 200);
    expect(restored.sensoresOpcionais.camera.facing, CameraFacing.front);
    expect(restored.sensoresOpcionais.camera.interval, 3);
    expect(restored.sensoresOpcionais.audio.durationSeconds, 60);
    expect(restored.orientation, CollectionOrientation.horizontal);
    expect(restored.posture, CollectionPosture.lyingDown);
    expect(restored.calibrationOffsetX, 1.5);
    expect(restored.calibrationOffsetY, -2);
    expect(restored.levelingMode, BubbleDisplayMode.tubularT);
    expect(restored.isCalibrated, isTrue);
  });

  testWidgets('edits the initial odometer without opening vehicle selection', (
    tester,
  ) async {
    final vehicle = Vehicle(
      id: 1,
      name: 'Veículo de teste',
      model: 'Modelo',
      licensePlate: 'ABC1234',
      defaultOdometer: 1234.5,
      year: 2020,
      isActive: true,
      createdAt: DateTime(2026),
    );
    final formKey = GlobalKey<FormState>();
    CollectionIdentification? identification;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: IdentificacaoSectionWidget(
                initialRoute: 'BR-101 km 10 ao 20',
                initialIdentifier: 'ensaio-001',
                initialVehicle: vehicle,
                initialOdometer: 1234.5,
                onChanged: (value) => identification = value,
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final odometerField = find.byKey(
      const ValueKey('collection-odometer-field'),
    );
    expect(odometerField, findsOneWidget);
    expect(
      tester.widget<TextFormField>(odometerField).controller!.text,
      '1234.5',
    );
    await tester.enterText(odometerField, '12345,6');
    await tester.pump();

    expect(formKey.currentState!.validate(), isTrue);
    expect(identification!.odometer, '12345,6');
    expect(identification!.vehicle!.id, vehicle.id);
  });

  testWidgets('prefills the collection form with the saved configuration', (
    tester,
  ) async {
    final preferences = CollectionPreferences();
    await preferences.save(
      ConfiguracaoColeta(
        sensoresSelecionados: {SensorColeta.acelerometro, SensorColeta.gps},
        taxaInercialHz: 250,
        taxaGpsHz: 6,
        intervaloMetros: 35,
        trecho: 'BR-262 km 20 ao 30',
        identificador: 'ensaio-2026-002',
        odometroInicial: 7654.5,
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: ColetaScreen(
          viewModel: MockColetaViewModel(),
          preferences: preferences,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      tester
          .widget<TextFormField>(
            find.byKey(const ValueKey('collection-route-field')),
          )
          .controller!
          .text,
      'BR-262 km 20 ao 30',
    );
    expect(
      tester
          .widget<TextFormField>(
            find.byKey(const ValueKey('collection-name-field')),
          )
          .controller!
          .text,
      'ensaio-2026-002',
    );
    expect(
      tester
          .widget<TextFormField>(find.byKey(const ValueKey('input-acc-custom')))
          .controller!
          .text,
      '250',
    );
    expect(
      tester
          .widget<TextFormField>(find.byKey(const ValueKey('input-gps-custom')))
          .controller!
          .text,
      '6',
    );
    expect(
      tester
          .widget<TextFormField>(
            find.byKey(const ValueKey('interval-meters-field')),
          )
          .controller!
          .text,
      '35.0',
    );
  });

  testWidgets('saves form and sensor changes before collection is started', (
    tester,
  ) async {
    final preferences = CollectionPreferences();

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: ColetaScreen(
          viewModel: MockColetaViewModel(),
          preferences: preferences,
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('collection-route-field')),
      'BR-381 km 2 ao 8',
    );
    await tester.enterText(
      find.byKey(const ValueKey('collection-name-field')),
      'ensaio-2026-004',
    );
    await tester.tap(find.byKey(const ValueKey('chip-acc-200')));
    final gpsFiveChip = find.byKey(const ValueKey('chip-gps-5'));
    await tester.ensureVisible(gpsFiveChip);
    await tester.tap(gpsFiveChip);
    await tester.enterText(
      find.byKey(const ValueKey('interval-meters-field')),
      '45',
    );
    await tester.pumpAndSettle();

    final saved = await preferences.load();
    expect(saved!.trecho, 'BR-381 km 2 ao 8');
    expect(saved.identificador, 'ensaio-2026-004');
    expect(saved.taxaInercialHz, 200);
    expect(saved.taxaGpsHz, 5);
    expect(saved.intervaloMetros, 45);
  });

  testWidgets('requires and returns sensor calibration before collection', (
    tester,
  ) async {
    final preferences = CollectionPreferences();
    ConfiguracaoColeta? result;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () async {
                result = await Navigator.of(context).push<ConfiguracaoColeta>(
                  MaterialPageRoute(
                    builder: (_) => CollectionOrientationSetupScreen(
                      configuracao: ConfiguracaoColeta(
                        sensoresSelecionados: {
                          SensorColeta.acelerometro,
                          SensorColeta.gps,
                        },
                        taxaInercialHz: 100,
                        taxaGpsHz: 5,
                        intervaloMetros: 20,
                        trecho: 'BR-262',
                        identificador: 'ensaio-003',
                        vehicleId: 1,
                      ),
                      preferences: preferences,
                    ),
                  ),
                );
              },
              child: const Text('Abrir nivelamento'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Abrir nivelamento'));
    await tester.pumpAndSettle();

    final continueButton = tester.widget<FilledButton>(
      find.byKey(const ValueKey('continue-to-recording')),
    );
    expect(continueButton.onPressed, isNull);

    final calibrateButton = find.byKey(
      const ValueKey('calibrate-before-recording'),
    );
    await tester.ensureVisible(calibrateButton);
    await tester.tap(calibrateButton);
    await tester.pump();
    expect(
      tester
          .widget<FilledButton>(
            find.byKey(const ValueKey('continue-to-recording')),
          )
          .onPressed,
      isNotNull,
    );
    final horizontalOption = find.text('Horizontal');
    await tester.ensureVisible(horizontalOption);
    await tester.tap(horizontalOption);
    final lyingDownOption = find.text('Deitado');
    await tester.ensureVisible(lyingDownOption);
    await tester.tap(lyingDownOption);
    await tester.tap(find.byKey(const ValueKey('continue-to-recording')));
    await tester.pumpAndSettle();

    expect(result, isNotNull);
    expect(result!.orientation, CollectionOrientation.horizontal);
    expect(result!.posture, CollectionPosture.lyingDown);
    expect(result!.isCalibrated, isTrue);
    expect(
      (await preferences.load())!.orientation,
      CollectionOrientation.horizontal,
    );
  });
}
