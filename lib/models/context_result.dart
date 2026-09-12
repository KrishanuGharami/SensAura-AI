import 'ambient_context.dart';
import 'automation_scene.dart';

class ContextResult {
  final AmbientContextType context;
  final double confidence;
  final String reasoning;
  final List<String> detectedSignals;
  final AutomationScene recommendedScene;
  final double inferenceLatencyMs;
  final DateTime evaluatedAt;

  const ContextResult({
    required this.context,
    required this.confidence,
    required this.reasoning,
    required this.detectedSignals,
    required this.recommendedScene,
    required this.inferenceLatencyMs,
    required this.evaluatedAt,
  });

  /// Formatted confidence string (e.g., "94%")
  String get confidencePercentage => '${(confidence * 100).toStringAsFixed(0)}%';

  factory ContextResult.initial() {
    return ContextResult(
      context: AmbientContextType.neutral,
      confidence: 0.85,
      reasoning: 'Standard daytime ambient light and normal movement detected.',
      detectedSignals: const [
        'Moderate indoor light (~120 lux)',
        'Low motion profile',
        'Home BLE beacon connected',
      ],
      recommendedScene: AutomationScene.neutral,
      inferenceLatencyMs: 0.9,
      evaluatedAt: DateTime.now(),
    );
  }
}
