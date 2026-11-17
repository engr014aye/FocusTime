import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../controllers/timer_controller.dart';
import '../../core/models/routine_item.dart';
import '../../core/services/haptic_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../widgets/bouncing_button.dart';
import '../widgets/glass_card.dart';
import '../widgets/timer_dial_painter.dart';
import '../widgets/soundscape_selector_sheet.dart';

class PomodoroFlowScreen extends StatefulWidget {
  final RoutineItem? initialRoutine;

  const PomodoroFlowScreen({super.key, this.initialRoutine});

  @override
  State<PomodoroFlowScreen> createState() => _PomodoroFlowScreenState();
}

class _PomodoroFlowScreenState extends State<PomodoroFlowScreen> {
  final TimerController _timerController = TimerController.instance;

  @override
  void initState() {
    super.initState();
    _timerController.addListener(_onTimerUpdate);
    if (widget.initialRoutine != null) {
      _timerController.setActiveRoutine(widget.initialRoutine);
    }
  }

  @override
  void dispose() {
    _timerController.removeListener(_onTimerUpdate);
    super.dispose();
  }

  void _onTimerUpdate() {
    if (mounted) setState(() {});
  }

  void _openSoundscapeSheet() {
    HapticService.instance.medium();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => SoundscapeSelectorSheet(
        selectedSound: _timerController.activeSound,
        onSelect: (sound) {
          _timerController.setActiveSound(sound);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isRunning = _timerController.isRunning;
    final isPaused = _timerController.isPaused;

    Color primaryAccent;
    Color secondaryAccent;
    switch (_timerController.mode) {
      case TimerMode.focus:
        primaryAccent = AppColors.primaryIndigo;
        secondaryAccent = const Color(0xFF06B6D4);
        break;
      case TimerMode.shortBreak:
        primaryAccent = const Color(0xFF10B981);
        secondaryAccent = const Color(0xFF34D399);
        break;
      case TimerMode.longBreak:
        primaryAccent = const Color(0xFF8B5CF6);
        secondaryAccent = const Color(0xFFA78BFA);
        break;
    }

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                const SizedBox(height: 12),

                // Top Segmented Mode Selector
                SizedBox(
                  width: double.infinity,
                  child: CupertinoSlidingSegmentedControl<TimerMode>(
                    groupValue: _timerController.mode,
                    backgroundColor: isDark
                        ? const Color(0xFF1E293B)
                        : const Color(0xFFE2E8F0),
                    thumbColor: isDark
                        ? const Color(0xFF334155)
                        : Colors.white,
                    children: {
                      TimerMode.focus: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          'Focus',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                      ),
                      TimerMode.shortBreak: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          'Short Break',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                      ),
                      TimerMode.longBreak: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          'Long Break',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                      ),
                    },
                    onValueChanged: (mode) {
                      if (mode != null) {
                        HapticService.instance.selection();
                        _timerController.setMode(mode);
                      }
                    },
                  ),
                ),
                const SizedBox(height: 16),

                // Active Routine Tag or Mode Title
                if (_timerController.activeRoutine != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: _timerController.activeRoutine!.color.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _timerController.activeRoutine!.color.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _timerController.activeRoutine!.iconData,
                          size: 14,
                          color: _timerController.activeRoutine!.color,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _timerController.activeRoutine!.title,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: _timerController.activeRoutine!.color,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Text(
                    _timerController.modeLabel,
                    style: AppTypography.titleMedium.copyWith(
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    ),
                  ),

                const SizedBox(height: 20),

                // Large Interactive Circular Dial
                Center(
                  child: SizedBox(
                    width: 290,
                    height: 290,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Custom Painter
                        CustomPaint(
                          size: const Size(290, 290),
                          painter: TimerDialPainter(
                            progress: _timerController.progress,
                            isDark: isDark,
                            primaryColor: primaryAccent,
                            secondaryColor: secondaryAccent,
                          ),
                        ),

                        // Center Digital Time Display & Status
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _timerController.formattedTime,
                              style: AppTypography.heroTimer.copyWith(
                                color: isDark
                                    ? AppColors.darkTextPrimary
                                    : AppColors.lightTextPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 3),
                              decoration: BoxDecoration(
                                color: (isRunning
                                        ? const Color(0xFF10B981)
                                        : (isPaused
                                            ? const Color(0xFFF59E0B)
                                            : Colors.grey))
                                    .withOpacity(0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                isRunning
                                    ? 'FLOW STATE ACTIVE'
                                    : (isPaused ? 'PAUSED' : 'READY TO FOCUS'),
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.8,
                                  color: isRunning
                                      ? const Color(0xFF10B981)
                                      : (isPaused
                                          ? const Color(0xFFF59E0B)
                                          : (isDark
                                              ? AppColors.darkTextTertiary
                                              : AppColors.lightTextTertiary)),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Ambient Soundscapes Selector Pill
                BouncingButton(
                  onTap: _openSoundscapeSheet,
                  child: GlassCard(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    borderRadius: 20,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFF0284C7).withOpacity(0.15),
                          ),
                          child: const Icon(
                            CupertinoIcons.music_note_2,
                            size: 16,
                            color: Color(0xFF0284C7),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'AMBIENT SOUNDSCAPE',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.6,
                                color: Color(0xFF0284C7),
                              ),
                            ),
                            Text(
                              _timerController.activeSound?.name ?? 'Select Soundscape',
                              style: AppTypography.titleMedium.copyWith(
                                fontSize: 14,
                                color: isDark
                                    ? AppColors.darkTextPrimary
                                    : AppColors.lightTextPrimary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 14),
                        Icon(
                          CupertinoIcons.chevron_down,
                          size: 14,
                          color: isDark
                              ? AppColors.darkTextTertiary
                              : AppColors.lightTextTertiary,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Primary Controls (Play / Pause / Reset / Skip)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Reset Button
                    BouncingButton(
                      onTap: _timerController.resetTimer,
                      child: Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isDark
                              ? const Color(0xFF1E293B)
                              : const Color(0xFFF1F5F9),
                          border: Border.all(
                            color: isDark
                                ? const Color(0xFF334155)
                                : const Color(0xFFCBD5E1),
                          ),
                        ),
                        child: Icon(
                          CupertinoIcons.arrow_counterclockwise,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary,
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: 24),

                    // Main Start / Pause Action Button
                    BouncingButton(
                      onTap: () {
                        if (isRunning) {
                          _timerController.pauseTimer();
                        } else {
                          _timerController.startTimer();
                        }
                      },
                      child: Container(
                        width: 78,
                        height: 78,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [primaryAccent, secondaryAccent],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: primaryAccent.withOpacity(0.4),
                              blurRadius: 20,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Icon(
                            isRunning
                                ? CupertinoIcons.pause_fill
                                : CupertinoIcons.play_fill,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 24),

                    // Skip Button
                    BouncingButton(
                      onTap: _timerController.skipTimer,
                      child: Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isDark
                              ? const Color(0xFF1E293B)
                              : const Color(0xFFF1F5F9),
                          border: Border.all(
                            color: isDark
                                ? const Color(0xFF334155)
                                : const Color(0xFFCBD5E1),
                          ),
                        ),
                        child: Icon(
                          CupertinoIcons.forward_fill,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Quick Duration Presets (Only enabled when timer is idle)
                if (_timerController.isIdle && _timerController.mode == TimerMode.focus) ...[
                  Text(
                    'FOCUS PRESETS',
                    style: AppTypography.overline.copyWith(
                      color: isDark
                          ? AppColors.darkTextTertiary
                          : AppColors.lightTextTertiary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [15, 25, 45, 60, 90].map((mins) {
                      final isSelected =
                          _timerController.targetSeconds == mins * 60;
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: BouncingButton(
                          onTap: () {
                            HapticService.instance.selection();
                            _timerController.setDuration(mins);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? primaryAccent
                                  : (isDark
                                      ? const Color(0xFF1E293B)
                                      : const Color(0xFFF1F5F9)),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: isSelected
                                    ? primaryAccent
                                    : (isDark
                                        ? const Color(0xFF334155)
                                        : const Color(0xFFE2E8F0)),
                              ),
                            ),
                            child: Text(
                              '${mins}m',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: isSelected
                                    ? Colors.white
                                    : (isDark
                                        ? AppColors.darkTextSecondary
                                        : AppColors.lightTextSecondary),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],

                const SizedBox(height: 24),

                // Daily Session Count Pill
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0x1FFFFFFF)
                        : const Color(0x0A000000),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        CupertinoIcons.checkmark_seal_fill,
                        color: Color(0xFF10B981),
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${_timerController.sessionsCompletedToday} Focus Sessions Completed Today',
                        style: AppTypography.caption.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
