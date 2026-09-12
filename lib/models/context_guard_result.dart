import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

/// Decision outcomes emitted by the SensAura Context Guard safety engine.
enum ContextGuardDecision {
  autoSafe,
  askUser,
  noAction;

  String get displayName {
    switch (this) {
      case ContextGuardDecision.autoSafe:
        return 'AUTO_SAFE';
      case ContextGuardDecision.askUser:
        return 'ASK_USER';
      case ContextGuardDecision.noAction:
        return 'NO_ACTION';
    }
  }

  String get userBadge {
    switch (this) {
      case ContextGuardDecision.autoSafe:
        return 'AUTO SAFE';
      case ContextGuardDecision.askUser:
        return 'ASK USER';
      case ContextGuardDecision.noAction:
        return 'AUTOMATION PAUSED';
    }
  }

  Color get color {
    switch (this) {
      case ContextGuardDecision.autoSafe:
        return AppColors.emeraldGreen;
      case ContextGuardDecision.askUser:
        return AppColors.primaryAmber;
      case ContextGuardDecision.noAction:
        return AppColors.dangerRed;
    }
  }

  IconData get iconData {
    switch (this) {
      case ContextGuardDecision.autoSafe:
        return Icons.verified_user_rounded;
      case ContextGuardDecision.askUser:
        return Icons.help_outline_rounded;
      case ContextGuardDecision.noAction:
        return Icons.shield_outlined;
    }
  }
}

/// An individual condition or safety check evaluated by Context Guard.
class ContextGuardCheck {
  final String label;
  final bool passed;
  final String detail;

  const ContextGuardCheck({
    required this.label,
    required this.passed,
    required this.detail,
  });
}

/// Immutable evaluation summary of the SensAura Context Guard.
class ContextGuardResult {
  final ContextGuardDecision decision;
  final String summary;
  final String explanation;
  final List<ContextGuardCheck> checks;
  final bool isSafeToApply;
  final DateTime? evaluatedAt;

  const ContextGuardResult({
    required this.decision,
    required this.summary,
    required this.explanation,
    required this.checks,
    required this.isSafeToApply,
    this.evaluatedAt,
  });

  static const ContextGuardResult defaultSafe = ContextGuardResult(
    decision: ContextGuardDecision.autoSafe,
    summary: 'Baseline environment safe',
    explanation: 'Presence confirmed, no manual override, and signals are coherent.',
    checks: [],
    isSafeToApply: true,
  );

  /// Factory for neutral initial state
  factory ContextGuardResult.initial() {
    return ContextGuardResult(
      decision: ContextGuardDecision.autoSafe,
      summary: 'Normal baseline environment safe for operation',
      explanation: 'Presence confirmed, no manual override, and signals are coherent.',
      checks: const [
        ContextGuardCheck(label: 'Presence confirmed', passed: true, detail: 'Home BLE beacon active'),
        ContextGuardCheck(label: 'No manual override', passed: true, detail: 'No active device lock'),
        ContextGuardCheck(label: 'Signal consistency', passed: true, detail: 'All sensors aligned'),
        ContextGuardCheck(label: 'Cooldown expired', passed: true, detail: 'System ready'),
        ContextGuardCheck(label: 'Confidence threshold', passed: true, detail: '85% >= 85%'),
      ],
      isSafeToApply: true,
      evaluatedAt: DateTime.now(),
    );
  }
}
