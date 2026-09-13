import '../models/ambient_context.dart';
import '../models/context_guard_result.dart';
import '../models/context_result.dart';
import '../models/pose_feature_snapshot.dart';
import '../models/sensor_snapshot.dart';

/// Local Explanation Engine.
/// Synthesizes transparent, human-readable natural language explanations
/// of why a context inference occurred and how the SensAura Context Guard evaluated safety.
///
/// Strictly executed on-device with zero cloud calls.
/// Never blocks the safety gate or actuator dispatch.
class LocalExplanationEngine {
  const LocalExplanationEngine();

  /// Generates a comprehensive natural language explanation of the current system state.
  String explain({
    required ContextResult contextResult,
    required SensorSnapshot sensorSnapshot,
    PoseFeatureSnapshot? postureSnapshot,
  }) {
    final context = contextResult.context;
    final guard = contextResult.guardResult;
    final buffer = StringBuffer();

    // 1. Context Explanation
    switch (context) {
      case AmbientContextType.focus:
        buffer.write('Adaptive Personal Workspace identified active Deep Focus. ');
        if (postureSnapshot != null && postureSnapshot.posture == ObservablePosture.seated) {
          buffer.write('Observable camera features confirmed stable seated posture (${(postureSnapshot.stabilityScore * 100).toStringAsFixed(0)}% stability). ');
        }
        buffer.write('Phone IMU motion was negligible (${sensorSnapshot.accelMagnitude.toStringAsFixed(2)} m/s²), and ambient light (${sensorSnapshot.lightLux.toStringAsFixed(0)} lux) matched focused desk illumination. ');
        break;

      case AmbientContextType.relaxation:
        buffer.write('Rest profile detected. ');
        buffer.write('Phone remained still for consecutive intervals, ambient light decreased to ${sensorSnapshot.lightLux.toStringAsFixed(0)} lux (< 40 lux), and workstation beacon verified home presence. ');
        break;

      case AmbientContextType.breakTime:
        buffer.write('Workspace break triggered. ');
        buffer.write('Periodic focus session elapsed or break intent registered. Ambient illumination softened and break timer initialized. ');
        break;

      case AmbientContextType.leaving:
        buffer.write('Workstation departure detected. ');
        buffer.write('A sustained acceleration surge (${sensorSnapshot.accelMagnitude.toStringAsFixed(1)} m/s²) correlated with a drop in workstation BLE beacon signal. ');
        break;

      case AmbientContextType.arriving:
        buffer.write('Workstation arrival registered. ');
        buffer.write('Workstation BLE beacon re-acquired with strong RSSI (${sensorSnapshot.homeBeaconRssi} dBm) while walking motion settled into desktop stability. ');
        break;

      case AmbientContextType.sleep:
        buffer.write('Sleep sanctuary context inferred. ');
        buffer.write('Pitch black darkness (${sensorSnapshot.lightLux.toStringAsFixed(1)} lux), zero physical motion, and engaged proximity sensor confirm night rest. ');
        break;

      case AmbientContextType.uncertain:
        buffer.write('Uncertain context detected due to signal conflict. ');
        buffer.write('Sensors recorded contradictory cues (such as high transit-level movement while connected to a stationary workstation beacon). ');
        break;

      case AmbientContextType.neutral:
        buffer.write('Active normal baseline. ');
        buffer.write('Ambient lighting and phone motion are within standard daytime operational parameters. ');
        break;
    }

    // 2. Context Guard Safety Explanation
    buffer.write('\n\nSensAura Context Guard evaluated safety: ');
    switch (guard.decision) {
      case ContextGuardDecision.autoSafe:
        buffer.write('Decision is AUTO_SAFE (${contextResult.confidencePercentage} confidence). All safety gates passed, including absence of conflicting signals, expired cooldown, and verified actuator reachability.');
        break;
      case ContextGuardDecision.askUser:
        buffer.write('Decision is ASK_USER. Confidence is moderate or physical presence is pending verification. Direct user approval is requested before actuator actuation.');
        break;
      case ContextGuardDecision.noAction:
        buffer.write('Decision is NO_ACTION. Automation is safely locked because: ${guard.summary.toLowerCase()}. Actuator commands are blocked.');
        break;
    }

    return buffer.toString();
  }
}
