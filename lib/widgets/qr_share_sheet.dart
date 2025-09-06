import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../services/contact_service.dart';
import '../services/profile_store.dart';
import '../services/share_bundle_service.dart';
import '../services/share_service.dart';
import '../utils/vcard.dart';
import '../widgets/send_to_sheet.dart';

/// Bottom sheet that displays a QR code with embedded avatar and offers
/// multiple sharing options: add contact, email, SMS, image, PDF, text.
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

    // Use vCard as QR payload (encodes a full contact card — not a plain URL).
    final vcard = buildVCard(profile);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(color: Colors.black),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Share My Profile',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            // QR with circular avatar embedded
            QrImageView(
              data: vcard,
              version: QrVersions.auto,
              size: 180,
              backgroundColor: Colors.white,
              eyeStyle: const QrEyeStyle(
                eyeShape: QrEyeShape.square,
                color: Colors.black,
              ),
              dataModuleStyle: const QrDataModuleStyle(
                dataModuleShape: QrDataModuleShape.circle,
                color: Colors.black,
              ),
              embeddedImage:
                  AssetImage(profile.avatarAssetOrPath) as ImageProvider,
              embeddedImageStyle: const QrEmbeddedImageStyle(
                size: Size(48, 48),
                color: null,
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
                      onComplete: (name, phone, email, business) async {
                    await ContactService.addContact(
                      firstName: name,
                      phone: phone,
                      email: email,
                      isBusiness: business,
                    );
                    if (_pdf != null && _png != null) {
                      await ShareService.sharePdfAndImage(
                        pdfBytes: _pdf!,
                        pngBytes: _png!,
                      );
                    }
                  }),
                );
              },
            ),

            _action(
              icon: Icons.image_outlined,
              label: 'Send My Profile Image',
              onTap: () async {
                if (_png != null) {
                  await ShareService.shareImage(_png!);
                }
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
              icon: Icons.text_fields_outlined,
              label: 'Share My Profile as Text',
              onTap: () async => ShareService.shareText(profile),
            ),

            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _action({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(label),
      onTap: onTap,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Colors.white.withOpacity(0.1)),
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}

/// Bottom sheet to gather new contact info (name, phone, email, type). On
/// completion, calls [onComplete] with the provided values and whether the
/// contact is business.
class _AddContactSheet extends StatefulWidget {
  const _AddContactSheet({required this.onComplete});
  final Future<void> Function(
      String name, String? phone, String? email, bool business) onComplete;

  @override
  State<_AddContactSheet> createState() => _AddContactSheetState();
}

class _AddContactSheetState extends State<_AddContactSheet> {
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();
  bool _business = true;

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
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Wrap(
            runSpacing: 10,
            children: [
              Text('Add New Contact',
                  style: Theme.of(context).textTheme.titleMedium),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Business'),
                value: _business,
                onChanged: (v) => setState(() => _business = v),
              ),
              TextField(
                controller: _name,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: _phone,
                decoration: const InputDecoration(labelText: 'Phone'),
                keyboardType: TextInputType.phone,
              ),
              TextField(
                controller: _email,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Spacer(),
                  FilledButton(
                    onPressed: () async {
                      if (_name.text.trim().isEmpty) return;
                      await widget.onComplete(
                        _name.text.trim(),
                        _phone.text.trim().isEmpty ? null : _phone.text.trim(),
                        _email.text.trim().isEmpty ? null : _email.text.trim(),
                        _business,
                      );
                      if (!mounted) return;
                      Navigator.pop(context);
                    },
                    child: const Text('Save & Send'),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
