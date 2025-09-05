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

    try {
      final bgBytes = await rootBundle.load(p.backgroundAsset);
      bgImg = pw.MemoryImage(bgBytes.buffer.asUint8List());
    } catch (_) {
      bgImg = null; // fallback: gradient block
    }

    final bodyText = pw.TextStyle(
      fontSize: 12,
      color: PdfColors.white,
    );

    final titleText = pw.TextStyle(
      fontSize: 16,
      fontWeight: pw.FontWeight.bold,
      color: PdfColors.white,
    );

    final chip = pw.BoxDecoration(
      color: PdfColor.fromInt(0xCC000000),
      borderRadius: pw.BorderRadius.circular(8),
    );

    pw.Widget linkLine(String label, String url) {
      final nu = normalizeUrl(url) ?? url;
      return pw.Padding(
        padding: const pw.EdgeInsets.symmetric(vertical: 2),
        child: pw.UrlLink(
          destination: nu,
          child: pw.Text('$label: $nu', style: bodyText),
        ),
      );
    }

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
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
                    decoration: pw.BoxDecoration(
                      gradient: pw.LinearGradient(
                        colors: [
                          PdfColor.fromInt(0xFF1F2937),
                          PdfColor.fromInt(0xFF0F172A),
                        ],
                        begin: pw.Alignment.topLeft,
                        end: pw.Alignment.bottomRight,
                      ),
                    ),
                  ),
                ),

              // Content box
              pw.Positioned(
                left: 28,
                right: 28,
                top: 40,
                child: pw.Container(
                  padding: const pw.EdgeInsets.all(16),
                  decoration: chip,
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(p.name, style: titleText),
                      if (p.title.isNotEmpty) pw.Text(p.title, style: bodyText),
                    ],
                  ),
                ),
              ),

              // Contact & links
              pw.Positioned(
                left: 28,
                right: 28,
                bottom: 40,
                child: pw.Container(
                  padding: const pw.EdgeInsets.all(16),
                  decoration: chip,
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      if (p.address.isNotEmpty)
                        pw.Text(p.address, style: bodyText),
                      if (p.phone.isNotEmpty)
                        pw.UrlLink(
                          destination: telUri(p.phone).toString(),
                          child: pw.Text('Phone: ${p.phone}', style: bodyText),
                        ),
                      if (p.email.isNotEmpty)
                        pw.UrlLink(
                          destination: mailtoUri(p.email).toString(),
                          child: pw.Text('Email: ${p.email}', style: bodyText),
                        ),
                      if (p.website.isNotEmpty) linkLine('Website', p.website),
                      ...p.links.entries.map((e) => linkLine(e.key, e.value)),
                    ],
                  ),
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
