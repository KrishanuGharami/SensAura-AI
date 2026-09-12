import 'dart:async';
import 'package:flutter/foundation.dart';
import '../core/constants/mock_scenarios.dart';
import '../models/automation_event.dart';
import '../models/automation_scene.dart';
import '../models/context_result.dart';
import '../models/sensor_snapshot.dart';
import '../models/smart_device.dart';
import 'ble_provider.dart';
import 'context_inference_engine.dart';
import 'local_storage_service.dart';
import 'mock_ble_provider.dart';
import 'mock_sensor_provider.dart';
import 'real_ble_provider.dart';
import 'real_sensor_provider.dart';
import 'rule_based_context_engine.dart';
import 'sensor_provider.dart';

/// Central state manager and orchestrator for SensAura AI.
/// Connects physical/simulated sensor streams -> on-device inference engine
/// -> contextual automation recommendation -> smart device actuators -> local persistence.
class AutomationService extends ChangeNotifier {
  static final AutomationService _instance = AutomationService._internal();
  factory AutomationService() => _instance;

  final LocalStorageService _storage = LocalStorageService();

  late SensorProvider _sensorProvider;
  late BleProvider _bleProvider;
  late ContextInferenceEngine _inferenceEngine;

  final MockSensorProvider _mockSensors = MockSensorProvider();
  final RealSensorProvider _realSensors = RealSensorProvider();
  final MockBleProvider _mockBle = MockBleProvider();
  final RealBleProvider _realBle = RealBleProvider();

  AutomationService._internal() {
    _sensorProvider = _mockSensors;
    _bleProvider = _mockBle;
    _inferenceEngine = RuleBasedContextEngine();
  }

  StreamSubscription<SensorSnapshot>? _sensorSubscription;

  SensorSnapshot _latestSnapshot = SensorSnapshot.neutral();
  ContextResult _latestContextResult = ContextResult.initial();
  List<SmartDevice> _devices = SmartDevice.initialDevices();
  List<AutomationEvent> _history = [];

  bool _isHardwareMode = false;
  bool _isApplyingScene = false;
  bool _isInitialized = false;

  // Getters
  SensorSnapshot get latestSnapshot => _latestSnapshot;
  ContextResult get latestContextResult => _latestContextResult;
  List<SmartDevice> get devices => List.unmodifiable(_devices);
  List<AutomationEvent> get history => List.unmodifiable(_history);
  bool get isHardwareMode => _isHardwareMode;
  bool get isApplyingScene => _isApplyingScene;
  bool get isInitialized => _isInitialized;
  SensorProvider get currentSensorProvider => _sensorProvider;
  BleProvider get currentBleProvider => _bleProvider;
  ContextInferenceEngine get currentEngine => _inferenceEngine;

  /// Initialize SensAura AI services
  Future<void> init() async {
    if (_isInitialized) return;

    await _storage.init();
    _history = _storage.getHistory();

    _inferenceEngine = RuleBasedContextEngine();
    _sensorProvider = _mockSensors;
    _bleProvider = _mockBle;

    await _sensorProvider.start();
    await _bleProvider.startScan();

    _sensorSubscription = _sensorProvider.sensorStream.listen(_onNewSensorSnapshot);

    // Initial evaluation
    await _evaluateContext(_latestSnapshot);

    _isInitialized = true;
    notifyListeners();
  }

  /// Internal handler called whenever a real or simulated sensor snapshot arrives
  Future<void> _onNewSensorSnapshot(SensorSnapshot snapshot) async {
    _latestSnapshot = snapshot;
    await _evaluateContext(snapshot);
    notifyListeners();
  }

  /// Runs the on-device inference engine against the sensor snapshot
  Future<void> _evaluateContext(SensorSnapshot snapshot) async {
    final result = await _inferenceEngine.inferContext(snapshot);
    _latestContextResult = result;
  }

  /// DEMO MODE TRIGGER: Injects a deterministic sensor scenario.
  /// Modifies actual sensor values, which flow through the real pipeline.
  void injectScenario(MockScenario scenario) {
    if (!_isHardwareMode) {
      _mockSensors.injectScenario(scenario, smoothTransition: true);
      // Sync mock BLE beacon state
      _mockBle.setHomeBeaconPresence(
        scenario.snapshot.homeBeaconDetected,
        rssi: scenario.snapshot.homeBeaconRssi,
      );
    }
  }

  /// Applies recommended or selected scene to physical / virtual smart home devices
  Future<void> applyScene(AutomationScene scene, {bool manual = false}) async {
    _isApplyingScene = true;
    notifyListeners();

    // Staggered animated update of smart devices
    final updatedDevices = <SmartDevice>[];
    for (final device in _devices) {
      if (scene.targetStates.containsKey(device.id)) {
        final target = scene.targetStates[device.id] as Map<String, dynamic>;
        updatedDevices.add(
          device.copyWith(
            isOn: target['isOn'] as bool? ?? device.isOn,
            primaryValue: target['brightness'] as int? ??
                target['temperature'] as int? ??
                target['speed'] as int? ??
                target['volume'] as int? ??
                target['powerWatts'] as int? ??
                device.primaryValue,
            secondaryStatus: target['colorTemp'] as String? ??
                target['mode'] as String? ??
                target['track'] as String? ??
                device.secondaryStatus,
          ),
        );
      } else {
        updatedDevices.add(device);
      }
    }

    _devices = updatedDevices;

    // Record immutable audit event in offline storage
    final event = AutomationEvent(
      id: EventIdGenerator.next(),
      timestamp: DateTime.now(),
      contextName: '${_latestContextResult.context.displayName} detected',
      sceneName: '${scene.title} applied',
      reasoning: _latestContextResult.reasoning,
      sensorSummary:
          'Light: ${_latestSnapshot.lightLux.toStringAsFixed(0)} lux • Motion: ${_latestSnapshot.motionLevel.displayName} • BLE: ${_latestSnapshot.bleDevicesCount} devices',
      appliedByUser: manual,
    );

    await _storage.saveEvent(event);
    _history = _storage.getHistory();

    // Subtle delay for visual confirmation of scene application
    await Future.delayed(const Duration(milliseconds: 350));
    _isApplyingScene = false;
    notifyListeners();
  }

  /// Toggle between real hardware IMU/BLE and high-fidelity local simulation
  Future<void> toggleHardwareMode(bool enabled) async {
    if (_isHardwareMode == enabled) return;
    _isHardwareMode = enabled;

    await _sensorSubscription?.cancel();
    await _sensorProvider.stop();
    await _bleProvider.stopScan();

    if (_isHardwareMode) {
      _sensorProvider = _realSensors;
      _bleProvider = _realBle;
    } else {
      _sensorProvider = _mockSensors;
      _bleProvider = _mockBle;
    }

    await _sensorProvider.start();
    await _bleProvider.startScan();

    _sensorSubscription = _sensorProvider.sensorStream.listen(_onNewSensorSnapshot);
    notifyListeners();
  }

  /// Manual device control override
  void updateDevice(
    String deviceId, {
    bool? isOn,
    int? primaryValue,
    String? secondaryStatus,
  }) {
    _devices = _devices.map((device) {
      if (device.id == deviceId) {
        return device.copyWith(
          isOn: isOn ?? device.isOn,
          primaryValue: primaryValue ?? device.primaryValue,
          secondaryStatus: secondaryStatus ?? device.secondaryStatus,
        );
      }
      return device;
    }).toList();
    notifyListeners();
  }

  /// Clear all automation logs
  Future<void> clearHistory() async {
    await _storage.clearHistory();
    _history = [];
    notifyListeners();
  }

  @override
  void dispose() {
    _sensorSubscription?.cancel();
    _sensorProvider.dispose();
    _bleProvider.dispose();
    super.dispose();
  }
}
