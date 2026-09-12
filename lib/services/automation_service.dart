import 'dart:async';
import 'package:flutter/foundation.dart';
import '../core/constants/app_constants.dart';
import '../core/constants/mock_scenarios.dart';
import '../models/ambient_context.dart';
import '../models/automation_event.dart';
import '../models/automation_scene.dart';
import '../models/context_guard_result.dart';
import '../models/context_result.dart';
import '../models/sensor_snapshot.dart';
import '../models/smart_device.dart';
import 'ble_provider.dart';
import 'context_guard.dart';
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
/// -> SensAura Context Guard safety evaluation -> smart device actuators -> local persistence.
class AutomationService extends ChangeNotifier {
  static final AutomationService _instance = AutomationService._internal();
  factory AutomationService() => _instance;

  final LocalStorageService _storage = LocalStorageService();
  final ContextGuard _contextGuard = const ContextGuard();

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

  // Robustness: Temporal stabilization & Safety timers
  final List<AmbientContextType> _contextHistory = [];
  DateTime? _lastSceneAppliedTime;
  DateTime? _manualOverrideUntil;

  bool _isHardwareMode = false;
  bool _isApplyingScene = false;
  bool _isInitialized = false;

  // Getters
  SensorSnapshot get latestSnapshot => _latestSnapshot;
  ContextResult get latestContextResult => _latestContextResult;
  ContextGuardResult get latestGuardResult => _latestContextResult.guardResult;
  List<SmartDevice> get devices => List.unmodifiable(_devices);
  List<AutomationEvent> get history => List.unmodifiable(_history);
  bool get isHardwareMode => _isHardwareMode;
  bool get isApplyingScene => _isApplyingScene;
  bool get isInitialized => _isInitialized;
  SensorProvider get currentSensorProvider => _sensorProvider;
  BleProvider get currentBleProvider => _bleProvider;
  ContextInferenceEngine get currentEngine => _inferenceEngine;

  // Cooldown status
  bool get isCooldownActive {
    if (_lastSceneAppliedTime == null) return false;
    return DateTime.now().difference(_lastSceneAppliedTime!).inSeconds <
        AppConstants.cooldownDurationSeconds;
  }

  Duration? get cooldownRemaining {
    if (_lastSceneAppliedTime == null) return null;
    final elapsed = DateTime.now().difference(_lastSceneAppliedTime!);
    final remaining =
        const Duration(seconds: AppConstants.cooldownDurationSeconds) - elapsed;
    return remaining.isNegative ? Duration.zero : remaining;
  }

  // Manual override status
  bool get isManualOverrideActive {
    if (_manualOverrideUntil == null) return false;
    return DateTime.now().isBefore(_manualOverrideUntil!);
  }

  Duration? get manualOverrideRemaining {
    if (_manualOverrideUntil == null) return null;
    final remaining = _manualOverrideUntil!.difference(DateTime.now());
    return remaining.isNegative ? Duration.zero : remaining;
  }

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

  /// Runs the on-device inference engine and evaluates through SensAura Context Guard
  Future<void> _evaluateContext(SensorSnapshot snapshot) async {
    final rawResult = await _inferenceEngine.inferContext(snapshot);

    // 1. Hysteresis / Temporal Stabilization
    _contextHistory.add(rawResult.context);
    if (_contextHistory.length > AppConstants.hysteresisWindowSize) {
      _contextHistory.removeAt(0);
    }

    AmbientContextType stabilizedContext = _latestContextResult.context;
    if (_contextHistory.length >= AppConstants.hysteresisWindowSize) {
      final counts = <AmbientContextType, int>{};
      for (final c in _contextHistory) {
        counts[c] = (counts[c] ?? 0) + 1;
      }
      for (final entry in counts.entries) {
        if (entry.value >= (AppConstants.hysteresisWindowSize / 2).ceil()) {
          stabilizedContext = entry.key;
          break;
        }
      }
    } else {
      stabilizedContext = rawResult.context;
    }

    // 2. Presence & Conflict evaluation
    final bool isPresenceConfirmed =
        snapshot.homeBeaconDetected || _bleProvider.isHomeBeaconPresent;
    final bool hasConflict = stabilizedContext == AmbientContextType.uncertain ||
        (snapshot.homeBeaconDetected &&
            snapshot.motionLevel == MotionLevel.high &&
            snapshot.lightLux > 250.0);

    // 3. SensAura Context Guard Evaluation
    final guardResult = _contextGuard.evaluate(
      inferredContext: stabilizedContext,
      confidence: rawResult.confidence,
      isPresenceConfirmed: isPresenceConfirmed,
      hasConflictingSignals: hasConflict,
      isManualOverrideActive: isManualOverrideActive,
      isCooldownActive: isCooldownActive,
      cooldownRemaining: cooldownRemaining,
      overrideRemaining: manualOverrideRemaining,
    );

    _latestContextResult = rawResult.copyWith(
      context: stabilizedContext,
      guardResult: guardResult,
    );
  }

  /// DEMO MODE TRIGGER: Injects a deterministic sensor scenario.
  /// Pre-primes stabilization buffer so the demo transitions immediately and predictably.
  void injectScenario(MockScenario scenario) {
    _contextHistory.clear();
    _contextHistory.addAll(
      List.filled(AppConstants.hysteresisWindowSize, scenario.targetContext),
    );

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
    _lastSceneAppliedTime = DateTime.now();
    _manualOverrideUntil = null; // Reconcile device state with approved scene

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

    // Re-evaluate context guard with active cooldown
    await _evaluateContext(_latestSnapshot);

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

  /// Manual device control override: Sets temporary override lock to respect user preference
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

    // Activate manual override lease
    _manualOverrideUntil = DateTime.now().add(
      const Duration(seconds: AppConstants.manualOverrideDurationSeconds),
    );

    _syncGuardResult();
    notifyListeners();
  }

  /// Release manual override lock immediately
  void clearManualOverride() {
    _manualOverrideUntil = null;
    _syncGuardResult();
    notifyListeners();
  }

  /// Reset automation cooldown immediately (for tests and quick demos)
  void resetCooldown() {
    _lastSceneAppliedTime = null;
    _syncGuardResult();
    notifyListeners();
  }

  /// Synchronously re-evaluates the Context Guard using current state
  void _syncGuardResult() {
    final bool isPresenceConfirmed =
        _latestSnapshot.homeBeaconDetected || _bleProvider.isHomeBeaconPresent;
    final bool hasConflict = _latestContextResult.context ==
            AmbientContextType.uncertain ||
        (_latestSnapshot.homeBeaconDetected &&
            _latestSnapshot.motionLevel == MotionLevel.high &&
            _latestSnapshot.lightLux > 250.0);

    final guardResult = _contextGuard.evaluate(
      inferredContext: _latestContextResult.context,
      confidence: _latestContextResult.confidence,
      isPresenceConfirmed: isPresenceConfirmed,
      hasConflictingSignals: hasConflict,
      isManualOverrideActive: isManualOverrideActive,
      isCooldownActive: isCooldownActive,
      cooldownRemaining: cooldownRemaining,
      overrideRemaining: manualOverrideRemaining,
    );

    _latestContextResult = _latestContextResult.copyWith(guardResult: guardResult);
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
