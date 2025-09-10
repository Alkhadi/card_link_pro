// lib/services/share_bundle_service.dart
import 'dart:typed_data'; // ByteData is defined here
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:pdf/pdf.dart';
// Inline PDF via `pdf` package to avoid missing method errors.
import 'package:pdf/widgets.dart' as pw;

// Keep using your Profile model.
import '../models/profile.dart';

class ShareBundle {
  final Uint8List pngImageBytes;
  final Uint8List pdfBytes;

  const ShareBundle({required this.pngImageBytes, required this.pdfBytes});
}

class ShareBundleService {
  static Future<ShareBundle> buildShareBundle({
    required GlobalKey captureKey,
    required Profile profile,
    double pixelRatio = 3.0,
  }) async {
    // Ensure the widget is painted before capture (helps avoid debugNeedsPaint)
    await Future<void>.delayed(const Duration(milliseconds: 1));
    await WidgetsBinding.instance.endOfFrame;

    final pngBytes = await _captureToPng(
      captureKey,
      pixelRatio: pixelRatio,
    );
    final pdfBytes = await _generatePdf(profile);
    return ShareBundle(pngImageBytes: pngBytes, pdfBytes: pdfBytes);
  }

  static Future<Uint8List> _captureToPng(
    GlobalKey key, {
    double pixelRatio = 3.0,
  }) async {
    final ctx = key.currentContext;
    if (ctx == null) {
      throw Exception('Capture failed: no context on the provided GlobalKey.');
    }

    final renderObject = ctx.findRenderObject();
    if (renderObject is! RenderRepaintBoundary) {
      throw Exception(
        'Capture failed: RenderObject is not a RenderRepaintBoundary. '
        'Wrap the widget with RepaintBoundary and pass its GlobalKey.',
      );
    }

    // Keep pixel ratio within a sensible range for quality vs. file size
    final double pr = pixelRatio.clamp(2.0, 4.0).toDouble();

    final ui.Image image = await renderObject.toImage(pixelRatio: pr);
    final ByteData? byteData =
        await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) {
      throw Exception('Failed to encode PNG bytes.');
    }
    return byteData.buffer.asUint8List();
  }

  /// Minimal inline PDF generator. Produces a simple single-page PDF.
  static Future<Uint8List> _generatePdf(Profile profile) async {
    final doc = pw.Document();

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (ctx) {
          return pw.Padding(
            padding: const pw.EdgeInsets.all(24),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'CardLink Pro',
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Text(
                  'Profile PDF',
                  style: pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
                ),
                pw.Divider(),
                pw.Text(
                  profile.toString(),
                  style: const pw.TextStyle(fontSize: 10),
                ),
              ],
            ),
          );
        },
      ),
    );

    return doc.save();
  }
}
