import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:sensors_plus/sensors_plus.dart';
import '../models/sensor_snapshot.dart';
import 'mock_sensor_provider.dart';
import 'sensor_provider.dart';

/// Physical hardware sensor adapter using sensors_plus with safe failsafe.
/// If physical hardware sensors are not available on the current device,
/// seamlessly and safely delegates to MockSensorProvider.
class RealSensorProvider implements SensorProvider {
  final StreamController<SensorSnapshot> _controller =
      StreamController<SensorSnapshot>.broadcast();
  final MockSensorProvider _fallbackMock = MockSensorProvider();

  StreamSubscription<AccelerometerEvent>? _accelSubscription;
  SensorSnapshot _current = SensorSnapshot.neutral();
  bool _isStreaming = false;
  bool _hardwareAvailable = false;

  @override
  Stream<SensorSnapshot> get sensorStream => _controller.stream;

  @override
  SensorSnapshot get currentSnapshot => _current;

  @override
  bool get isStreaming => _isStreaming;

  @override
  String get providerName => _hardwareAvailable
      ? 'Physical Silicon Sensors (Hardware)'
      : 'Sensor Fallback (Local Sim)';

  @override
  bool get isHardware => _hardwareAvailable;

  @override
  Future<void> start() async {
    if (_isStreaming) return;
    _isStreaming = true;

    try {
      // Attempt physical accelerometer listening
      _accelSubscription = accelerometerEventStream().listen(
        (AccelerometerEvent event) {
          _hardwareAvailable = true;
          _current = _current.copyWith(
            accelX: event.x,
            accelY: event.y,
            accelZ: event.z,
            timestamp: DateTime.now(),
            isSimulated: false,
            sourceLabel: 'PHYSICAL HARDWARE IMU',
          );
          _controller.add(_current);
        },
        onError: (error) {
          debugPrint('Hardware accelerometer unavailable, using safe fallback: $error');
          _hardwareAvailable = false;
          _activateFallback();
        },
        cancelOnError: false,
      );
    } catch (e) {
      debugPrint('Exception initializing hardware sensors: $e');
      _hardwareAvailable = false;
      _activateFallback();
    }
  }

  void _activateFallback() {
    _fallbackMock.start();
    _fallbackMock.sensorStream.listen((snapshot) {
      _current = snapshot;
      _controller.add(_current);
    });
  }

  @override
  Future<void> stop() async {
    _isStreaming = false;
    await _accelSubscription?.cancel();
    _accelSubscription = null;
    await _fallbackMock.stop();
  }

  @override
  void dispose() {
    _accelSubscription?.cancel();
    _fallbackMock.dispose();
    _controller.close();
  }
}
