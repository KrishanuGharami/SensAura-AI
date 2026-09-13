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
  static final MockScenario focus = MockScenario(
    id: 'sim_focus',
    label: 'FOCUS',
    targetContext: AmbientContextType.focus,
    description: 'Static phone on desk + bright focused light (220 lux)',
    snapshot: SensorSnapshot(
      accelX: 0.01,
      accelY: 0.01,
      accelZ: 9.81,
      gyroX: 0.01,
      gyroY: 0.01,
      gyroZ: 0.01,
      lightLux: 220.0,
      proximityNear: false,
      bleDevicesCount: 2,
      homeBeaconDetected: true,
      homeBeaconRssi: -64,
      timestamp: DateTime.now(),
      isSimulated: true,
      sourceLabel: 'DEMO SIMULATION',
    ),
  );

  static final MockScenario relaxation = MockScenario(
    id: 'sim_relaxation',
    label: 'REST',
    targetContext: AmbientContextType.relaxation,
    description: 'Low motion + dim light (25 lux) + workstation beacon active',
    snapshot: SensorSnapshot(
      accelX: 0.04,
      accelY: 0.02,
      accelZ: 9.80,
      gyroX: 0.02,
      gyroY: 0.01,
      gyroZ: 0.01,
      lightLux: 25.0,
      proximityNear: true,
      bleDevicesCount: 3,
      homeBeaconDetected: true,
      homeBeaconRssi: -58,
      timestamp: DateTime.now(),
      isSimulated: true,
      sourceLabel: 'DEMO SIMULATION',
    ),
  );

  static final MockScenario breakTime = MockScenario(
    id: 'sim_break',
    label: 'BREAK',
    targetContext: AmbientContextType.breakTime,
    description: 'Periodic desk pause + gentle light + break intent',
    snapshot: SensorSnapshot(
      accelX: 0.20,
      accelY: 0.15,
      accelZ: 9.82,
      gyroX: 0.05,
      gyroY: 0.03,
      gyroZ: 0.02,
      lightLux: 80.0,
      proximityNear: false,
      bleDevicesCount: 3,
      homeBeaconDetected: true,
      homeBeaconRssi: -60,
      timestamp: DateTime.now(),
      isSimulated: true,
      sourceLabel: 'DEMO SIMULATION',
    ),
  );

  static final MockScenario leaving = MockScenario(
    id: 'sim_leaving',
    label: 'LEAVING',
    targetContext: AmbientContextType.leaving,
    description: 'High movement + Workstation BLE signal lost',
    snapshot: SensorSnapshot(
      accelX: 3.80,
      accelY: 3.20,
      accelZ: 11.80,
      gyroX: 1.80,
      gyroY: 1.20,
      gyroZ: 0.90,
      lightLux: 420.0,
      proximityNear: false,
      bleDevicesCount: 0,
      homeBeaconDetected: false,
      homeBeaconRssi: -100,
      timestamp: DateTime.now(),
      isSimulated: true,
      sourceLabel: 'DEMO SIMULATION',
    ),
  );

  static final MockScenario arrival = MockScenario(
    id: 'sim_arrival',
    label: 'ARRIVING',
    targetContext: AmbientContextType.arriving,
    description: 'Workstation beacon re-detected + walking motion settling',
    snapshot: SensorSnapshot(
      accelX: 1.80,
      accelY: 1.40,
      accelZ: 10.40,
      gyroX: 0.40,
      gyroY: 0.30,
      gyroZ: 0.20,
      lightLux: 140.0,
      proximityNear: false,
      bleDevicesCount: 3,
      homeBeaconDetected: true,
      homeBeaconRssi: -52,
      timestamp: DateTime.now(),
      isSimulated: true,
      sourceLabel: 'DEMO SIMULATION',
    ),
  );

  static final MockScenario sleep = MockScenario(
    id: 'sim_sleep',
    label: 'SLEEP',
    targetContext: AmbientContextType.sleep,
    description: 'Pitch dark (0.8 lux) + phone stationary + proximity covered',
    snapshot: SensorSnapshot(
      accelX: 0.00,
      accelY: 0.00,
      accelZ: 9.81,
      gyroX: 0.00,
      gyroY: 0.00,
      gyroZ: 0.00,
      lightLux: 0.8,
      proximityNear: true,
      bleDevicesCount: 1,
      homeBeaconDetected: true,
      homeBeaconRssi: -65,
      timestamp: DateTime.now(),
      isSimulated: true,
      sourceLabel: 'DEMO SIMULATION',
    ),
  );

  static final MockScenario uncertain = MockScenario(
    id: 'sim_uncertain',
    label: 'UNCERTAIN',
    targetContext: AmbientContextType.uncertain,
    description: 'Conflict: High motion + High light + Workstation BLE active',
    snapshot: SensorSnapshot(
      accelX: 4.20,
      accelY: 3.80,
      accelZ: 12.40,
      gyroX: 2.10,
      gyroY: 1.80,
      gyroZ: 1.40,
      lightLux: 420.0,
      proximityNear: false,
      bleDevicesCount: 3,
      homeBeaconDetected: true,
      homeBeaconRssi: -55,
      timestamp: DateTime.now(),
      isSimulated: true,
      sourceLabel: 'DEMO SIMULATION',
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
        focus,
        relaxation,
        breakTime,
        leaving,
        arrival,
        sleep,
        uncertain,
        neutral,
      ];
}
