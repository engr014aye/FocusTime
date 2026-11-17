import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../controllers/timer_controller.dart';
import '../../core/models/routine_item.dart';
import '../../core/services/haptic_service.dart';
import '../../core/theme/app_colors.dart';
import '../screens/today_routine_screen.dart';
import '../screens/pomodoro_flow_screen.dart';
import '../screens/timebox_timeline_screen.dart';
import '../screens/analytics_history_screen.dart';
import '../screens/settings_screen.dart';
import '../widgets/bouncing_button.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  void _onTabSelected(int index) {
    if (_currentIndex != index) {
      HapticService.instance.selection();
      setState(() => _currentIndex = index);
    }
  }

  void _navigateToTimer(int tabIndex, [RoutineItem? routine]) {
    if (routine != null) {
      TimerController.instance.setActiveRoutine(routine);
    }
    _onTabSelected(tabIndex);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final screens = [
      TodayRoutineScreen(
        onNavigateToTimer: (tab, routine) => _navigateToTimer(tab, routine),
      ),
      const PomodoroFlowScreen(),
      TimeboxTimelineScreen(
        onNavigateToTimer: (tab) => _navigateToTimer(tab),
      ),
      const AnalyticsHistoryScreen(),
    ];

    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        toolbarHeight: 48,
        title: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppColors.heroGradient,
              ),
              child: const Icon(
                CupertinoIcons.timer,
                color: Colors.white,
                size: 16,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'FocusTime',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              ),
            ),
          ],
        ),
        actions: [
          BouncingButton(
            onTap: () {
              Navigator.of(context).push(
                CupertinoPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
            child: Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark
                    ? const Color(0xFF1E293B)
                    : const Color(0xFFF1F5F9),
              ),
              child: Icon(
                CupertinoIcons.gear_alt_fill,
                size: 18,
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
            ),
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.fromLTRB(18, 0, 18, 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withOpacity(0.5)
                  : const Color(0xFF64748B).withOpacity(0.12),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              height: 64,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xCC0F172A)
                    : const Color(0xE6FFFFFF),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: isDark
                      ? const Color(0x334B5563)
                      : const Color(0x33CBD5E1),
                  width: 1.0,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(0, CupertinoIcons.sun_max_fill, 'Routines', isDark),
                  _buildNavItem(1, CupertinoIcons.timer, 'Focus', isDark),
                  _buildNavItem(2, CupertinoIcons.square_grid_2x2_fill, 'Time-Box', isDark),
                  _buildNavItem(3, CupertinoIcons.chart_bar_fill, 'Insights', isDark),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label, bool isDark) {
    final isSelected = _currentIndex == index;

    return BouncingButton(
      onTap: () => _onTabSelected(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark
                  ? const Color(0x334F46E5)
                  : const Color(0x1F4F46E5))
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected
                  ? AppColors.primaryIndigo
                  : (isDark
                      ? AppColors.darkTextTertiary
                      : AppColors.lightTextTertiary),
            ),
            if (isSelected) ...[
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryIndigo,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
