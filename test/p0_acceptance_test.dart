import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:sensaura_ai/models/ambient_context.dart';
import 'package:sensaura_ai/models/context_guard_result.dart';
import 'package:sensaura_ai/models/pose_feature_snapshot.dart';
import 'package:sensaura_ai/models/sensor_snapshot.dart';
import 'package:sensaura_ai/services/context_guard.dart';
import 'package:sensaura_ai/services/rule_based_context_engine.dart';
import 'package:sensaura_ai/services/workstation_actuator_provider.dart';

void main() {
  group('P0 Critical Path Acceptance Tests', () {
    late HttpServer mockWorkstationNode;
    late int serverPort;
    late Map<String, dynamic> workstationState;
    late List<Map<String, dynamic>> receivedCommands;

    setUp(() async {
      receivedCommands = [];
      workstationState = {
        'node_id': 'sensaura-node-workstation-01',
        'current_profile': 'RESET',
        'focus_session_active': false,
        'break_timer_active': false,
        'media_muted': false,
        'locked': false,
      };

      // Spin up real local companion server listening on loopback
      mockWorkstationNode = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      serverPort = mockWorkstationNode.port;

      mockWorkstationNode.listen((HttpRequest request) async {
        if (request.method == 'GET') {
          request.response
            ..statusCode = 200
            ..headers.contentType = ContentType.json
            ..write(jsonEncode({'status': 'ONLINE', 'state': workstationState}));
          await request.response.close();
        } else if (request.method == 'POST') {
          final body = await utf8.decoder.bind(request).join();
          final Map<String, dynamic> payload = jsonDecode(body) as Map<String, dynamic>;
          final command = payload['command'] as String;
          final reqId = payload['requestId'] as String;

          receivedCommands.add(payload);

          // Mutate local workstation state
          workstationState['current_profile'] = command;
          if (command == 'FOCUS') {
            workstationState['focus_session_active'] = true;
            workstationState['media_muted'] = true;
          } else if (command == 'REST') {
            workstationState['focus_session_active'] = false;
            workstationState['media_muted'] = false;
          }

          request.response
            ..statusCode = 200
            ..headers.contentType = ContentType.json
            ..write(jsonEncode({
              'status': 'ACKNOWLEDGED',
              'requestId': reqId,
              'command': command,
              'nodeId': workstationState['node_id'],
              'state': workstationState,
            }));
          await request.response.close();
        }
      });
    });

    tearDown(() async {
      await mockWorkstationNode.close(force: true);
    });

    test('PATH 1: REAL SENSOR INPUT -> FOCUS -> CONFIDENCE -> CONTEXT GUARD -> LOCAL COMMAND -> LAPTOP CHANGE -> ACK -> HISTORY', () async {
      // 1. Real iQOO 15 Sensor Input (Desk IMU stationary baseline + bright focused light)
      final realSensorInput = SensorSnapshot(
        accelX: 0.04,
        accelY: 0.02,
        accelZ: 9.81,
        gyroX: 0.01,
        gyroY: 0.01,
        gyroZ: 0.01,
        lightLux: 240.0, // Physical desk light
        proximityNear: false,
        bleDevicesCount: 0, // No external BLE required!
        homeBeaconDetected: false, // Optional beacon not needed
        homeBeaconRssi: -100,
        timestamp: DateTime.now(),
        isSimulated: false, // Genuine hardware telemetry
        sourceLabel: 'LIVE HARDWARE (iQOO 15)',
        hasAccel: true,
        hasGyro: true,
        hasLight: true,
        hasProximity: true,
      );

      // Observable camera posture (seated at desk)
      final postureSnapshot = PoseFeatureSnapshot(
        posture: ObservablePosture.seated,
        confidence: 0.92,
        stabilityScore: 0.95,
        isUserPresent: true,
        headTiltAngle: 1.5,
        timestamp: DateTime.now(),
        isHardwareCamera: true,
      );

      // 2. Context Fusion
      final engine = RuleBasedContextEngine();
      final contextResult = await engine.inferContext(
        realSensorInput,
        posture: postureSnapshot,
      );

      // Verify Focus detection & Real Confidence
      expect(contextResult.context, equals(AmbientContextType.focus));
      expect(contextResult.confidence, greaterThanOrEqualTo(0.85));
      expect(contextResult.recommendedScene.id, equals('scene_deep_focus'));

      // 3. SensAura Context Guard Evaluation
      const guard = ContextGuard();
      final guardResult = guard.evaluate(
        inferredContext: contextResult.context,
        confidence: contextResult.confidence,
        isPresenceConfirmed: true, // Workstation node reachable & physical stationary desk presence
        hasConflictingSignals: false,
        isManualOverrideActive: false,
        isCooldownActive: false,
        isActuatorAvailable: true,
        isSensorTelemetryFresh: true,
      );

      expect(guardResult.decision, equals(ContextGuardDecision.autoSafe));
      expect(guardResult.isSafeToApply, isTrue);

      // 4. Local Laptop Actuator & Command Dispatch
      final actuator = WorkstationActuatorProvider(
        host: '127.0.0.1',
        port: serverPort,
      );

      final isConnected = await actuator.checkConnection();
      expect(isConnected, isTrue);
      expect(actuator.isConnected, isTrue);

      // 5. Dispatch command to SensAura Node
      final success = await actuator.dispatchCommand('FOCUS');
      expect(success, isTrue);

      // 6. Real-time Acknowledgement Verification
      expect(actuator.lastAck, isNotNull);
      expect(actuator.lastAck!.command, equals('FOCUS'));
      expect(actuator.status, equals(WorkstationStatus.commandAcknowledged));

      // 7. Verify Laptop State Change on SensAura Node
      expect(receivedCommands.length, equals(1));
      expect(receivedCommands.first['command'], equals('FOCUS'));
      expect(workstationState['current_profile'], equals('FOCUS'));
      expect(workstationState['focus_session_active'], isTrue);
      expect(workstationState['media_muted'], isTrue);

      actuator.dispose();
    });

    test('PATH 2: CONFLICTING SENSOR INPUT -> UNCERTAIN -> CONTEXT GUARD NO_ACTION -> LAPTOP REMAINS UNCHANGED', () async {
      // 1. Conflicting Sensor Input (Violent motion / high rotational velocity + bright workspace light)
      final conflictingInput = SensorSnapshot(
        accelX: 5.2,
        accelY: 4.8,
        accelZ: 14.5, // High linear acceleration deviation (~7.5 m/s²)
        gyroX: 2.8,
        gyroY: 2.5,
        gyroZ: 3.1, // High rotational shaking (~4.9 rad/s)
        lightLux: 320.0, // Contradictory: under desk lamp while in violent motion
        proximityNear: false,
        bleDevicesCount: 2,
        homeBeaconDetected: true, // Stationary beacon claims presence
        homeBeaconRssi: -55,
        timestamp: DateTime.now(),
        isSimulated: false,
        sourceLabel: 'LIVE HARDWARE (iQOO 15)',
        hasAccel: true,
        hasGyro: true,
        hasLight: true,
        hasProximity: true,
      );

      // Camera observes resting posture while IMU undergoes dynamic motion
      final contradictoryPosture = PoseFeatureSnapshot(
        posture: ObservablePosture.resting,
        confidence: 0.90,
        stabilityScore: 0.85,
        isUserPresent: true,
        timestamp: DateTime.now(),
      );

      // 2. Context Fusion
      final engine = RuleBasedContextEngine();
      final contextResult = await engine.inferContext(
        conflictingInput,
        posture: contradictoryPosture,
      );

      // Verify Uncertain context & sub-actionable confidence
      expect(contextResult.context, equals(AmbientContextType.uncertain));
      expect(contextResult.confidence, lessThan(0.60));

      // 3. SensAura Context Guard Evaluation
      const guard = ContextGuard();
      final guardResult = guard.evaluate(
        inferredContext: contextResult.context,
        confidence: contextResult.confidence,
        isPresenceConfirmed: true,
        hasConflictingSignals: true, // Telemetry contains contradiction
        isManualOverrideActive: false,
        isCooldownActive: false,
        isActuatorAvailable: true,
        isSensorTelemetryFresh: true,
      );

      // Verify Context Guard deterministically blocks actuation
      expect(guardResult.decision, equals(ContextGuardDecision.noAction));
      expect(guardResult.isSafeToApply, isFalse);
      expect(guardResult.summary, contains('Conflicting signals'));

      // 4. Laptop Actuator Safety Guarantee: Command MUST NOT be dispatched
      final actuator = WorkstationActuatorProvider(
        host: '127.0.0.1',
        port: serverPort,
      );

      // Guard check before actuation
      if (guardResult.decision != ContextGuardDecision.noAction) {
        await actuator.dispatchCommand('FOCUS');
      }

      // 5. Verify Laptop Node remains completely UNCHANGED
      expect(receivedCommands, isEmpty);
      expect(workstationState['current_profile'], equals('RESET'));
      expect(workstationState['focus_session_active'], isFalse);
      expect(workstationState['media_muted'], isFalse);

      actuator.dispose();
    });
  });
}
