import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../services/automation_service.dart';
import '../widgets/status_app_bar.dart';
import 'ai_context_screen.dart';
import 'history_screen.dart';
import 'home_screen.dart';
import 'live_sensors_screen.dart';
import 'smart_environment_screen.dart';

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
    final screens = [
      // 1. Home
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
        onNavigateToAi: () => setState(() => _currentIndex = 2),
        onNavigateToEnvironment: () => setState(() => _currentIndex = 3),
      ),

      // 2. Live Sensors
      LiveSensorsScreen(
        snapshot: _automation.latestSnapshot,
        bleDevices: _automation.currentBleProvider.devices,
        latencyMs: _automation.latestContextResult.inferenceLatencyMs,
        isHardware: _automation.isHardwareMode,
        onToggleHardware: (val) {
          _automation.toggleHardwareMode(val);
          _showFeedbackBanner(
            val ? 'Switched to Hardware Sensors' : 'Switched to Demo Simulation',
          );
        },
      ),

      // 3. AI Context
      AiContextScreen(
        result: _automation.latestContextResult,
        isApplyingScene: _automation.isApplyingScene,
        onApplyScene: (scene) {
          _automation.applyScene(scene, manual: true);
          _showFeedbackBanner('Applied: ${scene.title}');
        },
      ),

      // 4. Smart Environment
      SmartEnvironmentScreen(
        devices: _automation.devices,
        currentScene: _automation.latestContextResult.recommendedScene,
        onUpdateDevice: (id, {isOn, primaryValue, secondaryStatus}) {
          _automation.updateDevice(
            id,
            isOn: isOn,
            primaryValue: primaryValue,
            secondaryStatus: secondaryStatus,
          );
        },
      ),

      // 5. Automation History
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
        onToggleHardware: () {
          _automation.toggleHardwareMode(!_automation.isHardwareMode);
          _showFeedbackBanner(
            _automation.isHardwareMode
                ? 'Switched to Hardware Sensors'
                : 'Switched to Demo Simulation',
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
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.sensors_outlined),
              activeIcon: Icon(Icons.sensors_rounded),
              label: 'Sensors',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.psychology_outlined),
              activeIcon: Icon(Icons.psychology_rounded),
              label: 'AI Context',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.grid_view_outlined),
              activeIcon: Icon(Icons.grid_view_rounded),
              label: 'Smart Living',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history_toggle_off_rounded),
              activeIcon: Icon(Icons.history_rounded),
              label: 'History',
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
