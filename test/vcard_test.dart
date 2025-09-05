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
      backgroundAsset: 'assets/images/placeholders/background/bg1.jpg',
      avatarAsset: 'assets/images/placeholders/profile/alkhadi.png',
    );
    final vcf = String.fromCharCodes(ShareBundleService.buildVCard(p));
    expect(vcf.contains('FN:Jane Doe'), true);
    expect(vcf.contains('EMAIL;TYPE=INTERNET:jane@example.com'), true);
  });
}
