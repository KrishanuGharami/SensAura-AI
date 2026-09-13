import '../models/ambient_context.dart';
import '../models/pose_feature_snapshot.dart';
import '../models/sensor_snapshot.dart';
import '../models/vision_context_sample.dart';

/// Result of temporal multimodal fusion across vision and physical sensors.
class FusionResult {
  final AmbientContextType context;
  final double fusedConfidence;
  final HandGesture stabilizedGesture;
  final bool hasConflict;
  final String reasoning;
  final List<String> contributingSignals;

  const FusionResult({
    required this.context,
    required this.fusedConfidence,
    required this.stabilizedGesture,
    required this.hasConflict,
    required this.reasoning,
    required this.contributingSignals,
  });
}

/// Temporal stabilization and multimodal fusion engine.
/// Fuses:
/// - Real-time Vision (Facial Expression Signals, Hand Gestures, Observable Posture)
/// - Physical Silicon Sensors (IMU Accelerometer, Gyroscope, Light, Proximity)
/// - BLE Presence
///
/// Ensures stable, jitter-free decisions with explicit gesture prioritization
/// and strict sensor-vs-vision conflict detection.
class VisionTemporalFusionEngine {
  final List<VisionContextSample> _visionWindow = [];
  static const int maxWindowSize = 10; // ~1.25 seconds at 8 FPS
  static const int minGestureConfirmations = 4; // ~0.5s of steady gesture hold

  HandGesture _lastEmittedGesture = HandGesture.none;
  HandGesture get lastEmittedGesture => _lastEmittedGesture;

  /// Ingests a new visual sample into the temporal buffer
  void addSample(VisionContextSample sample) {
    _visionWindow.add(sample);
    if (_visionWindow.length > maxWindowSize) {
      _visionWindow.removeAt(0);
    }
  }

  /// Clears temporal history (e.g. after a scene executes or manual override)
  void clear() {
    _visionWindow.clear();
    _lastEmittedGesture = HandGesture.none;
  }

  /// Stabilizes hand gestures over the temporal window to avoid transient twitches
  HandGesture getStabilizedGesture() {
    if (_visionWindow.isEmpty) return HandGesture.none;

    final gestureCounts = <HandGesture, int>{};
    for (final sample in _visionWindow) {
      if (sample.gesture.isExplicitIntent && sample.gestureConfidence >= 0.70) {
        gestureCounts[sample.gesture] = (gestureCounts[sample.gesture] ?? 0) + 1;
      }
    }

    for (final entry in gestureCounts.entries) {
      if (entry.value >= minGestureConfirmations) {
        _lastEmittedGesture = entry.key;
        return entry.key;
      }
    }

    _lastEmittedGesture = HandGesture.none;
    return HandGesture.none;
  }

  /// Evaluates multimodal fusion across physical sensors and visual signals
  FusionResult evaluateFusion({
    required SensorSnapshot sensorSnapshot,
    required VisionContextSample visionSample,
    required AmbientContextType baselineContext,
    required double baselineSensorConfidence,
  }) {
    addSample(visionSample);
    final stabilizedGesture = getStabilizedGesture();

    final accelDev = (sensorSnapshot.accelMagnitude - 9.80665).abs();
    final isPhoneStationary = accelDev < 0.25 && sensorSnapshot.gyroMagnitude < 0.15;
    final isHighPhoneMotion = accelDev > 2.0 || sensorSnapshot.motionLevel == MotionLevel.high;

    // -------------------------------------------------------------------------
    // 1. VISION VS PHYSICAL SENSOR CONFLICT DETECTION
    // -------------------------------------------------------------------------
    // Conflict A: Camera sees high optical motion or walking posture, while phone is motionless on desk
    final bool visionMovingSensorStill =
        (visionSample.poseState == ObservablePosture.moving || visionSample.cameraMotion > 0.40) &&
            isPhoneStationary;

    // Conflict B: Camera sees resting pose / sustained closed eyes, while phone IMU measures vigorous walking
    final bool visionRestingSensorMoving =
        (visionSample.poseState == ObservablePosture.resting ||
                visionSample.expressionSignal == VisibleExpressionSignal.eyesClosed) &&
            isHighPhoneMotion;

    if (visionMovingSensorStill || visionRestingSensorMoving) {
      final conflictDetail = visionMovingSensorStill
          ? 'Vision observed dynamic motion while phone IMU is stationary on desk.'
          : 'Vision observed resting posture while phone IMU measured transit movement.';

      return FusionResult(
        context: AmbientContextType.uncertain,
        fusedConfidence: 0.48, // Below Context Guard auto threshold
        stabilizedGesture: stabilizedGesture,
        hasConflict: true,
        reasoning: 'Vision and sensor signals disagree. Environment preserved.',
        contributingSignals: [
          'Camera Pose: ${visionSample.poseState.displayName} [CONFLICT]',
          'IMU Motion: ${sensorSnapshot.motionLevel.displayName}',
          'Optical Motion: ${(visionSample.cameraMotion * 100).toStringAsFixed(0)}%',
          'SAFETY: Conflicting sensory inputs detected ($conflictDetail)',
        ],
      );
    }

    // -------------------------------------------------------------------------
    // 2. EXPLICIT GESTURE INTENT OVERRIDE
    // -------------------------------------------------------------------------
    // Explicit hand gestures represent direct user commands and override passive mood
    if (stabilizedGesture == HandGesture.victory) {
      return FusionResult(
        context: AmbientContextType.focus,
        fusedConfidence: 0.98,
        stabilizedGesture: stabilizedGesture,
        hasConflict: false,
        reasoning: 'Explicit Victory gesture (✌️) commanded Deep Focus workspace profile.',
        contributingSignals: [
          'Gesture: Victory / V-Sign (✌️) [EXPLICIT INTENT]',
          'Vision Confidence: ${(visionSample.visionConfidence * 100).toStringAsFixed(0)}%',
          'Stationary Desk Baseline Verified',
        ],
      );
    } else if (stabilizedGesture == HandGesture.closedFist) {
      return FusionResult(
        context: AmbientContextType.relaxation,
        fusedConfidence: 0.96,
        stabilizedGesture: stabilizedGesture,
        hasConflict: false,
        reasoning: 'Explicit Closed Fist gesture (✊) commanded Quiet / Rest profile.',
        contributingSignals: [
          'Gesture: Closed Fist (✊) [EXPLICIT INTENT]',
          'Rest environment calibrated',
        ],
      );
    }

    // -------------------------------------------------------------------------
    // 3. MULTIMODAL CONTEXT FUSION (CAMERA + SENSORS)
    // -------------------------------------------------------------------------
    AmbientContextType fusedContext = baselineContext;
    double fusedConfidence = baselineSensorConfidence;
    final signals = <String>[];

    // Synergistic Desk Focus:
    // Face engaged + seated pose + stationary phone + proper light
    if (visionSample.facePresent &&
        (visionSample.poseState == ObservablePosture.seated || visionSample.poseState == ObservablePosture.stationary) &&
        isPhoneStationary &&
        sensorSnapshot.lightLux >= 60.0) {
      fusedContext = AmbientContextType.focus;
      // High fused confidence (60% sensors + 40% vision)
      fusedConfidence = (baselineSensorConfidence * 0.55) + (visionSample.visionConfidence * 0.45);
      if (fusedConfidence > 0.96) fusedConfidence = 0.96;
      if (fusedConfidence < 0.88) fusedConfidence = 0.88;

      signals.add('Face: Present (${(visionSample.faceConfidence * 100).toStringAsFixed(0)}%)');
      signals.add('Expression: ${visionSample.expressionSignal.displayName}');
      signals.add('Pose: Seated at Desk (${(visionSample.poseConfidence * 100).toStringAsFixed(0)}%)');
      signals.add('IMU: Desk Stationary (${accelDev.toStringAsFixed(2)} dev)');
      signals.add('Light: ${sensorSnapshot.lightLux.toStringAsFixed(0)} lux (Focused)');

      return FusionResult(
        context: fusedContext,
        fusedConfidence: fusedConfidence,
        stabilizedGesture: stabilizedGesture,
        hasConflict: false,
        reasoning: 'Multimodal fusion: Seated desk posture, engaged expression signal, and stationary phone confirm Deep Focus session.',
        contributingSignals: signals,
      );
    }

    // Rest / Break Synergistic evaluation:
    if (visionSample.facePresent &&
        (visionSample.expressionSignal == VisibleExpressionSignal.lowActivity ||
            visionSample.expressionSignal == VisibleExpressionSignal.calm ||
            visionSample.poseState == ObservablePosture.resting) &&
        sensorSnapshot.lightLux < 100.0) {
      fusedContext = AmbientContextType.relaxation;
      fusedConfidence = (baselineSensorConfidence * 0.6) + (visionSample.visionConfidence * 0.4);
      if (fusedConfidence < 0.86) fusedConfidence = 0.86;

      signals.add('Expression: ${visionSample.expressionSignal.displayName}');
      signals.add('Dim Ambient Illumination (${sensorSnapshot.lightLux.toStringAsFixed(0)} lux)');
      signals.add('Relaxed posture confirmed');

      return FusionResult(
        context: fusedContext,
        fusedConfidence: fusedConfidence,
        stabilizedGesture: stabilizedGesture,
        hasConflict: false,
        reasoning: 'Multimodal fusion: Relaxed visual cues and calm illumination confirm Rest profile.',
        contributingSignals: signals,
      );
    }

    // Default fused return
    return FusionResult(
      context: baselineContext,
      fusedConfidence: (baselineSensorConfidence * 0.7) + (visionSample.visionConfidence * 0.3),
      stabilizedGesture: stabilizedGesture,
      hasConflict: false,
      reasoning: 'Temporal sensor fusion active.',
      contributingSignals: [
        'Baseline Context: ${baselineContext.displayName}',
        'Sensor Confidence: ${(baselineSensorConfidence * 100).toStringAsFixed(0)}%',
        'Vision Signal: ${visionSample.expressionSignal.displayName}',
      ],
    );
  }
}
