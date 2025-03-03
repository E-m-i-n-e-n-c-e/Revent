class Club {
  final String id;
  final String name;
  final String logoUrl;
  final String backgroundImageUrl;
  final String about;
  final List<String> adminEmails;

  Club({
    required this.id,
    required this.name,
    required this.logoUrl,
    required this.backgroundImageUrl,
    this.about = 'We\'re a group of students passionate about organizing events, workshops, and discussions. Join us to grow your skills and connect with others in the community.',
    this.adminEmails = const [],
  });

  factory Club.fromJson(Map<String, dynamic> json) {
    return Club(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      logoUrl: json['logoUrl'] ?? '',
      backgroundImageUrl: json['backgroundImageUrl'] ?? '',
      about: json['about'] ?? 'We\'re a group of students passionate about organizing events, workshops, and discussions. Join us to grow your skills and connect with others in the community.',
      adminEmails: List<String>.from(json['adminEmails'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'logoUrl': logoUrl,
      'backgroundImageUrl': backgroundImageUrl,
      'about': about,
      'adminEmails': adminEmails,
    };
  }

  Club copyWith({
    String? id,
    String? name,
    String? logoUrl,
    String? backgroundImageUrl,
    String? about,
    List<String>? adminEmails,
  }) {
    return Club(
      id: id ?? this.id,
      name: name ?? this.name,
      logoUrl: logoUrl ?? this.logoUrl,
      backgroundImageUrl: backgroundImageUrl ?? this.backgroundImageUrl,
      about: about ?? this.about,
      adminEmails: adminEmails ?? this.adminEmails,
    );
  }
}
