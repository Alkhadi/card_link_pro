import '../models/profile.dart';
import 'link_utils.dart';

/// Builds a vCard 3.0 representation of the profile.
///
/// Only basic fields (FN, TITLE, TEL, EMAIL, URL, ADR) are included,
/// ensuring compatibility with most contact apps. Additional fields can be
/// added later if needed.
String buildVCard(Profile p) {
  final sb = StringBuffer();
  sb.writeln('BEGIN:VCARD');
  sb.writeln('VERSION:3.0');
  sb.writeln('FN:${p.name}');
  sb.writeln('TITLE:${p.title}');
  sb.writeln('TEL;TYPE=CELL:${normalizePhone(p.phone)}');
  sb.writeln('EMAIL;TYPE=INTERNET:${p.email}');
  sb.writeln('URL:${normalizeUrl(p.website)}');
  sb.writeln('ADR;TYPE=HOME:;;${p.address.replaceAll('\n', '; ')}');
  sb.writeln('END:VCARD');
  return sb.toString();
}
