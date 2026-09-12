import 'package:flutter/material.dart';

enum DeviceType {
  light,
  ac,
  fan,
  speaker,
  plug;

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
  final String secondaryStatus; // e.g., 'Warm 2700K', 'Quiet', 'Lo-Fi Chill'

  const SmartDevice({
    required this.id,
    required this.name,
    required this.room,
    required this.type,
    required this.isOn,
    required this.primaryValue,
    required this.secondaryStatus,
  });

  SmartDevice copyWith({
    String? id,
    String? name,
    String? room,
    DeviceType? type,
    bool? isOn,
    int? primaryValue,
    String? secondaryStatus,
  }) {
    return SmartDevice(
      id: id ?? this.id,
      name: name ?? this.name,
      room: room ?? this.room,
      type: type ?? this.type,
      isOn: isOn ?? this.isOn,
      primaryValue: primaryValue ?? this.primaryValue,
      secondaryStatus: secondaryStatus ?? this.secondaryStatus,
    );
  }

  /// Initial default smart home setup for demo
  static List<SmartDevice> initialDevices() {
    return [
      const SmartDevice(
        id: 'light_living',
        name: 'Living Light',
        room: 'Living Room',
        type: DeviceType.light,
        isOn: true,
        primaryValue: 50,
        secondaryStatus: 'Natural 3500K',
      ),
      const SmartDevice(
        id: 'ac_living',
        name: 'Dual Inverter AC',
        room: 'Living Room',
        type: DeviceType.ac,
        isOn: true,
        primaryValue: 24,
        secondaryStatus: 'Auto',
      ),
      const SmartDevice(
        id: 'fan_living',
        name: 'Aura Smart Fan',
        room: 'Living Room',
        type: DeviceType.fan,
        isOn: false,
        primaryValue: 0,
        secondaryStatus: 'Standby',
      ),
      const SmartDevice(
        id: 'speaker_living',
        name: 'Studio Speaker',
        room: 'Living Room',
        type: DeviceType.speaker,
        isOn: false,
        primaryValue: 0,
        secondaryStatus: 'Idle',
      ),
      const SmartDevice(
        id: 'plug_living',
        name: 'Smart Socket',
        room: 'Living Room',
        type: DeviceType.plug,
        isOn: true,
        primaryValue: 30,
        secondaryStatus: 'Active load',
      ),
    ];
  }
}
