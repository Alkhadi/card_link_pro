import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/profile.dart';
import '../services/profile_store.dart';
import '../utils/image_provider_x.dart';
import '../widgets/image_picker_sheet.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late Profile _p;

  // Bundled images (match your pubspec.yaml)
  static const _avatarAssets = <String>[
    'assets/images/avatars/alkhadi.png',
    'assets/images/avatars/mariatou.png',
    'assets/images/avatars/avatar_business.png',
  ];

  static const _backgroundAssets = <String>[
    'assets/images/backgrounds/amz.jpg',
    'assets/images/backgrounds/abstract_wave.jpg',
    'assets/images/backgrounds/gradient_sky.jpg',
    'assets/images/backgrounds/gradient_sand.jpg',
    'assets/images/backgrounds/pattern_dots.jpg',
    'assets/images/backgrounds/texture_paper.jpg',
    'assets/images/backgrounds/city_soft.jpg',
  ];

  final _name = TextEditingController();
  final _title = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();
  final _website = TextEditingController();

  @override
  void initState() {
    super.initState();
    final store = context.read<ProfileStore>();
    _p = store.profile;
    _name.text = _p.name;
    _title.text = _p.title;
    _phone.text = _p.phone;
    _email.text = _p.email;
    _website.text = _p.website;
  }

  @override
  void dispose() {
    _name.dispose();
    _title.dispose();
    _phone.dispose();
    _email.dispose();
    _website.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => ImagePickerSheet(
        title: 'Choose Avatar',
        appImages: _avatarAssets,
        onPicked: (pathOrAsset) {
          setState(() {
            _p = _p.copyWith(avatarAssetOrPath: pathOrAsset);
          });
        },
      ),
    );
  }

  Future<void> _pickBackground() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => ImagePickerSheet(
        title: 'Choose Background',
        appImages: _backgroundAssets,
        onPicked: (pathOrAsset) {
          setState(() {
            _p = _p.copyWith(
              backgroundAssetOrPath: pathOrAsset,
              usesImageBackground: true,
            );
          });
        },
      ),
    );
  }

  Future<void> _save() async {
    final store = context.read<ProfileStore>();
    final updated = _p.copyWith(
      name: _name.text.trim(),
      title: _title.text.trim(),
      phone: _phone.text.trim(),
      email: _email.text.trim(),
      website: _website.text.trim(),
    );
    await store.save(updated);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final bg = _p.usesImageBackground
        ? DecorationImage(
            image: loadImageProvider(_p.backgroundAssetOrPath),
            fit: BoxFit.cover,
          )
        : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: [
          IconButton(
            onPressed: _save,
            icon: const Icon(Icons.check_rounded),
            tooltip: 'Save',
          )
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          color: _p.usesImageBackground ? null : Colors.black,
          image: bg,
        ),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Avatar + actions
            Center(
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 48,
                    backgroundImage: loadImageProvider(_p.avatarAssetOrPath),
                  ),
                  FloatingActionButton.small(
                    heroTag: 'editAvatar',
                    onPressed: _pickAvatar,
                    child: const Icon(Icons.camera_alt_rounded),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Background action
            FilledButton.icon(
              onPressed: _pickBackground,
              icon: const Icon(Icons.wallpaper),
              label: const Text('Change Background'),
            ),
            const SizedBox(height: 16),

            // Basic fields
            _field('Full name', _name, TextInputType.name),
            _field('Title', _title, TextInputType.text),
            _field('Phone', _phone, TextInputType.phone),
            _field('Email', _email, TextInputType.emailAddress),
            _field('Website', _website, TextInputType.url),

            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.save_rounded),
              label: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(String label, TextEditingController c, TextInputType k) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: c,
        keyboardType: k,
        decoration: InputDecoration(labelText: label),
      ),
    );
  }
}
