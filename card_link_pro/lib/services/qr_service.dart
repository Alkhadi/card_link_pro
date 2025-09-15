import 'dart:io';
// We alias `dart:ui` as `ui` for access to image, rect and path classes.
import 'dart:ui' as ui;

import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';

/// Utility for generating QR codes with an optional circular avatar
/// embedded at the centre.  The returned bytes are encoded as PNG.  The
/// avatar must be provided as a file path or as an asset reference; if
/// omitted the QR code is returned unmodified.  The quiet zone and
/// error correction level are tuned to maintain scannability even when
/// an avatar is overlaid.
class QrService {
  const QrService._();

  /// Generates a QR code PNG for the given [data] and optionally draws
  /// an avatar at the centre.  The [avatarPath] may refer to a
  /// filesystem path or a bundled asset beginning with `assets/`.  The
  /// [size] defines the square dimension in logical pixels used to
  /// render the QR image prior to encoding.  A larger size produces
  /// higher resolution output and improves avatar clarity.  Throws an
  /// exception if the QR code cannot be rendered.
  static Future<Uint8List> generateQrWithAvatar(
    String data, {
    String? avatarPath,
    double size = 800,
  }) async {
    // Build the base QR image using a painter.  We enforce a medium
    // error correction level to allow for the avatar overlay without
    // compromising scannability.
    final qrPainter = QrPainter(
      data: data,
      version: QrVersions.auto,
      gapless: true,
      errorCorrectionLevel: QrErrorCorrectLevel.M,
    );
    // QrPainter.toImage expects a double for the dimension.  Passing
    // size directly avoids an implicit int -> double cast error.
    final ui.Image qrImage = await qrPainter.toImage(size);

    // Prepare the avatar image if provided.
    ui.Image? avatar;
    if (avatarPath != null && avatarPath.isNotEmpty) {
      Uint8List bytes;
      if (avatarPath.startsWith('assets/')) {
        final data = await rootBundle.load(avatarPath);
        bytes = data.buffer.asUint8List();
      } else {
        bytes = await File(avatarPath).readAsBytes();
      }
      final codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      avatar = frame.image;
    }

    // Compose final image on a canvas.  Draw QR first, then overlay
    // avatar in the centre if available.
    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(
      recorder,
      ui.Rect.fromLTWH(0, 0, size, size),
    );
    canvas.drawImage(qrImage, ui.Offset.zero, ui.Paint());
    if (avatar != null) {
      // Determine avatar size as 25% of the QR dimension to maintain a
      // sufficient quiet zone.  Draw a circular clip before painting.
      final double avatarSize = size * 0.25;
      final ui.Offset center = ui.Offset(size / 2 - avatarSize / 2, size / 2 - avatarSize / 2);
      final ui.Rect rect = center & ui.Size(avatarSize, avatarSize);
      // Use ui.Path explicitly to avoid import errors on non-UI platforms
      final ui.Path clip = ui.Path()..addOval(rect);
      canvas.save();
      canvas.clipPath(clip);
      // Scale avatar to fit the rect
      final ui.Rect src = ui.Rect.fromLTWH(0, 0, avatar.width.toDouble(), avatar.height.toDouble());
      canvas.drawImageRect(
        avatar,
        src,
        rect,
        ui.Paint(),
      );
      canvas.restore();
    }
    final ui.Image finalImage = await recorder.endRecording().toImage(size.toInt(), size.toInt());
    final byteData = await finalImage.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }
}