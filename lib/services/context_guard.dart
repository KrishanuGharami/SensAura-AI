import '../core/constants/app_constants.dart';
import '../models/ambient_context.dart';
import '../models/context_guard_result.dart';

/// SensAura Context Guard
///
/// Deterministic safety layer preventing unsafe, jittery, or conflicting automation.
/// Evaluates:
/// - Inferred Context
/// - Confidence Score (minAuto: 0.85, minAsk: 0.60)
/// - Physical / Beacon Presence
/// - Signal Consistency (Conflict Detection)
/// - Manual User Override Lease (180s)
/// - Automation Cooldown Timer (45s)
/// - Actuator Reachability (SensAura Node Workstation / BLE GATT)
/// - Sensor Telemetry Freshness (Stale check)
class ContextGuard {
  const ContextGuard();

  /// Evaluates environment parameters and outputs a deterministic safety decision:
  /// [ContextGuardDecision.autoSafe], [ContextGuardDecision.askUser], or [ContextGuardDecision.noAction].
  ContextGuardResult evaluate({
    required AmbientContextType inferredContext,
    required double confidence,
    required bool isPresenceConfirmed,
    required bool hasConflictingSignals,
    required bool isManualOverrideActive,
    required bool isCooldownActive,
    bool isAutomationPausedByGesture = false,
    bool isActuatorAvailable = true,
    bool isSensorTelemetryFresh = true,
    Duration? cooldownRemaining,
    Duration? overrideRemaining,
  }) {
    final checks = <ContextGuardCheck>[
      ContextGuardCheck(
        label: 'Presence verified',
        passed: isPresenceConfirmed,
        detail: isPresenceConfirmed
            ? 'Workstation BLE beacon verified'
            : 'Workstation presence unconfirmed',
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
        label: 'Actuator available',
        passed: isActuatorAvailable,
        detail: isActuatorAvailable
            ? 'Workstation Node / BLE ready'
            : 'No connected actuator reachable',
      ),
      ContextGuardCheck(
        label: 'Sensors fresh',
        passed: isSensorTelemetryFresh,
        detail: isSensorTelemetryFresh
            ? 'Real-time telemetry streaming'
            : 'Telemetry stale (>10s without update)',
      ),
      ContextGuardCheck(
        label: 'Confidence threshold',
        passed: confidence >= AppConstants.minConfidenceAutoSafe,
        detail: '${(confidence * 100).toStringAsFixed(0)}% (Auto >= ${(AppConstants.minConfidenceAutoSafe * 100).toStringAsFixed(0)}%, Ask >= ${(AppConstants.minConfidenceAskUser * 100).toStringAsFixed(0)}%)',
      ),
      ContextGuardCheck(
        label: 'Gesture safety',
        passed: !isAutomationPausedByGesture,
        detail: isAutomationPausedByGesture
            ? 'Automation paused by user gesture (✋ Open Palm)'
            : 'No gesture pause requested',
      ),
    ];

    // =========================================================================
    // 1. NO_ACTION RULE EVALUATION:
    // User Gesture Pause takes immediate protective priority
    // =========================================================================
    if (isAutomationPausedByGesture) {
      return ContextGuardResult(
        decision: ContextGuardDecision.noAction,
        summary: 'Automation paused: User gesture (✋ Open Palm)',
        explanation: 'User explicitly presented an Open Palm gesture to lock the space. Automation remains paused until resumed.',
        checks: checks,
        isSafeToApply: false,
        evaluatedAt: DateTime.now(),
      );
    }

    if (!isSensorTelemetryFresh) {
      return ContextGuardResult(
        decision: ContextGuardDecision.noAction,
        summary: 'Automation paused: Stale sensor telemetry',
        explanation: 'Sensor readings have not refreshed in over 10 seconds. Automation is paused to avoid acting on outdated environmental data.',
        checks: checks,
        isSafeToApply: false,
        evaluatedAt: DateTime.now(),
      );
    }

    if (!isActuatorAvailable) {
      return ContextGuardResult(
        decision: ContextGuardDecision.noAction,
        summary: 'Automation paused: Actuator unreachable',
        explanation: 'Neither SensAura Node (Laptop Workstation) nor a compatible BLE GATT device is currently connected to receive commands.',
        checks: checks,
        isSafeToApply: false,
        evaluatedAt: DateTime.now(),
      );
    }

    if (isManualOverrideActive) {
      return ContextGuardResult(
        decision: ContextGuardDecision.noAction,
        summary: 'Automation paused: Manual override active',
        explanation: 'User recently adjusted smart devices manually (workstation override). Automated changes are paused to respect direct user control.',
        checks: checks,
        isSafeToApply: false,
        evaluatedAt: DateTime.now(),
      );
    }

    if (isCooldownActive) {
      return ContextGuardResult(
        decision: ContextGuardDecision.noAction,
        summary: 'Automation paused: Cooldown active',
        explanation: 'An automation scene was recently executed. Cooldown is active to prevent repeated or fluttering actuator commands.',
        checks: checks,
        isSafeToApply: false,
        evaluatedAt: DateTime.now(),
      );
    }

    if (hasConflictingSignals || inferredContext == AmbientContextType.uncertain) {
      return ContextGuardResult(
        decision: ContextGuardDecision.noAction,
        summary: 'Automation paused: Conflicting signals',
        explanation: 'Automation paused because sensory telemetry signals conflict with contradictory physical cues.',
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
    // AND no conflicting signals AND cooldown expired AND actuator available AND fresh
    // =========================================================================
    if (confidence >= AppConstants.minConfidenceAutoSafe && isPresenceConfirmed) {
      return ContextGuardResult(
        decision: ContextGuardDecision.autoSafe,
        summary: 'Safe for automated execution',
        explanation: 'High confidence (${(confidence * 100).toStringAsFixed(0)}%) with confirmed workstation presence, coherent telemetry, and verified actuator.',
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
