// test/link_utils_test.dart
import 'package:card_link_pro/services/link_utils.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('normalizeUrl adds https and validates', () {
    expect(normalizeUrl('example.com'), 'https://example.com');
    expect(normalizeUrl('https://flutter.dev'), 'https://flutter.dev');
    expect(isValidUrl('not a url'), false);
  });
}
