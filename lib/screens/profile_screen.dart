// title=lib/screens/profile_screen.dart
import 'dart:io';

import 'package:flutter/material.dart';

import '../models/profile.dart';
import '../services/preferences_service.dart';
import '../widgets/profile_card.dart';
import '../widgets/qr_share_sheet.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _prefs = PreferencesService();
  Profile? _p;
  final _cardKey = GlobalKey(); // for image capture in share sheet

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final loaded = await _prefs.loadProfile();
    if (!mounted) return;
    setState(() => _p = loaded);
  }

  ImageProvider _bgProvider(Profile p) {
    if (p.usesImageBackground) {
      if (p.backgroundAsset.startsWith('/')) {
        return FileImage(File(p.backgroundAsset));
      }
      return AssetImage(p.backgroundAsset);
    }
    return const AssetImage(''); // not used when color mode
  }

  ImageProvider _avatarProvider(Profile p) {
    if (p.avatarAsset.startsWith('/')) {
      return FileImage(File(p.avatarAsset));
    }
    return AssetImage(p.avatarAsset);
  }

  void _openShare() {
    final p = _p!;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => QrShareSheet(
        profile: p,
        avatarProvider: _avatarProvider(p),
        shareLink: null, // no web URL; we share image/PDF
        cardBoundary: _cardKey,
      ),
    );
  }

  Future<void> _openEdit() async {
    final p = _p!;
    await Navigator.of(context).pushNamed('/edit', arguments: p);
    final updated = await _prefs.loadProfile();
    if (!mounted) return;
    setState(() => _p = updated);
  }

  @override
  Widget build(BuildContext context) {
    if (_p == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final p = _p!;
    return Scaffold(
      appBar: AppBar(
        title: const Text('CardLink Pro'),
        actions: [
          IconButton(icon: const Icon(Icons.ios_share), onPressed: _openShare),
        ],
      ),
      body: Stack(
        children: [
          // Background (image or color)
          Positioned.fill(
            child: p.usesImageBackground
                ? Image(image: _bgProvider(p), fit: BoxFit.cover)
                : ColoredBox(color: p.backgroundColor),
          ),
          // Tint so white text pops (like your PDF)
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.15)),
          ),

          // Profile content (capturable)
          SafeArea(
            child: RepaintBoundary(
              key: _cardKey,
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ProfileCard(profile: p),
              ),
            ),
          ),

          // Bank details bottom pill (if provided)
          if (p.bankDetails.trim().isNotEmpty)
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.75),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Text(
                  // Rendered separately from the card; the card itself has a “story” area.
                  // If you prefer to show the bank on the card instead, move this into ProfileCard.
                  ' ', // (content already on the card if you use it there)
                  style: TextStyle(color: Colors.white, fontSize: 13),
                ),
              ),
            ),

          // Floating Edit
          Positioned(
            right: 16,
            bottom: 84,
            child: FloatingActionButton.extended(
              onPressed: _openEdit,
              icon: const Icon(Icons.edit),
              label: const Text('Edit'),
            ),
          ),
        ],
      ),
    );
  }
}
