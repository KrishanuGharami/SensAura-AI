import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../models/sensor_snapshot.dart';

class SensorWaveformCard extends StatefulWidget {
  final SensorSnapshot snapshot;
  final double latencyMs;
  final bool isHardware;

  const SensorWaveformCard({
    super.key,
    required this.snapshot,
    required this.latencyMs,
    required this.isHardware,
  });

  @override
  State<SensorWaveformCard> createState() => _SensorWaveformCardState();
}

class _SensorWaveformCardState extends State<SensorWaveformCard> {
  final List<double> _historyX = [];
  final List<double> _historyY = [];
  final List<double> _historyZ = [];
  static const int maxPoints = 28;

  @override
  void didUpdateWidget(covariant SensorWaveformCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.snapshot.timestamp != widget.snapshot.timestamp) {
      setState(() {
        _historyX.add(widget.snapshot.accelX);
        _historyY.add(widget.snapshot.accelY);
        _historyZ.add(widget.snapshot.accelZ);

        if (_historyX.length > maxPoints) _historyX.removeAt(0);
        if (_historyY.length > maxPoints) _historyY.removeAt(0);
        if (_historyZ.length > maxPoints) _historyZ.removeAt(0);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Status Badge + Latency
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.statusLocal,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'ON-DEVICE PROCESSING',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                      color: AppColors.emeraldGreen,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.cardSurfaceElevated,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppColors.borderSubtle),
                ),
                child: Text(
                  widget.isHardware ? 'HARDWARE SENSORS' : 'SIMULATED / LOCAL',
                  style: const TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Waveform Canvas
          SizedBox(
            height: 90,
            width: double.infinity,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Container(
                color: AppColors.backgroundSecondary,
                child: CustomPaint(
                  painter: _WaveformPainter(
                    historyX: _historyX,
                    historyY: _historyY,
                    historyZ: _historyZ,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Axis legend + real-time values
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildAxisChip('X', widget.snapshot.accelX, AppColors.primaryAmber),
              _buildAxisChip('Y', widget.snapshot.accelY, AppColors.cyberCyan),
              _buildAxisChip('Z', widget.snapshot.accelZ, AppColors.electricViolet),
              _buildMetricChip(
                'MAG',
                '${widget.snapshot.accelMagnitude.toStringAsFixed(1)} m/s²',
                AppColors.textHighlight,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAxisChip(String axis, double value, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(
          '$axis: ${value.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricChip(String label, String value, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$label: ',
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: AppColors.textMuted,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _WaveformPainter extends CustomPainter {
  final List<double> historyX;
  final List<double> historyY;
  final List<double> historyZ;

  _WaveformPainter({
    required this.historyX,
    required this.historyY,
    required this.historyZ,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Grid lines
    final gridPaint = Paint()
      ..color = AppColors.borderSubtle.withValues(alpha: 0.5)
      ..strokeWidth = 0.6;

    final centerY = size.height / 2;
    canvas.drawLine(Offset(0, centerY), Offset(size.width, centerY), gridPaint);
    canvas.drawLine(Offset(0, centerY / 2), Offset(size.width, centerY / 2), gridPaint);
    canvas.drawLine(Offset(0, centerY * 1.5), Offset(size.width, centerY * 1.5), gridPaint);

    if (historyX.isEmpty) return;

    _drawLine(canvas, size, historyX, AppColors.primaryAmber, scale: 3.5);
    _drawLine(canvas, size, historyY, AppColors.cyberCyan, scale: 3.5);
    _drawLine(canvas, size, historyZ, AppColors.electricViolet, scale: 3.5, offsetBias: -9.81);
  }

  void _drawLine(
    Canvas canvas,
    Size size,
    List<double> points,
    Color color, {
    double scale = 4.0,
    double offsetBias = 0.0,
  }) {
    if (points.length < 2) return;

    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    final stepX = size.width / (_SensorWaveformCardState.maxPoints - 1);
    final centerY = size.height / 2;

    for (int i = 0; i < points.length; i++) {
      final x = i * stepX;
      final val = points[i] + offsetBias;
      final y = (centerY - (val * scale)).clamp(4.0, size.height - 4.0);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _WaveformPainter oldDelegate) => true;
}
