import 'package:card_link_pro/models/profile.dart';
import 'package:card_link_pro/utils/vcard.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('vCard contains FN and EMAIL', () {
    final p = Profile.defaultProfile();
    final v = buildVCard(p);
    expect(v.contains('FN:${p.name}'), true);
    expect(v.contains('EMAIL;TYPE=INTERNET:${p.email}'), true);
  });
}
