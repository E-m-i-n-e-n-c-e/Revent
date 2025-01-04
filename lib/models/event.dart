class Event {
  final String title;
  final String description;
  final String imageUrl;
  final String time;
  final String clubId;
  final DateTime date;

  Event({
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.time,
    required this.clubId,
    required this.date,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      time: json['time'] ?? '',
      clubId: json['clubId'] ?? '',
      date: DateTime.parse(json['date'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'time': time,
      'clubId': clubId,
      'date': date.toIso8601String(),
    };
  }
}
