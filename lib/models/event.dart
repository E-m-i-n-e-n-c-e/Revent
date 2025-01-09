class Event {
  final String title;
  final String description;
  final DateTime startTime;
  final DateTime endTime;
  final String clubId;
  final String? venue;
  String? id;
  Event({
    required this.title,
    required this.description,
    required this.startTime,
    required this.endTime,
    required this.clubId,
    this.venue,
    this.id,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      startTime:
          DateTime.parse(json['startTime'] ?? DateTime.now().toIso8601String()),
      endTime: DateTime.parse(json['endTime'] ??
          DateTime.now().add(const Duration(hours: 1)).toIso8601String()),
      clubId: json['clubId'] ?? '',
      venue: json['venue'],
      id: json['id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'clubId': clubId,
      'venue': venue,
      'id': id,
    };
  }
}
