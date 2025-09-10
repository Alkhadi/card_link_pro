import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/profile.dart';
import '../utils/link_utils.dart';

/// Provides methods to prepare and share the profile in various formats.
class ShareService {
  /// Returns a formatted, copyable text representation of the profile.
  /// Normalizes URLs (https://), email (mailto:), and builds a maps link.
  static String prettyText(Profile p) {
    final maps = mapUrlFromAddress(p.address);

    final b = StringBuffer();
    b.writeln(
        '_______________________________________________________________');
    b.writeln('CARDLINK PRO');
    b.writeln(
        '_______________________________________________________________');
    b.writeln('');
    b.writeln(p.name);
    b.writeln(p.title);
    b.writeln('');
    b.writeln('☎  ${p.phone}');
    b.writeln('✉️  ${ensureMailto(p.email)}');
    b.writeln('🌐  ${normalizeUrl(p.website)}');
    b.writeln('');
    b.writeln('📍 Address');
    b.writeln(p.address.trim());
    b.writeln(maps);
    b.writeln('');
    b.writeln('— Social —');

    void add(String emoji, String url) {
      if (url.trim().isEmpty) return;
      b.writeln('$emoji ${normalizeUrl(url)}');
    }

    add('💬 WhatsApp ', p.whatsapp);
    add('📘 Facebook ', p.facebook);
    add('✖️ X/Twitter', p.xTwitter);
    add('▶️ YouTube   ', p.youtube);
    add('📷 Instagram ', p.instagram);
    add('🎵 TikTok    ', p.tiktok);
    add('💼 LinkedIn  ', p.linkedin);
    add('👻 Snapchat  ', p.snapchat);
    add('📌 Pinterest ', p.pinterest);

    b.writeln('');
    b.writeln('🏦 Bank');
    final bank = p.bankDetails.trim().isEmpty
        ? 'Ac number: 93087283   Sc Code: 09-01-35'
        : p.bankDetails.trim();
    b.writeln(bank);

    if (p.about.trim().isNotEmpty) {
      b.writeln('');
      b.writeln('— About —');
      b.writeln(p.about.trim());
    }

    return b.toString();
  }

  /// Copies the formatted text to the clipboard and shows a snackbar.
  static Future<void> copyFormattedText(BuildContext context, Profile p) async {
    final text = prettyText(p);
    await Clipboard.setData(ClipboardData(text: text));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile text copied')),
      );
    }
  }

  /// Shares the formatted text via the platform share sheet.
  static Future<void> shareText(Profile p) async {
    final text = prettyText(p);
    await Share.share(
      text,
      subject: 'My CardLink Pro Profile',
    );
  }

  /// Shares via email with attachments (PDF & image). Falls back to mailto if necessary.
  static Future<void> shareEmailWithAttachments({
    required String recipientEmail,
    required Uint8List pdfBytes,
    required Uint8List pngBytes,
  }) async {
    final files = [
      XFile.fromData(pdfBytes,
          name: 'CardLink_Pro_Profile.pdf', mimeType: 'application/pdf'),
      XFile.fromData(pngBytes,
          name: 'CardLink_Pro_Profile.png', mimeType: 'image/png'),
    ];
    try {
      await Share.shareXFiles(
        files,
        text: 'My CardLink Pro profile attached.',
        subject: 'CardLink Pro — My Profile',
      );
    } catch (_) {
      final uri = Uri(
        scheme: 'mailto',
        path: recipientEmail,
        queryParameters: {
          'subject': 'CardLink Pro — My Profile',
          'body':
              'Please find my profile attached.\n\n(If not attached, reply and I\'ll resend.)'
        },
      );
      await launchUrl(uri);
    }
  }

  /// Shares a single image (PNG) via the platform share sheet.
  static Future<void> shareImage(Uint8List pngBytes) async {
    final file = XFile.fromData(
      pngBytes,
      name: 'CardLink_Pro_Profile.png',
      mimeType: 'image/png',
    );
    await Share.shareXFiles([file]);
  }

  /// Shares both PDF and PNG together.
  static Future<void> sharePdfAndImage({
    required Uint8List pdfBytes,
    required Uint8List pngBytes,
  }) async {
    final files = [
      XFile.fromData(pdfBytes,
          name: 'CardLink_Pro_Profile.pdf', mimeType: 'application/pdf'),
      XFile.fromData(pngBytes,
          name: 'CardLink_Pro_Profile.png', mimeType: 'image/png'),
    ];
    await Share.shareXFiles(
      files,
      subject: 'CardLink Pro — My Profile',
      text: 'My CardLink Pro profile attached.',
    );
  }

  /// Sends a short SMS text (implementation in ShareService.smsText).
  static Future<void> smsText(Profile p) async {
    final text = prettyText(p); // or a shorter SMS-optimized version
    await Share.share(text);
  }
}
