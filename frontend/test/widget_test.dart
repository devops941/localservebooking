import 'package:flutter_test/flutter_test.dart';
import 'package:local_service_booking_mobileapp/main.dart';

void main() {
  testWidgets('App loads smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const LocalServiceApp());
    expect(find.byType(LocalServiceApp), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 500));
  });
}
