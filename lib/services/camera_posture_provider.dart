import 'dart:async';
import '../models/pose_feature_snapshot.dart';

/// Abstract provider for local, privacy-preserving camera posture telemetry.
abstract class CameraPostureProvider {
  Stream<PoseFeatureSnapshot> get postureStream;
  PoseFeatureSnapshot get currentSnapshot;
  bool get isActive;
  bool get isHardwareCamera;
  Future<void> start();
  Future<void> stop();
  void dispose();
}

/// Camera integration boundary.  A camera/pose model is not bundled yet, so
/// production mode reports unavailable rather than fabricating posture.
/// Demo and tests may inject derived posture features without raw frames.
class RealCameraPostureProvider implements CameraPostureProvider {
  final StreamController<PoseFeatureSnapshot> _controller =
      StreamController<PoseFeatureSnapshot>.broadcast();

  PoseFeatureSnapshot _current = PoseFeatureSnapshot.neutral();
  bool _isActive = false;
  bool _isHardware = false;

  @override
  Stream<PoseFeatureSnapshot> get postureStream => _controller.stream;

  @override
  PoseFeatureSnapshot get currentSnapshot => _current;

  @override
  bool get isActive => _isActive;

  @override
  bool get isHardwareCamera => _isHardware;

  @override
  Future<void> start() async {
    if (_isActive) return;
    // No camera capture/model is bundled. Keep the provider inactive and
    // expose an explicit unknown snapshot instead of claiming a live camera.
    _isActive = false;

    _current = PoseFeatureSnapshot.unknown().copyWith(
      debugSummary: 'Camera posture unavailable; no camera model configured',
    );
    _controller.add(_current);
  }

  /// Manually set observable posture (e.g. for testing or developer scenario injection)
  void injectPosture(ObservablePosture posture, double confidence, double stability) {
    _current = PoseFeatureSnapshot(
      posture: posture,
      confidence: confidence,
      stabilityScore: stability,
      isUserPresent: posture != ObservablePosture.unknown,
      timestamp: DateTime.now(),
      isHardwareCamera: _isHardware,
      debugSummary: 'Injected posture state: ${posture.displayName}',
    );
    _controller.add(_current);
  }

  /// Updates observable posture from real-time MediaPipe vision pipeline
  void updateFromVision({
    required ObservablePosture posture,
    required double confidence,
    required bool isHardwareCamera,
    required DateTime timestamp,
  }) {
    _isActive = true;
    _isHardware = isHardwareCamera;
    _current = PoseFeatureSnapshot(
      posture: posture,
      confidence: confidence,
      stabilityScore: 0.9,
      isUserPresent: posture != ObservablePosture.unknown,
      timestamp: timestamp,
      isHardwareCamera: isHardwareCamera,
      debugSummary: 'MediaPipe local posture: ${posture.displayName}',
    );
    _controller.add(_current);
  }

  @override
  Future<void> stop() async {
    _isActive = false;
  }

  @override
  void dispose() {
    stop();
    _controller.close();
  }
}
