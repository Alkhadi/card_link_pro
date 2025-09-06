// title=lib/services/share_bundle_service.dart
import 'dart:typed_data'; // ByteData is defined here
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../models/profile.dart';
import '../utils/pdf_generator.dart';

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
    final pdfBytes = await PdfGenerator.generate(profile);
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
    final pr = pixelRatio.clamp(2.0, 4.0);

    final ui.Image image = await renderObject.toImage(pixelRatio: pr);
    final ByteData? byteData =
        await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) {
      throw Exception('Failed to encode PNG bytes.');
    }
    return byteData.buffer.asUint8List();
  }
}
