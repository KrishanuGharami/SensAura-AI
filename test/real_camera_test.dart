import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sensaura_ai/models/context_result.dart';
import 'package:sensaura_ai/models/vision_context_sample.dart';
import 'package:sensaura_ai/screens/ai_context_screen.dart';
import 'package:sensaura_ai/services/mediapipe_vision_provider.dart';
import 'package:sensaura_ai/services/real_camera_provider.dart';

/// Test mock implementation of CameraProvider for unit and widget testing
class TestCameraProvider implements CameraProvider {
  bool _initialized = false;
  String? _error;
  final StreamController<CameraImage> _controller =
      StreamController<CameraImage>.broadcast();

  @override
  bool get isInitialized => _initialized;

  @override
  bool get isStreaming => _initialized;

  @override
  bool get isPermissionDenied => _error != null && _error!.contains('denied');

  @override
  String? get errorMessage => _error;

  @override
  CameraController? get controller => null;

  @override
  Stream<CameraImage> get imageStream => _controller.stream;

  @override
  double get measuredFps => 8.0;

  @override
  int get totalFramesReceived => 42;

  @override
  int get totalFramesProcessed => 42;

  @override
  String? get errorStatus => _error;

  @override
  List<CameraDescription> get availableCameras => const [];

  @override
  int get activeCameraIndex => 0;

  @override
  String get cameraLensDescription => 'Front Lens (Selfie)';

  @override
  String get activeLensName => 'Front Lens (Selfie)';

  @override
  Future<bool> initialize() async {
    _initialized = true;
    _error = null;
    return true;
  }

  void simulateError(String msg) {
    _initialized = false;
    _error = msg;
  }

  @override
  Future<void> startImageStream() async {}

  @override
  Future<void> stopImageStream() async {}

  @override
  Future<void> pause() async {}

  @override
  Future<void> resume() async {}

  @override
  Future<void> switchCamera() async {}

  @override
  void dispose() {
    _controller.close();
    _initialized = false;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Real Camera Pipeline & Provider Tests', () {
    test('RealCameraProvider: headless initialization returns false gracefully',
        () async {
      final realCamera = RealCameraProvider();

      expect(realCamera.isInitialized, isFalse);
      expect(realCamera.controller, isNull);
      expect(realCamera.totalFramesProcessed, equals(0));
      expect(realCamera.measuredFps, isNonNegative);

      // In unit test environment (no physical camera hardware or camera plugin channel)
      final ok = await realCamera.initialize();
      expect(ok, isFalse);
      expect(realCamera.isInitialized, isFalse);
      expect(realCamera.errorStatus, isNotNull);

      // Disposal should never crash
      realCamera.dispose();
    });

    test('MediaPipeVisionProvider: bindCameraStream accepts camera stream',
        () async {
      final vision = MediaPipeVisionProvider();
      final streamController = StreamController<CameraImage>.broadcast();

      vision.bindCameraStream(streamController.stream);

      // Vision sample stream should still provide samples and track metrics
      final sample = vision.latestSample;
      expect(sample, isNotNull);
      expect(vision.fps, isNonNegative);
      expect(vision.droppedFrames, isNonNegative);

      await streamController.close();
      vision.dispose();
    });

    test('MediaPipeVisionProvider: dropped frame and latency metrics tracking',
        () async {
      final vision = MediaPipeVisionProvider();
      await vision.start();

      expect(vision.droppedFrames, equals(0));
      expect(vision.latestSample.runtimeBackend, isNotNull);
      expect(vision.latestSample.isHardwareCamera, isFalse);

      // Injecting a sample works immediately
      vision.injectVisionSample(
        VisionContextSample.neutral().copyWith(
          isHardwareCamera: true,
          gesture: HandGesture.victory,
        ),
      );

      expect(vision.latestSample.gesture, equals(HandGesture.victory));
      expect(vision.latestSample.isHardwareCamera, isTrue);

      vision.dispose();
    });

    testWidgets('AiContextScreen: renders Sensor-Only mode when camera unavailable',
        (tester) async {
      final testCam = TestCameraProvider()..simulateError('No camera available');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AiContextScreen(
              result: ContextResult.initial(),
              visionSample: VisionContextSample.neutral(),
              cameraProvider: testCam,
              isAutomationPaused: false,
              isApplyingScene: false,
              onApplyScene: (_) {},
              onPauseAutomation: () {},
              onResumeAutomation: () {},
            ),
          ),
        ),
      );

      await tester.pump();

      // Should display SENSOR-ONLY MODE banner
      expect(find.text('CAMERA: SENSOR-ONLY MODE'), findsOneWidget);
      expect(find.text('CAMERA UNAVAILABLE — SENSOR-ONLY MODE'), findsOneWidget);
      expect(find.text('No camera available'), findsOneWidget);

      testCam.dispose();
    });

    testWidgets('AiContextScreen: displays Live iQOO front lens when initialized',
        (tester) async {
      final testCam = TestCameraProvider();
      await testCam.initialize();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AiContextScreen(
              result: ContextResult.initial(),
              visionSample: VisionContextSample.neutral().copyWith(
                isHardwareCamera: true,
                fps: 8.0,
                inferenceLatencyMs: 14.5,
              ),
              cameraProvider: testCam,
              isAutomationPaused: false,
              isApplyingScene: false,
              onApplyScene: (_) {},
              onPauseAutomation: () {},
              onResumeAutomation: () {},
            ),
          ),
        ),
      );

      await tester.pump();

      // Top control bar should display camera status
      expect(find.textContaining('CAMERA: LIVE iQOO'), findsOneWidget);
      expect(find.textContaining('8 CAM FPS'), findsOneWidget);
      expect(find.textContaining('14.5ms'), findsOneWidget);

      testCam.dispose();
    });
  });
}
