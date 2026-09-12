class AutomationEvent {
  final String id;
  final DateTime timestamp;
  final String contextName;
  final String sceneName;
  final String reasoning;
  final String sensorSummary;
  final bool appliedByUser;

  const AutomationEvent({
    required this.id,
    required this.timestamp,
    required this.contextName,
    required this.sceneName,
    required this.reasoning,
    required this.sensorSummary,
    this.appliedByUser = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'timestamp': timestamp.toIso8601String(),
      'contextName': contextName,
      'sceneName': sceneName,
      'reasoning': reasoning,
      'sensorSummary': sensorSummary,
      'appliedByUser': appliedByUser,
    };
  }

  factory AutomationEvent.fromMap(Map<dynamic, dynamic> map) {
    return AutomationEvent(
      id: map['id'] as String? ?? EventIdGenerator.next(),
      timestamp: map['timestamp'] != null
          ? DateTime.tryParse(map['timestamp'].toString()) ?? DateTime.now()
          : DateTime.now(),
      contextName: map['contextName'] as String? ?? 'Context Event',
      sceneName: map['sceneName'] as String? ?? 'Scene Applied',
      reasoning: map['reasoning'] as String? ?? '',
      sensorSummary: map['sensorSummary'] as String? ?? '',
      appliedByUser: map['appliedByUser'] as bool? ?? true,
    );
  }

  static List<AutomationEvent> initialDemoEvents() {
    final now = DateTime.now();
    return [
      AutomationEvent(
        id: 'evt_1',
        timestamp: now.subtract(const Duration(minutes: 42)),
        contextName: 'Relaxation detected',
        sceneName: 'Relaxation Scene applied',
        reasoning: 'Low motion + dim light (18 lux) + home BLE beacon active',
        sensorSummary: 'Light: 18 lux • Motion: Low • BLE: 3 devices',
        appliedByUser: true,
      ),
      AutomationEvent(
        id: 'evt_2',
        timestamp: now.subtract(const Duration(hours: 2, minutes: 15)),
        contextName: 'Leaving context detected',
        sceneName: 'Energy Saving Scene applied',
        reasoning: 'High movement + Home BLE signal lost',
        sensorSummary: 'Light: 410 lux • Motion: High • BLE: 0 devices',
        appliedByUser: true,
      ),
    ];
  }
}

class EventIdGenerator {
  static int _counter = 0;
  static String next() => 'evt_${DateTime.now().millisecondsSinceEpoch}_${++_counter}';
}
