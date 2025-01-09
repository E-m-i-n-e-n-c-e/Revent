import 'package:cloud_firestore/cloud_firestore.dart';

// We write firebase functions here

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
