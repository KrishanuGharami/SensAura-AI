import 'ambient_context.dart';
import 'automation_scene.dart';
import 'context_guard_result.dart';

class ContextResult {
  final AmbientContextType context;
  final double confidence;
  final String reasoning;
  final List<String> detectedSignals;
  final AutomationScene recommendedScene;
  final double inferenceLatencyMs;
  final DateTime evaluatedAt;
  final ContextGuardResult guardResult;

  const ContextResult({
    required this.context,
    required this.confidence,
    required this.reasoning,
    required this.detectedSignals,
    required this.recommendedScene,
    required this.inferenceLatencyMs,
    required this.evaluatedAt,
    this.guardResult = ContextGuardResult.defaultSafe,
  });

  /// Formatted confidence string (e.g., "94%")
  String get confidencePercentage => '${(confidence * 100).toStringAsFixed(0)}%';

  ContextResult copyWith({
    AmbientContextType? context,
    double? confidence,
    String? reasoning,
    List<String>? detectedSignals,
    AutomationScene? recommendedScene,
    double? inferenceLatencyMs,
    DateTime? evaluatedAt,
    ContextGuardResult? guardResult,
  }) {
    return ContextResult(
      context: context ?? this.context,
      confidence: confidence ?? this.confidence,
      reasoning: reasoning ?? this.reasoning,
      detectedSignals: detectedSignals ?? this.detectedSignals,
      recommendedScene: recommendedScene ?? this.recommendedScene,
      inferenceLatencyMs: inferenceLatencyMs ?? this.inferenceLatencyMs,
      evaluatedAt: evaluatedAt ?? this.evaluatedAt,
      guardResult: guardResult ?? this.guardResult,
    );
  }

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
      guardResult: ContextGuardResult.initial(),
    );
  }
}
