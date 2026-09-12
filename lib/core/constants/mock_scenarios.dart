import '../../models/sensor_snapshot.dart';
import '../../models/ambient_context.dart';

class MockScenario {
  final String id;
  final String label;
  final AmbientContextType targetContext;
  final SensorSnapshot snapshot;
  final String description;

  const MockScenario({
    required this.id,
    required this.label,
    required this.targetContext,
    required this.snapshot,
    required this.description,
  });
}

class MockScenarios {
  static final MockScenario relaxation = MockScenario(
    id: 'sim_relaxation',
    label: 'RELAXATION',
    targetContext: AmbientContextType.relaxation,
    description: 'Low motion + dim light (18 lux) + home BLE beacon active',
    snapshot: SensorSnapshot(
      accelX: 0.04,
      accelY: 0.02,
      accelZ: 9.80,
      lightLux: 18.0,
      proximityNear: true,
      bleDevicesCount: 3,
      homeBeaconDetected: true,
      homeBeaconRssi: -58,
      timestamp: DateTime.now(),
      isSimulated: true,
      sourceLabel: 'SIMULATED / LOCAL',
    ),
  );

  static final MockScenario leaving = MockScenario(
    id: 'sim_leaving',
    label: 'LEAVING',
    targetContext: AmbientContextType.leaving,
    description: 'High movement + Home BLE signal lost',
    snapshot: SensorSnapshot(
      accelX: 3.80,
      accelY: 3.20,
      accelZ: 11.80,
      lightLux: 420.0,
      proximityNear: false,
      bleDevicesCount: 0,
      homeBeaconDetected: false,
      homeBeaconRssi: -100,
      timestamp: DateTime.now(),
      isSimulated: true,
      sourceLabel: 'SIMULATED / LOCAL',
    ),
  );

  static final MockScenario arrival = MockScenario(
    id: 'sim_arrival',
    label: 'ARRIVAL',
    targetContext: AmbientContextType.arriving,
    description: 'Home BLE beacon re-detected + walking motion settling',
    snapshot: SensorSnapshot(
      accelX: 1.80,
      accelY: 1.40,
      accelZ: 10.40,
      lightLux: 140.0,
      proximityNear: false,
      bleDevicesCount: 3,
      homeBeaconDetected: true,
      homeBeaconRssi: -52,
      timestamp: DateTime.now(),
      isSimulated: true,
      sourceLabel: 'SIMULATED / LOCAL',
    ),
  );

  static final MockScenario focus = MockScenario(
    id: 'sim_focus',
    label: 'DEEP FOCUS',
    targetContext: AmbientContextType.focus,
    description: 'Static phone on desk + bright focused light (220 lux)',
    snapshot: SensorSnapshot(
      accelX: 0.01,
      accelY: 0.01,
      accelZ: 9.81,
      lightLux: 220.0,
      proximityNear: false,
      bleDevicesCount: 2,
      homeBeaconDetected: true,
      homeBeaconRssi: -64,
      timestamp: DateTime.now(),
      isSimulated: true,
      sourceLabel: 'SIMULATED / LOCAL',
    ),
  );

  static final MockScenario sleep = MockScenario(
    id: 'sim_sleep',
    label: 'SLEEP SANCTUARY',
    targetContext: AmbientContextType.sleep,
    description: 'Pitch dark (0.8 lux) + phone stationary + proximity covered',
    snapshot: SensorSnapshot(
      accelX: 0.00,
      accelY: 0.00,
      accelZ: 9.81,
      lightLux: 0.8,
      proximityNear: true,
      bleDevicesCount: 1,
      homeBeaconDetected: true,
      homeBeaconRssi: -65,
      timestamp: DateTime.now(),
      isSimulated: true,
      sourceLabel: 'SIMULATED / LOCAL',
    ),
  );

  static final MockScenario uncertain = MockScenario(
    id: 'sim_uncertain',
    label: 'UNCERTAIN',
    targetContext: AmbientContextType.uncertain,
    description: 'Conflict: High motion + High light + Home BLE active',
    snapshot: SensorSnapshot(
      accelX: 4.20,
      accelY: 3.80,
      accelZ: 12.40,
      lightLux: 420.0,
      proximityNear: false,
      bleDevicesCount: 3,
      homeBeaconDetected: true,
      homeBeaconRssi: -55,
      timestamp: DateTime.now(),
      isSimulated: true,
      sourceLabel: 'SIMULATED / LOCAL',
    ),
  );

  static final MockScenario neutral = MockScenario(
    id: 'sim_neutral',
    label: 'RESET NEUTRAL',
    targetContext: AmbientContextType.neutral,
    description: 'Balanced ambient baseline',
    snapshot: SensorSnapshot.neutral(),
  );

  static List<MockScenario> get all => [
        relaxation,
        leaving,
        arrival,
        focus,
        sleep,
        uncertain,
        neutral,
      ];
}
