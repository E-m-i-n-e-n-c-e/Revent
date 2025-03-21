import 'package:cloud_firestore/cloud_firestore.dart';

class Event {
  final String title;
  final String description;
  final DateTime startTime;
  final DateTime endTime;
  final String clubId;
  final String? venue;
  final String? id;
  final String? registrationLink;
  final String? feedbackLink;

  Event({
    required this.title,
    required this.description,
    required this.startTime,
    required this.endTime,
    required this.clubId,
    this.venue,
    this.id,
    this.registrationLink,
    this.feedbackLink,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    // Handle both Timestamp and String formats for dates
    return Event(
      id: json['id'] as String?,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      startTime: json['startTime'].toDate(),
      endTime: json['endTime'].toDate(),
      clubId: json['clubId'] as String? ?? '',
      venue: json['venue'] as String?,
      registrationLink: json['registrationLink'] as String?,
      feedbackLink: json['feedbackLink'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'startTime': Timestamp.fromDate(startTime),
      'endTime': Timestamp.fromDate(endTime),
      'clubId': clubId,
      'venue': venue,
      'registrationLink': registrationLink,
      'feedbackLink': feedbackLink,
    };
  }

  // Create a copy of the event with some fields updated
  Event copyWith({
    String? title,
    String? description,
    DateTime? startTime,
    DateTime? endTime,
    String? clubId,
    String? venue,
    String? id,
    String? registrationLink,
    String? feedbackLink,
  }) {
    return Event(
      title: title ?? this.title,
      description: description ?? this.description,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      clubId: clubId ?? this.clubId,
      venue: venue ?? this.venue,
      id: id ?? this.id,
      registrationLink: registrationLink ?? this.registrationLink,
      feedbackLink: feedbackLink ?? this.feedbackLink,
    );
  }
}
