import 'dart:math';

enum MotionLevel {
  low,
  medium,
  high;

  String get displayName {
    switch (this) {
      case MotionLevel.low:
        return 'Low Motion';
      case MotionLevel.medium:
        return 'Moderate';
      case MotionLevel.high:
        return 'High Movement';
    }
  }
}

class SensorSnapshot {
  final double accelX;
  final double accelY;
  final double accelZ;
  final double lightLux;
  final bool proximityNear;
  final int bleDevicesCount;
  final bool homeBeaconDetected;
  final int homeBeaconRssi; // in dBm e.g. -62
  final DateTime timestamp;
  final bool isSimulated;
  final String sourceLabel;

  const SensorSnapshot({
    required this.accelX,
    required this.accelY,
    required this.accelZ,
    required this.lightLux,
    required this.proximityNear,
    required this.bleDevicesCount,
    required this.homeBeaconDetected,
    this.homeBeaconRssi = -70,
    required this.timestamp,
    this.isSimulated = true,
    this.sourceLabel = 'ON-DEVICE SENSOR STREAM',
  });

  /// Total acceleration magnitude
  double get accelMagnitude {
    return sqrt(accelX * accelX + accelY * accelY + accelZ * accelZ);
  }

  /// Dynamic motion level derived from gravity deviation
  MotionLevel get motionLevel {
    // Normal gravity magnitude is ~9.8 m/s^2
    final deviation = (accelMagnitude - 9.80665).abs();
    if (deviation < 1.2) {
      return MotionLevel.low;
    } else if (deviation < 2.5) {
      return MotionLevel.medium;
    } else {
      return MotionLevel.high;
    }
  }

  /// Helper factory for neutral initial state
  factory SensorSnapshot.neutral() {
    return SensorSnapshot(
      accelX: 0.85,
      accelY: 0.60,
      accelZ: 10.15,
      lightLux: 75.0,
      proximityNear: false,
      bleDevicesCount: 2,
      homeBeaconDetected: true,
      homeBeaconRssi: -72,
      timestamp: DateTime.now(),
      isSimulated: true,
      sourceLabel: 'SIMULATED / LOCAL',
    );
  }

  SensorSnapshot copyWith({
    double? accelX,
    double? accelY,
    double? accelZ,
    double? lightLux,
    bool? proximityNear,
    int? bleDevicesCount,
    bool? homeBeaconDetected,
    int? homeBeaconRssi,
    DateTime? timestamp,
    bool? isSimulated,
    String? sourceLabel,
  }) {
    return SensorSnapshot(
      accelX: accelX ?? this.accelX,
      accelY: accelY ?? this.accelY,
      accelZ: accelZ ?? this.accelZ,
      lightLux: lightLux ?? this.lightLux,
      proximityNear: proximityNear ?? this.proximityNear,
      bleDevicesCount: bleDevicesCount ?? this.bleDevicesCount,
      homeBeaconDetected: homeBeaconDetected ?? this.homeBeaconDetected,
      homeBeaconRssi: homeBeaconRssi ?? this.homeBeaconRssi,
      timestamp: timestamp ?? this.timestamp,
      isSimulated: isSimulated ?? this.isSimulated,
      sourceLabel: sourceLabel ?? this.sourceLabel,
    );
  }
}
