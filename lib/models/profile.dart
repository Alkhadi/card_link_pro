// title=lib/models/profile.dart
import 'package:flutter/material.dart';

class Profile {
  final String name;
  final String title;
  final String phone;
  final String email;
  final String website;
  final String address;
  final String story;
  final String bankDetails;

  /// If this starts with 'color:<int>', we draw a solid color.
  /// Otherwise it's an asset/file path for an image.
  final String backgroundAsset;
  final String avatarAsset;

  /// For quick “brand” links: {label -> url}
  final Map<String, String> links;

  /// We keep the color value separately for convenience, too.
  final int backgroundColorValue;

  const Profile({
    required this.name,
    required this.title,
    required this.phone,
    required this.email,
    required this.website,
    required this.address,
    required this.story,
    required this.bankDetails,
    required this.backgroundAsset,
    required this.avatarAsset,
    required this.backgroundColorValue,
    this.links = const {},
  });

  /// Helpers used by screens
  bool get usesImageBackground => !backgroundAsset.startsWith('color:');

  Color get backgroundColor => Color(backgroundColorValue);

  Profile copyWith({
    String? name,
    String? title,
    String? phone,
    String? email,
    String? website,
    String? address,
    String? story,
    String? bankDetails,
    String? backgroundAsset,
    String? avatarAsset,
    Map<String, String>? links,
    int? backgroundColorValue,
  }) {
    return Profile(
      name: name ?? this.name,
      title: title ?? this.title,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      website: website ?? this.website,
      address: address ?? this.address,
      story: story ?? this.story,
      bankDetails: bankDetails ?? this.bankDetails,
      backgroundAsset: backgroundAsset ?? this.backgroundAsset,
      avatarAsset: avatarAsset ?? this.avatarAsset,
      links: links ?? this.links,
      backgroundColorValue: backgroundColorValue ?? this.backgroundColorValue,
    );
  }

  factory Profile.defaultProfile() => const Profile(
        name: 'Mariatou Ngum',
        title: 'Professional Title SCA',
        phone: '07736806367',
        email: 'ngummariatou@gmail.com',
        website: 'your-website.com',
        address: 'Flat 72 Priory Court\n1 Cheltenham Road\nLondon\nSE 15 3BG',
        story: '',
        bankDetails: '',
        backgroundAsset: 'assets/images/placeholders/background/bg1.jpg',
        avatarAsset: 'assets/images/alkhadi.png',
        backgroundColorValue: 0xFF111827,
        // Tailwind slate-900-ish
        links: {
          'WhatsApp': 'whatsapp.com',
          'Facebook': 'facebook.com',
          'Twitter X': 'x.com',
          'YouTube': 'youtube.com',
          'Instagram': 'instagram.com',
          'TikTok': 'tiktok.com',
          'LinkedIn': 'linkedin.com',
          'Snapchat': 'snapchat.com',
          'Pinterest': 'pinterest.com',
        },
      );

  Map<String, dynamic> toMap() => {
        'name': name,
        'title': title,
        'phone': phone,
        'email': email,
        'website': website,
        'address': address,
        'story': story,
        'bankDetails': bankDetails,
        'backgroundAsset': backgroundAsset,
        'avatarAsset': avatarAsset,
        'backgroundColorValue': backgroundColorValue,
        'links': links,
      };

  factory Profile.fromMap(Map<String, dynamic> map) => Profile(
        name: (map['name'] ?? '') as String,
        title: (map['title'] ?? '') as String,
        phone: (map['phone'] ?? '') as String,
        email: (map['email'] ?? '') as String,
        website: (map['website'] ?? '') as String,
        address: (map['address'] ?? '') as String,
        story: (map['story'] ?? '') as String,
        bankDetails: (map['bankDetails'] ?? '') as String,
        backgroundAsset: (map['backgroundAsset'] ??
            'assets/images/placeholders/background/bg1.jpg') as String,
        avatarAsset:
            (map['avatarAsset'] ?? 'assets/images/alkhadi.png') as String,
        backgroundColorValue:
            (map['backgroundColorValue'] ?? 0xFF111827) as int,
        links: Map<String, String>.from(map['links'] ?? const {}),
      );
}
