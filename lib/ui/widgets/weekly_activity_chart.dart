import 'dart:math';
import 'package:flutter/material.dart';
import '../../controllers/stats_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import 'glass_card.dart';

class WeeklyActivityChart extends StatelessWidget {
  final List<DailyActivity> activities;

  const WeeklyActivityChart({super.key, required this.activities});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final maxMinutes = activities.isEmpty
        ? 60
        : activities.map((a) => a.focusMinutes).reduce(max);
    final chartMax = max(maxMinutes, 45);

    return GlassCard(
      padding: const EdgeInsets.all(18),
      borderRadius: 22,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Weekly Focus Flow',
                style: AppTypography.titleMedium.copyWith(
                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                ),
              ),
              Text(
                'Last 7 Days',
                style: AppTypography.caption.copyWith(
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 140,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: activities.map((act) {
                final heightFactor = (act.focusMinutes / chartMax).clamp(0.06, 1.0);
                final isToday = act == activities.last;

                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      act.focusMinutes > 0 ? '${act.focusMinutes}m' : '-',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: isToday
                            ? (isDark ? AppColors.primaryCyan : AppColors.primaryIndigo)
                            : (isDark
                                ? AppColors.darkTextTertiary
                                : AppColors.lightTextTertiary),
                      ),
                    ),
                    const SizedBox(height: 6),
                    // Bar
                    Container(
                      width: 24,
                      height: 85 * heightFactor,
                      decoration: BoxDecoration(
                        gradient: isToday
                            ? const LinearGradient(
                                colors: [Color(0xFF0284C7), Color(0xFF6366F1)],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              )
                            : LinearGradient(
                                colors: [
                                  isDark
                                      ? const Color(0xFF334155)
                                      : const Color(0xFFCBD5E1),
                                  isDark
                                      ? const Color(0xFF1E293B)
                                      : const Color(0xFFE2E8F0),
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: isToday
                            ? [
                                BoxShadow(
                                  color: const Color(0xFF0284C7).withOpacity(0.35),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                )
                              ]
                            : null,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Day Label
                    Text(
                      act.dayName,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
                        color: isToday
                            ? (isDark ? Colors.white : AppColors.primaryIndigo)
                            : (isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.lightTextSecondary),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
