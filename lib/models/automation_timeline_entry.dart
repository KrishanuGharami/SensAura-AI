import 'package:flutter/material.dart';

/// Real-time sequential entry in the automation execution timeline.
class AutomationTimelineEntry {
  final DateTime timestamp;
  final String stage;
  final String detail;
  final Color statusColor;
  final IconData icon;

  const AutomationTimelineEntry({
    required this.timestamp,
    required this.stage,
    required this.detail,
    required this.statusColor,
    required this.icon,
  });

  /// Formatted time representation: HH:mm:ss
  String get formattedTime {
    final h = timestamp.hour.toString().padLeft(2, '0');
    final m = timestamp.minute.toString().padLeft(2, '0');
    final s = timestamp.second.toString().padLeft(2, '0');
    return '$h:$m:$s';
  }
}
