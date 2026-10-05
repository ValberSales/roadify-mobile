import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:roadify_app/core/theme/theme_controller.dart';
import 'package:roadify_app/features/auth_config/presentation/config_screen.dart';

void main() {
  testWidgets('ConfigScreen: seletor de temas expande e centraliza no card, e alterna tema', (tester) async {
    tester.view.physicalSize = const Size(1080, 1920); // 360 x 640 @ 3x
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final controller = ThemeController();

    await tester.pumpWidget(MaterialApp(
      home: ConfigScreen(themeController: controller),
    ));

    final segmentedButtonFinder = find.byType(SegmentedButton<ThemeMode>);
    expect(segmentedButtonFinder, findsOneWidget);

    // O container do card tem padding 20 horizontal no ListView, border de 1px em cada lado e 16 de padding interno.
    // 360 - (20 * 2) - (1 * 2) - (16 * 2) = 286.
    final segmentedButtonSize = tester.getSize(segmentedButtonFinder);
    expect(segmentedButtonSize.width, equals(286.0));

    // Testa alternância de tema ao clicar nos botões
    await tester.tap(find.text('Escuro'));
    await tester.pumpAndSettle();
    expect(controller.themeMode, equals(ThemeMode.dark));

    await tester.tap(find.text('Sistema'));
    await tester.pumpAndSettle();
    expect(controller.themeMode, equals(ThemeMode.system));

    await tester.tap(find.text('Claro'));
    await tester.pumpAndSettle();
    expect(controller.themeMode, equals(ThemeMode.light));
  });
}
