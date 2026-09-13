import 'package:flutter/material.dart';

enum DeviceType {
  light,
  ac,
  fan,
  speaker,
  plug,
  workstation;

  String get defaultUnit {
    switch (this) {
      case DeviceType.light:
        return '%';
      case DeviceType.ac:
        return '°C';
      case DeviceType.fan:
        return 'lvl';
      case DeviceType.speaker:
        return '%';
      case DeviceType.plug:
        return 'W';
      case DeviceType.workstation:
        return 'mode';
    }
  }

  IconData get iconData {
    switch (this) {
      case DeviceType.light:
        return Icons.lightbulb_rounded;
      case DeviceType.ac:
        return Icons.ac_unit_rounded;
      case DeviceType.fan:
        return Icons.mode_fan_off_rounded;
      case DeviceType.speaker:
        return Icons.speaker_rounded;
      case DeviceType.plug:
        return Icons.power_rounded;
      case DeviceType.workstation:
        return Icons.laptop_chromebook_rounded;
    }
  }
}

class SmartDevice {
  final String id;
  final String name;
  final String room;
  final DeviceType type;
  final bool isOn;
  final int primaryValue; // brightness (0-100), temp (16-30), speed (0-5), volume (0-100), powerWatts
  final String secondaryStatus; // e.g., '3000K', 'Quiet', 'Lo-Fi Chill', 'FOCUS ACTIVE'
  final bool isDemo;
  final List<String> capabilities;
  final String? lastCommandName;
  final DateTime? lastAckTime;
  final int? lastLatencyMs;
  final String latencyLabel;
  final bool isPendingAck;

  const SmartDevice({
    required this.id,
    required this.name,
    required this.room,
    required this.type,
    required this.isOn,
    required this.primaryValue,
    required this.secondaryStatus,
    this.isDemo = true,
    this.capabilities = const [],
    this.lastCommandName,
    this.lastAckTime,
    this.lastLatencyMs,
    this.latencyLabel = 'DEMO DEVICE RESPONSE',
    this.isPendingAck = false,
  });

  String get statusBadge {
    if (type == DeviceType.workstation && !isDemo) {
      return '● LOCAL NODE';
    }
    if (isDemo) {
      return '● DEMO ONLINE';
    }
    return '● REAL BLE DEVICE';
  }

  String get formattedLatency {
    if (lastLatencyMs != null) {
      return '${lastLatencyMs}ms ($latencyLabel)';
    }
    return 'Ready ($latencyLabel)';
  }

  SmartDevice copyWith({
    String? id,
    String? name,
    String? room,
    DeviceType? type,
    bool? isOn,
    int? primaryValue,
    String? secondaryStatus,
    bool? isDemo,
    List<String>? capabilities,
    String? lastCommandName,
    DateTime? lastAckTime,
    int? lastLatencyMs,
    String? latencyLabel,
    bool? isPendingAck,
  }) {
    return SmartDevice(
      id: id ?? this.id,
      name: name ?? this.name,
      room: room ?? this.room,
      type: type ?? this.type,
      isOn: isOn ?? this.isOn,
      primaryValue: primaryValue ?? this.primaryValue,
      secondaryStatus: secondaryStatus ?? this.secondaryStatus,
      isDemo: isDemo ?? this.isDemo,
      capabilities: capabilities ?? this.capabilities,
      lastCommandName: lastCommandName ?? this.lastCommandName,
      lastAckTime: lastAckTime ?? this.lastAckTime,
      lastLatencyMs: lastLatencyMs ?? this.lastLatencyMs,
      latencyLabel: latencyLabel ?? this.latencyLabel,
      isPendingAck: isPendingAck ?? this.isPendingAck,
    );
  }

  /// Initial default smart home setup for demo
  static List<SmartDevice> initialDevices() {
    return [
      const SmartDevice(
        id: 'light_living',
        name: 'Living Room Light',
        room: 'Living Room',
        type: DeviceType.light,
        isOn: true,
        primaryValue: 80,
        secondaryStatus: '3000K',
        isDemo: true,
        capabilities: ['power', 'brightness', 'colorTemperature'],
        latencyLabel: 'DEMO DEVICE RESPONSE',
        lastLatencyMs: 24,
      ),
      const SmartDevice(
        id: 'ac_living',
        name: 'AC / Climate',
        room: 'Living Room',
        type: DeviceType.ac,
        isOn: true,
        primaryValue: 22,
        secondaryStatus: 'COOL',
        isDemo: true,
        capabilities: ['power', 'temperature', 'mode'],
        latencyLabel: 'DEMO DEVICE RESPONSE',
        lastLatencyMs: 28,
      ),
      const SmartDevice(
        id: 'fan_living',
        name: 'Fan',
        room: 'Living Room',
        type: DeviceType.fan,
        isOn: true,
        primaryValue: 2,
        secondaryStatus: 'Speed 2',
        isDemo: true,
        capabilities: ['power', 'speed'],
        latencyLabel: 'DEMO DEVICE RESPONSE',
        lastLatencyMs: 20,
      ),
      const SmartDevice(
        id: 'speaker_living',
        name: 'Speaker',
        room: 'Living Room',
        type: DeviceType.speaker,
        isOn: true,
        primaryValue: 35,
        secondaryStatus: 'Ambient',
        isDemo: true,
        capabilities: ['power', 'volume', 'mode'],
        latencyLabel: 'DEMO DEVICE RESPONSE',
        lastLatencyMs: 22,
      ),
      const SmartDevice(
        id: 'plug_living',
        name: 'Smart Socket',
        room: 'Living Room',
        type: DeviceType.plug,
        isOn: true,
        primaryValue: 45,
        secondaryStatus: 'ON',
        isDemo: true,
        capabilities: ['power'],
        latencyLabel: 'DEMO DEVICE RESPONSE',
        lastLatencyMs: 18,
      ),
      const SmartDevice(
        id: 'workstation_node',
        name: 'Workstation',
        room: 'Personal Workspace',
        type: DeviceType.workstation,
        isOn: true,
        primaryValue: 1,
        secondaryStatus: 'FOCUS ACTIVE',
        isDemo: false,
        capabilities: ['focus', 'rest', 'break', 'restore', 'safe_state'],
        latencyLabel: 'LOCAL NODE TRANSPORT',
        lastLatencyMs: 14,
      ),
    ];
  }
}
