import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../l10n/app_localizations.dart';
import '../main.dart';

class StatusAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool isHardware;
  final bool hardwareAvailable;
  final bool isSensorAvailable;
  final bool isBleAvailable;
  final VoidCallback? onToggleHardware;

  const StatusAppBar({
    super.key,
    this.title = 'SensAura AI',
    this.isHardware = false,
    this.hardwareAvailable = true,
    this.isSensorAvailable = true,
    this.isBleAvailable = true,
    this.onToggleHardware,
  });

  @override
  Size get preferredSize => const Size.fromHeight(88);

  @override
  Widget build(BuildContext context) {
    final liveHardwareAvailable = isHardware && hardwareAvailable;
    final l10n = AppLocalizations.of(context);
    final currentLocale = Localizations.localeOf(context);
    final currentLang = AppLanguage.fromCode(currentLocale.languageCode);

    return Container(
      color: AppColors.background,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Top Title + Hardware switch + Language Switcher
              Row(
                children: [
                  Expanded(
                    child: Row(
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
                        const SizedBox(width: 8),
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                title,
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.5,
                                  color: AppColors.textPrimary,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                l10n?.offlineNotice ??
                                    'OFFLINE-FIRST • ON-DEVICE RULES',
                                style: const TextStyle(
                                  fontSize: 8.5,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.6,
                                  color: AppColors.cyberCyan,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 6),

                  // Feed Source Badge
                  GestureDetector(
                    onTap: onToggleHardware,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 5),
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
                            liveHardwareAvailable
                                ? Icons.memory_rounded
                                : Icons.science_rounded,
                            size: 13,
                            color: liveHardwareAvailable
                                ? AppColors.emeraldGreen
                                : AppColors.primaryAmber,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            liveHardwareAvailable
                                ? (l10n?.hardware ?? 'HARDWARE')
                                : isHardware
                                    ? (l10n?.hardwareUnavailable ??
                                        'HARDWARE UNAVAILABLE')
                                    : (l10n?.demoMode ?? 'DEMO MODE'),
                            style: TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                              color: liveHardwareAvailable
                                  ? AppColors.emeraldGreen
                                  : AppColors.primaryAmber,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(width: 6),

                  // Language Selector Button (🌐 Native script)
                  GestureDetector(
                    onTap: () => _showLanguageSelector(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.cyberCyan.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColors.cyberCyan.withValues(alpha: 0.6),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            '🌐',
                            style: TextStyle(fontSize: 11),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            currentLang.nativeName,
                            style: const TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.4,
                              color: AppColors.cyberCyan,
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
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: [
                    _buildStatusPill(
                        l10n?.statusLocal ?? 'LOCAL', AppColors.statusLocal),
                    const SizedBox(width: 8),
                    _buildStatusPill(
                      isSensorAvailable
                          ? (l10n?.statusSensorStream ?? 'SENSOR STREAM')
                          : (l10n?.statusSensorUnavailable ??
                              'SENSOR UNAVAILABLE'),
                      isSensorAvailable
                          ? AppColors.statusStream
                          : AppColors.dangerRed,
                    ),
                    const SizedBox(width: 8),
                    _buildStatusPill(
                      isBleAvailable
                          ? (l10n?.statusBleConnected ?? 'BLE CONNECTED')
                          : (l10n?.statusBleUnavailable ?? 'BLE UNAVAILABLE'),
                      isBleAvailable ? AppColors.statusBle : AppColors.dangerRed,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLanguageSelector(BuildContext context) {
    final currentLocale = Localizations.localeOf(context);
    final l10n = AppLocalizations.of(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF0F141D),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        side: BorderSide(color: AppColors.borderSubtle, width: 1),
      ),
      builder: (ctx) {
        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text('🌐', style: TextStyle(fontSize: 18)),
                    const SizedBox(width: 8),
                    Text(
                      l10n?.selectLanguage ?? 'Select Language',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                const Divider(color: AppColors.borderSubtle, height: 1),
                const SizedBox(height: 10),
                ...AppLanguage.values.map((lang) {
                  final isSelected = lang.code == currentLocale.languageCode;
                  return InkWell(
                    onTap: () {
                      Navigator.pop(ctx);
                      SensAuraApp.setLocale(context, Locale(lang.code));
                    },
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.cyberCyan.withValues(alpha: 0.12)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.cyberCyan.withValues(alpha: 0.5)
                              : AppColors.borderSubtle.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  lang.nativeName,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: isSelected
                                        ? FontWeight.w800
                                        : FontWeight.w600,
                                    color: isSelected
                                        ? AppColors.cyberCyan
                                        : AppColors.textPrimary,
                                  ),
                                ),
                                Text(
                                  lang.englishName,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (isSelected)
                            const Icon(
                              Icons.check_circle_rounded,
                              color: AppColors.cyberCyan,
                              size: 20,
                            ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
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
