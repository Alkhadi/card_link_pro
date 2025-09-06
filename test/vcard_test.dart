// title=test/vcard_test.dart
import 'package:card_link_pro/models/profile.dart';
import 'package:card_link_pro/services/share_bundle_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('vCard contains essential fields', () {
    final p = Profile(
      name: 'Jane Doe',
      title: 'Engineer',
      phone: '+441234567890',
      email: 'jane@example.com',
      website: 'example.com',
      address: '1 Main St',
      story: '',
      bankDetails: '',
      backgroundAsset: 'assets/images/placeholders/background/bg2.jpg',
      avatarAsset: 'assets/images/alkhadi.png',
      backgroundColorValue: 0xFF111827,
      links: const {},
    );
    final vcf = String.fromCharCodes(ShareBundleService.buildVCard(p));
    expect(vcf.contains('FN:Jane Doe'), isTrue);
    expect(vcf.contains('EMAIL;TYPE=INTERNET:jane@example.com'), isTrue);
  });
}
