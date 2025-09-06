import 'dart:convert';

class Profile {
  final String name;
  final String title;
  final String phone;
  final String email;
  final String website;

  // Address as multi-line string; stored and displayed exactly as edited
  final String address;

  // Socials (normalized https links)
  final String whatsapp;
  final String facebook;
  final String xTwitter;
  final String youtube;
  final String instagram;
  final String tiktok;
  final String linkedin;
  final String snapchat;
  final String pinterest;

  // Bank + About
  final String bankDetails;
  final String about;

  // Avatar & background
  final String avatarAssetOrPath;
  final String backgroundAssetOrPath;
  final bool usesImageBackground; // if false, use color
  final int backgroundColorValue; // ARGB

  // For future extensibility (e.g., business/personal)
  final bool isBusiness;

  const Profile({
    required this.name,
    required this.title,
    required this.phone,
    required this.email,
    required this.website,
    required this.address,
    required this.whatsapp,
    required this.facebook,
    required this.xTwitter,
    required this.youtube,
    required this.instagram,
    required this.tiktok,
    required this.linkedin,
    required this.snapchat,
    required this.pinterest,
    required this.bankDetails,
    required this.about,
    required this.avatarAssetOrPath,
    required this.backgroundAssetOrPath,
    required this.usesImageBackground,
    required this.backgroundColorValue,
    required this.isBusiness,
  });

  Profile copyWith({
    String? name,
    String? title,
    String? phone,
    String? email,
    String? website,
    String? address,
    String? whatsapp,
    String? facebook,
    String? xTwitter,
    String? youtube,
    String? instagram,
    String? tiktok,
    String? linkedin,
    String? snapchat,
    String? pinterest,
    String? bankDetails,
    String? about,
    String? avatarAssetOrPath,
    String? backgroundAssetOrPath,
    bool? usesImageBackground,
    int? backgroundColorValue,
    bool? isBusiness,
  }) {
    return Profile(
      name: name ?? this.name,
      title: title ?? this.title,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      website: website ?? this.website,
      address: address ?? this.address,
      whatsapp: whatsapp ?? this.whatsapp,
      facebook: facebook ?? this.facebook,
      xTwitter: xTwitter ?? this.xTwitter,
      youtube: youtube ?? this.youtube,
      instagram: instagram ?? this.instagram,
      tiktok: tiktok ?? this.tiktok,
      linkedin: linkedin ?? this.linkedin,
      snapchat: snapchat ?? this.snapchat,
      pinterest: pinterest ?? this.pinterest,
      bankDetails: bankDetails ?? this.bankDetails,
      about: about ?? this.about,
      avatarAssetOrPath: avatarAssetOrPath ?? this.avatarAssetOrPath,
      backgroundAssetOrPath:
          backgroundAssetOrPath ?? this.backgroundAssetOrPath,
      usesImageBackground: usesImageBackground ?? this.usesImageBackground,
      backgroundColorValue: backgroundColorValue ?? this.backgroundColorValue,
      isBusiness: isBusiness ?? this.isBusiness,
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'title': title,
        'phone': phone,
        'email': email,
        'website': website,
        'address': address,
        'whatsapp': whatsapp,
        'facebook': facebook,
        'xTwitter': xTwitter,
        'youtube': youtube,
        'instagram': instagram,
        'tiktok': tiktok,
        'linkedin': linkedin,
        'snapchat': snapchat,
        'pinterest': pinterest,
        'bankDetails': bankDetails,
        'about': about,
        'avatarAssetOrPath': avatarAssetOrPath,
        'backgroundAssetOrPath': backgroundAssetOrPath,
        'usesImageBackground': usesImageBackground,
        'backgroundColorValue': backgroundColorValue,
        'isBusiness': isBusiness,
      };

  factory Profile.fromMap(Map<String, dynamic> map) {
    // Backward compatible defaults
    return Profile(
      name: (map['name'] ?? '').toString(),
      title: (map['title'] ?? '').toString(),
      phone: (map['phone'] ?? '').toString(),
      email: (map['email'] ?? '').toString(),
      website: (map['website'] ?? '').toString(),
      address: (map['address'] ?? '').toString(),
      whatsapp: (map['whatsapp'] ?? '').toString(),
      facebook: (map['facebook'] ?? '').toString(),
      xTwitter: (map['xTwitter'] ?? map['twitter'] ?? '').toString(),
      youtube: (map['youtube'] ?? '').toString(),
      instagram: (map['instagram'] ?? '').toString(),
      tiktok: (map['tiktok'] ?? '').toString(),
      linkedin: (map['linkedin'] ?? '').toString(),
      snapchat: (map['snapchat'] ?? '').toString(),
      pinterest: (map['pinterest'] ?? '').toString(),
      bankDetails: (map['bankDetails'] ?? '').toString(),
      about: (map['about'] ?? '').toString(),
      avatarAssetOrPath:
          (map['avatarAssetOrPath'] ?? 'assets/images/mariatou.png').toString(),
      backgroundAssetOrPath:
          (map['backgroundAssetOrPath'] ?? 'assets/images/amz.jpg').toString(),
      usesImageBackground: (map['usesImageBackground'] ?? true) as bool,
      backgroundColorValue: (map['backgroundColorValue'] ?? 0xFF111827) as int,
      isBusiness: (map['isBusiness'] ?? true) as bool,
    );
  }

  String toJson() => json.encode(toMap());

  factory Profile.fromJson(String source) =>
      Profile.fromMap(json.decode(source) as Map<String, dynamic>);

  static Profile defaultProfile() {
    return const Profile(
      name: 'Mariatou Ngum',
      title: 'Professional Title SCA',
      phone: '07736806367',
      email: 'ngummariatou@gmail.com',
      website: 'https://your-website.com',
      address: 'Flat 72 Priory Court\n1 Cheltenham Road\nLondon\nSE 15 3BG',
      whatsapp: 'https://whatsapp.com',
      facebook: 'https://facebook.com',
      xTwitter: 'https://x.com',
      youtube: 'https://youtube.com',
      instagram: 'https://instagram.com',
      tiktok: 'https://tiktok.com',
      linkedin: 'https://linkedin.com',
      snapchat: 'https://snapchat.com',
      pinterest: 'https://pinterest.com',
      bankDetails: 'Ac number: 93087283   Sc Code: 09-01-35',
      about: 'This is a short bio about yourself. Tell your story here.',
      avatarAssetOrPath: 'assets/images/mariatou.png',
      backgroundAssetOrPath: 'assets/images/amz.jpg',
      usesImageBackground: true,
      backgroundColorValue: 0xFF111827,
      isBusiness: true,
    );
  }
}
