import 'package:flutter_test/flutter_test.dart';
import 'package:aerolog_4342511014/main.dart';

void main() {
  testWidgets('AeroLog app loads splash screen', (WidgetTester tester) async {
    await tester.pumpWidget(const AeroLogApp());

    expect(find.text('AeroLog'), findsOneWidget);
    expect(find.text('Mulai Sekarang'), findsOneWidget);
  });
}
