import 'dart:async';
import 'dart:math';
import 'ble_provider.dart';

class MockBleProvider implements BleProvider {
  final StreamController<List<BleDeviceInfo>> _controller =
      StreamController<List<BleDeviceInfo>>.broadcast();
  Timer? _scanTimer;
  bool _isScanning = false;
  final Random _random = Random();

  List<BleDeviceInfo> _devices = [
    BleDeviceInfo(
      id: 'SENS-AURA-BEACON-01',
      name: 'SensAura Living Room Beacon',
      rssi: -58,
      isHomeBeacon: true,
      lastSeen: DateTime.now(),
    ),
    BleDeviceInfo(
      id: 'IQOO-AUDIO-PRO',
      name: 'iQOO Hi-Res Audio Gateway',
      rssi: -66,
      isHomeBeacon: false,
      lastSeen: DateTime.now(),
    ),
    BleDeviceInfo(
      id: 'SMART-LIGHT-MESH',
      name: 'Aura Smart Mesh Bridge',
      rssi: -74,
      isHomeBeacon: false,
      lastSeen: DateTime.now(),
    ),
  ];

  @override
  Stream<List<BleDeviceInfo>> get discoveredDevicesStream => _controller.stream;

  @override
  List<BleDeviceInfo> get devices => List.unmodifiable(_devices);

  @override
  bool get isScanning => _isScanning;

  @override
  bool get isHomeBeaconPresent => _devices.any((d) => d.isHomeBeacon);

  @override
  String get providerName => 'SensAura BLE Emulation Engine';

  @override
  bool get isHardware => false;

  @override
  Future<void> startScan() async {
    if (_isScanning) return;
    _isScanning = true;
    _controller.add(_devices);

    _scanTimer?.cancel();
    _scanTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (!_isScanning) return;

      // Realistic RSSI fluctuating
      _devices = _devices.map((device) {
        final jitter = (_random.nextInt(5) - 2);
        return BleDeviceInfo(
          id: device.id,
          name: device.name,
          rssi: (device.rssi + jitter).clamp(-95, -45),
          isHomeBeacon: device.isHomeBeacon,
          lastSeen: DateTime.now(),
        );
      }).toList();

      _controller.add(_devices);
    });
  }

  @override
  Future<void> stopScan() async {
    _isScanning = false;
    _scanTimer?.cancel();
  }

  /// Programmatically simulate home beacon presence
  void setHomeBeaconPresence(bool present, {int rssi = -60}) {
    if (present) {
      if (!_devices.any((d) => d.isHomeBeacon)) {
        _devices.insert(
          0,
          BleDeviceInfo(
            id: 'SENS-AURA-BEACON-01',
            name: 'SensAura Living Room Beacon',
            rssi: rssi,
            isHomeBeacon: true,
            lastSeen: DateTime.now(),
          ),
        );
      } else {
        _devices = _devices.map((d) {
          if (d.isHomeBeacon) {
            return BleDeviceInfo(
              id: d.id,
              name: d.name,
              rssi: rssi,
              isHomeBeacon: true,
              lastSeen: DateTime.now(),
            );
          }
          return d;
        }).toList();
      }
    } else {
      _devices.removeWhere((d) => d.isHomeBeacon);
    }
    _controller.add(_devices);
  }

  @override
  void dispose() {
    _scanTimer?.cancel();
    _controller.close();
  }
}
