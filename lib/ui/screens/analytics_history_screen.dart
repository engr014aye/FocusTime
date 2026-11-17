import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../controllers/stats_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../widgets/glass_card.dart';
import '../widgets/weekly_activity_chart.dart';

class AnalyticsHistoryScreen extends StatefulWidget {
  const AnalyticsHistoryScreen({super.key});

  @override
  State<AnalyticsHistoryScreen> createState() => _AnalyticsHistoryScreenState();
}

class _AnalyticsHistoryScreenState extends State<AnalyticsHistoryScreen> {
  final StatsController _statsController = StatsController.instance;

  @override
  void initState() {
    super.initState();
    _statsController.addListener(_onStatsUpdate);
    _statsController.refresh();
  }

  @override
  void dispose() {
    _statsController.removeListener(_onStatsUpdate);
    super.dispose();
  }

  void _onStatsUpdate() {
    if (mounted) setState(() {});
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color, bool isDark) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      borderRadius: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: AppTypography.displayMedium.copyWith(
              fontSize: 24,
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: AppTypography.caption.copyWith(
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primaryIndigo,
          onRefresh: () async => await _statsController.refresh(),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  Text(
                    'FOCUS INSIGHTS',
                    style: AppTypography.overline.copyWith(
                      color: isDark ? AppColors.primaryCyan : AppColors.primaryIndigo,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Analytics & Logs',
                    style: AppTypography.displayLarge.copyWith(
                      color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Metrics Grid
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'Today Focus',
                          '${_statsController.minutesToday}m',
                          CupertinoIcons.timer,
                          AppColors.primaryIndigo,
                          isDark,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          'Daily Streak',
                          '${_statsController.currentStreak} Days',
                          CupertinoIcons.flame_fill,
                          const Color(0xFFD97706),
                          isDark,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'Overall Hours',
                          '${(_statsController.minutesOverall / 60).toStringAsFixed(1)}h',
                          CupertinoIcons.bolt_fill,
                          const Color(0xFF0284C7),
                          isDark,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          'Sessions Done',
                          '${_statsController.recentSessions.length}',
                          CupertinoIcons.checkmark_seal_fill,
                          const Color(0xFF10B981),
                          isDark,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Weekly Activity Chart
                  WeeklyActivityChart(
                    activities: _statsController.weeklyActivity,
                  ),

                  const SizedBox(height: 24),

                  // Category Breakdown
                  if (_statsController.categoryMinutes.isNotEmpty) ...[
                    Text(
                      'CATEGORY TIME ALLOCATION',
                      style: AppTypography.overline.copyWith(
                        color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    GlassCard(
                      padding: const EdgeInsets.all(16),
                      borderRadius: 20,
                      child: Column(
                        children: _statsController.categoryMinutes.entries.map((entry) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 10,
                                      height: 10,
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: AppColors.primaryIndigo,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      entry.key,
                                      style: AppTypography.bodyMedium.copyWith(
                                        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  '${entry.value} min',
                                  style: AppTypography.titleMedium.copyWith(
                                    fontSize: 14,
                                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Recent Focus Sessions List
                  Text(
                    'RECENT FOCUS BLOCKS',
                    style: AppTypography.overline.copyWith(
                      color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
                    ),
                  ),
                  const SizedBox(height: 10),

                  if (_statsController.recentSessions.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 30),
                        child: Column(
                          children: [
                            Icon(
                              CupertinoIcons.timer,
                              size: 40,
                              color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'No focus sessions logged yet.\nComplete your first Pomodoro Flow block!',
                              textAlign: TextAlign.center,
                              style: AppTypography.caption.copyWith(
                                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _statsController.recentSessions.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final session = _statsController.recentSessions[index];
                        final timeStr = DateFormat('MMM d, h:mm a').format(session.completedAt);

                        return GlassCard(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          borderRadius: 18,
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryIndigo.withOpacity(0.12),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  CupertinoIcons.checkmark,
                                  color: AppColors.primaryIndigo,
                                  size: 16,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      session.title,
                                      style: AppTypography.titleMedium.copyWith(
                                        fontSize: 15,
                                        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Row(
                                      children: [
                                        Text(
                                          timeStr,
                                          style: AppTypography.caption.copyWith(
                                            color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
                                          ),
                                        ),
                                        if (session.soundscapeUsed != null) ...[
                                          const SizedBox(width: 8),
                                          Text(
                                            '· ${session.soundscapeUsed}',
                                            style: AppTypography.caption.copyWith(
                                              color: const Color(0xFF0284C7),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF10B981).withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '${session.durationMinutes}m',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF10B981),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
