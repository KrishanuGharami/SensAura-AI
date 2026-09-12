import 'package:flutter_test/flutter_test.dart';
import 'package:sensaura_ai/models/sensor_snapshot.dart';

void main() {
  group('SensorSnapshot Model Tests', () {
    test('Calculates accurate 3D acceleration magnitude', () {
      final snap = SensorSnapshot(
        accelX: 0.0,
        accelY: 0.0,
        accelZ: 9.80665,
        lightLux: 100.0,
        proximityNear: false,
        bleDevicesCount: 2,
        homeBeaconDetected: true,
        timestamp: DateTime(2026, 9, 8, 20, 0),
      );

      expect(snap.accelMagnitude, closeTo(9.80665, 0.001));
      expect(snap.motionLevel, equals(MotionLevel.low));
    });

    test('Detects high motion deviation', () {
      final highMotionSnap = SensorSnapshot(
        accelX: 4.0,
        accelY: 3.5,
        accelZ: 12.0,
        lightLux: 300.0,
        proximityNear: false,
        bleDevicesCount: 1,
        homeBeaconDetected: false,
        timestamp: DateTime(2026, 9, 8, 20, 0),
      );

      expect(highMotionSnap.accelMagnitude, greaterThan(13.0));
      expect(highMotionSnap.motionLevel, equals(MotionLevel.high));
    });

    test('Detects neutral initial factory', () {
      final neutral = SensorSnapshot.neutral();
      expect(neutral.lightLux, equals(75.0));
      expect(neutral.proximityNear, isFalse);
      expect(neutral.homeBeaconDetected, isTrue);
      expect(neutral.isSimulated, isTrue);
    });
  });
}
