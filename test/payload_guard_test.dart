import 'package:card_link_pro/widgets/qr_share_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qr_flutter/qr_flutter.dart';

void main() {
  testWidgets('QrImageView renders', (tester) async {
    final key = GlobalKey();
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SizedBox(),
        ),
      ),
    );
    // The QrShareSheet uses QrImageView inside; we instantiate it to check.
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: QrShareSheet(captureKey: key),
        ),
      ),
    );
    await tester.pumpAndSettle(const Duration(milliseconds: 300));
    expect(find.byType(QrImageView), findsOneWidget);
  });
}
