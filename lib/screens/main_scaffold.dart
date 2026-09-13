import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../l10n/app_localizations.dart';
import '../models/vision_context_sample.dart';
import '../services/automation_service.dart';
import '../widgets/status_app_bar.dart';
import 'ai_context_screen.dart';
import 'connected_devices_screen.dart';
import 'history_screen.dart';
import 'home_screen.dart';
import 'live_sensors_screen.dart';

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _currentIndex = 0;
  final AutomationService _automation = AutomationService();

  @override
  void initState() {
    super.initState();
    _automation.init();
    _automation.addListener(_onStateChange);
  }

  @override
  void dispose() {
    _automation.removeListener(_onStateChange);
    super.dispose();
  }

  void _onStateChange() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final screens = [
      // 1. HOME
      HomeScreen(
        contextResult: _automation.latestContextResult,
        sensorSnapshot: _automation.latestSnapshot,
        isApplyingScene: _automation.isApplyingScene,
        onInjectScenario: (scenario) {
          _automation.injectScenario(scenario);
          _showFeedbackBanner('Injected scenario: ${scenario.label}');
        },
        onApplyScene: (scene) {
          _automation.applyScene(scene, manual: true);
          _showFeedbackBanner('Applied: ${scene.title}');
        },
        onNavigateToSensors: () => setState(() => _currentIndex = 1),
        onNavigateToEnvironment: () => setState(() => _currentIndex = 2),
        onNavigateToAi: () => setState(() => _currentIndex = 3),
        onClearOverride: () {
          _automation.clearManualOverride();
          _showFeedbackBanner('Manual device lock released');
        },
        onResetCooldown: () {
          _automation.resetCooldown();
          _showFeedbackBanner('Automation cooldown timer reset');
        },
      ),

      // 2. LIVE SENSORS
      LiveSensorsScreen(
        snapshot: _automation.latestSnapshot,
        bleDevices: _automation.currentBleProvider.devices,
        latencyMs: _automation.latestContextResult.inferenceLatencyMs,
        isHardware: _automation.isHardwareMode,
        hardwareAvailable: _automation.currentSensorProvider.isHardware,
        onToggleHardware: (val) {
          _automation.toggleHardwareMode(val);
          _showFeedbackBanner(
            val ? 'Switched to LIVE HARDWARE' : 'Switched to DEMO SIMULATION',
          );
        },
      ),

      // 3. CONNECTED ENVIRONMENT (Demo Smart Space & Physical Nodes)
      ConnectedDevicesScreen(
        workstationActuator: _automation.workstationActuator,
        bleActuator: _automation.bleActuator,
        demoActuator: _automation.demoActuator,
        devices: _automation.devices,
        timeline: _automation.timeline,
        isManualOverrideActive: _automation.isManualOverrideActive,
        manualOverrideRemaining: _automation.manualOverrideRemaining,
        onUpdateDevice: _automation.updateDevice,
        onClearOverride: () {
          _automation.clearManualOverride();
          _showFeedbackBanner('Manual override lease released');
        },
        onResetCooldown: () {
          _automation.resetCooldown();
          _showFeedbackBanner('Automation cooldown timer reset');
        },
      ),

      // 4. AI EXPLANATION & VISION INTENT
      AiContextScreen(
        result: _automation.latestContextResult,
        visionSample: _automation.latestVision,
        cameraProvider: _automation.cameraProvider,
        isAutomationPaused: _automation.isAutomationPausedByGesture,
        isApplyingScene: _automation.isApplyingScene,
        onApplyScene: (scene) {
          _automation.applyScene(scene, manual: true);
          _showFeedbackBanner('Applied: ${scene.title}');
        },
        onPauseAutomation: () {
          _automation.pauseAutomationByGesture();
          _showFeedbackBanner('Automation paused by user');
        },
        onResumeAutomation: () {
          _automation.resumeAutomation();
          _showFeedbackBanner('Automation resumed');
        },
        onInjectGesture: (gesture) {
          _automation.injectVisionSample(
            _automation.latestVision.copyWith(
              gesture: gesture,
              gestureConfidence: gesture == HandGesture.none ? 0.0 : 0.95,
              timestamp: DateTime.now(),
            ),
          );
          _showFeedbackBanner('Triggered gesture: ${gesture.displayName}');
        },
      ),

      // 5. HISTORY
      HistoryScreen(
        events: _automation.history,
        onClearHistory: () {
          _automation.clearHistory();
          _showFeedbackBanner('Audit log cleared');
        },
      ),
    ];

    return Scaffold(
      appBar: StatusAppBar(
        isHardware: _automation.isHardwareMode,
        hardwareAvailable: _automation.currentSensorProvider.isHardware,
        isSensorAvailable: !_automation.isHardwareMode ||
            (_automation.latestSnapshot.hasAccel &&
                _automation.latestSnapshot.hasLight &&
                !_automation.latestSnapshot.isStale()),
        isBleAvailable: !_automation.isHardwareMode ||
            _automation.currentBleProvider.isHardware,
        onToggleHardware: () {
          _automation.toggleHardwareMode(!_automation.isHardwareMode);
          _showFeedbackBanner(
            _automation.isHardwareMode
                ? 'Switched to LIVE HARDWARE'
                : 'Switched to DEMO SIMULATION',
          );
        },
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.backgroundSecondary,
          border: Border(top: BorderSide(color: AppColors.borderSubtle, width: 0.8)),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          backgroundColor: AppColors.backgroundSecondary,
          selectedItemColor: AppColors.primaryAmber,
          unselectedItemColor: AppColors.textMuted,
          type: BottomNavigationBarType.fixed,
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.home_outlined),
              activeIcon: const Icon(Icons.home_rounded),
              label: l10n?.tabHome ?? 'Home',
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.sensors_outlined),
              activeIcon: const Icon(Icons.sensors_rounded),
              label: l10n?.tabSensors ?? 'Sensors',
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.devices_other_outlined),
              activeIcon: const Icon(Icons.devices_other_rounded),
              label: l10n?.tabEnvironment ?? 'Environment',
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.psychology_outlined),
              activeIcon: const Icon(Icons.psychology_rounded),
              label: l10n?.tabAiContext ?? 'AI Context',
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.history_toggle_off_rounded),
              activeIcon: const Icon(Icons.history_rounded),
              label: l10n?.tabHistory ?? 'History',
            ),
          ],
        ),
      ),
    );
  }

  void _showFeedbackBanner(String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 12.5,
          ),
        ),
        backgroundColor: AppColors.cardSurfaceElevated,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(color: AppColors.borderSubtle),
        ),
      ),
    );
  }
}
