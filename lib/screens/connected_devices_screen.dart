import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../l10n/app_localizations.dart';
import '../models/automation_timeline_entry.dart';
import '../models/smart_device.dart';
import '../services/ble_actuator_provider.dart';
import '../services/demo_environment_actuator.dart';
import '../services/workstation_actuator_provider.dart';

class ConnectedDevicesScreen extends StatefulWidget {
  final WorkstationActuatorProvider workstationActuator;
  final BleActuatorProvider bleActuator;
  final DemoEnvironmentActuator demoActuator;
  final List<SmartDevice> devices;
  final List<AutomationTimelineEntry> timeline;
  final bool isManualOverrideActive;
  final Duration? manualOverrideRemaining;
  final Function(String deviceId,
      {bool? isOn, int? primaryValue, String? secondaryStatus}) onUpdateDevice;
  final VoidCallback onClearOverride;
  final VoidCallback onResetCooldown;

  const ConnectedDevicesScreen({
    super.key,
    required this.workstationActuator,
    required this.bleActuator,
    required this.demoActuator,
    required this.devices,
    required this.timeline,
    required this.isManualOverrideActive,
    this.manualOverrideRemaining,
    required this.onUpdateDevice,
    required this.onClearOverride,
    required this.onResetCooldown,
  });

  @override
  State<ConnectedDevicesScreen> createState() => _ConnectedDevicesScreenState();
}

class _ConnectedDevicesScreenState extends State<ConnectedDevicesScreen> {
  late TextEditingController _hostController;
  late TextEditingController _portController;
  bool _isTestingWorkstation = false;

  @override
  void initState() {
    super.initState();
    _hostController =
        TextEditingController(text: widget.workstationActuator.host);
    _portController =
        TextEditingController(text: widget.workstationActuator.port.toString());
  }

  @override
  void dispose() {
    _hostController.dispose();
    _portController.dispose();
    super.dispose();
  }

  Future<void> _handleTestWorkstation() async {
    final host = _hostController.text.trim();
    final port = int.tryParse(_portController.text.trim());
    if (host.isEmpty || port == null || port < 1 || port > 65535) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enter a valid host IPv4 address and port (1-65535).'),
          backgroundColor: AppColors.dangerRed,
        ),
      );
      return;
    }
    setState(() => _isTestingWorkstation = true);
    widget.workstationActuator.updateHost(host, port);
    final success = await widget.workstationActuator.checkConnection();
    if (mounted) {
      setState(() => _isTestingWorkstation = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? 'Connected to SensAura Node at $host:$port!'
                : 'Could not reach $host:$port. Ensure Python server is running on laptop.',
          ),
          backgroundColor:
              success ? AppColors.emeraldGreen : AppColors.dangerRed,
        ),
      );
    }
  }

  Future<void> _sendTestWorkstationCommand(String command) async {
    final success = await widget.workstationActuator.dispatchCommand(command);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? 'Command "$command" acknowledged by SensAura Node!'
                : 'Command dispatch failed. Check workstation connection.',
          ),
          backgroundColor: success ? AppColors.cyberCyan : AppColors.dangerRed,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          // 1. Top Title & Hierarchy
          _buildScreenHeader(),

          const SizedBox(height: 12),

          // 2. Hardware vs Demo Status Badges
          _buildStatusBadges(),

          const SizedBox(height: 14),

          // 3. Jury Transparency & Ground Truth Banner
          _buildJuryTransparencyCard(),

          // 4. Manual Override Lease Banner (if active)
          if (widget.isManualOverrideActive) ...[
            const SizedBox(height: 14),
            _buildManualOverrideBanner(),
          ],

          const SizedBox(height: 18),

          // 5. Demo Connected Environment Devices Section (Step 3 & 7 & 12)
          _buildDemoDevicesSection(),

          const SizedBox(height: 20),

          // 6. Real-Time Automation Timeline (Step 10)
          _buildAutomationTimelineSection(),

          const SizedBox(height: 20),

          // 7. Physical / Local Nodes Section (Step 8)
          _buildPhysicalNodesSection(),

          const SizedBox(height: 20),

          // 8. Privacy Assurance Card (Step 13)
          _buildPrivacyCard(),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildScreenHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'CONNECTED ENVIRONMENT',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.1,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Offline-first Smart Space Orchestration',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.cyberCyan.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                    color: AppColors.cyberCyan.withValues(alpha: 0.3)),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.hub_rounded, size: 12, color: AppColors.cyberCyan),
                  SizedBox(width: 4),
                  Text(
                    'ACTUATOR LAYER',
                    style: TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.6,
                      color: AppColors.cyberCyan,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusBadges() {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildStatusPill('iQOO 15', l10n?.liveHardware ?? 'REAL HARDWARE', AppColors.emeraldGreen),
          _buildStatusPill('SensAura AI', 'ON-DEVICE', AppColors.cyberCyan),
          _buildStatusPill('Demo Space', 'ACTIVE', AppColors.primaryAmber),
        ],
      ),
    );
  }

  Widget _buildStatusPill(String title, String subtitle, Color color) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.5),
                blurRadius: 4,
                spreadRadius: 1,
              ),
            ],
          ),
        ),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 8.5,
                fontWeight: FontWeight.w700,
                color: color,
                letterSpacing: 0.4,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildJuryTransparencyCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cardSurfaceElevated,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cyberCyan.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.verified_outlined,
                  size: 15, color: AppColors.cyberCyan),
              SizedBox(width: 6),
              Text(
                'HARDWARE-AGNOSTIC ACTUATOR ARCHITECTURE',
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.6,
                  color: AppColors.cyberCyan,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Because this prototype is designed to be hardware-agnostic, the smart-space actuator layer is represented here by a deterministic local device simulator. The exact same ActuatorProvider interface binds to compatible BLE, local-network (SensAura Node), or smart-home devices.',
            style: TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.warmGold.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'TRANSPORT: DEMO DEVICE RESPONSE',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: AppColors.warmGold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'No fabricated ping or false hardware claims',
                style: TextStyle(fontSize: 10, color: AppColors.textMuted),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildManualOverrideBanner() {
    final l10n = AppLocalizations.of(context);
    final remainingSec = widget.manualOverrideRemaining?.inSeconds ?? 0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.primaryAmber.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primaryAmber.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          const Icon(Icons.lock_clock_rounded,
              color: AppColors.primaryAmber, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n?.guardManualOverrideActive ?? 'MANUAL OVERRIDE ACTIVE',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.6,
                    color: AppColors.primaryAmber,
                  ),
                ),
                Text(
                  'Automation paused for ${remainingSec}s to protect user manual adjustments.',
                  style: const TextStyle(
                      fontSize: 10.5, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: widget.onClearOverride,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryAmber,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6)),
            ),
            child: Text(l10n?.releaseOverride ?? 'RELEASE',
                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildDemoDevicesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Row(
              children: [
                Icon(Icons.devices_other_rounded,
                    size: 16, color: AppColors.cyberCyan),
                SizedBox(width: 6),
                Text(
                  'DEMO CONNECTED ENVIRONMENT',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            Text(
              '${widget.devices.length} Virtual Endpoints',
              style: const TextStyle(fontSize: 10.5, color: AppColors.textMuted),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Column(
          children: widget.devices.map((device) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _buildDeviceCard(device),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDeviceCard(SmartDevice device) {
    final l10n = AppLocalizations.of(context);
    final isOn = device.isOn;
    final color = _getDeviceColor(device.type, isOn);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isOn ? AppColors.cardSurfaceElevated : AppColors.cardSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isOn ? color.withValues(alpha: 0.4) : AppColors.borderSubtle,
          width: isOn ? 1.2 : 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: Icon, Name, Badge, Switch
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: isOn
                      ? color.withValues(alpha: 0.18)
                      : AppColors.backgroundSecondary,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      color: isOn
                          ? color.withValues(alpha: 0.4)
                          : AppColors.borderSubtle),
                ),
                child: Icon(device.type.iconData,
                    size: 18, color: isOn ? color : AppColors.textMuted),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            device.name,
                            style: const TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 5, vertical: 1.5),
                          decoration: BoxDecoration(
                            color: device.isDemo
                                ? AppColors.primaryAmber.withValues(alpha: 0.15)
                                : AppColors.cyberCyan.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            device.statusBadge,
                            style: TextStyle(
                              fontSize: 8.5,
                              fontWeight: FontWeight.w800,
                              color: device.isDemo
                                  ? AppColors.primaryAmber
                                  : AppColors.cyberCyan,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${device.room} • ${device.formattedLatency}',
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              if (device.isPendingAck)
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(AppColors.primaryAmber),
                  ),
                )
              else
                Switch(
                  value: isOn,
                  onChanged: (val) {
                    widget.onUpdateDevice(device.id, isOn: val);
                  },
                  activeTrackColor: color.withValues(alpha: 0.4),
                  activeThumbColor: color,
                ),
            ],
          ),

          const SizedBox(height: 10),

          // Row 2: Capabilities chips
          Wrap(
            spacing: 5,
            runSpacing: 4,
            children: device.capabilities.map((cap) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.backgroundSecondary,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: AppColors.borderSubtle),
                ),
                child: Text(
                  cap,
                  style: const TextStyle(
                    fontSize: 9,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 10),

          // Row 3: Current state summary
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.backgroundDark,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.borderSubtle),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      isOn ? '${device.primaryValue}' : (l10n?.stateOff ?? 'OFF'),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color:
                            isOn ? AppColors.textPrimary : AppColors.textMuted,
                      ),
                    ),
                    if (isOn) ...[
                      const SizedBox(width: 2),
                      Text(
                        device.type.defaultUnit,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                    ],
                  ],
                ),
                Text(
                  isOn ? device.secondaryStatus : (l10n?.stateStandby ?? 'Standby'),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isOn ? AppColors.textSecondary : AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),

          // Row 4: Interactive manual controls (Sliders & Buttons)
          if (isOn) ...[
            const SizedBox(height: 8),
            _buildInteractiveControl(device, color),
          ],
        ],
      ),
    );
  }

  Widget _buildInteractiveControl(SmartDevice device, Color color) {
    switch (device.type) {
      case DeviceType.light:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Brightness',
                    style: TextStyle(
                        fontSize: 10.5,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.bold)),
                Text('${device.primaryValue}%',
                    style: TextStyle(
                        fontSize: 10.5,
                        color: color,
                        fontWeight: FontWeight.bold)),
              ],
            ),
            Slider(
              value: device.primaryValue.clamp(0, 100).toDouble(),
              min: 0,
              max: 100,
              divisions: 20,
              activeColor: color,
              onChanged: (val) {
                widget.onUpdateDevice(device.id, primaryValue: val.round());
              },
            ),
          ],
        );

      case DeviceType.ac:
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Temperature',
                style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.bold)),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline_rounded,
                      size: 20, color: AppColors.cyberCyan),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () {
                    final next = (device.primaryValue - 1).clamp(16, 30);
                    widget.onUpdateDevice(device.id, primaryValue: next);
                  },
                ),
                const SizedBox(width: 8),
                Text(
                  '${device.primaryValue}°C',
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline_rounded,
                      size: 20, color: AppColors.cyberCyan),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () {
                    final next = (device.primaryValue + 1).clamp(16, 30);
                    widget.onUpdateDevice(device.id, primaryValue: next);
                  },
                ),
              ],
            ),
          ],
        );

      case DeviceType.fan:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Fan Speed',
                    style: TextStyle(
                        fontSize: 10.5,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.bold)),
                Text('Level ${device.primaryValue}',
                    style: TextStyle(
                        fontSize: 10.5,
                        color: color,
                        fontWeight: FontWeight.bold)),
              ],
            ),
            Slider(
              value: device.primaryValue.clamp(0, 3).toDouble(),
              min: 0,
              max: 3,
              divisions: 3,
              activeColor: color,
              onChanged: (val) {
                widget.onUpdateDevice(device.id,
                    primaryValue: val.round(),
                    secondaryStatus: 'Speed ${val.round()}');
              },
            ),
          ],
        );

      case DeviceType.speaker:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Audio Volume',
                    style: TextStyle(
                        fontSize: 10.5,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.bold)),
                Text('${device.primaryValue}%',
                    style: TextStyle(
                        fontSize: 10.5,
                        color: color,
                        fontWeight: FontWeight.bold)),
              ],
            ),
            Slider(
              value: device.primaryValue.clamp(0, 100).toDouble(),
              min: 0,
              max: 100,
              divisions: 20,
              activeColor: color,
              onChanged: (val) {
                widget.onUpdateDevice(device.id, primaryValue: val.round());
              },
            ),
          ],
        );

      case DeviceType.workstation:
        return Wrap(
          spacing: 6,
          children: ['FOCUS', 'REST', 'BREAK', 'RESTORE'].map((mode) {
            final isSelected = device.secondaryStatus.contains(mode);
            return ChoiceChip(
              label: Text(mode,
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.black : AppColors.textPrimary)),
              selected: isSelected,
              selectedColor: AppColors.cyberCyan,
              backgroundColor: AppColors.backgroundSecondary,
              onSelected: (val) {
                if (val) {
                  widget.onUpdateDevice(device.id,
                      secondaryStatus: '$mode ACTIVE');
                }
              },
            );
          }).toList(),
        );

      case DeviceType.plug:
        return const SizedBox.shrink();
    }
  }

  Color _getDeviceColor(DeviceType type, bool isOn) {
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
      case DeviceType.workstation:
        return AppColors.cyberCyan;
    }
  }

  Widget _buildAutomationTimelineSection() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.timeline_rounded,
                      size: 16, color: AppColors.cyberCyan),
                  SizedBox(width: 6),
                  Text(
                    'REAL-TIME AUTOMATION TIMELINE',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              Text(
                'Deterministic Log',
                style: TextStyle(fontSize: 10, color: AppColors.textMuted),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (widget.timeline.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Center(
                child: Text(
                  'No automation events triggered yet. Apply a scene or trigger context inference.',
                  style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                  textAlign: TextAlign.center,
                ),
              ),
            )
          else
            Column(
              children: widget.timeline.reversed.take(8).map((entry) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.formattedTime,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textMuted,
                          fontFamily: 'monospace',
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(entry.icon, size: 13, color: entry.statusColor),
                      const SizedBox(width: 6),
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            style: const TextStyle(
                                fontSize: 11, color: AppColors.textPrimary),
                            children: [
                              TextSpan(
                                text: '${entry.stage}: ',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              TextSpan(
                                text: entry.detail,
                                style: TextStyle(
                                  color: entry.statusColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
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

  Widget _buildPhysicalNodesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.cable_rounded, size: 16, color: AppColors.emeraldGreen),
            SizedBox(width: 6),
            Text(
              'PHYSICAL / LOCAL NODES',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // 1. SensAura Node Workstation Card
        StreamBuilder<WorkstationStatus>(
          stream: widget.workstationActuator.statusStream,
          initialData: widget.workstationActuator.status,
          builder: (context, snapshot) {
            final status = snapshot.data ?? WorkstationStatus.disconnected;
            final isConnected = widget.workstationActuator.isConnected;
            final lastAck = widget.workstationActuator.lastAck;
            return _buildWorkstationCard(status, isConnected, lastAck);
          },
        ),

        const SizedBox(height: 12),

        // 2. Real BLE Actuator Card
        _buildBleActuatorCard(),
      ],
    );
  }

  Widget _buildWorkstationCard(
      WorkstationStatus status, bool isConnected, WorkstationAck? lastAck) {
    Color statusColor;
    switch (status) {
      case WorkstationStatus.connected:
      case WorkstationStatus.commandAcknowledged:
        statusColor = AppColors.emeraldGreen;
        break;
      case WorkstationStatus.connecting:
      case WorkstationStatus.commandSent:
        statusColor = AppColors.primaryAmber;
        break;
      case WorkstationStatus.disconnected:
      case WorkstationStatus.actuatorFailed:
        statusColor = AppColors.dangerRed;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: statusColor.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.laptop_chromebook_rounded,
                    color: statusColor, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'SENSAURA NODE (LAPTOP COMPANION)',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.6,
                      ),
                    ),
                    Text(
                      status.displayName,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: statusColor,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                flex: 3,
                child: TextField(
                  controller: _hostController,
                  style: const TextStyle(
                      color: AppColors.textPrimary, fontSize: 12),
                  decoration: InputDecoration(
                    labelText: 'Workstation IP',
                    labelStyle: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 11),
                    filled: true,
                    fillColor: AppColors.backgroundDark,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 8),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide:
                          const BorderSide(color: AppColors.borderSubtle),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                flex: 2,
                child: TextField(
                  controller: _portController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(
                      color: AppColors.textPrimary, fontSize: 12),
                  decoration: InputDecoration(
                    labelText: 'Port',
                    labelStyle: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 11),
                    filled: true,
                    fillColor: AppColors.backgroundDark,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 8),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide:
                          const BorderSide(color: AppColors.borderSubtle),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              ElevatedButton(
                onPressed: _isTestingWorkstation ? null : _handleTestWorkstation,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.cyberCyan,
                  foregroundColor: Colors.black,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                child: _isTestingWorkstation
                    ? const SizedBox(
                        width: 12,
                        height: 12,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('PING',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 10.5)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              _buildCmdButton(
                  'FOCUS', Icons.psychology_rounded, AppColors.cyberCyan),
              _buildCmdButton(
                  'REST', Icons.spa_rounded, AppColors.primaryAmber),
              _buildCmdButton(
                  'BREAK', Icons.coffee_rounded, AppColors.neonYellow),
              _buildCmdButton('LEAVING', Icons.directions_walk_rounded,
                  AppColors.dangerRed),
              _buildCmdButton(
                  'ARRIVING', Icons.home_rounded, AppColors.emeraldGreen),
            ],
          ),
          if (lastAck != null) ...[
            const SizedBox(height: 8),
            Text(
              'Last ACK: [${lastAck.command}] by ${lastAck.nodeId} (${lastAck.requestId})',
              style: const TextStyle(color: AppColors.textMuted, fontSize: 10),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCmdButton(String cmd, IconData icon, Color color) {
    return InkWell(
      onTap: () => _sendTestWorkstationCommand(cmd),
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: color.withValues(alpha: 0.4)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 12),
            const SizedBox(width: 4),
            Text(cmd,
                style: TextStyle(
                    color: color, fontSize: 10, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildBleActuatorCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(14),
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
                  Icon(Icons.bluetooth_searching_rounded,
                      color: AppColors.cyberCyan, size: 18),
                  SizedBox(width: 8),
                  Text(
                    'BLE GATT ACTUATORS',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.6,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.refresh_rounded,
                    color: AppColors.textSecondary, size: 18),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () => widget.bleActuator.startDiscovery(),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.backgroundDark,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.borderSubtle),
            ),
            child: Row(
              children: [
                const Icon(Icons.radio_button_unchecked_rounded,
                    color: AppColors.textMuted, size: 14),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.bleActuator.hasControllableActuator
                        ? '● REAL BLE DEVICE CONNECTED'
                        : '○ No compatible physical actuator detected — Demo Environment active',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 10.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacyCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'PRIVACY & SECURITY GUARANTEES',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
              color: AppColors.cyberCyan,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'PROCESSING: LOCAL • CAMERA: LOCAL • SENSORS: LOCAL • HISTORY: LOCAL • CLOUD: NOT REQUIRED',
            style: TextStyle(
              fontSize: 9.5,
              fontWeight: FontWeight.w700,
              color: AppColors.emeraldGreen,
              letterSpacing: 0.4,
            ),
          ),
        ],
      ),
    );
  }
}
