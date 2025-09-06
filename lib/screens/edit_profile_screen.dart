// title=lib/screens/edit_profile_screen.dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:image_picker/image_picker.dart';

import '../models/profile.dart';
import '../services/link_utils.dart';
import '../services/preferences_service.dart';
import '../widgets/qr_share_sheet.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key, required this.profile});

  final Profile profile;

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _prefs = PreferencesService();
  final _picker = ImagePicker();

  late Profile _p;

  late final _name = TextEditingController();
  late final _title = TextEditingController();
  late final _phone = TextEditingController();
  late final _email = TextEditingController();
  late final _website = TextEditingController();
  late final _address = TextEditingController();
  late final _story = TextEditingController();
  late final _bank = TextEditingController();

  @override
  void initState() {
    super.initState();
    _p = widget.profile;
    _bind();
  }

  void _bind() {
    _name.text = _p.name;
    _title.text = _p.title;
    _phone.text = _p.phone;
    _email.text = _p.email;
    _website.text = _p.website;
    _address.text = _p.address;
    _story.text = _p.story;
    _bank.text = _p.bankDetails;
  }

  ImageProvider _avatarProvider() {
    try {
      return _p.avatarAsset.startsWith('/')
          ? FileImage(File(_p.avatarAsset))
          : AssetImage(_p.avatarAsset);
    } catch (_) {
      return const AssetImage('assets/images/alkhadi.png');
    }
  }

  ImageProvider? _backgroundImageProviderOrNull() {
    if (_p.usesImageBackground) {
      try {
        return _p.backgroundAsset.startsWith('/')
            ? FileImage(File(_p.backgroundAsset))
            : AssetImage(_p.backgroundAsset);
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  Future<void> _save() async {
    final updated = _p.copyWith(
      name: _name.text.trim(),
      title: _title.text.trim(),
      phone: _phone.text.trim(),
      email: _email.text.trim(),
      website: _website.text.trim(),
      address: _address.text.trim(),
      story: _story.text.trim(),
      bankDetails: _bank.text.trim(),
    );
    setState(() => _p = updated);
    await _prefs.saveProfile(updated);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile saved')),
    );
  }

  void _openQrSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => QrShareSheet(
        profile: _p,
        avatarProvider: _avatarProvider(),
        shareLink: normalizeUrl(_website.text.trim()),
        cardBoundary: null,
      ),
    );
  }

  Future<void> _pickAvatar() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;
    final updated = _p.copyWith(avatarAsset: picked.path);
    setState(() => _p = updated);
    await _prefs.saveProfile(updated);
  }

  Future<void> _pickBackgroundImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;
    final updated = _p.copyWith(backgroundAsset: picked.path);
    setState(() => _p = updated);
    await _prefs.saveProfile(updated);
  }

  void _pickAppWallpaper() {
    final choices = <String>[
      'assets/images/placeholders/background/bg1.jpg',
    ];
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            const ListTile(title: Text('Choose a wallpaper')),
            for (final asset in choices)
              ListTile(
                leading: Image.asset(asset,
                    width: 54, height: 34, fit: BoxFit.cover),
                title: Text(asset.split('/').last),
                onTap: () async {
                  final updated = _p.copyWith(backgroundAsset: asset);
                  setState(() => _p = updated);
                  await _prefs.saveProfile(updated);
                  if (ctx.mounted) Navigator.pop(ctx);
                },
              ),
          ],
        ),
      ),
    );
  }

  void _pickBackgroundColor() {
    showDialog(
      context: context,
      builder: (ctx) {
        Color selected = _p.usesImageBackground
            ? const Color(0xFF111827)
            : _p.backgroundColor;
        return AlertDialog(
          title: const Text('Pick background color'),
          content: SingleChildScrollView(
            child: BlockPicker(
              pickerColor: selected,
              onColorChanged: (c) => selected = c,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                final updated = _p.copyWith(
                  backgroundAsset: 'color:${selected.value}',
                  backgroundColorValue: selected.value,
                );
                setState(() => _p = updated);
                await _prefs.saveProfile(updated);
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Widget _field(String label, TextEditingController c,
      {int maxLines = 1, TextInputType? type}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextField(
        controller: c,
        keyboardType: type,
        maxLines: maxLines,
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          labelText: label,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bgImage = _backgroundImageProviderOrNull();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: [
          IconButton(
              icon: const Icon(Icons.qr_code_2_outlined),
              onPressed: _openQrSheet),
          IconButton(icon: const Icon(Icons.save_alt), onPressed: _save),
        ],
      ),
      body: Stack(
        children: [
          // Background: image or solid color
          Positioned.fill(
            child: bgImage != null
                ? Image(image: bgImage, fit: BoxFit.cover)
                : ColoredBox(color: _p.backgroundColor),
          ),
          Positioned.fill(
              child: Container(color: Colors.black.withOpacity(0.3))),
          SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    CircleAvatar(
                        radius: 36, backgroundImage: _avatarProvider()),
                    OutlinedButton.icon(
                      icon: const Icon(Icons.photo),
                      label: const Text('Change Avatar'),
                      onPressed: _pickAvatar,
                    ),
                    OutlinedButton.icon(
                      icon: const Icon(Icons.collections),
                      label: const Text('Wallpapers'),
                      onPressed: _pickAppWallpaper,
                    ),
                    OutlinedButton.icon(
                      icon: const Icon(Icons.color_lens),
                      label: const Text('Background Color'),
                      onPressed: _pickBackgroundColor,
                    ),
                    OutlinedButton.icon(
                      icon: const Icon(Icons.photo_library),
                      label: const Text('Gallery Background'),
                      onPressed: _pickBackgroundImage,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _field('Name', _name),
                _field('Title', _title),
                _field('Phone', _phone, type: TextInputType.phone),
                _field('Email', _email, type: TextInputType.emailAddress),
                _field('Website', _website, type: TextInputType.url),
                _field('Address', _address, maxLines: 3),
                _field('Short Bio', _story, maxLines: 3),
                _field('Bank Details', _bank, maxLines: 2),
                const SizedBox(height: 16),
                FilledButton.icon(
                  icon: const Icon(Icons.check),
                  label: const Text('Save'),
                  onPressed: _save,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
