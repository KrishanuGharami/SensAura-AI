import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../models/automation_scene.dart';
import '../models/smart_device.dart';
import '../widgets/smart_device_tile.dart';

class SmartEnvironmentScreen extends StatelessWidget {
  final List<SmartDevice> devices;
  final AutomationScene currentScene;
  final Function(String deviceId, {bool? isOn, int? primaryValue, String? secondaryStatus})
      onUpdateDevice;

  const SmartEnvironmentScreen({
    super.key,
    required this.devices,
    required this.currentScene,
    required this.onUpdateDevice,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Room Header & Scene status
          _buildRoomHeader(),

          const SizedBox(height: 16),

          // Smart Devices List
          Column(
            children: devices.map((device) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: SmartDeviceTile(
                  device: device,
                  onToggle: (val) {
                    onUpdateDevice(device.id, isOn: val);
                  },
                  onValueChanged: (val) {
                    onUpdateDevice(device.id, primaryValue: val.round());
                  },
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildRoomHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.meeting_room_rounded, size: 16, color: AppColors.primaryAmber),
                  SizedBox(width: 8),
                  Text(
                    'ZONE: LIVING ROOM',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                      color: AppColors.primaryAmber,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                '${devices.where((d) => d.isOn).length} of ${devices.length} Devices Powered',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.cardSurfaceElevated,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.borderSubtle),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(currentScene.icon, size: 14, color: AppColors.cyberCyan),
                const SizedBox(width: 6),
                Text(
                  currentScene.title.replaceAll(' Scene', ''),
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.cyberCyan,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
