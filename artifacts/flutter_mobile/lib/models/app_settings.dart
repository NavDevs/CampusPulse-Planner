import 'package:flutter/material.dart';

class AppSettings {
  AppSettings({
    required this.notificationsEnabled,
    required this.classReminderMinutes,
    required this.darkMode,
  });

  bool notificationsEnabled;
  int classReminderMinutes;
  ThemeMode darkMode;

  Map<String, dynamic> toJson() => {
    'notificationsEnabled': notificationsEnabled,
    'classReminderMinutes': classReminderMinutes,
    'darkMode': darkMode.name,
  };

  factory AppSettings.fromJson(Map<String, dynamic> json) => AppSettings(
    notificationsEnabled: json['notificationsEnabled'] as bool? ?? true,
    classReminderMinutes: json['classReminderMinutes'] as int? ?? 15,
    darkMode: _themeModeFrom(json['darkMode'] as String? ?? 'system'),
  );

  static ThemeMode _themeModeFrom(String raw) {
    switch (raw) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }
}
