import 'dart:async';
import 'package:camera/camera.dart';
import 'package:camera/camera.dart' as cam_plugin;

/// Clean interface for hardware camera providers.
/// Decouples the UI and computer vision engines from concrete camera plugins.
abstract class CameraProvider {
  /// The underlying CameraController if initialized.
  CameraController? get controller;

  /// Whether the camera has been successfully initialized.
  bool get isInitialized;

  /// Whether the live frame stream is active.
  bool get isStreaming;

  /// Whether camera permission was explicitly denied.
  bool get isPermissionDenied;

  /// Error message if camera initialization or streaming failed.
  String? get errorMessage;

  /// Measured preview frame rate (FPS).
  double get measuredFps;

  /// Total count of frames received from the hardware camera.
  int get totalFramesReceived;

  /// Description of the active camera lens (e.g. "Front Facing (Selfie)").
  String get cameraLensDescription;

  /// Stream emitting real raw hardware camera frames.
  Stream<CameraImage> get imageStream;

  /// List of discovered hardware cameras on this device.
  List<CameraDescription> get availableCameras;

  /// Index of currently active camera in [availableCameras].
  int get activeCameraIndex;

  /// Human-readable name of active lens.
  String get activeLensName;

  /// Current error status if any.
  String? get errorStatus;

  /// Total count of frames processed by camera provider.
  int get totalFramesProcessed;

  /// Switch to next available camera lens (e.g. front -> rear).
  Future<void> switchCamera();

  /// Initialize hardware camera, selecting the front-facing camera by default.
  Future<bool> initialize();

  /// Start live frame ingestion stream for real-time computer vision analysis.
  Future<void> startImageStream();

  /// Pause/stop live frame ingestion to preserve power.
  Future<void> stopImageStream();

  /// Pause camera hardware when app is backgrounded.
  Future<void> pause();

  /// Resume camera hardware when app returns to foreground.
  Future<void> resume();

  /// Release native camera buffers, streams, and controllers.
  void dispose();
}

/// Production implementation of [CameraProvider] using the official Flutter camera plugin.
///
/// Architectural Guarantees:
/// - Discovers available cameras and automatically targets the front-facing camera for face/gesture tracking.
/// - Gracefully falls back to any available camera if front camera is absent.
/// - Handles camera permission denial and camera-in-use errors without crashing.
/// - Bounded, single-controller lifecycle preventing memory leaks and dual-stream exceptions.
class RealCameraProvider implements CameraProvider {
  CameraController? _controller;
  final StreamController<CameraImage> _imageStreamController =
      StreamController<CameraImage>.broadcast();

  bool _isInitialized = false;
  bool _isStreaming = false;
  bool _isPermissionDenied = false;
  String? _errorMessage;
  String _lensDescription = 'Searching cameras...';
  List<CameraDescription> _availableCameras = [];
  int _activeCameraIndex = 0;

  int _frameCount = 0;
  DateTime? _lastFpsTimestamp;
  double _measuredFps = 30.0;
  int _totalFramesReceived = 0;
  bool _isDisposed = false;

  @override
  CameraController? get controller => _controller;

  @override
  bool get isInitialized => _isInitialized && _controller != null && _controller!.value.isInitialized;

  @override
  bool get isStreaming => _isStreaming;

  @override
  bool get isPermissionDenied => _isPermissionDenied;

  @override
  String? get errorMessage => _errorMessage;

  @override
  String? get errorStatus => _errorMessage;

  @override
  double get measuredFps => _measuredFps;

  @override
  int get totalFramesReceived => _totalFramesReceived;

  @override
  int get totalFramesProcessed => _totalFramesReceived;

  @override
  String get cameraLensDescription => _lensDescription;

  @override
  String get activeLensName => _lensDescription;

  @override
  List<CameraDescription> get availableCameras => List.unmodifiable(_availableCameras);

  @override
  int get activeCameraIndex => _activeCameraIndex;

  @override
  Stream<CameraImage> get imageStream => _imageStreamController.stream;

  @override
  Future<bool> initialize() async {
    if (_isInitialized && _controller != null && _controller!.value.isInitialized) {
      return true;
    }

    try {
      _availableCameras = await cam_plugin.availableCameras();
      if (_availableCameras.isEmpty) {
        _errorMessage = 'No hardware cameras found on this device.';
        _lensDescription = 'No cameras available';
        _isInitialized = false;
        return false;
      }

      // Default to front-facing camera for face & hand gesture interaction
      CameraDescription selectedCamera = _availableCameras.firstWhere(
        (cam) => cam.lensDirection == CameraLensDirection.front,
        orElse: () => _availableCameras.first,
      );

      _activeCameraIndex = _availableCameras.indexOf(selectedCamera);
      if (_activeCameraIndex < 0) _activeCameraIndex = 0;

      _lensDescription = selectedCamera.lensDirection == CameraLensDirection.front
          ? 'Front Camera (Selfie)'
          : (selectedCamera.lensDirection == CameraLensDirection.back
              ? 'Rear Camera'
              : 'External Camera');

      // Create CameraController with balanced medium resolution for real-time ~8 FPS ML inference
      _controller = CameraController(
        selectedCamera,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.yuv420,
      );

      await _controller!.initialize();
      _isInitialized = true;
      _isPermissionDenied = false;
      _errorMessage = null;

      // Automatically start image streaming
      await startImageStream();
      return true;
    } on CameraException catch (e) {
      _isInitialized = false;
      if (e.code == 'CameraAccessDenied' ||
          e.code == 'CameraAccessDeniedWithoutPrompt' ||
          e.code == 'CameraAccessRestricted') {
        _isPermissionDenied = true;
        _errorMessage = 'Camera permission denied. SensAura is operating in sensor-only mode.';
      } else {
        _errorMessage = 'Camera hardware error: ${e.description ?? e.code}';
      }
      return false;
    } catch (e) {
      _isInitialized = false;
      _errorMessage = 'Unexpected camera initialization error: $e';
      return false;
    }
  }

  @override
  Future<void> switchCamera() async {
    if (_availableCameras.length <= 1) return;
    final nextIndex = (_activeCameraIndex + 1) % _availableCameras.length;
    await stopImageStream();
    if (_controller != null) {
      await _controller!.dispose();
      _controller = null;
    }
    _activeCameraIndex = nextIndex;
    final nextCam = _availableCameras[_activeCameraIndex];
    _lensDescription = nextCam.lensDirection == CameraLensDirection.front
        ? 'Front Camera (Selfie)'
        : (nextCam.lensDirection == CameraLensDirection.back
            ? 'Rear Camera'
            : 'External Camera');
    _controller = CameraController(
      nextCam,
      ResolutionPreset.medium,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.yuv420,
    );
    try {
      await _controller!.initialize();
      _isInitialized = true;
      await startImageStream();
    } catch (e) {
      _errorMessage = 'Failed to switch camera: $e';
    }
  }

  @override
  Future<void> startImageStream() async {
    if (_controller == null || !_controller!.value.isInitialized || _isStreaming) {
      return;
    }

    try {
      _isStreaming = true;
      _lastFpsTimestamp = DateTime.now();
      _frameCount = 0;

      await _controller!.startImageStream((CameraImage image) {
        if (_isDisposed || !_isStreaming) return;

        _totalFramesReceived++;
        _frameCount++;

        // Measure live preview FPS at 1-second intervals
        final now = DateTime.now();
        if (_lastFpsTimestamp != null) {
          final elapsedMs = now.difference(_lastFpsTimestamp!).inMilliseconds;
          if (elapsedMs >= 1000) {
            _measuredFps = (_frameCount * 1000.0) / elapsedMs;
            _frameCount = 0;
            _lastFpsTimestamp = now;
          }
        }

        if (!_imageStreamController.isClosed) {
          _imageStreamController.add(image);
        }
      });
    } on CameraException catch (e) {
      _isStreaming = false;
      _errorMessage = 'Failed to start image stream: ${e.description ?? e.code}';
    } catch (e) {
      _isStreaming = false;
      _errorMessage = 'Stream error: $e';
    }
  }

  @override
  Future<void> stopImageStream() async {
    if (_controller == null || !_isStreaming) return;
    try {
      _isStreaming = false;
      if (_controller!.value.isStreamingImages) {
        await _controller!.stopImageStream();
      }
    } catch (_) {
      _isStreaming = false;
    }
  }

  @override
  Future<void> pause() async {
    await stopImageStream();
  }

  @override
  Future<void> resume() async {
    if (_isInitialized && _controller != null && _controller!.value.isInitialized) {
      await startImageStream();
    } else {
      await initialize();
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _isStreaming = false;
    _isInitialized = false;
    try {
      if (_controller != null) {
        if (_controller!.value.isStreamingImages) {
          _controller!.stopImageStream();
        }
        _controller!.dispose();
        _controller = null;
      }
    } catch (_) {}
    _imageStreamController.close();
  }
}
