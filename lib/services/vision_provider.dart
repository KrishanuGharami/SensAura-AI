import 'dart:async';
import '../models/vision_context_sample.dart';

/// Clean interface for on-device real-time computer vision providers.
/// Decouples UI and Context Engine from concrete camera SDKs or MediaPipe backends.
abstract class VisionProvider {
  /// Stream emitting real-time vision context telemetry (facial expressions, gestures, pose).
  Stream<VisionContextSample> get visionStream;

  /// Most recent visual context sample.
  VisionContextSample get latestSample;

  /// Whether the vision subsystem is active.
  bool get isActive;

  /// Whether an inference frame is currently being processed (for non-blocking drop logic).
  bool get isProcessing;

  /// Measured preview camera frames per second.
  double get currentCameraFps;

  /// Measured on-device AI inference evaluations per second (targeted ~5-10 FPS).
  double get currentInferenceFps;

  /// Hardware acceleration runtime backend (AUTO / CPU / GPU / NPU / LOCAL FALLBACK).
  AiRuntimeBackend get runtimeBackend;

  /// Initialize camera hardware and AI pipeline.
  Future<bool> initialize();

  /// Start camera frame ingestion and AI feature extraction loop.
  Future<void> startVision();

  /// Pause/stop camera ingestion to preserve battery and compute when screen is backgrounded.
  Future<void> stopVision();

  /// Testing & developer diagnostic injection hook.
  void injectVisionSample(VisionContextSample sample);

  /// Release all camera controllers, native buffers, and streams.
  void dispose();
}
