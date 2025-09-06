import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/profile.dart';
import '../services/profile_store.dart';
import '../utils/link_utils.dart';

/// A reusable widget that displays the user’s profile on-screen. It fills the
/// available space, applies the selected background (image or color) and
/// overlays a dark translucent layer with white text. It also provides
/// tappable contact fields and a responsive socials grid.
class ProfileCard extends StatelessWidget {
  const ProfileCard(
      {super.key, required this.repaintKey, this.compact = false});

  final GlobalKey repaintKey;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ProfileStore>().profile;
    final bg = profile.usesImageBackground
        ? DecorationImage(
            image: AssetImage(profile.backgroundAssetOrPath),
            fit: BoxFit.cover,
          )
        : null;

    final bgColor = Color(profile.backgroundColorValue);

    return RepaintBoundary(
      key: repaintKey,
      child: Container(
        constraints: const BoxConstraints.expand(),
        decoration: BoxDecoration(
          color: profile.usesImageBackground ? Colors.black : bgColor,
          image: bg,
        ),
        child: Container(
          // Black translucent overlay (visual source of truth)
          decoration: BoxDecoration(
            color: Colors.black.withAlpha(180),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          child: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 520;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header row: avatar + name/title
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: isWide ? 44 : 38,
                          backgroundImage:
                              AssetImage(profile.avatarAssetOrPath),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(profile.name,
                                  style: TextStyle(
                                    fontSize: isWide ? 26 : 22,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  )),
                              const SizedBox(height: 4),
                              Text(profile.title,
                                  style: TextStyle(
                                    fontSize: isWide ? 16 : 14,
                                    color: Colors.white.withOpacity(0.9),
                                  )),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Address + tappable maps link
                    _LineItem(
                      icon: Icons.place_outlined,
                      label: _singleLineAddress(profile.address),
                      onTap: () async {
                        final maps = mapUrlFromAddress(profile.address);
                        final uri = Uri.parse(maps);
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(uri,
                              mode: LaunchMode.externalApplication);
                        }
                      },
                    ),
                    const SizedBox(height: 8),

                    // Phone
                    _LineItem(
                      icon: Icons.phone_outlined,
                      label: profile.phone,
                      onTap: () async {
                        final uri =
                            Uri.parse('tel:${normalizePhone(profile.phone)}');
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(uri);
                        }
                      },
                    ),

                    // Email
                    _LineItem(
                      icon: Icons.mail_outline,
                      label: profile.email,
                      onTap: () async {
                        final uri = Uri.parse('mailto:${profile.email}');
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(uri);
                        }
                      },
                    ),
                    // Website
                    _LineItem(
                      icon: Icons.language_outlined,
                      label: profile.website,
                      onTap: () async {
                        final uri = Uri.parse(normalizeUrl(profile.website));
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(uri,
                              mode: LaunchMode.externalApplication);
                        }
                      },
                    ),

                    const SizedBox(height: 14),

                    // Social icons in Wrap (responsive)
                    _SocialGrid(profile: profile),

                    const Spacer(),

                    // Bank translucent pill
                    if (profile.bankDetails.trim().isNotEmpty)
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.black.withAlpha(180),
                            borderRadius: BorderRadius.circular(32),
                            border: Border.all(
                                color: Colors.white.withOpacity(0.18)),
                          ),
                          child: Text(
                            profile.bankDetails,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              height: 1.3,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  static String _singleLineAddress(String multi) =>
      multi.replaceAll('\n', ' ').replaceAll(RegExp(r'\s+'), ' ');
}

/// A single row with an icon and label; tap triggers optional callback.
class _LineItem extends StatelessWidget {
  const _LineItem({required this.icon, required this.label, this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white.withOpacity(0.9)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.95),
                fontSize: 14,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Creates a responsive grid of social chips. Each chip displays an emoji and
/// label; tapping opens the link via url_launcher.
class _SocialGrid extends StatelessWidget {
  const _SocialGrid({required this.profile});
  final Profile profile;

  @override
  Widget build(BuildContext context) {
    final items = <_SocialItem>[
      _SocialItem('WhatsApp', '💬', profile.whatsapp),
      _SocialItem('Facebook', '📘', profile.facebook),
      _SocialItem('X/Twitter', '✖️', profile.xTwitter),
      _SocialItem('YouTube', '▶️', profile.youtube),
      _SocialItem('Instagram', '📷', profile.instagram),
      _SocialItem('TikTok', '🎵', profile.tiktok),
      _SocialItem('LinkedIn', '💼', profile.linkedin),
      _SocialItem('Snapchat', '👻', profile.snapchat),
      _SocialItem('Pinterest', '📌', profile.pinterest),
    ].where((e) => e.url.trim().isNotEmpty).toList();

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: items
          .map(
            (e) => _SocialChip(emoji: e.emoji, label: e.label, url: e.url),
          )
          .toList(),
    );
  }
}

class _SocialItem {
  final String label;
  final String emoji;
  final String url;
  _SocialItem(this.label, this.emoji, this.url);
}

class _SocialChip extends StatelessWidget {
  const _SocialChip(
      {required this.emoji, required this.label, required this.url});
  final String emoji;
  final String label;
  final String url;

  @override
  Widget build(BuildContext context) {
    final normalized = normalizeUrl(url);
    return InkWell(
      onTap: () async {
        final uri = Uri.parse(normalized);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.06),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.12)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 14)),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(fontSize: 13, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
