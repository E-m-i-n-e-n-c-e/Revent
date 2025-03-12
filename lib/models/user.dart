import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final String uid;
  final String name;
  final String email;
  final String? photoURL;
  final String? backgroundImageUrl;
  final String? rollNumber;
  String? clubId;
  final DateTime createdAt;
  final DateTime lastLogin;

  AppUser({
    required this.uid,
    required this.name,
    required this.email,
    this.photoURL,
    this.backgroundImageUrl,
    this.rollNumber,
    this.clubId,
    required this.createdAt,
    required this.lastLogin,
  });

  AppUser copyWith({
    String? name,
    String? email,
    String? photoURL,
    String? backgroundImageUrl,
    String? rollNumber,
    String? clubId,
    DateTime? createdAt,
    DateTime? lastLogin,
  }) {
    return AppUser(
      uid: uid,
      name: name ?? this.name,
      email: email ?? this.email,
      photoURL: photoURL ?? this.photoURL,
      backgroundImageUrl: backgroundImageUrl ?? this.backgroundImageUrl,
      rollNumber: rollNumber ?? this.rollNumber,
      clubId: clubId ?? this.clubId,
      createdAt: createdAt ?? this.createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'photoURL': photoURL,
      'backgroundImageUrl': backgroundImageUrl,
      'rollNumber': rollNumber,
      'clubId': clubId,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastLogin': Timestamp.fromDate(lastLogin),
    };
  }

  factory AppUser.fromJson(Map<String, dynamic> json) {
    final createdAtValue = json['createdAt'];
    final lastLoginValue = json['lastLogin'];

    final DateTime createdAt = createdAtValue.toDate();
    final DateTime lastLogin = lastLoginValue.toDate();

    return AppUser(
      uid: json['uid'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      photoURL: json['photoURL'] as String?,
      backgroundImageUrl: json['backgroundImageUrl'] as String?,
      rollNumber: json['rollNumber'] as String?,
      clubId: json['clubId'] as String?,
      createdAt: createdAt,
      lastLogin: lastLogin,
    );
  }

  factory AppUser.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AppUser.fromJson(data);
  }

  static Future<AppUser?> fromUid(String uid) async {
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (doc.exists) {
        return AppUser.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}