import '../core/constants/app_constants.dart';
import '../models/ambient_context.dart';
import '../models/context_guard_result.dart';

/// SensAura Context Guard
///
/// Deterministic safety layer preventing unsafe, jittery, or conflicting automation.
/// Evaluates:
/// - Inferred Context
/// - Confidence Score
/// - Physical / Beacon Presence
/// - Signal Consistency (Conflict Detection)
/// - Manual User Override lease
/// - Automation Cooldown timer
class ContextGuard {
  const ContextGuard();

  /// Evaluates current environment parameters and outputs a deterministic safety decision:
  /// [ContextGuardDecision.autoSafe], [ContextGuardDecision.askUser], or [ContextGuardDecision.noAction].
  ContextGuardResult evaluate({
    required AmbientContextType inferredContext,
    required double confidence,
    required bool isPresenceConfirmed,
    required bool hasConflictingSignals,
    required bool isManualOverrideActive,
    required bool isCooldownActive,
    Duration? cooldownRemaining,
    Duration? overrideRemaining,
  }) {
    final checks = <ContextGuardCheck>[
      ContextGuardCheck(
        label: 'Presence confirmed',
        passed: isPresenceConfirmed,
        detail: isPresenceConfirmed
            ? 'Home BLE beacon presence verified'
            : 'Home BLE beacon unconfirmed',
      ),
      ContextGuardCheck(
        label: 'No manual override',
        passed: !isManualOverrideActive,
        detail: isManualOverrideActive
            ? 'User manual lock active (${overrideRemaining?.inSeconds ?? 0}s remaining)'
            : 'No active manual override',
      ),
      ContextGuardCheck(
        label: 'Signal consistency',
        passed: !hasConflictingSignals && inferredContext != AmbientContextType.uncertain,
        detail: (hasConflictingSignals || inferredContext == AmbientContextType.uncertain)
            ? 'Sensory telemetry signals conflict'
            : 'Sensory telemetry signals coherent',
      ),
      ContextGuardCheck(
        label: 'Cooldown expired',
        passed: !isCooldownActive,
        detail: isCooldownActive
            ? 'Automation cooldown active (${cooldownRemaining?.inSeconds ?? 0}s remaining)'
            : 'Cooldown expired (ready)',
      ),
      ContextGuardCheck(
        label: 'Confidence threshold',
        passed: confidence >= AppConstants.minConfidenceAutoSafe,
        detail: '${(confidence * 100).toStringAsFixed(0)}% (Auto >= ${(AppConstants.minConfidenceAutoSafe * 100).toStringAsFixed(0)}%, Ask >= ${(AppConstants.minConfidenceAskUser * 100).toStringAsFixed(0)}%)',
      ),
    ];

    // =========================================================================
    // 1. NO_ACTION RULE EVALUATION:
    // confidence < 0.60 OR conflicting signals OR manual override active OR cooldown active
    // =========================================================================
    if (isManualOverrideActive) {
      return ContextGuardResult(
        decision: ContextGuardDecision.noAction,
        summary: 'Automation paused: Manual override active',
        explanation: 'User recently adjusted smart devices manually. Automated changes are paused to respect user control.',
        checks: checks,
        isSafeToApply: false,
        evaluatedAt: DateTime.now(),
      );
    }

    if (isCooldownActive) {
      return ContextGuardResult(
        decision: ContextGuardDecision.noAction,
        summary: 'Automation paused: Cooldown active',
        explanation: 'A scene was recently executed. Cooldown is active to prevent repeated or fluttering device state updates.',
        checks: checks,
        isSafeToApply: false,
        evaluatedAt: DateTime.now(),
      );
    }

    if (hasConflictingSignals || inferredContext == AmbientContextType.uncertain) {
      return ContextGuardResult(
        decision: ContextGuardDecision.noAction,
        summary: 'Automation paused: Conflicting signals',
        explanation: 'Automation paused because signals conflict (e.g. transit-level motion while beacon indicates home presence).',
        checks: checks,
        isSafeToApply: false,
        evaluatedAt: DateTime.now(),
      );
    }

    if (confidence < AppConstants.minConfidenceAskUser) {
      return ContextGuardResult(
        decision: ContextGuardDecision.noAction,
        summary: 'Automation paused: Low confidence',
        explanation: 'Context confidence (${(confidence * 100).toStringAsFixed(0)}%) is below the safe actionable threshold of ${(AppConstants.minConfidenceAskUser * 100).toStringAsFixed(0)}%.',
        checks: checks,
        isSafeToApply: false,
        evaluatedAt: DateTime.now(),
      );
    }

    // =========================================================================
    // 2. AUTO_SAFE RULE EVALUATION:
    // confidence >= 0.85 AND presence confirmed AND no manual override
    // AND no conflicting signals AND cooldown expired
    // =========================================================================
    if (confidence >= AppConstants.minConfidenceAutoSafe && isPresenceConfirmed) {
      return ContextGuardResult(
        decision: ContextGuardDecision.autoSafe,
        summary: 'Safe for automated execution',
        explanation: 'High confidence (${(confidence * 100).toStringAsFixed(0)}%) with confirmed beacon presence and coherent sensory telemetry.',
        checks: checks,
        isSafeToApply: true,
        evaluatedAt: DateTime.now(),
      );
    }

    // =========================================================================
    // 3. ASK_USER RULE EVALUATION:
    // confidence >= 0.60 AND confidence < 0.85 (or presence unconfirmed)
    // =========================================================================
    final bool isConfidenceModerate = confidence < AppConstants.minConfidenceAutoSafe;
    return ContextGuardResult(
      decision: ContextGuardDecision.askUser,
      summary: 'User confirmation recommended',
      explanation: isConfidenceModerate
          ? 'Confidence (${(confidence * 100).toStringAsFixed(0)}%) is moderate. User approval is recommended before applying scene.'
          : 'High confidence (${(confidence * 100).toStringAsFixed(0)}%) but physical presence is unconfirmed. User confirmation required.',
      checks: checks,
      isSafeToApply: true,
      evaluatedAt: DateTime.now(),
    );
  }
}
