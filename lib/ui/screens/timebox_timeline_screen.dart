import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../controllers/timer_controller.dart';
import '../../core/models/timebox_preset.dart';
import '../../core/services/audio_service.dart';
import '../../core/services/haptic_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../widgets/bouncing_button.dart';
import '../widgets/glass_card.dart';

class TimeboxTimelineScreen extends StatefulWidget {
  final Function(int tabIndex) onNavigateToTimer;

  const TimeboxTimelineScreen({super.key, required this.onNavigateToTimer});

  @override
  State<TimeboxTimelineScreen> createState() => _TimeboxTimelineScreenState();
}

class _TimeboxTimelineScreenState extends State<TimeboxTimelineScreen> {
  List<TimeboxPreset> _presets = [];

  final List<Map<String, dynamic>> _dayBlocks = [
    {
      'time': '07:00 - 08:30',
      'title': 'Morning Ignition & Hydration',
      'durationMinutes': 20,
      'category': 'Vitality',
      'color': 0xFFD97706,
      'icon': CupertinoIcons.sun_max_fill,
      'isCurrent': false,
    },
    {
      'time': '09:00 - 11:30',
      'title': 'Core Deep Work Sprint #1',
      'durationMinutes': 90,
      'category': 'Deep Work',
      'color': 0xFF4F46E5,
      'icon': CupertinoIcons.bolt_fill,
      'isCurrent': true,
    },
    {
      'time': '12:30 - 13:30',
      'title': 'Midday Reset & Screen Detox',
      'durationMinutes': 25,
      'category': 'Health',
      'color': 0xFF059669,
      'icon': CupertinoIcons.leaf_arrow_circlepath,
      'isCurrent': false,
    },
    {
      'time': '14:30 - 16:30',
      'title': 'Core Deep Work Sprint #2',
      'durationMinutes': 50,
      'category': 'Deep Work',
      'color': 0xFF0284C7,
      'icon': CupertinoIcons.timer,
      'isCurrent': false,
    },
    {
      'time': '17:30 - 19:00',
      'title': 'Movement & Ergonomic Reset',
      'durationMinutes': 30,
      'category': 'Health',
      'color': 0xFF10B981,
      'icon': CupertinoIcons.heart_fill,
      'isCurrent': false,
    },
    {
      'time': '20:30 - 22:00',
      'title': 'Digital Sunset & Daily Wins Log',
      'durationMinutes': 20,
      'category': 'Mindset',
      'color': 0xFF8B5CF6,
      'icon': CupertinoIcons.moon_stars_fill,
      'isCurrent': false,
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadPresets();
  }

  Future<void> _loadPresets() async {
    try {
      final jsonStr = await rootBundle.loadString('assets/data/timebox_presets.json');
      final List<dynamic> list = json.decode(jsonStr) as List<dynamic>;
      _presets = list.map((p) => TimeboxPreset.fromJson(p as Map<String, dynamic>)).toList();
    } catch (_) {}
    setState(() {});
  }

  void _launchPreset(TimeboxPreset preset) {
    HapticService.instance.medium();
    TimerController.instance.setMode(TimerMode.focus);
    TimerController.instance.setDuration(preset.focusMinutes);

    // Try finding recommended sound
    final sound = AudioService.instance.availableSounds.firstWhere(
      (s) => s.filename == preset.recommendedSound,
      orElse: () => AudioService.instance.availableSounds.first,
    );
    TimerController.instance.setActiveSound(sound);

    widget.onNavigateToTimer(1);
  }

  void _launchBlock(Map<String, dynamic> block) {
    HapticService.instance.medium();
    TimerController.instance.setMode(TimerMode.focus);
    TimerController.instance.setDuration(block['durationMinutes'] as int);
    widget.onNavigateToTimer(1);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                Text(
                  'TIME BOXING',
                  style: AppTypography.overline.copyWith(
                    color: isDark ? AppColors.primaryCyan : AppColors.primaryIndigo,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Day Flow & Presets',
                  style: AppTypography.displayLarge.copyWith(
                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Box out distraction. Allocate high-value micro blocks to conquer your daily energy.',
                  style: AppTypography.caption.copyWith(
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                ),
                const SizedBox(height: 20),

                // Presets Carousel Section
                Text(
                  'RECOMMENDED FOCUS PROTOCOLS',
                  style: AppTypography.overline.copyWith(
                    color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
                  ),
                ),
                const SizedBox(height: 10),

                SizedBox(
                  height: 155,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    itemCount: _presets.length,
                    separatorBuilder: (context, index) => const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      final preset = _presets[index];
                      return BouncingButton(
                        onTap: () => _launchPreset(preset),
                        child: GlassCard(
                          padding: const EdgeInsets.all(16),
                          borderRadius: 22,
                          child: SizedBox(
                            width: 175,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: AppColors.primaryIndigo.withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        preset.tag,
                                        style: const TextStyle(
                                          fontSize: 9,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.primaryIndigo,
                                        ),
                                      ),
                                    ),
                                    const Icon(
                                      CupertinoIcons.play_circle_fill,
                                      color: AppColors.primaryIndigo,
                                      size: 22,
                                    ),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      preset.title,
                                      style: AppTypography.titleMedium.copyWith(
                                        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${preset.focusMinutes}m Focus · ${preset.breakMinutes}m Rest',
                                      style: AppTypography.caption.copyWith(
                                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 28),

                // Daytime Timeline Schedule
                Text(
                  'OPTIMAL DAY TIMELINE',
                  style: AppTypography.overline.copyWith(
                    color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
                  ),
                ),
                const SizedBox(height: 12),

                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _dayBlocks.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final block = _dayBlocks[index];
                    final color = Color(block['color'] as int);
                    final isCurrent = block['isCurrent'] as bool;

                    return BouncingButton(
                      onTap: () => _launchBlock(block),
                      child: GlassCard(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        borderRadius: 20,
                        backgroundColor: isCurrent
                            ? (isDark
                                ? const Color(0x334F46E5)
                                : const Color(0x144F46E5))
                            : null,
                        borderColor: isCurrent
                            ? AppColors.primaryIndigo
                            : null,
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: color.withOpacity(0.15),
                              ),
                              child: Icon(
                                block['icon'] as IconData,
                                color: color,
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        block['time'] as String,
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: color,
                                        ),
                                      ),
                                      if (isCurrent) ...[
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF10B981),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: const Text(
                                            'NOW',
                                            style: TextStyle(
                                              fontSize: 9,
                                              fontWeight: FontWeight.w800,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    block['title'] as String,
                                    style: AppTypography.titleMedium.copyWith(
                                      color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: color.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Row(
                                children: [
                                  Icon(CupertinoIcons.play_arrow_solid, size: 12, color: color),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${block['durationMinutes']}m',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: color,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
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
    );
  }
}
