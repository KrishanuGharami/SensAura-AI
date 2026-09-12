import '../models/sensor_snapshot.dart';
import '../models/context_result.dart';

/// Abstract contract for on-device context inference.
/// Enables seamless swapping between Rule-based heuristic fusion and
/// Google AI Edge / MediaPipe neural tensor classifiers.
abstract class ContextInferenceEngine {
  /// Evaluates a raw sensor snapshot and outputs contextual inference.
  Future<ContextResult> inferContext(SensorSnapshot snapshot);

  /// Engine identifier for telemetry badges
  String get engineName;

  /// Whether this engine runs strictly on-device without cloud dependence
  bool get isOnDevice => true;
}
