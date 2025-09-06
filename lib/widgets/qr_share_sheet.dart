// title=lib/widgets/qr_share_sheet.dart
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../models/profile.dart';
import '../services/link_utils.dart';
import '../services/share_bundle_service.dart';

class QrShareSheet extends StatefulWidget {
  const QrShareSheet({
    super.key,
    required this.profile,
    required this.avatarProvider,
    this.shareLink,
    this.qrBoundary, // optional capture target (QR only)
    this.cardBoundary, // optional capture target (profile card)
  });

  final Profile profile;
  final ImageProvider avatarProvider;
  final String? shareLink;
  final GlobalKey? qrBoundary;
  final GlobalKey? cardBoundary;

  @override
  State<QrShareSheet> createState() => _QrShareSheetState();
}

class _QrShareSheetState extends State<QrShareSheet> {
  final GlobalKey _internalQrKey = GlobalKey();

  GlobalKey get _qrKey => widget.qrBoundary ?? _internalQrKey;

  String get _payload {
    // Prefer a normalized short link if present; otherwise MECARD
    final link = normalizeUrl(widget.shareLink);
    if (link != null && link.length <= 1024) return link;

    final b = StringBuffer('MECARD:');
    void add(String label, String? v) {
      final s = (v ?? '').trim();
      if (s.isEmpty) return;
      b.write('$label:${s.replaceAll(';', ',')};');
    }

    add('N', widget.profile.name);
    add('TEL', widget.profile.phone);
    add('EMAIL', widget.profile.email);
    add('URL', normalizeUrl(widget.profile.website));
    final adr = widget.profile.address.trim();
    if (adr.isNotEmpty) {
      final shortAdr = adr.length > 80 ? '${adr.substring(0, 77)}…' : adr;
      add('ADR', shortAdr);
    }
    final text = b.toString();
    return text.substring(0, min(text.length, 1500));
  }

  Future<void> _shareQrImage() async {
    await ShareBundleService.shareImageFromKey(
      _qrKey,
      fileName: 'CardLink_QR.png',
      text: 'Scan to view my CardLink',
    );
  }

  Future<void> _shareBundlePdf() async {
    await ShareBundleService.shareBundle(
      profile: widget.profile,
      cardBoundary: widget.cardBoundary,
      text: 'My CardLink Pro Profile',
    );
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 24.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 8),
              Text('Share via QR Code', style: text.titleLarge),
              const SizedBox(height: 12),

              // QR itself (capturable)
              RepaintBoundary(
                key: _qrKey,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: QrImageView(
                      data: _payload,
                      version: QrVersions.auto,
                      size: 250,
                      backgroundColor: Colors.white,
                      // Black squares & dots; avatar in the middle
                      eyeStyle: const QrEyeStyle(
                        eyeShape: QrEyeShape.square,
                        color: Colors.black,
                      ),
                      dataModuleStyle: const QrDataModuleStyle(
                        dataModuleShape: QrDataModuleShape.circle,
                        color: Colors.black,
                      ),
                      embeddedImage: widget.avatarProvider,
                      embeddedImageStyle:
                          const QrEmbeddedImageStyle(size: Size(68, 68)),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),
              Text('Scan QR Code to view profile', style: text.titleMedium),

              const SizedBox(height: 8),
              _tile(
                icon: Icons.picture_as_pdf_outlined,
                title: 'Share your CardLink',
                subtitle: 'Share your CardLink through messaging apps',
                onTap: _shareBundlePdf,
              ),
              _tile(
                icon: Icons.link,
                title: 'Copy Profile Link',
                subtitle: 'Copy shareable link to clipboard',
                onTap: () async {
                  final link = normalizeUrl(widget.shareLink);
                  if (link != null) {
                    await ShareBundleService.copyLink(link, context: context);
                  }
                },
              ),
              _tile(
                icon: Icons.qr_code_2_outlined,
                title: 'Share QR Code',
                subtitle: 'Share through messaging apps or social media',
                onTap: _shareQrImage,
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      onTap: onTap,
    );
  }
}
