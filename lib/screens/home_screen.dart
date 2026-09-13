import 'package:flutter/material.dart';
import '../core/constants/mock_scenarios.dart';
import '../core/theme/app_colors.dart';
import '../l10n/app_localizations.dart';
import '../models/ambient_context.dart';
import '../models/automation_scene.dart';
import '../models/context_guard_result.dart';
import '../models/context_result.dart';
import '../models/sensor_snapshot.dart';
import '../widgets/context_hero_card.dart';
import '../widgets/privacy_status_card.dart';
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
  final VoidCallback? onClearOverride;
  final VoidCallback? onResetCooldown;

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
    this.onClearOverride,
    this.onResetCooldown,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final recommendedScene = contextResult.recommendedScene;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Current Context Hero Card (with Confidence Gauge & Context Guard badge)
          ContextHeroCard(
            result: contextResult,
            onTapDetails: onNavigateToAi,
          ),

          const SizedBox(height: 12),

          // Connected Hardware & Privacy Badge Strip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.cardSurface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.borderSubtle),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: onNavigateToEnvironment,
                  child: const Row(
                    children: [
                      Icon(Icons.circle, color: AppColors.emeraldGreen, size: 7),
                      SizedBox(width: 4),
                      Text('iQOO 15', style: TextStyle(color: AppColors.textPrimary, fontSize: 10.5, fontWeight: FontWeight.bold)),
                      SizedBox(width: 7),
                      Icon(Icons.circle, color: AppColors.cyberCyan, size: 7),
                      SizedBox(width: 4),
                      Text('Node', style: TextStyle(color: AppColors.textPrimary, fontSize: 10.5, fontWeight: FontWeight.bold)),
                      SizedBox(width: 7),
                      Icon(Icons.circle, color: AppColors.primaryAmber, size: 7),
                      SizedBox(width: 4),
                      Text('Demo Space', style: TextStyle(color: AppColors.textPrimary, fontSize: 10.5, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.cyberCyan.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        l10n?.rulesLocal ?? 'RULES: LOCAL',
                        style: const TextStyle(color: AppColors.cyberCyan, fontSize: 9.5, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.emeraldGreen.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        l10n?.privacyLocalOnly ?? 'PRIVACY: LOCAL ONLY',
                        style: const TextStyle(color: AppColors.emeraldGreen, fontSize: 9.5, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // 2. Live Sensor Summary Strip
          SensorStatStrip(
            snapshot: sensorSnapshot,
            onTap: onNavigateToSensors,
          ),

          const SizedBox(height: 16),

          // 3. SensAura Context Guard & Explainability Card
          _buildContextGuardExplainabilityCard(context),

          const SizedBox(height: 16),

          // 4. Suggested Automation Section
          _buildSuggestedAutomationCard(context, recommendedScene),

          const SizedBox(height: 18),

          // 5. Verified Local Privacy Status Card
          const PrivacyStatusCard(),

          const SizedBox(height: 18),

          // 6. Deterministic Demo Simulation Controls (Developer Diagnostics)
          SimulationControlPanel(
            currentContext: contextResult.context,
            onSelectScenario: onInjectScenario,
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  /// Context Guard Safety & Explainability Card
  Widget _buildContextGuardExplainabilityCard(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final guard = contextResult.guardResult;
    final decision = guard.decision;
    final color = decision.color;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: color.withValues(alpha: 0.35),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.08),
            blurRadius: 16,
            spreadRadius: 1,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Shield Icon + Title + Decision Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.shield_outlined, size: 16, color: color),
                  const SizedBox(width: 8),
                  Text(
                    l10n?.contextGuardTitle ?? 'SENSAURA CONTEXT GUARD',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: color.withValues(alpha: 0.5)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(decision.iconData, size: 12, color: color),
                    const SizedBox(width: 4),
                    Text(
                      decision.getLocalizedUserBadge(l10n),
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                        color: color,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Primary Explainability Banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.cardSurfaceElevated,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.borderSubtle),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${contextResult.context.getLocalizedName(l10n).toUpperCase()} • ${contextResult.confidencePercentage} ${l10n?.confidence ?? "Confidence"}',
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  guard.explanation,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                    color: decision == ContextGuardDecision.noAction
                        ? AppColors.dangerRed
                        : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Signals Checklist & Safety Criteria Dual Section
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Column A: Signals Used
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n?.signalsDetected ?? 'SIGNALS DETECTED',
                      style: const TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                        color: AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 6),
                    ...contextResult.detectedSignals.take(3).map((sig) {
                      final isConflict = sig.contains('CONFLICT');
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              isConflict ? Icons.error_outline_rounded : Icons.check_circle_rounded,
                              size: 13,
                              color: isConflict ? AppColors.dangerRed : AppColors.emeraldGreen,
                            ),
                            const SizedBox(width: 5),
                            Expanded(
                              child: Text(
                                sig,
                                style: TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w500,
                                  color: isConflict ? AppColors.dangerRed : AppColors.textPrimary,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              // Column B: Safety Checks
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n?.guardSafetyChecks ?? 'GUARD SAFETY CHECKS',
                      style: const TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                        color: AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 6),
                    ...guard.checks.take(3).map((chk) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              chk.passed ? Icons.check_circle_rounded : Icons.cancel_rounded,
                              size: 13,
                              color: chk.passed ? AppColors.emeraldGreen : AppColors.dangerRed,
                            ),
                            const SizedBox(width: 5),
                            Expanded(
                              child: Text(
                                chk.label,
                                style: TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w500,
                                  color: chk.passed ? AppColors.textPrimary : AppColors.dangerRed,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ],
          ),

          // Actionable override or cooldown alert row
          if (decision == ContextGuardDecision.noAction) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.backgroundSecondary,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.borderSubtle),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      guard.summary,
                      style: const TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (guard.summary.contains('Manual override') && onClearOverride != null)
                    InkWell(
                      onTap: onClearOverride,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                        child: Text(
                          l10n?.releaseLock ?? 'Release Lock',
                          style: const TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.cyberCyan,
                          ),
                        ),
                      ),
                    ),
                  if (guard.summary.contains('Cooldown') && onResetCooldown != null)
                    InkWell(
                      onTap: onResetCooldown,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                        child: Text(
                          l10n?.resetTimer ?? 'Reset Timer',
                          style: const TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryAmber,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSuggestedAutomationCard(BuildContext context, AutomationScene scene) {
    final l10n = AppLocalizations.of(context);
    final accentColor = contextResult.context.color;
    final guard = contextResult.guardResult;
    final decision = guard.decision;

    // Dynamic button label and styling based on Context Guard
    String buttonText = l10n?.actionApply ?? 'APPLY SCENE';
    Color buttonColor = AppColors.primaryAmber;
    IconData buttonIcon = Icons.check_circle_rounded;

    if (decision == ContextGuardDecision.autoSafe) {
      buttonText = '${l10n?.actionApply ?? "APPLY SCENE"} (${l10n?.guardActionSafe ?? "AUTO SAFE"})';
      buttonColor = AppColors.emeraldGreen;
      buttonIcon = Icons.verified_user_rounded;
    } else if (decision == ContextGuardDecision.askUser) {
      buttonText = '${l10n?.actionApply ?? "APPLY SCENE"} (${l10n?.guardConfirmationRequired ?? "USER APPROVAL"})';
      buttonColor = AppColors.primaryAmber;
      buttonIcon = Icons.touch_app_rounded;
    } else {
      if (contextResult.context == AmbientContextType.uncertain) {
        buttonText = l10n?.signalsConflict ?? 'PAUSED • SIGNALS CONFLICT';
        buttonIcon = Icons.warning_amber_rounded;
        buttonColor = AppColors.dangerRed;
      } else if (guard.summary.contains('Manual override')) {
        buttonText = l10n?.guardManualOverride ?? 'PAUSED • MANUAL OVERRIDE';
        buttonIcon = Icons.lock_clock_rounded;
        buttonColor = AppColors.textMuted;
      } else if (guard.summary.contains('Cooldown')) {
        buttonText = l10n?.guardCooldownActive ?? 'PAUSED • COOLDOWN ACTIVE';
        buttonIcon = Icons.timer_outlined;
        buttonColor = AppColors.textMuted;
      } else {
        buttonText = l10n?.guardLowConfidence ?? 'PAUSED • LOW CONFIDENCE';
        buttonIcon = Icons.shield_outlined;
        buttonColor = AppColors.textMuted;
      }
    }

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
              Row(
                children: [
                  const Icon(Icons.bolt_rounded, size: 16, color: AppColors.primaryAmber),
                  const SizedBox(width: 8),
                  Text(
                    l10n?.suggestedAutomation ?? 'SUGGESTED AUTOMATION',
                    style: const TextStyle(
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
                child: Text(
                  l10n?.viewDevices ?? 'View Devices >',
                  style: const TextStyle(
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
          _buildTargetDeviceChips(context, scene),

          const SizedBox(height: 16),

          // Dynamic [ APPLY SCENE ] Action Button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: isApplyingScene ? null : () => onApplyScene(scene),
              style: ElevatedButton.styleFrom(
                backgroundColor: buttonColor,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
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
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(buttonIcon, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          buttonText,
                          style: const TextStyle(
                            fontSize: 13,
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

  Widget _buildTargetDeviceChips(BuildContext context, AutomationScene scene) {
    final l10n = AppLocalizations.of(context);
    final targets = scene.targetStates;
    final List<Widget> chips = [];

    final lightText = l10n?.smartLight ?? 'Light';
    final acText = l10n != null ? l10n.airConditioner.split(' ').first : 'AC';
    final speakerText = l10n?.speaker ?? 'Speaker';
    final plugText = l10n?.smartSocket ?? 'Plug';
    final offText = l10n?.stateOff ?? 'OFF';
    final onText = l10n?.stateOn ?? 'ON';

    if (targets.containsKey('light_living')) {
      final light = targets['light_living'] as Map<String, dynamic>;
      final bool on = light['isOn'] as bool? ?? false;
      chips.add(_buildActionPill('$lightText ${on ? "${light['brightness']}%" : offText}', Icons.lightbulb_outline));
    }

    if (targets.containsKey('ac_living')) {
      final ac = targets['ac_living'] as Map<String, dynamic>;
      final bool on = ac['isOn'] as bool? ?? false;
      chips.add(_buildActionPill('$acText ${on ? "${ac['temperature']}°C" : offText}', Icons.ac_unit_rounded));
    }

    if (targets.containsKey('speaker_living')) {
      final spk = targets['speaker_living'] as Map<String, dynamic>;
      final bool on = spk['isOn'] as bool? ?? false;
      chips.add(_buildActionPill('$speakerText ${on ? "${spk['volume']}%" : offText}', Icons.speaker_rounded));
    }

    if (targets.containsKey('plug_living')) {
      final plug = targets['plug_living'] as Map<String, dynamic>;
      final bool on = plug['isOn'] as bool? ?? false;
      chips.add(_buildActionPill('$plugText ${on ? onText : offText}', Icons.power_rounded));
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
