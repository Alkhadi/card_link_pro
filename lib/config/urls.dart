class AppUrls {
  // Replace USERNAME after you create your free GitHub Pages site (pay page).
  static const githubPayBase = 'https://USERNAME.github.io/pay';

  static String magicPayLink({String? amount, String? reference}) {
    final p = <String, String>{};
    if (amount != null && amount.isNotEmpty) p['amt'] = amount;
    if (reference != null && reference.isNotEmpty) p['ref'] = reference;
    final qs = p.isEmpty ? '' : '?${Uri(queryParameters: p).query}';
    return '$githubPayBase$qs';
  }
}
