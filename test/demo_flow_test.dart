import 'package:flutter_test/flutter_test.dart';
import 'package:sensaura_ai/core/constants/mock_scenarios.dart';
import 'package:sensaura_ai/models/ambient_context.dart';
import 'package:sensaura_ai/models/context_guard_result.dart';
import 'package:sensaura_ai/services/automation_service.dart';

void main() {
  group('SensAura AI Hackathon Demo Integration Flow Tests', () {
    late AutomationService service;

    setUp(() async {
      service = AutomationService();
      await service.init();
    });

    test('Full End-to-End Demo Scenario Execution Flow', () async {
      // Step 1 & 2: Local & Neutral State Verification
      expect(service.isInitialized, isTrue);
      expect(service.isHardwareMode, isFalse);
      expect(service.currentEngine.isOnDevice, isTrue);

      // Step 3: Neutral baseline context
      expect(service.latestContextResult.context, equals(AmbientContextType.neutral));

      // Step 4: Inject SIMULATE RELAXATION
      service.injectScenario(MockScenarios.relaxation);

      // Allow multi-step interpolation to settle
      await Future.delayed(const Duration(milliseconds: 1400));

      // Step 5, 6, 7 & 8: Verify Relaxation inference and confidence
      expect(service.latestSnapshot.lightLux, closeTo(18.0, 3.0));
      expect(service.latestContextResult.context, equals(AmbientContextType.relaxation));
      expect(service.latestContextResult.confidence, greaterThanOrEqualTo(0.90));
      expect(service.latestContextResult.confidencePercentage, contains('9'));
      expect(service.latestContextResult.reasoning.toLowerCase(), contains('relaxation'));

      // Step 9: Verify recommended scene is Relaxation Scene and Context Guard is AUTO_SAFE
      final recommendedScene = service.latestContextResult.recommendedScene;
      expect(recommendedScene.id, equals('scene_relaxation'));
      expect(service.latestGuardResult.decision, equals(ContextGuardDecision.autoSafe));

      // Step 10 & 11: Apply Relaxation Scene
      final initialEventCount = service.history.length;
      await service.applyScene(recommendedScene, manual: true);

      // Verify cooldown is now active
      expect(service.isCooldownActive, isTrue);
      expect(service.latestGuardResult.decision, equals(ContextGuardDecision.noAction));

      // Verify smart devices visibly updated
      final livingLight = service.devices.firstWhere((d) => d.id == 'light_living');
      final ac = service.devices.firstWhere((d) => d.id == 'ac_living');
      final speaker = service.devices.firstWhere((d) => d.id == 'speaker_living');

      expect(livingLight.isOn, isTrue);
      expect(livingLight.primaryValue, equals(30)); // 30% brightness
      expect(ac.isOn, isTrue);
      expect(ac.primaryValue, equals(24)); // 24°C
      expect(speaker.isOn, isTrue);
      expect(speaker.primaryValue, equals(20)); // 20% volume

      // Step 12: Verify history recorded event
      expect(service.history.length, equals(initialEventCount + 1));
      final latestEvent = service.history.first;
      expect(latestEvent.contextName, contains('Relaxation'));
      expect(latestEvent.sceneName, contains('Relaxation Scene applied'));

      // Step 13: Reset cooldown and inject SIMULATE LEAVING
      service.resetCooldown();
      service.injectScenario(MockScenarios.leaving);
      await Future.delayed(const Duration(milliseconds: 1400));

      // Step 14: Verify Energy Saving recommendation
      expect(service.latestContextResult.context, equals(AmbientContextType.leaving));
      expect(service.latestContextResult.recommendedScene.id, equals('scene_energy_saving'));

      // Step 15: Apply Energy Saving Scene
      await service.applyScene(service.latestContextResult.recommendedScene, manual: true);

      final lightAfterLeaving = service.devices.firstWhere((d) => d.id == 'light_living');
      final acAfterLeaving = service.devices.firstWhere((d) => d.id == 'ac_living');
      final speakerAfterLeaving = service.devices.firstWhere((d) => d.id == 'speaker_living');
      final plugAfterLeaving = service.devices.firstWhere((d) => d.id == 'plug_living');

      expect(lightAfterLeaving.isOn, isFalse);
      expect(acAfterLeaving.isOn, isFalse);
      expect(speakerAfterLeaving.isOn, isFalse);
      expect(plugAfterLeaving.isOn, isFalse);

      // Verify audit history has both events
      expect(service.history.length, equals(initialEventCount + 2));
      expect(service.history.first.contextName, contains('Leaving'));

      // Step 16: Test UNCERTAIN Scenario & Context Guard NO_ACTION
      service.resetCooldown();
      service.injectScenario(MockScenarios.uncertain);
      await Future.delayed(const Duration(milliseconds: 1400));

      expect(service.latestContextResult.context, equals(AmbientContextType.uncertain));
      expect(service.latestGuardResult.decision, equals(ContextGuardDecision.noAction));
      expect(service.latestGuardResult.summary, contains('Conflicting signals'));

      // Step 17: Test Manual Override Protection
      service.injectScenario(MockScenarios.arrival);
      await Future.delayed(const Duration(milliseconds: 1400));
      service.resetCooldown();

      // User manually overrides living light
      service.updateDevice('light_living', primaryValue: 100);
      expect(service.isManualOverrideActive, isTrue);
      expect(service.latestGuardResult.decision, equals(ContextGuardDecision.noAction));
      expect(service.latestGuardResult.summary, contains('Manual override'));

      // User clears manual override
      service.clearManualOverride();
      expect(service.isManualOverrideActive, isFalse);
    });
  });
}
