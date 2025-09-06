// lib/utils/pdf_generator.dart
import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../models/profile.dart';
import 'link_utils.dart';

class PdfGenerator {
  static Future<Uint8List> generate(Profile p) async {
    final pdf = pw.Document();
    final bgColor = PdfColor.fromInt(p.backgroundColorValue);

    final body = pw.TextStyle(fontSize: 14, color: PdfColors.white);
    final heading = pw.TextStyle(
      fontSize: 20,
      fontWeight: pw.FontWeight.bold,
      color: PdfColors.white,
    );
    final small = pw.TextStyle(fontSize: 12, color: PdfColors.white);

    pw.Widget _line(String emoji, String text, pw.TextStyle style) => pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('$emoji ', style: style),
            pw.Expanded(child: pw.Text(text, style: style)),
          ],
        );

    pw.Widget _linkLine(
      String emoji,
      String href,
      String label,
      pw.TextStyle style,
    ) =>
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('$emoji ', style: style),
            pw.UrlLink(destination: href, child: pw.Text(label, style: style)),
            pw.SizedBox(width: 8),
            pw.Text(href, style: style),
          ],
        );

    pw.Widget _contactsAndSocials(pw.Context context) {
      final w = context.page.pageFormat.availableWidth;
      final isWide = w > 460;

      final contactsCol = pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          _line('📍', singleLine(p.address), body),
          _linkLine('☎', 'tel:${normalizePhone(p.phone)}', 'Phone', body),
          _linkLine('✉️', ensureMailto(p.email), 'Email', body),
          _linkLine('🌐', normalizeUrl(p.website), 'Website', body),
          if (p.bankDetails.trim().isNotEmpty) pw.SizedBox(height: 8),
          if (p.bankDetails.trim().isNotEmpty)
            pw.Container(
              padding:
                  const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: pw.BoxDecoration(
                color: PdfColor.fromInt(0xB0000000),
                borderRadius: pw.BorderRadius.circular(20),
                border: pw.Border.all(color: PdfColors.white, width: 0.2),
              ),
              child: pw.Text(p.bankDetails, style: small),
            ),
        ],
      );

      final socials = [
        ['💬 WhatsApp', p.whatsapp],
        ['📘 Facebook', p.facebook],
        ['✖️ X/Twitter', p.xTwitter],
        ['▶️ YouTube', p.youtube],
        ['📷 Instagram', p.instagram],
        ['🎵 TikTok', p.tiktok],
        ['💼 LinkedIn', p.linkedin],
        ['👻 Snapchat', p.snapchat],
        ['📌 Pinterest', p.pinterest],
      ].where((e) => (e[1] ?? '').toString().trim().isNotEmpty).toList();

      final socialsCol = pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('— Social —', style: small),
          pw.SizedBox(height: 6),
          ...socials.map((s) => pw.UrlLink(
                destination: normalizeUrl(s[1]!),
                child: pw.Text('${s[0]}  ${normalizeUrl(s[1]!)}', style: body),
              )),
        ],
      );

      if (isWide) {
        return pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Expanded(child: contactsCol),
            pw.SizedBox(width: 24),
            pw.Expanded(child: socialsCol),
          ],
        );
      } else {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            contactsCol,
            pw.SizedBox(height: 16),
            socialsCol,
          ],
        );
      }
    }

    pdf.addPage(
      pw.Page(
        pageTheme: pw.PageTheme(
          margin: pw.EdgeInsets.zero,
          theme: pw.ThemeData.withFont(base: pw.Font.helvetica()),
        ),
        build: (ctx) => pw.Stack(
          children: [
            pw.Positioned.fill(child: pw.Container(color: bgColor)),
            pw.Padding(
              padding: const pw.EdgeInsets.all(24),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // Header (placeholder avatar)
                  pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      pw.Container(
                        width: 64,
                        height: 64,
                        decoration: pw.BoxDecoration(
                          shape: pw.BoxShape.circle,
                          color: PdfColors.white,
                        ),
                      ),
                      pw.SizedBox(width: 12),
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(p.name, style: heading),
                          pw.SizedBox(height: 4),
                          pw.Text(p.title, style: body),
                        ],
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 12),

                  // Dark translucent box for contacts/socials
                  pw.Container(
                    decoration: pw.BoxDecoration(
                      color: PdfColor.fromInt(0xB0000000),
                      borderRadius: pw.BorderRadius.circular(8),
                    ),
                    padding: const pw.EdgeInsets.all(12),
                    child: _contactsAndSocials(ctx),
                  ),

                  pw.SizedBox(height: 16),
                  if (p.about.trim().isNotEmpty)
                    pw.Text('— About —', style: small),
                  if (p.about.trim().isNotEmpty) pw.SizedBox(height: 6),
                  if (p.about.trim().isNotEmpty) pw.Text(p.about, style: body),

                  pw.SizedBox(height: 12),
                  pw.UrlLink(
                    destination: mapUrlFromAddress(p.address),
                    child: pw.Text(mapUrlFromAddress(p.address), style: small),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    return pdf.save();
  }
}
