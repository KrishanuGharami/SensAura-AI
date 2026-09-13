import 'dart:async';
import '../models/actuator_command.dart';
import '../models/smart_device.dart';
import 'actuator_provider.dart';

/// Deterministic, offline-first local actuator simulator representing the
/// Demo Connected Environment.
///
/// Jury transparency guarantee:
/// - Represents virtual smart living endpoints without external IoT appliances.
/// - Uses a small deterministic simulated transport delay (~25ms) strictly labelled
///   "DEMO DEVICE RESPONSE".
/// - Never manufactures real BLE devices or falsifies physical hardware telemetry.
class DemoEnvironmentActuator implements ActuatorProvider {
  static const String demoLatencyLabel = 'DEMO DEVICE RESPONSE';

  final Map<String, SmartDevice> _devices = {};
  final StreamController<SmartDevice> _stateController =
      StreamController<SmartDevice>.broadcast();

  ActuatorConnectionState _connectionState =
      ActuatorConnectionState.disconnected;

  /// Deterministic simulated transport delay for demonstration purposes.
  int simulatedLatencyMs;

  /// Testing hook to verify retry and error handling.
  bool simulateFailure = false;
  int failureCount = 0;

  DemoEnvironmentActuator({this.simulatedLatencyMs = 25}) {
    resetToDefault();
  }

  void resetToDefault() {
    _devices.clear();
    for (final dev in SmartDevice.initialDevices()) {
      _devices[dev.id] = dev;
    }
  }

  @override
  String get providerId => 'demo_environment_actuator';

  @override
  String get providerName => 'Demo Connected Environment';

  @override
  bool get isPhysicalHardware => false;

  @override
  ActuatorConnectionState get connectionState => _connectionState;

  @override
  List<String> get capabilities => [
        'power',
        'brightness',
        'colorTemperature',
        'temperature',
        'mode',
        'speed',
        'volume',
        'focus',
        'rest',
        'break',
        'restore',
        'safe_state',
      ];

  @override
  Stream<SmartDevice> get stateChanges => _stateController.stream;

  @override
  Future<bool> connect() async {
    _connectionState = ActuatorConnectionState.demoActive;
    return true;
  }

  @override
  Future<void> disconnect() async {
    _connectionState = ActuatorConnectionState.disconnected;
  }

  @override
  Future<List<SmartDevice>> discoverDevices() async {
    return _devices.values.toList();
  }

  @override
  SmartDevice? getDeviceState(String deviceId) {
    return _devices[deviceId];
  }

  @override
  Future<ActuatorCommandResult> applyCommand(ActuatorCommand command) async {
    final device = _devices[command.deviceId];
    if (device == null) {
      return ActuatorCommandResult.failure(
        commandId: command.commandId,
        deviceId: command.deviceId,
        message: 'Device not found in demo environment: ${command.deviceId}',
        latencyMs: 0,
        latencyLabel: demoLatencyLabel,
      );
    }

    // Deterministic simulated device response delay
    if (simulatedLatencyMs > 0) {
      await Future.delayed(Duration(milliseconds: simulatedLatencyMs));
    }

    // Check for simulated failure testing hook
    if (simulateFailure) {
      failureCount++;
      return ActuatorCommandResult.failure(
        commandId: command.commandId,
        deviceId: command.deviceId,
        message: 'Simulated demo actuator transient failure',
        latencyMs: simulatedLatencyMs,
        latencyLabel: demoLatencyLabel,
      );
    }

    // Extract requested target state
    final req = command.requestedState;
    final bool nextIsOn = req['isOn'] as bool? ?? device.isOn;

    int nextPrimary = device.primaryValue;
    if (req.containsKey('brightness')) {
      nextPrimary = (req['brightness'] as num).toInt();
    } else if (req.containsKey('temperature')) {
      nextPrimary = (req['temperature'] as num).toInt();
    } else if (req.containsKey('speed')) {
      nextPrimary = (req['speed'] as num).toInt();
    } else if (req.containsKey('volume')) {
      nextPrimary = (req['volume'] as num).toInt();
    } else if (req.containsKey('powerWatts')) {
      nextPrimary = (req['powerWatts'] as num).toInt();
    } else if (req.containsKey('primaryValue')) {
      nextPrimary = (req['primaryValue'] as num).toInt();
    }

    String nextSecondary = device.secondaryStatus;
    if (req.containsKey('colorTemp')) {
      nextSecondary = req['colorTemp'].toString();
    } else if (req.containsKey('mode')) {
      nextSecondary = req['mode'].toString();
    } else if (req.containsKey('track')) {
      nextSecondary = req['track'].toString();
    } else if (req.containsKey('profile')) {
      nextSecondary = req['profile'].toString();
    } else if (req.containsKey('secondaryStatus')) {
      nextSecondary = req['secondaryStatus'].toString();
    }

    final now = DateTime.now();
    final updated = device.copyWith(
      isOn: nextIsOn,
      primaryValue: nextPrimary,
      secondaryStatus: nextSecondary,
      lastCommandName: command.commandName,
      lastAckTime: now,
      lastLatencyMs: simulatedLatencyMs,
      latencyLabel: demoLatencyLabel,
      isPendingAck: false,
    );

    _devices[device.id] = updated;
    _stateController.add(updated);

    return ActuatorCommandResult(
      success: true,
      commandId: command.commandId,
      deviceId: device.id,
      acknowledgedAt: now,
      latencyMs: simulatedLatencyMs,
      latencyLabel: demoLatencyLabel,
      message: 'Command acknowledged by demo actuator',
      resultingState: {
        'isOn': nextIsOn,
        'primaryValue': nextPrimary,
        'secondaryStatus': nextSecondary,
      },
    );
  }

  @override
  Future<ActuatorCommandResult> acknowledgeCommand(String commandId) async {
    return ActuatorCommandResult(
      success: true,
      commandId: commandId,
      deviceId: 'demo_environment',
      acknowledgedAt: DateTime.now(),
      latencyMs: simulatedLatencyMs,
      latencyLabel: demoLatencyLabel,
    );
  }

  void dispose() {
    _stateController.close();
  }
}
