import 'package:flutter/material.dart';

/// Observable physical postures detectable by on-device camera/vision context
enum ObservablePosture {
  seated,
  standing,
  stationary,
  moving,
  resting,
  unknown;

  String get displayName {
    switch (this) {
      case ObservablePosture.seated:
        return 'Seated at Desk';
      case ObservablePosture.standing:
        return 'Standing Active';
      case ObservablePosture.stationary:
        return 'Stationary Pose';
      case ObservablePosture.moving:
        return 'In Motion / Walking';
      case ObservablePosture.resting:
        return 'Leaning / Resting';
      case ObservablePosture.unknown:
        return 'No Posture / Away';
    }
  }

  IconData get icon {
    switch (this) {
      case ObservablePosture.seated:
        return Icons.chair_rounded;
      case ObservablePosture.standing:
        return Icons.accessibility_new_rounded;
      case ObservablePosture.stationary:
        return Icons.accessibility_rounded;
      case ObservablePosture.moving:
        return Icons.directions_walk_rounded;
      case ObservablePosture.resting:
        return Icons.airline_seat_recline_extra_rounded;
      case ObservablePosture.unknown:
        return Icons.person_off_rounded;
    }
  }
}

/// Lightweight snapshot of derived camera posture features.
/// Strictly contains mathematical geometric features — NO RAW IMAGE STORAGE.
class PoseFeatureSnapshot {
  final ObservablePosture posture;
  final double confidence;
  final double stabilityScore; // 0.0 to 1.0 (higher = user is still/focused)
  final bool isUserPresent;
  final double headTiltAngle; // In degrees
  final DateTime timestamp;
  final bool isHardwareCamera;
  final String debugSummary;

  const PoseFeatureSnapshot({
    required this.posture,
    required this.confidence,
    required this.stabilityScore,
    required this.isUserPresent,
    this.headTiltAngle = 0.0,
    required this.timestamp,
    this.isHardwareCamera = false,
    this.debugSummary = 'Local camera posture analyzer active',
  });

  factory PoseFeatureSnapshot.neutral() {
    return PoseFeatureSnapshot(
      posture: ObservablePosture.seated,
      confidence: 0.88,
      stabilityScore: 0.92,
      isUserPresent: true,
      headTiltAngle: 2.5,
      timestamp: DateTime.now(),
      isHardwareCamera: false,
      debugSummary: 'Baseline seated desk posture',
    );
  }

  factory PoseFeatureSnapshot.unknown() {
    return PoseFeatureSnapshot(
      posture: ObservablePosture.unknown,
      confidence: 0.0,
      stabilityScore: 0.0,
      isUserPresent: false,
      timestamp: DateTime.now(),
      isHardwareCamera: false,
      debugSummary: 'Camera inactive or user not present',
    );
  }

  PoseFeatureSnapshot copyWith({
    ObservablePosture? posture,
    double? confidence,
    double? stabilityScore,
    bool? isUserPresent,
    double? headTiltAngle,
    DateTime? timestamp,
    bool? isHardwareCamera,
    String? debugSummary,
  }) {
    return PoseFeatureSnapshot(
      posture: posture ?? this.posture,
      confidence: confidence ?? this.confidence,
      stabilityScore: stabilityScore ?? this.stabilityScore,
      isUserPresent: isUserPresent ?? this.isUserPresent,
      headTiltAngle: headTiltAngle ?? this.headTiltAngle,
      timestamp: timestamp ?? this.timestamp,
      isHardwareCamera: isHardwareCamera ?? this.isHardwareCamera,
      debugSummary: debugSummary ?? this.debugSummary,
    );
  }

  /// True privacy guarantee: Only geometric pose heuristics exist in volatile memory.
  bool get isPrivacyPreserved => true;
}
