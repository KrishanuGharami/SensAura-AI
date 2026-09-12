import 'dart:async';
import 'dart:math';
import '../core/constants/mock_scenarios.dart';
import '../models/sensor_snapshot.dart';
import 'sensor_provider.dart';

/// Deterministic simulated sensor provider.
/// Generates realistic live micro-jitter and smooth interpolated transitions
/// between smart living contexts.
class MockSensorProvider implements SensorProvider {
  final StreamController<SensorSnapshot> _controller =
      StreamController<SensorSnapshot>.broadcast();
  Timer? _jitterTimer;
  Timer? _transitionTimer;

  SensorSnapshot _current = SensorSnapshot.neutral();
  bool _isStreaming = false;
  final Random _random = Random();

  @override
  Stream<SensorSnapshot> get sensorStream => _controller.stream;

  @override
  SensorSnapshot get currentSnapshot => _current;

  @override
  bool get isStreaming => _isStreaming;

  @override
  String get providerName => 'SensAura Telemetry Sim v2.0';

  @override
  bool get isHardware => false;

  @override
  Future<void> start() async {
    if (_isStreaming) return;
    _isStreaming = true;
    _controller.add(_current);
    _startJitter();
  }

  @override
  Future<void> stop() async {
    _isStreaming = false;
    _jitterTimer?.cancel();
    _transitionTimer?.cancel();
  }

  void _startJitter() {
    _jitterTimer?.cancel();
    _jitterTimer = Timer.periodic(const Duration(milliseconds: 750), (timer) {
      if (!_isStreaming || (_transitionTimer?.isActive ?? false)) return;

      // Realistic physical sensor micro-jitter
      final jitterAccelX = _current.accelX + (_random.nextDouble() - 0.5) * 0.04;
      final jitterAccelY = _current.accelY + (_random.nextDouble() - 0.5) * 0.04;
      final jitterAccelZ = _current.accelZ + (_random.nextDouble() - 0.5) * 0.04;
      final jitterLux = max(0.0, _current.lightLux + (_random.nextDouble() - 0.5) * 1.5);

      _current = _current.copyWith(
        accelX: jitterAccelX,
        accelY: jitterAccelY,
        accelZ: jitterAccelZ,
        lightLux: jitterLux,
        timestamp: DateTime.now(),
      );
      _controller.add(_current);
    });
  }

  /// Injects a deterministic scenario with smooth interpolation
  void injectScenario(MockScenario scenario, {bool smoothTransition = true}) {
    _transitionTimer?.cancel();

    if (!smoothTransition) {
      _current = scenario.snapshot.copyWith(timestamp: DateTime.now());
      _controller.add(_current);
      return;
    }

    // Smooth multi-step interpolation (8 steps over 1.2 seconds)
    const int totalSteps = 8;
    int step = 0;
    final startSnap = _current;
    final targetSnap = scenario.snapshot;

    _transitionTimer = Timer.periodic(const Duration(milliseconds: 140), (timer) {
      step++;
      final t = step / totalSteps;

      final curX = startSnap.accelX + (targetSnap.accelX - startSnap.accelX) * t;
      final curY = startSnap.accelY + (targetSnap.accelY - startSnap.accelY) * t;
      final curZ = startSnap.accelZ + (targetSnap.accelZ - startSnap.accelZ) * t;
      final curLux = startSnap.lightLux + (targetSnap.lightLux - startSnap.lightLux) * t;

      _current = SensorSnapshot(
        accelX: curX,
        accelY: curY,
        accelZ: curZ,
        lightLux: max(0.0, curLux),
        proximityNear: t > 0.5 ? targetSnap.proximityNear : startSnap.proximityNear,
        bleDevicesCount: t > 0.5 ? targetSnap.bleDevicesCount : startSnap.bleDevicesCount,
        homeBeaconDetected: t > 0.5 ? targetSnap.homeBeaconDetected : startSnap.homeBeaconDetected,
        homeBeaconRssi: (startSnap.homeBeaconRssi + (targetSnap.homeBeaconRssi - startSnap.homeBeaconRssi) * t).round(),
        timestamp: DateTime.now(),
        isSimulated: true,
        sourceLabel: 'SIMULATED / LOCAL',
      );

      _controller.add(_current);

      if (step >= totalSteps) {
        timer.cancel();
      }
    });
  }

  /// Manually set specific sensor properties
  void setManualValues({
    double? lightLux,
    double? accelMagnitude,
    bool? proximityNear,
    bool? homeBeaconDetected,
    int? bleCount,
  }) {
    _transitionTimer?.cancel();
    double newX = _current.accelX;
    double newY = _current.accelY;
    double newZ = _current.accelZ;

    if (accelMagnitude != null) {
      newX = accelMagnitude * 0.2;
      newY = accelMagnitude * 0.2;
      newZ = sqrt(max(0.0, accelMagnitude * accelMagnitude - newX * newX - newY * newY));
    }

    _current = _current.copyWith(
      lightLux: lightLux,
      accelX: newX,
      accelY: newY,
      accelZ: newZ,
      proximityNear: proximityNear,
      homeBeaconDetected: homeBeaconDetected,
      bleDevicesCount: bleCount,
      timestamp: DateTime.now(),
    );
    _controller.add(_current);
  }

  @override
  void dispose() {
    _jitterTimer?.cancel();
    _transitionTimer?.cancel();
    _controller.close();
  }
}
