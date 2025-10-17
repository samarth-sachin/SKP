import 'package:flutter/material.dart';

enum StatusType { image, text, video } 

class StatusModel {
  final String id;
  final String title;
  final String titleMarathi;
  final String description;
  final String descriptionMarathi;
  final StatusType type;
  final String? imageUrl;  
  final DateTime createdAt;
  final DateTime expiresAt;
  final IconData icon;
  final Color categoryColor;
  final String category;

  StatusModel({
    required this.id,
    required this.title,
    required this.titleMarathi,
    required this.description,
    required this.descriptionMarathi,
    required this.type,
    this.imageUrl,
    required this.createdAt,
    required this.expiresAt,
    required this.icon,
    required this.categoryColor,
    required this.category,
  });

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
}