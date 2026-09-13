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
  final double gyroX;
  final double gyroY;
  final double gyroZ;
  final double lightLux;
  final bool proximityNear;
  final double proximityDistance;
  final int bleDevicesCount;
  final bool homeBeaconDetected;
  final int homeBeaconRssi; // in dBm e.g. -62
  final DateTime timestamp;
  final int monotonicTimestampMs;
  final bool isSimulated;
  final String sourceLabel;

  // Real silicon hardware availability flags
  final bool hasAccel;
  final bool hasGyro;
  final bool hasLight;
  final bool hasProximity;

  const SensorSnapshot({
    required this.accelX,
    required this.accelY,
    required this.accelZ,
    this.gyroX = 0.0,
    this.gyroY = 0.0,
    this.gyroZ = 0.0,
    required this.lightLux,
    required this.proximityNear,
    this.proximityDistance = 5.0,
    required this.bleDevicesCount,
    required this.homeBeaconDetected,
    this.homeBeaconRssi = -70,
    required this.timestamp,
    this.monotonicTimestampMs = 0,
    this.isSimulated = true,
    this.sourceLabel = 'ON-DEVICE SENSOR STREAM',
    this.hasAccel = true,
    this.hasGyro = false,
    this.hasLight = false,
    this.hasProximity = false,
  });

  /// Total acceleration magnitude in m/s^2
  double get accelMagnitude {
    return sqrt(accelX * accelX + accelY * accelY + accelZ * accelZ);
  }

  /// Total angular velocity magnitude in rad/s
  double get gyroMagnitude {
    return sqrt(gyroX * gyroX + gyroY * gyroY + gyroZ * gyroZ);
  }

  /// Dynamic motion level derived from gravity deviation and angular velocity
  MotionLevel get motionLevel {
    // Normal gravity magnitude is ~9.80665 m/s^2
    final deviation = (accelMagnitude - 9.80665).abs();
    if (deviation > 2.5 || gyroMagnitude > 1.2) {
      return MotionLevel.high;
    } else if (deviation > 1.2 || gyroMagnitude > 0.3) {
      return MotionLevel.medium;
    } else {
      return MotionLevel.low;
    }
  }

  /// Check if sensor telemetry is stale (has not updated within threshold)
  bool isStale([Duration threshold = const Duration(seconds: 10)]) {
    return DateTime.now().difference(timestamp) > threshold;
  }

  /// Helper factory for neutral initial state
  factory SensorSnapshot.neutral() {
    return SensorSnapshot(
      accelX: 0.85,
      accelY: 0.60,
      accelZ: 10.15,
      gyroX: 0.01,
      gyroY: 0.02,
      gyroZ: 0.01,
      lightLux: 75.0,
      proximityNear: false,
      proximityDistance: 5.0,
      bleDevicesCount: 2,
      homeBeaconDetected: true,
      homeBeaconRssi: -72,
      timestamp: DateTime.now(),
      monotonicTimestampMs: DateTime.now().millisecondsSinceEpoch,
      isSimulated: true,
      sourceLabel: 'DEMO SIMULATION',
      hasAccel: true,
      hasGyro: true,
      hasLight: true,
      hasProximity: true,
    );
  }

  /// Snapshot used when physical telemetry is unavailable.  It is deliberately
  /// stale so the Context Guard cannot act on placeholder values.
  factory SensorSnapshot.unavailable() {
    final staleTime = DateTime.fromMillisecondsSinceEpoch(0);
    return SensorSnapshot(
      accelX: 0.0,
      accelY: 0.0,
      accelZ: 0.0,
      gyroX: 0.0,
      gyroY: 0.0,
      gyroZ: 0.0,
      lightLux: 0.0,
      proximityNear: false,
      proximityDistance: 0.0,
      bleDevicesCount: 0,
      homeBeaconDetected: false,
      homeBeaconRssi: -100,
      timestamp: staleTime,
      monotonicTimestampMs: 0,
      isSimulated: false,
      sourceLabel: 'HARDWARE UNAVAILABLE',
      hasAccel: false,
      hasGyro: false,
      hasLight: false,
      hasProximity: false,
    );
  }

  SensorSnapshot copyWith({
    double? accelX,
    double? accelY,
    double? accelZ,
    double? gyroX,
    double? gyroY,
    double? gyroZ,
    double? lightLux,
    bool? proximityNear,
    double? proximityDistance,
    int? bleDevicesCount,
    bool? homeBeaconDetected,
    int? homeBeaconRssi,
    DateTime? timestamp,
    int? monotonicTimestampMs,
    bool? isSimulated,
    String? sourceLabel,
    bool? hasAccel,
    bool? hasGyro,
    bool? hasLight,
    bool? hasProximity,
  }) {
    return SensorSnapshot(
      accelX: accelX ?? this.accelX,
      accelY: accelY ?? this.accelY,
      accelZ: accelZ ?? this.accelZ,
      gyroX: gyroX ?? this.gyroX,
      gyroY: gyroY ?? this.gyroY,
      gyroZ: gyroZ ?? this.gyroZ,
      lightLux: lightLux ?? this.lightLux,
      proximityNear: proximityNear ?? this.proximityNear,
      proximityDistance: proximityDistance ?? this.proximityDistance,
      bleDevicesCount: bleDevicesCount ?? this.bleDevicesCount,
      homeBeaconDetected: homeBeaconDetected ?? this.homeBeaconDetected,
      homeBeaconRssi: homeBeaconRssi ?? this.homeBeaconRssi,
      timestamp: timestamp ?? this.timestamp,
      monotonicTimestampMs: monotonicTimestampMs ?? this.monotonicTimestampMs,
      isSimulated: isSimulated ?? this.isSimulated,
      sourceLabel: sourceLabel ?? this.sourceLabel,
      hasAccel: hasAccel ?? this.hasAccel,
      hasGyro: hasGyro ?? this.hasGyro,
      hasLight: hasLight ?? this.hasLight,
      hasProximity: hasProximity ?? this.hasProximity,
    );
  }
}
