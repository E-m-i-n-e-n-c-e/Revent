import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:events_manager/models/announcement.dart';
import 'package:events_manager/models/club.dart';
import 'package:events_manager/models/event.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Stream<List<Map<String, dynamic>>> loadEventsStream() {
  final firestore = FirebaseFirestore.instance;
  final events = firestore.collection('events').snapshots();
  return events.map((event) => event.docs.map((doc) => doc.data()).toList());
}

Stream<List<Map<String, dynamic>>> loadTodaysEventsStream() {
  final firestore = FirebaseFirestore.instance;
  final now = DateTime.now();
  final startOfDay = DateTime(now.year, now.month, now.day);
  final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

  return firestore
      .collection('events')
      .where('startTime',
          isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
      .where('startTime', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
      .orderBy('startTime')
      .snapshots()
      .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
}

Stream<List<Map<String, dynamic>>> loadAnnouncementsStream() {
  final firestore = FirebaseFirestore.instance;
  return firestore.collection('announcements').snapshots().map((snapshot) {
    final List<Map<String, dynamic>> allAnnouncements = [];
    for (var doc in snapshot.docs) {
      if (doc.data().containsKey('announcementsList')) {
        final List<dynamic> announcementsList = doc.data()['announcementsList'];
        allAnnouncements.addAll(announcementsList.cast<Map<String, dynamic>>());
      }
    }
    allAnnouncements.sort((a, b) => b['date'].compareTo(a['date'])); //descending
    return allAnnouncements;
  });
}

final eventsStreamProvider = StreamProvider<List<Event>>((ref) {
  return loadEventsStream().map(
    (eventsList) =>
        eventsList.map((eventData) => Event.fromJson(eventData)).toList(),
  );
});

final todaysEventsStreamProvider = StreamProvider<List<Event>>((ref) {
  return loadTodaysEventsStream().map(
    (eventsList) =>
        eventsList.map((eventData) => Event.fromJson(eventData)).toList(),
  );
});

final announcementsStreamProvider = StreamProvider<List<Announcement>>((ref) {
  return loadAnnouncementsStream().map(
    (announcementsList) =>
        announcementsList.map((json) => Announcement.fromJson(json)).toList()
          ..sort((a, b) => b.date.compareTo(a.date)),
  );
});

// New providers for search functionality
final searchQueryProvider = StateProvider<String>((ref) => '');
final searchFilterProvider = StateProvider<String>((ref) => 'All');

final searchResultsProvider = Provider<List<dynamic>>((ref) {
  final query = ref.watch(searchQueryProvider);
  final filter = ref.watch(searchFilterProvider);
  final events = ref.watch(eventsStreamProvider).value ?? [];
  final announcements = ref.watch(announcementsStreamProvider).value ?? [];
  final clubs = ref.watch(clubsStreamProvider).value ?? [];

  if (query.isEmpty) return [];

  List<dynamic> results = [];
  final searchQuery = query.toLowerCase();

  // Helper function to get club name
  String getClubName(String clubId) {
    final club = clubs.firstWhere(
      (club) => club.id == clubId,
      orElse: () => Club(id: '', name: '', logoUrl: '', backgroundImageUrl: ''),
    );
    return club.name;
  }

  if (filter == 'All' || filter == 'Events') {
    results.addAll(events.where((event) =>
        event.title.toLowerCase().contains(searchQuery) ||
        event.description.toLowerCase().contains(searchQuery) ||
        event.clubId.toLowerCase().contains(searchQuery) ||
        getClubName(event.clubId).toLowerCase().contains(searchQuery)));
  }

  if (filter == 'All' || filter == 'Announcements') {
    results.addAll(announcements.where((announcement) =>
        announcement.title.toLowerCase().contains(searchQuery) ||
        announcement.subtitle.toLowerCase().contains(searchQuery) ||
        announcement.description.toLowerCase().contains(searchQuery) ||
        announcement.venue.toLowerCase().contains(searchQuery) ||
        announcement.time.toLowerCase().contains(searchQuery) ||
        announcement.clubId.toLowerCase().contains(searchQuery) ||
        getClubName(announcement.clubId).toLowerCase().contains(searchQuery)));
  }

  if (filter == 'All' || filter == 'Clubs') {
    results.addAll(clubs.where((club) =>
        club.name.toLowerCase().contains(searchQuery) ||
        club.id.toLowerCase().contains(searchQuery)));
  }

  return results;
});

// Add clubs stream provider
Stream<List<Map<String, dynamic>>> loadClubsStream() {
  final firestore = FirebaseFirestore.instance;
  return firestore
      .collection('clubs')
      .snapshots()
      .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
}

final clubsStreamProvider = StreamProvider<List<Club>>((ref) {
  return loadClubsStream().map(
    (clubsList) =>
        clubsList.map((clubData) => Club.fromJson(clubData)).toList(),
  );
});
