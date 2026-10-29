import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:roadify_app/core/l10n/locale_controller.dart';
import 'package:roadify_app/core/theme/theme_controller.dart';
import 'package:roadify_app/features/auth_config/presentation/config_screen.dart';
import 'package:roadify_app/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets(
    'ConfigScreen: seletor de temas expande e centraliza no card, e alterna tema',
    (tester) async {
      tester.view.physicalSize = const Size(1080, 1920); // 360 x 640 @ 3x
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final controller = ThemeController();

      await tester.pumpWidget(
        MaterialApp(home: ConfigScreen(themeController: controller)),
      );

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
    },
  );

  testWidgets(
    'SP2-08: ConfigScreen abre tela de gestão de veículos e altera idioma (i18n)',
    (tester) async {
      final themeController = ThemeController();
      final localeController = LocaleController();
      addTearDown(themeController.dispose);
      addTearDown(localeController.dispose);

      await tester.pumpWidget(
        ListenableBuilder(
          listenable: localeController,
          builder: (context, _) {
            return MaterialApp(
              locale: localeController.locale,
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: LocaleController.supportedLocales,
              home: ConfigScreen(
                themeController: themeController,
                localeController: localeController,
              ),
            );
          },
        ),
      );
      await tester.pumpAndSettle();

      // 1. Verifica link para tela de Gestão de Veículos
      final vehiclesTile = find.byKey(
        const ValueKey('config-manage-vehicles-tile'),
      );
      await tester.ensureVisible(vehiclesTile);
      await tester.tap(vehiclesTile);
      await tester.pumpAndSettle();

      expect(find.text('Gestão de Veículos'), findsOneWidget);
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();

      // 2. Verifica seletor de idioma e internacionalização (PT -> EN)
      final languageTile = find.byKey(
        const ValueKey('config-system-language-tile'),
      );
      await tester.ensureVisible(languageTile);
      await tester.tap(languageTile);
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('language-option-en')));
      await tester.pumpAndSettle();

      expect(localeController.locale.languageCode, equals('en'));
      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('Default Vehicle'), findsOneWidget);
      expect(find.text('System Language'), findsOneWidget);
    },
  );
}
