import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../l10n/app_localizations.dart';
import '../models/automation_scene.dart';
import '../models/context_guard_result.dart';
import '../models/context_result.dart';
import '../models/pose_feature_snapshot.dart';
import '../models/vision_context_sample.dart';
import '../services/real_camera_provider.dart';
import '../widgets/confidence_gauge.dart';
import '../widgets/vision_overlay_painter.dart';

class AiContextScreen extends StatefulWidget {
  final ContextResult result;
  final VisionContextSample visionSample;
  final CameraProvider? cameraProvider;
  final bool isAutomationPaused;
  final bool isApplyingScene;
  final ValueChanged<AutomationScene> onApplyScene;
  final VoidCallback onPauseAutomation;
  final VoidCallback onResumeAutomation;
  final ValueChanged<HandGesture>? onInjectGesture;

  const AiContextScreen({
    super.key,
    required this.result,
    required this.visionSample,
    this.cameraProvider,
    required this.isAutomationPaused,
    required this.isApplyingScene,
    required this.onApplyScene,
    required this.onPauseAutomation,
    required this.onResumeAutomation,
    this.onInjectGesture,
  });

  @override
  State<AiContextScreen> createState() => _AiContextScreenState();
}

class _AiContextScreenState extends State<AiContextScreen>
    with SingleTickerProviderStateMixin {
  bool _showAiOverlay = true;
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final contextType = widget.result.context;
    final accentColor = contextType.color;
    final scene = widget.result.recommendedScene;
    final vision = widget.visionSample;
    final guard = widget.result.guardResult;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. VISION & CAMERA VIEWPORT CARD
          _buildVisionViewport(accentColor, vision),

          const SizedBox(height: 16),

          // 2. CONTEXT GUARD SAFETY ALERT (IF PAUSED OR CONFLICT)
          if (widget.isAutomationPaused)
            _buildPauseBanner()
          else if (guard.hasConflictingSignals)
            _buildConflictBanner(),

          // 3. CURRENT INFERENCE HERO BLOCK
          _buildInferenceHero(contextType, accentColor, guard),

          const SizedBox(height: 16),

          // 4. VISION & MULTIMODAL TELEMETRY GRID
          _buildVisionTelemetryGrid(vision),

          const SizedBox(height: 16),

          // 5. JURY GESTURE DEMO / MANUAL TRIGGER PALETTE
          _buildGestureDemoPalette(),

          const SizedBox(height: 16),

          // 6. LOCAL REASONING & MULTIMODAL FUSION
          _buildReasoningCard(),

          const SizedBox(height: 16),

          // 7. RECOMMENDED AUTOMATION & ACTION CTA
          _buildActionCta(scene),

          const SizedBox(height: 16),

          // 8. PRIVACY & ARCHITECTURE GUARANTEE STRIP
          _buildPrivacyStrip(),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildVisionViewport(Color accentColor, VisionContextSample vision) {
    final l10n = AppLocalizations.of(context);
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF0A0E17),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.cyberCyan.withValues(alpha: 0.4),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.cyberCyan.withValues(alpha: 0.08),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          children: [
            // Viewport Top Control Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              color: Colors.black.withValues(alpha: 0.6),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: widget.cameraProvider?.isInitialized == true
                          ? AppColors.emeraldGreen
                          : AppColors.primaryAmber,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    widget.cameraProvider?.isInitialized == true
                        ? '${l10n?.cameraHardwareActive ?? "CAMERA: LIVE iQOO"} (${widget.cameraProvider!.activeLensName.toUpperCase()})'
                        : (l10n?.cameraSensorOnly ?? 'CAMERA: SENSOR-ONLY MODE'),
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (widget.cameraProvider != null &&
                      widget.cameraProvider!.availableCameras.length > 1) ...[
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: () async {
                        await widget.cameraProvider!.switchCamera();
                        if (mounted) setState(() {});
                      },
                      borderRadius: BorderRadius.circular(4),
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Icon(
                          Icons.flip_camera_android_rounded,
                          size: 14,
                          color: AppColors.cyberCyan,
                        ),
                      ),
                    ),
                  ],
                  if (widget.cameraProvider != null &&
                      !widget.cameraProvider!.isInitialized) ...[
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: () async {
                        await widget.cameraProvider!.initialize();
                        if (mounted) setState(() {});
                      },
                      borderRadius: BorderRadius.circular(4),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primaryAmber.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: AppColors.primaryAmber.withValues(alpha: 0.5),
                          ),
                        ),
                        child: Text(
                          l10n?.cameraRetry ?? 'RETRY',
                          style: const TextStyle(
                            fontSize: 8.5,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryAmber,
                          ),
                        ),
                      ),
                    ),
                  ],
                  const Spacer(),
                  // Honest AI Runtime Badge
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: vision.runtimeBackend.color.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color:
                            vision.runtimeBackend.color.withValues(alpha: 0.5),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      'AI RUNTIME: ${vision.runtimeBackend.displayName.toUpperCase()}',
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.6,
                        color: vision.runtimeBackend.color,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Main Visual Surface with Live Camera Preview + Custom Painter
            SizedBox(
              height: 220,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // 1. Live Camera Preview Layer (if available) or Dark Gradient Grid
                  if (widget.cameraProvider?.isInitialized == true &&
                      widget.cameraProvider?.controller != null &&
                      widget.cameraProvider!.controller!.value.isInitialized) ...[
                    ClipRect(
                      child: OverflowBox(
                        alignment: Alignment.center,
                        child: FittedBox(
                          fit: BoxFit.cover,
                          child: SizedBox(
                            width: 100,
                            height: 100 *
                                (widget.cameraProvider!.controller!.value
                                            .aspectRatio >
                                        0
                                    ? widget.cameraProvider!.controller!.value
                                        .aspectRatio
                                    : 1.333),
                            child: CameraPreview(
                                widget.cameraProvider!.controller!),
                          ),
                        ),
                      ),
                    ),
                    // High-contrast semi-transparent overlay for neon HUD elements
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.35),
                        ),
                      ),
                    ),
                  ] else ...[
                    // Fallback graceful degradation: Sensor-only cybernetic surface
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: RadialGradient(
                            center: Alignment.center,
                            radius: 0.9,
                            colors: [
                              AppColors.cyberCyan.withValues(alpha: 0.07),
                              const Color(0xFF06090F),
                            ],
                          ),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.videocam_off_rounded,
                                size: 38,
                                color: AppColors.textTertiary
                                    .withValues(alpha: 0.6),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                l10n?.cameraUnavailable ?? 'CAMERA UNAVAILABLE — SENSOR-ONLY MODE',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.8,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                widget.cameraProvider?.errorStatus ??
                                    'Operating securely on IMU, light & acoustic telemetry',
                                style: const TextStyle(
                                  fontSize: 9.5,
                                  color: AppColors.textTertiary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],

                  // 2. Vision Overlay Painter (Face landmarks, hand gesture box, pose skeleton)
                  AnimatedBuilder(
                    animation: _animController,
                    builder: (context, _) {
                      return CustomPaint(
                        painter: VisionOverlayPainter(
                          sample: vision,
                          showOverlay: _showAiOverlay,
                          animationValue: _animController.value,
                        ),
                      );
                    },
                  ),

                  // 3. Cadence and Latency Telemetry overlay
                  Positioned(
                    bottom: 8,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.75),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.1),
                        ),
                      ),
                      child: Text(
                        '${(widget.cameraProvider?.measuredFps ?? vision.fps).toStringAsFixed(0)} CAM FPS  •  ${vision.fps.toStringAsFixed(0)} AI FPS  •  ${vision.inferenceLatencyMs.toStringAsFixed(1)}ms  •  ${vision.droppedFrames} DROPPED',
                        style: const TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: AppColors.cyberCyan,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),

                  // 4. Overlay Toggle Button
                  Positioned(
                    bottom: 8,
                    right: 12,
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _showAiOverlay = !_showAiOverlay;
                        });
                      },
                      borderRadius: BorderRadius.circular(6),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: _showAiOverlay
                              ? AppColors.cyberCyan.withValues(alpha: 0.25)
                              : Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: _showAiOverlay
                                ? AppColors.cyberCyan
                                : AppColors.borderSubtle,
                            width: 1,
                          ),
                        ),
                        child: Text(
                          _showAiOverlay
                              ? (l10n?.hideAiOverlay ?? 'HIDE AI OVERLAY')
                              : (l10n?.showAiOverlay ?? 'SHOW AI OVERLAY'),
                          style: TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                            color: _showAiOverlay
                                ? AppColors.cyberCyan
                                : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPauseBanner() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryAmber.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primaryAmber, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.pan_tool_rounded,
                  color: AppColors.primaryAmber, size: 20),
              SizedBox(width: 8),
              Text(
                'AUTOMATION PAUSED BY USER GESTURE',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                  color: AppColors.primaryAmber,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'SensAura detected an Open Palm (✋) gesture. All automated adjustments are frozen until you manually resume.',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textPrimary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 40,
            child: ElevatedButton.icon(
              onPressed: widget.onResumeAutomation,
              icon: const Icon(Icons.play_arrow_rounded, size: 18),
              label: const Text(
                'RESUME AUTOMATION',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.6,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.emeraldGreen,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConflictBanner() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.dangerRed.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.dangerRed, width: 1.5),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.shield_outlined,
                  color: AppColors.dangerRed, size: 20),
              SizedBox(width: 8),
              Text(
                'CONTEXT GUARD: CONFLICTING SIGNALS',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                  color: AppColors.dangerRed,
                ),
              ),
            ],
          ),
          SizedBox(height: 6),
          Text(
            'Vision and physical sensor signals disagree. Environment preserved with NO_ACTION to prevent jarring workspace disruptions.',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textPrimary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInferenceHero(
      dynamic contextType, Color accentColor, ContextGuardResult guard) {
    final l10n = AppLocalizations.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.35),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: 0.1),
            blurRadius: 16,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'FUSED AMBIENT CONTEXT',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                    color: accentColor,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: guard.decision.badgeColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: guard.decision.badgeColor.withValues(alpha: 0.4),
                  ),
                ),
                child: Text(
                  'GUARD: ${guard.decision.getLocalizedUserBadge(l10n)}',
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                    color: guard.decision.badgeColor,
                    letterSpacing: 0.6,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      contextType.getLocalizedName(l10n).toUpperCase(),
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Multimodal: Sensors + Vision + Gestures',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              ConfidenceGauge(
                confidence: widget.result.confidence,
                primaryColor: accentColor,
                size: 76,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVisionTelemetryGrid(VisionContextSample vision) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.visibility_rounded,
                  size: 16, color: AppColors.cyberCyan),
              SizedBox(width: 8),
              Text(
                'VISION TELEMETRY & SIGNALS',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                  color: AppColors.cyberCyan,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _buildTelemetryCell(
                  label: 'FACE TRACKING',
                  value: vision.faceDetected
                      ? 'DETECTED (${(vision.faceLandmarkCount)} PTS)'
                      : 'NOT IN FRAME',
                  color: vision.faceDetected
                      ? AppColors.emeraldGreen
                      : AppColors.textMuted,
                  icon: Icons.face_rounded,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildTelemetryCell(
                  label: 'OBSERVED GESTURE',
                  value: vision.gesture == HandGesture.none
                      ? 'NONE'
                      : '${vision.gesture.symbol} ${vision.gesture.displayName.toUpperCase()}',
                  color: vision.gesture != HandGesture.none
                      ? AppColors.primaryAmber
                      : AppColors.textMuted,
                  icon: Icons.front_hand_rounded,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildTelemetryCell(
                  label: 'OBSERVED POSTURE',
                  value: vision.posture.displayName.toUpperCase(),
                  color: vision.posture == ObservablePosture.seated
                      ? AppColors.cyberCyan
                      : AppColors.textPrimary,
                  icon: Icons.chair_rounded,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildTelemetryCell(
                  label: 'EXPRESSION SIGNAL',
                  value: vision.expressionSignal.displayName.toUpperCase(),
                  color: AppColors.cyberCyan,
                  icon: Icons.mood_rounded,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            '* Facial signals reflect observable geometric features (e.g. eye openness, mouth curvature), not psychological ground truth.',
            style: TextStyle(
              fontSize: 10,
              fontStyle: FontStyle.italic,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTelemetryCell({
    required String label,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.cardSurfaceElevated,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGestureDemoPalette() {
    final l10n = AppLocalizations.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.touch_app_rounded,
                  size: 16, color: AppColors.primaryAmber),
              SizedBox(width: 8),
              Text(
                'TEST GESTURE INTENTS (OFFLINE DEMO / BENCHMARK)',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                  color: AppColors.primaryAmber,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Tap a gesture below to trigger it deterministically or demonstrate priority overrides:',
            style: TextStyle(
              fontSize: 11.5,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildGestureChip(
                gesture: HandGesture.openPalm,
                label: '✋ ${l10n?.gestureOpenPalm.split('(').first.trim() ?? "Pause Automation"}',
                color: AppColors.primaryAmber,
              ),
              _buildGestureChip(
                gesture: HandGesture.thumbUp,
                label: '👍 ${l10n?.gestureThumbUp.split('(').first.trim() ?? "Confirm Scene"}',
                color: AppColors.emeraldGreen,
              ),
              _buildGestureChip(
                gesture: HandGesture.thumbDown,
                label: '👎 ${l10n?.gestureThumbDown.split('(').first.trim() ?? "Dismiss Scene"}',
                color: AppColors.dangerRed,
              ),
              _buildGestureChip(
                gesture: HandGesture.victory,
                label: '✌️ ${l10n?.gestureVictory.split('(').first.trim() ?? "Focus Mode"}',
                color: AppColors.cyberCyan,
              ),
              _buildGestureChip(
                gesture: HandGesture.closedFist,
                label: '✊ ${l10n?.gestureClosedFist.split('(').first.trim() ?? "Quiet / Rest"}',
                color: Colors.deepPurpleAccent,
              ),
              _buildGestureChip(
                gesture: HandGesture.none,
                label: '🔄 ${l10n?.gestureNone ?? "Clear Gesture"}',
                color: AppColors.textMuted,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGestureChip({
    required HandGesture gesture,
    required String label,
    required Color color,
  }) {
    final isSelected = widget.visionSample.gesture == gesture;
    return InkWell(
      onTap: () {
        if (widget.onInjectGesture != null) {
          widget.onInjectGesture!(gesture);
        }
      },
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withValues(alpha: 0.25)
              : AppColors.cardSurfaceElevated,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? color : AppColors.borderSubtle,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            color: isSelected ? color : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }

  Widget _buildReasoningCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.psychology_rounded,
                  size: 16, color: AppColors.cyberCyan),
              SizedBox(width: 8),
              Text(
                'LOCAL MULTIMODAL REASONING',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                  color: AppColors.cyberCyan,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            '"${widget.result.reasoning}"',
            style: const TextStyle(
              fontSize: 13.5,
              fontStyle: FontStyle.italic,
              height: 1.5,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          // Signals Breakdown
          Column(
            children: widget.result.detectedSignals.map((signal) {
              return Container(
                margin: const EdgeInsets.only(bottom: 6),
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.cardSurfaceElevated,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_rounded,
                        size: 14, color: AppColors.emeraldGreen),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        signal,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCta(AutomationScene scene) {
    final l10n = AppLocalizations.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n?.recommendedAutomation ?? 'RECOMMENDED AUTOMATION',
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
              color: AppColors.primaryAmber,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            scene.title.toUpperCase(),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            scene.description,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              // Pause / Resume Button
              Expanded(
                flex: 2,
                child: SizedBox(
                  height: 48,
                  child: OutlinedButton.icon(
                    onPressed: widget.isAutomationPaused
                        ? widget.onResumeAutomation
                        : widget.onPauseAutomation,
                    icon: Icon(
                      widget.isAutomationPaused
                          ? Icons.play_arrow_rounded
                          : Icons.pan_tool_rounded,
                      size: 18,
                    ),
                    label: Text(
                      widget.isAutomationPaused
                          ? (l10n?.resumeAutomation ?? 'RESUME')
                          : (l10n?.pauseAutomation ?? 'PAUSE (✋)'),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.6,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: widget.isAutomationPaused
                          ? AppColors.emeraldGreen
                          : AppColors.primaryAmber,
                      side: BorderSide(
                        color: widget.isAutomationPaused
                            ? AppColors.emeraldGreen
                            : AppColors.primaryAmber,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // Apply / Confirm Scene Button
              Expanded(
                flex: 3,
                child: SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: widget.isApplyingScene
                        ? null
                        : () => widget.onApplyScene(scene),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryAmber,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: widget.isApplyingScene
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            'APPLY / 👍 CONFIRM',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.8,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacyStrip() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.cardSurfaceElevated,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: const Row(
        children: [
          Icon(Icons.shield_rounded, size: 16, color: AppColors.emeraldGreen),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Zero Cloud Transmission: No raw camera frames stored or uploaded. Face landmarks, postures, and gestures processed strictly on-device at ~8 FPS.',
              style: TextStyle(
                fontSize: 10.5,
                color: AppColors.textSecondary,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
