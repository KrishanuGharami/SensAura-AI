import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../l10n/app_localizations.dart';
import '../models/sensor_snapshot.dart';

class SensorStatStrip extends StatelessWidget {
  final SensorSnapshot snapshot;
  final VoidCallback? onTap;

  const SensorStatStrip({
    super.key,
    required this.snapshot,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.cardSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderSubtle),
        ),
        child: Row(
          children: [
            Expanded(
              child: _buildItem(
                icon: Icons.light_mode_rounded,
                iconColor: AppColors.warmGold,
                label: l10n?.sensorLight ?? 'Light',
                value: '${snapshot.lightLux.toStringAsFixed(0)} lux',
              ),
            ),
            _buildDivider(),
            Expanded(
              child: _buildItem(
                icon: Icons.vibration_rounded,
                iconColor: AppColors.cyberCyan,
                label: l10n?.sensorMotion ?? 'Motion',
                value: snapshot.motionLevel.displayName.replaceAll(' Motion', ''),
              ),
            ),
            _buildDivider(),
            Expanded(
              child: _buildItem(
                icon: Icons.bluetooth_searching_rounded,
                iconColor: AppColors.electricViolet,
                label: 'BLE',
                value: '${snapshot.bleDevicesCount} nodes',
              ),
            ),
            _buildDivider(),
            Expanded(
              child: _buildItem(
                icon: Icons.sensors_rounded,
                iconColor: snapshot.proximityNear ? AppColors.emeraldGreen : AppColors.textMuted,
                label: l10n?.sensorProximity ?? 'Proximity',
                value: snapshot.proximityNear ? 'Near' : 'Far',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 24,
      width: 1,
      color: AppColors.borderSubtle,
      margin: const EdgeInsets.symmetric(horizontal: 4),
    );
  }

  Widget _buildItem({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: iconColor),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: AppColors.textMuted,
          ),
        ),
      ],
    );
  }
}
