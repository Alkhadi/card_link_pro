// test/app_smoke_test.dart
import 'package:card_link_pro/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('App boots and shows CardLink Pro', (tester) async {
    await tester.pumpWidget(const CardLinkProApp());
    await tester.pumpAndSettle();
    expect(find.text('CardLink Pro'), findsOneWidget);
  });
}
