import 'package:flutter/material.dart';

class CategoryModel {
  final String id;
  final String name;
  final String description;
  final double startingPrice;
  final String status;

  const CategoryModel({
    required this.id,
    required this.name,
    required this.description,
    required this.startingPrice,
    required this.status,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) => CategoryModel(
        id: json['_id'] ?? json['id'] ?? '',
        name: json['name'] ?? '',
        description: json['description'] ?? '',
        startingPrice: (json['startingPrice'] ?? 0).toDouble(),
        status: json['status'] ?? 'active',
      );

  IconData get icon {
    switch (name.toLowerCase()) {
      case 'electrician':
        return Icons.electrical_services;
      case 'plumber':
      case 'plumbing':
        return Icons.plumbing;
      case 'cleaning':
      case 'home cleaning':
        return Icons.cleaning_services;
      case 'ac repair':
      case 'ac service':
        return Icons.ac_unit;
      case 'carpenter':
      case 'carpentry':
        return Icons.carpenter;
      case 'painter':
      case 'painting':
        return Icons.format_paint;
      case 'pest control':
        return Icons.bug_report;
      case 'appliance repair':
        return Icons.kitchen;
      default:
        return Icons.home_repair_service;
    }
  }

  Color get themeColor {
    switch (name.toLowerCase()) {
      case 'electrician':
        return const Color(0xFFF59E0B);
      case 'plumber':
      case 'plumbing':
        return const Color(0xFF3B82F6);
      case 'cleaning':
      case 'home cleaning':
        return const Color(0xFF10B981);
      case 'ac repair':
      case 'ac service':
        return const Color(0xFF06B6D4);
      case 'carpenter':
      case 'carpentry':
        return const Color(0xFF8B5CF6);
      case 'painter':
      case 'painting':
        return const Color(0xFFEC4899);
      case 'pest control':
        return const Color(0xFFEF4444);
      case 'appliance repair':
        return const Color(0xFF6B7280);
      default:
        return const Color(0xFF1E88E5);
    }
  }
}
