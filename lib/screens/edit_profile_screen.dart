// title=lib/screens/edit_profile_screen.dart
import 'dart:io';

import 'package:flutter/material.dart';

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

  late final TextEditingController _name =
      TextEditingController(text: widget.profile.name);
  late final TextEditingController _title =
      TextEditingController(text: widget.profile.title);
  late final TextEditingController _phone =
      TextEditingController(text: widget.profile.phone);
  late final TextEditingController _email =
      TextEditingController(text: widget.profile.email);
  late final TextEditingController _website =
      TextEditingController(text: widget.profile.website);
  late final TextEditingController _address =
      TextEditingController(text: widget.profile.address);
  late final TextEditingController _story =
      TextEditingController(text: widget.profile.story);

  late Profile _p = widget.profile;

  ImageProvider _avatarProvider() {
    try {
      return _p.avatarAsset.startsWith('/')
          ? FileImage(File(_p.avatarAsset))
          : AssetImage(_p.avatarAsset);
    } catch (_) {
      return const AssetImage('assets/images/placeholders/profile/alkhadi.png');
    }
  }

  ImageProvider _backgroundProvider() {
    try {
      return _p.backgroundAsset.startsWith('/')
          ? FileImage(File(_p.backgroundAsset))
          : AssetImage(_p.backgroundAsset);
    } catch (_) {
      return const AssetImage('assets/images/placeholders/background/bg1.jpg');
    }
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
    );
    setState(() => _p = updated);
    await _prefs.saveProfile(updated);
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Saved')));
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
      ),
    );
  }

  void _pickAppWallpaper() {
    // Simple built‑in picker that lists bundled assets.
    final choices = <String>[
      'assets/images/placeholders/background/bg1.jpg',
      // add more bundled backgrounds here if you like
    ];
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            const ListTile(
              title: Text('Choose an app wallpaper'),
            ),
            for (final asset in choices)
              ListTile(
                leading: SizedBox(
                  width: 54,
                  height: 34,
                  child: Image.asset(asset, fit: BoxFit.cover),
                ),
                title: Text(asset.split('/').last),
                onTap: () async {
                  final updated = _p.copyWith(backgroundAsset: asset);
                  setState(() => _p = updated);
                  await _prefs.saveProfile(updated);
                  if (ctx.mounted) Navigator.pop(ctx);
                },
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
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
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
        ).copyWith(labelText: label),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bgProvider = _backgroundProvider();

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
          Positioned.fill(child: Image(image: bgProvider, fit: BoxFit.cover)),
          Positioned.fill(
            child: Container(color: Colors.black.withValues(alpha: 0.2)),
          ),
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
                      icon: const Icon(Icons.collections),
                      label: const Text('App wallpapers'),
                      onPressed: _pickAppWallpaper,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _field('Name', _name),
                _field('Title', _title),
                _field('Phone', _phone, type: TextInputType.phone),
                _field('Email', _email, type: TextInputType.emailAddress),
                _field('Website', _website, type: TextInputType.url),
                _field('Address (multi-line)', _address, maxLines: 4),
                _field('Short bio', _story, maxLines: 3),
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
