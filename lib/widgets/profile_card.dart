// lib/widgets/profile_card.dart
import 'dart:io' show File;

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/profile.dart';
import '../services/link_utils.dart';

class ProfileCard extends StatelessWidget {
  const ProfileCard({super.key, required this.profile});

  final Profile profile;

  Future<void> _open(String uri) async {
    final u = normalizeUrl(uri) ?? uri;
    final parsed = Uri.tryParse(u) ?? Uri.parse('https://$u');
    await launchUrl(parsed, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    Widget avatar() {
      ImageProvider provider;
      try {
        if (profile.avatarAsset.startsWith('/')) {
          provider = FileImage(File(profile.avatarAsset));
        } else {
          provider = AssetImage(profile.avatarAsset);
        }
      } catch (_) {
        provider = const AssetImage(''); // will fall back to Icon below
      }

      return CircleAvatar(
        radius: 28,
        backgroundColor: cs.surface.withValues(alpha: 0.3),
        foregroundImage: provider,
        child: const Icon(Icons.person, size: 32),
      );
    }

    Widget chipIcon(IconData icon, String label, {VoidCallback? onTap}) {
      return InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.75),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Text(label,
                  style: text.bodyMedium?.copyWith(color: Colors.white)),
            ],
          ),
        ),
      );
    }

    List<Widget> linkList() {
      final items = <Widget>[];
      if (profile.website.isNotEmpty) {
        items.add(chipIcon(Icons.language, 'https://${profile.website}',
            onTap: () => _open(profile.website)));
      }
      if (profile.phone.isNotEmpty) {
        items.add(chipIcon(Icons.phone, profile.phone,
            onTap: () => launchUrl(telUri(profile.phone))));
      }
      if (profile.email.isNotEmpty) {
        items.add(chipIcon(Icons.mail, profile.email,
            onTap: () => launchUrl(mailtoUri(profile.email))));
      }
      for (final e in profile.links.entries) {
        items.add(chipIcon(serviceIconForUrl(e.value), '${e.key}: ${e.value}',
            onTap: () => _open(e.value)));
      }
      return items;
    }

    return Material(
      color: Colors.transparent,
      child: Container(
        width: 360,
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Card top area (name/title/avatar + address bubble)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar + name
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          avatar(),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.75),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    profile.name,
                                    style: text.titleLarge?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.75),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    profile.title,
                                    style: text.labelLarge?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 12),

                // Address bubble on the right
                if (profile.address.isNotEmpty)
                  Container(
                    width: 150,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.75),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      profile.address,
                      style: text.bodySmall?.copyWith(color: Colors.white),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 12),

            // Contact / Link chips as a column
            Wrap(
              runSpacing: 10,
              spacing: 10,
              children: linkList(),
            ),

            const SizedBox(height: 12),

            if (profile.story.isNotEmpty)
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.75),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  profile.story,
                  style: text.bodyMedium?.copyWith(color: Colors.white),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
