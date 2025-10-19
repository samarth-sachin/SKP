import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/notification_model.dart';
import '../../services/notification_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  String? _farmerId;

  @override
  void initState() {
    super.initState();
    _loadFarmerId();
  }

  Future<void> _loadFarmerId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _farmerId = prefs.getString('farmerId');
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_farmerId == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('सूचना', style: GoogleFonts.notoSansDevanagari()),
          automaticallyImplyLeading: false,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E7D32),
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'सूचना',
              style: GoogleFonts.notoSansDevanagari(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Notifications',
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        automaticallyImplyLeading: false,
        actions: [
          // Unread count badge
          StreamBuilder<int>(
            stream: NotificationService.getUnreadCount(_farmerId!),
            builder: (context, snapshot) {
              final unreadCount = snapshot.data ?? 0;
              if (unreadCount > 0) {
                return Center(
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$unreadCount नवीन',
                      style: GoogleFonts.notoSansDevanagari(
                        fontSize: 12,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
          // Mark all as read
          PopupMenuButton(
            icon: const Icon(Icons.more_vert),
            itemBuilder: (context) => [
              PopupMenuItem(
                child: Row(
                  children: [
                    const Icon(Icons.done_all, size: 20),
                    const SizedBox(width: 8),
                    Text('सर्व वाचलेले म्हणून चिन्हांकित करा', style: GoogleFonts.notoSansDevanagari(fontSize: 13)),
                  ],
                ),
                onTap: () {
                  NotificationService.markAllAsRead(_farmerId!);
                },
              ),
            ],
          ),
        ],
      ),
      body: StreamBuilder<List<NotificationModel>>(
        stream: NotificationService.getNotificationsForFarmer(_farmerId!),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error, size: 60, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Text('Error loading notifications', style: GoogleFonts.poppins(color: Colors.red)),
                ],
              ),
            );
          }

          final notifications = snapshot.data ?? [];

          if (notifications.isEmpty) {
            return _buildEmptyState();
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification = notifications[index];
              return _buildNotificationCard(notification);
            },
          );
        },
      ),
    );
  }

  Widget _buildNotificationCard(NotificationModel notification) {
    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (direction) {
        NotificationService.deleteNotification(notification.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('सूचना हटवली', style: GoogleFonts.notoSansDevanagari()),
            backgroundColor: Colors.red,
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        color: notification.isRead ? Colors.white : const Color(0xFFE8F5E9),
        elevation: notification.isRead ? 1 : 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: notification.isRead ? Colors.grey[200]! : const Color(0xFF2E7D32).withOpacity(0.3),
            width: notification.isRead ? 1 : 2,
          ),
        ),
        child: InkWell(
          onTap: () {
            if (!notification.isRead) {
              NotificationService.markAsRead(notification.id);
            }
            _handleNotificationTap(notification);
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _getNotificationColor(notification.type).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getNotificationIcon(notification.type),
                    color: _getNotificationColor(notification.type),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              notification.titleMarathi,
                              style: GoogleFonts.notoSansDevanagari(
                                fontSize: 16,
                                fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
                              ),
                            ),
                          ),
                          if (!notification.isRead)
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Color(0xFF2E7D32),
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        notification.bodyMarathi,
                        style: GoogleFonts.notoSansDevanagari(
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        notification.body,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.access_time, size: 12, color: Colors.grey[500]),
                          const SizedBox(width: 4),
                          Text(
                            _formatTime(notification.createdAt),
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
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
            'सूचना नाहीत',
            style: GoogleFonts.notoSansDevanagari(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'No notifications',
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[500]),
          ),
          const SizedBox(height: 4),
          Text(
            'तुमच्या अपडेट्स येथे दिसतील',
            textAlign: TextAlign.center,
            style: GoogleFonts.notoSansDevanagari(fontSize: 13, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  IconData _getNotificationIcon(NotificationType type) {
    switch (type) {
      case NotificationType.doseAdded:
        return Icons.local_pharmacy;
      case NotificationType.statusPosted:
        return Icons.campaign;
      case NotificationType.general:
      default:
        return Icons.notifications;
    }
  }

  Color _getNotificationColor(NotificationType type) {
    switch (type) {
      case NotificationType.doseAdded:
        return Colors.green;
      case NotificationType.statusPosted:
        return Colors.orange;
      case NotificationType.general:
      default:
        return const Color(0xFF2E7D32);
    }
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 1) {
      return 'आत्ताच • Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} मिनिटांपूर्वी • ${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} तासांपूर्वी • ${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} दिवसांपूर्वी • ${difference.inDays}d ago';
    } else {
      return DateFormat('dd MMM yyyy').format(time);
    }
  }

  void _handleNotificationTap(NotificationModel notification) {
    // Navigate to relevant screen based on notification type
    if (notification.type == NotificationType.doseAdded && notification.relatedId != null) {
      // Navigate to dose details or lands screen
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Opening dose details...', style: GoogleFonts.poppins()),
        ),
      );
    } else if (notification.type == NotificationType.statusPosted) {
      // Navigate to status screen
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Opening status...', style: GoogleFonts.poppins()),
        ),
      );
    }
  }
}
