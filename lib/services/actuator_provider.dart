import '../models/actuator_command.dart';
import '../models/smart_device.dart';

/// Clean actuator abstraction for all physical and virtual smart-space targets.
/// Completely decouples the UI and Automation Engine from concrete transport protocols
/// (Demo Simulator, BLE GATT, Local Network / SensAura Node).
abstract class ActuatorProvider {
  /// Unique identifier of the actuator provider.
  String get providerId;

  /// Human-readable provider name.
  String get providerName;

  /// True if this provider communicates with verified physical silicon/appliances.
  /// False if this provider represents a virtual/demo environment.
  bool get isPhysicalHardware;

  /// Current connection state of the provider.
  ActuatorConnectionState get connectionState;

  /// Set of capabilities supported across devices managed by this provider.
  List<String> get capabilities;

  /// Real-time stream of device state changes.
  Stream<SmartDevice> get stateChanges;

  /// Establish or initialize the connection to the actuator endpoint.
  Future<bool> connect();

  /// Gracefully disconnect from the actuator endpoint.
  Future<void> disconnect();

  /// Discover or enumerate all accessible devices.
  Future<List<SmartDevice>> discoverDevices();

  /// Query the current in-memory or hardware state of a specific device.
  SmartDevice? getDeviceState(String deviceId);

  /// Apply a requested state change command to a target device.
  Future<ActuatorCommandResult> applyCommand(ActuatorCommand command);

  /// Explicitly acknowledge or query the acknowledgement of a command.
  Future<ActuatorCommandResult> acknowledgeCommand(String commandId);
}

/// Future-ready interface for local-network or Matter/LAN smart actuators.
abstract class LocalNetworkActuator extends ActuatorProvider {
  String get host;
  int get port;
  Future<bool> ping();
}
