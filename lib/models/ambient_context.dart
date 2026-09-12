import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

enum AmbientContextType {
  relaxation,
  leaving,
  arriving,
  focus,
  sleep,
  neutral;

  String get displayName {
    switch (this) {
      case AmbientContextType.relaxation:
        return 'Relaxation';
      case AmbientContextType.leaving:
        return 'Leaving';
      case AmbientContextType.arriving:
        return 'Arriving';
      case AmbientContextType.focus:
        return 'Deep Focus';
      case AmbientContextType.sleep:
        return 'Sleep Mode';
      case AmbientContextType.neutral:
        return 'Active Normal';
    }
  }

  IconData get iconData {
    switch (this) {
      case AmbientContextType.relaxation:
        return Icons.spa_rounded;
      case AmbientContextType.leaving:
        return Icons.directions_walk_rounded;
      case AmbientContextType.arriving:
        return Icons.home_rounded;
      case AmbientContextType.focus:
        return Icons.psychology_rounded;
      case AmbientContextType.sleep:
        return Icons.bedtime_rounded;
      case AmbientContextType.neutral:
        return Icons.sensors_rounded;
    }
  }

  Color get color {
    switch (this) {
      case AmbientContextType.relaxation:
        return AppColors.primaryAmber;
      case AmbientContextType.leaving:
        return AppColors.dangerRed;
      case AmbientContextType.arriving:
        return AppColors.emeraldGreen;
      case AmbientContextType.focus:
        return AppColors.cyberCyan;
      case AmbientContextType.sleep:
        return AppColors.electricViolet;
      case AmbientContextType.neutral:
        return AppColors.textSecondary;
    }
  }
}
