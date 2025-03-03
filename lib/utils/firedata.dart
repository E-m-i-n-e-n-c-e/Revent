import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:events_manager/models/announcement.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<List<Map<String, dynamic>>> loadEvents() async {
  final firestore = FirebaseFirestore.instance;
  final events =
      await firestore.collection('events').orderBy('startTime').get();

  final eventList = events.docs.map((doc) => doc.data()).toList();
  return eventList;
}

Future<List<Map<String, dynamic>>> loadEventsByDate(DateTime date) async {
  final events = await loadEvents();
  final eventsByDate = events.where((event) {
    final eventDate = event['startTime'].toDate();
    return eventDate.year == date.year &&
        eventDate.month == date.month &&
        eventDate.day == date.day;
  }).toList();
  return eventsByDate;
}

Future<List<Map<String, dynamic>>> loadTodayEvents() async {
  return loadEventsByDate(DateTime.now());
}

Future<List<Map<String, dynamic>>> loadEventsByDateRange(
    DateTime startDate, DateTime endDate) async {
  final firestore = FirebaseFirestore.instance;

  // Convert to Timestamps for Firestore query
  final startTimestamp = Timestamp.fromDate(startDate);
  final endTimestamp = Timestamp.fromDate(endDate);

  final events = await firestore
      .collection('events')
      .where('startTime', isGreaterThanOrEqualTo: startTimestamp)
      .where('startTime', isLessThanOrEqualTo: endTimestamp)
      .orderBy('startTime')
      .get();

  final eventList = events.docs.map((doc) => doc.data()).toList();

  return eventList;
}

Future<String> sendEvent(Map<String, dynamic> eventJson) async {
  final firestore = FirebaseFirestore.instance;
  final docRef = await firestore.collection('events').add(eventJson);
  await docRef.update({'id': docRef.id});
  return docRef.id;
}

Future<void> updateEvent(String eventId, Map<String, dynamic> eventJson) async {
  final firestore = FirebaseFirestore.instance;
  eventJson['id'] = eventId;
  await firestore.collection('events').doc(eventId).update(eventJson);
}

Future<void> deleteEvent(String eventId) async {
  try {
    final firestore = FirebaseFirestore.instance;
    await firestore.collection('events').doc(eventId).delete();
  } catch (e) {
    rethrow;
  }
}

// Announcements Firebase Functions
Future<List<Announcement>> loadAnnouncementsbyClubId(String clubId) async {
  try {
    final firestore = FirebaseFirestore.instance;
    final doc = await firestore.collection('announcements').doc(clubId).get();

    if (!doc.exists || !doc.data()!.containsKey('announcementsList')) {
      return [];
    }

    final List<dynamic> announcementsList = doc.data()!['announcementsList'];
    return announcementsList
        .map((json) => Announcement.fromJson(json))
        .toList();
  } catch (e) {
    return [];
  }
}

Future<List<Announcement>> loadAllAnnouncements() async {
  final firestore = FirebaseFirestore.instance;
  final clubIdsList = await firestore.collection('announcements').get();
  final clubIds = clubIdsList.docs.map((doc) => doc.id).toList();
  final announcements = await Future.wait(
      clubIds.map((clubId) => loadAnnouncementsbyClubId(clubId)));
  final allAnnouncements =
      announcements.expand((announcements) => announcements).toList();
  allAnnouncements.sort((a, b) =>
      b.date.compareTo(a.date)); // Order announcements by date ascending
  return allAnnouncements;
}

Future<void> addAnnouncement(Announcement announcement) async {
  try {
    final firestore = FirebaseFirestore.instance;
    final docRef =
        firestore.collection('announcements').doc(announcement.clubId);

    final doc = await docRef.get();
    List<Map<String, dynamic>> announcementsList = [];

    if (doc.exists && doc.data()!.containsKey('announcementsList')) {
      announcementsList =
          List<Map<String, dynamic>>.from(doc.data()!['announcementsList']);
    }

    announcementsList.insert(0, announcement.toJson());
    announcementsList = announcementsList.take(20).toList();

    await docRef.set({'announcementsList': announcementsList});
  } catch (e) {
    rethrow;
  }
}

Future<void> updateAnnouncement(
    String clubId, int index, Announcement announcement) async {
  try {
    final firestore = FirebaseFirestore.instance;
    final docRef = firestore.collection('announcements').doc(clubId);

    final doc = await docRef.get();
    if (!doc.exists || !doc.data()!.containsKey('announcementsList')) {
      throw Exception('No announcements found');
    }

    List<Map<String, dynamic>> announcementsList =
        List<Map<String, dynamic>>.from(doc.data()!['announcementsList']);
    if (index >= announcementsList.length) {
      throw Exception('Invalid announcement index');
    }

    announcementsList[index] = announcement.toJson();

    await docRef.update({'announcementsList': announcementsList});
  } catch (e) {
    rethrow;
  }
}

Future<void> deleteAnnouncement(String clubId, int index) async {
  try {
    final firestore = FirebaseFirestore.instance;
    final docRef = firestore.collection('announcements').doc(clubId);

    final doc = await docRef.get();
    if (!doc.exists || !doc.data()!.containsKey('announcementsList')) {
      throw Exception('No announcements found');
    }

    List<Map<String, dynamic>> announcementsList =
        List<Map<String, dynamic>>.from(doc.data()!['announcementsList']);
    if (index >= announcementsList.length) {
      throw Exception('Invalid announcement index');
    }

    announcementsList.removeAt(index);

    await docRef.update({'announcementsList': announcementsList});
  } catch (e) {
    rethrow;
  }
}

// Supabase Storage Function
Future<String> uploadAnnouncementImage(String filePath) async {
  try {
    final supabase = Supabase.instance.client;
    final file = File(filePath);
    final fileExt = filePath.split('.').last;
    final fileName = '${DateTime.now().millisecondsSinceEpoch}.$fileExt';

    await supabase.storage
        .from('assets')
        .upload('announcements/$fileName', file);

    final imageUrl =
        supabase.storage.from('assets').getPublicUrl('announcements/$fileName');

    return imageUrl;
  } catch (e) {
    rethrow;
  }
}

Future<void> updateClubBackground(String clubId, String imageUrl) async {
  final firestore = FirebaseFirestore.instance;
  await firestore.collection('clubs').doc(clubId).update({'backgroundImageUrl': imageUrl});
}

Future<void> updateClubLogo(String clubId, String imageUrl) async {
  final firestore = FirebaseFirestore.instance;
  await firestore.collection('clubs').doc(clubId).update({'logoUrl': imageUrl});
}

Future<void> updateClubDetails(String clubId, {
  String? name,
  String? about,
  List<String>? adminEmails,
}) async {
  final firestore = FirebaseFirestore.instance;
  final Map<String, dynamic> updateData = {};

  if (name != null) updateData['name'] = name;
  if (about != null) updateData['about'] = about;
  if (adminEmails != null) updateData['adminEmails'] = adminEmails;

  if (updateData.isNotEmpty) {
    await firestore.collection('clubs').doc(clubId).update(updateData);
  }
}

Future<String> uploadClubImage(String clubId, String filePath, String type) async {
  try {
    final supabase = Supabase.instance.client;
    final file = File(filePath);
    final fileExt = filePath.split('.').last;
    final fileName = '${DateTime.now().millisecondsSinceEpoch}.$fileExt';
    final path = 'clubs/$clubId/${type}_$fileName';

    await supabase.storage.from('assets').upload(path, file);
    final imageUrl = supabase.storage.from('assets').getPublicUrl(path);

    return imageUrl;
  } catch (e) {
    rethrow;
  }
}

Future<void> updateEventLinks(String eventId, {String? registrationLink, String? feedbackLink}) async {
  try {
    final firestore = FirebaseFirestore.instance;
    final Map<String, dynamic> updateData = {};

    if (registrationLink != null) {
      updateData['registrationLink'] = registrationLink;
    }

    if (feedbackLink != null) {
      updateData['feedbackLink'] = feedbackLink;
    }

    if (updateData.isNotEmpty) {
      await firestore.collection('events').doc(eventId).update(updateData);
    }
  } catch (e) {
    rethrow;
  }
}
