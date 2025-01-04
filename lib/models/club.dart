class Club {
  final String id;
  final String name;
  final String logoUrl;
  final int points;

  Club({
    required this.id,
    required this.name,
    required this.logoUrl,
    required this.points,
  });

  factory Club.fromJson(Map<String, dynamic> json) {
    return Club(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      logoUrl: json['logoUrl'] ?? '',
      points: json['points'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'logoUrl': logoUrl,
      'points': points,
    };
  }
}
