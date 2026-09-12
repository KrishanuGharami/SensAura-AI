import 'package:flutter_test/flutter_test.dart';
import 'package:sensaura_ai/models/automation_scene.dart';

void main() {
  group('AutomationScene Model Tests', () {
    test('Relaxation Scene sets light to 30%, AC to 24C, speaker to 20%', () {
      const scene = AutomationScene.relaxation;
      expect(scene.id, equals('scene_relaxation'));
      expect(scene.targetStates['light_living']['brightness'], equals(30));
      expect(scene.targetStates['ac_living']['temperature'], equals(24));
      expect(scene.targetStates['speaker_living']['volume'], equals(20));
      expect(scene.targetStates['plug_living']['isOn'], isTrue);
    });

    test('Energy Saving Scene powers off all smart home devices', () {
      const scene = AutomationScene.energySaving;
      expect(scene.id, equals('scene_energy_saving'));
      expect(scene.targetStates['light_living']['isOn'], isFalse);
      expect(scene.targetStates['ac_living']['isOn'], isFalse);
      expect(scene.targetStates['speaker_living']['isOn'], isFalse);
      expect(scene.targetStates['plug_living']['isOn'], isFalse);
    });

    test('Welcome Home Scene initializes comfort climate and illumination', () {
      const scene = AutomationScene.welcomeHome;
      expect(scene.id, equals('scene_welcome_home'));
      expect(scene.targetStates['light_living']['brightness'], equals(80));
      expect(scene.targetStates['ac_living']['temperature'], equals(22));
    });
  });
}
