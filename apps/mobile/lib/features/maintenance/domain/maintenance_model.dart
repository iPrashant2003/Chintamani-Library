import 'package:flutter/material.dart';

enum MaintenancePriority { urgent, medium, routine }
enum MaintenanceStatus { reported, inProgress, resolved }

class MaintenanceTicket {
  final String id;
  final String title;
  final String category; // 'AC & Cooling', 'Fiber Wi-Fi', 'Power & Inverter', 'Water & RO', 'Lighting', 'Chairs & Desks', 'Sanitization'
  final MaintenancePriority priority;
  final MaintenanceStatus status;
  final DateTime reportedAt;
  final DateTime? resolvedAt;
  final double estimatedCost;
  final String technicianName;
  final String technicianPhone;
  final String branchId;
  final String? notes;

  const MaintenanceTicket({
    required this.id,
    required this.title,
    required this.category,
    required this.priority,
    required this.status,
    required this.reportedAt,
    this.resolvedAt,
    required this.estimatedCost,
    required this.technicianName,
    required this.technicianPhone,
    required this.branchId,
    this.notes,
  });

  MaintenanceTicket copyWith({
    String? id,
    String? title,
    String? category,
    MaintenancePriority? priority,
    MaintenanceStatus? status,
    DateTime? reportedAt,
    DateTime? resolvedAt,
    double? estimatedCost,
    String? technicianName,
    String? technicianPhone,
    String? branchId,
    String? notes,
  }) {
    return MaintenanceTicket(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      reportedAt: reportedAt ?? this.reportedAt,
      resolvedAt: resolvedAt ?? this.resolvedAt,
      estimatedCost: estimatedCost ?? this.estimatedCost,
      technicianName: technicianName ?? this.technicianName,
      technicianPhone: technicianPhone ?? this.technicianPhone,
      branchId: branchId ?? this.branchId,
      notes: notes ?? this.notes,
    );
  }

  IconData get icon {
    switch (category) {
      case 'AC & Cooling':
        return Icons.ac_unit_rounded;
      case 'Fiber Wi-Fi':
        return Icons.wifi_rounded;
      case 'Power & Inverter':
        return Icons.bolt_rounded;
      case 'Water & RO':
        return Icons.water_drop_rounded;
      case 'Lighting':
        return Icons.lightbulb_rounded;
      case 'Chairs & Desks':
        return Icons.chair_rounded;
      case 'Sanitization':
        return Icons.cleaning_services_rounded;
      default:
        return Icons.build_rounded;
    }
  }

  Color get categoryColor {
    switch (category) {
      case 'AC & Cooling':
        return const Color(0xFF38BDF8); // Sky blue
      case 'Fiber Wi-Fi':
        return const Color(0xFF00E5BC); // Teal
      case 'Power & Inverter':
        return const Color(0xFFF59E0B); // Amber
      case 'Water & RO':
        return const Color(0xFF3B82F6); // Blue
      case 'Lighting':
        return const Color(0xFFFBBF24); // Warm Gold
      case 'Chairs & Desks':
        return const Color(0xFFC084FC); // Purple
      case 'Sanitization':
        return const Color(0xFF10B981); // Emerald
      default:
        return const Color(0xFF94A3B8);
    }
  }

  Color get priorityColor {
    switch (priority) {
      case MaintenancePriority.urgent:
        return const Color(0xFFEF4444);
      case MaintenancePriority.medium:
        return const Color(0xFFF59E0B);
      case MaintenancePriority.routine:
        return const Color(0xFF10B981);
    }
  }

  String get priorityLabel {
    switch (priority) {
      case MaintenancePriority.urgent:
        return 'CRITICAL';
      case MaintenancePriority.medium:
        return 'MEDIUM';
      case MaintenancePriority.routine:
        return 'ROUTINE';
    }
  }

  Color get statusColor {
    switch (status) {
      case MaintenanceStatus.reported:
        return const Color(0xFFF59E0B);
      case MaintenanceStatus.inProgress:
        return const Color(0xFF60A5FA);
      case MaintenanceStatus.resolved:
        return const Color(0xFF34D399);
    }
  }

  String get statusLabel {
    switch (status) {
      case MaintenanceStatus.reported:
        return 'REPORTED';
      case MaintenanceStatus.inProgress:
        return 'IN PROGRESS';
      case MaintenanceStatus.resolved:
        return 'RESOLVED';
    }
  }
}
