import '../models/sensor_snapshot.dart';

/// Abstract hardware abstraction for sensor telemetry.
/// Emits continuous sensor snapshots whether originating from physical silicon or mock stream.
abstract class SensorProvider {
  /// Continuous stream of sensor telemetry
  Stream<SensorSnapshot> get sensorStream;

  /// Current latest snapshot
  SensorSnapshot get currentSnapshot;

  /// Whether the provider is currently active
  bool get isStreaming;

  /// Start telemetry
  Future<void> start();

  /// Stop telemetry
  Future<void> stop();

  /// Provider name/identifier
  String get providerName;

  /// Whether running real hardware sensors
  bool get isHardware;

  /// Dispose resources
  void dispose();
}
