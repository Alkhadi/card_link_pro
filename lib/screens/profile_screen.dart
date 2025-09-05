// lib/screens/profile_screen.dart
import 'dart:io' show File;

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/profile.dart';
import '../services/link_utils.dart';
import '../widgets/profile_card.dart';
import '../widgets/qr_share_sheet.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Profile _profile;

  final GlobalKey _cardKey = GlobalKey(); // RepaintBoundary for capture
  final GlobalKey _qrKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _profile = Profile.defaultProfile();
  }

  void _openQrSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => QrShareSheet(
        profile: _profile,
        avatarProvider: _avatarProvider(),
        shareLink: _profile.website,
        qrBoundary: _qrKey,
        cardBoundary: _cardKey,
      ),
    );
  }

  ImageProvider _avatarProvider() {
    try {
      if (_profile.avatarAsset.startsWith('/')) {
        return FileImage(File(_profile.avatarAsset));
      }
      return AssetImage(_profile.avatarAsset);
    } catch (_) {
      return const AssetImage(''); // will show icon instead
    }
  }

  Widget _background() {
    // load asset or fallback gradient
    return FutureBuilder(
      future: Future(() {
        if (_profile.backgroundAsset.startsWith('/')) {
          return File(_profile.backgroundAsset).exists();
        }
        return true;
      }),
      builder: (ctx, snap) {
        // Fill screen
        return Positioned.fill(
          child: (snap.hasData && snap.data == true)
              ? Image(
                  image: _profile.backgroundAsset.startsWith('/')
                      ? FileImage(File(_profile.backgroundAsset))
                      : AssetImage(_profile.backgroundAsset) as ImageProvider,
                  fit: BoxFit.cover,
                )
              : Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF1F2937), Color(0xFF0F172A)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('CardLink Pro'),
        actions: [
          IconButton(
            tooltip: 'Open website',
            icon: const Icon(Icons.language),
            onPressed: () {
              final nu = normalizeUrl(_profile.website);
              if (nu != null) launchUrl(Uri.parse(nu));
            },
          ),
          IconButton(
            tooltip: 'Share / QR',
            icon: const Icon(Icons.share_outlined),
            onPressed: _openQrSheet,
          ),
        ],
      ),
      body: Stack(
        children: [
          _background(),

          // Centered, responsive card
          Positioned.fill(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: Center(
                child: RepaintBoundary(
                  key: _cardKey,
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 420),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ProfileCard(profile: _profile),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          // Minimal inline editor (quick edit)
          final updated = await showDialog<Profile>(
            context: context,
            builder: (ctx) => _EditDialog(profile: _profile),
          );
          if (updated != null) setState(() => _profile = updated);
        },
        icon: const Icon(Icons.edit),
        label: Text('Edit', style: text.labelLarge),
      ),
    );
  }
}

class _EditDialog extends StatefulWidget {
  const _EditDialog({required this.profile});
  final Profile profile;

  @override
  State<_EditDialog> createState() => _EditDialogState();
}

class _EditDialogState extends State<_EditDialog> {
  late final TextEditingController name =
      TextEditingController(text: widget.profile.name);
  late final TextEditingController title =
      TextEditingController(text: widget.profile.title);
  late final TextEditingController phone =
      TextEditingController(text: widget.profile.phone);
  late final TextEditingController email =
      TextEditingController(text: widget.profile.email);
  late final TextEditingController website =
      TextEditingController(text: widget.profile.website);
  late final TextEditingController address =
      TextEditingController(text: widget.profile.address);

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return AlertDialog(
      title: const Text('Edit profile'),
      content: SingleChildScrollView(
        child: Column(
          children: [
            TextField(
                controller: name,
                decoration: const InputDecoration(labelText: 'Name')),
            TextField(
                controller: title,
                decoration: const InputDecoration(labelText: 'Title')),
            TextField(
                controller: phone,
                decoration: const InputDecoration(labelText: 'Phone')),
            TextField(
                controller: email,
                decoration: const InputDecoration(labelText: 'Email')),
            TextField(
                controller: website,
                decoration: const InputDecoration(labelText: 'Website')),
            TextField(
              controller: address,
              decoration: const InputDecoration(labelText: 'Address'),
              maxLines: 3,
            ),
            const SizedBox(height: 8),
            Text('Background/Avatar can be swapped by replacing asset files.',
                style: text.bodySmall),
          ],
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel')),
        FilledButton(
          onPressed: () {
            final p = widget.profile.copyWith(
              name: name.text.trim(),
              title: title.text.trim(),
              phone: phone.text.trim(),
              email: email.text.trim(),
              website: website.text.trim(),
              address: address.text.trim(),
            );
            Navigator.pop(context, p);
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
