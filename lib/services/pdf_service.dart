import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/services.dart' show rootBundle;

import '../models/profile.dart';
import 'qr_service.dart';

/// Builds a richly formatted PDF containing profile information, an
/// embedded QR code with avatar and an optional background image or
/// colour.  All contact and social details are rendered as
/// tappable links where appropriate to improve usability on mobile PDF
/// viewers.  Bank details are shown as plain text alongside other
/// information.  The generated file is written to the temporary
/// directory and returned as a [File].
class PdfService {
  static Future<File> buildProfilePdf({required Profile profile}) async {
    final pdf = pw.Document();

    // Generate QR code with avatar overlay.  If the profile has a
    // website defined it is used as the QR payload, otherwise the
    // entire profile is serialised to JSON.  This call returns PNG
    // bytes which are embedded directly into the PDF below.
    final String qrData = profile.website.isNotEmpty
        ? profile.website
        : profile.toJson();
    final Uint8List qrBytes = await QrService.generateQrWithAvatar(
      qrData,
      avatarPath: profile.avatarPath,
      size: 800,
    );
    final pw.ImageProvider qrImage = pw.MemoryImage(qrBytes);

    // Prepare background decoration.  If a background path exists we
    // attempt to load it; if it fails or is missing we fall back to
    // using the provided background colour.  When neither is
    // available a light grey is used.
    // Use BoxDecoration for the PDF container backgrounds.  The generic
    // Decoration type is not available in the pdf package API, so we
    // explicitly use BoxDecoration here.
    pw.BoxDecoration backgroundDecoration;
    if (profile.backgroundPath != null) {
      try {
        final bytes = profile.backgroundPath!.startsWith('assets/')
            ? (await rootBundle.load(profile.backgroundPath!)).buffer.asUint8List()
            : await File(profile.backgroundPath!).readAsBytes();
        backgroundDecoration = pw.BoxDecoration(
          image: pw.DecorationImage(
            image: pw.MemoryImage(bytes),
            fit: pw.BoxFit.cover,
          ),
        );
      } catch (_) {
        backgroundDecoration = pw.BoxDecoration(
          color: profile.backgroundColor != null
              ? PdfColor.fromInt(profile.backgroundColor!.value)
              : PdfColors.grey200,
        );
      }
    } else {
      backgroundDecoration = pw.BoxDecoration(
        color: profile.backgroundColor != null
            ? PdfColor.fromInt(profile.backgroundColor!.value)
            : PdfColors.grey200,
      );
    }

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) {
          return pw.Container(
            decoration: backgroundDecoration,
            // Do not use const here; pdf package does not support constant
            // EdgeInsets in this context.
            padding: pw.EdgeInsets.all(24),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(profile.fullName,
                    style: pw.TextStyle(
                      fontSize: 20,
                      fontWeight: pw.FontWeight.bold,
                    )),
                if (profile.role.isNotEmpty) pw.Text(profile.role),
                pw.SizedBox(height: 16),
                _row('Address', profile.address),
                _linkRow('Phone', 'tel:${profile.phone}', profile.phone),
                _linkRow('Email', 'mailto:${profile.email}', profile.email),
                _linkRow('Website', _ensureHttp(profile.website), profile.website),
                if (profile.wellbeingLink.isNotEmpty)
                  _linkRow('Wellbeing', _ensureHttp(profile.wellbeingLink),
                      profile.wellbeingLink),
                pw.SizedBox(height: 16),
                _row('Sort Code', profile.bankSortCode),
                _row('Account Number', profile.bankAccountNumber),
                pw.SizedBox(height: 24),
                pw.Text(
                  'Scan to open:',
                  style: pw.TextStyle(fontSize: 12),
                ),
                pw.SizedBox(height: 8),
                pw.Container(
                  width: 200,
                  height: 200,
                  child: pw.Image(qrImage, fit: pw.BoxFit.contain),
                ),
              ],
            ),
          );
        },
      ),
    );

    final dir = await getTemporaryDirectory();
    final file = File(
        '${dir.path}/CardLink-Pro-${DateTime.now().millisecondsSinceEpoch}.pdf');
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  static pw.Widget _row(String label, String value) => pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(width: 100, child: pw.Text('$label:')),
          pw.Expanded(child: pw.Text(value)),
        ],
      );

  static pw.Widget _linkRow(String label, String url, String text) => pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(width: 100, child: pw.Text('$label:')),
          pw.UrlLink(
            destination: url,
            child: pw.Text(
              text,
              // Do not use const; constant expressions are not supported by the
              // pdf widgets library in this context.
              style: pw.TextStyle(color: PdfColors.blue),
            ),
          ),
        ],
      );

  /// Normalises a URL by adding an implicit https prefix if missing.  The
  /// PDF library will throw if a URL is invalid; this helper ensures
  /// external links always include a scheme.
  static String _ensureHttp(String input) {
    final t = input.trim();
    if (t.startsWith('http://') || t.startsWith('https://')) return t;
    return 'https://$t';
  }
}
