// lib/services/export_service.dart
// Capture any widget behind a GlobalKey into a PNG file + temp file helpers.

import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart'
    show GlobalKey; // <-- needed for GlobalKey
import 'package:path_provider/path_provider.dart';

class ExportService {
  static Future<File?> captureToPng(
    dynamic key, {
    double pixelRatio = 3.0,
    String filenamePrefix = 'capture',
  }) async {
    if (key is! GlobalKey) return null;
    final ctx = key.currentContext;
    if (ctx == null) return null;

    // Give the frame time to paint
    await Future<void>.delayed(const Duration(milliseconds: 16));

    final obj = ctx.findRenderObject();
    if (obj is! RenderRepaintBoundary) return null;

    if (obj.debugNeedsPaint) {
      await Future<void>.delayed(const Duration(milliseconds: 16));
    }

    final img = await obj.toImage(pixelRatio: pixelRatio);
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) return null;
    final bytes = byteData.buffer.asUint8List();

    final dir = await getTemporaryDirectory();
    final f = File(
      '${dir.path}/$filenamePrefix-${DateTime.now().millisecondsSinceEpoch}.png',
    );
    await f.writeAsBytes(bytes, flush: true);
    return f;
  }

  static Future<File> writeTempBytes(List<int> bytes, String filename) async {
    final dir = await getTemporaryDirectory();
    final f = File('${dir.path}/$filename');
    await f.writeAsBytes(bytes, flush: true);
    return f;
  }
}
