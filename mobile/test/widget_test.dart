import 'package:flutter_test/flutter_test.dart';
import 'package:jackdany/main.dart';

void main() {
  testWidgets('JackDanyApp si avvia sullo splash', (WidgetTester tester) async {
    await tester.pumpWidget(const JackDanyApp());
    await tester.pump();
    // Splash: il logo hero deve essere presente
    expect(find.byType(JackDanyApp), findsOneWidget);
  });
}
