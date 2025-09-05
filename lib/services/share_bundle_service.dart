// title=lib/services/share_bundle_service.dart
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../models/profile.dart';
import '../utils/pdf_generator.dart';

class ShareBundleService {
  /// Capture any widget wrapped by a RepaintBoundary via its [key] into a PNG.
  static Future<Uint8List?> captureWidgetPng(
    GlobalKey key, {
    double pixelRatio = 3.0,
  }) async {
    // Wait until painted to avoid '!debugNeedsPaint'
    await Future.delayed(const Duration(milliseconds: 32));
    await WidgetsBinding.instance.endOfFrame;

    final ctx = key.currentContext;
    if (ctx == null) return null;
    final render = ctx.findRenderObject();
    if (render is! RenderRepaintBoundary) return null;

    try {
      final image = await render.toImage(pixelRatio: pixelRatio);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (_) {
      return null;
    }
  }

  static Future<File> _writeTemp(Uint8List bytes, String fileName) async {
    final dir = await getTemporaryDirectory();
    final f = File('${dir.path}/$fileName');
    await f.writeAsBytes(bytes, flush: true);
    return f;
  }

  static Future<void> shareImageFromKey(
    GlobalKey key, {
    String fileName = 'image.png',
    String? text,
  }) async {
    final bytes = await captureWidgetPng(key);
    if (bytes == null) return;
    final file = await _writeTemp(bytes, fileName);
    await Share.shareXFiles([XFile(file.path)], text: text);
  }

  /// Generate PDF and share it via platform share sheet.
  static Future<void> shareProfilePdf(Profile p, {String? text}) async {
    final bytes = await PdfGenerator.build(p);
    final file = await _writeTemp(bytes, 'CardLink_${p.name}.pdf');
    await Share.shareXFiles([XFile(file.path)], text: text ?? 'My CardLink');
  }

  /// Bundle → currently: just PDF (kept expand‑able).
  static Future<void> shareBundle({
    required Profile profile,
    GlobalKey? qrBoundary,
    GlobalKey? cardBoundary,
    String? shortLink,
    String? text,
  }) async {
    await shareProfilePdf(profile, text: text ?? 'My CardLink');
  }

  /// Copy a link to clipboard and optionally show a snackbar.
  static Future<void> copyLink(String link, {BuildContext? context}) async {
    await Clipboard.setData(ClipboardData(text: link));
    final ctx = context;
    if (ctx != null && ctx.mounted) {
      ScaffoldMessenger.of(ctx).showSnackBar(
        const SnackBar(content: Text('Link copied to clipboard')),
      );
    }
  }

  /// Build a vCard (VCF) for a Profile – used by tests and optional share.
  static List<int> buildVCard(Profile p) {
    final parts = p.name.trim().split(' ');
    final surname = parts.length > 1 ? parts.last : '';
    final given = parts.length > 1
        ? parts.sublist(0, parts.length - 1).join(' ')
        : parts.first;

    final buffer = StringBuffer()
      ..writeln('BEGIN:VCARD')
      ..writeln('VERSION:3.0')
      ..writeln('FN:${p.name}')
      ..writeln('N:$surname;$given;;;')
      ..writeln('TITLE:${p.title}')
      ..writeln('TEL;TYPE=CELL,VOICE:${p.phone}')
      ..writeln('EMAIL;TYPE=INTERNET:${p.email}')
      ..writeln('URL:${p.website}')
      ..writeln('ADR;TYPE=WORK:;;${p.address.replaceAll('\n', ' ')};;;;')
      ..writeln('NOTE:${p.story}')
      ..writeln('END:VCARD');

    return utf8.encode(buffer.toString());
  }
}
