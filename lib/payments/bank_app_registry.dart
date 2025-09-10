// lib/payments/bank_app_registry.dart

class BankApp {
  final String name;
  final String androidPackage; // Android: launch/check presence
  final String iosAppStoreId; // iOS: fallback to App Store
  final String? iosScheme; // iOS public scheme (Revolut)
  final Uri? webHome; // Fallback website

  const BankApp({
    required this.name,
    required this.androidPackage,
    required this.iosAppStoreId,
    this.iosScheme,
    this.webHome,
  });
}

/// Use a runtime-immutable list so we can hold non-const `Uri` values
/// without compile-time const restrictions.
final List<BankApp> bankAppsUK = List.unmodifiable(<BankApp>[
  BankApp(
    name: 'Monzo',
    androidPackage: 'co.uk.getmondo',
    iosAppStoreId: '1052238659',
    webHome: Uri(scheme: 'https', host: 'monzo.com'),
  ),
  BankApp(
    name: 'Starling',
    androidPackage: 'com.starlingbank.android',
    iosAppStoreId: '956806430',
    webHome: Uri(scheme: 'https', host: 'www.starlingbank.com'),
  ),
  BankApp(
    name: 'Barclays',
    androidPackage: 'com.barclays.android.barclaysmobilebanking',
    iosAppStoreId: '536248734',
    webHome: Uri(scheme: 'https', host: 'www.barclays.co.uk'),
  ),
  BankApp(
    name: 'NatWest',
    androidPackage: 'com.rbs.mobile.android.natwest',
    iosAppStoreId: '334855322',
    webHome: Uri(scheme: 'https', host: 'www.natwest.com'),
  ),
  BankApp(
    name: 'Revolut',
    androidPackage: 'com.revolut.revolut',
    iosAppStoreId: '932493382',
    iosScheme: 'revolut',
    webHome: Uri(scheme: 'https', host: 'www.revolut.com'),
  ),
]);
