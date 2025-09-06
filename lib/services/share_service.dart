// lib/services/share_service.dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/profile.dart';
import '../services/link_utils.dart';
import '../utils/pdf_generator.dart';
import 'share_bundle_service.dart';

class ShareService {
  static Future<void> shareAsText(BuildContext context, Profile p) async {
    final text = _prettyText(p);
    await Share.share(text, subject: 'My CardLink Pro Profile');
  }

  static Future<void> shareAsPdf(BuildContext context, Profile p) async {
    final bytes = await PdfGenerator.build(p);
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/cardlink_profile.pdf');
    await file.writeAsBytes(bytes, flush: true);
    await Share.shareXFiles([XFile(file.path)],
        text: 'My CardLink Pro Profile');
  }

  static Future<void> shareAsImage(
    BuildContext context,
    GlobalKey cardKey,
  ) async {
    final png = await ShareBundleService.captureWidgetPng(cardKey);
    if (png == null) return;
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/profile_card.png');
    await file.writeAsBytes(png, flush: true);
    await Share.shareXFiles([XFile(file.path)],
        text: 'My CardLink Pro Profile');
  }

  /// Send formatted text via SMS or email.
  static Future<void> sendAsTextToTargets({
    required BuildContext context,
    required Profile profile,
    String? phone,
    String? email,
  }) async {
    final text = _prettyText(profile);
    final phoneClean =
        (phone ?? profile.phone).replaceAll(RegExp(r'[^+\d]'), '');

    if (phoneClean.isNotEmpty) {
      final sms =
          Uri.parse('sms:$phoneClean?body=${Uri.encodeComponent(text)}');
      if (await canLaunchUrl(sms)) {
        await launchUrl(sms, mode: LaunchMode.externalApplication);
      }
    }

    if ((email ?? '').trim().isNotEmpty) {
      final mail = mailtoUri(email!.trim(),
          subject: 'My CardLink Pro Profile', body: text);
      if (await canLaunchUrl(mail)) {
        await launchUrl(mail, mode: LaunchMode.externalApplication);
      }
    }
  }

  /// Send PDF (and attach to email if provided).
  static Future<void> sendPdfToTargets({
    required BuildContext context,
    required Profile profile,
    String? phone,
    String? email,
  }) async {
    final bytes = await PdfGenerator.build(profile);
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/cardlink_profile.pdf');
    await file.writeAsBytes(bytes, flush: true);

    await Share.shareXFiles([XFile(file.path)],
        text: 'My CardLink Pro Profile');

    if ((email ?? '').trim().isNotEmpty) {
      final mail = mailtoUri(email!.trim(),
          subject: 'My CardLink Pro Profile', body: 'See attached PDF.');
      if (await canLaunchUrl(mail)) {
        await launchUrl(mail, mode: LaunchMode.externalApplication);
      }
    }
  }

  /// Nicely formatted plain-text profile with all fields.
  static String _prettyText(Profile p) {
    final buf = StringBuffer()
      ..writeln('════════════════════════════════')
      ..writeln('           CARDLINK PRO')
      ..writeln('════════════════════════════════')
      ..writeln(p.name)
      ..writeln(p.title)
      ..writeln()
      ..writeln('📞  ${p.phone}')
      ..writeln('✉️  ${p.email}')
      ..writeln('🌐  ${p.website}')
      ..writeln()
      ..writeln('📍 Address')
      ..writeln(p.address)
      ..writeln();

    if (p.bankDetails.trim().isNotEmpty) {
      buf
        ..writeln('🏦 Bank')
        ..writeln(p.bankDetails)
        ..writeln();
    }

    if (p.links.isNotEmpty) {
      buf.writeln('— Social —');
      for (final entry in p.links.entries) {
        buf.writeln('• ${entry.key}: ${entry.value}');
      }
      buf.writeln();
    }

    if (p.story.trim().isNotEmpty) {
      buf
        ..writeln('— About —')
        ..writeln(p.story)
        ..writeln();
    }

    buf.writeln('Sent from CardLink Pro');
    return buf.toString();
  }
}
