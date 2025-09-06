// title=test/payload_guard_test.dart
import 'package:card_link_pro/models/profile.dart';
import 'package:card_link_pro/widgets/qr_share_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qr_flutter/qr_flutter.dart';

void main() {
  testWidgets('QR payload renders', (tester) async {
    final p = Profile(
      name: 'A' * 500,
      title: 'B' * 500,
      phone: '+44 123 456 789',
      email: 'long@example.com',
      website: '',
      address: 'C' * 500,
      story: '',
      bankDetails: '',
      backgroundAsset: 'assets/images/placeholders/background/bg2.jpg',
      avatarAsset: 'assets/images/alkhadi.png',
      backgroundColorValue: 0xFF111827,
      links: const {},
    );

    final qrKey = GlobalKey();
    final cardKey = GlobalKey();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: QrShareSheet(
            profile: p,
            avatarProvider: const AssetImage('assets/images/alkhadi.png'),
            shareLink: null,
            qrBoundary: qrKey,
            cardBoundary: cardKey,
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.byType(QrImageView), findsOneWidget);
  });
}
