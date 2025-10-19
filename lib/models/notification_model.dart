import 'package:cloud_firestore/cloud_firestore.dart';

enum NotificationType {
  doseAdded,
  statusPosted,
  general,
}

class NotificationModel {
  final String id;
  final String title;
  final String titleMarathi;
  final String body;
  final String bodyMarathi;
  final NotificationType type;
  final String? relatedId; // Dose ID or Status ID
  final DateTime createdAt;
  final bool isRead;
  final String farmerId; // Who receives this

  NotificationModel({
    required this.id,
    required this.title,
    required this.titleMarathi,
    required this.body,
    required this.bodyMarathi,
    required this.type,
    this.relatedId,
    required this.createdAt,
    this.isRead = false,
    required this.farmerId,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'title': title,
      'titleMarathi': titleMarathi,
      'body': body,
      'bodyMarathi': bodyMarathi,
      'type': type.toString().split('.').last,
      'relatedId': relatedId,
      'createdAt': Timestamp.fromDate(createdAt),
      'isRead': isRead,
      'farmerId': farmerId,
    };
  }

  factory NotificationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return NotificationModel(
      id: doc.id,
      title: data['title'] ?? '',
      titleMarathi: data['titleMarathi'] ?? '',
      body: data['body'] ?? '',
      bodyMarathi: data['bodyMarathi'] ?? '',
      type: NotificationType.values.firstWhere(
            (e) => e.toString().split('.').last == data['type'],
        orElse: () => NotificationType.general,
      ),
      relatedId: data['relatedId'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      isRead: data['isRead'] ?? false,
      farmerId: data['farmerId'] ?? '',
    );
  }

  NotificationModel copyWith({bool? isRead}) {
    return NotificationModel(
      id: id,
      title: title,
      titleMarathi: titleMarathi,
      body: body,
      bodyMarathi: bodyMarathi,
      type: type,
      relatedId: relatedId,
      createdAt: createdAt,
      isRead: isRead ?? this.isRead,
      farmerId: farmerId,
    );
  }
}
