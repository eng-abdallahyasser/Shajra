import 'package:flutter_test/flutter_test.dart';
import 'package:shajra/app.dart';

void main() {
  testWidgets('App should render without errors', (WidgetTester tester) async {
    await tester.pumpWidget(const ShajraApp());
    await tester.pumpAndSettle();

    expect(find.text('Shajra'), findsOneWidget);
  });
}
