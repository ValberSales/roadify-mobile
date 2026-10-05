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

    // 6. Verifica botão grande de capturar foto (registro de patologias na via)
    final botaoFoto = find.byKey(const ValueKey('botao-capturar-foto'));
    expect(botaoFoto, findsOneWidget);
    expect(find.text('TIRAR FOTO DA VIA'), findsOneWidget);
    expect(find.text('0 fotos'), findsOneWidget);

    // Toca no botão grande para registrar a foto #1
    await tester.ensureVisible(botaoFoto);
    await tester.tap(botaoFoto);
    await tester.pump();

    // Verifica que exibiu SnackBar de geotagging e contador atualizou para 1 foto
    expect(find.text('1 foto'), findsOneWidget);
    expect(find.textContaining('Foto #1 registrada com geotagging'), findsOneWidget);

    // Toca no botão grande novamente para registrar foto #2
    await tester.tap(botaoFoto);
    await tester.pump();
    expect(find.text('2 fotos'), findsOneWidget);

    // Abre os detalhes da Foto #1 tocando na miniatura/tag
    final chipFoto1 = find.textContaining('Foto #1');
    expect(chipFoto1, findsOneWidget);
    await tester.tap(chipFoto1);
    await tester.pumpAndSettle();

    expect(find.text('Foto #1 (Geotag)'), findsOneWidget);
    expect(find.textContaining('Latitude:'), findsOneWidget);
    expect(find.textContaining('Longitude:'), findsOneWidget);
    await tester.tap(find.text('Fechar'));
    await tester.pumpAndSettle();

    // 7. Verifica botão de finalizar coleta e diálogo de confirmação
    ScaffoldMessenger.of(tester.element(find.byType(Scaffold))).hideCurrentSnackBar();
    await tester.pump(const Duration(milliseconds: 300));

    final finalizarButton = find.text('Finalizar Coleta');
    expect(finalizarButton, findsOneWidget);
    await tester.ensureVisible(finalizarButton);
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(finalizarButton);
    await tester.pump();

    expect(find.text('Finalizar Coleta?'), findsOneWidget);
    expect(find.textContaining('Foram registradas 2 fotos com geotagging'), findsOneWidget);
    expect(find.text('Finalizar e Salvar'), findsOneWidget);

    // Confirma encerramento
    await tester.tap(find.text('Finalizar e Salvar'));
    await tester.pumpAndSettle();

    // A tela de gravação deve ter sido encerrada
    expect(find.text('Coleta em Andamento'), findsNothing);
  });
}
