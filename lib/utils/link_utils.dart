/// Normalizes a user-provided URL, ensuring it is prefixed with https:// if
/// missing. Returns the trimmed URL. If the input is empty, returns it
/// unchanged.
String normalizeUrl(String input) {
  final t = input.trim();
  if (t.isEmpty) return t;
  if (t.startsWith('http://') || t.startsWith('https://')) return t;
  return 'https://$t';
}

/// Normalizes a phone number by stripping all characters except digits and
/// leading plus sign. This ensures tel: URIs work across platforms.
String normalizePhone(String input) {
  final digits = input.replaceAll(RegExp(r'[^\d+]'), '');
  return digits;
}

/// Converts a multi-line address into a single-line string and constructs a
/// Google Maps search URL for that address. Newlines are replaced with spaces
/// and extra whitespace is collapsed.
String mapUrlFromAddress(String multiLineAddress) {
  final one = multiLineAddress
      .replaceAll('\n', ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
  final enc = Uri.encodeComponent(one);
  return 'https://www.google.com/maps/search/?api=1&query=$enc';
}

/// Returns a single-line version of the given string. Newlines become spaces
/// and extra whitespace is collapsed.
String singleLine(String s) =>
    s.replaceAll('\n', ' ').replaceAll(RegExp(r'\s+'), ' ').trim();

/// Ensure the given email is prefixed with `mailto:`. If the email is
/// already prefixed, returns it unchanged.
String ensureMailto(String email) => 'mailto:$email';
