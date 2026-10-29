import 'dart:io';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:roadify_app/core/database/app_database.dart';
import 'package:roadify_app/features/dados/presentation/dados_screen.dart';
import 'package:roadify_app/features/dados/services/run_export_service.dart';
import 'package:roadify_app/features/dados/viewmodel/dados_viewmodel.dart';

void main() {
  testWidgets(
    'SP2-07: tocar em um ensaio abre o modal de detalhes com odômetro, coordenadas GPS, amostras e botão Fechar',
    (tester) async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(db.close);

      final runId = await db.runDao.insertRun(
        RunsTableCompanion.insert(
          title: const Value('PR-280 • Pato Branco'),
          recordedAt: Value(DateTime(2026, 10, 29, 10, 15)),
          endedAt: Value(DateTime(2026, 10, 29, 10, 45)),
          odometer: const Value(14500.0),
          distanceKm: const Value(18.5),
          durationSeconds: const Value(1800),
          accelerometerSampleCount: const Value(180000),
          gpsPointCount: const Value(1800),
          mediaCount: const Value(0),
        ),
      );

      await db.into(db.gpsPointsTable).insert(
        GpsPointsTableCompanion.insert(
          runId: runId,
          recordedAt: DateTime(2026, 10, 29, 10, 15),
          latitude: -26.22861,
          longitude: -52.67083,
        ),
      );
      await db.into(db.gpsPointsTable).insert(
        GpsPointsTableCompanion.insert(
          runId: runId,
          recordedAt: DateTime(2026, 10, 29, 10, 45),
          latitude: -26.19500,
          longitude: -52.61200,
        ),
      );

      final exportService = RunExportService(db);
      final viewModel = DadosViewModel(
        db.runDao,
        exportService,
        documentsDirectory: () async => Directory.systemTemp,
      );
      addTearDown(viewModel.dispose);

      await tester.pumpWidget(
        MaterialApp(home: DadosScreen(viewModel: viewModel)),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Verifica que a frase redundante foi removida e não há overflow ao lado do botão Ordenar
      expect(
        find.text('Toque em um ensaio para ver os detalhes'),
        findsNothing,
      );
      expect(find.text('Ordenar'), findsOneWidget);
      expect(tester.takeException(), isNull);

      // Verifica que o card do ensaio é exibido na lista
      final cardFinder = find.byKey(ValueKey('run-item-card-$runId'));
      expect(cardFinder, findsOneWidget);
      expect(find.text('PR-280 • Pato Branco'), findsOneWidget);

      // Toca no card para abrir o modal deslizante (bottom sheet)
      await tester.tap(cardFinder);
      await tester.pumpAndSettle();

      // Verifica conteúdo detalhado do modal (SP2-07)
      expect(
        find.byKey(const ValueKey('run-details-bottom-sheet')),
        findsOneWidget,
      );
      expect(find.text('Odômetro e Distância'), findsOneWidget);
      expect(find.text('14500,0 km'), findsOneWidget); // Odômetro inicial
      expect(find.text('14518,5 km'), findsOneWidget); // Odômetro final
      expect(find.text('18,5 km'), findsOneWidget); // Distância

      expect(find.text('Coordenadas GPS'), findsOneWidget);
      expect(find.text('-26.22861, -52.67083'), findsOneWidget);
      expect(find.text('-26.19500, -52.61200'), findsOneWidget);

      expect(find.text('Amostras Coletadas'), findsOneWidget);
      expect(find.text('180000'), findsOneWidget);
      expect(find.text('1800'), findsOneWidget);

      // Fecha o modal pelo botão Fechar
      await tester.tap(find.byKey(const ValueKey('close-run-details-button')));
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey('run-details-bottom-sheet')),
        findsNothing,
      );
    },
  );
}
