import 'package:flutter/material.dart';
import 'store/app_store.dart';
import 'theme/app_theme.dart';
import 'screens/home_page.dart';

class TimetableApp extends StatelessWidget {
  const TimetableApp({super.key, required this.store});

  final AppStore store;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: store,
      builder: (context, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'CampusPulse Planner',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: store.settings.darkMode,
          home: HomePage(store: store),
        );
      },
    );
  }
}
