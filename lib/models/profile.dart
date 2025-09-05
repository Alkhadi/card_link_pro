// title=lib/models/profile.dart

class Profile {
  final String name;
  final String title;
  final String phone;
  final String email;
  final String website;
  final String address;
  final String story;

  /// Asset paths (or absolute file paths if you decide later)
  final String backgroundAsset;
  final String avatarAsset;

  /// service name -> url (e.g. {"WhatsApp": "whatsapp.com"})
  final Map<String, String> links;

  const Profile({
    required this.name,
    required this.title,
    required this.phone,
    required this.email,
    required this.website,
    required this.address,
    required this.story,
    required this.backgroundAsset,
    required this.avatarAsset,
    this.links = const {},
  });

  Profile copyWith({
    String? name,
    String? title,
    String? phone,
    String? email,
    String? website,
    String? address,
    String? story,
    String? backgroundAsset,
    String? avatarAsset,
    Map<String, String>? links,
  }) {
    return Profile(
      name: name ?? this.name,
      title: title ?? this.title,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      website: website ?? this.website,
      address: address ?? this.address,
      story: story ?? this.story,
      backgroundAsset: backgroundAsset ?? this.backgroundAsset,
      avatarAsset: avatarAsset ?? this.avatarAsset,
      links: links ?? this.links,
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
        backgroundAsset: 'assets/images/placeholders/background/bg1.jpg',
        avatarAsset: 'assets/images/placeholders/profile/alkhadi.png',
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
        'backgroundAsset': backgroundAsset,
        'avatarAsset': avatarAsset,
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
        backgroundAsset: (map['backgroundAsset'] ??
            'assets/images/placeholders/background/bg1.jpg') as String,
        avatarAsset: (map['avatarAsset'] ??
            'assets/images/placeholders/profile/alkhadi.png') as String,
        links: Map<String, String>.from(map['links'] ?? const {}),
      );
}
