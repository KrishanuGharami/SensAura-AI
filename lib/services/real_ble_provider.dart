import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'ble_provider.dart';
import 'mock_ble_provider.dart';

/// Real BLE provider utilizing flutter_blue_plus with automatic mock fallback.
/// Guarantees that Bluetooth permission denial, desktop execution, or unsupported
/// hardware will never crash the demo.
class RealBleProvider implements BleProvider {
  final StreamController<List<BleDeviceInfo>> _controller =
      StreamController<List<BleDeviceInfo>>.broadcast();
  final MockBleProvider _fallback = MockBleProvider();

  StreamSubscription<List<ScanResult>>? _scanSubscription;
  List<BleDeviceInfo> _devices = [];
  bool _isScanning = false;
  bool _hardwareAvailable = false;

  @override
  Stream<List<BleDeviceInfo>> get discoveredDevicesStream => _controller.stream;

  @override
  List<BleDeviceInfo> get devices =>
      _hardwareAvailable ? List.unmodifiable(_devices) : _fallback.devices;

  @override
  bool get isScanning => _isScanning;

  @override
  bool get isHomeBeaconPresent {
    if (_hardwareAvailable) {
      return _devices.any((d) => d.isHomeBeacon);
    }
    return _fallback.isHomeBeaconPresent;
  }

  @override
  String get providerName => _hardwareAvailable
      ? 'Physical BLE Radio (flutter_blue_plus)'
      : 'BLE Fallback (Local Emulation)';

  @override
  bool get isHardware => _hardwareAvailable;

  @override
  Future<void> startScan() async {
    if (_isScanning) return;
    _isScanning = true;

    try {
      final isSupported = await FlutterBluePlus.isSupported;
      if (!isSupported) {
        _hardwareAvailable = false;
        await _fallback.startScan();
        _fallback.discoveredDevicesStream.listen((list) => _controller.add(list));
        return;
      }

      _hardwareAvailable = true;
      _scanSubscription = FlutterBluePlus.scanResults.listen((results) {
        _devices = results.map((r) {
          final name = r.device.platformName.isNotEmpty
              ? r.device.platformName
              : 'BLE Peripheral (${r.device.remoteId.str.substring(0, 5)})';
          final isHome = name.toLowerCase().contains('aura') ||
              name.toLowerCase().contains('beacon') ||
              r.device.remoteId.str.contains('01');

          return BleDeviceInfo(
            id: r.device.remoteId.str,
            name: name,
            rssi: r.rssi,
            isHomeBeacon: isHome,
            lastSeen: DateTime.now(),
          );
        }).toList();

        _controller.add(_devices);
      });

      await FlutterBluePlus.startScan(timeout: const Duration(seconds: 15));
    } catch (e) {
      debugPrint('Real BLE radio scan failed, seamlessly activating mock fallback: $e');
      _hardwareAvailable = false;
      await _fallback.startScan();
      _fallback.discoveredDevicesStream.listen((list) => _controller.add(list));
    }
  }

  @override
  Future<void> stopScan() async {
    _isScanning = false;
    try {
      await FlutterBluePlus.stopScan();
      await _scanSubscription?.cancel();
    } catch (_) {}
    await _fallback.stopScan();
  }

  @override
  void dispose() {
    _scanSubscription?.cancel();
    _fallback.dispose();
    _controller.close();
  }
}
