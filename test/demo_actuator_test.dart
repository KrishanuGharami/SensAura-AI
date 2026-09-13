import 'package:flutter_test/flutter_test.dart';
import 'package:sensaura_ai/models/actuator_command.dart';
import 'package:sensaura_ai/models/ambient_context.dart';
import 'package:sensaura_ai/models/automation_scene.dart';
import 'package:sensaura_ai/models/context_guard_result.dart';
import 'package:sensaura_ai/services/context_guard.dart';
import 'package:sensaura_ai/services/demo_environment_actuator.dart';

void main() {
  group('Demo Connected Environment & Actuator Layer Tests', () {
    late DemoEnvironmentActuator actuator;

    setUp(() {
      // Use 5ms latency for fast deterministic unit tests
      actuator = DemoEnvironmentActuator(simulatedLatencyMs: 5);
    });

    tearDown(() {
      actuator.dispose();
    });

    test('1. Device Discovery: Discovers all 6 demo smart living endpoints',
        () async {
      await actuator.connect();
      expect(actuator.connectionState,
          equals(ActuatorConnectionState.demoActive));
      expect(actuator.isPhysicalHardware, isFalse);

      final devices = await actuator.discoverDevices();
      expect(devices.length, equals(6));

      final ids = devices.map((d) => d.id).toSet();
      expect(
          ids,
          containsAll([
            'light_living',
            'ac_living',
            'fan_living',
            'speaker_living',
            'plug_living',
            'workstation_node',
          ]));
    });

    test('2. Device Capabilities: Exposes exact capability lists', () async {
      final devices = await actuator.discoverDevices();

      final light = devices.firstWhere((d) => d.id == 'light_living');
      expect(light.capabilities,
          containsAll(['power', 'brightness', 'colorTemperature']));

      final ac = devices.firstWhere((d) => d.id == 'ac_living');
      expect(ac.capabilities, containsAll(['power', 'temperature', 'mode']));

      final fan = devices.firstWhere((d) => d.id == 'fan_living');
      expect(fan.capabilities, containsAll(['power', 'speed']));

      final speaker = devices.firstWhere((d) => d.id == 'speaker_living');
      expect(speaker.capabilities, containsAll(['power', 'volume', 'mode']));

      final plug = devices.firstWhere((d) => d.id == 'plug_living');
      expect(plug.capabilities, containsAll(['power']));

      final workstation =
          devices.firstWhere((d) => d.id == 'workstation_node');
      expect(workstation.capabilities,
          containsAll(['focus', 'rest', 'break', 'restore', 'safe_state']));
    });

    test('3. Command Acknowledgement: Dispatches command and receives ACK',
        () async {
      final cmd = ActuatorCommand(
        commandId: 'cmd_test_light',
        timestamp: DateTime.now(),
        deviceId: 'light_living',
        commandName: 'SET_BRIGHTNESS',
        requestedState: {'isOn': true, 'brightness': 65, 'colorTemp': '4500K'},
      );

      final result = await actuator.applyCommand(cmd);

      expect(result.success, isTrue);
      expect(result.commandId, equals('cmd_test_light'));
      expect(result.deviceId, equals('light_living'));
      expect(result.latencyMs, equals(5));
      expect(result.latencyLabel, equals('DEMO DEVICE RESPONSE'));

      final updatedLight = actuator.getDeviceState('light_living');
      expect(updatedLight, isNotNull);
      expect(updatedLight!.isOn, isTrue);
      expect(updatedLight.primaryValue, equals(65));
      expect(updatedLight.secondaryStatus, equals('4500K'));
      expect(updatedLight.lastCommandName, equals('SET_BRIGHTNESS'));
      expect(updatedLight.lastAckTime, isNotNull);
    });

    test('4. Device Unavailable: Fails cleanly if device does not exist',
        () async {
      final cmd = ActuatorCommand(
        commandId: 'cmd_nonexistent',
        timestamp: DateTime.now(),
        deviceId: 'unknown_device_999',
        commandName: 'TEST',
        requestedState: {'isOn': true},
      );

      final result = await actuator.applyCommand(cmd);

      expect(result.success, isFalse);
      expect(result.message, contains('Device not found in demo environment'));
    });

    test('5. Failed Command & Retry Simulation: Handles transient failure hook',
        () async {
      actuator.simulateFailure = true;

      final cmd = ActuatorCommand(
        commandId: 'cmd_fail_test',
        timestamp: DateTime.now(),
        deviceId: 'fan_living',
        commandName: 'SET_SPEED',
        requestedState: {'isOn': true, 'speed': 2},
      );

      final result = await actuator.applyCommand(cmd);
      expect(result.success, isFalse);
      expect(actuator.failureCount, equals(1));

      // Retry after transient failure
      actuator.simulateFailure = false;
      final retryResult = await actuator.applyCommand(cmd);
      expect(retryResult.success, isTrue);
      expect(actuator.getDeviceState('fan_living')!.primaryValue, equals(2));
    });

    test('6. FOCUS Scene Verification: Target states align with specification',
        () async {
      const scene = AutomationScene.deepFocus;

      for (final entry in scene.targetStates.entries) {
        final res = await actuator.applyCommand(ActuatorCommand(
          commandId: 'focus_${entry.key}',
          timestamp: DateTime.now(),
          deviceId: entry.key,
          commandName: scene.title,
          requestedState: entry.value as Map<String, dynamic>,
        ));
        expect(res.success, isTrue);
      }

      final light = actuator.getDeviceState('light_living')!;
      expect(light.isOn, isTrue);
      expect(light.primaryValue, equals(65));
      expect(light.secondaryStatus, equals('4500K'));

      final ac = actuator.getDeviceState('ac_living')!;
      expect(ac.isOn, isTrue);
      expect(ac.primaryValue, equals(23));
      expect(ac.secondaryStatus, equals('Normal'));

      final fan = actuator.getDeviceState('fan_living')!;
      expect(fan.isOn, isTrue);
      expect(fan.primaryValue, equals(1));

      final speaker = actuator.getDeviceState('speaker_living')!;
      expect(speaker.isOn, isFalse);
      expect(speaker.primaryValue, equals(0));

      final plug = actuator.getDeviceState('plug_living')!;
      expect(plug.isOn, isTrue);

      final workstation = actuator.getDeviceState('workstation_node')!;
      expect(workstation.secondaryStatus, equals('FOCUS ACTIVE'));
    });

    test('7. REST Scene Verification: Target states align with specification',
        () async {
      const scene = AutomationScene.relaxation;

      for (final entry in scene.targetStates.entries) {
        await actuator.applyCommand(ActuatorCommand(
          commandId: 'rest_${entry.key}',
          timestamp: DateTime.now(),
          deviceId: entry.key,
          commandName: scene.title,
          requestedState: entry.value as Map<String, dynamic>,
        ));
      }

      final light = actuator.getDeviceState('light_living')!;
      expect(light.isOn, isTrue);
      expect(light.primaryValue, equals(30));
      expect(light.secondaryStatus, equals('2700K'));

      final ac = actuator.getDeviceState('ac_living')!;
      expect(ac.isOn, isTrue);
      expect(ac.primaryValue, equals(24));
      expect(ac.secondaryStatus, equals('Quiet'));

      final fan = actuator.getDeviceState('fan_living')!;
      expect(fan.isOn, isTrue);
      expect(fan.primaryValue, equals(1));

      final speaker = actuator.getDeviceState('speaker_living')!;
      expect(speaker.isOn, isTrue);
      expect(speaker.primaryValue, equals(20));

      final plug = actuator.getDeviceState('plug_living')!;
      expect(plug.isOn, isTrue);

      final workstation = actuator.getDeviceState('workstation_node')!;
      expect(workstation.secondaryStatus, equals('REST'));
    });

    test('8. BREAK Scene Verification: Target states align with specification',
        () async {
      const scene = AutomationScene.breakTime;

      for (final entry in scene.targetStates.entries) {
        await actuator.applyCommand(ActuatorCommand(
          commandId: 'break_${entry.key}',
          timestamp: DateTime.now(),
          deviceId: entry.key,
          commandName: scene.title,
          requestedState: entry.value as Map<String, dynamic>,
        ));
      }

      final light = actuator.getDeviceState('light_living')!;
      expect(light.isOn, isTrue);
      expect(light.primaryValue, equals(50));

      final ac = actuator.getDeviceState('ac_living')!;
      expect(ac.isOn, isTrue);
      expect(ac.primaryValue, equals(24));

      final fan = actuator.getDeviceState('fan_living')!;
      expect(fan.isOn, isTrue);
      expect(fan.primaryValue, equals(1));

      final speaker = actuator.getDeviceState('speaker_living')!;
      expect(speaker.isOn, isTrue);
      expect(speaker.primaryValue, equals(20));

      final workstation = actuator.getDeviceState('workstation_node')!;
      expect(workstation.secondaryStatus, equals('BREAK'));
    });

    test(
        '9. ARRIVING Scene Verification: Target states align with specification',
        () async {
      const scene = AutomationScene.welcomeHome;

      for (final entry in scene.targetStates.entries) {
        await actuator.applyCommand(ActuatorCommand(
          commandId: 'arrive_${entry.key}',
          timestamp: DateTime.now(),
          deviceId: entry.key,
          commandName: scene.title,
          requestedState: entry.value as Map<String, dynamic>,
        ));
      }

      final light = actuator.getDeviceState('light_living')!;
      expect(light.primaryValue, equals(80));
      expect(light.secondaryStatus, equals('3000K'));

      final ac = actuator.getDeviceState('ac_living')!;
      expect(ac.primaryValue, equals(22));
      expect(ac.secondaryStatus, equals('Cool'));

      final fan = actuator.getDeviceState('fan_living')!;
      expect(fan.primaryValue, equals(2));

      final speaker = actuator.getDeviceState('speaker_living')!;
      expect(speaker.primaryValue, equals(35));

      final workstation = actuator.getDeviceState('workstation_node')!;
      expect(workstation.secondaryStatus, equals('RESTORE'));
    });

    test('10. LEAVING Scene Verification: All appliances power off', () async {
      const scene = AutomationScene.energySaving;

      for (final entry in scene.targetStates.entries) {
        await actuator.applyCommand(ActuatorCommand(
          commandId: 'leave_${entry.key}',
          timestamp: DateTime.now(),
          deviceId: entry.key,
          commandName: scene.title,
          requestedState: entry.value as Map<String, dynamic>,
        ));
      }

      expect(actuator.getDeviceState('light_living')!.isOn, isFalse);
      expect(actuator.getDeviceState('ac_living')!.isOn, isFalse);
      expect(actuator.getDeviceState('fan_living')!.isOn, isFalse);
      expect(actuator.getDeviceState('speaker_living')!.isOn, isFalse);
      expect(actuator.getDeviceState('plug_living')!.isOn, isFalse);
      expect(actuator.getDeviceState('workstation_node')!.isOn, isFalse);
      expect(actuator.getDeviceState('workstation_node')!.secondaryStatus,
          equals('LEAVING / SAFE STATE'));
    });

    test(
        '11. UNCERTAIN Safety: Context Guard NO_ACTION preserves environment unchanged',
        () async {
      // Establish baseline state
      await actuator.applyCommand(ActuatorCommand(
        commandId: 'baseline_light',
        timestamp: DateTime.now(),
        deviceId: 'light_living',
        commandName: 'BASELINE',
        requestedState: {'isOn': true, 'brightness': 80, 'colorTemp': '3000K'},
      ));

      final baselineLight = actuator.getDeviceState('light_living')!;
      expect(baselineLight.primaryValue, equals(80));

      // Evaluate uncertain context
      const guard = ContextGuard();
      final guardResult = guard.evaluate(
        inferredContext: AmbientContextType.uncertain,
        confidence: 0.45,
        isPresenceConfirmed: true,
        hasConflictingSignals: true,
        isManualOverrideActive: false,
        isCooldownActive: false,
        isActuatorAvailable: true,
        isSensorTelemetryFresh: true,
      );

      expect(guardResult.decision, equals(ContextGuardDecision.noAction));
      expect(guardResult.isSafeToApply, isFalse);

      // Enforce: NO ACTION taken when decision != autoSafe
      if (guardResult.isSafeToApply) {
        await actuator.applyCommand(ActuatorCommand(
          commandId: 'should_not_run',
          timestamp: DateTime.now(),
          deviceId: 'light_living',
          commandName: 'MUTATE',
          requestedState: {'brightness': 10},
        ));
      }

      // Verify environment remains completely untouched
      final preservedLight = actuator.getDeviceState('light_living')!;
      expect(preservedLight.primaryValue, equals(80));
      expect(preservedLight.secondaryStatus, equals('3000K'));
    });

    test('12. Manual Override Protection: Guard blocks automation during lease',
        () {
      const guard = ContextGuard();

      final guardResult = guard.evaluate(
        inferredContext: AmbientContextType.focus,
        confidence: 0.94,
        isPresenceConfirmed: true,
        hasConflictingSignals: false,
        isManualOverrideActive: true, // Manual lease active
        isCooldownActive: false,
        isActuatorAvailable: true,
        isSensorTelemetryFresh: true,
      );

      expect(guardResult.decision, equals(ContextGuardDecision.noAction));
      expect(guardResult.summary, contains('Manual override'));
      expect(guardResult.isSafeToApply, isFalse);
    });

    test('13. Cooldown Protection: Guard blocks rapid automation spam', () {
      const guard = ContextGuard();

      final guardResult = guard.evaluate(
        inferredContext: AmbientContextType.focus,
        confidence: 0.92,
        isPresenceConfirmed: true,
        hasConflictingSignals: false,
        isManualOverrideActive: false,
        isCooldownActive: true, // Cooldown timer active
        isActuatorAvailable: true,
        isSensorTelemetryFresh: true,
      );

      expect(guardResult.decision, equals(ContextGuardDecision.noAction));
      expect(guardResult.summary, contains('Cooldown'));
      expect(guardResult.isSafeToApply, isFalse);
    });
  });
}
