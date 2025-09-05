// title=lib/services/share_service.dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

import '../models/profile.dart';
import '../utils/pdf_generator.dart';
import 'share_bundle_service.dart';

class ShareService {
  static Future<void> shareAsText(BuildContext context, Profile p) async {
    final text = _prettyText(p);
    await Share.share(text, subject: 'My contact');
  }

  static Future<void> shareAsPdf(BuildContext context, Profile p) async {
    final bytes = await PdfGenerator.build(p);
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/cardlink_profile.pdf');
    await file.writeAsBytes(bytes, flush: true);
    await Share.shareXFiles([XFile(file.path)], text: 'My CardLink');
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
    await Share.shareXFiles([XFile(file.path)], text: 'My profile card');
  }

  static Future<void> shareVCard(BuildContext context, Profile p) async {
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/profile_contact.vcf');
    await file.writeAsBytes(ShareBundleService.buildVCard(p), flush: true);
    await Share.shareXFiles([XFile(file.path)],
        text: 'Here are my contact details');
  }

  /// A simple QR dialog that encodes the website (or a MECARD fallback).
  static Future<void> showQrDialog(
    BuildContext context,
    Profile p,
  ) async {
    final data = (p.website.trim().isNotEmpty)
        ? (p.website.startsWith(RegExp(r'^[a-z]+://'))
            ? p.website
            : 'https://${p.website}')
        : 'MECARD:N:${p.name};TEL:${p.phone};EMAIL:${p.email};ADR:${p.address.replaceAll('\n', ' ')};;';

    if (!context.mounted) return;
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => AlertDialog(
        title: const Text('Scan to open'),
        content: SizedBox(
          width: 240,
          height: 240,
          child: Center(
            child: QrImageView(data: data, version: QrVersions.auto, size: 240),
          ),
        ),
      ),
    );
  }

  // ----- Utilities -----

  static String _prettyText(Profile p) {
    final buf = StringBuffer()
      ..writeln('════════════════════════════════')
      ..writeln('            CARDLINK PRO')
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
      ..writeln()
      ..writeln('— Social —');

    for (final entry in p.links.entries) {
      buf.writeln('• ${entry.key}: ${entry.value}');
    }

    if (p.story.trim().isNotEmpty) {
      buf
        ..writeln()
        ..writeln('— About —')
        ..writeln(p.story);
    }

    buf
      ..writeln()
      ..writeln('Sent from CardLink Pro');

    return buf.toString();
  }
}
