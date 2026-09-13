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

  /// FOCUS Scene
  /// Light: ON 65% 4500K
  /// AC: ON 23°C Normal
  /// Fan: ON Speed 1
  /// Speaker: MUTED (0%)
  /// Socket: ON
  /// Workstation: FOCUS ACTIVE
  static const AutomationScene deepFocus = AutomationScene(
    id: 'scene_deep_focus',
    title: 'Adaptive Focus Profile',
    description: 'Workstation Focus Session • Media Muted • Display Calibrated • Distraction Blocked',
    icon: Icons.psychology_rounded,
    targetStates: {
      'workstation_node': {'isOn': true, 'profile': 'FOCUS', 'mode': 'FOCUS ACTIVE', 'mediaMuted': true, 'timerRunning': true},
      'light_living': {'isOn': true, 'brightness': 65, 'colorTemp': '4500K'},
      'ac_living': {'isOn': true, 'temperature': 23, 'mode': 'Normal'},
      'fan_living': {'isOn': true, 'speed': 1, 'mode': 'Speed 1'},
      'speaker_living': {'isOn': false, 'volume': 0, 'mode': 'MUTED', 'track': 'Muted'},
      'plug_living': {'isOn': true, 'powerWatts': 65, 'mode': 'ON'},
    },
  );

  /// REST Scene
  /// Light: ON 30% 2700K
  /// AC: ON 24°C Quiet
  /// Fan: ON Speed 1
  /// Speaker: 20% Relaxing
  /// Socket: ON
  /// Workstation: REST
  static const AutomationScene relaxation = AutomationScene(
    id: 'scene_relaxation',
    title: 'Adaptive Rest Profile',
    description: 'Workstation Rest Mode • Warm Ambient Light (30%) • Climate 24°C • Lo-Fi Acoustic (20%)',
    icon: Icons.spa_rounded,
    targetStates: {
      'workstation_node': {'isOn': true, 'profile': 'REST', 'mode': 'REST', 'mediaMuted': false, 'timerRunning': false},
      'light_living': {'isOn': true, 'brightness': 30, 'colorTemp': '2700K'},
      'ac_living': {'isOn': true, 'temperature': 24, 'mode': 'Quiet'},
      'fan_living': {'isOn': true, 'speed': 1, 'mode': 'Speed 1'},
      'speaker_living': {'isOn': true, 'volume': 20, 'mode': 'Relaxing', 'track': 'Relaxing'},
      'plug_living': {'isOn': true, 'powerWatts': 45, 'mode': 'ON'},
    },
  );

  /// BREAK Scene
  /// Light: ON 50% 3000K
  /// AC: ON 24°C
  /// Fan: ON Speed 1
  /// Speaker: 20%
  /// Socket: ON
  /// Workstation: BREAK
  static const AutomationScene breakTime = AutomationScene(
    id: 'scene_break_time',
    title: 'Adaptive Break Timer',
    description: 'Workstation 5-min Standby • Gentle Illumination • Break Reminder Dispatched',
    icon: Icons.coffee_rounded,
    targetStates: {
      'workstation_node': {'isOn': true, 'profile': 'BREAK', 'mode': 'BREAK', 'mediaMuted': true, 'timerRunning': true},
      'light_living': {'isOn': true, 'brightness': 50, 'colorTemp': '3000K'},
      'ac_living': {'isOn': true, 'temperature': 24, 'mode': 'Eco'},
      'fan_living': {'isOn': true, 'speed': 1, 'mode': 'Speed 1'},
      'speaker_living': {'isOn': true, 'volume': 20, 'mode': 'Break Audio', 'track': 'Break Audio'},
      'plug_living': {'isOn': true, 'powerWatts': 40, 'mode': 'ON'},
    },
  );

  /// ARRIVING Scene (Welcome Home)
  /// Light: 80% 3000K
  /// AC: 22°C Cool
  /// Fan: Speed 2
  /// Speaker: 35%
  /// Socket: ON
  /// Workstation: RESTORE
  static const AutomationScene welcomeHome = AutomationScene(
    id: 'scene_welcome_home',
    title: 'Welcome / Restore Workspace',
    description: 'Workstation Session Restored • Ambient Illumination (80%) • Climate 22°C',
    icon: Icons.home_rounded,
    targetStates: {
      'workstation_node': {'isOn': true, 'profile': 'ARRIVING', 'mode': 'RESTORE', 'locked': false, 'timerRunning': false},
      'light_living': {'isOn': true, 'brightness': 80, 'colorTemp': '3000K'},
      'ac_living': {'isOn': true, 'temperature': 22, 'mode': 'Cool'},
      'fan_living': {'isOn': true, 'speed': 2, 'mode': 'Speed 2'},
      'speaker_living': {'isOn': true, 'volume': 35, 'mode': 'Ambient', 'track': 'Ambient'},
      'plug_living': {'isOn': true, 'powerWatts': 85, 'mode': 'ON'},
    },
  );

  /// LEAVING Scene (Energy Saving)
  /// Light: OFF
  /// AC: OFF
  /// Fan: OFF
  /// Speaker: OFF
  /// Socket: OFF
  /// Workstation: LEAVING / SAFE STATE
  static const AutomationScene energySaving = AutomationScene(
    id: 'scene_energy_saving',
    title: 'Leaving / Secure Workstation',
    description: 'Workstation Lock Triggered • Display Standby • Peripherals Powered Off',
    icon: Icons.directions_walk_rounded,
    targetStates: {
      'workstation_node': {'isOn': false, 'profile': 'LEAVING', 'mode': 'LEAVING / SAFE STATE', 'locked': true, 'timerRunning': false},
      'light_living': {'isOn': false, 'brightness': 0, 'colorTemp': 'OFF'},
      'ac_living': {'isOn': false, 'temperature': 26, 'mode': 'OFF'},
      'fan_living': {'isOn': false, 'speed': 0, 'mode': 'OFF'},
      'speaker_living': {'isOn': false, 'volume': 0, 'mode': 'OFF', 'track': 'OFF'},
      'plug_living': {'isOn': false, 'powerWatts': 0, 'mode': 'OFF'},
    },
  );

  static const AutomationScene sleepSanctuary = AutomationScene(
    id: 'scene_sleep_sanctuary',
    title: 'Night Sleep Sanctuary',
    description: 'Zero illumination • Workstation Suspended • Quiet climate 21°C',
    icon: Icons.bedtime_rounded,
    targetStates: {
      'workstation_node': {'isOn': false, 'profile': 'REST', 'mode': 'REST', 'locked': true, 'timerRunning': false},
      'light_living': {'isOn': false, 'brightness': 0, 'colorTemp': '2200K'},
      'ac_living': {'isOn': true, 'temperature': 21, 'mode': 'Sleep'},
      'fan_living': {'isOn': true, 'speed': 1, 'mode': 'Speed 1'},
      'speaker_living': {'isOn': true, 'volume': 15, 'mode': 'Sleep Ambience', 'track': 'Deep Rain Ambience'},
      'plug_living': {'isOn': false, 'powerWatts': 0, 'mode': 'OFF'},
    },
  );

  static const AutomationScene neutral = AutomationScene(
    id: 'scene_neutral',
    title: 'Neutral Workspace Baseline',
    description: 'Standard baseline workstation and living environment',
    icon: Icons.sensors_rounded,
    targetStates: {
      'workstation_node': {'isOn': true, 'profile': 'RESET', 'mode': 'ACTIVE', 'locked': false, 'timerRunning': false},
      'light_living': {'isOn': true, 'brightness': 50, 'colorTemp': '3500K'},
      'ac_living': {'isOn': true, 'temperature': 24, 'mode': 'Auto'},
      'fan_living': {'isOn': false, 'speed': 0, 'mode': 'Standby'},
      'speaker_living': {'isOn': false, 'volume': 0, 'mode': 'Idle', 'track': 'Idle'},
      'plug_living': {'isOn': true, 'powerWatts': 30, 'mode': 'Active load'},
    },
  );
}
