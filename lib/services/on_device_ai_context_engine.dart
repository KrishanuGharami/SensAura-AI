import 'dart:math';
import '../models/ambient_context.dart';
import '../models/automation_scene.dart';
import '../models/context_result.dart';
import '../models/pose_feature_snapshot.dart';
import '../models/sensor_snapshot.dart';
import '../models/vision_context_sample.dart';
import 'context_inference_engine.dart';
import 'rule_based_context_engine.dart';
import 'voice_intent_provider.dart';

/// Optional on-device model bridge.
/// Designed for Google AI Edge / MediaPipe Custom Classifier Model (.tflite / .task).
/// Takes a normalized feature tensor:
/// [normalized_accel_x, normalized_accel_y, normalized_accel_z,
///  log_lux, proximity_binary, ble_presence_binary, ble_rssi_normalized]
/// and outputs softmax probabilities across ambient context classes.
class OnDeviceAIContextEngine implements ContextInferenceEngine {
  final RuleBasedContextEngine _fallbackEngine = RuleBasedContextEngine();
  final bool isModelLoaded;

  OnDeviceAIContextEngine({this.isModelLoaded = false});

  @override
  String get engineName => isModelLoaded
      ? 'On-Device Tensor Model'
      : 'Deterministic Rules (Model Not Installed)';

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

    // If local model tensor runner is not initialized, delegate to the
    // deterministic rule engine and report that fact honestly.
    if (!isModelLoaded) {
      final fallbackResult = await _fallbackEngine.inferContext(
        snapshot,
        posture: posture,
        vision: vision,
        voice: voice,
      );
      stopwatch.stop();
      return ContextResult(
        context: fallbackResult.context,
        confidence: fallbackResult.confidence,
        reasoning: '${fallbackResult.reasoning} [Deterministic on-device rules; no model runner]',
        detectedSignals: [
          ...fallbackResult.detectedSignals,
          'No tensor model runner configured; deterministic rules used',
        ],
        recommendedScene: fallbackResult.recommendedScene,
        inferenceLatencyMs: max(1.1, stopwatch.elapsedMicroseconds / 1000.0),
        evaluatedAt: DateTime.now(),
      );
    }

    // Example tensor preprocessing pipeline:
    // final tensor = [
    //   snapshot.accelX / 19.6,
    //   snapshot.accelY / 19.6,
    //   snapshot.accelZ / 19.6,
    //   log(max(1.0, snapshot.lightLux)) / 10.0,
    //   snapshot.proximityNear ? 1.0 : 0.0,
    //   snapshot.homeBeaconDetected ? 1.0 : 0.0,
    //   (snapshot.homeBeaconRssi + 100.0) / 70.0,
    // ];

    // A model flag is not evidence that a model runner exists. Fail closed
    // until a real tensor interpreter is connected.
    stopwatch.stop();
    return ContextResult(
      context: AmbientContextType.uncertain,
      confidence: 0.0,
      reasoning: 'On-device model runner unavailable; automation is disabled.',
      detectedSignals: const ['No model inference executed'],
      recommendedScene: AutomationScene.neutral,
      inferenceLatencyMs: stopwatch.elapsedMicroseconds / 1000.0,
      evaluatedAt: DateTime.now(),
    );
  }
}
