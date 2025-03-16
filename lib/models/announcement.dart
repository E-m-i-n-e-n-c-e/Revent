class Announcement {
  final String title;
  final String description;
  final String clubId;
  final DateTime date;

  Announcement({
    required this.title,
    required this.description,
    required this.clubId,
    required this.date,
  });

  factory Announcement.fromJson(Map<String, dynamic> json) {
    return Announcement(
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      clubId: json['clubId'] ?? '',
      date: DateTime.parse(json['date'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'clubId': clubId,
      'date': date.toIso8601String(),
    };
  }
}
