import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../models/profile.dart';
import '../services/profile_store.dart';
import '../services/share_service.dart';

/// A form-driven screen to edit all aspects of the user’s profile. Allows
/// selecting avatar, background (image or color), editing text fields and
/// previewing the formatted text share output.
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late Profile _p;
  final _form = GlobalKey<FormState>();
  bool _showTextPreview = false;

  @override
  void initState() {
    super.initState();
    _p = context.read<ProfileStore>().profile;
  }

  Future<void> _pickAvatar() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery);
    if (!mounted) return;
    if (file != null) {
      setState(() {
        _p = _p.copyWith(avatarAssetOrPath: file.path);
      });
    }
  }

  Future<void> _pickBackgroundImage() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery);
    if (!mounted) return;
    if (file != null) {
      setState(() {
        _p = _p.copyWith(
          backgroundAssetOrPath: file.path,
          usesImageBackground: true,
        );
      });
    }
  }

  Future<void> _pickBackgroundColor() async {
    Color selected = Color(_p.backgroundColorValue);
    await showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: const Text('Pick background color',
              style: TextStyle(color: Colors.white)),
          content: BlockPicker(
            pickerColor: selected,
            onColorChanged: (c) => selected = c,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Use Color'),
            ),
          ],
        );
      },
    );
    setState(() {
      _p = _p.copyWith(
        backgroundColorValue: selected.value,
        usesImageBackground: false,
      );
    });
  }

  Future<void> _save() async {
    if (_form.currentState?.validate() ?? false) {
      await context.read<ProfileStore>().save(_p);
      if (!mounted) return;
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final text = ShareService.prettyText(_p); // Live formatted preview text

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
      ),
      body: Form(
        key: _form,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Avatar & background selectors
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundImage: _p.avatarAssetOrPath.startsWith('/')
                      ? FileImage(File(_p.avatarAssetOrPath))
                      : AssetImage(_p.avatarAssetOrPath) as ImageProvider,
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: _pickAvatar,
                  icon: const Icon(Icons.photo),
                  label: const Text('Change Avatar'),
                ),
                const Spacer(),
                SegmentedButton<bool>(
                  segments: const [
                    ButtonSegment(value: true, label: Text('Image')),
                    ButtonSegment(value: false, label: Text('Color')),
                  ],
                  selected: {_p.usesImageBackground},
                  onSelectionChanged: (s) {
                    setState(() {
                      _p = _p.copyWith(usesImageBackground: s.first);
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (_p.usesImageBackground)
              Row(
                children: [
                  Expanded(
                      child: Text(
                    _p.backgroundAssetOrPath,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  )),
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    onPressed: _pickBackgroundImage,
                    icon: const Icon(Icons.image_outlined),
                    label: const Text('Pick Background'),
                  ),
                ],
              )
            else
              Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: Color(_p.backgroundColorValue),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white24),
                    ),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    onPressed: _pickBackgroundColor,
                    icon: const Icon(Icons.palette_outlined),
                    label: const Text('Pick Color'),
                  ),
                ],
              ),

            const Divider(height: 28),

            // Core text fields
            _t('Name',
                initial: _p.name, onSaved: (v) => _p = _p.copyWith(name: v)),
            _t('Title',
                initial: _p.title, onSaved: (v) => _p = _p.copyWith(title: v)),
            _t('Phone',
                initial: _p.phone,
                keyboard: TextInputType.phone,
                onSaved: (v) => _p = _p.copyWith(phone: v)),
            _t('Email',
                initial: _p.email,
                keyboard: TextInputType.emailAddress,
                onSaved: (v) => _p = _p.copyWith(email: v)),
            _t('Website (https://...)',
                initial: _p.website,
                onSaved: (v) => _p = _p.copyWith(website: v)),

            _m('Address (multi-line)',
                initial: _p.address,
                onSaved: (v) => _p = _p.copyWith(address: v)),

            const SizedBox(height: 8),
            const Text('Socials (full URLs recommended)'),
            _t('WhatsApp',
                initial: _p.whatsapp,
                onSaved: (v) => _p = _p.copyWith(whatsapp: v)),
            _t('Facebook',
                initial: _p.facebook,
                onSaved: (v) => _p = _p.copyWith(facebook: v)),
            _t('X/Twitter',
                initial: _p.xTwitter,
                onSaved: (v) => _p = _p.copyWith(xTwitter: v)),
            _t('YouTube',
                initial: _p.youtube,
                onSaved: (v) => _p = _p.copyWith(youtube: v)),
            _t('Instagram',
                initial: _p.instagram,
                onSaved: (v) => _p = _p.copyWith(instagram: v)),
            _t('TikTok',
                initial: _p.tiktok,
                onSaved: (v) => _p = _p.copyWith(tiktok: v)),
            _t('LinkedIn',
                initial: _p.linkedin,
                onSaved: (v) => _p = _p.copyWith(linkedin: v)),
            _t('Snapchat',
                initial: _p.snapchat,
                onSaved: (v) => _p = _p.copyWith(snapchat: v)),
            _t('Pinterest',
                initial: _p.pinterest,
                onSaved: (v) => _p = _p.copyWith(pinterest: v)),

            const SizedBox(height: 8),
            _m('Bank Details',
                hint: 'Ac number: ...   Sc Code: ...',
                initial: _p.bankDetails,
                onSaved: (v) => _p = _p.copyWith(
                    bankDetails: v?.isEmpty ?? true
                        ? 'Ac number: 93087283   Sc Code: 09-01-35'
                        : v)),
            _m('About',
                initial: _p.about, onSaved: (v) => _p = _p.copyWith(about: v)),

            const SizedBox(height: 16),
            ExpansionPanelList(
              expansionCallback: (_, isOpen) {
                setState(() => _showTextPreview = !isOpen);
              },
              children: [
                ExpansionPanel(
                  canTapOnHeader: true,
                  isExpanded: _showTextPreview,
                  headerBuilder: (_, __) => const ListTile(
                    title: Text('Share as Text (Preview)'),
                    subtitle: Text('Copy or share formatted message'),
                  ),
                  body: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.06),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white24),
                          ),
                          child: SelectableText(
                            text,
                            style: const TextStyle(
                                fontFamily: 'monospace', fontSize: 13.5),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            OutlinedButton.icon(
                              onPressed: () =>
                                  ShareService.copyFormattedText(context, _p),
                              icon: const Icon(Icons.copy),
                              label: const Text('Copy'),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton.icon(
                              onPressed: () => ShareService.shareText(_p),
                              icon: const Icon(Icons.share),
                              label: const Text('Share'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 22),
            FilledButton.icon(
              onPressed: () {
                _form.currentState?.save();
                _save();
              },
              icon: const Icon(Icons.check),
              label: const Text('Save Changes'),
            ),
            const SizedBox(height: 28),
          ],
        ),
      ),
    );
  }

  Widget _t(
    String label, {
    String? initial,
    String? hint,
    TextInputType? keyboard,
    required void Function(String) onSaved,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        initialValue: initial ?? '',
        keyboardType: keyboard,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
        ),
        onSaved: (v) => onSaved(v?.trim() ?? ''),
      ),
    );
  }

  Widget _m(
    String label, {
    String? initial,
    String? hint,
    required void Function(String) onSaved,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        initialValue: initial ?? '',
        maxLines: null,
        minLines: 3,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
        ),
        onSaved: (v) => onSaved(v?.trim() ?? ''),
      ),
    );
  }
}
