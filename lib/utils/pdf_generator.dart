// lib/utils/pdf_generator.dart
import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../models/profile.dart';
import '../services/link_utils.dart';

class PdfGenerator {
  /// Build a professional single-page PDF for the profile.
  static Future<Uint8List> build(Profile p) async {
    final doc = pw.Document();
    pw.ImageProvider? bgImg;

    // Load background (image or fallback color gradient)
    try {
      if (p.backgroundAsset.startsWith('color:')) {
        bgImg = null; // handled with solid color
      } else {
        final bgBytes = await rootBundle.load(p.backgroundAsset);
        bgImg = pw.MemoryImage(bgBytes.buffer.asUint8List());
      }
    } catch (_) {
      bgImg = null;
    }

    // Styles
    final bodyText = pw.TextStyle(
      fontSize: 14,
      color: PdfColors.white,
    );

    final titleText = pw.TextStyle(
      fontSize: 18,
      fontWeight: pw.FontWeight.bold,
      color: PdfColors.white,
    );

    pw.Widget chip(pw.Widget child) => pw.Container(
          padding: const pw.EdgeInsets.all(8),
          decoration: pw.BoxDecoration(
            color: PdfColor.fromInt(0xCC000000),
            borderRadius: pw.BorderRadius.circular(8),
          ),
          child: child,
        );

    pw.Widget linkLine(String label, String value, {String? url}) {
      final dest = url ?? normalizeUrl(value) ?? value;
      return pw.Padding(
        padding: const pw.EdgeInsets.symmetric(vertical: 2),
        child: pw.UrlLink(
          destination: dest,
          child: pw.Text('$label: $value', style: bodyText),
        ),
      );
    }

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.zero,
        build: (ctx) {
          return pw.Stack(
            children: [
              // Background
              if (bgImg != null)
                pw.Positioned.fill(
                  child: pw.FittedBox(
                    fit: pw.BoxFit.cover,
                    child: pw.Image(bgImg),
                  ),
                )
              else
                pw.Positioned.fill(
                  child: pw.Container(
                    color: PdfColor.fromInt(0xFF101010),
                  ),
                ),

              // Content
              pw.Padding(
                padding: const pw.EdgeInsets.all(24),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                  children: [
                    // Name + Title
                    chip(
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(p.name, style: titleText),
                          if (p.title.isNotEmpty)
                            pw.Text(p.title, style: bodyText),
                        ],
                      ),
                    ),
                    pw.SizedBox(height: 16),

                    // Phone + Email row
                    chip(
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          if (p.phone.isNotEmpty)
                            pw.UrlLink(
                              destination: telUri(p.phone).toString(),
                              child: pw.Text('📞 ${p.phone}', style: bodyText),
                            ),
                          if (p.email.isNotEmpty)
                            pw.UrlLink(
                              destination: mailtoUri(p.email).toString(),
                              child: pw.Text('✉️ ${p.email}', style: bodyText),
                            ),
                        ],
                      ),
                    ),
                    pw.SizedBox(height: 16),

                    // Address (separated, Google Maps)
                    if (p.address.isNotEmpty)
                      chip(
                        pw.UrlLink(
                          destination:
                              'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(p.address)}',
                          child: pw.Text('📍 ${p.address}', style: bodyText),
                        ),
                      ),
                    pw.SizedBox(height: 16),

                    // Website + Social links grid
                    if (p.website.isNotEmpty || p.links.isNotEmpty)
                      chip(
                        pw.Wrap(
                          spacing: 12,
                          runSpacing: 8,
                          children: [
                            if (p.website.isNotEmpty)
                              pw.UrlLink(
                                destination:
                                    normalizeUrl(p.website) ?? p.website,
                                child:
                                    pw.Text('🌐 ${p.website}', style: bodyText),
                              ),
                            ...p.links.entries.map(
                              (e) => pw.UrlLink(
                                destination: normalizeUrl(e.value) ?? e.value,
                                child: pw.Text(
                                  '${e.key}: ${e.value}',
                                  style: bodyText,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    pw.SizedBox(height: 16),

                    // Bank details
                    if (p.bankDetails.trim().isNotEmpty)
                      chip(
                        pw.Text('🏦 ${p.bankDetails}', style: bodyText),
                      ),
                    pw.SizedBox(height: 16),

                    // Story/About
                    if (p.story.trim().isNotEmpty)
                      chip(
                        pw.Text(p.story, style: bodyText),
                      ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );

    return doc.save();
  }
}
