import 'package:flutter_test/flutter_test.dart';
import 'package:sensaura_ai/core/constants/app_constants.dart';
import 'package:sensaura_ai/models/ambient_context.dart';
import 'package:sensaura_ai/models/context_guard_result.dart';
import 'package:sensaura_ai/services/context_guard.dart';

void main() {
  group('SensAura Context Guard Safety Gate Tests', () {
    const guard = ContextGuard();

    test('Threshold constants are correctly configured without magic numbers', () {
      expect(AppConstants.minConfidenceAutoSafe, equals(0.85));
      expect(AppConstants.minConfidenceAskUser, equals(0.60));
      expect(AppConstants.cooldownDurationSeconds, equals(45));
      expect(AppConstants.manualOverrideDurationSeconds, equals(180));
    });

    test('AUTO_SAFE: confidence >= 0.85, presence confirmed, no override, no conflict, cooldown expired', () {
      final result = guard.evaluate(
        inferredContext: AmbientContextType.relaxation,
        confidence: 0.92,
        isPresenceConfirmed: true,
        hasConflictingSignals: false,
        isManualOverrideActive: false,
        isCooldownActive: false,
      );

      expect(result.decision, equals(ContextGuardDecision.autoSafe));
      expect(result.isSafeToApply, isTrue);
      expect(result.checks.every((c) => c.passed), isTrue);
      expect(result.explanation, contains('High confidence'));
    });

    test('AUTO_SAFE exactly at 0.85 boundary', () {
      final result = guard.evaluate(
        inferredContext: AmbientContextType.arriving,
        confidence: 0.85,
        isPresenceConfirmed: true,
        hasConflictingSignals: false,
        isManualOverrideActive: false,
        isCooldownActive: false,
      );

      expect(result.decision, equals(ContextGuardDecision.autoSafe));
      expect(result.isSafeToApply, isTrue);
    });

    test('ASK_USER: confidence between 0.60 and 0.85 with no conflicts', () {
      final result = guard.evaluate(
        inferredContext: AmbientContextType.focus,
        confidence: 0.75,
        isPresenceConfirmed: true,
        hasConflictingSignals: false,
        isManualOverrideActive: false,
        isCooldownActive: false,
      );

      expect(result.decision, equals(ContextGuardDecision.askUser));
      expect(result.isSafeToApply, isTrue);
      expect(result.explanation, contains('User approval is recommended'));
    });

    test('ASK_USER: confidence >= 0.85 but physical presence is unconfirmed', () {
      final result = guard.evaluate(
        inferredContext: AmbientContextType.relaxation,
        confidence: 0.94,
        isPresenceConfirmed: false,
        hasConflictingSignals: false,
        isManualOverrideActive: false,
        isCooldownActive: false,
      );

      expect(result.decision, equals(ContextGuardDecision.askUser));
      expect(result.isSafeToApply, isTrue);
      expect(result.explanation, contains('physical presence is unconfirmed'));
    });

    test('NO_ACTION: confidence below 0.60 (< 0.60)', () {
      final result = guard.evaluate(
        inferredContext: AmbientContextType.neutral,
        confidence: 0.58,
        isPresenceConfirmed: true,
        hasConflictingSignals: false,
        isManualOverrideActive: false,
        isCooldownActive: false,
      );

      expect(result.decision, equals(ContextGuardDecision.noAction));
      expect(result.isSafeToApply, isFalse);
      expect(result.explanation, contains('below the safe actionable threshold'));
    });

    test('NO_ACTION: conflicting signals active even with high confidence', () {
      final result = guard.evaluate(
        inferredContext: AmbientContextType.uncertain,
        confidence: 0.95,
        isPresenceConfirmed: true,
        hasConflictingSignals: true,
        isManualOverrideActive: false,
        isCooldownActive: false,
      );

      expect(result.decision, equals(ContextGuardDecision.noAction));
      expect(result.isSafeToApply, isFalse);
      expect(result.explanation, contains('signals conflict'));
    });

    test('NO_ACTION: manual override active takes strict priority', () {
      final result = guard.evaluate(
        inferredContext: AmbientContextType.relaxation,
        confidence: 0.96,
        isPresenceConfirmed: true,
        hasConflictingSignals: false,
        isManualOverrideActive: true,
        isCooldownActive: false,
        overrideRemaining: const Duration(seconds: 120),
      );

      expect(result.decision, equals(ContextGuardDecision.noAction));
      expect(result.isSafeToApply, isFalse);
      expect(result.explanation, contains('adjusted smart devices manually'));
    });

    test('NO_ACTION: cooldown active prevents rapid spam triggers', () {
      final result = guard.evaluate(
        inferredContext: AmbientContextType.arriving,
        confidence: 0.92,
        isPresenceConfirmed: true,
        hasConflictingSignals: false,
        isManualOverrideActive: false,
        isCooldownActive: true,
        cooldownRemaining: const Duration(seconds: 30),
      );

      expect(result.decision, equals(ContextGuardDecision.noAction));
      expect(result.isSafeToApply, isFalse);
      expect(result.explanation, contains('Cooldown is active'));
    });
  });
}
