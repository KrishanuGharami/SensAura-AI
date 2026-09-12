import 'dart:async';

class BleDeviceInfo {
  final String id;
  final String name;
  final int rssi;
  final bool isHomeBeacon;
  final DateTime lastSeen;

  const BleDeviceInfo({
    required this.id,
    required this.name,
    required this.rssi,
    required this.isHomeBeacon,
    required this.lastSeen,
  });

  /// Signal strength categorized
  String get signalQuality {
    if (rssi >= -60) return 'Excellent';
    if (rssi >= -75) return 'Good';
    if (rssi >= -85) return 'Fair';
    return 'Weak';
  }
}

/// Abstract contract for Bluetooth Low Energy presence detection.
abstract class BleProvider {
  /// Stream of discovered nearby BLE peripherals
  Stream<List<BleDeviceInfo>> get discoveredDevicesStream;

  /// Current list of detected devices
  List<BleDeviceInfo> get devices;

  /// Whether Bluetooth scanning is actively executing
  bool get isScanning;

  /// Whether the designated home environment beacon is present
  bool get isHomeBeaconPresent;

  /// Start BLE scanner
  Future<void> startScan();

  /// Stop BLE scanner
  Future<void> stopScan();

  /// Provider identifier
  String get providerName;

  /// Whether backed by physical Bluetooth hardware
  bool get isHardware;

  /// Dispose
  void dispose();
}
