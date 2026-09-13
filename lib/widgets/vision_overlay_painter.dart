import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../models/pose_feature_snapshot.dart';
import '../models/vision_context_sample.dart';

/// Custom painter for rendering on-device MediaPipe vision HUD overlays:
/// - Face landmarks wireframe & bounding box
/// - Hand gesture tracking box & gesture badge
/// - Pose skeleton wireframe (torso, spine, shoulders)
class VisionOverlayPainter extends CustomPainter {
  final VisionContextSample sample;
  final bool showOverlay;
  final double animationValue;

  VisionOverlayPainter({
    required this.sample,
    required this.showOverlay,
    this.animationValue = 1.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (!showOverlay) return;

    final w = size.width;
    final h = size.height;

    // 1. Draw Corner HUD Brackets
    _drawHudBrackets(canvas, size);

    // 2. Draw Face Mesh / Landmarks if face detected
    if (sample.faceDetected) {
      _drawFaceOverlay(canvas, Rect.fromCenter(
        center: Offset(w * 0.5, h * 0.38),
        width: w * 0.32,
        height: h * 0.36,
      ));
    }

    // 3. Draw Hand Gesture Tracking Box if hand detected
    if (sample.gesture != HandGesture.none) {
      _drawHandOverlay(canvas, Rect.fromLTWH(
        w * 0.65,
        h * 0.45,
        w * 0.28,
        h * 0.32,
      ));
    }

    // 4. Draw Posture Skeleton
    if (sample.posture != ObservablePosture.unknown) {
      _drawPoseSkeleton(canvas, size);
    }
  }

  void _drawHudBrackets(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.cyberCyan.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    const len = 22.0;
    const pad = 14.0;
    final w = size.width;
    final h = size.height;

    // Top-Left
    canvas.drawLine(const Offset(pad, pad), const Offset(pad + len, pad), paint);
    canvas.drawLine(const Offset(pad, pad), const Offset(pad, pad + len), paint);

    // Top-Right
    canvas.drawLine(Offset(w - pad, pad), Offset(w - pad - len, pad), paint);
    canvas.drawLine(Offset(w - pad, pad), Offset(w - pad, pad + len), paint);

    // Bottom-Left
    canvas.drawLine(Offset(pad, h - pad), Offset(pad + len, h - pad), paint);
    canvas.drawLine(Offset(pad, h - pad), Offset(pad, h - pad - len), paint);

    // Bottom-Right
    canvas.drawLine(Offset(w - pad, h - pad), Offset(w - pad - len, h - pad), paint);
    canvas.drawLine(Offset(w - pad, h - pad), Offset(w - pad, h - pad - len), paint);

    // Center Crosshair
    final crossPaint = Paint()
      ..color = AppColors.cyberCyan.withValues(alpha: 0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawLine(Offset(w / 2 - 12, h / 2), Offset(w / 2 + 12, h / 2), crossPaint);
    canvas.drawLine(Offset(w / 2, h / 2 - 12), Offset(w / 2, h / 2 + 12), crossPaint);
  }

  void _drawFaceOverlay(Canvas canvas, Rect faceRect) {
    final boxPaint = Paint()
      ..color = AppColors.cyberCyan.withValues(alpha: 0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // Face oval
    canvas.drawOval(faceRect, boxPaint);

    // Landmarks simulation points
    final dotPaint = Paint()
      ..color = AppColors.emeraldGreen.withValues(alpha: 0.85)
      ..style = PaintingStyle.fill;

    final cx = faceRect.center.dx;
    final cy = faceRect.center.dy;
    final rw = faceRect.width / 2;
    final rh = faceRect.height / 2;

    // Eyes
    canvas.drawCircle(Offset(cx - rw * 0.35, cy - rh * 0.15), 3, dotPaint);
    canvas.drawCircle(Offset(cx + rw * 0.35, cy - rh * 0.15), 3, dotPaint);

    // Eye contour / brows
    final browPaint = Paint()
      ..color = AppColors.emeraldGreen.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawLine(
      Offset(cx - rw * 0.55, cy - rh * 0.3),
      Offset(cx - rw * 0.15, cy - rh * 0.3),
      browPaint,
    );
    canvas.drawLine(
      Offset(cx + rw * 0.15, cy - rh * 0.3),
      Offset(cx + rw * 0.55, cy - rh * 0.3),
      browPaint,
    );

    // Nose bridge
    canvas.drawCircle(Offset(cx, cy + rh * 0.05), 2.5, dotPaint);

    // Mouth
    final mouthPaint = Paint()
      ..color = AppColors.primaryAmber.withValues(alpha: 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final mouthY = cy + rh * 0.45;
    if (sample.expressionSignal == VisibleExpressionSignal.positive) {
      // Smile curve
      final path = Path()
        ..moveTo(cx - rw * 0.3, mouthY)
        ..quadraticBezierTo(cx, mouthY + 8, cx + rw * 0.3, mouthY);
      canvas.drawPath(path, mouthPaint);
    } else {
      // Neutral line
      canvas.drawLine(Offset(cx - rw * 0.25, mouthY), Offset(cx + rw * 0.25, mouthY), mouthPaint);
    }

    // Label
    _drawText(
      canvas,
      'FACE: ${sample.expressionSignal.displayName.toUpperCase()} (${(sample.expressionConfidence * 100).toInt()}%)',
      Offset(faceRect.left, faceRect.top - 16),
      AppColors.cyberCyan,
    );
  }

  void _drawHandOverlay(Canvas canvas, Rect handRect) {
    final boxPaint = Paint()
      ..color = AppColors.primaryAmber.withValues(alpha: 0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8;

    canvas.drawRRect(
      RRect.fromRectAndRadius(handRect, const Radius.circular(8)),
      boxPaint,
    );

    // Key points for fingers
    final dotPaint = Paint()
      ..color = AppColors.primaryAmber
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 5; i++) {
      final fx = handRect.left + (handRect.width / 6) * (i + 1);
      final fy = handRect.top + 8;
      canvas.drawCircle(Offset(fx, fy), 2.5, dotPaint);
    }

    // Label
    _drawText(
      canvas,
      '${sample.gesture.displayName.toUpperCase()} (${(sample.gestureConfidence * 100).toInt()}%)',
      Offset(handRect.left, handRect.top - 16),
      AppColors.primaryAmber,
    );
  }

  void _drawPoseSkeleton(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final linePaint = Paint()
      ..color = AppColors.cyberCyan.withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final jointPaint = Paint()
      ..color = AppColors.cyberCyan.withValues(alpha: 0.7)
      ..style = PaintingStyle.fill;

    final head = Offset(w * 0.5, h * 0.38);
    final neck = Offset(w * 0.5, h * 0.58);
    final leftShoulder = Offset(w * 0.32, h * 0.62);
    final rightShoulder = Offset(w * 0.68, h * 0.62);
    final spine = Offset(w * 0.5, h * 0.88);

    // Spine and shoulders
    canvas.drawLine(head, neck, linePaint);
    canvas.drawLine(neck, spine, linePaint);
    canvas.drawLine(neck, leftShoulder, linePaint);
    canvas.drawLine(neck, rightShoulder, linePaint);

    // Joints
    for (final pt in [neck, leftShoulder, rightShoulder, spine]) {
      canvas.drawCircle(pt, 3.5, jointPaint);
    }

    _drawText(
      canvas,
      'POSE: ${sample.posture.displayName.toUpperCase()}',
      Offset(w * 0.05, h * 0.92),
      AppColors.textSecondary,
    );
  }

  void _drawText(Canvas canvas, String text, Offset offset, Color color) {
    final textSpan = TextSpan(
      text: text,
      style: TextStyle(
        color: color,
        fontSize: 9.5,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.5,
        backgroundColor: Colors.black.withValues(alpha: 0.7),
      ),
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant VisionOverlayPainter oldDelegate) {
    return oldDelegate.sample != sample ||
        oldDelegate.showOverlay != showOverlay ||
        oldDelegate.animationValue != animationValue;
  }
}
