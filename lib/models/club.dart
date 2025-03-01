class Club {
  final String id;
  final String name;
  final String logoUrl;
  final String backgroundImageUrl;

  Club({
    required this.id,
    required this.name,
    required this.logoUrl,
    required this.backgroundImageUrl,
  });

  factory Club.fromJson(Map<String, dynamic> json) {
    return Club(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      logoUrl: json['logoUrl'] ?? '',
      backgroundImageUrl: json['backgroundImageUrl'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'logoUrl': logoUrl,
      'backgroundImageUrl': backgroundImageUrl,
    };
  }
}
