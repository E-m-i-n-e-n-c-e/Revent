import 'package:cloud_firestore/cloud_firestore.dart';

// We write firebase functions here

Future<List<Map<String, dynamic>>> loadEvents() async {
  final firestore = FirebaseFirestore.instance;
  final events = await firestore.collection('events').orderBy('date').get();

  final eventList = events.docs.map((doc) => doc.data()).toList();
  return eventList;
}

Future<List<Map<String, dynamic>>> loadEventsByDate(DateTime date) async {
  final events = await loadEvents();
  final eventsByDate = events.where((event) => event['date'] == date).toList();
  return eventsByDate;
}

Future<List<Map<String, dynamic>>> loadTodayEvents() async {
  return loadEventsByDate(DateTime.now());
}

Future<List<Map<String, dynamic>>> loadEventsByDateRange(
    DateTime startDate, DateTime endDate) async {
  final events = await loadEvents();
  final eventsByDateRange = events
      .where((event) => event['date'] >= startDate && event['date'] <= endDate)
      .toList();
  return eventsByDateRange;
}

Future<String> sendEvent(Map<String, dynamic> eventJson) async {
  final firestore = FirebaseFirestore.instance;
  final docRef = await firestore.collection('events').add(eventJson);
  await docRef.update({'id': docRef.id});
  return docRef.id;
}

Future<void> updateEvent(String eventId, Map<String, dynamic> eventJson) async {
  final firestore = FirebaseFirestore.instance;
  await firestore.collection('events').doc(eventId).update(eventJson);
}

Future<void> deleteEvent(String eventId) async {
  final firestore = FirebaseFirestore.instance;
  await firestore.collection('events').doc(eventId).delete();
}
