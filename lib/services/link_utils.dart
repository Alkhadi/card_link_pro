// lib/services/link_utils.dart
import 'package:flutter/material.dart';

/// Adds https:// if missing and validates host. Never appends trailing junk.
String? normalizeUrl(String? input) {
  final raw = (input ?? '').trim();
  if (raw.isEmpty) return null;

  final prefixed = raw.startsWith(RegExp(r'^[a-z]+://', caseSensitive: false))
      ? raw
      : 'https://$raw';

  final uri = Uri.tryParse(prefixed);
  if (uri == null) return null;
  if (!uri.hasScheme || (uri.host.isEmpty && uri.path.isEmpty)) return null;

  // Remove fragment-only (#) and ensure toString() is stable
  final cleaned = uri.replace(fragment: '').toString();
  return cleaned;
}

bool isValidUrl(String? input) => normalizeUrl(input) != null;

/// Map a URL to a representative Material icon.
IconData serviceIconForUrl(String? input) {
  final u = (input ?? '').toLowerCase();
  if (u.contains('whatsapp')) return Icons.sms_outlined;
  if (u.contains('facebook')) return Icons.facebook;
  if (u.contains('x.com') || u.contains('twitter'))
    return Icons.alternate_email;
  if (u.contains('instagram')) return Icons.camera_alt_outlined;
  if (u.contains('linkedin')) return Icons.business_center_outlined;
  if (u.contains('youtube')) return Icons.ondemand_video_outlined;
  if (u.contains('tiktok')) return Icons.music_note_outlined;
  if (u.contains('snapchat')) return Icons.chat_bubble_outline;
  if (u.contains('pinterest')) return Icons.push_pin_outlined;
  if (u.contains('github')) return Icons.code;
  return Icons.link;
}

/// Helpers for actionable URIs
Uri telUri(String phone) => Uri(scheme: 'tel', path: phone);

Uri smsUri(String body) => Uri(scheme: 'sms', queryParameters: {'body': body});

Uri mailtoUri(String email, {String? subject, String? body}) =>
    Uri(scheme: 'mailto', path: email, queryParameters: {
      if (subject != null) 'subject': subject,
      if (body != null) 'body': body,
    });
