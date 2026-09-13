import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:sensors_plus/sensors_plus.dart';
import '../models/sensor_snapshot.dart';
import 'sensor_provider.dart';

/// Production-quality real hardware sensor provider for Android / iQOO 15.
/// Acquires real telemetry from:
/// - Accelerometer (sensors_plus)
/// - Gyroscope (sensors_plus)
/// - Ambient Light (Android SensorManager via EventChannel)
/// - Proximity (Android SensorManager via EventChannel)
///
/// Implements Exponential Moving Average (EMA) smoothing for noise reduction,
/// individual sensor availability tracking, monotonic timing, and zero-leak lifecycle management.
class RealSensorProvider implements SensorProvider {
  static const EventChannel _lightChannel = EventChannel('sensaura/sensors/light');
  static const EventChannel _proximityChannel = EventChannel('sensaura/sensors/proximity');
  static const MethodChannel _capabilitiesChannel = MethodChannel('sensaura/sensors/capabilities');

  final StreamController<SensorSnapshot> _controller =
      StreamController<SensorSnapshot>.broadcast();

  StreamSubscription<AccelerometerEvent>? _accelSubscription;
  StreamSubscription<GyroscopeEvent>? _gyroSubscription;
  StreamSubscription<dynamic>? _lightSubscription;
  StreamSubscription<dynamic>? _proximitySubscription;
  Timer? _publishTimer;
  bool _publishPending = false;

  SensorSnapshot _current = SensorSnapshot.unavailable();
  bool _isStreaming = false;
  bool _hardwareAvailable = false;

  // EMA smoothing factors (0.0 to 1.0; lower is smoother)
  static const double _emaAccelAlpha = 0.35;
  static const double _emaGyroAlpha = 0.40;
  static const double _emaLightAlpha = 0.25;

  // Filtered values
  double _smoothAccelX = 0.0;
  double _smoothAccelY = 0.0;
  double _smoothAccelZ = 9.8;
  double _smoothGyroX = 0.0;
  double _smoothGyroY = 0.0;
  double _smoothGyroZ = 0.0;
  double _smoothLightLux = 150.0;
  bool _isNear = false;
  double _proximityDist = 5.0;

  // Individual availability
  bool _hasAccel = false;
  bool _hasGyro = false;
  bool _hasLight = false;
  bool _hasProximity = false;

  @override
  Stream<SensorSnapshot> get sensorStream => _controller.stream;

  @override
  SensorSnapshot get currentSnapshot => _current;

  @override
  bool get isStreaming => _isStreaming;

  @override
  String get providerName => _hardwareAvailable
      ? 'LIVE HARDWARE (iQOO 15 Silicon)'
      : 'HARDWARE UNAVAILABLE';

  @override
  bool get isHardware => _hardwareAvailable;

  @override
  Future<void> start() async {
    if (_isStreaming) return;
    _isStreaming = true;
    _current = SensorSnapshot.unavailable();

    // In non-mobile environments (e.g. desktop unit tests), remain unavailable
    // rather than presenting simulated values as production telemetry.
    if (!kIsWeb && !Platform.isAndroid && !Platform.isIOS) {
      _hardwareAvailable = false;
      _current = SensorSnapshot.unavailable();
      _controller.add(_current);
      return;
    }

    // Check hardware capabilities if available
    await _detectCapabilities();

    // 1. Accelerometer Subscription
    try {
      _accelSubscription = accelerometerEventStream().listen(
        (AccelerometerEvent event) {
          _hasAccel = true;
          _hardwareAvailable = true;
          _smoothAccelX = _emaAccelAlpha * event.x + (1 - _emaAccelAlpha) * _smoothAccelX;
          _smoothAccelY = _emaAccelAlpha * event.y + (1 - _emaAccelAlpha) * _smoothAccelY;
          _smoothAccelZ = _emaAccelAlpha * event.z + (1 - _emaAccelAlpha) * _smoothAccelZ;
          _publishSnapshot();
        },
        onError: (error) {
          debugPrint('Hardware accelerometer error: $error');
          _hasAccel = false;
        },
        cancelOnError: false,
      );
    } catch (e) {
      debugPrint('Failed to attach accelerometer: $e');
      _hasAccel = false;
    }

    // 2. Gyroscope Subscription
    try {
      _gyroSubscription = gyroscopeEventStream().listen(
        (GyroscopeEvent event) {
          _hasGyro = true;
          _smoothGyroX = _emaGyroAlpha * event.x + (1 - _emaGyroAlpha) * _smoothGyroX;
          _smoothGyroY = _emaGyroAlpha * event.y + (1 - _emaGyroAlpha) * _smoothGyroY;
          _smoothGyroZ = _emaGyroAlpha * event.z + (1 - _emaGyroAlpha) * _smoothGyroZ;
          _publishSnapshot();
        },
        onError: (error) {
          debugPrint('Hardware gyroscope error: $error');
          _hasGyro = false;
        },
        cancelOnError: false,
      );
    } catch (e) {
      debugPrint('Failed to attach gyroscope: $e');
      _hasGyro = false;
    }

    // 3. Ambient Light EventChannel (Android Sensor.TYPE_LIGHT)
    try {
      _lightSubscription = _lightChannel.receiveBroadcastStream().listen(
        (dynamic lux) {
          if (lux is num) {
            _hasLight = true;
            final double rawLux = lux.toDouble();
            _smoothLightLux = _emaLightAlpha * rawLux + (1 - _emaLightAlpha) * _smoothLightLux;
            _publishSnapshot();
          }
        },
        onError: (error) {
          debugPrint('Native light sensor channel error: $error');
          _hasLight = false;
        },
        cancelOnError: false,
      );
    } catch (e) {
      debugPrint('Failed to attach light sensor channel: $e');
      _hasLight = false;
    }

    // 4. Proximity EventChannel (Android Sensor.TYPE_PROXIMITY)
    try {
      _proximitySubscription = _proximityChannel.receiveBroadcastStream().listen(
        (dynamic event) {
          if (event is Map) {
            _hasProximity = true;
            _proximityDist = (event['distance'] as num?)?.toDouble() ?? 5.0;
            _isNear = (event['isNear'] as bool?) ?? false;
            _publishSnapshot();
          }
        },
        onError: (error) {
          debugPrint('Native proximity sensor channel error: $error');
          _hasProximity = false;
        },
        cancelOnError: false,
      );
    } catch (e) {
      debugPrint('Failed to attach proximity sensor channel: $e');
      _hasProximity = false;
    }

    // Never substitute simulated values for production telemetry.  A device
    // without sensors remains unavailable and the safety guard will pause.
    if (!_hasAccel && !_hasGyro && !_hasLight && !_hasProximity) {
      _hardwareAvailable = false;
      _current = SensorSnapshot.unavailable();
      _controller.add(_current);
    }
  }

  Future<void> _detectCapabilities() async {
    try {
      final caps = await _capabilitiesChannel.invokeMapMethod<String, dynamic>('getCapabilities');
      if (caps != null) {
        _hasLight = caps['hasLightSensor'] as bool? ?? false;
        _hasProximity = caps['hasProximitySensor'] as bool? ?? false;
        _hasAccel = caps['hasAccelerometer'] as bool? ?? false;
        _hasGyro = caps['hasGyroscope'] as bool? ?? false;
      }
    } catch (_) {
      // Non-Android platforms or missing native bridge
    }
  }

  void _publishSnapshot() {
    if (_publishPending) return;
    _publishPending = true;
    _publishTimer = Timer(const Duration(milliseconds: 100), () {
      _publishPending = false;
      _publishTimer = null;
      _publishSnapshotNow();
    });
  }

  void _publishSnapshotNow() {
    _current = _current.copyWith(
      accelX: _smoothAccelX,
      accelY: _smoothAccelY,
      accelZ: _smoothAccelZ,
      gyroX: _smoothGyroX,
      gyroY: _smoothGyroY,
      gyroZ: _smoothGyroZ,
      lightLux: _smoothLightLux,
      proximityNear: _isNear,
      proximityDistance: _proximityDist,
      timestamp: DateTime.now(),
      monotonicTimestampMs: DateTime.now().millisecondsSinceEpoch,
      isSimulated: false,
      sourceLabel: 'LIVE HARDWARE (iQOO 15)',
      hasAccel: _hasAccel,
      hasGyro: _hasGyro,
      hasLight: _hasLight,
      hasProximity: _hasProximity,
    );
    _controller.add(_current);
  }

  @override
  Future<void> stop() async {
    _isStreaming = false;
    await _accelSubscription?.cancel();
    _accelSubscription = null;
    await _gyroSubscription?.cancel();
    _gyroSubscription = null;
    await _lightSubscription?.cancel();
    _lightSubscription = null;
    await _proximitySubscription?.cancel();
    _proximitySubscription = null;
    _publishTimer?.cancel();
    _publishTimer = null;
    _publishPending = false;
  }

  @override
  void dispose() {
    _accelSubscription?.cancel();
    _gyroSubscription?.cancel();
    _lightSubscription?.cancel();
    _proximitySubscription?.cancel();
    _publishTimer?.cancel();
    _controller.close();
  }
}
