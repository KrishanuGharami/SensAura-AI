import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sensaura_ai/models/ambient_context.dart';
import 'package:sensaura_ai/models/automation_scene.dart';
import 'package:sensaura_ai/models/context_guard_result.dart';
import 'package:sensaura_ai/models/context_result.dart';
import 'package:sensaura_ai/models/pose_feature_snapshot.dart';
import 'package:sensaura_ai/models/sensor_snapshot.dart';
import 'package:sensaura_ai/models/vision_context_sample.dart';
import 'package:sensaura_ai/screens/ai_context_screen.dart';
import 'package:sensaura_ai/services/context_guard.dart';
import 'package:sensaura_ai/services/mediapipe_vision_provider.dart';
import 'package:sensaura_ai/services/rule_based_context_engine.dart';
import 'package:sensaura_ai/services/vision_temporal_fusion_engine.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('1. Vision Context & Gesture Models', () {
    test('HandGesture: all 6 gestures provide explicit intent and metadata', () {
      expect(HandGesture.openPalm.isExplicitIntent, isTrue);
      expect(HandGesture.openPalm.emoji, equals('✋'));
      expect(HandGesture.openPalm.symbol, equals('✋'));
      expect(HandGesture.openPalm.displayName, contains('Open Palm'));

      expect(HandGesture.thumbUp.isExplicitIntent, isTrue);
      expect(HandGesture.thumbUp.emoji, equals('👍'));

      expect(HandGesture.thumbDown.isExplicitIntent, isTrue);
      expect(HandGesture.thumbDown.emoji, equals('👎'));

      expect(HandGesture.victory.isExplicitIntent, isTrue);
      expect(HandGesture.victory.emoji, equals('✌️'));

      expect(HandGesture.closedFist.isExplicitIntent, isTrue);
      expect(HandGesture.closedFist.emoji, equals('✊'));

      expect(HandGesture.pointingUp.isExplicitIntent, isTrue);
      expect(HandGesture.pointingUp.emoji, equals('☝️'));

      expect(HandGesture.none.isExplicitIntent, isFalse);
      expect(HandGesture.unknown.isExplicitIntent, isFalse);
    });

    test('VisibleExpressionSignal: honest observable geometric signals', () {
      for (final signal in VisibleExpressionSignal.values) {
        expect(signal.displayName, isNotEmpty);
        expect(signal.userDescription, isNotEmpty);
        expect(signal.badgeColor, isNotNull);
      }
      expect(VisibleExpressionSignal.calm.displayName, equals('Calm Signal'));
      expect(VisibleExpressionSignal.engaged.displayName, equals('Engaged Focus'));
      expect(VisibleExpressionSignal.positive.displayName, equals('Positive Expression'));
      expect(VisibleExpressionSignal.eyesClosed.displayName, equals('Eyes Closed'));
    });

    test('AiRuntimeBackend: verified runtime acceleration flags', () {
      expect(AiRuntimeBackend.gpu.isHardwareAccelerated, isTrue);
      expect(AiRuntimeBackend.npu.isHardwareAccelerated, isTrue);
      expect(AiRuntimeBackend.cpu.isHardwareAccelerated, isFalse);
      expect(AiRuntimeBackend.localFallback.isHardwareAccelerated, isFalse);
      expect(AiRuntimeBackend.localFallback.displayName, contains('LOCAL FALLBACK'));
    });

    test('VisionContextSample: factories and convenience getters', () {
      final neutral = VisionContextSample.neutral();
      expect(neutral.faceDetected, isTrue);
      expect(neutral.faceLandmarkCount, equals(468));
      expect(neutral.posture, equals(ObservablePosture.seated));
      expect(neutral.postureConfidence, greaterThan(0.8));
      expect(neutral.expressionSignal, equals(VisibleExpressionSignal.calm));
      expect(neutral.isPrivacyPreserved, isTrue);

      final unknown = VisionContextSample.unknown();
      expect(unknown.faceDetected, isFalse);
      expect(unknown.faceLandmarkCount, equals(0));
      expect(unknown.posture, equals(ObservablePosture.unknown));
      expect(unknown.gesture, equals(HandGesture.none));
    });
  });

  group('2. MediaPipe Vision Provider', () {
    test('Initializes with honest local fallback without throwing', () async {
      final provider = MediaPipeVisionProvider();
      final ok = await provider.initialize();
      expect(ok, isTrue);
      expect(provider.runtimeBackend, equals(AiRuntimeBackend.localFallback));
      expect(provider.latestSample.faceDetected, isTrue);
      provider.dispose();
    });

    test('Injects sample cleanly and updates latestSample', () {
      final provider = MediaPipeVisionProvider();
      final customSample = VisionContextSample.neutral().copyWith(
        gesture: HandGesture.victory,
        gestureConfidence: 0.96,
        poseState: ObservablePosture.standing,
      );

      provider.injectVisionSample(customSample);
      expect(provider.latestSample.gesture, equals(HandGesture.victory));
      expect(provider.latestSample.posture, equals(ObservablePosture.standing));
      expect(provider.latestSample.gestureConfidence, equals(0.96));
      provider.dispose();
    });
  });

  group('3. Temporal Fusion Engine & Debouncing', () {
    test('Gesture Debouncing: requires sustained samples before emitting', () {
      final fusion = VisionTemporalFusionEngine();
      final sample = VisionContextSample.neutral().copyWith(
        gesture: HandGesture.openPalm,
        gestureConfidence: 0.95,
      );

      // 1-3 samples should NOT trigger yet (under minGestureConfirmations = 4)
      fusion.addSample(sample);
      expect(fusion.getStabilizedGesture(), equals(HandGesture.none));

      fusion.addSample(sample);
      expect(fusion.getStabilizedGesture(), equals(HandGesture.none));

      fusion.addSample(sample);
      expect(fusion.getStabilizedGesture(), equals(HandGesture.none));

      // 4th sustained sample triggers stabilized gesture
      fusion.addSample(sample);
      expect(fusion.getStabilizedGesture(), equals(HandGesture.openPalm));
      expect(fusion.lastEmittedGesture, equals(HandGesture.openPalm));
    });

    test('Conflict Detection: stationary phone + walking camera -> conflict & UNCERTAIN', () {
      final fusion = VisionTemporalFusionEngine();
      final stationaryPhone = SensorSnapshot(
        accelX: 0.0,
        accelY: 0.0,
        accelZ: 9.80665,
        lightLux: 350.0,
        proximityNear: false,
        bleDevicesCount: 2,
        homeBeaconDetected: true,
        timestamp: DateTime.now(),
      );

      final movingCamera = VisionContextSample.neutral().copyWith(
        poseState: ObservablePosture.moving,
        poseConfidence: 0.92,
        cameraMotion: 0.65,
      );

      final result = fusion.evaluateFusion(
        sensorSnapshot: stationaryPhone,
        visionSample: movingCamera,
        baselineContext: AmbientContextType.focus,
        baselineSensorConfidence: 0.90,
      );

      expect(result.hasConflict, isTrue);
      expect(result.context, equals(AmbientContextType.uncertain));
      expect(result.fusedConfidence, lessThanOrEqualTo(0.50));
      expect(result.reasoning, contains('Vision and sensor signals disagree'));
    });

    test('Multimodal Agreement: stationary desk phone + calm seated camera -> elevated confidence', () {
      final fusion = VisionTemporalFusionEngine();
      final deskPhone = SensorSnapshot(
        accelX: 0.0,
        accelY: 0.0,
        accelZ: 9.80665,
        lightLux: 350.0,
        proximityNear: false,
        bleDevicesCount: 3,
        homeBeaconDetected: true,
        timestamp: DateTime.now(),
      );

      final calmSeated = VisionContextSample.neutral().copyWith(
        poseState: ObservablePosture.seated,
        expressionSignal: VisibleExpressionSignal.calm,
        visionConfidence: 0.92,
      );

      final result = fusion.evaluateFusion(
        sensorSnapshot: deskPhone,
        visionSample: calmSeated,
        baselineContext: AmbientContextType.focus,
        baselineSensorConfidence: 0.88,
      );

      expect(result.hasConflict, isFalse);
      expect(result.context, equals(AmbientContextType.focus));
      expect(result.fusedConfidence, greaterThanOrEqualTo(0.88));
      expect(result.contributingSignals.any((s) => s.contains('Seated at Desk')), isTrue);
    });
  });

  group('4. SensAura Context Guard Safety with Gestures', () {
    const guard = ContextGuard();

    test('✋ Open Palm Gesture: forces NO_ACTION / Automation Paused', () {
      final guardResult = guard.evaluate(
        inferredContext: AmbientContextType.focus,
        confidence: 0.95,
        isPresenceConfirmed: true,
        hasConflictingSignals: false,
        isManualOverrideActive: false,
        isCooldownActive: false,
        isActuatorAvailable: true,
        isSensorTelemetryFresh: true,
        isAutomationPausedByGesture: true, // ✋ USER GESTURE PAUSE
      );

      expect(guardResult.decision, equals(ContextGuardDecision.noAction));
      expect(guardResult.decision.userBadge, contains('AUTOMATION PAUSED'));
      expect(guardResult.isSafeToApply, isFalse);
      expect(guardResult.summary, contains('Automation paused: User gesture'));
    });

    test('Conflicting signals: forces NO_ACTION even if confidence was high', () {
      final guardResult = guard.evaluate(
        inferredContext: AmbientContextType.uncertain,
        confidence: 0.88,
        isPresenceConfirmed: true,
        hasConflictingSignals: true, // Conflict active
        isManualOverrideActive: false,
        isCooldownActive: false,
        isActuatorAvailable: true,
        isSensorTelemetryFresh: true,
      );

      expect(guardResult.decision, equals(ContextGuardDecision.noAction));
      expect(guardResult.hasConflictingSignals, isTrue);
      expect(guardResult.isSafeToApply, isFalse);
    });
  });

  group('5. Rule-Based Context Engine with Vision Integration', () {
    final engine = RuleBasedContextEngine();

    test('Vision Conflict: phone stationary + camera moving -> UNCERTAIN context', () async {
      final phone = SensorSnapshot(
        accelX: 0.0,
        accelY: 0.0,
        accelZ: 9.80665,
        lightLux: 350.0,
        proximityNear: false,
        bleDevicesCount: 2,
        homeBeaconDetected: true,
        timestamp: DateTime.now(),
      );

      final cameraWalking = VisionContextSample.neutral().copyWith(
        poseState: ObservablePosture.moving,
        poseConfidence: 0.95,
      );

      final result = await engine.inferContext(
        phone,
        vision: cameraWalking,
      );

      expect(result.context, equals(AmbientContextType.uncertain));
      expect(result.confidence, lessThanOrEqualTo(0.50));
      expect(result.guardResult.hasConflictingSignals, isTrue);
    });

    test('✌️ Victory Gesture override: triggers FOCUS context recommendation', () async {
      final phone = SensorSnapshot(
        accelX: 0.0,
        accelY: 0.0,
        accelZ: 9.80665,
        lightLux: 200.0,
        proximityNear: false,
        bleDevicesCount: 2,
        homeBeaconDetected: true,
        timestamp: DateTime.now(),
      );

      final victoryVision = VisionContextSample.neutral().copyWith(
        gesture: HandGesture.victory,
        gestureConfidence: 0.95,
      );

      final result = await engine.inferContext(
        phone,
        vision: victoryVision,
      );

      expect(result.context, equals(AmbientContextType.focus));
      expect(result.confidence, greaterThanOrEqualTo(0.90));
      expect(result.recommendedScene, equals(AutomationScene.deepFocus));
      expect(result.reasoning, contains('Victory gesture'));
    });

    test('✊ Closed Fist Gesture override: triggers REST / RELAXATION context', () async {
      final phone = SensorSnapshot(
        accelX: 0.0,
        accelY: 0.0,
        accelZ: 9.80665,
        lightLux: 400.0,
        proximityNear: false,
        bleDevicesCount: 2,
        homeBeaconDetected: true,
        timestamp: DateTime.now(),
      );

      final fistVision = VisionContextSample.neutral().copyWith(
        gesture: HandGesture.closedFist,
        gestureConfidence: 0.95,
      );

      final result = await engine.inferContext(
        phone,
        vision: fistVision,
      );

      expect(result.context, equals(AmbientContextType.relaxation));
      expect(result.confidence, greaterThanOrEqualTo(0.90));
      expect(result.recommendedScene, equals(AutomationScene.relaxation));
      expect(result.reasoning, contains('Closed Fist gesture'));
    });
  });

  group('6. AiContextScreen UI & HUD Overlay Tests', () {
    testWidgets('Renders camera viewport, AI runtime badge, and toggles overlay', (tester) async {
      final sample = VisionContextSample.neutral();
      final contextResult = ContextResult(
        context: AmbientContextType.focus,
        confidence: 0.94,
        reasoning: 'Calm user seated at workstation with focused lighting.',
        detectedSignals: ['Stationary phone', 'Face detected', 'Focused light'],
        recommendedScene: AutomationScene.deepFocus,
        inferenceLatencyMs: 11.2,
        evaluatedAt: DateTime.now(),
      );

      bool paused = false;
      bool applied = false;
      HandGesture? injected;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AiContextScreen(
              result: contextResult,
              visionSample: sample,
              isAutomationPaused: false,
              isApplyingScene: false,
              onApplyScene: (_) => applied = true,
              onPauseAutomation: () => paused = true,
              onResumeAutomation: () => paused = false,
              onInjectGesture: (g) => injected = g,
            ),
          ),
        ),
      );

      // Verify viewport and honest runtime badge
      expect(find.textContaining('CAMERA:'), findsOneWidget);
      expect(find.textContaining('LOCAL FALLBACK'), findsOneWidget);
      expect(find.text('HIDE AI OVERLAY'), findsOneWidget);
      expect(find.textContaining('DEEP FOCUS'), findsOneWidget);

      // Toggle overlay off
      await tester.tap(find.text('HIDE AI OVERLAY'));
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('SHOW AI OVERLAY'), findsOneWidget);

      // Scroll to and tap gesture chip (Victory)
      await tester.ensureVisible(find.text('✌️ Focus Mode'));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.tap(find.text('✌️ Focus Mode'));
      await tester.pump(const Duration(milliseconds: 100));
      expect(injected, equals(HandGesture.victory));

      // Scroll to and tap Pause button
      await tester.ensureVisible(find.text('PAUSE (✋)'));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.tap(find.text('PAUSE (✋)'));
      await tester.pump(const Duration(milliseconds: 100));
      expect(paused, isTrue);

      // Scroll to and tap Apply / Confirm Scene button
      await tester.ensureVisible(find.text('APPLY / 👍 CONFIRM'));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.tap(find.text('APPLY / 👍 CONFIRM'));
      await tester.pump(const Duration(milliseconds: 100));
      expect(applied, isTrue);
    });

    testWidgets('Renders gesture pause banner when isAutomationPaused is true', (tester) async {
      final sample = VisionContextSample.neutral();
      final contextResult = ContextResult(
        context: AmbientContextType.focus,
        confidence: 0.94,
        reasoning: 'Calm user seated at workstation.',
        detectedSignals: ['Stationary phone'],
        recommendedScene: AutomationScene.deepFocus,
        inferenceLatencyMs: 10.0,
        evaluatedAt: DateTime.now(),
      );

      bool resumed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AiContextScreen(
              result: contextResult,
              visionSample: sample,
              isAutomationPaused: true,
              isApplyingScene: false,
              onApplyScene: (_) {},
              onPauseAutomation: () {},
              onResumeAutomation: () => resumed = true,
            ),
          ),
        ),
      );

      expect(find.text('AUTOMATION PAUSED BY USER GESTURE'), findsOneWidget);
      expect(find.text('RESUME AUTOMATION'), findsOneWidget);

      await tester.tap(find.text('RESUME AUTOMATION'));
      await tester.pump();
      expect(resumed, isTrue);
    });
  });
}
