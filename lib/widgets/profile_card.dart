// lib/widgets/profile_card.dart
import 'dart:io' show File;

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/profile.dart';
import '../services/link_utils.dart';

class ProfileCard extends StatelessWidget {
  const ProfileCard({super.key, required this.profile});

  final Profile profile;

  Future<void> _open(String url) async {
    final uri = Uri.tryParse(normalizeUrl(url) ?? url);
    if (uri != null) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _openMaps(String address) async {
    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(address)}',
    );
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
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
        provider =
            const AssetImage('assets/images/placeholders/profile/alkhadi.png');
      }
      return CircleAvatar(
        radius: 48,
        backgroundImage: provider,
        backgroundColor: Colors.black.withOpacity(0.3),
      );
    }

    Widget blackBox(Widget child) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.75),
            borderRadius: BorderRadius.circular(8),
          ),
          child: child,
        );

    Widget linkChip(IconData icon, String label, VoidCallback onTap) {
      return InkWell(
        onTap: onTap,
        child: blackBox(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.white, size: 18),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  style: text.bodyMedium?.copyWith(color: Colors.white),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          avatar(),
          const SizedBox(height: 12),
          blackBox(Text(
            profile.name,
            style: text.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          )),
          const SizedBox(height: 8),
          blackBox(Text(
            profile.title,
            style: text.bodyMedium?.copyWith(color: Colors.white),
          )),
          const SizedBox(height: 16),

          // Address
          if (profile.address.isNotEmpty)
            InkWell(
              onTap: () => _openMaps(profile.address),
              child: blackBox(Text(
                profile.address,
                textAlign: TextAlign.center,
                style: text.bodyMedium?.copyWith(color: Colors.white),
              )),
            ),

          const SizedBox(height: 16),

          // Contact Info
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              if (profile.phone.isNotEmpty)
                linkChip(Icons.phone, profile.phone, () {
                  launchUrl(Uri.parse("tel:${profile.phone}"));
                }),
              if (profile.email.isNotEmpty)
                linkChip(Icons.email, profile.email, () {
                  launchUrl(Uri.parse("mailto:${profile.email}"));
                }),
              if (profile.website.isNotEmpty)
                linkChip(Icons.language, profile.website, () {
                  _open(profile.website);
                }),
            ],
          ),

          const SizedBox(height: 16),

          // Social Links
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: profile.links.entries.map((e) {
              return linkChip(serviceIconForUrl(e.value), e.key, () {
                _open(e.value);
              });
            }).toList(),
          ),

          const SizedBox(height: 16),

          // Bank Details
          if (profile.bankDetails.isNotEmpty)
            blackBox(Text(
              profile.bankDetails,
              textAlign: TextAlign.center,
              style: text.bodyMedium?.copyWith(color: Colors.white),
            )),
        ],
      ),
    );
  }
}
