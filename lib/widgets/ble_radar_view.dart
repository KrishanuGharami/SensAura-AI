import 'dart:math';
import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../services/ble_provider.dart';

class BleRadarView extends StatefulWidget {
  final List<BleDeviceInfo> devices;

  const BleRadarView({super.key, required this.devices});

  @override
  State<BleRadarView> createState() => _BleRadarViewState();
}

class _BleRadarViewState extends State<BleRadarView> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.bluetooth_searching_rounded, size: 16, color: AppColors.electricViolet),
                  SizedBox(width: 8),
                  Text(
                    'BLE SPATIAL RADAR',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                      color: AppColors.electricViolet,
                    ),
                  ),
                ],
              ),
              Text(
                '${widget.devices.length} Beacons Active',
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Radar circle display
          SizedBox(
            height: 140,
            width: double.infinity,
            child: AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                return CustomPaint(
                  painter: _RadarPainter(
                    pulseValue: _pulseController.value,
                    devices: widget.devices,
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 12),

          // List of detected devices
          Column(
            children: widget.devices.map((device) {
              return Container(
                margin: const EdgeInsets.only(bottom: 6),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.cardSurfaceElevated,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: device.isHomeBeacon
                        ? AppColors.primaryAmber.withValues(alpha: 0.4)
                        : AppColors.borderSubtle,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      device.isHomeBeacon ? Icons.home_mini_rounded : Icons.device_hub_rounded,
                      size: 14,
                      color: device.isHomeBeacon ? AppColors.primaryAmber : AppColors.cyberCyan,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        device.name,
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: device.isHomeBeacon ? FontWeight.w700 : FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      '${device.rssi} dBm',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textMuted,
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
}

class _RadarPainter extends CustomPainter {
  final double pulseValue;
  final List<BleDeviceInfo> devices;

  _RadarPainter({required this.pulseValue, required this.devices});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = min(size.width / 2, size.height / 2) - 10;

    // Background concentric rings
    final ringPaint = Paint()
      ..color = AppColors.borderSubtle.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    for (int i = 1; i <= 3; i++) {
      canvas.drawCircle(center, maxRadius * (i / 3), ringPaint);
    }

    // Expanding pulse wave
    final pulseRadius = maxRadius * pulseValue;
    final pulsePaint = Paint()
      ..color = AppColors.electricViolet.withValues(alpha: (1.0 - pulseValue) * 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(center, pulseRadius, pulsePaint);

    // Center phone node
    final centerPaint = Paint()..color = AppColors.cyberCyan;
    canvas.drawCircle(center, 4.5, centerPaint);

    // Render device blips based on RSSI
    for (int i = 0; i < devices.length; i++) {
      final device = devices[i];
      // RSSI map: -40 dBm close to center, -90 dBm at perimeter
      final normalizedDist = ((device.rssi + 40).abs() / 50.0).clamp(0.2, 0.95);
      final angle = (i * (2 * pi / max(1, devices.length))) - (pi / 2);

      final blipX = center.dx + cos(angle) * (maxRadius * normalizedDist);
      final blipY = center.dy + sin(angle) * (maxRadius * normalizedDist);

      final blipPaint = Paint()
        ..color = device.isHomeBeacon ? AppColors.primaryAmber : AppColors.electricViolet;

      canvas.drawCircle(Offset(blipX, blipY), device.isHomeBeacon ? 5.5 : 4.0, blipPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _RadarPainter oldDelegate) => true;
}
