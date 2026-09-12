import 'package:flutter/material.dart';
import '../core/constants/mock_scenarios.dart';
import '../core/theme/app_colors.dart';
import '../models/ambient_context.dart';

class SimulationControlPanel extends StatelessWidget {
  final AmbientContextType currentContext;
  final ValueChanged<MockScenario> onSelectScenario;

  const SimulationControlPanel({
    super.key,
    required this.currentContext,
    required this.onSelectScenario,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.science_rounded, size: 16, color: AppColors.primaryAmber),
                  SizedBox(width: 8),
                  Text(
                    'DEMO SCENARIO INJECTION',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                      color: AppColors.primaryAmber,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.backgroundSecondary,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'REAL PIPELINE',
                  style: TextStyle(
                    fontSize: 8.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textMuted,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Primary scenario simulation chips: Relaxation, Leaving, Arrival
          Row(
            children: [
              Expanded(
                child: _buildScenarioButton(
                  MockScenarios.relaxation,
                  Icons.spa_rounded,
                  AppColors.primaryAmber,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildScenarioButton(
                  MockScenarios.leaving,
                  Icons.directions_walk_rounded,
                  AppColors.dangerRed,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildScenarioButton(
                  MockScenarios.arrival,
                  Icons.home_rounded,
                  AppColors.emeraldGreen,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Secondary row: Deep Focus, Sleep Sanctuary, Uncertain Conflict
          Row(
            children: [
              Expanded(
                child: _buildScenarioButton(
                  MockScenarios.focus,
                  Icons.psychology_rounded,
                  AppColors.cyberCyan,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildScenarioButton(
                  MockScenarios.sleep,
                  Icons.bedtime_rounded,
                  AppColors.electricViolet,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildScenarioButton(
                  MockScenarios.uncertain,
                  Icons.warning_amber_rounded,
                  AppColors.statusWarning,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Neutral Reset Row
          SizedBox(
            width: double.infinity,
            child: _buildScenarioButton(
              MockScenarios.neutral,
              Icons.refresh_rounded,
              AppColors.textSecondary,
              compact: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScenarioButton(
    MockScenario scenario,
    IconData icon,
    Color color, {
    bool compact = false,
  }) {
    final isSelected = currentContext == scenario.targetContext;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onSelectScenario(scenario),
        borderRadius: BorderRadius.circular(10),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: EdgeInsets.symmetric(
            vertical: compact ? 7 : 10,
            horizontal: 6,
          ),
          decoration: BoxDecoration(
            color: isSelected ? color.withValues(alpha: 0.18) : AppColors.cardSurfaceElevated,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? color : AppColors.borderSubtle,
              width: isSelected ? 1.4 : 0.8,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: color.withValues(alpha: 0.25),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    )
                  ]
                : [],
          ),
          child: compact
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      icon,
                      size: 14,
                      color: isSelected ? color : AppColors.textSecondary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      scenario.label,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.3,
                        color: isSelected ? AppColors.textHighlight : AppColors.textSecondary,
                      ),
                    ),
                  ],
                )
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      icon,
                      size: 16,
                      color: isSelected ? color : AppColors.textSecondary,
                    ),
                    const SizedBox(height: 5),
                    Text(
                      scenario.label,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.3,
                        color: isSelected ? AppColors.textHighlight : AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
