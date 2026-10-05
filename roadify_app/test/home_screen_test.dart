import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:roadify_app/core/theme/theme_controller.dart';
import 'package:roadify_app/features/home/presentation/home_screen.dart';

void main() {
  testWidgets('HomeScreen: remove escala de qualidade e card de nuvem, exibe últimas coletas com sync no card', (tester) async {
    final controller = ThemeController();

    await tester.pumpWidget(
      MaterialApp(
        home: HomeScreen(
          themeController: controller,
          onStartCollection: () {},
        ),
      ),
    );

    // 1. Escala de qualidade do pavimento DEVE estar removida
    expect(find.text('Escala de Qualidade do Pavimento'), findsNothing);

    // 2. Card antigo de sincronização em nuvem DEVE estar removido
    expect(find.text('Sincronização em Nuvem'), findsNothing);

    // 3. Seção "Últimas Coletas" DEVE estar presente
    expect(find.text('Últimas Coletas'), findsOneWidget);

    // 4. Cards de coletas com dados essenciais
    expect(find.text('BR-101 • Trecho Norte'), findsOneWidget);
    expect(find.text('Av. Paulista • Leste'), findsOneWidget);

    // 5. Ícones de nuvem de sincronização nos cards
    // 2 já sincronizados (nuvem com check) e 1 pendente (nuvem upload)
    expect(find.byIcon(Icons.cloud_done_rounded), findsNWidgets(2));
    expect(find.byIcon(Icons.cloud_upload_outlined), findsOneWidget);

    // 6. Clica no botão de sincronizar do card pendente
    final syncButtonFinder = find.byIcon(Icons.cloud_upload_outlined);
    await tester.ensureVisible(syncButtonFinder);
    await tester.tap(syncButtonFinder);
    await tester.pump();

    // Verifica que exibiu SnackBar de sincronização concluída
    expect(find.textContaining('sincronizado com a nuvem com sucesso!'), findsOneWidget);

    // Agora todos os 3 cards devem estar sincronizados
    await tester.pump();
    expect(find.byIcon(Icons.cloud_done_rounded), findsNWidgets(3));
  });

  testWidgets('HomeScreen: card de armazenamento não transborda (sem overflow) em tela de celular estreita (320px)', (tester) async {
    tester.view.physicalSize = const Size(320 * 2.0, 640 * 2.0);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final controller = ThemeController();

    await tester.pumpWidget(
      MaterialApp(
        home: HomeScreen(
          themeController: controller,
          onStartCollection: () {},
        ),
      ),
    );

    // Renderiza e verifica que os textos estão presentes sem estourar overflow
    expect(find.text('Armazenamento do Aparelho'), findsOneWidget);
    expect(find.text('143,3 MB usados'), findsOneWidget);
    expect(find.text('42 GB disponíveis'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
