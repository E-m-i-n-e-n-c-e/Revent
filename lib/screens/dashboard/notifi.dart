// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:intl/intl.dart';
// import 'package:events_manager/services/notification_service.dart';
// import 'package:events_manager/models/club.dart';
// import 'package:events_manager/models/event.dart';
// import 'package:events_manager/screens/dashboard/widgets/announcement_card.dart';
// import 'package:cached_network_image/cached_network_image.dart';

// class NotificationsScreen extends StatefulWidget {
//   const NotificationsScreen({super.key});

//   @override
//   State<NotificationsScreen> createState() => _NotificationsScreenState();
// }

// class _NotificationsScreenState extends State<NotificationsScreen> {
//   late Stream<QuerySnapshot> _notificationsStream;
//   bool _isLoading = true;
//   String? _errorMessage;
//   final NotificationService _notificationService = NotificationService();
//   final Map<String, Club> _clubCache = {};
//   final Map<String, Event> _eventCache = {};

//   @override
//   void initState() {
//     super.initState();
//     _initializeNotificationsStream();
//   }

//   void _initializeNotificationsStream() {
//     try {
//       // Get notifications from the past 48 hours using the notification service
//       _notificationsStream = _notificationService.getRecentNotifications();

//       setState(() {
//         _isLoading = false;
//       });
//     } catch (e) {
//       setState(() {
//         _isLoading = false;
//         _errorMessage = 'Failed to load notifications: $e';
//       });
//     }
//   }

//   Future<void> _markAllAsRead() async {
//     try {
//       setState(() {
//         _isLoading = true;
//       });

//       await _notificationService.markAllAsRead();

//       setState(() {
//         _isLoading = false;
//       });

//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('All notifications marked as read')),
//       );
//     } catch (e) {
//       setState(() {
//         _isLoading = false;
//       });

//       print('Error marking all notifications as read: $e');
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Failed to mark notifications as read: $e')),
//       );
//     }
//   }

//   // Fetch club details with error handling
//   Future<Club?> _getClubDetails(String clubId) async {
//     // Check cache first
//     if (_clubCache.containsKey(clubId)) {
//       return _clubCache[clubId];
//     }

//     try {
//       final clubDoc = await FirebaseFirestore.instance.collection('clubs').doc(clubId).get();
//       if (clubDoc.exists && clubDoc.data() != null) {
//         final clubData = clubDoc.data()!;
//         clubData['id'] = clubId; // Ensure ID is set
//         final club = Club.fromJson(clubData);

//         // Cache the result
//         _clubCache[clubId] = club;
//         return club;
//       }
//     } catch (e) {
//       print('Error fetching club details: $e');
//       // Don't rethrow, just return null
//     }
//     return null;
//   }

//   // Fetch event details with error handling
//   Future<Event?> _getEventDetails(String eventId) async {
//     // Check cache first
//     if (_eventCache.containsKey(eventId)) {
//       return _eventCache[eventId];
//     }

//     try {
//       final eventDoc = await FirebaseFirestore.instance.collection('events').doc(eventId).get();
//       if (eventDoc.exists && eventDoc.data() != null) {
//         final eventData = eventDoc.data()!;
//         eventData['id'] = eventId; // Ensure ID is set
//         final event = Event.fromJson(eventData);

//         // Cache the result
//         _eventCache[eventId] = event;
//         return event;
//       }
//     } catch (e) {
//       print('Error fetching event details: $e');
//       // Don't rethrow, just return null
//     }
//     return null;
//   }

//   // Navigate to announcement detail view
//   void _navigateToAnnouncementDetailView(Event event, Club club) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => AnnouncementDetailView(
//           title: event.title,
//           description: event.description,
//           clubId: club.id,
//           date: event.startTime,
//         ),
//       ),
//     );
//   }

//   // Show event details in a modal bottom sheet
//   void _showEventDetails(Event event, Club club) {
//     final isPastEvent = DateTime.now().isAfter(event.endTime);
//     final timeRange = '${DateFormat('h:mm a').format(event.startTime)} - ${DateFormat('h:mm a').format(event.endTime)}';
//     final dateFormatted = DateFormat('EEE, MMM d').format(event.startTime);

//     showModalBottomSheet(
//       context: context,
//       backgroundColor: const Color(0xFF0F2027),
//       isScrollControlled: true,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       builder: (context) => Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 Container(
//                   width: 40,
//                   height: 40,
//                   decoration: BoxDecoration(
//                     shape: BoxShape.circle,
//                     color: const Color(0xFF17323D),
//                   ),
//                   child: club.logoUrl.isEmpty
//                       ? const Icon(Icons.notifications, color: Colors.white)
//                       : ClipOval(
//                           child: CachedNetworkImage(
//                             imageUrl: club.logoUrl,
//                             fit: BoxFit.cover,
//                             placeholder: (context, url) => const Center(
//                               child: SizedBox(
//                                 width: 20,
//                                 height: 20,
//                                 child: CircularProgressIndicator(
//                                   strokeWidth: 2,
//                                   color: Color(0xFF71C2E4),
//                                 ),
//                               ),
//                             ),
//                             errorWidget: (context, url, error) => const Icon(
//                               Icons.notifications,
//                               color: Colors.white,
//                             ),
//                           ),
//                         ),
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         event.title,
//                         style: const TextStyle(
//                           color: Color(0xFFAEE7FF),
//                           fontSize: 18,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                       Text(
//                         club.name,
//                         style: const TextStyle(
//                           color: Color(0xFF83ACBD),
//                           fontSize: 14,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 16),
//             Text(
//               event.description,
//               style: const TextStyle(
//                 color: Color(0xFFAEE7FF),
//                 fontSize: 14,
//               ),
//             ),
//             const SizedBox(height: 16),
//             Row(
//               children: [
//                 const Icon(
//                   Icons.calendar_today,
//                   color: Color(0xFF83ACBD),
//                   size: 16,
//                 ),
//                 const SizedBox(width: 8),
//                 Text(
//                   dateFormatted,
//                   style: const TextStyle(
//                     color: Color(0xFF83ACBD),
//                     fontSize: 14,
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 8),
//             Row(
//               children: [
//                 const Icon(
//                   Icons.access_time,
//                   color: Color(0xFF83ACBD),
//                   size: 16,
//                 ),
//                 const SizedBox(width: 8),
//                 Text(
//                   timeRange,
//                   style: const TextStyle(
//                     color: Color(0xFF83ACBD),
//                     fontSize: 14,
//                   ),
//                 ),
//               ],
//             ),
//             if (event.venue != null && event.venue!.isNotEmpty) ...[
//               const SizedBox(height: 8),
//               Row(
//                 children: [
//                   const Icon(
//                     Icons.location_on,
//                     color: Color(0xFF83ACBD),
//                     size: 16,
//                   ),
//                   const SizedBox(width: 8),
//                   Expanded(
//                     child: Text(
//                       event.venue!,
//                       style: const TextStyle(
//                         color: Color(0xFF83ACBD),
//                         fontSize: 14,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//             const SizedBox(height: 16),
//             if (isPastEvent && event.feedbackLink != null && event.feedbackLink!.isNotEmpty) ...[
//               SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton(
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: const Color(0xFF0E668A),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                   ),
//                   onPressed: () {
//                     // Launch feedback link
//                     // launchUrlExternal(event.feedbackLink!);
//                   },
//                   child: const Text('GIVE FEEDBACK'),
//                 ),
//               ),
//             ] else if (!isPastEvent && event.registrationLink != null && event.registrationLink!.isNotEmpty) ...[
//               SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton(
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: const Color(0xFF0E668A),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                   ),
//                   onPressed: () {
//                     // Launch registration link
//                     // launchUrlExternal(event.registrationLink!);
//                   },
//                   child: const Text('REGISTER'),
//                 ),
//               ),
//             ],
//             const SizedBox(height: 16),
//             SizedBox(
//               width: double.infinity,
//               child: ElevatedButton(
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: const Color(0xFF173240),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                 ),
//                 onPressed: () {
//                   Navigator.pop(context);
//                   _navigateToAnnouncementDetailView(event, club);
//                 },
//                 child: const Text('VIEW ANNOUNCEMENT'),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (_errorMessage != null) {
//       return Scaffold(
//         body: Container(
//           decoration: const BoxDecoration(
//             gradient: LinearGradient(
//               begin: Alignment.topCenter,
//               end: Alignment.bottomCenter,
//               colors: [
//                 Color.fromRGBO(7, 24, 31, 1),
//                 Colors.black,
//               ],
//             ),
//           ),
//           child: Center(
//             child: Text(
//               _errorMessage!,
//               style: const TextStyle(color: Colors.red),
//             ),
//           ),
//         ),
//       );
//     }

//     return Scaffold(
//       body: Container(
//         decoration: const BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//             colors: [
//               Color.fromRGBO(7, 24, 31, 1),
//               Colors.black,
//             ],
//           ),
//         ),
//         child: SafeArea(
//           child: Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     const Text(
//                       'Notifications',
//                       style: TextStyle(
//                         fontSize: 24,
//                         fontWeight: FontWeight.bold,
//                         color: Color(0xFFAEE7FF),
//                       ),
//                     ),
//                     IconButton(
//                       onPressed: () {
//                         Navigator.pop(context);
//                       },
//                       icon: const Icon(
//                         Icons.close,
//                         color: Color(0xFFAEE7FF),
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 24),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     const Text(
//                       'Last 48 hours',
//                       style: TextStyle(
//                         fontSize: 16,
//                         color: Color(0xFFAEE7FF),
//                       ),
//                     ),
//                     Row(
//                       children: [
//                         TextButton(
//                           onPressed: _markAllAsRead,
//                           child: const Text(
//                             'Mark all as read',
//                             style: TextStyle(
//                               fontSize: 14,
//                               color: Color(0xFF71C2E4),
//                             ),
//                           ),
//                         ),
//                         const SizedBox(width: 8),
//                         Row(
//                           children: [
//                             const Text(
//                               'Sort by',
//                               style: TextStyle(
//                                 fontSize: 14,
//                                 color: Color(0xFF71C2E4),
//                               ),
//                             ),
//                             const SizedBox(width: 4),
//                             const Icon(
//                               Icons.arrow_downward,
//                               size: 14,
//                               color: Color(0xFF71C2E4),
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 16),
//                 Expanded(
//                   child: _isLoading
//                       ? const Center(child: CircularProgressIndicator())
//                       : StreamBuilder<QuerySnapshot>(
//                           stream: _notificationsStream,
//                           builder: (context, snapshot) {
//                             if (snapshot.hasError) {
//                               // Handle different types of errors
//                               String errorMessage = 'Error loading notifications';

//                               if (snapshot.error.toString().contains('permission-denied')) {
//                                 errorMessage = 'Permission denied: You do not have access to these notifications. Please log out and log back in.';
//                               } else if (snapshot.error.toString().contains('FAILED_PRECONDITION') &&
//                                   snapshot.error.toString().contains('index')) {
//                                 errorMessage = 'Notification index is being created. Please try again in a few minutes.';
//                               } else {
//                                 errorMessage = 'Error: ${snapshot.error}';
//                               }

//                               print('Notification error: ${snapshot.error}');

//                               return Center(
//                                 child: Column(
//                                   mainAxisAlignment: MainAxisAlignment.center,
//                                   children: [
//                                     Text(
//                                       errorMessage,
//                                       style: const TextStyle(color: Colors.red),
//                                       textAlign: TextAlign.center,
//                                     ),
//                                     const SizedBox(height: 16),
//                                     ElevatedButton(
//                                       onPressed: () {
//                                         setState(() {
//                                           _isLoading = true;
//                                           _errorMessage = null;
//                                         });
//                                         _initializeNotificationsStream();
//                                       },
//                                       child: const Text('Retry'),
//                                     ),
//                                   ],
//                                 ),
//                               );
//                             }

//                             if (snapshot.connectionState == ConnectionState.waiting) {
//                               return const Center(child: CircularProgressIndicator());
//                             }

//                             final notifications = snapshot.data?.docs ?? [];

//                             if (notifications.isEmpty) {
//                               return const Center(
//                                 child: Text(
//                                   'No notifications in the last 48 hours',
//                                   style: TextStyle(color: Color(0xFFAEE7FF)),
//                                 ),
//                               );
//                             }

//                             // Group notifications by day
//                             final today = DateTime.now();
//                             final yesterday = today.subtract(const Duration(days: 1));

//                             final todayNotifications = <DocumentSnapshot>[];
//                             final yesterdayNotifications = <DocumentSnapshot>[];
//                             final olderNotifications = <DocumentSnapshot>[];

//                             for (var notification in notifications) {
//                               final time = (notification.data() as Map<String, dynamic>)['time'] as Timestamp;
//                               final date = time.toDate();

//                               if (date.year == today.year && date.month == today.month && date.day == today.day) {
//                                 todayNotifications.add(notification);
//                               } else if (date.year == yesterday.year && date.month == yesterday.month && date.day == yesterday.day) {
//                                 yesterdayNotifications.add(notification);
//                               } else {
//                                 olderNotifications.add(notification);
//                               }
//                             }

//                             return ListView(
//                               children: [
//                                 if (todayNotifications.isNotEmpty) ...[
//                                   const Padding(
//                                     padding: EdgeInsets.only(bottom: 8.0),
//                                     child: Text(
//                                       'Today',
//                                       style: TextStyle(
//                                         fontSize: 16,
//                                         fontWeight: FontWeight.bold,
//                                         color: Color(0xFFAEE7FF),
//                                       ),
//                                     ),
//                                   ),
//                                   ...todayNotifications.map((notification) => _buildNotificationCard(notification)),
//                                 ],
//                                 if (yesterdayNotifications.isNotEmpty) ...[
//                                   const Padding(
//                                     padding: EdgeInsets.only(top: 16.0, bottom: 8.0),
//                                     child: Text(
//                                       'Yesterday',
//                                       style: TextStyle(
//                                         fontSize: 16,
//                                         fontWeight: FontWeight.bold,
//                                         color: Color(0xFFAEE7FF),
//                                       ),
//                                     ),
//                                   ),
//                                   ...yesterdayNotifications.map((notification) => _buildNotificationCard(notification)),
//                                 ],
//                                 if (olderNotifications.isNotEmpty) ...[
//                                   const Padding(
//                                     padding: EdgeInsets.only(top: 16.0, bottom: 8.0),
//                                     child: Text(
//                                       'Older',
//                                       style: TextStyle(
//                                         fontSize: 16,
//                                         fontWeight: FontWeight.bold,
//                                         color: Color(0xFFAEE7FF),
//                                       ),
//                                     ),
//                                   ),
//                                   ...olderNotifications.map((notification) => _buildNotificationCard(notification)),
//                                 ],
//                               ],
//                             );
//                           },
//                         ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildNotificationCard(DocumentSnapshot notification) {
//     final data = notification.data() as Map<String, dynamic>;
//     final title = data['title'] as String? ?? 'New Notification';
//     final message = data['message'] as String? ?? 'You have a new notification';
//     final timestamp = data['time'] as Timestamp? ?? Timestamp.now();
//     final tags = List<String>.from(data['tags'] ?? []);
//     final isRead = data['read'] as bool? ?? false;
//     final eventId = data['eventId'] as String?;
//     final clubId = data['clubId'] as String?;

//     // Format time
//     final time = timestamp.toDate();
//     final timeString = DateFormat('hh:mm a').format(time);
//     final dateFormatted = DateFormat('EEE, MMM d').format(time);

//     return FutureBuilder<Club?>(
//       future: clubId != null ? _getClubDetails(clubId) : Future.value(null),
//       builder: (context, clubSnapshot) {
//         final club = clubSnapshot.data;

//         return FutureBuilder<Event?>(
//           future: eventId != null ? _getEventDetails(eventId) : Future.value(null),
//           builder: (context, eventSnapshot) {
//             final event = eventSnapshot.data;
//             final isPastEvent = event != null ? DateTime.now().isAfter(event.endTime) : false;
//             final timeRange = event != null
//                 ? '${DateFormat('h:mm a').format(event.startTime)} - ${DateFormat('h:mm a').format(event.endTime)}'
//                 : timeString;

//             return Card(
//               margin: const EdgeInsets.only(bottom: 12),
//               color: const Color(0xFF0F2027),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(12),
//                 side: BorderSide(
//                   color: !isRead ? const Color(0xFF71C2E4) : const Color(0xFF17323D),
//                   width: 1
//                 ),
//               ),
//               elevation: 4,
//               child: InkWell(
//                 onTap: () async {
//                   try {
//                     // Mark notification as read when tapped
//                     if (!isRead) {
//                       await _notificationService.markAsRead(notification.id);
//                     }

//                     // Show event details if both event and club are available
//                     if (event != null && club != null) {
//                       _showEventDetails(event, club);
//                     }
//                   } catch (e) {
//                     print('Error handling notification tap: $e');
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       SnackBar(content: Text('Error: $e')),
//                     );
//                   }
//                 },
//                 borderRadius: BorderRadius.circular(12),
//                 child: Padding(
//                   padding: const EdgeInsets.all(12),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Row(
//                         children: [
//                           Container(
//                             width: 40,
//                             height: 40,
//                             decoration: BoxDecoration(
//                               shape: BoxShape.circle,
//                               color: const Color(0xFF17323D),
//                             ),
//                             child: club == null || club.logoUrl.isEmpty
//                                 ? const Icon(Icons.notifications, color: Colors.white)
//                                 : ClipOval(
//                                     child: CachedNetworkImage(
//                                       imageUrl: club.logoUrl,
//                                       fit: BoxFit.cover,
//                                       placeholder: (context, url) => const Center(
//                                         child: SizedBox(
//                                           width: 20,
//                                           height: 20,
//                                           child: CircularProgressIndicator(
//                                             strokeWidth: 2,
//                                             color: Color(0xFF71C2E4),
//                                           ),
//                                         ),
//                                       ),
//                                       errorWidget: (context, url, error) => const Icon(
//                                         Icons.notifications,
//                                         color: Colors.white,
//                                       ),
//                                     ),
//                                   ),
//                           ),
//                           const SizedBox(width: 12),
//                           Expanded(
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text(
//                                   title,
//                                   style: const TextStyle(
//                                     color: Color(0xFFAEE7FF),
//                                     fontSize: 16,
//                                     fontWeight: FontWeight.w600,
//                                   ),
//                                   maxLines: 1,
//                                   overflow: TextOverflow.ellipsis,
//                                 ),
//                                 Text(
//                                   club != null ? club.name : 'Notification',
//                                   style: const TextStyle(
//                                     color: Color(0xFF83ACBD),
//                                     fontSize: 12,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                           if (event != null)
//                             Container(
//                               padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                               decoration: BoxDecoration(
//                                 color: isPastEvent
//                                     ? const Color(0xFF173240)
//                                     : const Color(0xFF0E668A),
//                                 borderRadius: BorderRadius.circular(12),
//                               ),
//                               child: Text(
//                                 isPastEvent ? 'Past' : 'Upcoming',
//                                 style: const TextStyle(
//                                   color: Color(0xFFAEE7FF),
//                                   fontSize: 10,
//                                   fontWeight: FontWeight.w500,
//                                 ),
//                               ),
//                             ),
//                         ],
//                       ),
//                       const SizedBox(height: 8),
//                       Text(
//                         message,
//                         style: const TextStyle(color: Color(0xFFAEE7FF)),
//                         maxLines: 2,
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                       const SizedBox(height: 8),
//                       Row(
//                         children: [
//                           const Icon(
//                             Icons.calendar_today,
//                             color: Color(0xFF83ACBD),
//                             size: 12,
//                           ),
//                           const SizedBox(width: 4),
//                           Text(
//                             dateFormatted,
//                             style: const TextStyle(
//                               color: Color(0xFF83ACBD),
//                               fontSize: 12,
//                             ),
//                           ),
//                           const SizedBox(width: 12),
//                           const Icon(
//                             Icons.access_time,
//                             color: Color(0xFF83ACBD),
//                             size: 12,
//                           ),
//                           const SizedBox(width: 4),
//                           Text(
//                             timeRange,
//                             style: const TextStyle(
//                               color: Color(0xFF83ACBD),
//                               fontSize: 12,
//                             ),
//                           ),
//                           if (event != null && event.venue != null && event.venue!.isNotEmpty) ...[
//                             const SizedBox(width: 12),
//                             const Icon(
//                               Icons.location_on,
//                               color: Color(0xFF83ACBD),
//                               size: 12,
//                             ),
//                             const SizedBox(width: 4),
//                             Expanded(
//                               child: Text(
//                                 event.venue!,
//                                 style: const TextStyle(
//                                   color: Color(0xFF83ACBD),
//                                   fontSize: 12,
//                                 ),
//                                 overflow: TextOverflow.ellipsis,
//                               ),
//                             ),
//                           ],
//                         ],
//                       ),
//                       if (tags.isNotEmpty) ...[
//                         const SizedBox(height: 8),
//                         Wrap(
//                           spacing: 4,
//                           runSpacing: 4,
//                           children: tags.map((tag) => Container(
//                             padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
//                             decoration: BoxDecoration(
//                               color: const Color(0xFF173C4D),
//                               borderRadius: BorderRadius.circular(4),
//                             ),
//                             child: Text(
//                               tag,
//                               style: const TextStyle(
//                                 fontSize: 10,
//                                 color: Color(0xFFAEE7FF),
//                               ),
//                             ),
//                           )).toList(),
//                         ),
//                       ],
//                     ],
//                   ),
//                 ),
//               ),
//             );
//           },
//         );
//       },
//     );
//   }
// }