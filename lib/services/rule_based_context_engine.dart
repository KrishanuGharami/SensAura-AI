import 'dart:math';
import '../models/ambient_context.dart';
import '../models/automation_scene.dart';
import '../models/context_result.dart';
import '../models/sensor_snapshot.dart';
import 'context_inference_engine.dart';

/// Deterministic on-device rule-based context engine.
/// Evaluates multi-modal sensor fusion (light, motion, proximity, BLE beacons)
/// locally in sub-2ms with zero external cloud dependencies.
class RuleBasedContextEngine implements ContextInferenceEngine {
  @override
  String get engineName => 'SensAura Heuristic Fusion v1.0 (On-Device)';

  @override
  bool get isOnDevice => true;

  @override
  Future<ContextResult> inferContext(SensorSnapshot snapshot) async {
    final stopwatch = Stopwatch()..start();

    final accelMag = snapshot.accelMagnitude;
    final accelDeviation = (accelMag - 9.80665).abs();
    final lux = snapshot.lightLux;
    final hasHomeBle = snapshot.homeBeaconDetected;
    final isProximityNear = snapshot.proximityNear;

    AmbientContextType inferredContext;
    double confidence;
    String reasoning;
    List<String> signals = [];
    AutomationScene scene;

    // 1. SLEEP SANCTUARY EVALUATION
    // Very dark (< 3 lux), static motion, proximity covered or near
    if (lux < 3.0 && accelDeviation < 0.5 && isProximityNear && hasHomeBle) {
      inferredContext = AmbientContextType.sleep;
      confidence = 0.98;
      reasoning = 'Pitch darkness + stationary phone + proximity sensor engaged suggests sleep state.';
      signals = [
        'Darkness: ${lux.toStringAsFixed(1)} lux',
        'Stationary: ${accelMag.toStringAsFixed(2)} m/s²',
        'Proximity sensor covered (face-down/nightstand)',
        'Home BLE beacon connected',
      ];
      scene = AutomationScene.sleepSanctuary;
    }
    // 2. LEAVING EVALUATION
    // High motion or transit acceleration with home BLE absent
    else if (!hasHomeBle && (accelDeviation > 1.8 || snapshot.motionLevel == MotionLevel.high)) {
      inferredContext = AmbientContextType.leaving;
      confidence = 0.96;
      reasoning = 'High movement + Home BLE presence lost suggests user departure.';
      signals = [
        'High motion detected (${accelMag.toStringAsFixed(1)} m/s²)',
        'Home BLE beacon signal lost',
        'Ambient transition to exterior',
      ];
      scene = AutomationScene.energySaving;
    }
    // 3. RELAXATION EVALUATION
    // Low motion, low ambient light (< 35 lux), home BLE active
    else if (lux <= 35.0 && accelDeviation < 1.4 && hasHomeBle) {
      inferredContext = AmbientContextType.relaxation;
      confidence = 0.94;
      reasoning = 'Low movement + dim environment + home presence suggests relaxation context.';
      signals = [
        'Low movement: ${accelMag.toStringAsFixed(2)} m/s²',
        'Dim ambient light: ${lux.toStringAsFixed(0)} lux (< 35 lux)',
        'Home BLE beacon detected (${snapshot.homeBeaconRssi} dBm)',
        'Proximity state: ${isProximityNear ? "Near" : "Far"}',
      ];
      scene = AutomationScene.relaxation;
    }
    // 4. ARRIVAL EVALUATION
    // Home beacon detected with strong RSSI (> -68 dBm), moderate settling motion
    else if (hasHomeBle && snapshot.homeBeaconRssi > -68 && accelDeviation >= 0.6 && accelDeviation <= 2.5) {
      inferredContext = AmbientContextType.arriving;
      confidence = 0.92;
      reasoning = 'Home BLE beacon re-detected + transit motion settling suggests arrival.';
      signals = [
        'Home BLE beacon acquired (${snapshot.homeBeaconRssi} dBm)',
        'Walking/entry motion settling',
        'Indoor illumination detected (${lux.toStringAsFixed(0)} lux)',
      ];
      scene = AutomationScene.welcomeHome;
    }
    // 5. DEEP FOCUS EVALUATION
    // Phone virtually static (< 0.25 dev), bright desk illumination, home beacon present
    else if (accelDeviation < 0.25 && lux >= 150.0 && lux <= 450.0 && hasHomeBle) {
      inferredContext = AmbientContextType.focus;
      confidence = 0.91;
      reasoning = 'Static desk orientation + bright workspace illumination indicates deep focus.';
      signals = [
        'Static desk orientation (${accelDeviation.toStringAsFixed(2)} m/s² dev)',
        'Focused workspace lighting (${lux.toStringAsFixed(0)} lux)',
        'Home beacon connected',
      ];
      scene = AutomationScene.deepFocus;
    }
    // 6. NEUTRAL / DEFAULT BASELINE
    else {
      inferredContext = AmbientContextType.neutral;
      confidence = 0.84;
      reasoning = 'Balanced ambient conditions and standard daily mobile activity.';
      signals = [
        'Moderate indoor light: ${lux.toStringAsFixed(0)} lux',
        'Normal device motion: ${snapshot.motionLevel.displayName}',
        'BLE network: ${snapshot.bleDevicesCount} devices found',
      ];
      scene = AutomationScene.neutral;
    }

    stopwatch.stop();
    final elapsedMs = max(0.4, stopwatch.elapsedMicroseconds / 1000.0);

    return ContextResult(
      context: inferredContext,
      confidence: confidence,
      reasoning: reasoning,
      detectedSignals: signals,
      recommendedScene: scene,
      inferenceLatencyMs: elapsedMs,
      evaluatedAt: DateTime.now(),
    );
  }
}
