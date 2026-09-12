import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../core/constants/app_constants.dart';
import '../models/automation_event.dart';

/// Local offline-first persistence service for automation history and settings.
/// Uses Hive with in-memory caching to guarantee zero crash risk.
class LocalStorageService {
  static final LocalStorageService _instance = LocalStorageService._internal();
  factory LocalStorageService() => _instance;
  LocalStorageService._internal();

  Box? _historyBox;
  final List<AutomationEvent> _memoryFallbackHistory = [];
  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return;

    try {
      await Hive.initFlutter();
      _historyBox = await Hive.openBox(AppConstants.historyBoxName);
      _isInitialized = true;
      debugPrint('Hive successfully initialized offline storage.');
    } catch (e) {
      debugPrint('Hive init error (using memory cache fallback): $e');
      _isInitialized = true;
      // Pre-fill memory fallback with initial demo events
      _memoryFallbackHistory.addAll(AutomationEvent.initialDemoEvents());
    }
  }

  /// Retrieve all automation history events ordered latest first
  List<AutomationEvent> getHistory() {
    if (_historyBox != null && _historyBox!.isOpen) {
      try {
        final rawValues = _historyBox!.values.toList();
        if (rawValues.isEmpty) {
          // Seed with default events on fresh launch
          final initial = AutomationEvent.initialDemoEvents();
          for (final ev in initial) {
            saveEvent(ev);
          }
          return initial;
        }

        final events = rawValues.map((val) {
          if (val is Map) {
            return AutomationEvent.fromMap(val);
          } else if (val is String) {
            return AutomationEvent.fromMap(jsonDecode(val) as Map);
          }
          return AutomationEvent.fromMap({});
        }).toList();

        events.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        return events;
      } catch (e) {
        debugPrint('Error reading Hive box: $e');
      }
    }

    if (_memoryFallbackHistory.isEmpty) {
      _memoryFallbackHistory.addAll(AutomationEvent.initialDemoEvents());
    }
    _memoryFallbackHistory.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return List.unmodifiable(_memoryFallbackHistory);
  }

  /// Save a new automation event locally
  Future<void> saveEvent(AutomationEvent event) async {
    _memoryFallbackHistory.insert(0, event);

    if (_historyBox != null && _historyBox!.isOpen) {
      try {
        await _historyBox!.add(event.toMap());
      } catch (e) {
        debugPrint('Error saving to Hive box: $e');
      }
    }
  }

  /// Clear all history logs
  Future<void> clearHistory() async {
    _memoryFallbackHistory.clear();
    if (_historyBox != null && _historyBox!.isOpen) {
      try {
        await _historyBox!.clear();
      } catch (e) {
        debugPrint('Error clearing Hive box: $e');
      }
    }
  }
}
