import '../models/pose_feature_snapshot.dart';
import '../models/sensor_snapshot.dart';
import '../models/context_result.dart';
import '../models/vision_context_sample.dart';
import 'voice_intent_provider.dart';

/// Abstract contract for on-device multimodal context inference.
/// Processes real hardware sensors, camera posture features, vision samples, and local voice intents.
abstract class ContextInferenceEngine {
  /// Evaluates multimodal inputs and outputs contextual inference.
  Future<ContextResult> inferContext(
    SensorSnapshot snapshot, {
    PoseFeatureSnapshot? posture,
    VisionContextSample? vision,
    VoiceIntentSnapshot? voice,
  });

  /// Engine identifier for telemetry badges. This must describe the actual
  /// implementation, not an unbundled model or cloud service.
  String get engineName;

  /// Whether this engine runs strictly on-device without cloud dependence
  bool get isOnDevice => true;
}
