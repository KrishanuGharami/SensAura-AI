import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../l10n/app_localizations.dart';

enum AmbientContextType {
  relaxation,
  leaving,
  arriving,
  focus,
  breakTime,
  sleep,
  neutral,
  uncertain;

  String get displayName {
    switch (this) {
      case AmbientContextType.relaxation:
        return 'Rest Mode';
      case AmbientContextType.leaving:
        return 'Leaving Workstation';
      case AmbientContextType.arriving:
        return 'Arriving / Back';
      case AmbientContextType.focus:
        return 'Deep Focus';
      case AmbientContextType.breakTime:
        return 'Break Time';
      case AmbientContextType.sleep:
        return 'Night Rest';
      case AmbientContextType.neutral:
        return 'Active Normal';
      case AmbientContextType.uncertain:
        return 'Uncertain Context';
    }
  }

  String getLocalizedName(AppLocalizations? l10n) {
    if (l10n == null) return displayName;
    switch (this) {
      case AmbientContextType.relaxation:
        return l10n.contextRestFull;
      case AmbientContextType.leaving:
        return l10n.contextLeavingFull;
      case AmbientContextType.arriving:
        return l10n.contextArrivingFull;
      case AmbientContextType.focus:
        return l10n.contextFocusFull;
      case AmbientContextType.breakTime:
        return l10n.contextBreakFull;
      case AmbientContextType.sleep:
        return l10n.contextSleepFull;
      case AmbientContextType.neutral:
        return l10n.contextNeutralFull;
      case AmbientContextType.uncertain:
        return l10n.contextUncertainFull;
    }
  }

  String getLocalizedShortName(AppLocalizations? l10n) {
    if (l10n == null) return displayName;
    switch (this) {
      case AmbientContextType.relaxation:
        return l10n.contextRest;
      case AmbientContextType.leaving:
        return l10n.contextLeaving;
      case AmbientContextType.arriving:
        return l10n.contextArriving;
      case AmbientContextType.focus:
        return l10n.contextFocus;
      case AmbientContextType.breakTime:
        return l10n.contextBreak;
      case AmbientContextType.sleep:
        return l10n.contextSleep;
      case AmbientContextType.neutral:
        return l10n.contextNeutral;
      case AmbientContextType.uncertain:
        return l10n.contextUncertain;
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
      case AmbientContextType.breakTime:
        return Icons.coffee_rounded;
      case AmbientContextType.sleep:
        return Icons.bedtime_rounded;
      case AmbientContextType.neutral:
        return Icons.sensors_rounded;
      case AmbientContextType.uncertain:
        return Icons.warning_amber_rounded;
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
      case AmbientContextType.breakTime:
        return AppColors.neonYellow;
      case AmbientContextType.sleep:
        return AppColors.electricViolet;
      case AmbientContextType.neutral:
        return AppColors.textSecondary;
      case AmbientContextType.uncertain:
        return AppColors.statusWarning;
    }
  }
}
