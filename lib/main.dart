import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'controllers/theme_controller.dart';
import 'controllers/routine_controller.dart';
import 'controllers/timer_controller.dart';
import 'core/theme/app_theme.dart';
import 'ui/navigation/main_navigation_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Configure system navigation bar & status bar transparent styling
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarDividerColor: Colors.transparent,
    ),
  );

  // Initialize controllers
  await ThemeController.instance.init();
  await RoutineController.instance.init();
  await TimerController.instance.init();

  runApp(const FocusTimeApp());
}

class FocusTimeApp extends StatelessWidget {
  const FocusTimeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: ThemeController.instance,
      builder: (context, _) {
        final isDark = ThemeController.instance.isDarkMode;

        SystemChrome.setSystemUIOverlayStyle(
          SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
            systemNavigationBarColor: Colors.transparent,
            systemNavigationBarDividerColor: Colors.transparent,
          ),
        );

        return MaterialApp(
          title: 'FocusTime Routine',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeController.instance.themeMode,
          home: const MainNavigationScreen(),
        );
      },
    );
  }
}
