import 'dart:math';
import '../models/ambient_context.dart';
import '../models/automation_scene.dart';
import '../models/context_guard_result.dart';
import '../models/context_result.dart';
import '../models/pose_feature_snapshot.dart';
import '../models/sensor_snapshot.dart';
import '../models/vision_context_sample.dart';
import 'context_inference_engine.dart';
import 'voice_intent_provider.dart';

/// Deterministic on-device rule-based multimodal context engine.
/// Evaluates:
/// - Silicon IMU (Accelerometer & Gyroscope magnitude)
/// - Ambient light lux
/// - Proximity state
/// - BLE workstation beacon presence
/// - Camera observable posture (Seated, Standing, Moving, Resting)
/// - Vision features (Hand Gestures, Facial Expression Signals, Gaze/Head tilt)
/// - Local voice intent commands
///
/// Executes deterministically on-device without cloud dependence; the reported
/// latency is measured per evaluation rather than a guaranteed bound.
class RuleBasedContextEngine implements ContextInferenceEngine {
  @override
  String get engineName => 'SensAura On-Device Deterministic Rules';

  @override
  bool get isOnDevice => true;

  @override
  Future<ContextResult> inferContext(
    SensorSnapshot snapshot, {
    PoseFeatureSnapshot? posture,
    VisionContextSample? vision,
    VoiceIntentSnapshot? voice,
  }) async {
    final stopwatch = Stopwatch()..start();

    final accelMag = snapshot.accelMagnitude;
    final accelDeviation = (accelMag - 9.80665).abs();
    final gyroMag = snapshot.gyroMagnitude;
    final lux = snapshot.lightLux;
    final hasHomeBle = snapshot.homeBeaconDetected;
    final isProximityNear = snapshot.proximityNear;

    final userPosture = vision?.poseState ?? posture?.posture ?? ObservablePosture.unknown;
    final gesture = vision?.gesture ?? HandGesture.none;
    final expression = vision?.expressionSignal ?? VisibleExpressionSignal.unknown;
    final postureStability = posture?.stabilityScore ?? vision?.poseConfidence ?? 0.5;
    final voiceIsFresh = voice != null &&
        DateTime.now().difference(voice.timestamp) <= const Duration(seconds: 15) &&
        voice.confidence >= 0.7;
    final userVoiceIntent =
        voiceIsFresh ? voice.intent : VoiceIntent.none;

    AmbientContextType inferredContext;
    double confidence;
    String reasoning;
    List<String> signals = [];
    AutomationScene scene;

    // -------------------------------------------------------------------------
    // 0. SIGNAL CONFLICT / UNCERTAIN CONTEXT EVALUATION
    // -------------------------------------------------------------------------
    // Conflict Case A: High IMU motion + bright light while connected to workstation beacon
    final bool isHighMotion = snapshot.motionLevel == MotionLevel.high || accelDeviation > 2.2 || gyroMag > 1.5;
    final bool isHighLight = lux >= 250.0;
    final bool hasSensorConflict = hasHomeBle && isHighMotion && isHighLight;

    // Conflict Case B: Camera indicates user is Resting/Sleeping, but accelerometer indicates high physical walking
    final bool hasVisionImuConflict =
        (userPosture == ObservablePosture.resting || expression == VisibleExpressionSignal.eyesClosed) && isHighMotion;

    // Conflict Case C: Camera indicates moving/walking, but phone IMU is completely stationary on desk
    final bool isPhoneStationary = accelDeviation < 0.25 && gyroMag < 0.15;
    final bool hasVisionMovingConflict =
        (userPosture == ObservablePosture.moving || (vision != null && vision.cameraMotion > 0.40)) && isPhoneStationary;

    if (hasSensorConflict || hasVisionImuConflict || hasVisionMovingConflict) {
      inferredContext = AmbientContextType.uncertain;
      confidence = 0.50; // Below actionable threshold (0.60) to guarantee Context Guard blocks it
      reasoning = hasVisionMovingConflict
          ? 'Vision and sensor signals disagree. Environment preserved.'
          : (hasVisionImuConflict
              ? 'Conflicting signals: Camera detected resting posture while IMU measured dynamic transit movement.'
              : 'Conflicting signals: High physical motion and bright light detected while connected to workstation beacon.');
      signals = [
        'Motion: ${accelMag.toStringAsFixed(1)} m/s² (dev: ${accelDeviation.toStringAsFixed(2)})',
        'Angular rate: ${gyroMag.toStringAsFixed(2)} rad/s',
        'Light: ${lux.toStringAsFixed(0)} lux',
        if (hasHomeBle) 'Beacon: Connected (${snapshot.homeBeaconRssi} dBm)',
        'Posture: ${userPosture.displayName} [CONFLICT]',
        if (vision != null) 'Expression: ${expression.displayName}',
        'CONFLICT: Automation paused for safety',
      ];
      scene = AutomationScene.neutral;
    }
    // -------------------------------------------------------------------------
    // 1. EXPLICIT GESTURE INTENT OVERRIDE (Explicit hand gesture has top priority)
    // -------------------------------------------------------------------------
    else if (gesture == HandGesture.victory) {
      inferredContext = AmbientContextType.focus;
      confidence = 0.98;
      reasoning = 'Explicit Victory gesture (✌️) commanded Deep Focus workspace profile.';
      signals = [
        'Gesture Intent: Victory / V-Sign (✌️) [EXPLICIT INTENT]',
        'Vision Confidence: ${((vision?.visionConfidence ?? 0.9) * 100).toStringAsFixed(0)}%',
        'Desk telemetry aligned (${lux.toStringAsFixed(0)} lux)',
        'Posture: ${userPosture.displayName}',
      ];
      scene = AutomationScene.deepFocus;
    } else if (gesture == HandGesture.closedFist) {
      inferredContext = AmbientContextType.relaxation;
      confidence = 0.96;
      reasoning = 'Explicit Closed Fist gesture (✊) commanded Quiet / Rest profile.';
      signals = [
        'Gesture Intent: Closed Fist (✊) [EXPLICIT INTENT]',
        'Rest environment calibrated',
      ];
      scene = AutomationScene.relaxation;
    }
    // -------------------------------------------------------------------------
    // 2. VOICE INTENT OVERRIDE BOOST (Explicit local intent has highest priority)
    // -------------------------------------------------------------------------
    else if (userVoiceIntent == VoiceIntent.focus) {
      inferredContext = AmbientContextType.focus;
      confidence = 0.98;
      reasoning = 'Local voice intent ("${voice?.rawPhrase}") confirmed Deep Focus workspace profile.';
      signals = [
        'Voice Intent: "${voice?.rawPhrase}" (Local KWS)',
        'Desk telemetry aligned (${lux.toStringAsFixed(0)} lux)',
        'Posture: ${userPosture.displayName}',
      ];
      scene = AutomationScene.deepFocus;
    } else if (userVoiceIntent == VoiceIntent.breakTime) {
      inferredContext = AmbientContextType.breakTime;
      confidence = 0.96;
      reasoning = 'Local voice intent ("${voice?.rawPhrase}") triggered 5-min workspace break timer.';
      signals = [
        'Voice Intent: "${voice?.rawPhrase}"',
        'Workstation session paused',
      ];
      scene = AutomationScene.breakTime;
    } else if (userVoiceIntent == VoiceIntent.rest) {
      inferredContext = AmbientContextType.relaxation;
      confidence = 0.96;
      reasoning = 'Local voice intent ("${voice?.rawPhrase}") activated workspace relaxation profile.';
      signals = [
        'Voice Intent: "${voice?.rawPhrase}"',
        'Rest environment calibrated',
      ];
      scene = AutomationScene.relaxation;
    } else if (userVoiceIntent == VoiceIntent.leaving) {
      inferredContext = AmbientContextType.leaving;
      confidence = 0.98;
      reasoning = 'Local voice intent ("${voice?.rawPhrase}") initiated departure workstation security lock.';
      signals = [
        'Voice Intent: "${voice?.rawPhrase}"',
        'Workstation lock armed',
      ];
      scene = AutomationScene.energySaving;
    } else if (userVoiceIntent == VoiceIntent.arriving) {
      inferredContext = AmbientContextType.arriving;
      confidence = 0.98;
      reasoning = 'Local voice intent ("${voice?.rawPhrase}") restored personal workspace profile.';
      signals = [
        'Voice Intent: "${voice?.rawPhrase}"',
        'Workspace state restored',
      ];
      scene = AutomationScene.welcomeHome;
    }
    // -------------------------------------------------------------------------
    // 2. NIGHT SLEEP EVALUATION
    // -------------------------------------------------------------------------
    else if (lux < 3.0 && accelDeviation < 0.5 && isProximityNear && hasHomeBle) {
      inferredContext = AmbientContextType.sleep;
      confidence = 0.98;
      reasoning = 'Pitch darkness + stationary phone + proximity sensor engaged indicates sleep sanctuary.';
      signals = [
        'Darkness: ${lux.toStringAsFixed(1)} lux',
        'Stationary: ${accelMag.toStringAsFixed(2)} m/s²',
        'Proximity sensor covered (face-down/docked)',
        'Workstation beacon connected',
      ];
      scene = AutomationScene.sleepSanctuary;
    }
    // -------------------------------------------------------------------------
    // 3. LEAVING / DEPARTURE EVALUATION
    // -------------------------------------------------------------------------
    else if (!hasHomeBle && (accelDeviation > 1.8 || snapshot.motionLevel == MotionLevel.high)) {
      inferredContext = AmbientContextType.leaving;
      confidence = 0.96;
      reasoning = 'High motion + Workstation BLE beacon signal drop confirms departure.';
      signals = [
        'High motion detected (${accelMag.toStringAsFixed(1)} m/s²)',
        'Workstation BLE connection lost',
        'Ambient transition to exterior',
      ];
      scene = AutomationScene.energySaving;
    }
    // -------------------------------------------------------------------------
    // 4. REST / RELAXATION EVALUATION
    // -------------------------------------------------------------------------
    else if (lux <= 45.0 && accelDeviation < 1.4 && (userPosture == ObservablePosture.resting || userPosture == ObservablePosture.seated || userPosture == ObservablePosture.unknown)) {
      inferredContext = AmbientContextType.relaxation;
      confidence = 0.94;
      reasoning = 'Dim ambient illumination + low movement + workstation presence indicates relaxation / rest state.';
      signals = [
        'Low movement: ${accelMag.toStringAsFixed(2)} m/s²',
        'Dim ambient light: ${lux.toStringAsFixed(0)} lux (< 45 lux)',
        if (hasHomeBle) 'Workstation beacon detected (${snapshot.homeBeaconRssi} dBm)',
        if (posture != null) 'Posture: ${userPosture.displayName}',
      ];
      scene = AutomationScene.relaxation;
    }
    // -------------------------------------------------------------------------
    // 5. ARRIVAL EVALUATION
    // -------------------------------------------------------------------------
    else if (hasHomeBle && snapshot.homeBeaconRssi > -68 && accelDeviation >= 0.6 && accelDeviation <= 2.5) {
      inferredContext = AmbientContextType.arriving;
      confidence = 0.92;
      reasoning = 'Workstation beacon re-acquired with strong RSSI and settling motion indicates arrival.';
      signals = [
        'Workstation beacon acquired (${snapshot.homeBeaconRssi} dBm)',
        'Transit motion settling (${accelDeviation.toStringAsFixed(2)} m/s² dev)',
        'Indoor workspace light detected (${lux.toStringAsFixed(0)} lux)',
      ];
      scene = AutomationScene.welcomeHome;
    }
    // -------------------------------------------------------------------------
    // 6. ADAPTIVE PERSONAL WORKSPACE: DEEP FOCUS EVALUATION
    // -------------------------------------------------------------------------
    else if (accelDeviation < 0.45 && gyroMag < 0.25 && lux >= 80.0 && lux <= 800.0 && !isProximityNear) {
      final bool isSeated = userPosture == ObservablePosture.seated || userPosture == ObservablePosture.stationary;
      inferredContext = AmbientContextType.focus;
      confidence = (isSeated || hasHomeBle || expression == VisibleExpressionSignal.engaged) ? 0.96 : 0.91;
      reasoning = isSeated
          ? 'Seated at workstation + stable desk IMU + focused illumination indicates active Deep Focus.'
          : 'Static desk orientation + bright workspace illumination indicates active Deep Focus.';
      signals = [
        'Stable desk IMU (${accelDeviation.toStringAsFixed(2)} m/s² dev, ${gyroMag.toStringAsFixed(2)} rad/s)',
        'Focused workspace lighting (${lux.toStringAsFixed(0)} lux)',
        if (hasHomeBle) 'Workstation beacon connected (${snapshot.homeBeaconRssi} dBm)',
        if (posture != null || vision != null) 'Posture: ${userPosture.displayName} (${(postureStability * 100).toStringAsFixed(0)}% stability)',
        if (vision != null) 'Vision Expression: ${vision.expressionSignal.displayName}',
      ];
      scene = AutomationScene.deepFocus;
    }
    // -------------------------------------------------------------------------
    // 7. NEUTRAL / DEFAULT BASELINE
    // -------------------------------------------------------------------------
    else {
      inferredContext = AmbientContextType.neutral;
      confidence = 0.84;
      reasoning = 'Balanced ambient conditions and standard daily mobile workspace activity.';
      signals = [
        'Moderate light: ${lux.toStringAsFixed(0)} lux',
        'Device motion: ${snapshot.motionLevel.displayName}',
        'BLE devices: ${snapshot.bleDevicesCount} visible',
        if (posture != null) 'Posture: ${userPosture.displayName}',
      ];
      scene = AutomationScene.neutral;
    }

    stopwatch.stop();
    final elapsedMs = max(0.4, stopwatch.elapsedMicroseconds / 1000.0);

    final bool hasConflict = hasSensorConflict ||
        hasVisionImuConflict ||
        hasVisionMovingConflict;

    final guardResult = hasConflict
        ? const ContextGuardResult(
            decision: ContextGuardDecision.noAction,
            summary: 'Signals conflict: Automation paused',
            explanation:
                'Vision and sensor signals disagree. Environment preserved.',
            checks: [
              ContextGuardCheck(
                label: 'Signal consistency',
                passed: false,
                detail: 'Vision and physical sensor conflict',
              ),
            ],
            isSafeToApply: false,
          )
        : ContextGuardResult.defaultSafe;

    return ContextResult(
      context: inferredContext,
      confidence: confidence,
      reasoning: reasoning,
      detectedSignals: signals,
      recommendedScene: scene,
      inferenceLatencyMs: elapsedMs,
      evaluatedAt: DateTime.now(),
      guardResult: guardResult,
    );
  }
}
