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
      confidence: 0.0,
      reasoning: 'Waiting for fresh sensor telemetry.',
      detectedSignals: const ['No fresh telemetry available'],
      recommendedScene: AutomationScene.neutral,
      inferenceLatencyMs: 0.0,
      evaluatedAt: DateTime.now(),
      guardResult: const ContextGuardResult(
        decision: ContextGuardDecision.noAction,
        summary: 'Automation paused: Waiting for telemetry',
        explanation: 'No fresh sensor snapshot is available yet.',
        checks: [],
        isSafeToApply: false,
      ),
    );
  }
}
