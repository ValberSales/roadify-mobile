import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:roadify_app/core/theme/app_theme.dart';
import 'package:roadify_app/features/coleta/presentation/gravacao_screen.dart';
import 'package:roadify_app/features/coleta/viewmodels/coleta_viewmodel.dart';

void main() {
  testWidgets('GravacaoScreen exibe parâmetros, telemetria, osciloscópio e finalização', (tester) async {
    final configuracao = ConfiguracaoColeta(
      sensoresSelecionados: {
        SensorColeta.acelerometro,
        SensorColeta.gps,
        SensorColeta.giroscopio,
      },
      taxaInercialHz: 200,
      taxaGpsHz: 10,
      intervaloMetros: 25.0,
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: GravacaoScreen(configuracao: configuracao),
      ),
    );

    // 1. Verifica status GRAVANDO e título
    expect(find.text('Coleta em Andamento'), findsOneWidget);
    expect(find.text('GRAVANDO'), findsOneWidget);

    // 2. Verifica tempo decorrido
    expect(find.text('TEMPO DECORRIDO'), findsOneWidget);

    // 3. Verifica parâmetros selecionados
    expect(find.text('200 Hz'), findsOneWidget);
    expect(find.text('10 Hz'), findsOneWidget);
    expect(find.text('25 m'), findsOneWidget);
    expect(find.text('Acelerômetro'), findsNWidgets(2));
    expect(find.text('GPS'), findsOneWidget);
    expect(find.text('Giroscópio'), findsOneWidget);

    // 4. Verifica armazenamento e temperatura
    expect(find.text('Arquivo / Espaço'), findsOneWidget);
    expect(find.text('Temperatura'), findsOneWidget);
    expect(find.textContaining('°C'), findsOneWidget);
    expect(find.textContaining('% livre'), findsOneWidget);

    // 5. Verifica gráfico ao vivo do acelerômetro
    expect(find.text('Acelerômetro ao Vivo'), findsOneWidget);

    // 6. Verifica botão de finalizar coleta e diálogo de confirmação
    final finalizarButton = find.text('Finalizar Coleta');
    expect(finalizarButton, findsOneWidget);
    await tester.ensureVisible(finalizarButton);
    await tester.tap(finalizarButton);
    await tester.pump();

    expect(find.text('Finalizar Coleta?'), findsOneWidget);
    expect(find.text('Finalizar e Salvar'), findsOneWidget);

    // Confirma encerramento
    await tester.tap(find.text('Finalizar e Salvar'));
    await tester.pumpAndSettle();

    // A tela de gravação deve ter sido encerrada
    expect(find.text('Coleta em Andamento'), findsNothing);
  });
}
