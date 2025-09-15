import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/profile.dart';
import '../services/share_service.dart';
import '../widgets/bank_buttons.dart';
import 'edit_profile_screen.dart';

/// Landing page displaying the user profile.
///
/// This screen loads a stored [Profile] from shared preferences on
/// initialisation and presents the user's avatar, name, contact
/// information and bank details.  The UI adapts colours based on the
/// selected background image or colour to maintain contrast.  A
/// floating action button allows editing the profile, and a share
/// button in the app bar opens a modal with multiple share options
/// (text, PDF + QR, QR image, email).
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Profile _profile;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  /// Load the profile from shared preferences.  Supports both the
  /// modern JSON format and a legacy query string format for backward
  /// compatibility.  If no stored profile is found, the default
  /// profile is used.  Once loaded, the UI is updated by setting
  /// [_loading] to false.
  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString('profile_json');
    final legacyQuery = prefs.getString('profile');
    setState(() {
      if (json != null) {
        _profile = Profile.fromJson(json);
      } else if (legacyQuery != null) {
        final decoded = Uri.decodeComponent(legacyQuery);
        final map = <String, dynamic>{};
        for (final part in decoded.split('&')) {
          final split = part.split('=');
          if (split.isNotEmpty) {
            map[split.first] =
                split.length > 1 ? split.sublist(1).join('=') : '';
          }
        }
        _profile = Profile.fromMap(map);
      } else {
        _profile = Profile.defaultProfile();
      }
      _loading = false;
    });
  }

  Future<void> _saveProfile() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('profile_json', _profile.toJson());
  }

  /// Push the edit screen and await a possibly updated profile.  If the
  /// returned profile is non-null, update [_profile] and persist it.
  Future<void> _editProfile() async {
    final updated = await Navigator.of(context).push<Profile>(
      MaterialPageRoute(builder: (_) => EditProfileScreen(profile: _profile)),
    );
    if (updated != null) {
      setState(() => _profile = updated);
      await _saveProfile();
    }
  }

  /// Open the share modal bottom sheet.  Provides options to share
  /// the profile as text, PDF with QR, QR image, or via email.
  void _openShareSection() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        final bottomInset = MediaQuery.of(ctx).viewPadding.bottom;
        final svc = ShareService(profile: _profile);
        return SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + bottomInset + 20),
            child: Wrap(
              spacing: 16,
              runSpacing: 16,
              alignment: WrapAlignment.center,
              children: [
                _shareTile(
                  icon: Icons.text_snippet_rounded,
                  label: 'Share My Profile as Text',
                  onTap: () async {
                    Navigator.pop(ctx);
                    await svc.shareAsText(ctx);
                  },
                ),
                _shareTile(
                  icon: Icons.picture_as_pdf_rounded,
                  label: 'Share PDF + QR',
                  onTap: () async {
                    Navigator.pop(ctx);
                    await svc.sharePdfWithQr(ctx);
                  },
                ),
                _shareTile(
                  icon: Icons.qr_code_2_rounded,
                  label: 'Share QR Image',
                  onTap: () async {
                    Navigator.pop(ctx);
                    await svc.shareQrImage(ctx);
                  },
                ),
                _shareTile(
                  icon: Icons.email_rounded,
                  label: 'Email My CardLink Pro',
                  onTap: () async {
                    Navigator.pop(ctx);
                    await svc.shareViaEmail(ctx);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Build a tile used in the share sheet.  Each tile includes a
  /// circular icon and a label beneath it.  Tapping the tile invokes
  /// the provided [onTap] callback.
  Widget _shareTile({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: Theme.of(context).colorScheme.primary,
            child: Icon(icon, color: Colors.white),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: 110,
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  /// Launch a URL externally via [url_launcher].  Shows a snackbar on
  /// failure.  Accepts a [Uri] instead of a raw string to avoid
  /// quoting issues.
  Future<void> _launchUrl(Uri url) async {
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not launch $url')),
      );
    }
  }

  /// Ensure a URL string has an HTTP or HTTPS scheme.  If the input
  /// lacks a scheme, `https://` is prefixed.
  static String _ensureHttp(String input) {
    final t = input.trim();
    if (t.startsWith('http://') || t.startsWith('https://')) return t;
    return 'https://$t';
  }

  /// Render the user's avatar.  When no avatar image is set, the
  /// initials of the user's name are displayed using the provided
  /// [foreground] colour.  The avatar is centred horizontally.
  Widget _buildAvatar(Color foreground) {
    final avatarPath = _profile.avatarPath;
    return Center(
      child: CircleAvatar(
        radius: 48,
        backgroundImage: avatarPath != null
            ? (avatarPath.startsWith('assets/')
                ? AssetImage(avatarPath) as ImageProvider
                : FileImage(File(avatarPath)))
            : null,
        child: avatarPath == null
            ? Text(
                _profile.fullName.isNotEmpty
                    ? _profile.fullName[0].toUpperCase()
                    : '?',
                style: TextStyle(fontSize: 40, color: foreground),
              )
            : null,
      ),
    );
  }

  /// Render a row for an individual contact detail (address, phone,
  /// email, website).  The [foreground] colour is applied to both
  /// the icon and the text.  Tapping the row invokes [onTap].
  Widget _contactRow({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required Color foreground,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Icon(icon, size: 20, color: foreground),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(fontSize: 14, color: foreground),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Render the bank details section.  Includes a heading, the user's
  /// name, wellbeing link (if present), account and sort code, and a
  /// set of buttons to open common banking apps.  Colours are
  /// adjusted based on the selected background using the passed
  /// [foreground] colour.  A semi-transparent card background is used
  /// when a background image is present to aid contrast.
  Widget _bankSection(Color foreground) {
    final scheme = Theme.of(context).colorScheme;
    final bool hasBgImage = _profile.backgroundPath != null;
    final Color cardColor = hasBgImage
        ? Colors.black.withOpacity(0.4)
        : scheme.surfaceContainerHighest;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Send/Receive Money (Bank)',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: foreground,
          ),
        ),
        const SizedBox(height: 8),
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          color: cardColor,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: DefaultTextStyle.merge(
              style: TextStyle(color: foreground),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _profile.fullName,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: foreground,
                    ),
                  ),
                  if (_profile.wellbeingLink.isNotEmpty)
                    Text(
                      'Wellbeing: ${_profile.wellbeingLink}',
                      style: TextStyle(color: foreground),
                    ),
                  Text(
                    'Account: ${_profile.bankAccountNumber}',
                    style: TextStyle(color: foreground),
                  ),
                  Text(
                    'Sort: ${_profile.bankSortCode}',
                    style: TextStyle(color: foreground),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Open your banking app with details prefilled:',
                    style: TextStyle(
                      fontSize: 12,
                      color: foreground.withOpacity(0.9),
                    ),
                  ),
                  const SizedBox(height: 8),
                  BankButtons(profile: _profile, foreground: foreground),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final String? bg = _profile.backgroundPath;
    // Resolve a non-null background colour.  Using Colors.grey.shade200
    // ensures we always get a concrete Colour rather than a nullable
    // entry from the Map index operator (e.g. Colors.grey[200]).
    final Color bgColor = _profile.backgroundColor ?? Colors.grey.shade200;

    // Determine the foreground (text/icon) colour based on the
    // background.  Images always use white for maximum contrast.  When
    // a colour is chosen, use brightness estimation to decide between
    // white and a dark colour.
    Color foreground;
    if (bg != null) {
      foreground = Colors.white;
    } else {
      final brightness = ThemeData.estimateBrightnessForColor(bgColor);
      foreground =
          brightness == Brightness.dark ? Colors.white : Colors.black87;
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(
          'My CardLink Pro',
          style: TextStyle(color: foreground),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.share_rounded, color: foreground),
            onPressed: _openShareSection,
          ),
        ],
      ),
      body: Stack(
        children: [
          // Render the background image or colour.  Use a full-screen
          // Positioned.fill to ensure complete coverage.
          if (bg != null)
            Positioned.fill(
              child: bg.startsWith('assets/')
                  ? Image.asset(bg, fit: BoxFit.cover)
                  : Image.file(File(bg), fit: BoxFit.cover),
            )
          else
            Positioned.fill(child: Container(color: bgColor)),
          // Apply a semi-transparent overlay when using an image to
          // improve contrast for text and icons.
          if (bg != null)
            Positioned.fill(
              child: Container(color: Colors.black45),
            ),
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 32, 16, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildAvatar(foreground),
                  const SizedBox(height: 8),
                  Text(
                    _profile.fullName,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: foreground,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  if (_profile.role.isNotEmpty)
                    Text(
                      _profile.role,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: foreground),
                      textAlign: TextAlign.center,
                    ),
                  const SizedBox(height: 16),
                  _contactRow(
                    icon: Icons.location_on,
                    label: _profile.address,
                    onTap: () async {
                      final q = Uri.encodeComponent(_profile.address);
                      await _launchUrl(Uri.parse(
                          'https://www.google.com/maps/search/?api=1&query=$q'));
                    },
                    foreground: foreground,
                  ),
                  _contactRow(
                    icon: Icons.phone,
                    label: _profile.phone,
                    onTap: () async =>
                        _launchUrl(Uri.parse('tel:${_profile.phone}')),
                    foreground: foreground,
                  ),
                  _contactRow(
                    icon: Icons.email,
                    label: _profile.email,
                    onTap: () async =>
                        _launchUrl(Uri.parse('mailto:${_profile.email}')),
                    foreground: foreground,
                  ),
                  _contactRow(
                    icon: Icons.link,
                    label: _profile.website,
                    onTap: () async =>
                        _launchUrl(Uri.parse(_ensureHttp(_profile.website))),
                    foreground: foreground,
                  ),
                  const SizedBox(height: 24),
                  _bankSection(foreground),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: FloatingActionButton(
          onPressed: _editProfile,
          tooltip: 'Edit Profile',
          backgroundColor: Theme.of(context).colorScheme.primary,
          child: const Icon(Icons.edit_rounded, color: Colors.white),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
    );
  }
}