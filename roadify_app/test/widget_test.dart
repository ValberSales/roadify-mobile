import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:roadify_app/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('tela de carregamento exibe logo e nome sem indicador', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: RoadifyLoadingScreen()));

    expect(find.byKey(const ValueKey('roadify-startup-logo')), findsOneWidget);
    expect(find.text('Roadify'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.byType(LinearProgressIndicator), findsNothing);
  });

  testWidgets('RoadifyApp abre sem atraso artificial e renderiza as 5 abas', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const RoadifyApp());
    await tester.pumpAndSettle();

    expect(find.text('Início'), findsOneWidget);
    expect(find.text('Coleta'), findsOneWidget);
    expect(find.text('Sensores'), findsOneWidget);
    expect(find.text('Dados'), findsOneWidget);
    expect(find.text('Config'), findsOneWidget);
    expect(find.text('Roadify'), findsOneWidget);
    expect(find.text('Iniciar Nova Vistoria'), findsOneWidget);
  });
}
