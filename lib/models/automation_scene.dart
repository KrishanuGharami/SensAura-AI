import 'package:flutter/material.dart';

class AutomationScene {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final Map<String, dynamic> targetStates;

  const AutomationScene({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.targetStates,
  });

  static const AutomationScene relaxation = AutomationScene(
    id: 'scene_relaxation',
    title: 'Relaxation Scene',
    description: 'Warm ambient glow (30%), Climate 24°C, Low volume acoustics (20%)',
    icon: Icons.spa_rounded,
    targetStates: {
      'light_living': {'isOn': true, 'brightness': 30, 'colorTemp': 'Warm 2700K'},
      'ac_living': {'isOn': true, 'temperature': 24, 'mode': 'Quiet'},
      'fan_living': {'isOn': false, 'speed': 0},
      'speaker_living': {'isOn': true, 'volume': 20, 'track': 'Acoustic Lo-Fi Chill'},
      'plug_living': {'isOn': true, 'powerWatts': 45},
    },
  );

  static const AutomationScene energySaving = AutomationScene(
    id: 'scene_energy_saving',
    title: 'Energy Saving Scene',
    description: 'Complete standby mode: All lights, climate, and peripherals turned OFF',
    icon: Icons.energy_savings_leaf_rounded,
    targetStates: {
      'light_living': {'isOn': false, 'brightness': 0, 'colorTemp': 'Warm 2700K'},
      'ac_living': {'isOn': false, 'temperature': 26, 'mode': 'Eco'},
      'fan_living': {'isOn': false, 'speed': 0},
      'speaker_living': {'isOn': false, 'volume': 0, 'track': 'Paused'},
      'plug_living': {'isOn': false, 'powerWatts': 0},
    },
  );

  static const AutomationScene welcomeHome = AutomationScene(
    id: 'scene_welcome_home',
    title: 'Welcome Home Scene',
    description: 'Comfort entry: Bright ambient lighting (80%), AC 22°C, Smart Plug ON',
    icon: Icons.home_rounded,
    targetStates: {
      'light_living': {'isOn': true, 'brightness': 80, 'colorTemp': 'Warm 3000K'},
      'ac_living': {'isOn': true, 'temperature': 22, 'mode': 'Cool'},
      'fan_living': {'isOn': true, 'speed': 2},
      'speaker_living': {'isOn': true, 'volume': 35, 'track': 'Welcome Chill Playlist'},
      'plug_living': {'isOn': true, 'powerWatts': 85},
    },
  );

  static const AutomationScene deepFocus = AutomationScene(
    id: 'scene_deep_focus',
    title: 'Deep Focus Scene',
    description: 'Crisp balanced light (65%), AC 23°C, Low white noise, Distraction-free',
    icon: Icons.psychology_rounded,
    targetStates: {
      'light_living': {'isOn': true, 'brightness': 65, 'colorTemp': 'Cool 4500K'},
      'ac_living': {'isOn': true, 'temperature': 23, 'mode': 'Normal'},
      'fan_living': {'isOn': true, 'speed': 1},
      'speaker_living': {'isOn': false, 'volume': 0, 'track': 'Muted'},
      'plug_living': {'isOn': true, 'powerWatts': 65},
    },
  );

  static const AutomationScene sleepSanctuary = AutomationScene(
    id: 'scene_sleep_sanctuary',
    title: 'Sleep Sanctuary Scene',
    description: 'Zero illumination, night climate 21°C, quiet fan, white noise soundscape',
    icon: Icons.bedtime_rounded,
    targetStates: {
      'light_living': {'isOn': false, 'brightness': 0, 'colorTemp': 'Warm 2200K'},
      'ac_living': {'isOn': true, 'temperature': 21, 'mode': 'Sleep'},
      'fan_living': {'isOn': true, 'speed': 1},
      'speaker_living': {'isOn': true, 'volume': 15, 'track': 'Deep Rain Ambience'},
      'plug_living': {'isOn': false, 'powerWatts': 0},
    },
  );

  static const AutomationScene neutral = AutomationScene(
    id: 'scene_neutral',
    title: 'Neutral Ambient Scene',
    description: 'Standard baseline living room operation',
    icon: Icons.sensors_rounded,
    targetStates: {
      'light_living': {'isOn': true, 'brightness': 50, 'colorTemp': 'Natural 3500K'},
      'ac_living': {'isOn': true, 'temperature': 24, 'mode': 'Auto'},
      'fan_living': {'isOn': false, 'speed': 0},
      'speaker_living': {'isOn': false, 'volume': 0, 'track': 'Idle'},
      'plug_living': {'isOn': true, 'powerWatts': 30},
    },
  );
}
