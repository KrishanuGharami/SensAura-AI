import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../l10n/app_localizations.dart';
import '../models/sensor_snapshot.dart';
import '../services/ble_provider.dart';
import '../widgets/ble_radar_view.dart';
import '../widgets/sensor_waveform_card.dart';

class LiveSensorsScreen extends StatelessWidget {
  final SensorSnapshot snapshot;
  final List<BleDeviceInfo> bleDevices;
  final double latencyMs;
  final bool isHardware;
  final bool hardwareAvailable;
  final ValueChanged<bool> onToggleHardware;

  const LiveSensorsScreen({
    super.key,
    required this.snapshot,
    required this.bleDevices,
    required this.latencyMs,
    required this.isHardware,
    required this.hardwareAvailable,
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
          // 0. Hardware Mode Banner
          _buildHardwareToggleBanner(context),

          const SizedBox(height: 14),

          // 1. Hardware Silicon Availability Strip
          _buildHardwareStatusStrip(),

          const SizedBox(height: 14),

          // 2. Accelerometer 3-Axis Live Waveform
          SensorWaveformCard(
            snapshot: snapshot,
            latencyMs: latencyMs,
            isHardware: isHardware && hardwareAvailable,
          ),

          const SizedBox(height: 14),

          // 3. Gyroscope 3-Axis Angular Velocity Card
          _buildGyroscopeCard(),

          const SizedBox(height: 14),

          // 4. Ambient Light & Proximity Dual Grid
          Row(
            children: [
              Expanded(child: _buildLightCard(context)),
              const SizedBox(width: 12),
              Expanded(child: _buildProximityCard(context)),
            ],
          ),

          const SizedBox(height: 14),

          // 5. BLE Spatial Radar & Beacon List
          BleRadarView(devices: bleDevices),

          const SizedBox(height: 14),

          // 6. On-Device Edge Processing Telemetry
          _buildEdgeTelemetryCard(),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildHardwareToggleBanner(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final liveHardwareAvailable = isHardware && hardwareAvailable;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: liveHardwareAvailable
              ? AppColors.emeraldGreen.withValues(alpha: 0.4)
              : AppColors.primaryAmber.withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                liveHardwareAvailable
                    ? Icons.developer_board_rounded
                    : Icons.science_rounded,
                size: 18,
                color: liveHardwareAvailable
                    ? AppColors.emeraldGreen
                    : AppColors.primaryAmber,
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    liveHardwareAvailable
                        ? '${l10n?.liveHardware ?? "LIVE HARDWARE"} (iQOO 15)'
                        : isHardware
                            ? '${l10n?.liveHardware ?? "LIVE HARDWARE"} (${l10n?.stateUnavailable ?? "UNAVAILABLE"})'
                            : '${l10n?.demoSimulation ?? "DEMO SIMULATION"} (Dev Tool)',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: liveHardwareAvailable
                          ? AppColors.emeraldGreen
                          : AppColors.primaryAmber,
                    ),
                  ),
                  Text(
                    liveHardwareAvailable
                        ? 'Direct silicon sensor streams active'
                        : isHardware
                            ? 'No supported sensor telemetry detected'
                            : 'Virtual physics scenario modeler',
                    style: const TextStyle(fontSize: 10.5, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ],
          ),
          Switch.adaptive(
            value: isHardware,
            onChanged: onToggleHardware,
            activeThumbColor: AppColors.emeraldGreen,
            inactiveTrackColor: AppColors.cardSurfaceElevated,
          ),
        ],
      ),
    );
  }

  Widget _buildHardwareStatusStrip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildSensorChip('IMU Accel', snapshot.hasAccel),
          _buildSensorChip('Gyroscope', snapshot.hasGyro),
          _buildSensorChip('Light (Lux)', snapshot.hasLight),
          _buildSensorChip('Proximity', snapshot.hasProximity),
        ],
      ),
    );
  }

  Widget _buildSensorChip(String label, bool isAvailable) {
    final color = isAvailable ? AppColors.emeraldGreen : AppColors.textMuted;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.circle, color: color, size: 6),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            color: isAvailable ? AppColors.textPrimary : AppColors.textMuted,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildGyroscopeCard() {
    final gyroMag = snapshot.gyroMagnitude;
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
              const Row(
                children: [
                  Icon(Icons.screen_rotation_rounded, size: 16, color: AppColors.cyberCyan),
                  SizedBox(width: 8),
                  Text(
                    'GYROSCOPE ANGULAR RATE',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                      color: AppColors.cyberCyan,
                    ),
                  ),
                ],
              ),
              Text(
                '|ω| = ${gyroMag.toStringAsFixed(2)} rad/s',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildAxisStat('ωX', snapshot.gyroX)),
              const SizedBox(width: 8),
              Expanded(child: _buildAxisStat('ωY', snapshot.gyroY)),
              const SizedBox(width: 8),
              Expanded(child: _buildAxisStat('ωZ', snapshot.gyroZ)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAxisStat(String label, double val) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.cardSurfaceElevated,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        children: [
          Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textMuted, fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text(
            '${val >= 0 ? "+" : ""}${val.toStringAsFixed(2)}',
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
        ],
      ),
    );
  }

  Widget _buildLightCard(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final lux = snapshot.lightLux;
    String lightContext;
    Color lightColor;

    if (lux < 5.0) {
      lightContext = 'Dark / Night Rest';
      lightColor = AppColors.electricViolet;
    } else if (lux < 40.0) {
      lightContext = 'Dim / Rest Profile';
      lightColor = AppColors.primaryAmber;
    } else if (lux <= 450.0) {
      lightContext = 'Workspace Focus';
      lightColor = AppColors.cyberCyan;
    } else {
      lightContext = 'Bright / Direct Sunlight';
      lightColor = AppColors.neonYellow;
    }

    return Container(
      padding: const EdgeInsets.all(14),
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
              Text(
                l10n?.sensorLight != null ? l10n!.sensorLight.toUpperCase() : 'AMBIENT LIGHT',
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                  color: AppColors.primaryAmber,
                ),
              ),
              const Icon(Icons.light_mode_rounded, size: 16, color: AppColors.primaryAmber),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                lux.toStringAsFixed(0),
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(width: 4),
              const Text('lux', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            lightContext,
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              color: lightColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProximityCard(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isNear = snapshot.proximityNear;
    return Container(
      padding: const EdgeInsets.all(14),
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
              Text(
                l10n?.sensorProximity != null ? l10n!.sensorProximity.toUpperCase() : 'PROXIMITY',
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                  color: AppColors.cyberCyan,
                ),
              ),
              const Icon(Icons.sensors_rounded, size: 16, color: AppColors.cyberCyan),
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
            isNear ? '< 5 cm (Covered/Docked)' : '> 10 cm (Open air)',
            style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
          ),
          const SizedBox(height: 4),
          Text(
            isNear ? 'Docked at Desk' : 'In Hand / Free',
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              color: isNear ? AppColors.emeraldGreen : AppColors.textSecondary,
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
                  'Measured local execution',
                  AppColors.emeraldGreen,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildMetricTile(
                  'CLOUD ROUNDTRIP',
                  '0.0 ms',
                  'No network inference',
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
