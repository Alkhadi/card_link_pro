import 'dart:typed_data';

import 'package:barcode/barcode.dart' as bc;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../models/profile.dart';
import '../payments/pay_utils.dart';

/// Generates a single-page A4 PDF of the profile. Links are clickable.
/// - Phone: tel:+E164
/// - Email: mailto:
/// - Web: https://
/// - Pay: Universal link (cardlink.pro/pay)
/// - EPC QR shown if IBAN available
class PdfGenerator {
  static Future<Uint8List> build(Profile p) async {
    final pdf = pw.Document();

    final payLink = buildPayUniversalLink(
      name: p.name,
      sortCode: _scFromBank(p.bankDetails),
      accountNumber: _accFromBank(p.bankDetails),
      iban: _ibanFromBank(p.bankDetails),
      bic: _bicFromBank(p.bankDetails),
    );

    // Optional EPC QR if IBAN present
    final iban = _ibanFromBank(p.bankDetails);
    final epcText = (iban != null && iban.isNotEmpty)
        ? buildEpcQrText(
            name: p.name,
            iban: iban,
            bic: _bicFromBank(p.bankDetails),
            amountEur: null,
            reference: null,
          )
        : null;

    pw.Widget? _epcQr() {
      if (epcText == null) return null;
      final qr = bc.Barcode.qrCode();
      return pw.BarcodeWidget(
        barcode: qr,
        data: epcText,
        width: 120,
        height: 120,
        drawText: false,
      );
    }

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (ctx) {
          return pw.Padding(
            padding: const pw.EdgeInsets.all(24),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(p.name,
                    style: pw.TextStyle(
                        fontSize: 20, fontWeight: pw.FontWeight.bold)),
                if (p.title.isNotEmpty) pw.Text(p.title),
                pw.SizedBox(height: 12),

                // Contacts
                pw.Text('☎ ${p.phone}'),
                _linkText('✉ ${p.email}', 'mailto:${p.email}'),
                _linkText('🌐 ${p.website}', _ensureHttps(p.website)),
                pw.SizedBox(height: 12),

                pw.Text('📍 Address'),
                pw.Text(p.address),
                pw.SizedBox(height: 12),

                // Socials
                pw.Text('— Social —'),
                ..._socialList(p),
                pw.SizedBox(height: 12),

                // Bank
                pw.Text('🏦 Bank'),
                pw.Text(_bankLine(p.bankDetails)),
                pw.SizedBox(height: 4),
                _linkText('Pay link', payLink.toString()),
                pw.SizedBox(height: 8),
                if (_epcQr() != null)
                  pw.Row(
                    children: [
                      pw.Text('EPC QR  (SEPA transfers)'),
                      pw.SizedBox(width: 16),
                      _epcQr()!,
                    ],
                  ),
              ],
            ),
          );
        },
      ),
    );

    return pdf.save();
  }

  static pw.Widget _linkText(String label, String url) {
    return pw.UrlLink(
      destination: url,
      child: pw.Text(label,
          style: const pw.TextStyle(decoration: pw.TextDecoration.underline)),
    );
  }

  static String _ensureHttps(String url) {
    final t = url.trim();
    if (t.startsWith('http://') || t.startsWith('https://')) return t;
    return 'https://$t';
  }

  static List<pw.Widget> _socialList(Profile p) {
    final items = <String>[
      p.whatsapp,
      p.facebook,
      p.xTwitter,
      p.youtube,
      p.instagram,
      p.tiktok,
      p.linkedin,
      p.snapchat,
      p.pinterest,
    ];
    final labels = <String>[
      '💬 WhatsApp',
      '📘 Facebook',
      '✖ X/Twitter',
      '▶ YouTube',
      '📷 Instagram',
      '🎵 TikTok',
      '💼 LinkedIn',
      '👻 Snapchat',
      '📌 Pinterest',
    ];

    final out = <pw.Widget>[];
    for (var i = 0; i < items.length; i++) {
      final u = items[i].trim();
      if (u.isEmpty) continue;
      out.add(_linkText('${labels[i]}', _ensureHttps(u)));
    }
    return out;
  }

  static String _bankLine(String bankDetails) => bankDetails.trim().isEmpty
      ? 'Ac number: 93087283   Sc Code: 09-01-35'
      : bankDetails.trim();

  static String? _ibanFromBank(String bankDetails) {
    final m = RegExp(r'IBAN[:\s]*([A-Z0-9]+)', caseSensitive: false)
        .firstMatch(bankDetails);
    return m?.group(1);
  }

  static String? _bicFromBank(String bankDetails) {
    final m = RegExp(r'(BIC|SWIFT)[:\s]*([A-Z0-9]+)', caseSensitive: false)
        .firstMatch(bankDetails);
    return m?.group(2);
  }

  static String _scFromBank(String bankDetails) {
    final m =
        RegExp(r'(Sc|Sort(?:\s+)?Code)[:\s]*([0-9\-]+)', caseSensitive: false)
            .firstMatch(bankDetails);
    return (m?.group(2) ?? '00-00-00').replaceAll(' ', '');
  }

  static String _accFromBank(String bankDetails) {
    final m = RegExp(r'(Ac|Account(?:\s+)?(No|Number)?)[:\s]*([0-9]+)',
            caseSensitive: false)
        .firstMatch(bankDetails);
    return m?.group(3) ?? '00000000';
  }
}
