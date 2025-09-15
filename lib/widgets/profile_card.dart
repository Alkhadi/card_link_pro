import 'dart:io';

import 'package:flutter/material.dart';

import '../models/profile.dart';
import '../services/bank_launcher.dart';
import 'package:url_launcher/url_launcher.dart';

/// Displays a profile card with avatar, name, role and contact
/// information.  The card respects the profile’s background image or
/// colour.  Tapping on the phone, email, website or address rows
/// launches the appropriate intent (e.g. mailto, tel, maps).  Bank
/// details are rendered at the bottom with a button that triggers
/// [BankLauncher.confirmAndLaunch] after copying the details to the
/// clipboard.
class ProfileCard extends StatelessWidget {
  const ProfileCard({super.key, required this.profile});
  final Profile profile;

  Future<void> _launchUrl(BuildContext context, Uri url) async {
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Could not launch $url')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final String? bgPath = profile.backgroundPath;
    final Color bgColor = profile.backgroundColor ?? Colors.grey[200]!;

    // Determine a suitable content colour based on the background.  For
    // image backgrounds we default to white for maximum contrast.  When a
    // background colour is specified we approximate brightness using
    // ThemeData.estimateBrightnessForColor and pick white for dark
    // backgrounds and black for light backgrounds.
    final Color contentColor;
    if (bgPath != null) {
      contentColor = Colors.white;
    } else {
      final brightness = ThemeData.estimateBrightnessForColor(bgColor);
      contentColor = brightness == Brightness.dark ? Colors.white : Colors.black;
    }

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Background
          if (bgPath != null)
            Positioned.fill(
              child: bgPath.startsWith('assets/')
                  ? Image.asset(bgPath, fit: BoxFit.cover)
                  : Image.file(File(bgPath), fit: BoxFit.cover),
            )
          else
            Positioned.fill(child: Container(color: bgColor)),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: CircleAvatar(
                    radius: 40,
                    backgroundImage: profile.avatarPath != null
                        ? (profile.avatarPath!.startsWith('assets/')
                            ? AssetImage(profile.avatarPath!) as ImageProvider<Object>
                            : FileImage(File(profile.avatarPath!)) as ImageProvider<Object>)
                        : null,
                    child: profile.avatarPath == null
                        ? Text(
                            profile.fullName.isNotEmpty
                                ? profile.fullName[0].toUpperCase()
                                : '?',
                            style: TextStyle(fontSize: 32, color: contentColor),
                          )
                        : null,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  profile.fullName,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: contentColor,
                      ),
                ),
                if (profile.role.isNotEmpty)
                  Text(
                    profile.role,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: contentColor.withOpacity(0.8),
                        ),
                  ),
                const SizedBox(height: 16),
                _contactRow(
                  context,
                  icon: Icons.location_on,
                  label: profile.address,
                  color: contentColor,
                  onTap: () async {
                    final q = Uri.encodeComponent(profile.address);
                    await _launchUrl(
                        context, Uri.parse('https://www.google.com/maps/search/?api=1&query=$q'));
                  },
                ),
                _contactRow(
                  context,
                  icon: Icons.phone,
                  label: profile.phone,
                  color: contentColor,
                  onTap: () async =>
                      _launchUrl(context, Uri.parse('tel:${profile.phone}')),
                ),
                _contactRow(
                  context,
                  icon: Icons.email,
                  label: profile.email,
                  color: contentColor,
                  onTap: () async =>
                      _launchUrl(context, Uri.parse('mailto:${profile.email}')),
                ),
                _contactRow(
                  context,
                  icon: Icons.link,
                  label: profile.website,
                  color: contentColor,
                  onTap: () async =>
                      _launchUrl(context, Uri.parse(_ensureHttp(profile.website))),
                ),
                const SizedBox(height: 16),
                // Bank section with send money action
                Text('Bank Details',
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(fontWeight: FontWeight.bold, color: contentColor)),
                Text('Sort code: ${profile.bankSortCode}',
                    style: TextStyle(color: contentColor)),
                Text('Account: ${profile.bankAccountNumber}',
                    style: TextStyle(color: contentColor)),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: () async {
                    // Use default bank name null to just copy details
                    await BankLauncher.confirmAndLaunch(context, profile);
                  },
                  icon: Icon(Icons.attach_money_rounded, color: contentColor),
                  label: Text('Send Money', style: TextStyle(color: contentColor)),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: contentColor),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Renders a single contact row with an icon and label.  The optional
  /// [color] parameter controls the colour of both the icon and the text
  /// allowing callers to adapt to dark or light backgrounds.
  Widget _contactRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? color,
  }) {
    final Color resolved = color ?? Theme.of(context).iconTheme.color ?? Colors.black;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Icon(icon, size: 18, color: resolved),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: resolved),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _ensureHttp(String input) {
    final t = input.trim();
    if (t.startsWith('http://') || t.startsWith('https://')) return t;
    return 'https://$t';
  }
}