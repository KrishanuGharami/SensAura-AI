import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

enum BleActuatorType {
  smartLight,
  powerSwitch,
  environmentalNode,
  unknown;

  String get label {
    switch (this) {
      case BleActuatorType.smartLight:
        return 'GATT Smart Light';
      case BleActuatorType.powerSwitch:
        return 'GATT Power Switch';
      case BleActuatorType.environmentalNode:
        return 'Sensor Node';
      case BleActuatorType.unknown:
        return 'Standard BLE Peripheral';
    }
  }
}

class BleActuatorDevice {
  final String id;
  final String name;
  final int rssi;
  final bool isControllable;
  final BleActuatorType type;
  final List<String> capabilities;
  final bool isConnected;

  const BleActuatorDevice({
    required this.id,
    required this.name,
    required this.rssi,
    required this.isControllable,
    required this.type,
    required this.capabilities,
    this.isConnected = false,
  });
}

class BleActuatorProvider {
  final StreamController<List<BleActuatorDevice>> _devicesController =
      StreamController<List<BleActuatorDevice>>.broadcast();

  StreamSubscription<List<ScanResult>>? _scanSub;
  List<BleActuatorDevice> _actuators = [];
  bool _isScanning = false;
  String _statusMessage = 'BLE actuator discovery is read-only; no writes configured.';

  Stream<List<BleActuatorDevice>> get devicesStream => _devicesController.stream;
  List<BleActuatorDevice> get actuators => List.unmodifiable(_actuators);
  bool get isScanning => _isScanning;
  String get statusMessage => _statusMessage;
  bool get hasControllableActuator => _actuators.any((d) => d.isControllable);

  Future<void> startDiscovery() async {
    if (_isScanning) return;
    _isScanning = true;

    try {
      final isSupported = await FlutterBluePlus.isSupported;
      if (!isSupported) {
        _statusMessage = 'BLE radio unsupported on platform — no actuator writes available.';
        _isScanning = false;
        return;
      }

      _scanSub = FlutterBluePlus.scanResults.listen((results) {
        _actuators = results.map((r) {
          final name = r.device.platformName.isNotEmpty
              ? r.device.platformName
              : 'BLE Device (${r.device.remoteId.str.length > 5 ? r.device.remoteId.str.substring(0, 5) : r.device.remoteId.str})';

          // Discovery alone is not proof that a peripheral accepts writes.
          // This provider intentionally has no GATT connection/characteristic
          // implementation yet, so every discovered device is read-only.
          const isControllable = false;
          const type = BleActuatorType.unknown;
          const caps = <String>['Discovery only — no writes enabled'];

          return BleActuatorDevice(
            id: r.device.remoteId.str,
            name: name,
            rssi: r.rssi,
            isControllable: isControllable,
            type: type,
            capabilities: caps,
          );
        }).toList();

        _statusMessage =
            'BLE devices discovered, but safe GATT writes are not configured.';

        _devicesController.add(_actuators);
      });

      await FlutterBluePlus.startScan(timeout: const Duration(seconds: 12));
    } catch (e) {
      debugPrint('[BleActuatorProvider] Discovery error: $e');
      _statusMessage = 'BLE actuator discovery unavailable — no writes will be attempted.';
      _isScanning = false;
    }
  }

  Future<void> stopDiscovery() async {
    _isScanning = false;
    try {
      await FlutterBluePlus.stopScan();
      await _scanSub?.cancel();
    } catch (_) {}
    _scanSub = null;
    _actuators = [];
  }

  void dispose() {
    stopDiscovery();
    _devicesController.close();
  }
}
