import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock notifications - replace with real Firebase data
    final notifications = [
      {
        'title': 'Next Dose Reminder',
        'message': 'Your next fertilizer dose for Land A is scheduled for tomorrow',
        'time': DateTime.now().subtract(const Duration(hours: 2)),
        'type': 'reminder',
      },
      {
        'title': 'Payment Pending',
        'message': 'You have ₹2,500 credit pending for last month',
        'time': DateTime.now().subtract(const Duration(days: 1)),
        'type': 'payment',
      },
      {
        'title': 'Weather Alert',
        'message': 'Heavy rain expected in next 24 hours',
        'time': DateTime.now().subtract(const Duration(days: 2)),
        'type': 'weather',
      },
    ];

    return Scaffold(
      body: notifications.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notification = notifications[index];
                return _buildNotificationCard(
                  title: notification['title'] as String,
                  message: notification['message'] as String,
                  time: notification['time'] as DateTime,
                  type: notification['type'] as String,
                );
              },
            ),
    );
  }

  Widget _buildNotificationCard({
    required String title,
    required String message,
    required DateTime time,
    required String type,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _getNotificationColor(type).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _getNotificationIcon(type),
                color: _getNotificationColor(type),
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    message,
                    style: GoogleFonts.nunito(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _formatTime(time),
                    style: GoogleFonts.nunito(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_off, size: 100, color: Colors.grey[300]),
          const SizedBox(height: 20),
          Text(
            'No notifications',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your updates will appear here',
            style: GoogleFonts.nunito(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'reminder':
        return Icons.notification_important;
      case 'payment':
        return Icons.payment;
      case 'weather':
        return Icons.wb_cloudy;
      default:
        return Icons.notifications;
    }
  }

  Color _getNotificationColor(String type) {
    switch (type) {
      case 'reminder':
        return Colors.orange;
      case 'payment':
        return Colors.red;
      case 'weather':
        return Colors.blue;
      default:
        return const Color(0xFF2E7D32);
    }
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return DateFormat('dd MMM yyyy').format(time);
    }
  }
}
