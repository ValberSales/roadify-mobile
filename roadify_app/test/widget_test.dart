import 'package:flutter_test/flutter_test.dart';
import 'package:roadify_app/main.dart';

void main() {
  testWidgets('RoadifyApp inicializa e renderiza a PillDockBar com 5 abas', (WidgetTester tester) async {
    await tester.pumpWidget(const RoadifyApp());
    await tester.pumpAndSettle();

    // Verifica se os atalhos do Pill Dock estão presentes
    expect(find.text('Início'), findsOneWidget);
    expect(find.text('Coleta'), findsOneWidget);
    expect(find.text('Sensores'), findsOneWidget);
    expect(find.text('Dados'), findsOneWidget);
    expect(find.text('Config'), findsOneWidget);

    // Verifica elementos da HomeScreen
    expect(find.text('Roadify'), findsOneWidget);
    expect(find.text('Iniciar Nova Vistoria'), findsOneWidget);
  });
}
