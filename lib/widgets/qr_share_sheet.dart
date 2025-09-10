// lib/widgets/qr_share_sheet.dart
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../payments/pay_dialog.dart';
import '../services/contact_service.dart';
import '../services/profile_store.dart';
import '../services/share_bundle_service.dart';
import '../services/share_service.dart';
import '../utils/image_provider_x.dart';
import '../utils/vcard.dart';
import 'send_to_sheet.dart';
import 'text_share_sheet.dart';

class QrShareSheet extends StatefulWidget {
  const QrShareSheet({super.key, required this.captureKey});

  final GlobalKey captureKey;

  @override
  State<QrShareSheet> createState() => _QrShareSheetState();
}

class _QrShareSheetState extends State<QrShareSheet> {
  Uint8List? _png;
  Uint8List? _pdf;

  @override
  void initState() {
    super.initState();
    _prepare();
  }

  Future<void> _prepare() async {
    final profile = context.read<ProfileStore>().profile;
    final bundle = await ShareBundleService.buildShareBundle(
      captureKey: widget.captureKey,
      profile: profile,
    );
    if (!mounted) return;
    setState(() {
      _png = bundle.pngImageBytes;
      _pdf = bundle.pdfBytes;
    });
  }

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ProfileStore>().profile;
    final vcard = buildVCard(profile);

    // Non-nullable provider from your utility
    final ImageProvider<Object> avatarProvider =
        loadImageProvider(profile.avatarAssetOrPath);

    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/backgrounds/amz.jpg'),
          fit: BoxFit.cover,
        ),
      ),
      child: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.75),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                children: [
                  CircleAvatar(
                    backgroundImage: avatarProvider,
                    radius: 22,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Share My Profile',
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(color: Colors.white),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: const Icon(Icons.close, color: Colors.white70),
                    tooltip: 'Close',
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // QR Card / Preview
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
                padding:
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                child: Column(
                  children: [
                    QrImageView(
                      data: vcard,
                      version: QrVersions.auto,
                      size: 200,
                      padding: const EdgeInsets.all(12),
                      errorCorrectionLevel: QrErrorCorrectLevel.M,
                      backgroundColor: Colors.white,
                      eyeStyle: const QrEyeStyle(
                        eyeShape: QrEyeShape.square,
                        color: Colors.black,
                      ),
                      dataModuleStyle: const QrDataModuleStyle(
                        dataModuleShape: QrDataModuleShape.circle,
                        color: Colors.black,
                      ),
                      embeddedImage: avatarProvider,
                      embeddedImageStyle: const QrEmbeddedImageStyle(
                        size: Size(48, 48),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      profile.name,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Scan to save contact',
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: Colors.black54),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      alignment: WrapAlignment.center,
                      children: [
                        if (_pdf != null && _png != null)
                          _smallActionChip(
                            icon: Icons.picture_as_pdf_outlined,
                            label: 'Share PDF + QR',
                            onTap: () async {
                              await ShareService.sharePdfAndImage(
                                pdfBytes: _pdf!,
                                pngBytes: _png!,
                              );
                            },
                          ),
                        if (_png != null)
                          _smallActionChip(
                            icon: Icons.qr_code_2_outlined,
                            label: 'Share QR Image',
                            onTap: () async => ShareService.shareImage(_png!),
                          ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Actions
              _action(
                icon: Icons.person_add_alt_1,
                label: 'Add New Contact',
                onTap: () async {
                  await showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.black,
                    builder: (_) => _AddContactSheet(
                      onComplete: (String name, String phone, String email,
                          bool biz) async {
                        await ContactService.addContact(
                          firstName: name,
                          phone: phone,
                          email: email,
                          isBusiness: biz,
                        );
                        if (_pdf != null && _png != null) {
                          await ShareService.sharePdfAndImage(
                            pdfBytes: _pdf!,
                            pngBytes: _png!,
                          );
                        }
                      },
                    ),
                  );
                },
              ),

              _action(
                icon: Icons.text_fields_outlined,
                label: 'Share My Profile as Text',
                onTap: () async {
                  await showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    useSafeArea: true,
                    backgroundColor: Colors.black,
                    builder: (_) => TextShareSheet(profile: profile),
                  );
                },
              ),

              _action(
                icon: Icons.image_outlined,
                label: 'Send My Profile Image',
                onTap: () async {
                  if (_png != null) await ShareService.shareImage(_png!);
                },
              ),

              _action(
                icon: Icons.email_outlined,
                label: 'Email My CardLink Pro Profile',
                onTap: () async {
                  await showModalBottomSheet(
                    context: context,
                    backgroundColor: Colors.black,
                    isScrollControlled: true,
                    builder: (_) => SendToSheet(
                      modeLabel: 'Email',
                      onSubmit: (email) async {
                        if (_pdf != null && _png != null) {
                          await ShareService.shareEmailWithAttachments(
                            recipientEmail: email,
                            pdfBytes: _pdf!,
                            pngBytes: _png!,
                          );
                        }
                      },
                    ),
                  );
                },
              ),

              _action(
                icon: Icons.sms_outlined,
                label: 'SMS My Profile',
                onTap: () => ShareService.smsText(profile),
              ),

              _action(
                icon: Icons.payments_rounded,
                label: 'Send Money (Bank)',
                onTap: () async {
                  final sc = _scFromBank(profile.bankDetails);
                  final acc = _accFromBank(profile.bankDetails);
                  final iban = _ibanFromBank(profile.bankDetails);
                  final bic = _bicFromBank(profile.bankDetails);

                  await showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    useSafeArea: true,
                    backgroundColor: Colors.black,
                    builder: (_) => PayDialog(
                      payeeName: profile.name,
                      sortCode: sc,
                      accountNumber: acc,
                      iban: iban,
                      bic: bic,
                      enableOpenBanking: false, // flip when keys ready
                    ),
                  );
                },
              ),

              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  // --- Helpers ---------------------------------------------------------------

  Widget _action({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        border: Border.all(color: const Color.fromARGB(26, 255, 255, 255)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.white),
        title: Text(label, style: const TextStyle(color: Colors.white)),
        trailing: const Icon(Icons.chevron_right, color: Colors.white70),
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      ),
    );
  }

  Widget _smallActionChip({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.black,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: Colors.white),
              const SizedBox(width: 6),
              Text(label, style: const TextStyle(color: Colors.white)),
            ],
          ),
        ),
      ),
    );
  }

  String _scFromBank(String s) {
    final m =
        RegExp(r'(Sc|Sort(?:\s+)?Code)[:\s]*([0-9\-]+)', caseSensitive: false)
            .firstMatch(s);
    return (m?.group(2) ?? '').replaceAll(' ', '');
  }

  String _accFromBank(String s) {
    final m = RegExp(r'(Ac|Account(?:\s+)?(No|Number)?)[:\s]*([0-9]+)',
            caseSensitive: false)
        .firstMatch(s);
    return m?.group(3) ?? '';
  }

  String? _ibanFromBank(String s) {
    final m =
        RegExp(r'IBAN[:\s]*([A-Z0-9]+)', caseSensitive: false).firstMatch(s);
    return m?.group(1);
  }

  String? _bicFromBank(String s) {
    final m = RegExp(r'(BIC|SWIFT)[:\s]*([A-Z0-9]+)', caseSensitive: false)
        .firstMatch(s);
    return m?.group(2);
  }
}

// --- Inline minimal sheet to avoid "isn't defined" error ---------------------

class _AddContactSheet extends StatefulWidget {
  const _AddContactSheet({required this.onComplete});

  final Future<void> Function(
    String name,
    String phone,
    String email,
    bool isBusiness,
  ) onComplete;

  @override
  State<_AddContactSheet> createState() => _AddContactSheetState();
}

class _AddContactSheetState extends State<_AddContactSheet> {
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();
  bool _isBusiness = false;

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _email.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(color: Colors.black),
          child: Wrap(
            runSpacing: 12,
            children: [
              Text(
                'Add New Contact',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(color: Colors.white),
              ),
              _field('Full name', _name, keyboardType: TextInputType.name),
              _field('Phone', _phone, keyboardType: TextInputType.phone),
              _field('Email', _email, keyboardType: TextInputType.emailAddress),
              Row(
                children: [
                  Checkbox(
                    value: _isBusiness,
                    onChanged: (v) => setState(() => _isBusiness = v ?? false),
                    checkColor: Colors.black,
                    activeColor: Colors.white,
                  ),
                  const SizedBox(width: 6),
                  const Text('Business contact',
                      style: TextStyle(color: Colors.white)),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.white70),
                    label: const Text('Cancel',
                        style: TextStyle(color: Colors.white70)),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                    ),
                    onPressed: () async {
                      await widget.onComplete(
                        _name.text.trim(),
                        _phone.text.trim(),
                        _email.text.trim(),
                        _isBusiness,
                      );
                      if (mounted) Navigator.pop(context);
                    },
                    icon: const Icon(Icons.person_add_alt_1),
                    label: const Text('Save'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(
    String label,
    TextEditingController c, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: c,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.08),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.white54),
        ),
      ),
    );
  }
}
