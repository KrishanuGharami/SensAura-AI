import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../models/sensor_snapshot.dart';
import '../services/ble_provider.dart';
import '../widgets/ble_radar_view.dart';
import '../widgets/sensor_waveform_card.dart';

class LiveSensorsScreen extends StatelessWidget {
  final SensorSnapshot snapshot;
  final List<BleDeviceInfo> bleDevices;
  final double latencyMs;
  final bool isHardware;
  final ValueChanged<bool> onToggleHardware;

  const LiveSensorsScreen({
    super.key,
    required this.snapshot,
    required this.bleDevices,
    required this.latencyMs,
    required this.isHardware,
    required this.onToggleHardware,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Source switcher banner
          _buildHardwareToggleBanner(),

          const SizedBox(height: 14),

          // 1. Accelerometer 3-Axis Live Waveform
          SensorWaveformCard(
            snapshot: snapshot,
            latencyMs: latencyMs,
            isHardware: isHardware,
          ),

          const SizedBox(height: 14),

          // 2. Ambient Light & Proximity Dual Grid
          Row(
            children: [
              Expanded(child: _buildLightCard()),
              const SizedBox(width: 12),
              Expanded(child: _buildProximityCard()),
            ],
          ),

          const SizedBox(height: 14),

          // 3. BLE Spatial Radar & Beacon List
          BleRadarView(devices: bleDevices),

          const SizedBox(height: 14),

          // 4. On-Device Edge Processing Telemetry
          _buildEdgeTelemetryCard(),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildHardwareToggleBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                isHardware ? Icons.developer_board_rounded : Icons.science_rounded,
                size: 18,
                color: isHardware ? AppColors.emeraldGreen : AppColors.primaryAmber,
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isHardware ? 'Hardware Sensors Active' : 'Simulation Engine Active',
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    isHardware
                        ? 'Using on-board IMU & Bluetooth radio'
                        : 'Feeding deterministic live test telemetry',
                    style: const TextStyle(
                      fontSize: 10.5,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Switch(
            value: isHardware,
            onChanged: onToggleHardware,
            activeThumbColor: AppColors.emeraldGreen,
            activeTrackColor: AppColors.emeraldGreen.withValues(alpha: 0.3),
          ),
        ],
      ),
    );
  }

  Widget _buildLightCard() {
    final lux = snapshot.lightLux;
    final isDim = lux < 35.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'AMBIENT LIGHT',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                  color: AppColors.warmGold,
                ),
              ),
              Icon(
                isDim ? Icons.nightlight_round : Icons.wb_sunny_rounded,
                size: 16,
                color: AppColors.warmGold,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            lux.toStringAsFixed(0),
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              color: AppColors.textHighlight,
              letterSpacing: -0.5,
            ),
          ),
          const Text(
            'lux illumination',
            style: TextStyle(fontSize: 10, color: AppColors.textMuted),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: isDim
                  ? AppColors.primaryAmber.withValues(alpha: 0.15)
                  : AppColors.cyberCyan.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              isDim ? 'DIM / EVENING' : 'DAY / WORKSPACE',
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: isDim ? AppColors.primaryAmber : AppColors.cyberCyan,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProximityCard() {
    final isNear = snapshot.proximityNear;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'PROXIMITY',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                  color: AppColors.cyberCyan,
                ),
              ),
              Icon(Icons.sensors_rounded, size: 16, color: AppColors.cyberCyan),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            isNear ? 'NEAR' : 'FAR',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              color: isNear ? AppColors.emeraldGreen : AppColors.textSecondary,
              letterSpacing: -0.5,
            ),
          ),
          Text(
            isNear ? '< 5 cm (Obstructed)' : '> 15 cm (Open air)',
            style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: isNear
                  ? AppColors.emeraldGreen.withValues(alpha: 0.15)
                  : AppColors.cardSurfaceElevated,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              isNear ? 'FACE DOWN / COUCH' : 'DESK / IN HAND',
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: isNear ? AppColors.emeraldGreen : AppColors.textMuted,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEdgeTelemetryCard() {
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
          const Row(
            children: [
              Icon(Icons.memory_rounded, size: 16, color: AppColors.cyberCyan),
              SizedBox(width: 8),
              Text(
                'ON-DEVICE ENGINE PERFORMANCE',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                  color: AppColors.cyberCyan,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildMetricTile(
                  'INFERENCE LATENCY',
                  '${latencyMs.toStringAsFixed(1)} ms',
                  'Sub-2ms target met',
                  AppColors.emeraldGreen,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildMetricTile(
                  'CLOUD ROUNDTRIP',
                  '0.0 ms',
                  '100% Offline processing',
                  AppColors.cyberCyan,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricTile(String title, String value, String subtext, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cardSurfaceElevated,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          Text(
            subtext,
            style: const TextStyle(
              fontSize: 9.5,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
