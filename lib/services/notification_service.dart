import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService {
  // Mock notifications list
  static List<Map<String, dynamic>> _notifications = [];

  Future<void> initialize() async {
    print('✅ Notification Service Initialized (Mock Mode)');
    _loadMockNotifications();
  }

  void _loadMockNotifications() {
    _notifications = [
      {
        'id': '1',
        'title': 'Next Dose Reminder',
        'message': 'Your next fertilizer dose for East Field is scheduled for tomorrow',
        'time': DateTime.now().subtract(const Duration(hours: 2)),
        'type': 'reminder',
        'isRead': false,
      },
      {
        'id': '2',
        'title': 'Payment Pending',
        'message': 'You have ₹2,500 credit pending for last month',
        'time': DateTime.now().subtract(const Duration(days: 1)),
        'type': 'payment',
        'isRead': false,
      },
      {
        'id': '3',
        'title': 'Weather Alert',
        'message': 'Heavy rain expected in next 24 hours',
        'time': DateTime.now().subtract(const Duration(days: 2)),
        'type': 'weather',
        'isRead': true,
      },
    ];
  }

  // Schedule a notification (mock version)
  Future<void> scheduleNotification({
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    print('📅 Notification Scheduled:');
    print('   Title: $title');
    print('   Body: $body');
    print('   Date: $scheduledDate');

    // Add to mock notifications list
    _notifications.insert(0, {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'title': title,
      'message': body,
      'time': DateTime.now(),
      'type': 'reminder',
      'isRead': false,
    });
  }

  // Show immediate notification (mock version)
  Future<void> showNotification({
    required String title,
    required String body,
    String type = 'info',
  }) async {
    print('🔔 Notification:');
    print('   Title: $title');
    print('   Body: $body');

    // Add to mock notifications list
    _notifications.insert(0, {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'title': title,
      'message': body,
      'time': DateTime.now(),
      'type': type,
      'isRead': false,
    });
  }

  // Get all notifications
  List<Map<String, dynamic>> getNotifications() {
    return _notifications;
  }

  // Mark notification as read
  void markAsRead(String notificationId) {
    final index = _notifications.indexWhere((n) => n['id'] == notificationId);
    if (index != -1) {
      _notifications[index]['isRead'] = true;
    }
  }

  // Clear all notifications
  void clearAllNotifications() {
    _notifications.clear();
  }

  // Get unread count
  int getUnreadCount() {
    return _notifications.where((n) => n['isRead'] == false).length;
  }
}
