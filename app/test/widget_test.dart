import 'package:flutter_test/flutter_test.dart';
import 'package:app/main.dart';

void main() {
  testWidgets('App se inicia correctamente', (WidgetTester tester) async {
    await tester.pumpWidget(const PaquexpressApp());
    expect(find.text('Paquexpress'), findsOneWidget);
  });
}