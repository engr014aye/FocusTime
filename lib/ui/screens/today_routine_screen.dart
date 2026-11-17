import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../controllers/routine_controller.dart';
import '../../core/models/routine_item.dart';
import '../../core/services/haptic_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../widgets/bouncing_button.dart';
import '../widgets/glass_card.dart';
import '../widgets/routine_tile.dart';
import '../widgets/add_routine_sheet.dart';

class TodayRoutineScreen extends StatefulWidget {
  final Function(int tabIndex, RoutineItem? routine) onNavigateToTimer;

  const TodayRoutineScreen({super.key, required this.onNavigateToTimer});

  @override
  State<TodayRoutineScreen> createState() => _TodayRoutineScreenState();
}

class _TodayRoutineScreenState extends State<TodayRoutineScreen> {
  final RoutineController _controller = RoutineController.instance;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onControllerUpdate);
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerUpdate);
    super.dispose();
  }

  void _onControllerUpdate() {
    if (mounted) setState(() {});
  }

  void _openAddRoutineSheet() {
    HapticService.instance.medium();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddRoutineSheet(
        onSave: (newRoutine) => _controller.addRoutine(newRoutine),
      ),
    );
  }

  Widget _buildSection(String title, String subtitle, List<RoutineItem> routines, IconData icon, Color color) {
    if (routines.isEmpty) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 16),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.titleMedium.copyWith(
                      color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: AppTypography.caption.copyWith(
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        ...routines.map((routine) {
          final completed = _controller.isCompleted(routine.id);
          return RoutineTile(
            routine: routine,
            isCompleted: completed,
            onToggle: () => _controller.toggleCompletion(routine.id),
            onStartFocus: () => widget.onNavigateToTimer(1, routine),
          );
        }),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final now = DateTime.now();
    final dateDisplay = DateFormat('EEEE, MMMM d').format(now);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          color: AppColors.primaryIndigo,
          onRefresh: () async => await _controller.refresh(),
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
            slivers: [
              // Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            dateDisplay.toUpperCase(),
                            style: AppTypography.overline.copyWith(
                              color: isDark ? AppColors.primaryCyan : AppColors.primaryIndigo,
                            ),
                          ),
                          // Streak Counter Pill
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFD97706).withOpacity(0.15),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: const Color(0xFFD97706).withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  CupertinoIcons.flame_fill,
                                  color: Color(0xFFF59E0B),
                                  size: 15,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${_controller.streakCount} Day Streak',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFFD97706),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Daily Routines',
                        style: AppTypography.displayLarge.copyWith(
                          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Progress Overview Glass Card
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  child: GlassCard(
                    padding: const EdgeInsets.all(18),
                    borderRadius: 24,
                    child: Row(
                      children: [
                        // Radial Progress Indicator
                        SizedBox(
                          width: 68,
                          height: 68,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              CircularProgressIndicator(
                                value: _controller.completionPercentage,
                                strokeWidth: 7,
                                backgroundColor: isDark
                                    ? const Color(0xFF1E293B)
                                    : const Color(0xFFE2E8F0),
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                  Color(0xFF10B981),
                                ),
                                strokeCap: StrokeCap.round,
                              ),
                              Center(
                                child: Text(
                                  '${(_controller.completionPercentage * 100).toInt()}%',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: isDark
                                        ? AppColors.darkTextPrimary
                                        : AppColors.lightTextPrimary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 18),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${_controller.completedCount} of ${_controller.totalCount} Micro-Habits Done',
                                style: AppTypography.titleMedium.copyWith(
                                  color: isDark
                                      ? AppColors.darkTextPrimary
                                      : AppColors.lightTextPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _controller.completionPercentage >= 1.0
                                    ? 'All daily blocks completed! Masterful flow.'
                                    : 'Protect your energy. Win one block at a time.',
                                style: AppTypography.caption.copyWith(
                                  color: isDark
                                      ? AppColors.darkTextSecondary
                                      : AppColors.lightTextSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Wisdom Quote Card
              if (_controller.dailyQuote != null)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    child: GlassCard(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      borderRadius: 18,
                      backgroundColor: isDark
                          ? const Color(0x1F4F46E5)
                          : const Color(0x0F4F46E5),
                      borderColor: const Color(0x334F46E5),
                      child: Row(
                        children: [
                          const Icon(
                            CupertinoIcons.quote_bubble_fill,
                            color: AppColors.primaryIndigo,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '"${_controller.dailyQuote!.quote}"',
                                  style: AppTypography.caption.copyWith(
                                    fontStyle: FontStyle.italic,
                                    color: isDark
                                        ? AppColors.darkTextPrimary
                                        : AppColors.lightTextPrimary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '— ${_controller.dailyQuote!.author}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: isDark
                                        ? AppColors.primaryCyan
                                        : AppColors.primaryIndigo,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              // Time-of-Day Blocks
              SliverToBoxAdapter(
                child: _buildSection(
                  'Morning Ignition',
                  'Awaken body and set conscious intention',
                  _controller.morningRoutines,
                  CupertinoIcons.sun_max_fill,
                  const Color(0xFFD97706),
                ),
              ),
              SliverToBoxAdapter(
                child: _buildSection(
                  'Afternoon Deep Flow',
                  'Sustained high-impact focus and reset',
                  _controller.afternoonRoutines,
                  CupertinoIcons.bolt_fill,
                  const Color(0xFF4F46E5),
                ),
              ),
              SliverToBoxAdapter(
                child: _buildSection(
                  'Evening Decompression',
                  'Recovery, reflection, and quiet rest',
                  _controller.eveningRoutines,
                  CupertinoIcons.moon_stars_fill,
                  const Color(0xFF8B5CF6),
                ),
              ),

              // Bottom Padding
              const SliverToBoxAdapter(
                child: SizedBox(height: 100),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 60),
        child: BouncingButton(
          onTap: _openAddRoutineSheet,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            decoration: BoxDecoration(
              gradient: AppColors.heroGradient,
              borderRadius: BorderRadius.circular(26),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryIndigo.withOpacity(0.4),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(CupertinoIcons.add, color: Colors.white, size: 20),
                SizedBox(width: 6),
                Text(
                  'Add Routine',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
