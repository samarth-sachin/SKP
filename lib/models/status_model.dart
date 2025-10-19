import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum StatusType { image, text, video }

class StatusModel {
  final String id;
  final String title;
  final String titleMarathi;
  final String description;
  final String descriptionMarathi;
  final StatusType type;
  final String? imageUrl; // Firebase Storage URL
  final String? thumbnailUrl; // For video thumbnails
  final DateTime createdAt;
  final DateTime expiresAt;
  final String category;
  final int viewCount;

  StatusModel({
    required this.id,
    required this.title,
    required this.titleMarathi,
    required this.description,
    required this.descriptionMarathi,
    required this.type,
    this.imageUrl,
    this.thumbnailUrl,
    required this.createdAt,
    required this.expiresAt,
    required this.category,
    this.viewCount = 0,
  });

  // ✅ Convert to Firestore format
  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'title': title,
      'titleMarathi': titleMarathi,
      'description': description,
      'descriptionMarathi': descriptionMarathi,
      'type': type.toString().split('.').last,
      'imageUrl': imageUrl,
      'thumbnailUrl': thumbnailUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      'expiresAt': Timestamp.fromDate(expiresAt),
      'category': category,
      'viewCount': viewCount,
    };
  }

  // ✅ Create from Firestore document
  factory StatusModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return StatusModel(
      id: doc.id,
      title: data['title'] ?? '',
      titleMarathi: data['titleMarathi'] ?? '',
      description: data['description'] ?? '',
      descriptionMarathi: data['descriptionMarathi'] ?? '',
      type: StatusType.values.firstWhere(
            (e) => e.toString().split('.').last == data['type'],
        orElse: () => StatusType.text,
      ),
      imageUrl: data['imageUrl'],
      thumbnailUrl: data['thumbnailUrl'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      expiresAt: (data['expiresAt'] as Timestamp).toDate(),
      category: data['category'] ?? 'खत',
      viewCount: data['viewCount'] ?? 0,
    );
  }

  // ✅ Helper getters
  IconData get icon {
    switch (category) {
      case 'खत':
        return Icons.grass;
      case 'हवामान':
        return Icons.cloud;
      case 'टीप':
        return Icons.lightbulb;
      case 'योजना':
        return Icons.agriculture;
      default:
        return Icons.info;
    }
  }

  Color get categoryColor {
    switch (category) {
      case 'खत':
        return Colors.green;
      case 'हवामान':
        return Colors.blue;
      case 'टीप':
        return Colors.orange;
      case 'योजना':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  String get timeRemaining {
    final now = DateTime.now();
    final difference = expiresAt.difference(now);

    if (difference.inDays > 0) {
      return '${difference.inDays} दिवस शिल्लक';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} तास शिल्लक';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} मिनिटे शिल्लक';
    } else {
      return 'कालबाह्य';
    }
  }

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  // Copy with method for updates
  StatusModel copyWith({
    int? viewCount,
  }) {
    return StatusModel(
      id: id,
      title: title,
      titleMarathi: titleMarathi,
      description: description,
      descriptionMarathi: descriptionMarathi,
      type: type,
      imageUrl: imageUrl,
      thumbnailUrl: thumbnailUrl,
      createdAt: createdAt,
      expiresAt: expiresAt,
      category: category,
      viewCount: viewCount ?? this.viewCount,
    );
  }
}
