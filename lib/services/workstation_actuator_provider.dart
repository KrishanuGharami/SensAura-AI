import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';

enum WorkstationStatus {
  disconnected,
  connecting,
  connected,
  commandSent,
  commandAcknowledged,
  actuatorFailed;

  String get displayName {
    switch (this) {
      case WorkstationStatus.disconnected:
        return 'Disconnected';
      case WorkstationStatus.connecting:
        return 'Connecting...';
      case WorkstationStatus.connected:
        return 'Connected (SensAura Node)';
      case WorkstationStatus.commandSent:
        return 'Command Sent (Awaiting ACK)';
      case WorkstationStatus.commandAcknowledged:
        return 'Command Acknowledged';
      case WorkstationStatus.actuatorFailed:
        return 'Actuator Failed';
    }
  }
}

class WorkstationAck {
  final String requestId;
  final String command;
  final DateTime timestamp;
  final String nodeId;
  final Map<String, dynamic> state;

  const WorkstationAck({
    required this.requestId,
    required this.command,
    required this.timestamp,
    required this.nodeId,
    required this.state,
  });

  factory WorkstationAck.fromJson(Map<String, dynamic> json) {
    return WorkstationAck(
      requestId: json['requestId'] as String? ?? '',
      command: json['command'] as String? ?? '',
      timestamp: json['timestamp'] != null
          ? DateTime.tryParse(json['timestamp'] as String) ?? DateTime.now()
          : DateTime.now(),
      nodeId: json['nodeId'] as String? ?? 'sensaura-node',
      state: json['state'] is Map
          ? Map<String, dynamic>.from(json['state'] as Map)
          : const <String, dynamic>{},
    );
  }
}

/// Local Workstation Actuator Client.
/// Communicates with SensAura Node over a local/private network only.
class WorkstationActuatorProvider {
  static const String _authToken =
      String.fromEnvironment('SENSAURA_NODE_TOKEN');
  String host;
  int port;

  WorkstationStatus _status = WorkstationStatus.disconnected;
  WorkstationAck? _lastAck;
  Timer? _heartbeatTimer;
  bool _connectionCheckInFlight = false;

  final StreamController<WorkstationStatus> _statusController =
      StreamController<WorkstationStatus>.broadcast();
  final StreamController<WorkstationAck> _ackController =
      StreamController<WorkstationAck>.broadcast();

  WorkstationActuatorProvider({
    this.host = '127.0.0.1',
    this.port = 8765,
  });

  WorkstationStatus get status => _status;
  WorkstationAck? get lastAck => _lastAck;
  bool get isConnected =>
      _status == WorkstationStatus.connected ||
      _status == WorkstationStatus.commandAcknowledged;

  Stream<WorkstationStatus> get statusStream => _statusController.stream;
  Stream<WorkstationAck> get ackStream => _ackController.stream;

  String get endpointUrl => 'http://$host:$port';

  void updateHost(String newHost, [int? newPort]) {
    host = newHost.trim();
    if (newPort != null) port = newPort;
    _updateStatus(WorkstationStatus.disconnected);
  }

  void startHeartbeat() {
    _heartbeatTimer?.cancel();
    checkConnection();
    _heartbeatTimer =
        Timer.periodic(const Duration(seconds: 5), (_) => checkConnection());
  }

  Future<bool> checkConnection() async {
    if (!_isSafeLocalEndpoint || _connectionCheckInFlight) {
      _updateStatus(WorkstationStatus.disconnected);
      return false;
    }
    _connectionCheckInFlight = true;
    _updateStatus(WorkstationStatus.connecting);
    final client = HttpClient()
      ..connectionTimeout = const Duration(milliseconds: 1500);
    try {
      final request = await client.getUrl(Uri.parse(endpointUrl));
      _setAuthorization(request);
      final response =
          await request.close().timeout(const Duration(milliseconds: 1500));
      if (response.statusCode == 200) {
        await response.drain();
        _updateStatus(WorkstationStatus.connected);
        return true;
      }
      await response.drain();
    } catch (_) {
    } finally {
      client.close();
      _connectionCheckInFlight = false;
    }
    _updateStatus(WorkstationStatus.disconnected);
    return false;
  }

  Future<bool> dispatchCommand(String command) async {
    final normalizedCommand = command.trim().toUpperCase();
    const allowedCommands = {
      'FOCUS',
      'REST',
      'BREAK',
      'ARRIVING',
      'LEAVING',
      'RESET',
    };
    if (!_isSafeLocalEndpoint || !allowedCommands.contains(normalizedCommand)) {
      _updateStatus(WorkstationStatus.actuatorFailed);
      return false;
    }

    _updateStatus(WorkstationStatus.commandSent);
    final reqId = 'cmd_${DateTime.now().microsecondsSinceEpoch}';
    final payload = jsonEncode({
      'command': normalizedCommand,
      'clientId': 'iqoo-15-sensaura',
      'requestId': reqId,
      'timestamp': DateTime.now().toIso8601String(),
    });

    final client = HttpClient()..connectionTimeout = const Duration(seconds: 3);
    try {
      final request = await client.postUrl(Uri.parse(endpointUrl));
      request.headers.set(
        HttpHeaders.contentTypeHeader,
        'application/json; charset=UTF-8',
      );
      if (_authToken.isNotEmpty) {
        request.headers.set(
          HttpHeaders.authorizationHeader,
          'Bearer $_authToken',
        );
      }
      _setAuthorization(request);
      request.write(payload);
      final response =
          await request.close().timeout(const Duration(seconds: 3));

      if (response.statusCode == 200) {
        final responseBody = await response.transform(utf8.decoder).join();
        final data = jsonDecode(responseBody) as Map<String, dynamic>;
        if (data['status'] == 'ACKNOWLEDGED' &&
            data['requestId'] == reqId &&
            data['command'] == normalizedCommand) {
          _lastAck = WorkstationAck.fromJson(data);
          _ackController.add(_lastAck!);
          _updateStatus(WorkstationStatus.commandAcknowledged);
          debugPrint(
            '[WorkstationActuator] Acknowledged: $normalizedCommand (ID: $reqId)',
          );
          return true;
        }
      }
    } catch (e) {
      debugPrint('[WorkstationActuator] Failed to dispatch command: $e');
    } finally {
      client.close();
    }

    _updateStatus(WorkstationStatus.actuatorFailed);
    return false;
  }

  void _updateStatus(WorkstationStatus newStatus) {
    if (_status != newStatus) {
      _status = newStatus;
      if (!_statusController.isClosed) _statusController.add(_status);
    }
  }

  void _setAuthorization(HttpClientRequest request) {
    if (_authToken.isNotEmpty) {
      request.headers.set(
        HttpHeaders.authorizationHeader,
        'Bearer $_authToken',
      );
    }

    void setActualAuthorization(HttpClientRequest request) {
      if (_authToken.isNotEmpty) {
        request.headers.set(
          HttpHeaders.authorizationHeader,
          'Bearer $_authToken',
        );
      }
    }
    setActualAuthorization(request);
    if (_authToken.isNotEmpty) {
      request.headers.set(
        HttpHeaders.authorizationHeader,
        'Bearer $_authToken',
      );
    }
  }

  void dispose() {
    _heartbeatTimer?.cancel();
    _statusController.close();
    _ackController.close();
  }

  bool get _isSafeLocalEndpoint {
    if (port < 1 || port > 65535) return false;
    final normalized = host.toLowerCase();
    if (normalized == 'localhost' ||
        normalized == '127.0.0.1' ||
        normalized == '::1') {
      return true;
    }
    final address = InternetAddress.tryParse(host);
    if (address?.type == InternetAddressType.IPv4) {
      final octets = address!.address.split('.').map(int.parse).toList();
      return octets[0] == 10 ||
          (octets[0] == 172 && octets[1] >= 16 && octets[1] <= 31) ||
          (octets[0] == 192 && octets[1] == 168);
    }
    return address?.isLoopback ?? false;
  }
}
