import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../core/models/routine_item.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import 'bouncing_button.dart';
import 'glass_card.dart';

class RoutineTile extends StatelessWidget {
  final RoutineItem routine;
  final bool isCompleted;
  final VoidCallback onToggle;
  final VoidCallback onStartFocus;

  const RoutineTile({
    super.key,
    required this.routine,
    required this.isCompleted,
    required this.onToggle,
    required this.onStartFocus,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: GlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        borderRadius: 20,
        backgroundColor: isCompleted
            ? (isDark
                ? const Color(0x1A10B981)
                : const Color(0x1410B981))
            : null,
        borderColor: isCompleted
            ? const Color(0x6610B981)
            : null,
        child: Row(
          children: [
            // 1. Completion Checkbox Circle
            BouncingButton(
              onTap: onToggle,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutBack,
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isCompleted
                      ? const Color(0xFF10B981)
                      : (isDark
                          ? const Color(0x1FFFFFFF)
                          : const Color(0x0F000000)),
                  border: Border.all(
                    color: isCompleted
                        ? const Color(0xFF10B981)
                        : (isDark
                            ? const Color(0x409CA3AF)
                            : const Color(0x4064748B)),
                    width: 2,
                  ),
                ),
                child: Center(
                  child: isCompleted
                      ? const Icon(
                          CupertinoIcons.checkmark_alt,
                          color: Colors.white,
                          size: 22,
                        )
                      : Icon(
                          routine.iconData,
                          color: routine.color,
                          size: 18,
                        ),
                ),
              ),
            ),
            const SizedBox(width: 14),

            // 2. Title & Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    routine.title,
                    style: AppTypography.titleMedium.copyWith(
                      color: isCompleted
                          ? (isDark
                              ? AppColors.darkTextTertiary
                              : AppColors.lightTextTertiary)
                          : (isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.lightTextPrimary),
                      decoration: isCompleted
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                      decorationColor: const Color(0xFF10B981),
                    ),
                  ),
                  if (routine.subtitle.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(
                      routine.subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.caption.copyWith(
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                      ),
                    ),
                  ],
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      // Category Pill
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: routine.color.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          routine.category,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: routine.color,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Target minutes
                      Row(
                        children: [
                          Icon(
                            CupertinoIcons.stopwatch,
                            size: 12,
                            color: isDark
                                ? AppColors.darkTextTertiary
                                : AppColors.lightTextTertiary,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            '${routine.targetMinutes}m',
                            style: AppTypography.caption.copyWith(
                              color: isDark
                                  ? AppColors.darkTextTertiary
                                  : AppColors.lightTextTertiary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),

            // 3. Start Focus Pomodoro Flow Button
            BouncingButton(
              onTap: onStartFocus,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      routine.color,
                      routine.color.withOpacity(0.85),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: routine.color.withOpacity(0.25),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      CupertinoIcons.play_fill,
                      color: Colors.white,
                      size: 12,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Focus',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
