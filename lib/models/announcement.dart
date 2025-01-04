class Announcement {
  final String title;
  final String subtitle;
  final String image;
  final DateTime date;
  final String clubId;

  Announcement({
    required this.title,
    required this.subtitle,
    required this.image,
    required this.date,
    required this.clubId,
  });

  factory Announcement.fromJson(Map<String, dynamic> json) {
    return Announcement(
      title: json['title'] ?? '',
      subtitle: json['subtitle'] ?? '',
      image: json['image'] ?? '',
      date: DateTime.parse(json['date'] ?? DateTime.now().toIso8601String()),
      clubId: json['clubId'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'subtitle': subtitle,
      'image': image,
      'date': date.toIso8601String(),
      'clubId': clubId,
    };
  }
}
