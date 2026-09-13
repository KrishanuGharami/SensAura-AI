import 'dart:async';
import 'package:flutter/material.dart';
import '../core/constants/app_constants.dart';
import '../core/constants/mock_scenarios.dart';
import '../core/theme/app_colors.dart';
import '../models/actuator_command.dart';
import '../models/ambient_context.dart';
import '../models/automation_event.dart';
import '../models/automation_scene.dart';
import '../models/automation_timeline_entry.dart';
import '../models/context_guard_result.dart';
import '../models/context_result.dart';
import '../models/pose_feature_snapshot.dart';
import '../models/sensor_snapshot.dart';
import '../models/smart_device.dart';
import '../models/vision_context_sample.dart';
import 'ble_actuator_provider.dart';
import 'ble_provider.dart';
import 'camera_posture_provider.dart';
import 'context_guard.dart';
import 'context_inference_engine.dart';
import 'demo_environment_actuator.dart';
import 'local_explanation_engine.dart';
import 'local_storage_service.dart';
import 'mediapipe_vision_provider.dart';
import 'mock_ble_provider.dart';
import 'mock_sensor_provider.dart';
import 'real_ble_provider.dart';
import 'real_camera_provider.dart';
import 'real_sensor_provider.dart';
import 'rule_based_context_engine.dart';
import 'sensor_provider.dart';
import 'vision_provider.dart';
import 'vision_temporal_fusion_engine.dart';
import 'voice_intent_provider.dart';
import 'workstation_actuator_provider.dart';

/// Central state manager and orchestrator for SensAura AI.
/// Connects physical iQOO 15 hardware sensors, camera posture, voice intent
/// -> On-device multimodal context engine -> SensAura Context Guard safety evaluation
/// -> Workstation Node (Laptop Companion) & Demo Connected Environment -> Local Hive audit log.
class AutomationService extends ChangeNotifier {
  static final AutomationService _instance = AutomationService._internal();
  factory AutomationService() => _instance;

  final LocalStorageService _storage = LocalStorageService();
  final ContextGuard _contextGuard = const ContextGuard();
  final LocalExplanationEngine _explanationEngine =
      const LocalExplanationEngine();

  late SensorProvider _sensorProvider;
  late BleProvider _bleProvider;
  late ContextInferenceEngine _inferenceEngine;

  final MockSensorProvider _mockSensors = MockSensorProvider();
  final RealSensorProvider _realSensors = RealSensorProvider();
  final MockBleProvider _mockBle = MockBleProvider();
  final RealBleProvider _realBle = RealBleProvider();

  // Hardware extensions: Camera Posture, Voice Intent, Workstation Actuator, BLE Actuator
  final RealCameraPostureProvider _cameraPosture = RealCameraPostureProvider();
  final RealVoiceIntentProvider _voiceIntent = RealVoiceIntentProvider();
  final WorkstationActuatorProvider _workstationActuator =
      WorkstationActuatorProvider();
  final BleActuatorProvider _bleActuator = BleActuatorProvider();

  // Demo Connected Environment Actuator (deterministic offline simulator)
  final DemoEnvironmentActuator _demoActuator = DemoEnvironmentActuator();

  // Vision & Gesture subsystem (MediaPipe on-device pipeline)
  final RealCameraProvider _realCamera = RealCameraProvider();
  final MediaPipeVisionProvider _visionProvider = MediaPipeVisionProvider();
  final VisionTemporalFusionEngine _fusionEngine =
      VisionTemporalFusionEngine();

  AutomationService._internal() {
    // Default to LIVE HARDWARE mode for genuine phone-first evaluation
    _sensorProvider = _realSensors;
    _bleProvider = _realBle;
    _inferenceEngine = RuleBasedContextEngine();
  }

  StreamSubscription<SensorSnapshot>? _sensorSubscription;
  StreamSubscription<PoseFeatureSnapshot>? _postureSubscription;
  StreamSubscription<VoiceIntentSnapshot>? _voiceSubscription;
  StreamSubscription<VisionContextSample>? _visionSubscription;

  SensorSnapshot _latestSnapshot = SensorSnapshot.neutral();
  PoseFeatureSnapshot _latestPosture = PoseFeatureSnapshot.neutral();
  VoiceIntentSnapshot _latestVoice = VoiceIntentSnapshot.idle();
  VisionContextSample _latestVision = VisionContextSample.neutral();
  bool _isAutomationPausedByGesture = false;
  ContextResult _latestContextResult = ContextResult.initial();
  List<SmartDevice> _devices = SmartDevice.initialDevices();
  List<AutomationEvent> _history = [];
  final List<AutomationTimelineEntry> _timeline = [];
  String _latestExplanation = '';

  // Robustness: Temporal stabilization & Safety timers
  final List<AmbientContextType> _contextHistory = [];
  DateTime? _lastSceneAppliedTime;
  String? _lastAppliedSceneId;
  DateTime? _manualOverrideUntil;

  bool _isHardwareMode = true; // Default LIVE HARDWARE
  bool _isApplyingScene = false;
  bool _isInitialized = false;
  bool _isDisposed = false;
  bool _isSwitchingMode = false;
  int _evaluationGeneration = 0;

  // Getters
  SensorSnapshot get latestSnapshot => _latestSnapshot;
  PoseFeatureSnapshot get latestPosture => _latestPosture;
  VoiceIntentSnapshot get latestVoice => _latestVoice;
  ContextResult get latestContextResult => _latestContextResult;
  ContextGuardResult get latestGuardResult => _latestContextResult.guardResult;
  List<SmartDevice> get devices => List.unmodifiable(_devices);
  List<AutomationEvent> get history => List.unmodifiable(_history);
  List<AutomationTimelineEntry> get timeline => List.unmodifiable(_timeline);
  String get latestExplanation => _latestExplanation;
  bool get isHardwareMode => _isHardwareMode;
  bool get isApplyingScene => _isApplyingScene;
  bool get isInitialized => _isInitialized;
  String? get lastAppliedSceneId => _lastAppliedSceneId;

  SensorProvider get currentSensorProvider => _sensorProvider;
  BleProvider get currentBleProvider => _bleProvider;
  ContextInferenceEngine get currentEngine => _inferenceEngine;
  CameraPostureProvider get cameraPosture => _cameraPosture;
  VoiceIntentProvider get voiceIntent => _voiceIntent;
  WorkstationActuatorProvider get workstationActuator => _workstationActuator;
  BleActuatorProvider get bleActuator => _bleActuator;
  DemoEnvironmentActuator get demoActuator => _demoActuator;
  CameraProvider get cameraProvider => _realCamera;
  VisionProvider get visionProvider => _visionProvider;
  VisionTemporalFusionEngine get fusionEngine => _fusionEngine;
  VisionContextSample get latestVision => _latestVision;
  bool get isAutomationPausedByGesture => _isAutomationPausedByGesture;

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

  void _addTimelineEntry(
      String stage, String detail, Color color, IconData icon) {
    _timeline.add(AutomationTimelineEntry(
      timestamp: DateTime.now(),
      stage: stage,
      detail: detail,
      statusColor: color,
      icon: icon,
    ));
    if (_timeline.length > 30) {
      _timeline.removeAt(0);
    }
  }

  /// Initialize SensAura AI services
  Future<void> init() async {
    if (_isInitialized) return;

    await _storage.init();
    _history = _storage.getHistory();

    _inferenceEngine = RuleBasedContextEngine();
    _sensorProvider = _isHardwareMode ? _realSensors : _mockSensors;
    _bleProvider = _isHardwareMode ? _realBle : _mockBle;

    await _sensorProvider.start();
    await _bleProvider.startScan();
    await _cameraPosture.start();
    await _voiceIntent.startListening();
    await _visionProvider.start();
    _workstationActuator.startHeartbeat();

    // Initialize Physical iQOO Camera (Front lens default for smart living posture/gestures)
    final camOk = await _realCamera.initialize();
    if (camOk) {
      _visionProvider.bindCameraStream(_realCamera.imageStream);
      _addTimelineEntry(
        'Camera',
        'Physical ${_realCamera.activeLensName} camera active (~8 FPS AI vision stream)',
        AppColors.cyberCyan,
        Icons.videocam_rounded,
      );
    } else {
      _addTimelineEntry(
        'Camera',
        'Camera unavailable (${_realCamera.errorStatus ?? "hardware/denied"}) — running in sensor-only mode',
        AppColors.primaryAmber,
        Icons.videocam_off_rounded,
      );
    }

    // Connect Demo Environment Actuator
    await _demoActuator.connect();
    _devices = await _demoActuator.discoverDevices();

    _addTimelineEntry(
      'System',
      'SensAura AI Online (Demo Actuator Ready)',
      AppColors.cyberCyan,
      Icons.sensors_rounded,
    );

    _sensorSubscription =
        _sensorProvider.sensorStream.listen(_onNewSensorSnapshot);
    _postureSubscription = _cameraPosture.postureStream.listen((posture) {
      _latestPosture = posture;
      _evaluateContext(_latestSnapshot);
      notifyListeners();
    });
    _voiceSubscription = _voiceIntent.intentStream.listen((voice) {
      _latestVoice = voice;
      _evaluateContext(_latestSnapshot);
      notifyListeners();
    });
    _visionSubscription =
        _visionProvider.sampleStream.listen(_onNewVisionSample);

    // Initial evaluation
    await _evaluateContext(_latestSnapshot);

    _isInitialized = true;
    notifyListeners();
  }

  Future<void> _onNewSensorSnapshot(SensorSnapshot snapshot) async {
    if (_isDisposed) return;
    _latestSnapshot = snapshot;
    await _evaluateContext(snapshot);
    notifyListeners();
  }

  Future<void> _onNewVisionSample(VisionContextSample sample) async {
    if (_isDisposed) return;
    _latestVision = sample;

    // Update camera posture boundary
    _cameraPosture.updateFromVision(
      posture: sample.posture,
      confidence: sample.postureConfidence,
      isHardwareCamera: sample.isHardwareCamera,
      timestamp: sample.timestamp,
    );

    // ✋ Open Palm -> Pause automation immediately
    if (sample.gesture == HandGesture.openPalm && !_isAutomationPausedByGesture) {
      pauseAutomationByGesture();
      return;
    }

    // 👍 Thumb Up -> Confirm pending ASK_USER scene
    if (sample.gesture == HandGesture.thumbUp) {
      if (_latestContextResult.guardResult.decision ==
          ContextGuardDecision.askUser) {
        _addTimelineEntry(
          'Vision Gesture',
          '👍 Thumb Up: User confirmed pending scene via gesture',
          AppColors.emeraldGreen,
          Icons.thumb_up_alt_rounded,
        );
        await applyScene(_latestContextResult.recommendedScene, manual: true);
        return;
      }
    }

    // 👎 Thumb Down -> Reject pending scene
    if (sample.gesture == HandGesture.thumbDown) {
      if (_latestContextResult.guardResult.decision ==
          ContextGuardDecision.askUser) {
        _addTimelineEntry(
          'Vision Gesture',
          '👎 Thumb Down: User dismissed pending scene via gesture',
          AppColors.dangerRed,
          Icons.thumb_down_alt_rounded,
        );
        _addTimelineEntry(
          'Environment',
          'Environment preserved because user rejected scene with thumb down gesture.',
          AppColors.cyberCyan,
          Icons.lock_outline_rounded,
        );
        notifyListeners();
        return;
      }
    }

    // ✌️ Victory -> Trigger Focus mode shortcut
    if (sample.gesture == HandGesture.victory) {
      if (!_isAutomationPausedByGesture &&
          _latestContextResult.context != AmbientContextType.focus) {
        _addTimelineEntry(
          'Vision Gesture',
          '✌️ Victory Gesture: User activated Focus Mode',
          AppColors.cyberCyan,
          Icons.workspace_premium_rounded,
        );
      }
    }

    // ✊ Closed Fist -> Trigger Quiet / Rest shortcut
    if (sample.gesture == HandGesture.closedFist) {
      if (!_isAutomationPausedByGesture &&
          _latestContextResult.context != AmbientContextType.relaxation) {
        _addTimelineEntry(
          'Vision Gesture',
          '✊ Closed Fist: User activated Quiet / Rest Mode',
          AppColors.primaryAmber,
          Icons.nightlight_round,
        );
      }
    }

    await _evaluateContext(_latestSnapshot);
    notifyListeners();
  }

  Future<void> _evaluateContext(SensorSnapshot snapshot) async {
    final evaluationGeneration = ++_evaluationGeneration;
    final rawResult = await _inferenceEngine.inferContext(
      snapshot,
      posture: _latestPosture,
      voice: _latestVoice,
      vision: _latestVision,
    );
    if (evaluationGeneration != _evaluationGeneration) return;

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
    final bool isPresenceConfirmed = _workstationActuator.isConnected ||
        snapshot.homeBeaconDetected ||
        _bleProvider.isHomeBeaconPresent ||
        false;

    final bool hasConflict = stabilizedContext == AmbientContextType.uncertain ||
        (snapshot.homeBeaconDetected &&
            snapshot.motionLevel == MotionLevel.high &&
            snapshot.lightLux > 250.0) ||
        (snapshot.motionLevel == MotionLevel.low &&
            _latestVision.posture == ObservablePosture.moving);

    // 3. SensAura Context Guard Evaluation
    // Note: DemoEnvironmentActuator is available as the reliable offline fallback.
    final guardResult = _contextGuard.evaluate(
      inferredContext: stabilizedContext,
      confidence: rawResult.confidence,
      isPresenceConfirmed: isPresenceConfirmed,
      hasConflictingSignals: hasConflict,
      isManualOverrideActive: isManualOverrideActive,
      isCooldownActive: isCooldownActive,
      isActuatorAvailable: true,
      isSensorTelemetryFresh: _isTelemetryUsable(snapshot),
      cooldownRemaining: cooldownRemaining,
      overrideRemaining: manualOverrideRemaining,
      isAutomationPausedByGesture: _isAutomationPausedByGesture,
    );

    _latestContextResult = rawResult.copyWith(
      context: stabilizedContext,
      guardResult: guardResult,
    );

    _latestExplanation = _explanationEngine.explain(
      contextResult: _latestContextResult,
      sensorSnapshot: _latestSnapshot,
      postureSnapshot: _latestPosture,
    );
  }

  /// DEMO MODE TRIGGER: Injects a deterministic sensor scenario.
  void injectScenario(MockScenario scenario) {
    if (_isHardwareMode) {
      toggleHardwareMode(false);
    }

    _contextHistory.clear();
    _contextHistory.addAll(
      List.filled(AppConstants.hysteresisWindowSize, scenario.targetContext),
    );

    _mockSensors.injectScenario(scenario, smoothTransition: true);
    _mockBle.setHomeBeaconPresence(
      scenario.snapshot.homeBeaconDetected,
      rssi: scenario.snapshot.homeBeaconRssi,
    );
  }

  /// Applies recommended or selected scene to workstation and demo connected environment.
  /// Strictly adheres to Context Guard safety gate:
  /// - UNCERTAIN -> NO_ACTION -> All devices remain completely unchanged.
  /// - Cooldown / Manual Override / Conflicts -> Blocked.
  /// - Real-time command-ack-state pipeline with actual timestamps.
  Future<void> applyScene(AutomationScene scene, {bool manual = false}) async {
    if (_isApplyingScene) return;

    // STEP 11: When Context Guard or inference says UNCERTAIN / conflicting signals,
    // the entire environment must remain unchanged.
    if (_latestContextResult.context == AmbientContextType.uncertain ||
        _latestContextResult.guardResult.hasConflictingSignals) {
      _addTimelineEntry(
        'Context Guard',
        'NO_ACTION (Conflicting signals detected)',
        AppColors.dangerRed,
        Icons.shield_outlined,
      );
      _addTimelineEntry(
        'Environment',
        'Environment preserved because SensAura detected conflicting signals.',
        AppColors.cyberCyan,
        Icons.lock_outline_rounded,
      );
      notifyListeners();
      return;
    }

    // Automatic execution strictly requires autoSafe
    if (!manual &&
        _latestContextResult.guardResult.decision !=
            ContextGuardDecision.autoSafe) {
      _addTimelineEntry(
        'Context Guard',
        '${_latestContextResult.guardResult.decision.userBadge}: Auto-apply blocked',
        AppColors.primaryAmber,
        Icons.shield_outlined,
      );
      notifyListeners();
      return;
    }

    // Context Guard: Block if automation is paused by gesture
    if (!manual && _isAutomationPausedByGesture) {
      _addTimelineEntry(
        'Context Guard',
        'Automation paused by user gesture (✋ Open Palm)',
        AppColors.primaryAmber,
        Icons.pan_tool_rounded,
      );
      notifyListeners();
      return;
    }

    // Check manual override lease
    if (!manual && isManualOverrideActive) {
      _addTimelineEntry(
        'Context Guard',
        'MANUAL OVERRIDE ACTIVE: Auto-apply blocked',
        AppColors.primaryAmber,
        Icons.lock_clock_rounded,
      );
      notifyListeners();
      return;
    }

    // Check cooldown
    if (!manual && isCooldownActive) {
      _addTimelineEntry(
        'Context Guard',
        'COOLDOWN ACTIVE: Auto-apply blocked',
        AppColors.primaryAmber,
        Icons.timer_outlined,
      );
      notifyListeners();
      return;
    }

    _isApplyingScene = true;

    // Timeline: Stage 1 - Context Detected
    _addTimelineEntry(
      'Context detected',
      '${_latestContextResult.context.displayName.toUpperCase()} ${_latestContextResult.confidencePercentage}',
      AppColors.cyberCyan,
      Icons.psychology_rounded,
    );

    // Timeline: Stage 2 - Context Guard Decision
    _addTimelineEntry(
      'Context Guard',
      _latestContextResult.guardResult.decision.userBadge,
      AppColors.emeraldGreen,
      Icons.verified_user_rounded,
    );

    // Timeline: Stage 3 - Scene Selected
    _addTimelineEntry(
      'Scene',
      scene.title.replaceAll(' Scene', '').toUpperCase(),
      AppColors.warmGold,
      scene.icon,
    );

    notifyListeners();

    // 1. Dispatch command to SensAura Node (Laptop Workstation) if available
    String workstationCommand = 'RESET';
    if (scene.id == 'scene_deep_focus') {
      workstationCommand = 'FOCUS';
    } else if (scene.id == 'scene_relaxation') {
      workstationCommand = 'REST';
    } else if (scene.id == 'scene_break_time') {
      workstationCommand = 'BREAK';
    } else if (scene.id == 'scene_energy_saving') {
      workstationCommand = 'LEAVING';
    } else if (scene.id == 'scene_welcome_home') {
      workstationCommand = 'ARRIVING';
    }

    if (_workstationActuator.isConnected) {
      _addTimelineEntry(
        'Workstation command',
        'SENT: $workstationCommand',
        AppColors.primaryAmber,
        Icons.send_rounded,
      );
      final acknowledged =
          await _workstationActuator.dispatchCommand(workstationCommand);
      if (acknowledged) {
        _addTimelineEntry(
          'Workstation',
          'ACKNOWLEDGED by SensAura Node',
          AppColors.emeraldGreen,
          Icons.check_circle_outline_rounded,
        );
      }
    }

    // 2. Dispatch commands to Demo Environment Actuator devices in real time
    for (final entry in scene.targetStates.entries) {
      final deviceId = entry.key;
      final targetState = entry.value as Map<String, dynamic>;

      // Match device name for clear timeline
      final currentDev = _devices.firstWhere(
        (d) => d.id == deviceId,
        orElse: () => SmartDevice(
          id: deviceId,
          name: deviceId,
          room: 'Living Room',
          type: DeviceType.light,
          isOn: false,
          primaryValue: 0,
          secondaryStatus: '',
        ),
      );

      _addTimelineEntry(
        '${currentDev.name} command',
        'SENT',
        AppColors.primaryAmber,
        Icons.send_rounded,
      );

      // Set device pending ack so UI reflects sending state
      _devices = _devices.map((d) {
        if (d.id == deviceId) {
          return d.copyWith(isPendingAck: true);
        }
        return d;
      }).toList();
      notifyListeners();

      // Dispatch command through ActuatorProvider
      final cmd = ActuatorCommand(
        commandId: 'cmd_${DateTime.now().microsecondsSinceEpoch}',
        timestamp: DateTime.now(),
        deviceId: deviceId,
        commandName: scene.title,
        requestedState: targetState,
      );

      final result = await _demoActuator.applyCommand(cmd);

      if (result.success) {
        _addTimelineEntry(
          currentDev.name,
          'ACKNOWLEDGED (${result.latencyMs}ms)',
          AppColors.emeraldGreen,
          Icons.check_circle_outline_rounded,
        );
      }
    }

    // Refresh devices from actuator state
    _devices = await _demoActuator.discoverDevices();

    // Timeline: Stage 6 - Environment Updated
    _addTimelineEntry(
      'Environment',
      'UPDATED',
      AppColors.cyberCyan,
      Icons.auto_awesome_rounded,
    );

    // Timeline: Stage 7 - Automation Completed
    _addTimelineEntry(
      'Automation',
      'COMPLETED',
      AppColors.emeraldGreen,
      Icons.task_alt_rounded,
    );

    _lastAppliedSceneId = scene.id;
    _lastSceneAppliedTime = DateTime.now();
    _manualOverrideUntil = null; // Reconcile device state with approved scene

    // 3. Record immutable audit event in offline storage
    final event = AutomationEvent(
      id: EventIdGenerator.next(),
      timestamp: DateTime.now(),
      contextName: '${_latestContextResult.context.displayName} detected',
      sceneName: '${scene.title} applied',
      reasoning: _latestContextResult.reasoning,
      sensorSummary:
          'Light: ${_latestSnapshot.lightLux.toStringAsFixed(0)} lux • Motion: ${_latestSnapshot.motionLevel.displayName} • Posture: ${_latestPosture.posture.displayName}',
      appliedByUser: manual,
    );

    await _storage.saveEvent(event);
    _history = _storage.getHistory();

    // Re-evaluate context guard with active cooldown
    await _evaluateContext(_latestSnapshot);

    _isApplyingScene = false;
    notifyListeners();
  }

  /// Toggle between real silicon hardware and developer diagnostic simulation
  Future<void> toggleHardwareMode(bool enabled) async {
    if (_isHardwareMode == enabled || _isSwitchingMode) return;
    _isSwitchingMode = true;
    try {
      _isHardwareMode = enabled;
      _evaluationGeneration++;

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

      _sensorSubscription =
          _sensorProvider.sensorStream.listen(_onNewSensorSnapshot);
      notifyListeners();
    } finally {
      _isSwitchingMode = false;
    }
  }

  /// Manual device control override
  /// Dispatches command through ActuatorProvider and activates the MANUAL OVERRIDE lease.
  Future<void> updateDevice(
    String deviceId, {
    bool? isOn,
    int? primaryValue,
    String? secondaryStatus,
  }) async {
    final dev = _devices.firstWhere(
      (d) => d.id == deviceId,
      orElse: () => SmartDevice(
        id: deviceId,
        name: deviceId,
        room: 'Living Room',
        type: DeviceType.light,
        isOn: false,
        primaryValue: 0,
        secondaryStatus: '',
      ),
    );

    // Set manual override lease immediately
    _manualOverrideUntil = DateTime.now().add(
      const Duration(seconds: AppConstants.manualOverrideDurationSeconds),
    );

    // Apply immediate local optimistic state
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

    _addTimelineEntry(
      'Manual Control',
      '${dev.name} adjusted by user',
      AppColors.primaryAmber,
      Icons.touch_app_rounded,
    );

    _addTimelineEntry(
      'Context Guard',
      'MANUAL OVERRIDE ACTIVE (${AppConstants.manualOverrideDurationSeconds}s lease)',
      AppColors.primaryAmber,
      Icons.lock_clock_rounded,
    );

    _syncGuardResult();
    notifyListeners();

    final req = <String, dynamic>{
      if (isOn != null) 'isOn': isOn,
      if (primaryValue != null) 'primaryValue': primaryValue,
      if (secondaryStatus != null) 'secondaryStatus': secondaryStatus,
    };

    final cmd = ActuatorCommand(
      commandId: 'cmd_manual_${DateTime.now().microsecondsSinceEpoch}',
      timestamp: DateTime.now(),
      deviceId: deviceId,
      commandName: 'MANUAL_OVERRIDE',
      requestedState: req,
    );

    await _demoActuator.applyCommand(cmd);
    _devices = await _demoActuator.discoverDevices();
    notifyListeners();
  }

  void clearManualOverride() {
    _manualOverrideUntil = null;
    _addTimelineEntry(
      'Context Guard',
      'Manual override lease released',
      AppColors.emeraldGreen,
      Icons.lock_open_rounded,
    );
    _syncGuardResult();
    notifyListeners();
  }

  void resetCooldown() {
    _lastSceneAppliedTime = null;
    _lastAppliedSceneId = null;
    _addTimelineEntry(
      'Context Guard',
      'Automation cooldown timer reset',
      AppColors.emeraldGreen,
      Icons.refresh_rounded,
    );
    _syncGuardResult();
    notifyListeners();
  }

  void pauseAutomationByGesture() {
    _isAutomationPausedByGesture = true;
    _addTimelineEntry(
      'Context Guard',
      'Automation paused by user gesture (✋ Open Palm)',
      AppColors.primaryAmber,
      Icons.pan_tool_rounded,
    );
    _syncGuardResult();
    notifyListeners();
  }

  void resumeAutomation() {
    _isAutomationPausedByGesture = false;
    _addTimelineEntry(
      'Context Guard',
      'Automation resumed by user',
      AppColors.emeraldGreen,
      Icons.play_arrow_rounded,
    );
    _syncGuardResult();
    notifyListeners();
  }

  void injectVisionSample(VisionContextSample sample) {
    _visionProvider.injectSample(sample);
  }

  void _syncGuardResult() {
    final bool isPresenceConfirmed = _workstationActuator.isConnected ||
        _latestSnapshot.homeBeaconDetected ||
        _bleProvider.isHomeBeaconPresent ||
        false;
    final bool hasConflict = _latestContextResult.context ==
            AmbientContextType.uncertain ||
        (_latestSnapshot.homeBeaconDetected &&
            _latestSnapshot.motionLevel == MotionLevel.high &&
            _latestSnapshot.lightLux > 250.0) ||
        (_latestSnapshot.motionLevel == MotionLevel.low &&
            _latestVision.posture == ObservablePosture.moving);

    final guardResult = _contextGuard.evaluate(
      inferredContext: _latestContextResult.context,
      confidence: _latestContextResult.confidence,
      isPresenceConfirmed: isPresenceConfirmed,
      hasConflictingSignals: hasConflict,
      isManualOverrideActive: isManualOverrideActive,
      isCooldownActive: isCooldownActive,
      isActuatorAvailable: true,
      isSensorTelemetryFresh: _isTelemetryUsable(_latestSnapshot),
      cooldownRemaining: cooldownRemaining,
      overrideRemaining: manualOverrideRemaining,
      isAutomationPausedByGesture: _isAutomationPausedByGesture,
    );

    _latestContextResult =
        _latestContextResult.copyWith(guardResult: guardResult);
    _latestExplanation = _explanationEngine.explain(
      contextResult: _latestContextResult,
      sensorSnapshot: _latestSnapshot,
      postureSnapshot: _latestPosture,
    );
  }

  Future<void> clearHistory() async {
    await _storage.clearHistory();
    _history = [];
    notifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _evaluationGeneration++;
    _sensorSubscription?.cancel();
    _postureSubscription?.cancel();
    _voiceSubscription?.cancel();
    _visionSubscription?.cancel();
    _realCamera.dispose();
    _sensorProvider.dispose();
    _bleProvider.dispose();
    _cameraPosture.dispose();
    _voiceIntent.dispose();
    _visionProvider.dispose();
    _workstationActuator.dispose();
    _bleActuator.dispose();
    _demoActuator.dispose();
    super.dispose();
  }

  bool _isTelemetryUsable(SensorSnapshot snapshot) {
    if (!_isHardwareMode) return !snapshot.isStale();
    // Accelerometer and light are required by the rule engine. Missing
    // optional sensors are surfaced in the UI but do not silently become data.
    return !snapshot.isStale() && snapshot.hasAccel && snapshot.hasLight;
  }
}
