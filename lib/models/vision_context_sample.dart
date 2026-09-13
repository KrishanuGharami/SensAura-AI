import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import 'pose_feature_snapshot.dart';

/// Explicit hand gestures recognized by on-device computer vision.
enum HandGesture {
  none,
  openPalm,
  thumbUp,
  thumbDown,
  victory,
  closedFist,
  pointingUp,
  unknown;

  String get displayName {
    switch (this) {
      case HandGesture.none:
        return 'No Gesture';
      case HandGesture.openPalm:
        return 'Open Palm (✋)';
      case HandGesture.thumbUp:
        return 'Thumb Up (👍)';
      case HandGesture.thumbDown:
        return 'Thumb Down (👎)';
      case HandGesture.victory:
        return 'Victory / V-Sign (✌️)';
      case HandGesture.closedFist:
        return 'Closed Fist (✊)';
      case HandGesture.pointingUp:
        return 'Pointing Up (☝️)';
      case HandGesture.unknown:
        return 'Unrecognized';
    }
  }

  String getLocalizedName(AppLocalizations? l10n) {
    if (l10n == null) return displayName;
    switch (this) {
      case HandGesture.none:
        return l10n.gestureNone;
      case HandGesture.openPalm:
        return l10n.gestureOpenPalm;
      case HandGesture.thumbUp:
        return l10n.gestureThumbUp;
      case HandGesture.thumbDown:
        return l10n.gestureThumbDown;
      case HandGesture.victory:
        return l10n.gestureVictory;
      case HandGesture.closedFist:
        return l10n.gestureClosedFist;
      case HandGesture.pointingUp:
        return l10n.gesturePointingUp;
      case HandGesture.unknown:
        return l10n.gestureUnknown;
    }
  }

  String getLocalizedAction(AppLocalizations? l10n) {
    if (l10n == null) return mappedActionDescription;
    switch (this) {
      case HandGesture.none:
        return l10n.gestureNone;
      case HandGesture.openPalm:
        return l10n.gestureActionPause;
      case HandGesture.thumbUp:
        return l10n.gestureActionConfirm;
      case HandGesture.thumbDown:
        return l10n.gestureActionReject;
      case HandGesture.victory:
        return l10n.gestureActionFocus;
      case HandGesture.closedFist:
        return l10n.gestureActionRest;
      case HandGesture.pointingUp:
        return l10n.gestureActionCycle;
      case HandGesture.unknown:
        return l10n.gestureUnknown;
    }
  }

  String get emoji {
    switch (this) {
      case HandGesture.none:
        return '—';
      case HandGesture.openPalm:
        return '✋';
      case HandGesture.thumbUp:
        return '👍';
      case HandGesture.thumbDown:
        return '👎';
      case HandGesture.victory:
        return '✌️';
      case HandGesture.closedFist:
        return '✊';
      case HandGesture.pointingUp:
        return '☝️';
      case HandGesture.unknown:
        return '❓';
    }
  }

  String get symbol => emoji;

  bool get isExplicitIntent =>
      this != HandGesture.none && this != HandGesture.unknown;

  String get mappedActionDescription {
    switch (this) {
      case HandGesture.none:
        return 'Passive ambient observation';
      case HandGesture.openPalm:
        return 'Pause automation / lock current environment';
      case HandGesture.thumbUp:
        return 'Explicitly confirm recommended scene';
      case HandGesture.thumbDown:
        return 'Reject recommended scene';
      case HandGesture.victory:
        return 'Trigger Deep Focus profile';
      case HandGesture.closedFist:
        return 'Trigger Quiet / Rest profile';
      case HandGesture.pointingUp:
        return 'Cycle to next recommended profile';
      case HandGesture.unknown:
        return 'Gesture below confidence threshold';
    }
  }
}

/// Observable visible expression signals derived from facial landmark geometry.
/// Does NOT pretend to read inner psychological emotions; strictly measures observable geometry.
enum VisibleExpressionSignal {
  calm,
  engaged,
  positive,
  lowActivity,
  elevatedActivity,
  eyesClosed,
  notDetected,
  unknown;

  String get displayName {
    switch (this) {
      case VisibleExpressionSignal.calm:
        return 'Calm Signal';
      case VisibleExpressionSignal.engaged:
        return 'Engaged Focus';
      case VisibleExpressionSignal.positive:
        return 'Positive Expression';
      case VisibleExpressionSignal.lowActivity:
        return 'Low Facial Activity';
      case VisibleExpressionSignal.elevatedActivity:
        return 'Elevated Activity';
      case VisibleExpressionSignal.eyesClosed:
        return 'Eyes Closed';
      case VisibleExpressionSignal.notDetected:
        return 'Face Not Detected';
      case VisibleExpressionSignal.unknown:
        return 'Indeterminate Signal';
    }
  }

  String getLocalizedName(AppLocalizations? l10n) {
    if (l10n == null) return displayName;
    switch (this) {
      case VisibleExpressionSignal.calm:
        return l10n.signalCalm;
      case VisibleExpressionSignal.engaged:
        return l10n.signalEngaged;
      case VisibleExpressionSignal.positive:
        return l10n.signalPositive;
      case VisibleExpressionSignal.lowActivity:
        return l10n.signalLowActivity;
      case VisibleExpressionSignal.elevatedActivity:
        return l10n.signalElevatedActivity;
      case VisibleExpressionSignal.eyesClosed:
        return l10n.signalEyesClosed;
      case VisibleExpressionSignal.notDetected:
      case VisibleExpressionSignal.unknown:
        return l10n.signalNotDetected;
    }
  }

  String get userDescription {
    switch (this) {
      case VisibleExpressionSignal.calm:
        return 'Neutral, relaxed facial muscle geometry';
      case VisibleExpressionSignal.engaged:
        return 'Direct forward gaze with steady brow engagement';
      case VisibleExpressionSignal.positive:
        return 'Elevated zygomaticus / smile-related mouth movement';
      case VisibleExpressionSignal.lowActivity:
        return 'Minimal facial motion; steady baseline';
      case VisibleExpressionSignal.elevatedActivity:
        return 'Dynamic facial displacement detected';
      case VisibleExpressionSignal.eyesClosed:
        return 'Eyelids closed for sustained duration';
      case VisibleExpressionSignal.notDetected:
        return 'No user face in camera field of view';
      case VisibleExpressionSignal.unknown:
        return 'Facial landmark geometry below confidence threshold';
    }
  }

  Color get badgeColor {
    switch (this) {
      case VisibleExpressionSignal.calm:
        return const Color(0xFF00E5FF); // Cyber Cyan
      case VisibleExpressionSignal.engaged:
        return const Color(0xFFFFB300); // Amber
      case VisibleExpressionSignal.positive:
        return const Color(0xFF00E676); // Emerald Green
      case VisibleExpressionSignal.lowActivity:
        return const Color(0xFF7C4DFF); // Violet
      case VisibleExpressionSignal.elevatedActivity:
        return const Color(0xFFFF9100); // Orange
      case VisibleExpressionSignal.eyesClosed:
        return const Color(0xFF9E9E9E); // Muted
      case VisibleExpressionSignal.notDetected:
        return const Color(0xFFFF5252); // Red
      case VisibleExpressionSignal.unknown:
        return const Color(0xFF757575);
    }
  }
}

/// Runtime backend for on-device computer vision.
/// Strictly honest: Never claims unverified NPU.
enum AiRuntimeBackend {
  auto,
  cpu,
  gpu,
  npu,
  localFallback;

  String get displayName {
    switch (this) {
      case AiRuntimeBackend.auto:
        return 'AUTO (DEVICE SELECTED)';
      case AiRuntimeBackend.cpu:
        return 'CPU (ON-DEVICE)';
      case AiRuntimeBackend.gpu:
        return 'GPU ACCELERATED';
      case AiRuntimeBackend.npu:
        return 'NPU / QNN ACCELERATED';
      case AiRuntimeBackend.localFallback:
        return 'LOCAL FALLBACK';
    }
  }

  bool get isHardwareAccelerated =>
      this == AiRuntimeBackend.gpu || this == AiRuntimeBackend.npu;

  Color get color {
    switch (this) {
      case AiRuntimeBackend.auto:
        return const Color(0xFF00E5FF);
      case AiRuntimeBackend.cpu:
        return const Color(0xFFFFB300);
      case AiRuntimeBackend.gpu:
        return const Color(0xFF00E676);
      case AiRuntimeBackend.npu:
        return const Color(0xFF7C4DFF);
      case AiRuntimeBackend.localFallback:
        return const Color(0xFF00E5FF);
    }
  }
}

/// Real-time sample containing extracted visual geometry and intent features.
/// RAW CAMERA FRAMES ARE NEVER STORED OR TRANSMITTED TO CLOUD.
class VisionContextSample {
  final DateTime timestamp;
  final bool facePresent;
  final double faceConfidence;
  final VisibleExpressionSignal expressionSignal;
  final double expressionConfidence;
  final HandGesture gesture;
  final double gestureConfidence;
  final ObservablePosture poseState;
  final double poseConfidence;
  final double facialActivity; // 0.0 to 1.0
  final double eyeOpenness; // 0.0 (closed) to 1.0 (open)
  final double mouthOpenness; // 0.0 to 1.0
  final double headTiltAngle; // Degrees
  final double cameraMotion; // Optical flow magnitude
  final double visionConfidence;
  final AiRuntimeBackend runtimeBackend;
  final String debugSummary;
  final bool isHardwareCamera;
  final double fps;
  final double inferenceLatencyMs;
  final int droppedFrames;

  const VisionContextSample({
    required this.timestamp,
    required this.facePresent,
    required this.faceConfidence,
    required this.expressionSignal,
    required this.expressionConfidence,
    required this.gesture,
    required this.gestureConfidence,
    required this.poseState,
    required this.poseConfidence,
    this.facialActivity = 0.15,
    this.eyeOpenness = 0.90,
    this.mouthOpenness = 0.05,
    this.headTiltAngle = 1.5,
    this.cameraMotion = 0.02,
    required this.visionConfidence,
    this.runtimeBackend = AiRuntimeBackend.localFallback,
    this.debugSummary = 'Local on-device vision extractor active',
    this.isHardwareCamera = false,
    this.fps = 8.0,
    this.inferenceLatencyMs = 12.5,
    this.droppedFrames = 0,
  });

  factory VisionContextSample.neutral() {
    return VisionContextSample(
      timestamp: DateTime.now(),
      facePresent: true,
      faceConfidence: 0.91,
      expressionSignal: VisibleExpressionSignal.calm,
      expressionConfidence: 0.88,
      gesture: HandGesture.none,
      gestureConfidence: 0.0,
      poseState: ObservablePosture.seated,
      poseConfidence: 0.92,
      facialActivity: 0.12,
      eyeOpenness: 0.95,
      mouthOpenness: 0.04,
      headTiltAngle: 1.0,
      cameraMotion: 0.02,
      visionConfidence: 0.90,
      runtimeBackend: AiRuntimeBackend.localFallback,
      debugSummary: 'Calm seated user detected at desk',
      isHardwareCamera: false,
      fps: 8.0,
      inferenceLatencyMs: 12.5,
      droppedFrames: 0,
    );
  }

  factory VisionContextSample.unknown() {
    return VisionContextSample(
      timestamp: DateTime.now(),
      facePresent: false,
      faceConfidence: 0.0,
      expressionSignal: VisibleExpressionSignal.notDetected,
      expressionConfidence: 0.0,
      gesture: HandGesture.none,
      gestureConfidence: 0.0,
      poseState: ObservablePosture.unknown,
      poseConfidence: 0.0,
      facialActivity: 0.0,
      eyeOpenness: 0.0,
      mouthOpenness: 0.0,
      headTiltAngle: 0.0,
      cameraMotion: 0.0,
      visionConfidence: 0.0,
      runtimeBackend: AiRuntimeBackend.localFallback,
      debugSummary: 'Camera inactive or no visual target present',
      isHardwareCamera: false,
      fps: 0.0,
      inferenceLatencyMs: 0.0,
      droppedFrames: 0,
    );
  }

  VisionContextSample copyWith({
    DateTime? timestamp,
    bool? facePresent,
    double? faceConfidence,
    VisibleExpressionSignal? expressionSignal,
    double? expressionConfidence,
    HandGesture? gesture,
    double? gestureConfidence,
    ObservablePosture? poseState,
    double? poseConfidence,
    double? facialActivity,
    double? eyeOpenness,
    double? mouthOpenness,
    double? headTiltAngle,
    double? cameraMotion,
    double? visionConfidence,
    AiRuntimeBackend? runtimeBackend,
    String? debugSummary,
    bool? isHardwareCamera,
    double? fps,
    double? inferenceLatencyMs,
    int? droppedFrames,
  }) {
    return VisionContextSample(
      timestamp: timestamp ?? this.timestamp,
      facePresent: facePresent ?? this.facePresent,
      faceConfidence: faceConfidence ?? this.faceConfidence,
      expressionSignal: expressionSignal ?? this.expressionSignal,
      expressionConfidence: expressionConfidence ?? this.expressionConfidence,
      gesture: gesture ?? this.gesture,
      gestureConfidence: gestureConfidence ?? this.gestureConfidence,
      poseState: poseState ?? this.poseState,
      poseConfidence: poseConfidence ?? this.poseConfidence,
      facialActivity: facialActivity ?? this.facialActivity,
      eyeOpenness: eyeOpenness ?? this.eyeOpenness,
      mouthOpenness: mouthOpenness ?? this.mouthOpenness,
      headTiltAngle: headTiltAngle ?? this.headTiltAngle,
      cameraMotion: cameraMotion ?? this.cameraMotion,
      visionConfidence: visionConfidence ?? this.visionConfidence,
      runtimeBackend: runtimeBackend ?? this.runtimeBackend,
      debugSummary: debugSummary ?? this.debugSummary,
      isHardwareCamera: isHardwareCamera ?? this.isHardwareCamera,
      fps: fps ?? this.fps,
      inferenceLatencyMs: inferenceLatencyMs ?? this.inferenceLatencyMs,
      droppedFrames: droppedFrames ?? this.droppedFrames,
    );
  }

  bool get isPrivacyPreserved => true;

  bool get faceDetected => facePresent;
  int get faceLandmarkCount => facePresent ? 468 : 0;
  ObservablePosture get posture => poseState;
  double get postureConfidence => poseConfidence;
}
