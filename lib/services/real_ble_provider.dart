import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'ble_provider.dart';

/// Real BLE provider utilizing flutter_blue_plus.
/// Unsupported hardware and denied permissions remain unavailable; production
/// presence must never be inferred from simulated devices.
class RealBleProvider implements BleProvider {
  static const String homeBeaconServiceUuid = '0000feed-0000-1000-8000-00805f9b34fb';
  final StreamController<List<BleDeviceInfo>> _controller =
      StreamController<List<BleDeviceInfo>>.broadcast();
  StreamSubscription<List<ScanResult>>? _scanSubscription;
  List<BleDeviceInfo> _devices = [];
  bool _isScanning = false;
  bool _hardwareAvailable = false;

  @override
  Stream<List<BleDeviceInfo>> get discoveredDevicesStream => _controller.stream;

  @override
  List<BleDeviceInfo> get devices =>
      List.unmodifiable(_devices);

  @override
  bool get isScanning => _isScanning;

  @override
  bool get isHomeBeaconPresent {
    if (!_hardwareAvailable) return false;
    return _devices.any(
      (d) =>
          d.isHomeBeacon &&
          DateTime.now().difference(d.lastSeen) <= const Duration(seconds: 20),
    );
  }

  @override
  String get providerName => _hardwareAvailable
      ? 'Physical BLE Radio (flutter_blue_plus)'
      : 'BLE UNAVAILABLE';

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
        _devices = [];
        if (!_controller.isClosed) _controller.add(_devices);
        _isScanning = false;
        return;
      }

      _hardwareAvailable = true;
      _scanSubscription = FlutterBluePlus.scanResults.listen((results) {
        _devices = results.map((r) {
          final name = r.device.platformName.isNotEmpty
              ? r.device.platformName
              : 'BLE Peripheral (${r.device.remoteId.str.length > 5 ? r.device.remoteId.str.substring(0, 5) : r.device.remoteId.str})';
          final isHome = r.advertisementData.serviceUuids.any(
            (uuid) => uuid.toString().toLowerCase() == homeBeaconServiceUuid,
          );

          return BleDeviceInfo(
            id: r.device.remoteId.str,
            name: name,
            rssi: r.rssi,
            isHomeBeacon: isHome,
            lastSeen: DateTime.now(),
          );
        }).toList();

        if (!_controller.isClosed) _controller.add(_devices);
      });

      await FlutterBluePlus.startScan(timeout: const Duration(seconds: 15));
      _isScanning = false;
      _devices = _devices.where((d) =>
          DateTime.now().difference(d.lastSeen) <= const Duration(seconds: 20)).toList();
      _controller.add(_devices);
    } catch (e) {
      debugPrint('Real BLE radio scan failed; BLE presence is unavailable: $e');
      _hardwareAvailable = false;
      _devices = [];
      _controller.add(_devices);
      _isScanning = false;
    }
  }

  @override
  Future<void> stopScan() async {
    _isScanning = false;
    try {
      await FlutterBluePlus.stopScan();
      await _scanSubscription?.cancel();
    } catch (_) {}
    _hardwareAvailable = false;
    _devices = [];
    _controller.add(_devices);
    _isScanning = false;
  }

  @override
  void dispose() {
    _scanSubscription?.cancel();
    _controller.close();
  }
}
