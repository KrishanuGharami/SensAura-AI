import 'package:flutter_test/flutter_test.dart';
import 'package:sensaura_ai/core/constants/mock_scenarios.dart';
import 'package:sensaura_ai/models/ambient_context.dart';
import 'package:sensaura_ai/services/rule_based_context_engine.dart';

void main() {
  group('RuleBasedContextEngine Tests', () {
    late RuleBasedContextEngine engine;

    setUp(() {
      engine = RuleBasedContextEngine();
    });

    test('Engine runs locally and reports on-device status', () {
      expect(engine.isOnDevice, isTrue);
      expect(engine.engineName, contains('On-Device'));
    });

    test('Infers RELAXATION context under low motion, dim light and home beacon', () async {
      final result = await engine.inferContext(MockScenarios.relaxation.snapshot);

      expect(result.context, equals(AmbientContextType.relaxation));
      expect(result.confidence, greaterThanOrEqualTo(0.90));
      expect(result.reasoning.toLowerCase(), contains('relaxation'));
      expect(result.recommendedScene.id, equals('scene_relaxation'));
      expect(result.inferenceLatencyMs, lessThan(20.0)); // Well under real-time threshold
    });

    test('Infers LEAVING context under high motion and lost home beacon', () async {
      final result = await engine.inferContext(MockScenarios.leaving.snapshot);

      expect(result.context, equals(AmbientContextType.leaving));
      expect(result.confidence, greaterThanOrEqualTo(0.90));
      expect(result.reasoning.toLowerCase(), contains('departure'));
      expect(result.recommendedScene.id, equals('scene_energy_saving'));
    });

    test('Infers ARRIVAL context under strong home beacon RSSI and settling motion', () async {
      final result = await engine.inferContext(MockScenarios.arrival.snapshot);

      expect(result.context, equals(AmbientContextType.arriving));
      expect(result.confidence, greaterThanOrEqualTo(0.90));
      expect(result.recommendedScene.id, equals('scene_welcome_home'));
    });

    test('Infers DEEP FOCUS context under static phone and bright workspace light', () async {
      final result = await engine.inferContext(MockScenarios.focus.snapshot);

      expect(result.context, equals(AmbientContextType.focus));
      expect(result.confidence, greaterThanOrEqualTo(0.85));
      expect(result.recommendedScene.id, equals('scene_deep_focus'));
    });

    test('Infers SLEEP context under pitch darkness and stationary phone', () async {
      final result = await engine.inferContext(MockScenarios.sleep.snapshot);

      expect(result.context, equals(AmbientContextType.sleep));
      expect(result.confidence, greaterThanOrEqualTo(0.95));
      expect(result.recommendedScene.id, equals('scene_sleep_sanctuary'));
    });

    test('Infers UNCERTAIN context under conflicting signals (high motion + bright light + home BLE)', () async {
      final result = await engine.inferContext(MockScenarios.uncertain.snapshot);

      expect(result.context, equals(AmbientContextType.uncertain));
      expect(result.confidence, lessThan(0.60)); // Under actionable threshold
      expect(result.reasoning.toLowerCase(), contains('conflicting signals'));
      expect(result.detectedSignals.any((s) => s.contains('CONFLICT')), isTrue);
    });
  });
}
