import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/notification_model.dart';

class NotificationService {
  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ✅ Initialize FCM
  static Future<void> initialize() async {
    // Request permission
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    print('✅ FCM Permission: ${settings.authorizationStatus}');

    // Initialize local notifications
    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings();
    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (details) {
        // Handle notification tap
        print('Notification tapped: ${details.payload}');
      },
    );

    // Create notification channel for Android
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      description: 'This channel is used for important notifications.',
      importance: Importance.high,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('📱 Foreground message: ${message.notification?.title}');
      _showLocalNotification(message);
    });

    // Handle background message tap
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('🔔 Notification opened: ${message.notification?.title}');
      // Navigate to specific screen
    });
  }

  // ✅ Get FCM token
  static Future<String?> getFCMToken() async {
    try {
      String? token = await _firebaseMessaging.getToken();
      print('✅ FCM Token: $token');
      return token;
    } catch (e) {
      print('❌ Error getting FCM token: $e');
      return null;
    }
  }

  // ✅ Save FCM token to Firestore
  static Future<void> saveFCMToken(String farmerId, String token) async {
    try {
      await _firestore.collection('farmers').doc(farmerId).update({
        'fcmToken': token,
        'fcmTokenUpdatedAt': FieldValue.serverTimestamp(),
      });
      print('✅ FCM token saved for farmer: $farmerId');
    } catch (e) {
      print('❌ Error saving FCM token: $e');
    }
  }

  // ✅ Show local notification
  static Future<void> _showLocalNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'high_importance_channel',
      'High Importance Notifications',
      channelDescription: 'This channel is used for important notifications.',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const NotificationDetails details = NotificationDetails(android: androidDetails);

    await _localNotifications.show(
      message.hashCode,
      message.notification?.title ?? 'New Notification',
      message.notification?.body ?? '',
      details,
      payload: message.data['relatedId'],
    );
  }

  // ✅ Send notification to specific farmer
  static Future<void> sendNotificationToFarmer({
    required String farmerId,
    required String title,
    required String titleMarathi,
    required String body,
    required String bodyMarathi,
    required NotificationType type,
    String? relatedId,
  }) async {
    try {
      // Save notification to Firestore
      final notificationDoc = _firestore.collection('notifications').doc();
      final notification = NotificationModel(
        id: notificationDoc.id,
        title: title,
        titleMarathi: titleMarathi,
        body: body,
        bodyMarathi: bodyMarathi,
        type: type,
        relatedId: relatedId,
        createdAt: DateTime.now(),
        farmerId: farmerId,
      );

      await notificationDoc.set(notification.toFirestore());

      // Get farmer's FCM token
      final farmerDoc = await _firestore.collection('farmers').doc(farmerId).get();
      final fcmToken = farmerDoc.data()?['fcmToken'] as String?;

      if (fcmToken != null) {
        // Send FCM notification using Cloud Functions or HTTP API
        print('✅ Notification saved for farmer: $farmerId');
        // Note: Actual FCM sending requires Cloud Functions or backend
      }
    } catch (e) {
      print('❌ Error sending notification: $e');
    }
  }

  // ✅ Send notification to all farmers
  static Future<void> sendNotificationToAllFarmers({
    required String title,
    required String titleMarathi,
    required String body,
    required String bodyMarathi,
    required NotificationType type,
    String? relatedId,
  }) async {
    try {
      final farmersSnapshot = await _firestore.collection('farmers').get();

      for (var farmerDoc in farmersSnapshot.docs) {
        await sendNotificationToFarmer(
          farmerId: farmerDoc.id,
          title: title,
          titleMarathi: titleMarathi,
          body: body,
          bodyMarathi: bodyMarathi,
          type: type,
          relatedId: relatedId,
        );
      }

      print('✅ Notification sent to all farmers');
    } catch (e) {
      print('❌ Error sending notifications: $e');
    }
  }

  // ✅ Get notifications for farmer
  static Stream<List<NotificationModel>> getNotificationsForFarmer(String farmerId) {
    return _firestore
        .collection('notifications')
        .where('farmerId', isEqualTo: farmerId)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => NotificationModel.fromFirestore(doc)).toList();
    });
  }

  // ✅ Get unread count
  static Stream<int> getUnreadCount(String farmerId) {
    return _firestore
        .collection('notifications')
        .where('farmerId', isEqualTo: farmerId)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  // ✅ Mark notification as read
  static Future<void> markAsRead(String notificationId) async {
    try {
      await _firestore.collection('notifications').doc(notificationId).update({
        'isRead': true,
      });
    } catch (e) {
      print('❌ Error marking notification as read: $e');
    }
  }

  // ✅ Mark all as read
  static Future<void> markAllAsRead(String farmerId) async {
    try {
      final unreadNotifications = await _firestore
          .collection('notifications')
          .where('farmerId', isEqualTo: farmerId)
          .where('isRead', isEqualTo: false)
          .get();

      for (var doc in unreadNotifications.docs) {
        await doc.reference.update({'isRead': true});
      }
    } catch (e) {
      print('❌ Error marking all as read: $e');
    }
  }

  // ✅ Delete notification
  static Future<void> deleteNotification(String notificationId) async {
    try {
      await _firestore.collection('notifications').doc(notificationId).delete();
    } catch (e) {
      print('❌ Error deleting notification: $e');
    }
  }
}

// ✅ Background message handler (must be top-level function)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('🔔 Background message: ${message.notification?.title}');
}
