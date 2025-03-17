// import 'dart:convert';
// import 'dart:io';

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:events_manager/models/event.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:timezone/data/latest.dart' as tz;
// import 'package:firebase_core/firebase_core.dart';

// // Channel IDs for notifications
// const String eventChannelId = 'event_channel';
// const String eventChannelName = 'Event Notifications';
// const String eventChannelDescription = 'Notifications for new events';

// // This function must be top-level (not inside a class)
// @pragma('vm:entry-point')
// Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   // Initialize Firebase for background handler
//   await Firebase.initializeApp();

//   print('Handling a background message: ${message.messageId}');
//   print('Message data: ${message.data}');

//   // Show local notification for the background message
//   final notification = message.notification;
//   if (notification != null) {
//     final androidNotificationDetails = AndroidNotificationDetails(
//       eventChannelId,
//       eventChannelName,
//       channelDescription: eventChannelDescription,
//       importance: Importance.max,
//       priority: Priority.high,
//     );

//     final iosNotificationDetails = const DarwinNotificationDetails(
//       presentAlert: true,
//       presentBadge: true,
//       presentSound: true,
//     );

//     final notificationDetails = NotificationDetails(
//       android: androidNotificationDetails,
//       iOS: iosNotificationDetails,
//     );

//     await FlutterLocalNotificationsPlugin().show(
//       notification.hashCode,
//       notification.title ?? 'New Event',
//       notification.body,
//       notificationDetails,
//     );
//   }
// }

// class NotificationService {
//   static final NotificationService _instance = NotificationService._internal();

//   // Initialize Firebase Messaging and Local Notifications
//   final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
//   final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

//   // Track recently processed event IDs to prevent duplicates
//   final Set<String> _recentlyProcessedEventIds = {};

//   factory NotificationService() {
//     return _instance;
//   }

//   NotificationService._internal();

//   Future<void> initialize() async {
//     try {
//       // Initialize push notification functionality
//       await _initializePushNotifications();

//       // Listen for new events in Firestore
//       _listenForNewEvents();
//     } catch (e) {
//       print('Error initializing notification service: $e');
//     }
//   }

//   Future<void> _initializePushNotifications() async {
//     try {
//       // Initialize timezone
//       tz.initializeTimeZones();

//       // Request permission for notifications
//       NotificationSettings settings = await _firebaseMessaging.requestPermission(
//         alert: true,
//         badge: true,
//         sound: true,
//         provisional: false,
//       );

//       print('User notification permission status: ${settings.authorizationStatus}');

//       // Set the background message handler
//       FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

//       // Request permission for local notifications on iOS
//       if (Platform.isIOS) {
//         await _localNotifications.resolvePlatformSpecificImplementation<
//             IOSFlutterLocalNotificationsPlugin>()?.requestPermissions(
//           alert: true,
//           badge: true,
//           sound: true,
//         );
//       }

//       // Initialize local notifications
//       const AndroidInitializationSettings androidSettings =
//           AndroidInitializationSettings('@mipmap/ic_launcher');

//       final DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
//         requestAlertPermission: false,
//         requestBadgePermission: false,
//         requestSoundPermission: false,
//       );

//       final InitializationSettings initSettings = InitializationSettings(
//         android: androidSettings,
//         iOS: iosSettings,
//       );

//       await _localNotifications.initialize(
//         initSettings,
//         onDidReceiveNotificationResponse: (NotificationResponse response) {
//           // Handle notification tap
//           final String? payload = response.payload;
//           if (payload != null) {
//             print('Notification payload: $payload');
//             // Navigate to appropriate screen based on payload
//           }
//         },
//       );

//       // Create notification channel for Android
//       final AndroidNotificationChannel channel = AndroidNotificationChannel(
//         eventChannelId,
//         eventChannelName,
//         description: eventChannelDescription,
//         importance: Importance.high,
//       );

//       await _localNotifications
//           .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
//           ?.createNotificationChannel(channel);

//       // Handle messages when app is in foreground
//       FirebaseMessaging.onMessage.listen((RemoteMessage message) {
//         print('Got a message whilst in the foreground!');
//         print('Message data: ${message.data}');

//         if (message.notification != null) {
//           print('Message also contained a notification: ${message.notification}');
//           _showLocalNotification(message);
//         }
//       });

//       // Get initial message if app was opened from a terminated state
//       RemoteMessage? initialMessage = await _firebaseMessaging.getInitialMessage();
//       if (initialMessage != null) {
//         print('Initial message: ${initialMessage.data}');
//         // Handle initial message
//       }

//       // Handle message when app is in background and user taps on notification
//       FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
//         print('Message opened app: ${message.data}');
//         // Handle message opened app
//       });

//       // Store FCM token in Firestore for the current user
//       await _storeFcmToken();
//     } catch (e) {
//       print('Error initializing push notifications: $e');
//     }
//   }

//   Future<void> _listenForNewEvents() async {
//     try {
//       // Get the current timestamp
//       final now = Timestamp.now();

//       FirebaseFirestore.instance
//           .collection('events')
//           .where('startTime', isGreaterThan: now)  // Only listen for future events
//           .orderBy('startTime', descending: true)
//           .limit(1)
//           .snapshots()
//           .listen((snapshot) {
//         if (snapshot.docs.isNotEmpty) {
//           final latestEvent = Event.fromJson(snapshot.docs.first.data());

//           // Check if we've already processed this event
//           if (_recentlyProcessedEventIds.contains(latestEvent.id)) {
//             print('Event ${latestEvent.id} already processed, skipping notification');
//             return;
//           }

//           // Only process events created in the last minute
//           final eventDoc = snapshot.docs.first;
//           if (eventDoc.metadata.hasPendingWrites) {
//             // Add to recently processed set
//             _recentlyProcessedEventIds.add(latestEvent.id as String);

//             // Limit the size of the set
//             if (_recentlyProcessedEventIds.length > 100) {
//               final iterator = _recentlyProcessedEventIds.iterator;
//               if (iterator.moveNext()) {
//                 _recentlyProcessedEventIds.remove(iterator.current);
//               }
//             }

//             _storeNotification(latestEvent);
//             _sendPushNotificationForEvent(latestEvent);
//           }
//         }
//       }, onError: (error) {
//         print('Error listening for events: $error');
//       });
//     } catch (e) {
//       print('Error setting up event listener: $e');
//     }
//   }

//   Future<String> _getClubName(String clubId) async {
//     try {
//       final clubDoc = await FirebaseFirestore.instance.collection('clubs').doc(clubId).get();
//       if (clubDoc.exists) {
//         return clubDoc.data()?['name'] ?? 'Unknown Club';
//       }
//       return 'Unknown Club';
//     } catch (e) {
//       print('Error getting club name: $e');
//       return 'Unknown Club';
//     }
//   }

//   Future<void> _storeNotification(Event event) async {
//     try {
//       // Get current user
//       final user = FirebaseAuth.instance.currentUser;
//       if (user == null) {
//         print('No user logged in, cannot store notification');
//         return;
//       }

//       // Check if a notification for this event already exists for this user
//       final existingNotifications = await FirebaseFirestore.instance
//           .collection('notifications')
//           .where('eventId', isEqualTo: event.id)
//           .where('userId', isEqualTo: user.uid)
//           .get();

//       if (existingNotifications.docs.isNotEmpty) {
//         print('Notification for event ${event.id} already exists for user ${user.uid}, skipping');
//         return;
//       }

//       final clubName = await _getClubName(event.clubId);

//       // Store notification with user ID
//       await FirebaseFirestore.instance.collection('notifications').add({
//         'title': 'New Event: ${event.title}',
//         'message': 'A new event has been added by $clubName',
//         'time': Timestamp.now(),
//         'eventId': event.id,
//         'clubId': event.clubId,
//         'tags': [clubName],
//         'read': false,
//         'userId': user.uid, // Add user ID to associate notification with user
//       });
//     } catch (e) {
//       print('Error storing notification: $e');
//     }
//   }

//   Future<void> _sendPushNotificationForEvent(Event event) async {
//     try {
//       final clubName = await _getClubName(event.clubId);

//       // Get all users with FCM tokens
//       final usersSnapshot = await FirebaseFirestore.instance.collection('users').get();

//       for (var userDoc in usersSnapshot.docs) {
//         final userData = userDoc.data();
//         final fcmToken = userData['fcmToken'] as String?;

//         if (fcmToken != null && fcmToken.isNotEmpty) {
//           // Send notification to each user
//           await _sendPushNotification(
//             token: fcmToken,
//             title: 'New Event: ${event.title}',
//             body: 'A new event has been added by $clubName',
//             data: {
//               'eventId': event.id,
//               'clubId': event.clubId,
//               'type': 'event',
//             },
//           );
//         }
//       }
//     } catch (e) {
//       print('Error sending push notification for event: $e');
//     }
//   }

//   Future<void> _sendPushNotification({
//     required String token,
//     required String title,
//     required String body,
//     required Map<String, dynamic> data,
//   }) async {
//     try {
//       // This would typically be done through a server-side function
//       // For testing purposes, we'll show a local notification instead
//       final androidDetails = AndroidNotificationDetails(
//         eventChannelId,
//         eventChannelName,
//         channelDescription: eventChannelDescription,
//         importance: Importance.max,
//         priority: Priority.high,
//       );

//       final iosDetails = const DarwinNotificationDetails(
//         presentAlert: true,
//         presentBadge: true,
//         presentSound: true,

//       );

//       final notificationDetails = NotificationDetails(
//         android: androidDetails,
//         iOS: iosDetails,
//       );

//       await _localNotifications.show(
//         DateTime.now().millisecond,
//         title,
//         body,
//         notificationDetails,
//         payload: json.encode(data),
//       );
//     } catch (e) {
//       print('Error sending push notification: $e');
//     }
//   }

//   void _showLocalNotification(RemoteMessage message) {
//     RemoteNotification? notification = message.notification;
//     AndroidNotification? android = message.notification?.android;

//     if (notification != null && android != null && !kIsWeb) {
//       _localNotifications.show(
//         notification.hashCode,
//         notification.title ?? 'New Notification',
//         notification.body ?? 'You have a new notification',
//         NotificationDetails(
//           android: AndroidNotificationDetails(
//             eventChannelId,
//             eventChannelName,
//             channelDescription: eventChannelDescription,
//             icon: '@mipmap/ic_launcher',
//             importance: Importance.max,
//             priority: Priority.high,
//           ),
//           iOS: const DarwinNotificationDetails(
//             presentAlert: true,
//             presentBadge: true,
//             presentSound: true,
//           ),
//         ),
//         payload: message.data.isNotEmpty ? json.encode(message.data) : '',
//       );
//     }
//   }

//   Future<void> _storeFcmToken() async {
//     try {
//       // Get current user
//       final user = FirebaseAuth.instance.currentUser;
//       if (user == null) {
//         print('No user logged in, cannot store FCM token');
//         return;
//       }

//       // Get FCM token
//       String? token = await _firebaseMessaging.getToken();
//       if (token == null) {
//         print('Failed to get FCM token');
//         return;
//       }

//       // Check if user document exists
//       final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

//       if (!userDoc.exists) {
//         print('User document does not exist, creating it');
//         // Create a complete user document with all required fields
//         final now = Timestamp.now();
//         await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
//           'uid': user.uid,
//           'name': user.displayName ?? 'Anonymous User',
//           'email': user.email ?? '',
//           'photoURL': user.photoURL,
//           'fcmToken': token,
//           'lastTokenUpdate': now,
//           'createdAt': now,
//           'lastLogin': now,
//         });
//       } else {
//         // Update existing user document
//         await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
//           'fcmToken': token,
//           'lastTokenUpdate': Timestamp.now(),
//           'lastLogin': Timestamp.now(), // Update last login time
//         });
//       }

//       // Listen for token refresh
//       _firebaseMessaging.onTokenRefresh.listen((newToken) {
//         _updateFcmToken(newToken);
//       });
//     } catch (e) {
//       print('Error storing FCM token: $e');
//     }
//   }

//   Future<void> _updateFcmToken(String token) async {
//     try {
//       // Get current user
//       final user = FirebaseAuth.instance.currentUser;
//       if (user == null) {
//         print('No user logged in, cannot update FCM token');
//         return;
//       }

//       // Update token in Firestore
//       await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
//         'fcmToken': token,
//         'lastTokenUpdate': Timestamp.now(),
//       });
//     } catch (e) {
//       print('Error updating FCM token: $e');
//     }
//   }

//   // Method to get notifications for the past 48 hours
//   Stream<QuerySnapshot> getRecentNotifications() {
//     try {
//       // Get current user
//       final user = FirebaseAuth.instance.currentUser;
//       if (user == null) {
//         print('No user logged in, returning empty stream');
//         return Stream.empty();
//       }

//       print('Getting notifications for user: ${user.uid}');

//       // Get notifications from the past 48 hours
//       final DateTime cutoffTime = DateTime.now().subtract(const Duration(hours: 48));
//       final Timestamp cutoffTimestamp = Timestamp.fromDate(cutoffTime);

//       // Modified query to avoid requiring a complex composite index
//       // First filter by userId, then use a simpler ordering
//       return FirebaseFirestore.instance
//           .collection('notifications')
//           .where('userId', isEqualTo: user.uid)
//           .where('time', isGreaterThanOrEqualTo: cutoffTimestamp)
//           .orderBy('time', descending: true)
//           .snapshots();
//     } catch (e) {
//       print('Error getting recent notifications: $e');
//       // Return an empty stream
//       return Stream.empty();
//     }
//   }

//   // Method to mark a notification as read
//   Future<void> markAsRead(String notificationId) async {
//     try {
//       final user = FirebaseAuth.instance.currentUser;
//       if (user == null) {
//         print('No user logged in, cannot mark notification as read');
//         return;
//       }

//       // First check if the notification belongs to the current user
//       final notificationDoc = await FirebaseFirestore.instance
//           .collection('notifications')
//           .doc(notificationId)
//           .get();

//       if (!notificationDoc.exists) {
//         print('Notification does not exist: $notificationId');
//         return;
//       }

//       final notificationData = notificationDoc.data();
//       if (notificationData == null || notificationData['userId'] != user.uid) {
//         print('Notification does not belong to current user or is missing userId');
//         return;
//       }

//       await FirebaseFirestore.instance
//           .collection('notifications')
//           .doc(notificationId)
//           .update({'read': true});
//     } catch (e) {
//       print('Error marking notification as read: $e');
//     }
//   }

//   // Method to mark all notifications as read
//   Future<void> markAllAsRead() async {
//     try {
//       final user = FirebaseAuth.instance.currentUser;
//       if (user == null) {
//         print('No user logged in, cannot mark all notifications as read');
//         return;
//       }

//       print('Marking all notifications as read for user: ${user.uid}');

//       final batch = FirebaseFirestore.instance.batch();
//       final querySnapshot = await FirebaseFirestore.instance
//           .collection('notifications')
//           .where('userId', isEqualTo: user.uid)
//           .where('read', isEqualTo: false)
//           .get();

//       print('Found ${querySnapshot.docs.length} unread notifications');

//       for (var doc in querySnapshot.docs) {
//         batch.update(doc.reference, {'read': true});
//       }

//       await batch.commit();
//     } catch (e) {
//       print('Error marking all notifications as read: $e');
//     }
//   }
// }