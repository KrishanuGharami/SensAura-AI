import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

class StatusAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool isHardware;
  final VoidCallback? onToggleHardware;

  const StatusAppBar({
    super.key,
    this.title = 'SensAura AI',
    this.isHardware = false,
    this.onToggleHardware,
  });

  @override
  Size get preferredSize => const Size.fromHeight(88);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Top Title + Hardware switch
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: AppColors.amberGradient,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryAmberGlow,
                              blurRadius: 10,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.radar_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const Text(
                            'OFFLINE-FIRST • ON-DEVICE AI',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.8,
                              color: AppColors.cyberCyan,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  // Feed Source Badge
                  GestureDetector(
                    onTap: onToggleHardware,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: isHardware
                            ? AppColors.emeraldGreen.withValues(alpha: 0.15)
                            : AppColors.primaryAmber.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isHardware
                              ? AppColors.emeraldGreen.withValues(alpha: 0.5)
                              : AppColors.primaryAmber.withValues(alpha: 0.5),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isHardware ? Icons.memory_rounded : Icons.science_rounded,
                            size: 13,
                            color: isHardware ? AppColors.emeraldGreen : AppColors.primaryAmber,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            isHardware ? 'HARDWARE' : 'DEMO MODE',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                              color: isHardware ? AppColors.emeraldGreen : AppColors.primaryAmber,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Status badges row: ● LOCAL  ● SENSOR STREAM  ● BLE CONNECTED
              Row(
                children: [
                  _buildStatusPill('LOCAL', AppColors.statusLocal),
                  const SizedBox(width: 8),
                  _buildStatusPill('SENSOR STREAM', AppColors.statusStream),
                  const SizedBox(width: 8),
                  _buildStatusPill('BLE CONNECTED', AppColors.statusBle),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusPill(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.cardSurfaceElevated,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.borderSubtle, width: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.6),
                  blurRadius: 4,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              fontSize: 9.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.4,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
