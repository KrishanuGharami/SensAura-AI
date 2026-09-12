import 'package:flutter/material.dart';
import '../core/constants/mock_scenarios.dart';
import '../core/theme/app_colors.dart';
import '../models/automation_scene.dart';
import '../models/context_result.dart';
import '../models/sensor_snapshot.dart';
import '../widgets/context_hero_card.dart';
import '../widgets/sensor_stat_strip.dart';
import '../widgets/simulation_control_panel.dart';

class HomeScreen extends StatelessWidget {
  final ContextResult contextResult;
  final SensorSnapshot sensorSnapshot;
  final bool isApplyingScene;
  final ValueChanged<MockScenario> onInjectScenario;
  final ValueChanged<AutomationScene> onApplyScene;
  final VoidCallback onNavigateToSensors;
  final VoidCallback onNavigateToAi;
  final VoidCallback onNavigateToEnvironment;

  const HomeScreen({
    super.key,
    required this.contextResult,
    required this.sensorSnapshot,
    required this.isApplyingScene,
    required this.onInjectScenario,
    required this.onApplyScene,
    required this.onNavigateToSensors,
    required this.onNavigateToAi,
    required this.onNavigateToEnvironment,
  });

  @override
  Widget build(BuildContext context) {
    final recommendedScene = contextResult.recommendedScene;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Current Context Hero Card
          ContextHeroCard(
            result: contextResult,
            onTapDetails: onNavigateToAi,
          ),

          const SizedBox(height: 14),

          // Live Sensor Summary Strip (clickable to view live waveforms)
          SensorStatStrip(
            snapshot: sensorSnapshot,
            onTap: onNavigateToSensors,
          ),

          const SizedBox(height: 18),

          // Suggested Automation Section
          _buildSuggestedAutomationCard(context, recommendedScene),

          const SizedBox(height: 18),

          // Deterministic Demo Simulation Controls
          SimulationControlPanel(
            currentContext: contextResult.context,
            onSelectScenario: onInjectScenario,
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSuggestedAutomationCard(BuildContext context, AutomationScene scene) {
    final accentColor = contextResult.context.color;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.bolt_rounded, size: 16, color: AppColors.primaryAmber),
                  SizedBox(width: 8),
                  Text(
                    'SUGGESTED AUTOMATION',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                      color: AppColors.primaryAmber,
                    ),
                  ),
                ],
              ),
              InkWell(
                onTap: onNavigateToEnvironment,
                child: const Text(
                  'View Devices >',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.cyberCyan,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Scene Title + Icon
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: accentColor.withValues(alpha: 0.4)),
                ),
                child: Icon(scene.icon, size: 18, color: accentColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      scene.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      scene.description,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Target device chips
          _buildTargetDeviceChips(scene),

          const SizedBox(height: 16),

          // [ APPLY SCENE ] Action Button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: isApplyingScene ? null : () => onApplyScene(scene),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryAmber,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                shadowColor: AppColors.primaryAmberGlow,
              ),
              child: isApplyingScene
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle_rounded, size: 18),
                        SizedBox(width: 8),
                        Text(
                          'APPLY SCENE',
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTargetDeviceChips(AutomationScene scene) {
    final targets = scene.targetStates;
    final List<Widget> chips = [];

    if (targets.containsKey('light_living')) {
      final light = targets['light_living'] as Map<String, dynamic>;
      final bool on = light['isOn'] as bool? ?? false;
      chips.add(_buildActionPill('Light ${on ? "${light['brightness']}%" : "OFF"}', Icons.lightbulb_outline));
    }

    if (targets.containsKey('ac_living')) {
      final ac = targets['ac_living'] as Map<String, dynamic>;
      final bool on = ac['isOn'] as bool? ?? false;
      chips.add(_buildActionPill('AC ${on ? "${ac['temperature']}°C" : "OFF"}', Icons.ac_unit_rounded));
    }

    if (targets.containsKey('speaker_living')) {
      final spk = targets['speaker_living'] as Map<String, dynamic>;
      final bool on = spk['isOn'] as bool? ?? false;
      chips.add(_buildActionPill('Speaker ${on ? "${spk['volume']}%" : "OFF"}', Icons.speaker_rounded));
    }

    if (targets.containsKey('plug_living')) {
      final plug = targets['plug_living'] as Map<String, dynamic>;
      final bool on = plug['isOn'] as bool? ?? false;
      chips.add(_buildActionPill('Plug ${on ? "ON" : "OFF"}', Icons.power_rounded));
    }

    return Wrap(
      spacing: 8,
      runSpacing: 6,
      children: chips,
    );
  }

  Widget _buildActionPill(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.cardSurfaceElevated,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppColors.cyberCyan),
          const SizedBox(width: 5),
          Text(
            text,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
