class Announcement {
  final String title;
  final String subtitle;
  final String description;
  final String venue;
  final String time;
  final String? image;
  final String clubId;
  final DateTime date;

  Announcement({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.venue,
    required this.time,
    this.image,
    required this.clubId,
    required this.date,
  });

  factory Announcement.fromJson(Map<String, dynamic> json) {
    return Announcement(
      title: json['title'] ?? '',
      subtitle: json['subtitle'] ?? '',
      description: json['description'] ?? '',
      venue: json['venue'] ?? '',
      time: json['time'] ?? '',
      image: json['image'],
      clubId: json['clubId'] ?? '',
      date: DateTime.parse(json['date'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'subtitle': subtitle,
      'description': description,
      'venue': venue,
      'time': time,
      'image': image,
      'clubId': clubId,
      'date': date.toIso8601String(),
    };
  }
}
