import 'package:flutter/material.dart';

/// Execution lifecycle of an actuator command.
enum ActuatorCommandStatus {
  pending,
  acknowledged,
  failed;

  String get displayName {
    switch (this) {
      case ActuatorCommandStatus.pending:
        return 'Pending';
      case ActuatorCommandStatus.acknowledged:
        return 'Acknowledged';
      case ActuatorCommandStatus.failed:
        return 'Failed';
    }
  }

  Color get color {
    switch (this) {
      case ActuatorCommandStatus.pending:
        return const Color(0xFFFFB300); // Amber
      case ActuatorCommandStatus.acknowledged:
        return const Color(0xFF00E676); // Emerald Green
      case ActuatorCommandStatus.failed:
        return const Color(0xFFFF5252); // Red
    }
  }
}

/// Connection status of an actuator endpoint.
enum ActuatorConnectionState {
  disconnected,
  connecting,
  connected,
  demoActive;

  String get displayName {
    switch (this) {
      case ActuatorConnectionState.disconnected:
        return 'Disconnected';
      case ActuatorConnectionState.connecting:
        return 'Connecting...';
      case ActuatorConnectionState.connected:
        return 'Connected (Physical)';
      case ActuatorConnectionState.demoActive:
        return 'Demo Online';
    }
  }

  bool get isOnline =>
      this == ActuatorConnectionState.connected ||
      this == ActuatorConnectionState.demoActive;

  Color get color {
    switch (this) {
      case ActuatorConnectionState.disconnected:
        return const Color(0xFF9E9E9E);
      case ActuatorConnectionState.connecting:
        return const Color(0xFFFFB300);
      case ActuatorConnectionState.connected:
        return const Color(0xFF00E676);
      case ActuatorConnectionState.demoActive:
        return const Color(0xFF00E5FF); // Cyber Cyan
    }
  }
}

/// Strongly-typed command dispatched to an actuator endpoint.
class ActuatorCommand {
  final String commandId;
  final DateTime timestamp;
  final String deviceId;
  final String commandName;
  final Map<String, dynamic> requestedState;
  final ActuatorCommandStatus status;
  final DateTime? acknowledgedAt;
  final int? latencyMs;
  final String latencyLabel;
  final String? errorMessage;

  const ActuatorCommand({
    required this.commandId,
    required this.timestamp,
    required this.deviceId,
    required this.commandName,
    required this.requestedState,
    this.status = ActuatorCommandStatus.pending,
    this.acknowledgedAt,
    this.latencyMs,
    this.latencyLabel = 'DEMO DEVICE RESPONSE',
    this.errorMessage,
  });

  ActuatorCommand copyWith({
    String? commandId,
    DateTime? timestamp,
    String? deviceId,
    String? commandName,
    Map<String, dynamic>? requestedState,
    ActuatorCommandStatus? status,
    DateTime? acknowledgedAt,
    int? latencyMs,
    String? latencyLabel,
    String? errorMessage,
  }) {
    return ActuatorCommand(
      commandId: commandId ?? this.commandId,
      timestamp: timestamp ?? this.timestamp,
      deviceId: deviceId ?? this.deviceId,
      commandName: commandName ?? this.commandName,
      requestedState: requestedState ?? this.requestedState,
      status: status ?? this.status,
      acknowledgedAt: acknowledgedAt ?? this.acknowledgedAt,
      latencyMs: latencyMs ?? this.latencyMs,
      latencyLabel: latencyLabel ?? this.latencyLabel,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

/// Explicit acknowledgement returned by an actuator after command processing.
class ActuatorCommandResult {
  final bool success;
  final String commandId;
  final String deviceId;
  final DateTime acknowledgedAt;
  final int latencyMs;
  final String latencyLabel;
  final String? message;
  final Map<String, dynamic>? resultingState;

  const ActuatorCommandResult({
    required this.success,
    required this.commandId,
    required this.deviceId,
    required this.acknowledgedAt,
    required this.latencyMs,
    this.latencyLabel = 'DEMO DEVICE RESPONSE',
    this.message,
    this.resultingState,
  });

  factory ActuatorCommandResult.failure({
    required String commandId,
    required String deviceId,
    required String message,
    int latencyMs = 0,
    String latencyLabel = 'DEMO DEVICE RESPONSE',
  }) {
    return ActuatorCommandResult(
      success: false,
      commandId: commandId,
      deviceId: deviceId,
      acknowledgedAt: DateTime.now(),
      latencyMs: latencyMs,
      latencyLabel: latencyLabel,
      message: message,
    );
  }
}
