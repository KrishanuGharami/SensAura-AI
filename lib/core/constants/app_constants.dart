class AppConstants {
  static const String appName = 'SensAura AI';
  static const String appTagline = 'On-Device Contextual Home Assistant';
  static const String hackathonTrack = 'iQOO Hackathon 2026 • Smart Living';

  // Persistence keys
  static const String historyBoxName = 'sensaura_history_box';
  static const String settingsBoxName = 'sensaura_settings_box';

  // Thresholds for Context Inference
  static const double lowLightThresholdLux = 35.0;
  static const double highLightThresholdLux = 350.0;
  static const double lowMotionThreshold = 1.2; // Accel deviation from 9.8 m/s^2
  static const double highMotionThreshold = 4.0;
  static const double focusMotionThreshold = 0.8;

  // SensAura Context Guard Thresholds & Constants
  static const double minConfidenceAutoSafe = 0.85;
  static const double minConfidenceAskUser = 0.60;
  static const int cooldownDurationSeconds = 45;
  static const int manualOverrideDurationSeconds = 180;
  static const int hysteresisWindowSize = 3;

  // BLE Beacon Identifiers
  static const String homeBeaconUuid = 'SENS-HOME-BEACON-01';
  static const String deskBeaconUuid = 'SENS-DESK-BEACON-02';

  // Demo Timing
  static const int sensorUpdateIntervalMs = 800;
  static const int simulationStepCount = 12;
}
