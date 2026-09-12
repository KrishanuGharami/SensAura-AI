import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../models/smart_device.dart';

class SmartDeviceTile extends StatelessWidget {
  final SmartDevice device;
  final ValueChanged<bool>? onToggle;
  final ValueChanged<double>? onValueChanged;

  const SmartDeviceTile({
    super.key,
    required this.device,
    this.onToggle,
    this.onValueChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isOn = device.isOn;
    final color = _getDeviceAccentColor(device.type, isOn);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isOn ? AppColors.cardSurfaceElevated : AppColors.cardSurface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isOn ? color.withValues(alpha: 0.4) : AppColors.borderSubtle,
          width: isOn ? 1.2 : 1.0,
        ),
        boxShadow: isOn
            ? [
                BoxShadow(
                  color: color.withValues(alpha: 0.1),
                  blurRadius: 12,
                  spreadRadius: 1,
                  offset: const Offset(0, 4),
                )
              ]
            : [],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Icon + Name + Switch
          Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: isOn ? color.withValues(alpha: 0.18) : AppColors.backgroundSecondary,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isOn ? color.withValues(alpha: 0.5) : AppColors.borderSubtle,
                  ),
                ),
                child: Icon(
                  device.type.iconData,
                  size: 20,
                  color: isOn ? color : AppColors.textMuted,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      device.name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      device.room,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: isOn,
                onChanged: onToggle,
                activeTrackColor: color.withValues(alpha: 0.4),
                activeThumbColor: color,
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Primary Value + Unit & Secondary Chip
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    isOn ? '${device.primaryValue}' : 'OFF',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: isOn ? AppColors.textHighlight : AppColors.textMuted,
                      letterSpacing: -0.5,
                    ),
                  ),
                  if (isOn) ...[
                    const SizedBox(width: 3),
                    Text(
                      device.type.defaultUnit,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                    ),
                  ],
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.backgroundSecondary,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppColors.borderSubtle),
                ),
                child: Text(
                  isOn ? device.secondaryStatus : 'Standby',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: isOn ? AppColors.textSecondary : AppColors.textMuted,
                  ),
                ),
              ),
            ],
          ),

          // Slider for analog devices (Light, AC, Fan, Speaker)
          if (isOn && device.type != DeviceType.plug) ...[
            const SizedBox(height: 4),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: color,
                thumbColor: color,
                overlayColor: color.withValues(alpha: 0.2),
                trackHeight: 3,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
              ),
              child: Slider(
                value: _getNormalizedSliderValue(device),
                min: _getMinSliderValue(device.type),
                max: _getMaxSliderValue(device.type),
                divisions: _getSliderDivisions(device.type),
                onChanged: onValueChanged,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getDeviceAccentColor(DeviceType type, bool isOn) {
    if (!isOn) return AppColors.textMuted;
    switch (type) {
      case DeviceType.light:
        return AppColors.warmGold;
      case DeviceType.ac:
        return AppColors.cyberCyan;
      case DeviceType.fan:
        return AppColors.emeraldGreen;
      case DeviceType.speaker:
        return AppColors.electricViolet;
      case DeviceType.plug:
        return AppColors.primaryAmber;
    }
  }

  double _getNormalizedSliderValue(SmartDevice device) {
    if (device.type == DeviceType.ac) {
      return device.primaryValue.clamp(16, 30).toDouble();
    }
    return device.primaryValue.clamp(0, 100).toDouble();
  }

  double _getMinSliderValue(DeviceType type) {
    if (type == DeviceType.ac) return 16.0;
    return 0.0;
  }

  double _getMaxSliderValue(DeviceType type) {
    if (type == DeviceType.ac) return 30.0;
    if (type == DeviceType.fan) return 5.0;
    return 100.0;
  }

  int? _getSliderDivisions(DeviceType type) {
    if (type == DeviceType.ac) return 14;
    if (type == DeviceType.fan) return 5;
    return 20;
  }
}
