import 'package:flutter_test/flutter_test.dart';
import 'package:sensaura_ai/models/ambient_context.dart';
import 'package:sensaura_ai/models/automation_scene.dart';
import 'package:sensaura_ai/models/context_guard_result.dart';
import 'package:sensaura_ai/models/context_result.dart';
import 'package:sensaura_ai/models/pose_feature_snapshot.dart';
import 'package:sensaura_ai/models/sensor_snapshot.dart';
import 'package:sensaura_ai/services/local_explanation_engine.dart';
import 'package:sensaura_ai/services/voice_intent_provider.dart';
import 'package:sensaura_ai/services/workstation_actuator_provider.dart';

void main() {
  group('SensAura Hardware MVP Extensions Tests', () {
    test('PoseFeatureSnapshot preserves privacy and computes geometry', () {
      final posture = PoseFeatureSnapshot(
        posture: ObservablePosture.seated,
        confidence: 0.88,
        stabilityScore: 0.92,
        isUserPresent: true,
        headTiltAngle: 3.5,
        timestamp: DateTime.now(),
      );

      expect(posture.posture, equals(ObservablePosture.seated));
      expect(posture.isPrivacyPreserved, isTrue);
      expect(posture.posture.displayName, equals('Seated at Desk'));
      expect(posture.stabilityScore, greaterThan(0.9));
      expect(posture.headTiltAngle, closeTo(3.5, 0.1));
    });

    test('VoiceIntentSnapshot accurately classifies local voice intent', () {
      final focusIntent = VoiceIntentSnapshot(
        intent: VoiceIntent.focus,
        rawPhrase: 'focus mode',
        confidence: 0.95,
        timestamp: DateTime.now(),
        isLocalModel: true,
      );

      expect(focusIntent.intent, equals(VoiceIntent.focus));
      expect(focusIntent.intent.label, equals('Focus Mode'));
      expect(focusIntent.isLocalModel, isTrue);

      final breakIntent = VoiceIntentSnapshot(
        intent: VoiceIntent.breakTime,
        rawPhrase: 'take a break',
        confidence: 0.91,
        timestamp: DateTime.now(),
      );

      expect(breakIntent.intent, equals(VoiceIntent.breakTime));
      expect(breakIntent.intent.label, equals('Take a Break'));
    });

    test('LocalExplanationEngine generates natural language explanation', () {
      const engine = LocalExplanationEngine();
      final sensorSnapshot = SensorSnapshot(
        accelX: 0.05,
        accelY: 0.05,
        accelZ: 9.81,
        lightLux: 220.0,
        proximityNear: false,
        bleDevicesCount: 2,
        homeBeaconDetected: true,
        homeBeaconRssi: -62,
        timestamp: DateTime.now(),
      );

      final postureSnapshot = PoseFeatureSnapshot(
        posture: ObservablePosture.seated,
        confidence: 0.90,
        stabilityScore: 0.94,
        isUserPresent: true,
        headTiltAngle: 2.0,
        timestamp: DateTime.now(),
      );

      final contextResult = ContextResult(
        context: AmbientContextType.focus,
        confidence: 0.95,
        reasoning: 'Bright focused light + static phone indicates deep focus.',
        detectedSignals: const ['Static motion', 'Bright light'],
        recommendedScene: AutomationScene.deepFocus,
        inferenceLatencyMs: 0.8,
        evaluatedAt: DateTime.now(),
        guardResult: ContextGuardResult(
          decision: ContextGuardDecision.autoSafe,
          summary: 'Safe for automated execution',
          explanation: 'High confidence with verified presence',
          checks: const [],
          isSafeToApply: true,
          evaluatedAt: DateTime.now(),
        ),
      );

      final explanation = engine.explain(
        contextResult: contextResult,
        sensorSnapshot: sensorSnapshot,
        postureSnapshot: postureSnapshot,
      );

      expect(explanation, isNotEmpty);
      expect(explanation, contains('Deep Focus'));
      expect(explanation, contains('seated'));
      expect(explanation, contains('95%'));
    });

    test('WorkstationActuatorProvider initial status and configuration', () {
      final provider = WorkstationActuatorProvider();

      expect(provider.status, equals(WorkstationStatus.disconnected));
      expect(provider.isConnected, isFalse);
      expect(provider.host, equals('127.0.0.1'));
      expect(provider.port, equals(8765));
      expect(provider.lastAck, isNull);
      provider.dispose();
    });

    test('Production endpoint rejects public hosts and arbitrary commands', () async {
      final provider = WorkstationActuatorProvider(host: '8.8.8.8');

      expect(await provider.checkConnection(), isFalse);
      expect(await provider.dispatchCommand('SHELL'), isFalse);
      expect(provider.status, equals(WorkstationStatus.actuatorFailed));

      provider.dispose();
    });

    test('Unavailable sensor snapshots are stale and cannot be treated as telemetry', () {
      final snapshot = SensorSnapshot.unavailable();

      expect(snapshot.isSimulated, isFalse);
      expect(snapshot.sourceLabel, equals('HARDWARE UNAVAILABLE'));
      expect(snapshot.isStale(), isTrue);
      expect(snapshot.hasAccel, isFalse);
      expect(snapshot.hasLight, isFalse);
    });
  });
}
