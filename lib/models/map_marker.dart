import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:latlong2/latlong.dart';

class MapMarker {
  final String id;
  final LatLng position;
  String title;
  String description;
  String? imageUrl;
  final DateTime createdAt;

  MapMarker({
    required this.id,
    required this.position,
    required this.title,
    required this.description,
    this.imageUrl,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'position': {
        'latitude': position.latitude,
        'longitude': position.longitude,
      },
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory MapMarker.fromJson(Map<String, dynamic> json) {
    return MapMarker(
      id: json['id'] as String,
      position: LatLng(
        json['position']['latitude'] as double,
        json['position']['longitude'] as double,
      ),
      title: json['title'] as String,
      description: json['description'] as String,
      imageUrl: json['imageUrl'] as String?,
      createdAt: (json['createdAt'] as Timestamp).toDate(),
    );
  }
}